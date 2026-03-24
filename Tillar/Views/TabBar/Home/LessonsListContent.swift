//
//  LessonsListContent.swift
//  Tillar
//
//  Created by Gusein Djalilov on 10/03/26.
//

import SwiftUI

struct LessonsListContent: View {
    
    @ObservedObject var vm: LessonsViewModel
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            header
            
            if vm.isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else if let errorText = vm.errorText {
                VStack(spacing: 10) {
                    Text("Не удалось загрузить уроки")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primaryText)
                    
                    Text(errorText)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.tertiaryText)
                        .multilineTextAlignment(.center)
                    
                    Button("Повторить") {
                        vm.getLessons()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.linkPrimary)
                    .clipShape(Capsule())
                }
                .padding(.top, 40)
                .padding(.horizontal, 16)
            } else if vm.lessons.compactMap({ $0 }).isEmpty {
                Text("Уроки пока недоступны")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.tertiaryText)
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(Array(vm.lessons.compactMap { $0 }.enumerated()), id: \.offset) { _, lesson in
                        LessonVideoCard(lesson: lesson) { lesson in
                            vm.openLesson(lesson) {
                                vm.mode = .details
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var header: some View {
        HStack {
            Button {
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.85))
                    .frame(width: 33, height: 33)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)
                    )
            }
            
            Spacer()
            
            Text("Уроки")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primary)
            
            Spacer()
            
            Color.clear
                .frame(width: 33, height: 33)
        }
    }
}

struct LessonVideoCard: View {
    let lesson: ResultLessons
    let onTap: (ResultLessons) -> Void
    
    var body: some View {
        Button {
            onTap(lesson)
        } label: {
            VStack(spacing: 0) {
                lessonImage
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lesson.name ?? "Без названия")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.primaryText)
                            .multilineTextAlignment(.leading)
                        
                        Text(subtitleText)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.tertiaryText)
                    }
                    
                    Spacer()
                    
                    lessonLevelBadge
                }
                .padding(14)
            }
            .background(Color.primaryObject)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var lessonImage: some View {
        if let imageUrl = lesson.media?.image?.large,
           let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholderImage
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
            .frame(height: 180)
            .clipped()
        } else {
            placeholderImage
                .frame(height: 180)
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray.opacity(0.12))
            
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 34))
                .foregroundStyle(Color.gray.opacity(0.5))
        }
    }
    
    private var subtitleText: String {
        let orgText = lesson.org?.isEmpty == false ? lesson.org! : "Видеоурок"
        let effortText = lesson.effort?.isEmpty == false ? lesson.effort! : "Без длительности"
        return "\(orgText) • \(effortText)"
    }
    
    private var lessonLevelBadge: some View {
        Text(levelText)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(levelColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private var levelText: String {
        guard let number = lesson.number, !number.isEmpty else { return "L1" }
        return number.uppercased()
    }
    
    private var levelColor: Color {
        switch levelText {
        case "L1": return .green
        case "L2": return .blue
        case "L3": return .orange
        case "L4": return .pink
        default: return .gray
        }
    }
}

#Preview {
    LessonsListContent(vm: LessonsViewModel(), onBack: {})
}
