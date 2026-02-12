//
//  APIManager.swift
//  Tillar
//
//  Created by Gusein Djalilov on 21/01/26.
//

import Foundation
import Alamofire

public enum NetworkError: Error, LocalizedError {
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case decodingError
    case transport(Error)             // AF/URLSession error
    case backend(message: String)     // ошибка из ErrorResponse
    case custom(status: Int, body: Data?)

    public var errorDescription: String? {
        switch self {
        case .badRequest: return "Bad request"
        case .unauthorized: return "Unauthorized"
        case .forbidden: return "Forbidden"
        case .notFound: return "Not found"
        case .serverError: return "Server error"
        case .decodingError: return "Decoding error"
        case .transport(let e): return e.localizedDescription
        case .backend(let msg): return msg
        case .custom(let s, _): return "HTTP \(s)"
        }
    }
}

final class APIManager {

    static let shared = APIManager()

    // host без завершающего "/"
    private let baseURL = "https://api.test.hayotex.uz"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

    private let session: Session = {
        let cfg = URLSessionConfiguration.af.default
        cfg.timeoutIntervalForRequest = 30
        cfg.httpCookieStorage = .shared
        return Session(configuration: cfg)
    }()

    private init() {}

    // MARK: - Public toggles (если хочешь подцепить Loader/Toast)
    var onShowLoader: (() -> Void)?
    var onHideLoader: (() -> Void)?
    var onShowMessage: ((String) -> Void)?

    // MARK: - Headers

    private func headers(needsAuth: Bool, needsCSRF: Bool) -> HTTPHeaders {
        var h: HTTPHeaders = ["Content-Type": "application/json"]

        if needsAuth, !UD.accessToken.isEmpty {
            h.add(.authorization(bearerToken: UD.accessToken))
        }

        // Postman: X-CSRFToken, токен в cookie "csrftoken" :contentReference[oaicite:0]{index=0}
        if needsCSRF {
            syncCSRFFromCookies(domainContains: URL(string: baseURL)?.host ?? "")
            if !UD.csrfToken.isEmpty {
                h.add(name: "X-CSRFToken", value: UD.csrfToken)
            }
        }

        return h
    }

    // MARK: - Generic request with retry

    typealias Completion<T> = (Result<T, NetworkError>) -> Void

    func request<T: Decodable>(
        _ path: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        needsAuth: Bool = true,
        needsCSRF: Bool = false,
        completion: @escaping Completion<T>
    ) {
        requestWithRetry(
            path,
            method: method,
            parameters: parameters,
            needsAuth: needsAuth,
            needsCSRF: needsCSRF,
            retryCount: 0,
            completion: completion
        )
    }

    private func requestWithRetry<T: Decodable>(
        _ path: String,
        method: HTTPMethod,
        parameters: Parameters?,
        needsAuth: Bool,
        needsCSRF: Bool,
        retryCount: Int,
        completion: @escaping Completion<T>
    ) {
        let fullURL = baseURL + path
        let httpHeaders = headers(needsAuth: needsAuth, needsCSRF: needsCSRF)

        debugPrint("🚀 \(method.rawValue) \(fullURL) (retry: \(retryCount))")
        if let parameters {
            debugPrint("➡️ Params: \(parameters)")
        }

        onShowLoader?()

        session.request(
            fullURL,
            method: method,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: httpHeaders
        )
        .responseData { [weak self] response in
            guard let self else { return }
            self.onHideLoader?()

            if let data = response.data, let json = String(data: data, encoding: .utf8) {
                debugPrint("📥 Response:\n\(json)")
            }

            let status = response.response?.statusCode

            // 1) Если 401 — пробуем refresh один раз и повторяем запрос
            if status == 401, retryCount == 0 {
                debugPrint("🔐 401. Refreshing token…")
                self.refreshAccessToken { ok in
                    guard ok else {
                        completion(.failure(.unauthorized))
                        return
                    }
                    self.requestWithRetry(
                        path,
                        method: method,
                        parameters: parameters,
                        needsAuth: needsAuth,
                        needsCSRF: needsCSRF,
                        retryCount: retryCount + 1,
                        completion: completion
                    )
                }
                return
            }

            // 2) Иногда бэк может вернуть 200/4xx с errors=["Время действия токена истекло"]
            if retryCount == 0,
               let data = response.data,
               let apiErr = try? self.decoder.decode(ErrorResponse.self, from: data),
               let msg = apiErr.errors?.first,
               msg.localizedCaseInsensitiveContains("Время действия токена истекло") {
                debugPrint("🔐 Token expired in body. Refreshing…")
                self.refreshAccessToken { ok in
                    guard ok else {
                        completion(.failure(.unauthorized))
                        return
                    }
                    self.requestWithRetry(
                        path,
                        method: method,
                        parameters: parameters,
                        needsAuth: needsAuth,
                        needsCSRF: needsCSRF,
                        retryCount: retryCount + 1,
                        completion: completion
                    )
                }
                return
            }

            // 3) Декод + маппинг ошибок
            switch response.result {
            case .success(let data):
                // если statusCode плохой — вернем mapped error + покажем msg из ErrorResponse
                if let status, !(200...299).contains(status) {
                    if let msg = self.extractBackendMessage(from: data) {
                        self.onShowMessage?(msg)
                        completion(.failure(.backend(message: msg)))
                        return
                    }
                    completion(.failure(self.map(status: status, body: data)))
                    return
                }

                do {
                    let decoded = try self.decoder.decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.decodingError))
                }

            case .failure(let afError):
                // если есть errors[] — покажем
                if let data = response.data, let msg = self.extractBackendMessage(from: data) {
                    self.onShowMessage?(msg)
                    completion(.failure(.backend(message: msg)))
                } else {
                    completion(.failure(.transport(afError)))
                }
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

    private func extractBackendMessage(from data: Data) -> String? {
        if let apiErr = try? decoder.decode(ErrorResponse.self, from: data),
           let msg = apiErr.errors?.first,
           !msg.isEmpty {
            return msg
        }
        return nil
    }
}

// MARK: - CSRF

extension APIManager {

