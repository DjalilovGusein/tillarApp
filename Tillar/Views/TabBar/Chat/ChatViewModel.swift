//
//  ChatViewModel.swift
//  Tillar
//
//  Updated to use APIManager for all REST calls
//

import SwiftUI
import Combine

@MainActor
final class ChatViewModel: ObservableObject {

    @Published var chatRooms: [ChatRoom] = []
    @Published var messages: [ChatMessage] = []
    @Published var searchText: String = ""
    @Published var selectedChatRoom: ChatRoom?
    @Published var messageText: String = ""

    @Published var isLoadingRooms = false
    @Published var isLoadingMessages = false
    @Published var isSendingMessage = false
    @Published var errorText: String?

    @Published var currentUserId: String
    @Published var isSocketConnected = false
    @Published var socketState: SocketState = .disconnected
    @Published var typingUsers: Set<String> = []

    private var currentPage = 0
    private let pageSize = 50
    @Published var hasMoreMessages = true

    private let socketManager: SocketManager
    private let api = APIManager.shared
    private var cancellables = Set<AnyCancellable>()
    @Published  var chatUsers: [ChatUser] = []

    @Published var currentUsername: String = UD.authUser?.username ?? ""
    private var typingTimers: [String: Timer] = [:]
    
    var filteredChatUsers: [ChatUser] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        return chatUsers.filter {
            $0.id != currentUserId &&
            (
                $0.username.localizedCaseInsensitiveContains(trimmed) ||
                $0.displayName.localizedCaseInsensitiveContains(trimmed)
            )
        }
    }
    
    var typingUserInSelectedRoom: ChatUser? {
        guard let room = selectedChatRoom else { return nil }

        return room.participants.first {
            $0.username != currentUsername &&
            typingUsers.contains($0.username)
        }
    }

    init(
        currentUserId: String,
        socketManager: SocketManager = .shared
    ) {
        self.currentUserId = currentUserId
        self.socketManager = socketManager

        bindSocketState()
        bindSocketCallbacks()
        getAllUsers()
        connectSocket(
            token: UD.sokenToken,
            username: UD.authUser?.username ?? ""
        )
    }

    deinit {
        typingTimers.values.forEach { $0.invalidate() }
        typingTimers.removeAll()
    }
    
    func selectUserFromSearch(_ user: ChatUser, completion: @escaping (ChatRoom?) -> Void) {
        if let existingRoom = chatRooms.first(where: { room in
            room.type.uppercased() == "PRIVATE" &&
            room.participants.contains(where: { $0.id == user.id })
        }) {
            selectedChatRoom = existingRoom
            searchText = ""
            completion(existingRoom)
            return
        }

        createDirectRoom(with: user.id) { [weak self] room in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let room {
                    self.selectedChatRoom = room
                    self.searchText = ""
                }
                completion(room)
            }
        }
    }

    var filteredChatRooms: [ChatRoom] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return chatRooms }

        return chatRooms.filter {
            $0.displayTitle(for: currentUserId).localizedCaseInsensitiveContains(trimmed)
        }
    }

    func loadInitialData() {
        loadChatRooms()
    }
    
    func getAllUsers() {
        APIManager.shared.getAllChatUsers { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let users):
                self.chatUsers = users.data ?? []
            case .failure(let err):
                debugPrint(err)
            }
            
        }
    }

    func selectChatRoom(_ room: ChatRoom) {
        selectedChatRoom = room
        messages = []
        currentPage = 0
        hasMoreMessages = true
        typingUsers.removeAll()

        socketManager.setRoom(room.id)
        loadMessages(for: room.id)
    }

    func connectSocket(token: String, username: String) {
        currentUsername = username
        socketManager.connect()
    }

    func reconnectSocket() {
        socketManager.connect()
    }

    func disconnectSocket() {
        socketManager.disconnect()
    }

    func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, selectedChatRoom != nil else { return }

        messageText = ""
        socketManager.sendMessage(trimmed)
    }

    func sendTyping() {
        guard selectedChatRoom != nil else { return }
        socketManager.sendTyping()
    }
    
    func markAsRead() {
        guard selectedChatRoom != nil else { return }
        socketManager.markRoomAsRead()
    }

    func handleIncomingSocketMessage(_ socketMessage: WSChatMessage) {
        guard let currentRoom = selectedChatRoom else { return }

        let upperType = socketMessage.type.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let trimmedContent = (socketMessage.content ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard upperType == "CHAT" else { return }
        guard !trimmedContent.isEmpty else { return }

        let senderUser = currentRoom.participants.first(where: {
            $0.id == socketMessage.sender || $0.username == socketMessage.sender
        }) ?? ChatUser(
            id: socketMessage.sender,
            username: socketMessage.sender,
            displayName: socketMessage.sender,
            status: "online"
        )

        let timestamp = socketMessage.timestamp ?? ISO8601DateFormatter().string(from: Date())
        let isMyMessage = senderUser.username == currentUsername || senderUser.id == currentUserId

        let incomingMessage = ChatMessage(
            id: Int(socketMessage.id ?? "") ?? Int(Date().timeIntervalSince1970 * 1000),
            content: trimmedContent,
            sender: senderUser,
            chatRoomId: currentRoom.id,
            type: upperType,
            createdAt: timestamp,
            isRead: isMyMessage
        )

        if isDuplicateSocketMessage(incomingMessage) {
            return
        }

        typingUsers.remove(senderUser.username)
        typingTimers[senderUser.username]?.invalidate()
        typingTimers[senderUser.username] = nil

        messages.append(incomingMessage)

        updateRoomAfterLastMessage(
            roomId: currentRoom.id,
            contentDate: timestamp
        )

        if !isMyMessage {
            markAsRead()
            markMessageAsRead(messageId: incomingMessage.id)
        }
    }

    func handleTypingMessage(_ socketMessage: WSChatMessage) {
        guard selectedChatRoom != nil else { return }

        let sender = socketMessage.sender
        guard sender != currentUsername else { return }

        typingUsers.insert(sender)

        typingTimers[sender]?.invalidate()
        typingTimers[sender] = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.typingUsers.remove(sender)
                self?.typingTimers[sender] = nil
            }
        }
    }

    func handleUserStatus(_ socketMessage: WSChatMessage) {
        let username = socketMessage.sender
        let newStatus = (socketMessage.content ?? "offline").lowercased()

        for roomIndex in chatRooms.indices {
            for participantIndex in chatRooms[roomIndex].participants.indices {
                if chatRooms[roomIndex].participants[participantIndex].username == username {
                    chatRooms[roomIndex].participants[participantIndex].status = newStatus
                }
            }
        }

        if let selectedRoom = selectedChatRoom,
           let updatedRoom = chatRooms.first(where: { $0.id == selectedRoom.id }) {
            selectedChatRoom = updatedRoom
        }
    }
}

