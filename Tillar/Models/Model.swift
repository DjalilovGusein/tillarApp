//
//  Model.swift
//  Tillar
//
//  Created by Gusein Djalilov on 21/01/26.
//

import Foundation

// MARK: - Common

struct ErrorResponse: Decodable {
    let errors: [String]?
}

struct APISuccessMessage: Decodable {
    let success: Bool?
    let message: String?
}

// MARK: - Auth

struct RegisterRequest: Encodable {
    let username: String
    let email: String
    let password: String
    let firstName: String
    let lastName: String
}

struct LoginRequest: Encodable {
    let username: String
    let password: String
}

struct RefreshRequest: Encodable {
    let refreshToken: String
}

struct AuthTokens: Decodable {
    let accessToken: String?
    let refreshToken: String?
    let expiresIn: Int?
    let tokenType: String?
}

struct AuthUser: Decodable {
    let id: Int?
    let username: String?
    let email: String?
    let firstName: String?
    let lastName: String?
    let isActive: Bool?
    let isStaff: Bool?
    let keycloakUuid: String?
}

// POST /api/keycloak/register/
struct RegisterResponse: Decodable {
    let success: Bool?
    let message: String?
    let emailVerificationRequired: Bool?
    let emailVerificationSent: Bool?
    let user: AuthUser?
    let tokens: AuthTokens?
}

// POST /api/keycloak/login/
struct LoginResponse: Decodable {
    let success: Bool?
    let message: String?
    let user: AuthUser?
    let tokens: AuthTokens?
}

// POST /api/keycloak/refresh/
struct RefreshResponse: Decodable {
    let success: Bool?
    let tokens: AuthTokens?
}

// GET /api/keycloak/userinfo/
struct UserInfoResponse: Decodable {
    let success: Bool?
    let user: AuthUser?
}

// MARK: - Microservices Proxy

struct MicroserviceProxyRequest: Encodable {
    let service: String
    let method: String       // "GET"/"POST"
    let endpoint: String
    let userId: Bool?
    let data: [String: AnyCodable]?
}

// MARK: - Coins

// coins: data приходит массивом [{coinId, amount}] :contentReference[oaicite:4]{index=4}
struct CoinsBalanceResponse: Decodable {
    let success: Bool?
    let status: Int?
    let data: [CoinBalanceItem]?
}

struct CoinBalanceItem: Decodable, Identifiable {
    var id: Int { coinId ?? 0 }
    let coinId: Int?
    let amount: Int?
}

// MARK: - News (через proxy)

struct NewsListResponse: Decodable {
    let success: Bool?
    let status: Int?
    let data: NewsListData?
}

struct NewsListData: Decodable {
    let content: [NewsItem]?
    let totalPages: Int?
    let totalElements: Int?
    let numberOfElements: Int?
    let size: Int?
    let number: Int?
    let first: Bool?
    let last: Bool?
    let empty: Bool?
}

struct NewsItem: Decodable, Identifiable {
    let id: Int
    let translation: NewsTranslation?
    let status: String?
    let authorId: Int?
    let category: String?
    let tags: [String]?
    let imageUrl: String?
    let featured: Bool?
    let createdAt: String?
    let updatedAt: String?
    let publishedAt: String?
    let availableLanguages: [String]?
}

struct NewsTranslation: Decodable {
    let id: Int?
    let language: String?
    let title: String?
    let summary: String?
    let content: String?
    let localizedSlug: String?
}

// MARK: - AI Bot (пример — подстрой под свой ответ)

struct AIBotResponse: Decodable {
    let success: Bool?
    let status: Int?
    let data: AIBotData?
}

struct AIBotData: Decodable {
    let message: String?
    let answer: String?
}

// MARK: - AnyCodable for `data` in microservice proxy

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) { self.value = value }

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()

        if let v = try? c.decode(Bool.self) { value = v; return }
        if let v = try? c.decode(Int.self) { value = v; return }
        if let v = try? c.decode(Double.self) { value = v; return }
        if let v = try? c.decode(String.self) { value = v; return }
        if let v = try? c.decode([AnyCodable].self) { value = v.map { $0.value }; return }
        if let v = try? c.decode([String: AnyCodable].self) { value = v.mapValues { $0.value }; return }

        value = NSNull()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()

        switch value {
        case let v as Bool: try c.encode(v)
        case let v as Int: try c.encode(v)
        case let v as Double: try c.encode(v)
        case let v as String: try c.encode(v)
        case let v as [Any]:
            try c.encode(v.map { AnyCodable($0) })
        case let v as [String: Any]:
            try c.encode(v.mapValues { AnyCodable($0) })
        default:
            try c.encodeNil()
        }
    }
}
