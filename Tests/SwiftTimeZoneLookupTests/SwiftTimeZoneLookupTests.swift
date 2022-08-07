import XCTest
import SwiftTimeZoneLookup

final class SwiftTimeZoneLookupTests: XCTestCase {
    func testLookup() throws {
        let database = try SwiftTimeZoneLookup()
        XCTAssertEqual(database.simple(latitude: 47.5, longitude: 8.6), "Europe/Zurich")
        XCTAssertEqual(database.simple(latitude: 47.5, longitude: -2.6), "Europe/Paris")
        XCTAssertEqual(database.simple(latitude: 47.5, longitude: -8.6), "Etc/GMT+1")
        XCTAssertEqual(database.simple(latitude: 42.5, longitude: -8.6), "Europe/Madrid")
        
        XCTAssertEqual(database.simple(latitude: 242.5, longitude: -8.6), nil)
        
        XCTAssertEqual(database.lookup(latitude: 42.5, longitude: -8.6)?.countryName, "Spain")
        XCTAssertEqual(database.lookup(latitude: 42.5, longitude: -8.6)?.countryAlpha2, "ES")
        
        // on the border to the netherlands. Requires high resolution lookup
        XCTAssertEqual(database.simple(latitude: 53.242293, longitude: 7.209253), "Europe/Berlin")
        XCTAssertEqual(database.simple(latitude: 53.239692, longitude: 7.207879), "Europe/Amsterdam")
    }
}
