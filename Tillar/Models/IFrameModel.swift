//
//  IFrameModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 16/03/26.
//


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let lessonXBlock = try? JSONDecoder().decode(LessonXBlock.self, from: jsonData)

import Foundation

// MARK: - LessonXBlock
struct LessonXBlock: Codable {
    let blockID, blockType, displayName: String?
    let video: Video?
    let lessonText, practice, materials: LessonText?
    let problems: [Problem]?
}

// MARK: - LessonText
struct LessonText: Codable {
    let blockID, html: String?
}

// MARK: - Problem
struct Problem: Codable {
    let blockID, displayName, handlerURL: String?
    let metadata: Metadata?
    let questions: [Question]?
}

// MARK: - Metadata
struct Metadata: Codable {
    let maxAttempts: Int?
    let attempts, weight: Int?
    let graded, hasScore: Bool?
}

// MARK: - Question
struct Question: Codable {
    let id, type, text, inputName: String?
    let choices: [Choice]?
}

// MARK: - Choice
struct Choice: Codable {
    let value, text: String?
}

// MARK: - Video
struct Video: Codable {
    let blockID: String?
    let url: String?
    let completionURL, saveStateURL: String?
    let transcripts: Transcripts?
    let duration: String?
    let thumbnail: String?
}

// MARK: - Transcripts
struct Transcripts: Codable {
    let en: String?
    let ru: String?
    let uz: String?
}