// MARK: - REST

extension ChatViewModel {

    func loadChatRooms() {
        isLoadingRooms = true
        errorText = nil

        api.getUserChatRooms(userId: currentUserId) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isLoadingRooms = false

                switch result {
                case .success(let rooms):
                    self.chatRooms = rooms.data ?? []
                case .failure(let error):
                    self.errorText = error.localizedDescription
                }
            }
        }
    }

    func loadMessages(for roomId: Int) {
        isLoadingMessages = true
        errorText = nil

        api.getChatMessages(roomId: roomId, page: currentPage, size: pageSize) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isLoadingMessages = false

                switch result {
                case .success(let loaded):
                    guard let messages = loaded.data else { return }
                    if self.currentPage == 0 {
                        self.messages = messages.sorted { $0.createdAt < $1.createdAt }
                    } else {
                        let merged = messages + self.messages
                        self.messages = merged.sorted { $0.createdAt < $1.createdAt }
                    }

                    self.hasMoreMessages = messages.count >= self.pageSize

                case .failure(let error):
                    self.errorText = error.localizedDescription
                }
            }
        }
    }

    func loadMoreMessages() {
        guard !isLoadingMessages,
              hasMoreMessages,
              let room = selectedChatRoom else { return }

        currentPage += 1
        loadMessages(for: room.id)
    }

    func createRoom(
        participantIds: [String],
        type: String = "PRIVATE",
        name: String? = nil,
        completion: ((ChatRoom?) -> Void)? = nil
    ) {
        let body = CreateChatRoomRequest(
            participantIds: participantIds,
            type: type,
            name: name
        )

        APIManager.shared.createChatRoom(requestBody: body) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let room):
                selectedChatRoom = room.data
                completion?(room.data)
            case .failure(let err):
                debugPrint(err)
            }
        }
    }

    func createDirectRoom(with participantId: String,
                          isGroup: Bool = false,
                          completion: ((ChatRoom?) -> Void)? = nil) {
        createRoom(
            participantIds: [participantId, UD.authUser?.keycloakUuid ?? ""],
            type: isGroup ? "GROUP" : "PRIVATE",
            name: UD.authUser?.username ?? "",
            completion: completion
        )
    }

    func markMessageAsRead(messageId: Int) {
        api.markMessageAsRead(messageId: messageId) { result in
            if case .failure(let error) = result {
                debugPrint("markMessageAsRead error:", error)
            }
        }
    }
}

