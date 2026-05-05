//
//  LinearHistoryView.swift
//  weekly
//
//  Created by Stef Kors on 20/01/2026.
//

import SwiftUI

struct LinearHistoryView: View {
    @AppStorage("linearAPIKey") var linearAPIKey: String = ""
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
    @State private var linear: Linear?
    @State private var isFetching: Bool = false
    @State private var errorMessage: String?
    @State private var draggingItem: String?

    var body: some View {
        VStack {
            HStack {
                ScrollView {
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .padding()
                    }
                    
                    if let issues = linear?.data?.viewer?.assignedIssues?.nodes?.sorted(by: { lhs, rhs in
                        // Sort by updated at desc
                        (lhs.updatedAt ?? "") > (rhs.updatedAt ?? "")
                    }) {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(issues, id: \.id) { issue in
                                HStack(alignment: .top) {
                                    Image(linearStatusToEmoji(issue.state?.name))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 16, height: 16)
                                        .padding(.top, 2)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        if let title = issue.title {
                                            Text(title)
                                                .fontWeight(.medium)
                                        }
                                        
                                        HStack {
                                            if let project = issue.project?.name {
                                                Text(project)
                                                    .font(.caption)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.secondary.opacity(0.1))
                                                    .cornerRadius(4)
                                            }
                                            
                                            if let dateString = issue.updatedAt,
                                               let date = ISO8601DateFormatter().date(from: dateString) {
                                                Text(date, style: .date)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                Divider()
                            }
                        }
                        .padding(.top)
                    } else if isFetching {
                         ProgressView()
                             .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if linear == nil {
                         ContentUnavailableView("No Activity", systemImage: "clock.arrow.circlepath", description: Text("Fetch your Linear activity to see it here."))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                Divider()
                
                // Settings / Controls Pane
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Linear API Key")
                            .foregroundStyle(.secondary)
                        SecureField("Linear API Key", text: $linearAPIKey)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text("Time Range")
                            .foregroundStyle(.secondary)
                        
                        DatePicker(
                            "Start Date",
                            selection: $startDate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                    }
                    
                    Spacer()
                    
                    Button {
                        Task {
                            await fetchActivity()
                        }
                    } label: {
                        Text("Fetch Activity")
                            .fontDesign(.rounded)
                            .padding(4)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isFetching || linearAPIKey.isEmpty)
                }
                .padding()
                .frame(maxWidth: 320)
            }
        }
    }
    
    func linearStatusToEmoji(_ input: String?) -> String {
        switch input {
        case "Done":
            "check"
        case "QA":
            "check"
        case "In Progress":
            "progress"
        case "In Review":
            "progress"
        default:
            "todo"
        }
    }

    func fetchActivity() async {
        isFetching = true
        errorMessage = nil
        
        do {
            guard let data = try await fetchLinearData(with: linearAPIKey, since: startDate) else {
                errorMessage = "Failed to fetch data"
                isFetching = false
                return
            }
            
            self.linear = try JSONDecoder().decode(Linear.self, from: data)
            
        } catch {
            errorMessage = error.localizedDescription
            print(error)
        }
        
        isFetching = false
    }

    func fetchLinearData(with apiKey: String, since date: Date) async throws -> Data? {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        guard let URL = URL(string: "https://api.linear.app/graphql") else { return nil }
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"

        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let isoDate = ISO8601DateFormatter().string(from: date)
        
        // Query to fetch assigned issues updated since the date
        let bodyString = """
        {
            "query": "query { viewer { assignedIssues(filter: { updatedAt: { gt: \\"\(isoDate)\\" } }) { nodes { id title url description updatedAt state { id name color type } project { id name description } } } } }",
            "variables": {}
        }
        """
        
        request.httpBody = bodyString.data(using: .utf8)

        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
             throw URLError(.badServerResponse)
        }
        
        return data
    }
}

#Preview {
    LinearHistoryView()
}
