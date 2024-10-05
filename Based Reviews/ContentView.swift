//
//  ContentView.swift
//  Based Reviews
//
//  Created by Bob Moriasi on 10/3/24.
//

import SwiftUI
import Factory

struct ContentView: View {
    // Access isLoggedIn from userdefaults
    @AppStorage("isLoggedIn") var isLoggedIn: Bool?
    
    var body: some View {
        if isLoggedIn != nil {
            HomePage()
        } else {
            LoginPage()
        }
    }
}

#Preview {
    ContentView()
}
