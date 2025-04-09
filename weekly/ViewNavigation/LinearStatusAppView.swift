//
//  LinearStatusAppView.swift
//  weekly
//
//  Created by Stef Kors on 27/01/2025.
//

import SwiftUI
import GoogleGenerativeAI

// Gemini flash
//You are a software engineer who is reporting the status of the projects you're working on from your issues in Linear.
//Please summarize the attached linear output of the issues in 1-2 sentences, focusing on the key points, status, important comments, and any updates.
//* Keep the link/URL to the issue in the output. Use markdown links
//* If there are github or slack links, include them in the output
//
//When you organize and summarize these issues:
//* start each issue with one of the following slack icons to communicate the current status:
//-   :aligned:
//-   :canceled:
//-   :check:
//-   :ongoing:
//-   :paused:
//-   :progress:
//-   :todo:
//* ONLY use these icons
//* Group the issues by projects
//* Use professional tone but be concise
//* Issue group title should be bold
//* If the status is communicated by icon don't repeat it in writing
//* Use the provided issue summaries to create a cohesive overview
//* If an issue has a GitHub pull request attached, please include a link to the PR
//* Include a link to the linear issue
//* If there are any links, include them in the summary
//* Format the output as slack markdown using bulleted list
//* Output only the summary, no other text

struct LinearStatusAppView: View {
    @AppStorage("linearAPIKey") var linearAPIKey: String = ""
    @AppStorage("geminiAPIKey") var geminiAPIKey: String = ""
    @AppStorage("Prompt") var geminiPrompt: String = """
You are a software engineer who is reporting the status of the projects you're working on from your issues in Linear.
Please summarize the status of the attached linear output in a bulleted list. Focus on the progress made today.

When you organize and summarize these issues:
* Use professional tone but be concise
* Use the provided issue summaries to create a cohesive overview
* Make the issue label a title text that's wrapped in a markdown link
* Provide more information for issues that are in progress
* Provide less information for issues that are finished
* The summary the space where you can add a personal note / mention any roadblocks. It is optional, prefer to leave it empty if there is nothing to note.
"""

    @State private var linear: Linear?
    @State private var output: String?
    @State private var isFetching: Bool = false
    @State private var loadingStatus: String?
    @State private var gemini: Gemini?
    @State private var findNavigatorIsPresented = true

    @AppStorage("prompt.temperature") private var temperature: Double = 0.2
    @AppStorage("prompt.days") private var days: Double = 1

    let size: CGFloat = 18

    var leadingView: some View {
        VStack {
            if isFetching == false && gemini == nil {
                Text("Start by Fetching content from Gemini and Linear")
                    .foregroundStyle(.secondary)
            }

            if isFetching {
                if let status = loadingStatus {
                    Text(status)
                }
                ProgressView().progressViewStyle(.linear)
            }

            //            if let output {
            //                Text(.init(output))
            //            }
            if let projects = gemini?.projects {
                ForEach(projects, id: \.title) { project in
                    //                    if let title = project.title {
                    //                        Text(title)
                    //                            .font(.title)
                    //                            .fontWeight(.bold)
                    //                    }
                    if let issues = project.issues {
                        VStack(alignment: .leading) {
                            ForEach(issues, id: \.label) { issue in
                                HStack(alignment: .top) {
                                    if let status = issue.status {
                                        Image(status.replacingOccurrences(of: ":", with: ""))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: size, height: size)
                                    }

                                    VStack(alignment: .leading) {
                                        if let text = issue.label {
                                            Text(.init(text))
                                        }

                                        if let summary = issue.summary, !summary.isEmptyTrimmed {
                                            Text(.init(summary))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
        }
        .frame(alignment: .top)
        .padding()
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
                withAnimation {
                    isFetching = true
                    loadingStatus = "Fetching..."
                }
                Task {
                    let result = try await queryGemini(forDays: Int(days))
                    withAnimation {
                        self.output = result
                        self.isFetching = false
                    }
                }
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

    var body: some View {
        VStack {
            HStack {
                ScrollView {
                    leadingView
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                Divider()
                trailingView
                    .frame(maxWidth: 380, maxHeight: .infinity, alignment: .top)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    gemini?.copyToPasteboard()
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

    func queryGemini(forDays days: Int = 0) async throws -> String? {
        withAnimation {
            loadingStatus = "Querying Linear..."
        }

        guard let linearData = try await fetchLinearData(with: linearAPIKey, forDays: days), let linearContent = String(data: linearData, encoding: .utf8) else {
            return nil
        }

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
            systemInstruction: geminiAPIKey
        )

        let chat = model.startChat(history: [])
        do {
            let message = linearContent
            withAnimation {
                loadingStatus = "Fetching Gemini response..."
            }
            let response = try await chat.sendMessage(message)
            print(response.text ?? "No response received")
            if let data = response.text?.data(using: .utf8) {
                withAnimation {
                    loadingStatus = "Gemini response fetched..."
                    self.gemini = try? JSONDecoder().decode(Gemini.self, from: data)
                }
            }
            return response.text
        } catch {
            print(error)
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

    let jsonSchema = Schema(type: .object, properties: [
        "projects": Schema(
            type: .array,
            description: "List of projects",
            items:
                Schema(type: .object, properties: [
                    "title": Schema(type: .string, description: "Title of the linear project", nullable: false),
                    "issues": Schema(
                        type: .array,
                        description: "List of linear project issues",
                        items:
                            Schema(
                                type: .object,
                                properties: [
                                    "status": Schema(
                                        type: .string,
                                        description: "Name of the recipe",
                                        nullable: false,
                                        enumValues: [":todo:",":progress:",":check:",":canceled:"]
                                    ),
                                    "label": Schema(type: .string, description: "Title of the issue", nullable: false),
                                    "link": Schema(type: .string, description: "Github, Slack or Linear link", nullable: true),
                                    //                                    "summary": Schema(type: .string, description: "Optional short reflection on the changes and potential roadblocks, leave empty if possible", nullable: true),
                                ],
                                requiredProperties: ["status", "label"]
                            )
                    )
                ])
        )
    ])


}

#Preview {
    LinearStatusAppView()
        .previewSetup()
}
