//
//  LessonDetailsContent.swift
//  Tillar
//
//  Created by Gusein Djalilov on 10/03/26.
//

import SwiftUI
import AVKit

enum LessonDetailsTab {
    case lessons
    case practice
    case test
    case materials
}

struct LessonDetailsContent: View {
    
    @State private var player: AVPlayer = AVPlayer(url: URL(string: "http://172.20.20.12:9000/elementary-course-videos/video-uploads/english_alphabet.mp4")!)
    @ObservedObject var vm: LessonsViewModel
    let onBack: () -> Void
    @State private var selectedTab: LessonDetailsTab = .lessons
    
    var body: some View {
        VStack(spacing: 14) {
            header
            
            searchAndFilter
            
            heroCard
            
            tabBar
            
            detailsBody
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
            
            Text(vm.selectedLesson?.name ?? "Урок")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primary)
                .lineLimit(1)
            
            Spacer()
            
            Color.clear
                .frame(width: 33, height: 33)
        }
    }
    
    private var searchAndFilter: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.gray)
                
                Text("Поиск...")
                    .foregroundStyle(Color.gray.opacity(0.8))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            
            Button {
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 74, height: 56)
                    .background(Color.linkPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }
    
    private var heroCard: some View {
        VStack(spacing: 0) {
            PlayerViewController(player: player)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            HStack {
                Text(vm.selectedLesson?.name ?? "Без названия")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primaryText)
                
                Spacer()
            }
            .padding(16)
        }
        .background(Color.primaryObject)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
    }
    
    private var tabBar: some View {
        HStack {
            tabButton(title: "Уроки", tab: .lessons)
            tabButton(title: "Практика", tab: .practice)
            tabButton(title: "Тест", tab: .test)
            tabButton(title: "Материалы", tab: .materials)
        }
        .padding(.top, 4)
    }
    
    private func tabButton(title: String, tab: LessonDetailsTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(selectedTab == tab ? Color.linkPrimary : Color.linkPrimary.opacity(0.8))
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(selectedTab == tab ? Color.linkPrimary : Color.clear)
                    .frame(height: 4)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var detailsBody: some View {
        switch selectedTab {
        case .lessons:
            lessonItemsView
        case .practice:
            practiceView
        case .test:
            testView
        case .materials:
            materialsView
        }
    }
    
    private var lessonItemsView: some View {
        VStack(spacing: 14) {
            if let blocks = vm.selectedLessonDetails?.blocks {
                ForEach(Array(blocks.values), id: \.id) { block in
                    lessonListRow(title: block.displayName ?? "")
                }
            }
        }
    }
    
    private func lessonListRow(title: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.yellow.opacity(0.7))
                .frame(width: 140, height: 90)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.primaryText)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding(14)
        .background(Color.primaryObject)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    private var practiceView: some View {
        VStack(spacing: 12) {
            practiceCard(titleRU: "Яблоко", titleEN: "Apple")
            practiceCard(titleRU: "Книга", titleEN: "Book")
            practiceCard(titleRU: "Кошка", titleEN: "Cat")
        }
    }
    
    private func practiceCard(titleRU: String, titleEN: String) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Text(titleRU)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.gray)
                
                Text(titleEN)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.primaryText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            HStack(spacing: 18) {
                Image(systemName: "star").foregroundStyle(.white)
                Image(systemName: "speaker.wave.2").foregroundStyle(.white)
            }
            .font(.system(size: 24))
            .foregroundStyle(Color.linkPrimary)
            .frame(width: 110)
            .frame(maxHeight: .infinity)
            .background(Color.linkPrimary.opacity(0.9))
            .foregroundStyle(.white)
        }
        .frame(height: 92)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private var testView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Как называется буква ‘A’")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.primaryText)
            
            answerRow(title: "Би", selected: false)
            answerRow(title: "Ей", selected: true)
            answerRow(title: "Си", selected: false)
            answerRow(title: "Ди", selected: false)
            
            HStack {
                Text("1/1")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.linkPrimary)
                
                Spacer()
                
                Button("Отправить") {
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 180, height: 56)
                .background(Color.linkPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(16)
        .background(Color.primaryObject)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private func answerRow(title: String, selected: Bool) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(selected ? Color.linkPrimary : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.linkPrimary, lineWidth: 2)
                )
                .frame(width: 34, height: 34)
            
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.primaryText)
            
            Spacer()
            
            if selected {
                Image(systemName: "checkmark")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.linkPrimary)
            }
        }
        .padding(.vertical, 10)
        
    }
    
    private var materialsView: some View {
        VStack(spacing: 14) {
            Text("Материалы урока")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.primaryText)
            
            Button("Скачать рабочую тетрадь (PDF)") {
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(Color.linkPrimary)
            
            Button {
            } label: {
                HStack(spacing: 0) {
                    Text("Скачать")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                    
                    ZStack {
                        Rectangle()
                            .fill(Color.linkPrimary.opacity(0.8))
                        
                        Image(systemName: "arrow.down")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 90)
                }
                .frame(height: 72)
                .background(Color.linkPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.primaryObject)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    LessonDetailsContent(vm: LessonsViewModel(), onBack: {})
}
