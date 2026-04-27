//
//  SocketManager.swift
//  Tillar
//

import Foundation
import SwiftStomp

enum SocketState: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)
}

struct WSChatMessage: Codable {
    let id: String?
    let sender: String
    let content: String?
    let recipient: String?
    let type: String
    let timestamp: String?
}

@MainActor
final class SocketManager: NSObject, ObservableObject {

    static let shared = SocketManager()

    @Published private(set) var state: SocketState = .disconnected
    @Published private(set) var isConnected = false

    var onConnected: (() -> Void)?
    var onDisconnected: (() -> Void)?
    var onError: ((String) -> Void)?
    var onRoomMessage: ((WSChatMessage) -> Void)?
    var onTyping: ((WSChatMessage) -> Void)?
    var onStatus: ((WSChatMessage) -> Void)?

    private var stomp: SwiftStomp?
    private var currentRoomId: Int?

    private override init() {
        super.init()
    }

    func connect(urlString: String = "ws://tillar.uz/ws") {
        guard var components = URLComponents(string: urlString) else {
            setError("Invalid socket URL")
            return
        }

        components.queryItems = (components.queryItems ?? []) + [
            URLQueryItem(name: "token", value: UD.sokenToken)
        ]

        guard let url = components.url else {
            setError("Invalid socket URL with token")
            return
        }

        disconnect()

        let client = SwiftStomp(host: url)
        client.delegate = self
        client.autoReconnect = false

        stomp = client
        state = .connecting
        isConnected = false

        client.connect(timeout: 20.0, acceptVersion: "1.1,1.2")
    }

    func disconnect() {
        stomp?.disconnect()
        stomp = nil
        currentRoomId = nil
        state = .disconnected
        isConnected = false
    }

    func setRoom(_ roomId: Int) {
        currentRoomId = roomId
        subscribeIfPossible(roomId: roomId)
    }

    func sendMessage(_ text: String) {
        guard
            let stomp,
            stomp.connectionStatus == .fullyConnected,
            let roomId = currentRoomId
        else { return }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let payload = WSChatMessage(
            id: nil,
            sender: UD.authUser?.username ?? "",
            content: trimmed,
            recipient: nil,
            type: "CHAT",
            timestamp: nil
        )

        send(payload, to: "/app/chat.sendMessage/\(roomId)")
    }
    
    func markRoomAsRead() {
        guard
            let stomp,
            stomp.connectionStatus == .fullyConnected,
            let roomId = currentRoomId
        else { return }
        
        let username = UD.authUser?.username ?? ""
        guard !username.isEmpty else {
            setError("Username is empty")
            return
        }
        
        let payload = WSChatMessage(
            id: nil,
            sender: username,
            content: nil,
            recipient: nil,
            type: "READ_RECEIPT",
            timestamp: nil
        )
        
        send(payload, to: "/app/chat.markRead/\(roomId)")
    }

    func sendTyping() {
        guard
            let stomp,
            stomp.connectionStatus == .fullyConnected,
            let roomId = currentRoomId
        else { return }

        let payload = WSChatMessage(
            id: nil,
            sender: UD.authUser?.username ?? "",
            content: nil,
            recipient: nil,
            type: "TYPING",
            timestamp: nil
        )

        send(payload, to: "/app/chat.typing/\(roomId)")
    }

    private func sendJoin() {
        let username = UD.authUser?.username ?? ""
        guard !username.isEmpty else {
            setError("Username is empty")
            return
        }

        let payload = WSChatMessage(
            id: nil,
            sender: username,
            content: nil,
            recipient: nil,
            type: "JOIN",
            timestamp: nil
        )

        send(payload, to: "/app/chat.addUser")
    }

    private func subscribeIfPossible(roomId: Int) {
        guard
            isConnected,
            let stomp,
            stomp.connectionStatus == .fullyConnected
        else { return }

        stomp.subscribe(to: "/topic/room/\(roomId)", mode: .clientIndividual)
        stomp.subscribe(to: "/topic/room/\(roomId)/typing", mode: .clientIndividual)
        stomp.subscribe(to: "/topic/user.status", mode: .clientIndividual)
    }

    private func send<T: Encodable>(_ payload: T, to destination: String) {
        guard let stomp else { return }

        do {
            let data = try JSONEncoder().encode(payload)
            guard let json = String(data: data, encoding: .utf8) else { return }

            stomp.send(
                body: json,
                to: destination,
                receiptId: nil,
                headers: ["content-type": "application/json"]
            )
        } catch {
            setError(error.localizedDescription)
        }
    }

    private func handleIncomingText(_ text: String, destination: String) {
        guard
            let data = text.data(using: .utf8),
            let message = try? JSONDecoder().decode(WSChatMessage.self, from: data)
        else { return }

        if destination.contains("/typing") {
            onTyping?(message)
        } else if destination.contains("/user.status") {
            onStatus?(message)
        } else {
            onRoomMessage?(message)
        }
    }

    private func setError(_ text: String) {
        state = .error(text)
        isConnected = false
        onError?(text)
    }
}

extension SocketManager: SwiftStompDelegate {
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        switch connectType {
        case .toSocketEndpoint:
            break

        case .toStomp:
            state = .connected
            isConnected = true

            // ОБЯЗАТЕЛЬНО после подключения отправляем JOIN
            sendJoin()

            if let currentRoomId {
                subscribeIfPossible(roomId: currentRoomId)
            }

            onConnected?()

        @unknown default:
            break
        }
    }

    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        state = .disconnected
        isConnected = false
        onDisconnected?()
    }

    func onMessageReceived(
        swiftStomp: SwiftStomp,
        message: Any?,
        messageId: String,
        destination: String,
        headers: [String : String]
    ) {
        if let text = message as? String {
            handleIncomingText(text, destination: destination)
        } else if let data = message as? Data,
                  let text = String(data: data, encoding: .utf8) {
            handleIncomingText(text, destination: destination)
        }
    }

    func onReceipt(swiftStomp: SwiftStomp, receiptId: String) { }

    func onError(
        swiftStomp: SwiftStomp,
        briefDescription: String,
        fullDescription: String?,
        receiptId: String?,
        type: StompErrorType
    ) {
        setError(fullDescription ?? briefDescription)
    }
}
