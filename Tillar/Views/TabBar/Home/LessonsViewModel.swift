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

class LessonsViewModel: ObservableObject {
    @Published var lessons: [ResultLessons?] = []
    @Published var selectedLessonDetails: CourseDetailsResponse?
    @Published var selectedLessonContent: LessonXBlock?
    @Published var selectedLesson: ResultLessons?
    @Published var mode: LessonScreenMode = .list
    @Published var isLoading = false
    @Published var errorText: String?
    
    init() {
        getLessons()
    }
    
    func getLessons() {
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
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
            }
        }
    }
    
    func openLesson(_ lesson: ResultLessons, completion: @escaping(() -> Void)) {
        selectedLesson = lesson
        selectedLessonDetails = nil
        debugPrint(lesson)
        getLessonDetails(courseID: lesson.id ?? "", completion: completion)
    }
    
    func goBackToLessons() {
        mode = .list
    }
    
    func getLessonDetails(courseID: String, completion: @escaping(() -> Void)) {
        
        isLoading = true
        errorText = nil
        
        APIManager.shared.getCourseDetails(id: courseID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let selectedLessonDetails):
                    self.selectedLessonDetails = selectedLessonDetails
                    self.getLessonContent(courseID: courseID, completion: {completion()})
                case .failure(let err):
                    self.errorText = err.localizedDescription
                    completion()
                }
                
            }
        }
    }
    
    func getLessonContent(courseID: String, completion: @escaping(() -> Void)) {
        
        isLoading = true
        errorText = nil
        
        APIManager.shared.getLessonContent(id: courseID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let selectedLessonDetails):
                    self.selectedLessonContent = selectedLessonDetails
                case .failure(let err):
                    self.errorText = err.localizedDescription
                }
                completion()
            }
        }
    }
}
