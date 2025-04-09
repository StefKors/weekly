//
//  String.swift
//  weekly
//
//  Created by Stef Kors on 02/02/2025.
//

import Foundation

extension String {
    var isEmptyTrimmed: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
