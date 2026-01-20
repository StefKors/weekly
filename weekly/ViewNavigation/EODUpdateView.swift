//
//  EODUpdateView.swift
//  weekly
//
//  Created by Stef Kors on 22/06/2025.
//

import SwiftUI
import GoogleGenerativeAI

struct OptionalRedacted: ViewModifier {
    let isFetching: Bool
    func body(content: Content) -> some View {
        if isFetching {
            content
                .redacted(reason: .placeholder)
        } else {
            content
        }

    }
}

#Preview {
    Text("Hello, world!")
        .modifier(OptionalRedacted(isFetching: false))
}

struct EODUpdateView: View {
    var minimal: Bool = false
    @AppStorage("linearAPIKey") var linearAPIKey: String = ""
    @AppStorage("geminiAPIKey") var geminiAPIKey: String = ""
    @AppStorage("Prompt-Summary") private var geminiPrompt: String = """
        You are a software engineer who is reporting the daily (End Of Day) status of the projects you're working on from your issues in Linear.
        Please summarize the attached linear output of the issues in 1-2 sentences, focusing on the key points, status, important comments, and any updates. The interface will already display the list and status of the linear issues. Write it like you are the person who is giving the status update
        """

    @AppStorage("linear-response") private var linearData: Data?
    var linear: Linear? {
        if let linearData {
            parseData(linearData)
        } else {
            nil
        }
    }
    @State private var output: String?
    @State private var isFetching: Bool = false
    @State private var loadingStatus: String?
    @AppStorage("gemini-response") private var gemini: String?
    @AppStorage("date") private var date: Date?
    @AppStorage("daysFetched") private var daysFetched: Int = 1
    @State private var findNavigatorIsPresented = true

    @AppStorage("prompt-summary.temperature") private var temperature: Double = 1
    @AppStorage("prompt-summary.days") private var days: Double = 1

