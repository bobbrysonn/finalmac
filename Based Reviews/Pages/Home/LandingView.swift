//
//  LandingView.swift
//  Based Reviews
//
//  Created by Bob Moriasi on 10/4/24.
//

import SwiftUI

struct LandingView: View {
    @State var path: [String] = []
    @State var searchText: String = ""
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                // Moai Image
                Image(.threeMoai)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 128)
                
                // Title
                VStack {
                    Text("Based Reviews")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Dartmouth Course Reviews, Rankings, and Recommendations")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                
                // Search form
                VStack {
                    Form {
                        TextField("", text: $searchText)
                        Button("Search") {
                            path.append(searchText)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .frame(maxWidth: 448)
            }
            .navigationDestination(for: String.self) { query in
                SearchResultsView(query: query)
            }
        }
    }
}

#Preview {
    LandingView()
}
