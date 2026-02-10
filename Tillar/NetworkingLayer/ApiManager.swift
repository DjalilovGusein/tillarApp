//
//  ApiManager.swift
//  Tillar
//
//  Created by Gusein Djalilov on 21/01/26.
//

import Foundation
import Alamofire

public enum NetworkError: Error, LocalizedError {
    case badRequest, unauthorized, forbidden, notFound, serverError
    case unknownError
    case decodingError
    case custom(status: Int, body: Data?)

    public var errorDescription: String? {
        switch self {
        case .badRequest: return "Bad request"
        case .unauthorized: return "Unauthorized"
        case .forbidden: return "Forbidden"
        case .notFound: return "Not found"
        case .serverError: return "Server error"
        case .unknownError: return "Unknown error"
        case .decodingError: return "Decoding error"
        case .custom(let s, _): return "HTTP \(s)"
        }
    }
}

final class APIManager {

    static let shared = APIManager()

    // ⚠️ Поставь свой host. Дальше мы добавляем path вида "/api/keycloak/..."
    private let baseURL = "https://api.test.hayotex.uz"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    private let session: Session = {
        let cfg = URLSessionConfiguration.af.default
        cfg.timeoutIntervalForRequest = 30
        // чтобы CSRF cookie мог сохраняться между запросами
        cfg.httpCookieStorage = .shared
        return Session(configuration: cfg)
    }()

    private init() {}

    // MARK: - Headers

    private func defaultHeaders(needsAuth: Bool, needsCSRF: Bool) -> HTTPHeaders {
        var headers: HTTPHeaders = ["Content-Type": "application/json"]

        if needsAuth, !UD.accessToken.isEmpty {
            headers.add(.authorization(bearerToken: UD.accessToken))
        }

        // Postman использует X-CSRFToken :contentReference[oaicite:6]{index=6}
        if needsCSRF, !UD.csrfToken.isEmpty {
            headers.add(name: "X-CSRFToken", value: UD.csrfToken)
        }

        return headers
    }

    // MARK: - Generic request

    typealias Completion<T> = (Result<T, NetworkError>) -> Void

    func request<T: Decodable>(
        _ path: String,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        needsAuth: Bool = true,
        needsCSRF: Bool = false,
        completion: @escaping Completion<T>
    ) {
        let url = baseURL + path

        session.request(
            url,
            method: method,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: defaultHeaders(needsAuth: needsAuth, needsCSRF: needsCSRF)
        )
        .validate()
        .responseData { [weak self] response in
            guard let self else { return }

            switch response.result {
            case .success(let data):
                do {
                    let decoded = try self.decoder.decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.decodingError))
                }

            case .failure:
                let status = response.response?.statusCode ?? -1
                completion(.failure(self.map(status: status, body: response.data)))
            }
        }
    }

    private func map(status: Int, body: Data?) -> NetworkError {
        switch status {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 500...599: return .serverError
        default: return .custom(status: status, body: body)
        }
    }
}

// MARK: - Endpoints

extension APIManager {

    // Если у тебя есть отдельный эндпоинт для csrf — просто сюда вставишь.
    // Сейчас мы умеем сохранять csrf из CookieStorage если бэк ставит csrftoken.
    func syncCSRFFromCookies(for domainContains: String) {
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        if let csrf = cookies.first(where: { $0.name.lowercased() == "csrftoken" && $0.domain.contains(domainContains) }) {
            UD.csrfToken = csrf.value
        }
    }

    // Register: POST /api/keycloak/register/ :contentReference[oaicite:7]{index=7}
    func register(_ req: RegisterRequest, completion: @escaping Completion<APIEnvelope<AuthUser>>) {
        request(
            "/api/keycloak/register/",
            method: .post,
            parameters: req.dictionary,
            needsAuth: false,
            needsCSRF: true,
            completion: completion
        )
    }

    // Login (в коллекции есть ответ с user + tokens) :contentReference[oaicite:8]{index=8}
    func login(_ req: LoginRequest, completion: @escaping Completion<LoginResponse>) {
        request(
            "/api/keycloak/login/",
            method: .post,
            parameters: req.dictionary,
            needsAuth: false,
            needsCSRF: true,
            completion: completion
        )
    }

    // Refresh: POST /api/keycloak/refresh/ :contentReference[oaicite:9]{index=9}
    func refreshToken(completion: @escaping Completion<APIEnvelope<AuthTokens>>) {
        let req = RefreshRequest(refreshToken: UD.refreshToken)
        request(
            "/api/keycloak/refresh/",
            method: .post,
            parameters: req.dictionary,
            needsAuth: true,
            needsCSRF: true,
            completion: completion
        )
    }

    // UserInfo: GET /api/keycloak/userinfo/ :contentReference[oaicite:10]{index=10}
    func userInfo(completion: @escaping Completion<AuthUser>) {
        request(
            "/api/keycloak/userinfo/",
            method: .get,
            parameters: nil,
            needsAuth: true,
            needsCSRF: false,
            completion: completion
        )
    }

    // Microservices proxy: POST /api/microservices/proxy/ + body {service,method,endpoint,userId} :contentReference[oaicite:11]{index=11}
    func microserviceProxy<T: Decodable>(
        _ req: MicroserviceProxyRequest,
        completion: @escaping Completion<T>
    ) {
        request(
            "/api/microservices/proxy/",
            method: .post,
            parameters: req.dictionary,
            needsAuth: true,
            needsCSRF: true,
            completion: completion
        )
    }

    // Coins example: service=coins, method=GET, endpoint=/v1/coins, userId=true :contentReference[oaicite:12]{index=12}
    func getCoinsBalance(completion: @escaping Completion<CoinsBalanceResponse>) {
        let req = MicroserviceProxyRequest(service: "coins", method: "GET", endpoint: "/v1/coins", userId: true)
        microserviceProxy(req, completion: completion)
    }

    // News list (путь может отличаться — в коллекции видно структуру ответа) :contentReference[oaicite:13]{index=13}
    func getNewsList(page: Int = 0, size: Int = 20, completion: @escaping Completion<NewsListResponse>) {
        // если у вас это отдельный эндпоинт, поправишь path/params
        request(
            "/api/news/?page=\(page)&size=\(size)",
            method: .get,
            parameters: nil,
            needsAuth: true,
            needsCSRF: false,
            completion: completion
        )
    }
}

// MARK: - Encodable -> Parameters (как у тебя)

extension Encodable {
    var dictionary: Parameters? {
        guard let data = try? JSONEncoder().encode(self),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let dict = obj as? Parameters
        else { return nil }
        return dict
    }
}
