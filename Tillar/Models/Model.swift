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



struct translateRequest: Codable {
    let text: String,
        targetLanguage: String,
        sourceLanguage: String
}

struct translateResponse: Codable {
    let success: Bool?
    let data: translateDataStream?
    let status: Int?
}

struct translateDataStream: Codable {
    let translatedText: String?,
        detectedSourceLanguage: String?,
        targetLanguage: String?,
        originalText: String?
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
    let error: String?
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

struct CoursesResponse: Codable {
    let success: Bool
    let overall: Overall
    let courses: [Course]
}

// MARK: - Overall
struct Overall: Codable {
    let averageGrade: Double
    let totalCourses: Int
    let activeCourses: Int
    let completedCourses: Int
    let averageCompletion: Int
    let totalUnitsComplete: Int
    let totalUnits: Int
    let certificatesEarned: Int
    
    enum CodingKeys: String, CodingKey {
        case averageGrade = "average_grade"
        case totalCourses = "total_courses"
        case activeCourses = "active_courses"
        case completedCourses = "completed_courses"
        case averageCompletion = "average_completion"
        case totalUnitsComplete = "total_units_complete"
        case totalUnits = "total_units"
        case certificatesEarned = "certificates_earned"
    }
}

// MARK: - Course
struct Course: Codable {
    let course_id: String
    let courseName: String
    let grade: Double
    let completionPercent: Int
    let unitsComplete: Int
    let unitsTotal: Int
    let certificateStatus: String?
    let enrollmentMode: String
    
    enum CodingKeys: String, CodingKey {
        case courseName = "course_name"
        case grade
        case course_id = "course_id"
        case completionPercent = "completion_percent"
        case unitsComplete = "units_complete"
        case unitsTotal = "units_total"
        case certificateStatus = "certificate_status"
        case enrollmentMode = "enrollment_mode"
    }
}

struct FrazesResponse: Codable {
    let success: Bool?
    let status: Int?
    let data: [Fraze]?
}

struct Fraze: Codable {
    let id: Int?
    let name: String?
    let iconUrl: String?
}

struct СategoriesResponse: Codable {
    let next: String?
    let previous: String?
    let count: Int
    let numPages: Int
    let currentPage: Int
    let start: Int
    let results: [Subject]
    
    enum CodingKeys: String, CodingKey {
        case next
        case previous
        case count
        case numPages = "num_pages"
        case currentPage = "current_page"
        case start
        case results
    }
}

// MARK: - Subject (Result Item)
struct Subject: Codable {
    let id: Int
    let name: String
    let slug: String
    let description: String
    let testCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
        case description
        case testCount = "test_count"
    }
}

struct Lessons: Codable {
    let results: [ResultLessons]
    let pagination: Paginations
}

struct Paginations: Codable {
    let next: String?
    let previous: String?
    let count: Int?
    let numPages: Int?
}

struct ResultLessons: Codable {
    let blocksURL: String?
    let effort: String?
    let end: String?
    let enrollmentStart: String?
    let enrollmentEnd: String?
    let id: String?
    let media: Media?
    let name: String?
    let number: String?
    let org: String?
    let shortDescription: String?
    let start: String?
    let startDisplay: String?
    let startType: String?
    let pacing: String?
    let mobileAvailable: Bool?
    let hidden: Bool?
    let invitationOnly: Bool?
    let firstLessonURL: String?
    let courseID: String?
}

struct Media: Codable {
    let bannerImage: BannerImage?
    let courseImage: Courses?
    let courseVideo: Courses?
    let image: ImageLessons?
}

struct BannerImage: Codable {
    let uri: String?
    let uriAbsolute: String?
}

struct Courses: Codable {
    let uri: String?
}

struct ImageLessons: Codable {
    let raw: String?
    let small: String?
    let large: String?
}


struct CourseDetailsResponse: Codable {
    let blocks: [String: Block]?
}

// MARK: - Block
struct Block: Codable {
    var id: String { _id ?? UUID().uuidString }
    private let _id: String?
    let children: [String]?
    let complete: Bool?
    let description: String?
    let displayName: String?
    let due: String?
    let effortActivities: Int?
    let effortTime: Int?
    let icon: String?
    let lmsWebUrl: String?
    let resumeBlock: Bool?
    let type: String?
    let hasScheduledContent: Bool?
    let hideFromToc: Bool?
    let isLocked: Bool?
    let completionStat: CompletionStat?
    let tags: [Tag]?
    let thumbnail: String?
    
    enum CodingKeys: String, CodingKey {
            case _id = "id"
            case children, complete, description, displayName, due,
                 effortActivities, effortTime, icon, lmsWebUrl,
                 resumeBlock, type, hasScheduledContent, hideFromToc,
                 isLocked, completionStat, tags, thumbnail
        }
}

// MARK: - CompletionStat
struct CompletionStat: Codable {
    let completion: Int?
    let completableChildren: Int?
}

// MARK: - Tag
struct Tag: Codable {
    let taxonomy: String?
    let value: String?
}
