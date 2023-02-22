//
//  Login.swift
//  Chat
//
//  Created by Patrick Battisti Forsthofer on 15/12/21.
//

import SwiftUI

struct Login: View {
    @StateObject var streamData = StreamViewModel()
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
