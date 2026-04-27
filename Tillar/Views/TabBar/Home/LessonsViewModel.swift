//
//  LessonsViewModel.swift
//  Tillar
//
//  Created by Gusein Djalilov on 10/03/26.
//

import Foundation

enum LessonScreenMode {
    case list
    case details
}

final class LessonsViewModel: ObservableObject {
    @Published var lessons: [ResultLessons?] = []
    @Published var selectedLessonDetails: CourseDetailsResponse?
    @Published var selectedLessonContent: LessonXBlock?
    @Published var selectedLesson: ResultLessons?
    @Published var mode: LessonScreenMode = .list
    @Published var isLoading = false
    @Published var errorText: String?

    private var didLoadLessons = false
    private var loadingCourseID: String?

    init() {
        loadLessonsIfNeeded()
    }

    func loadLessonsIfNeeded() {
        guard !didLoadLessons, !isLoading else { return }
        getLessons()
    }

    func refreshLessons() {
        didLoadLessons = false
        getLessons()
    }

    func getLessons() {
        guard !isLoading else { return }

        isLoading = true
        errorText = nil

        APIManager.shared.getCourses { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let lessons):
                    debugPrint("Lessons are \(lessons)")
                    self.lessons = lessons.results
                    self.didLoadLessons = true

                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }

    func openLesson(_ lesson: ResultLessons, completion: @escaping (() -> Void)) {
        let lessonID = lesson.id ?? ""

        selectedLesson = lesson

        if selectedLesson?.id == lessonID,
           selectedLessonDetails != nil,
           selectedLessonContent != nil {
            mode = .details
            completion()
            return
        }

        selectedLessonDetails = nil
        selectedLessonContent = nil

        getLessonDetails(courseID: lessonID, completion: completion)
    }

    func goBackToLessons() {
        mode = .list
    }

    func getLessonDetails(courseID: String, completion: @escaping (() -> Void)) {
        guard !courseID.isEmpty else {
            errorText = "Course ID is empty"
            completion()
            return
        }

        loadingCourseID = courseID
        isLoading = true
        errorText = nil

        APIManager.shared.getCourseDetails(id: courseID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let details):
                    self.selectedLessonDetails = details
                    self.getLessonContent(courseID: courseID, completion: completion)

                case .failure(let err):
                    self.isLoading = false
                    self.errorText = err.localizedDescription
                    completion()
                }
            }
        }
    }

    func getLessonContent(courseID: String, completion: @escaping (() -> Void)) {
        APIManager.shared.getLessonContent(id: courseID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let content):
                    self.selectedLessonContent = content
                    self.mode = .details

                case .failure(let err):
                    self.errorText = err.localizedDescription
                }

                self.loadingCourseID = nil
                completion()
            }
        }
    }
}
