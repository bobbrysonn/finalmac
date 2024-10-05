//
//  Home.swift
//  Based Reviews
//
//  Created by Bob Moriasi on 10/4/24.
//

import SwiftUI

struct HomePage: View {
    // For storing currently selected
    @State private var selection: String? = "Home"
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    // Available sections
    let nav = ["Home", "Departments"]
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selection) {
                ForEach(nav, id: \.self) { item in
                    Text(item)
                }
            }
        } detail: {
            if let selection {
                switch selection {
                case "Home":
                    LandingView()
                case "Departments":
                    DepartmentsPage()
                default:
                    Text("Unknown selection: \(selection)")
                }
            }
        }
    }
}

#Preview {
    HomePage()
}
