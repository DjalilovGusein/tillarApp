//
//  Model.swift
//  Tillar
//
//  Created by Gusein Djalilov on 21/01/26.
//

import Foundation

// MARK: - Common

struct APIEnvelope<T: Decodable>: Decodable {
    let success: Bool?
    let status: Int?
    let message: String?
    let data: T?
}

struct APIMessage: Decodable {
    let success: Bool?
    let message: String?
}

struct ErrorResponse: Decodable {
    let errors: [String]?
}

// MARK: - Auth / Keycloak

struct RegisterRequest: Encodable {
    let username: String
    let email: String
    let password: String
    let firstName: String
    let lastName: String

    enum CodingKeys: String, CodingKey {
        case username, email, password
        case firstName = "first_name"
        case lastName  = "last_name"
    }
}

struct LoginRequest: Encodable {
    let username: String
    let password: String
}

struct RefreshRequest: Encodable {
    let refreshToken: String
    enum CodingKeys: String, CodingKey { case refreshToken = "refresh_token" }
}

struct AuthTokens: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int?
    let tokenType: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

struct AuthUser: Decodable {
    let id: Int?
    let username: String?
    let email: String?
    let firstName: String?
    let lastName: String?
    let isActive: Bool?
    let isStaff: Bool?
    let keycloakUUID: String?

    enum CodingKeys: String, CodingKey {
        case id, username, email
        case firstName = "first_name"
        case lastName  = "last_name"
        case isActive  = "is_active"
        case isStaff   = "is_staff"
        case keycloakUUID = "keycloak_uuid"
    }
}

struct LoginResponse: Decodable {
    let success: Bool?
    let message: String?
    let user: AuthUser?
    let tokens: AuthTokens?
}

// MARK: - Microservices Proxy

struct MicroserviceProxyRequest: Encodable {
    let service: String
    let method: String     // "GET" / "POST" как строка (в Postman так) :contentReference[oaicite:5]{index=5}
    let endpoint: String
    let userId: Bool
}

// Пример: Coins баланс (в ответе у тебя может быть любой формат — ниже самый безопасный вариант)
struct CoinsBalanceResponse: Decodable {
    let success: Bool?
    let status: Int?
    let data: CoinsBalanceData?
}

struct CoinsBalanceData: Decodable {
    let coins: Int?
    let balance: Int?
    let amount: Int?
}

// MARK: - News

struct NewsListResponse: Decodable {
    let success: Bool?
    let status: Int?
    let data: NewsListData?
}

struct NewsListData: Decodable {
    let content: [NewsItem]?
    let totalPages: Int?
    let totalElements: Int?
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