// MARK: - Socket binding

private extension ChatViewModel {

    func bindSocketState() {
        socketManager.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.socketState = state
            }
            .store(in: &cancellables)

        socketManager.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                self?.isSocketConnected = connected
            }
            .store(in: &cancellables)
    }

    func bindSocketCallbacks() {
        socketManager.onConnected = { [weak self] in
            guard let self else { return }
            self.errorText = nil

            if let room = self.selectedChatRoom {
                self.socketManager.setRoom(room.id)
            }
        }

        socketManager.onDisconnected = { [weak self] in
            self?.isSocketConnected = false
        }

        socketManager.onError = { [weak self] error in
            self?.errorText = error
        }

        socketManager.onRoomMessage = { [weak self] message in
            Task { @MainActor [weak self] in
                self?.handleIncomingSocketMessage(message)
            }
        }

        socketManager.onTyping = { [weak self] message in
            Task { @MainActor [weak self] in
                self?.handleTypingMessage(message)
            }
        }

        socketManager.onStatus = { [weak self] message in
            Task { @MainActor [weak self] in
                self?.handleUserStatus(message)
            }
        }
    }

    func isDuplicateSocketMessage(_ newMessage: ChatMessage) -> Bool {
        if messages.contains(where: { $0.id == newMessage.id }) {
            return true
        }

        let newDate = isoDate(from: newMessage.createdAt) ?? Date()

        return messages.contains { existing in
            guard existing.sender.username == newMessage.sender.username else { return false }
            guard existing.content == newMessage.content else { return false }

            let existingDate = isoDate(from: existing.createdAt) ?? .distantPast
            return abs(existingDate.timeIntervalSince(newDate)) < 2.0
        }
    }

    func updateRoomAfterLastMessage(roomId: Int, contentDate: String) {
        guard let index = chatRooms.firstIndex(where: { $0.id == roomId }) else { return }

        chatRooms[index].lastMessageAt = contentDate
        let updatedRoom = chatRooms.remove(at: index)
        chatRooms.insert(updatedRoom, at: 0)

        if selectedChatRoom?.id == roomId {
            selectedChatRoom = updatedRoom
        }
    }

    func isoDate(from string: String) -> Date? {
        let formatterWithFractional = ISO8601DateFormatter()
        formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatterWithFractional.date(from: string) {
            return date
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }
}

// MARK: - Helpers

extension ChatViewModel {
    func user(for room: ChatRoom) -> ChatUser? {
        room.participants.first(where: { $0.id != currentUserId })
    }
}