    var leadingView: some View {
        VStack(alignment: .leading) {
            if isFetching == false && gemini == nil {
                Text("Start by Fetching content from Gemini and Linear")
                    .foregroundStyle(.secondary)
            }

                if let date {
                    HStack(spacing: 6) {
                        let startOfDateRange = Calendar.current.date(byAdding: .day, value: -daysFetched, to: date) ?? date
                        if daysFetched > 1 {
                            Text(startOfDateRange, format: .dateTime.day().weekday(.wide).month(.wide))
                            Text("-")
                        }
                        Text(date, format: .dateTime.day().weekday(.wide).month(.wide))
                    }
                    .fontWeight(.semibold)

                    Divider()
                }
                if let gemini, let summary = try? AttributedString(
                    markdown: gemini,
                    options: .init(
                        allowsExtendedAttributes: true,
                        interpretedSyntax: .full,
                        failurePolicy: .returnPartiallyParsedIfPossible
                    )
                ) {
                    Text(summary)

                    Divider()
                }

                VStack(alignment: .leading) {
                    if let issues = linear?.data?.viewer?.assignedIssues?.nodes?.sorted(by: { lhs, rhs in
                        let order = ["check", "progress", "todo"]
                        let left = linearStatusToEmoji(lhs.state?.name ?? "")
                        let right = linearStatusToEmoji(rhs.state?.name ?? "")

                        if let leftIndex = order.firstIndex(of: left),
                           let rightIndex = order.firstIndex(of: right) {
                            return (leftIndex < rightIndex)
                        }
                        return (left > right)
                    }) {
                        ForEach(issues, id: \.id) { issue in
                            HStack(alignment: .top) {
                                Image(linearStatusToEmoji(issue.state?.name))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 16, height: 16)

                                VStack(alignment: .leading) {
                                    if let text = issue.title {
                                        Text(.init(text))
                                    }
                                }
                            }
                        }
                    }
                }
        }
        .frame(alignment: .top)
        .padding()
        .modifier(OptionalRedacted(isFetching: isFetching))
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            if minimal {
                VStack(alignment: .leading, spacing: 0) {
                leadingView

                    HStack() {
                        Button {
                            fetch()
                        } label: {
                            Image(systemName: "repeat")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 12, height: 12, alignment: .center)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            if let gemini, let linear {
                                let issues = linear.data?.viewer?.assignedIssues?.nodes?.map { issue in
                                    let status = linearStatusToEmoji(issue.state?.name)
                                    return ":\(status): \(issue.title ?? "")"
                                }.joined(separator: "\n") ?? ""
                                var pasteboardString = """
                                \(gemini)
                                \(issues)
                                """
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(pasteboardString, forType: .string)
                            }
                            dismiss()
                        } label: {
                            Text("Copy")
                                .frame(maxWidth: .infinity, alignment: .top)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .frame(maxWidth: 380, maxHeight: .infinity, alignment: .top)
                .task {
                    if gemini == nil {
                        fetch()
                    }
                }
            } else {
                HStack {
                    ScrollView {
                        leadingView
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    Divider()
                    trailingView
                        .frame(maxWidth: 380, maxHeight: .infinity, alignment: .top)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
//                                                gemini?.copyToPasteboard()
                        } label: {
                            Label {
                                Text("Copy to Slack")
                            } icon: {
                                Image(.slack)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .grayscale(1)
                                    .frame(width: 20, height: 20, alignment: .center)
                            }
                        }

                    }
                }
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


    var trailingView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Gemini API Key")
                                .foregroundStyle(.secondary)
                            HStack {
                                SecureField("Gemini API Key", text: $geminiAPIKey)
                                Button {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(geminiAPIKey, forType: .string)
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                }
                                .buttonStyle(.borderless)
                            }
                        }

                        Divider()

                        VStack(alignment: .leading) {
                            Text("Linear API Key")
                                .foregroundStyle(.secondary)
                            HStack {
                                SecureField("Linear API Key", text: $linearAPIKey)
                                Button {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(linearAPIKey, forType: .string)
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                    Divider()

                    VStack(alignment: .leading) {
                        Text("Temperature \(temperature.description)")
                            .foregroundStyle(.secondary)

                        Slider(
                            value: $temperature,
                            in: 0.0...2.0,
                            step: 0.1,
                            label: {},
                            minimumValueLabel: {
                                Text("0")
                            }, maximumValueLabel: {
                                Text("2")
                            })
                    }

                    VStack(alignment: .leading) {
                        Text("Days \(days.description)")
                            .foregroundStyle(.secondary)

                        Slider(
                            value: $days,
                            in: 1.0...14.0,
                            step: 1,
                            label: {},
                            minimumValueLabel: {
                                Text("1")
                            }, maximumValueLabel: {
                                Text("14")
                            })
                    }

                    Divider()
                    TextEditor(text: $geminiPrompt)
                        .textEditorStyle(.plain)
                    //            TextField("Gemini Prompt", text: $geminiPrompt, axis: .vertical)
                    //                    .textFieldStyle(.plain)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            Divider()

            Button {
                fetch()
            } label: {
                Text("Fetch Updates")
                    .fontDesign(.rounded)
                    .padding(4)
                    .frame(maxWidth: .infinity)
            }
        }
        .textFieldStyle(.roundedBorder)
        .buttonStyle(.borderedProminent)
        .padding()
    }

    func fetch() {
        withAnimation {
            isFetching = true
            loadingStatus = "Fetching..."
        }
        Task {
            do {
                let result = try await queryGemini(forDays: Int(days))
                withAnimation {
                    self.output = result
                    self.isFetching = false
                }
            } catch {
                print(error)
            }
        }
    }

    let jsonSchema = Schema(type: .object, properties: [
        "summary": Schema(type: .string)
    ])

    func queryGemini(forDays days: Int = 0) async throws -> String? {
        withAnimation {
            loadingStatus = "Querying Linear..."
        }

        guard let linearData = try await fetchLinearData(with: linearAPIKey, forDays: days), let linearContent = String(data: linearData, encoding: .utf8) else {
            return nil
        }

        self.linearData = linearData

        // empty issues
        if linearContent.contains("{\"data\":{\"viewer\":{\"assignedIssues\":{\"nodes\":[]}}}}") {
            print("retrying with \(days.description) days")
            return try? await queryGemini(forDays: days + 1)
        }

        withAnimation {
            loadingStatus = "Configuring Gemini..."
        }

        let config = GenerationConfig(
            temperature: Float($temperature.wrappedValue),
            topP: 0.95,
            topK: 40,
            maxOutputTokens: 8192,
            responseMIMEType: "application/json",
            responseSchema: jsonSchema
        )

        let model = GenerativeModel(
            name: "gemini-2.0-flash-exp",
            apiKey: geminiAPIKey,
            generationConfig: config,
            systemInstruction: geminiPrompt
        )

        print(linearContent)
        let chat = model.startChat(history: [])
        do {
            let message = linearContent.replacingOccurrences(of: "\"name\":\"QA\",", with: "\"name\":\"Done\",")
            withAnimation {
                loadingStatus = "Fetching Gemini response..."
            }
            let response = try await chat.sendMessage(message)
            print("Received Response")
            print(response.text ?? "No response received")
//            print(response.text)
            if let data = response.text?.data(using: .utf8) {
                withAnimation {
                    loadingStatus = "Gemini response fetched..."
//                    self.gemini = response.text
                    let result = try? JSONDecoder().decode(Gemini2.self, from: data)
                    self.gemini = result?.summary
                    print("✅ \(result?.summary ?? "No response received")")
                    self.date = .now
                    self.daysFetched = days
                }
            }
            return response.text
        } catch {
            print("Received Error")
            print(error.localizedDescription)
        }

        return nil
    }

    func fetchLinearData(with apiKey: String, forDays days: Int) async throws -> Data? {
        /* Configure session, choose between:
         * defaultSessionConfiguration
         * ephemeralSessionConfiguration
         * backgroundSessionConfigurationWithIdentifier:
         And set session-wide properties, such as: HTTPAdditionalHeaders,
         HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
         */
        let sessionConfig = URLSessionConfiguration.default

        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        /* Create the Request:
         Request (POST https://api.linear.app/graphql)
         */

        guard let URL = URL(string: "https://api.linear.app/graphql") else { return nil }
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"

        // Headers
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        // Body
        // ignores tickets in backlog
        let bodyString = "{\n    \"query\": \"query{viewer{assignedIssues(filter:{updatedAt:{gt:\\\"-P\(days.description)D\\\"},state:{type:{nin:[\\\"backlog\\\"]}}}){nodes{id title url description updatedAt state{id name color type}project{id name description}attachments{nodes{url title subtitle}}comments{nodes{id body}}}}}}\",\n    \"variables\": {}\n}"
        request.httpBody = bodyString.data(using: .utf8, allowLossyConversion: true)

        /* Start a new Task */
        let (data, response) = try await session.data(for: request)
        let statusCode = (response as! HTTPURLResponse).statusCode
        print("URL Session Task Succeeded: HTTP \(statusCode)")
        return data
    }

    func parseData(_ data: Data) -> Linear? {
        return try? JSONDecoder().decode(Linear.self, from: data)
    }

}

#Preview {
    EODUpdateView()
}
