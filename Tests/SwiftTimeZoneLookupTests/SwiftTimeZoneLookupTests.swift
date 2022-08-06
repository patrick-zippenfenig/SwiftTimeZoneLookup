import XCTest
@testable import SwiftTimeZoneLookup

final class SwiftTimeZoneLookupTests: XCTestCase {
    func testLookup() throws {
        let database = try SwiftTimeZoneLookup()
        XCTAssertEqual(database.lookup(latitude: 47.5, longitude: 8.6), "Europe/Zurich")
        XCTAssertEqual(database.lookup(latitude: 47.5, longitude: -2.6), "Europe/Paris")
        XCTAssertEqual(database.lookup(latitude: 47.5, longitude: -8.6), "Etc/GMT+1")
        XCTAssertEqual(database.lookup(latitude: 42.5, longitude: -8.6), "Europe/Madrid")
    }
}
