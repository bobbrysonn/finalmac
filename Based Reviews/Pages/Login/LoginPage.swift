//
//  LoginPage.swift
//  Based Reviews
//
//  Created by Bob Moriasi on 10/4/24.
//

import SwiftUI
import Factory

struct LoginPage: View {
    @Injected(\.authService) var authService: AuthService
    
    // State
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
            
            if !authService.error.isEmpty {
                Text(authService.error)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    LoginPage()
}
