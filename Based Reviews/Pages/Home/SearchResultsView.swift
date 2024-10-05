//
//  SearchResultsView.swift
//  Based Reviews
//
//  Created by Bob Moriasi on 10/4/24.
//

import SwiftUI
import Factory

struct SearchResultsView: View {
    // Get the course service
    @Injected(\.courseService) var courseService: CourseService
    
    // Holds search results
    @State var courses: [Course] = []
    // Holds error message
    @State var errorMessage: String?
    
    // Course query
    var query: String
    
    var body: some View {
        List {
            ForEach(courses, id: \.id) { course in
                Text(course.title ?? "No title provided")
            }
        }
        .onAppear {
            loadSearchResults()
        }
    }
    
    /// Loads search results
    private func loadSearchResults() {
        courseService.fetchCoursesByTitle(query: query) { result in
            switch result {
                case .success(let courses):
                self.courses = courses
            case .failure:
                self.errorMessage = "Error loading search results."
            }
        }
    }
}

#Preview {
    SearchResultsView(query: "COSC")
}
