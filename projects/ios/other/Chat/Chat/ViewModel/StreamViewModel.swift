//
//  StreamViewModel.swift
//  Chat
//
//  Created by Patrick Battisti Forsthofer on 15/12/21.
//

import SwiftUI

class StreamViewModel: ObservableObject {
    @Published var userName = ""
    
    @AppStorage("userName") var storedUser = ""
    @AppStorage("log_Status") var logStatus = false
    
    func logInUser() {
        
    }
}

