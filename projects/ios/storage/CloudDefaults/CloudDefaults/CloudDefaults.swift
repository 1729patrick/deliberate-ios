//
//  CloudDefaults.swift
//  CloudDefaults
//
//  Created by Patrick Battisti Forsthofer on 25/02/23.
//

import Foundation

final class CloudDefaults {
    static let shared = CloudDefaults()
    private var ignoreLocalChanges = false
    
    private init() { }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func start() {
        NotificationCenter.default.addObserver(forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default, queue: .main, using: updateLocal)

        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main, using: updateRemote)

        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    private func updateRemote(note: Notification) {
        guard ignoreLocalChanges == false else { return }

        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            guard key.hasPrefix("sync-") else { continue }
            print("Updating remote value of \(key) to \(value)")
            NSUbiquitousKeyValueStore.default.set(value, forKey: key)
        }
    }

    private func updateLocal(note: Notification) {
        ignoreLocalChanges = true

        for (key, value) in NSUbiquitousKeyValueStore.default.dictionaryRepresentation {
            guard key.hasPrefix("sync-") else { continue }
            print("Updating local value of \(key) to \(value)")
            UserDefaults.standard.set(value, forKey: key)
        }

        ignoreLocalChanges = false
    }
}
