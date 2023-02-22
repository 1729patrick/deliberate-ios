//
//  ChatApp.swift
//  Chat
//
//  Created by Patrick Battisti Forsthofer on 15/12/21.
//

import SwiftUI
import StreamChat

@main
struct ChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate{
 
    @AppStorage("userName") var storedUser = ""
    @AppStorage("log_Status") var logStatus = false
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let config = ChatClientConfig(apiKeyString: APIKey)
        
        if logStatus{
            ChatClient.shared = ChatClient(config: config) {completion in
                
                
                completion(.success(.development(userId: self.storedUser)))
                
            }
        }else {
           // ChatClient.shared = ChatClient(config: config, tokenProvider: .anonymous)
            
        }
        
        return true
    }
}

extension ChatClient {
    static var shared: ChatClient!
}
