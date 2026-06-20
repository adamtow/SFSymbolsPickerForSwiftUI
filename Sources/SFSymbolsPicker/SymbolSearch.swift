//
//  SymbolSearch.swift
//
//
//  Created by Adam Tow on 19/06/26.
//

import Foundation

enum SymbolSearch {
    static func sortedMatches(in symbols: [String], matching name: String) -> [String] {
        let query = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }

        return symbols.enumerated()
            .compactMap { index, symbol -> SymbolSearchMatch? in
                guard let rank = symbol.searchRank(for: query) else { return nil }
                return SymbolSearchMatch(symbol: symbol, rank: rank, index: index)
            }
            .sorted { lhs, rhs in
                if lhs.rank != rhs.rank {
                    return lhs.rank < rhs.rank
                }

                return lhs.index < rhs.index
            }
            .map(\.symbol)
    }
}

private struct SymbolSearchMatch {
    let symbol: String
    let rank: Int
    let index: Int
}

private extension String {
    func searchRank(for query: String) -> Int? {
        let query = query.lowercased()
        let symbol = lowercased()

        if symbol.hasPrefix(query) {
            return 0
        }

        if symbol
            .split(separator: ".")
            .contains(where: { String($0).hasPrefix(query) }) {
            return 1
        }

        if localizedStandardContains(query) {
            return 2
        }

        if fuzzyMatch(query) {
            return 3
        }

        return nil
    }

    func fuzzyMatch(_ pattern: String) -> Bool {
        let pattern = pattern.lowercased()
        let string = lowercased()

        if pattern.isEmpty { return true }
        if string.isEmpty { return false }

        var patternIndex = pattern.startIndex
        var stringIndex = string.startIndex

        while patternIndex < pattern.endIndex && stringIndex < string.endIndex {
            if pattern[patternIndex] == string[stringIndex] {
                patternIndex = pattern.index(after: patternIndex)
            }
            stringIndex = string.index(after: stringIndex)
        }

        return patternIndex == pattern.endIndex
    }
}
