//
//  UserDefaults+Extensions.swift
//  ConsumptionManagement
//
//  Created by Gusein Djalilov on 24/09/25.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let loginData = "userLoginData"
        static let authUser = "authUser"
    }

    public var csrfToken: String {
        get { self.string(forKey: "csrfToken") ?? "" }
        set { self.set(newValue, forKey: "csrfToken") }
    }

    public var language: String {
        get { self.string(forKey: "language") ?? "ru" }
        set { self.set(newValue, forKey: "language") }
    }

    public var accessWeb: String {
        get { self.string(forKey: "accessWeb") ?? "" }
        set { self.set(newValue, forKey: "accessWeb") }
    }
    
    public var sokenToken: String {
        get { self.string(forKey: "sokenToken") ?? "" }
        set { self.set(newValue, forKey: "sokenToken") }
    }

    public var accessToken: String {
        get { self.string(forKey: "accessToken") ?? "" }
        set { self.set(newValue, forKey: "accessToken") }
    }

    public var refreshToken: String {
        get { self.string(forKey: "refreshToken") ?? "" }
        set { self.set(newValue, forKey: "refreshToken") }
    }

    public var email: String {
        get { self.string(forKey: "email") ?? "" }
        set { self.set(newValue, forKey: "email") }
    }

    public var unreadTopicSign: Bool {
        get { self.bool(forKey: "unreadTopicSign") }
        set { self.set(newValue, forKey: "unreadTopicSign") }
    }

    public var eventsEnable: Bool {
        get { self.bool(forKey: "eventsEnable") }
        set { self.set(newValue, forKey: "eventsEnable") }
    }

    public var eimzoDesc: Bool {
        get { self.bool(forKey: "eimzoDesc") }
        set { self.set(newValue, forKey: "eimzoDesc") }
    }

    public var lastActiveDate: Date? {
        get { object(forKey: "lastActiveDate") as? Date }
        set { set(newValue, forKey: "lastActiveDate") }
    }

    public var refreshWeb: String {
        get { self.string(forKey: "refreshWeb") ?? "" }
        set {
            self.set(newValue, forKey: "refreshWeb")
            debugPrint("newValue \(newValue)")
        }
    }

    public var payloadWorked: String {
        get { self.string(forKey: "payloadWorked") ?? "false" }
        set { self.set(newValue, forKey: "payloadWorked") }
    }

    public var numberOfNotificationsOpened: Int {
        get { self.integer(forKey: "numberOfNotifications") }
        set { self.set(newValue, forKey: "numberOfNotifications") }
    }

    public var feedbackSent: Int {
        get { self.integer(forKey: "feedbackSent") }
        set { self.set(newValue, forKey: "feedbackSent") }
    }

    public var unseenTrigger: Bool {
        get { self.bool(forKey: "unseenTrigger") }
        set { self.set(newValue, forKey: "unseenTrigger") }
    }

    public var firstLaunch: Bool {
        get {
            if object(forKey: "firstLaunch") == nil {
                return true
            }
            return bool(forKey: "firstLaunch")
        }
        set {
            set(newValue, forKey: "firstLaunch")
        }
    }

    public var registrationAttemts: Int {
        get { self.integer(forKey: "registrationAttemts") }
        set { self.set(newValue, forKey: "registrationAttemts") }
    }

    public var companyId: Int {
        get { self.integer(forKey: "companyId") }
        set { self.set(newValue, forKey: "companyId") }
    }

    public var launchDate: Date? {
        get { object(forKey: "launchDate") as? Date }
        set { set(newValue, forKey: "launchDate") }
    }

    public var ratePromptCount: Int {
        get { self.integer(forKey: "ratePromptCount") }
        set { self.set(newValue, forKey: "ratePromptCount") }
    }

    public var pushDeclineCount: Int {
        get { self.integer(forKey: "pushDeclineCount") }
        set { self.set(newValue, forKey: "pushDeclineCount") }
    }

    public var pushNextPromptDate: Date? {
        get { self.object(forKey: "pushNextPromptDate") as? Date }
        set { self.set(newValue, forKey: "pushNextPromptDate") }
    }

    public var authUser: AuthUser? {
        get {
            guard let data = self.data(forKey: Keys.authUser) else { return nil }
            return try? JSONDecoder().decode(AuthUser.self, from: data)
        }
        set {
            if let newValue,
               let data = try? JSONEncoder().encode(newValue) {
                self.set(data, forKey: Keys.authUser)
            } else {
                self.removeObject(forKey: Keys.authUser)
            }
        }
    }
}
