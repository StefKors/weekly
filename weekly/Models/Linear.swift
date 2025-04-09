//
//  Linear.swift
//  weekly
//
//  Created by Stef Kors on 27/01/2025.
//

import Foundation
import AppKit

// MARK: - Linear
struct Gemini: Equatable, Sendable, Codable {
    let projects: [GeminiProject]

    func copyToPasteboard() {
        var pasteboardString = ""
        pasteboardString += "*EOD Update*\n"
        for project in projects {
            if let title = project.title, !title.isEmpty {
                pasteboardString += "*" + title + "*\n"
            }
            guard let issues = project.issues else { return }

            pasteboardString += issues.map { $0.description }.joined(separator: "\n")
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(pasteboardString, forType: .string)
        }
    }
}

struct GeminiProject: Equatable, Sendable, Codable {
    let title: String?
    let issues: [GeminiIssue]?
}

// MARK: - LinearIssue
struct GeminiIssue: Equatable, Sendable, Codable {
    let label, status: String?
    let link: String?
    let summary: String?

    var description: String {
        var result = "\(status ?? "") "
        if let summary, !summary.isEmptyTrimmed {
            result += "\n\t\(summary)"
        }
        if let link {
            result += "[\(label ?? "")](\(link))"
        } else {
            result += "\(label ?? "")"
        }
        return result
    }
}

// MARK: - Linear
struct Linear: Equatable, Sendable, Codable {
    let data: LinearData?
}

// MARK: - LinearData
struct LinearData: Equatable, Sendable, Codable {
    let viewer: LinearViewer?
}

// MARK: - LinearViewer
struct LinearViewer: Equatable, Sendable, Codable {
    let assignedIssues: LinearAssignedIssues?
}

// MARK: - LinearAssignedIssuesNode
struct LinearAssignedIssuesNode: Equatable, Sendable, Codable {
    let id, title: String?
    let url: String?
    let description: String?
    let updatedAt: String?
    let state: LinearState?
    let project: LinearProject?
    let attachments: LinearAttachments?
    let comments: LinearAssignedIssues?
}

// MARK: - LinearAssignedIssues
struct LinearAssignedIssues: Equatable, Sendable, Codable {
    let nodes: [LinearAssignedIssuesNode]?
}

// MARK: - LinearAttachments
struct LinearAttachments: Equatable, Sendable, Codable {
    let nodes: [LinearAttachmentsNode]?
}

// MARK: - LinearAttachmentsNode
struct LinearAttachmentsNode: Equatable, Sendable, Codable {
    let url: String?
    let title: String?
    let subtitle: String?
}

// MARK: - LinearProject
struct LinearProject: Equatable, Sendable, Codable {
    let id, name, description: String?
}

// MARK: - LinearState
struct LinearState: Equatable, Sendable, Codable {
    let id, name, color, type: String?
}
