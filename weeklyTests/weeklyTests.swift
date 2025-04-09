//
//  weeklyTests.swift
//  weeklyTests
//
//  Created by Stef Kors on 23/01/2025.
//

import Testing

struct weeklyTests {
    private func tokensMatchesQueryExact(_ tokens: [String], queryTokens: [String]) -> (matches: Bool, matchesCount: Int) {
        let matchingCount = tokens.filter { queryTokens.contains($0) }.count
        return (matchingCount > 0, matchingCount)
    }

    private func tokensMatchesQuery(_ tokens: [String], queryTokens: [String]) -> (matches: Bool, matchesCount: Int) {
        let count = queryTokens.reduce(0) { result, queryToken in
            if queryTokens.count > 1 {
                // Only match the tokens starting with the query token
                for token in tokens where token.hasPrefix(queryToken) {
                    return result + 1
                }
            } else {
                // Match any token containing the query token
                for token in tokens where token.contains(queryToken) || queryToken.contains(token) {
                    return result + 1
                }
            }
            return result
        }
        return (count > 0, count)
    }

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.

        let result = tokensMatchesQuery(["424", "855", "1052"], queryTokens: ["", "", "+14248551052"])
        #expect(result.matches == true)
        #expect(2 == result.matchesCount)
    }

    @Test func example2() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.

        let result = tokensMatchesQuery(["", "", "+14248551052"], queryTokens: ["424", "855", "1052"])
        #expect(result.matches == false)
        #expect(0 == result.matchesCount)
    }

    @Test func example3() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let result = tokensMatchesQuery(["424", "855", "1052"], queryTokens: ["+14248551052"])
        #expect(result.matches == true)
        #expect(1 == result.matchesCount)
    }

    @Test func example4() async throws {
        let result = tokensMatchesQuery(["kelechi", "lheagwara"], queryTokens: ["seva", "k"])
        #expect(result.matches == true)
        #expect(1 == result.matchesCount)

        let result2 = tokensMatchesQueryExact(["kelechi", "lheagwara"], queryTokens: ["seva", "k"])
        #expect(result2.matches == false)
        #expect(0 == result2.matchesCount)
    }

    @Test func example5() async throws {
        let result = tokensMatchesQuery(["stef", "kors"], queryTokens: ["stef", "kors"])
        #expect(result.matches == true)
        #expect(2 == result.matchesCount)

        let result2 = tokensMatchesQueryExact(["stef", "kors"], queryTokens: ["stef", "kors", "+1234234234"])
        #expect(result2.matches == true)
        #expect(2 == result2.matchesCount)
    }
}
