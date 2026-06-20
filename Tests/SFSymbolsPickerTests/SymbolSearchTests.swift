import XCTest
@testable import SFSymbolsPicker

final class SymbolSearchTests: XCTestCase {
    func testSearchMatchesSymbolNameComponentsWhenPrefixMatchesExist() {
        let symbols = [
            "walkie.talkie",
            "figure.walk",
            "figure.walk.circle",
            "figure.golf"
        ]

        let results = SymbolSearch.sortedMatches(in: symbols, matching: "walk")

        XCTAssertEqual(results, [
            "walkie.talkie",
            "figure.walk",
            "figure.walk.circle"
        ])
    }

    func testSearchMatchesLaterSymbolNameComponents() {
        let symbols = [
            "figure.walk",
            "figure.golf",
            "figure.golf.circle",
            "figure.golf.circle.fill",
            "gamecontroller.fill",
            "flag.checkered"
        ]

        let results = SymbolSearch.sortedMatches(in: symbols, matching: "golf")

        XCTAssertEqual(results, [
            "figure.golf",
            "figure.golf.circle",
            "figure.golf.circle.fill"
        ])
    }

    func testSearchTrimsWhitespace() {
        let symbols = [
            "figure.walk",
            "figure.golf"
        ]

        let results = SymbolSearch.sortedMatches(in: symbols, matching: " golf ")

        XCTAssertEqual(results, ["figure.golf"])
    }
}