    /// В Postman перед логином/регистрацией сначала дергают /api/keycloak/csrf/ :contentReference[oaicite:1]{index=1}
    func getCSRFToken(completion: @escaping Completion<APISuccessMessage>) {
        request(
            "/api/keycloak/csrf/",
            method: .get,
            parameters: nil,
            needsAuth: false,
            needsCSRF: false
        ) { [weak self] (result: Result<APISuccessMessage, NetworkError>) in
            self?.syncCSRFFromCookies(domainContains: URL(string: self?.baseURL ?? "")?.host ?? "")
            completion(result)
        }
    }

    func syncCSRFFromCookies(domainContains: String) {
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        if let csrf = cookies.first(where: {
            $0.name.lowercased() == "csrftoken" && $0.domain.contains(domainContains)
        }) {
            UD.csrfToken = csrf.value
        }
    }
}

// MARK: - Auth endpoints

extension APIManager {

    func register(_ req: RegisterRequest, completion: @escaping Completion<RegisterResponse>) {
        request(
            "/api/keycloak/register/",
            method: .post,
            parameters: req.dictionary(using: encoder),
            needsAuth: false,
            needsCSRF: true,
            completion: completion
        )
    }

    func login(_ req: LoginRequest, completion: @escaping Completion<LoginResponse>) {
        request(
            "/api/keycloak/login/",
            method: .post,
            parameters: req.dictionary(using: encoder),
            needsAuth: false,
            needsCSRF: true,
            completion: completion
        )
    }

    func userInfo(completion: @escaping Completion<UserInfoResponse>) {
        request(
            "/api/keycloak/userinfo/",
            method: .get,
            parameters: nil,
            needsAuth: true,
            needsCSRF: false,
            completion: completion
        )
    }

    func logout(completion: @escaping Completion<APISuccessMessage>) {
        request(
            "/api/keycloak/logout/",
            method: .post,
            parameters: nil,
            needsAuth: true,
            needsCSRF: true,
            completion: completion
        )
    }

    // MARK: - Refresh (internal)

    private func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard !UD.refreshToken.isEmpty else {
            completion(false)
            return
        }

        let body = RefreshRequest(refreshToken: UD.refreshToken)

        // В Postman refresh требует Authorization + X-CSRFToken :contentReference[oaicite:2]{index=2}
        request(
            "/api/keycloak/refresh/",
            method: .post,
            parameters: body.dictionary(using: encoder),
            needsAuth: true,
            needsCSRF: true
        ) { [weak self] (result: Result<RefreshResponse, NetworkError>) in
            guard let self else { completion(false); return }

            switch result {
            case .success(let resp):
                if let tokens = resp.tokens {
                    UD.accessToken = tokens.accessToken ?? ""
                    UD.refreshToken = tokens.refreshToken ?? UD.refreshToken
                    self.syncCSRFFromCookies(domainContains: URL(string: self.baseURL)?.host ?? "")
                    completion(!UD.accessToken.isEmpty)
                } else {
                    completion(false)
                }

            case .failure:
                completion(false)
            }
        }
    }
}

// MARK: - Microservices proxy

extension APIManager {

    func microserviceProxy<T: Decodable>(
        _ req: MicroserviceProxyRequest,
        completion: @escaping Completion<T>
    ) {
        request(
            "/api/microservices/proxy/",
            method: .post,
            parameters: req.dictionary(using: encoder),
            needsAuth: true,
            needsCSRF: true,
            completion: completion
        )
    }

    func getCoinsBalance(completion: @escaping Completion<CoinsBalanceResponse>) {
        let req = MicroserviceProxyRequest(
            service: "coins",
            method: "GET",
            endpoint: "/v1/coins",
            userId: true,
            data: nil
        )
        microserviceProxy(req, completion: completion)
    }

    func getNewsList(completion: @escaping Completion<NewsListResponse>) {
        // В Postman новости ходят через proxy: service=news, endpoint=/api/v1/news :contentReference[oaicite:3]{index=3}
        let req = MicroserviceProxyRequest(
            service: "news",
            method: "GET",
            endpoint: "/api/v1/news",
            userId: nil,
            data: nil
        )
        microserviceProxy(req, completion: completion)
    }

    func sendToAIBot(botId: String, message: String, completion: @escaping Completion<AIBotResponse>) {
        let req = MicroserviceProxyRequest(
            service: "aibot",
            method: "POST",
            endpoint: "/ai/\(botId)",
            userId: true,
            data: ["message": AnyCodable(message)]
        )
        microserviceProxy(req, completion: completion)
    }
}

// MARK: - Encodable -> Parameters

extension Encodable {
    func dictionary(using encoder: JSONEncoder = JSONEncoder()) -> Parameters? {
        guard let data = try? encoder.encode(self),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let dict = obj as? Parameters
        else { return nil }
        return dict
    }
}
