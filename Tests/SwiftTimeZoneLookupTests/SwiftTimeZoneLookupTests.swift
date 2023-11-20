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
        
        // Astypalaia island in Greece does not resolve any timezone and would return nil
        // Reasons unknown, could be an invalid polygon
        XCTAssertEqual(database.simple(latitude: 36.5362, longitude: 26.3396), "Europe/Athens") // Hard coded fix now in code
        XCTAssertEqual(database.simple(latitude: 36.8370, longitude: 25.8904), "Europe/Athens") // island to the north
        XCTAssertEqual(database.simple(latitude: 36.3683, longitude: 25.7735), "Europe/Athens") // island to north west
        

    }
}
