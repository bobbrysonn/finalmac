//
//  ContentView.swift
//  Based Reviews
//
//  Created by Bob Moriasi on 10/3/24.
//

import SwiftUI
import Factory

struct ContentView: View {
    @Injected(\.authService) private var authService
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            Image(.threeMoai)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 128)
            
            Form {
                TextField("Email", text: $email)
                
                SecureField("Password", text: $password)
                
                Button("Login") {
                    authService.signIn(email: email, password: password)
                }
            }
            
            if authService.isLoggedIn {
                Text("Logged in successfully")
                    .foregroundStyle(.green)
                Text(authService.access)
            }
            
            if !authService.error.isEmpty {
                Text(authService.error)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: 400)
    }
}

#Preview {
    ContentView()
}
