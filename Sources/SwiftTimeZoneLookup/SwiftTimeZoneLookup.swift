@_implementationOnly import CZoneDetect
import Foundation

public enum SwiftTimeZoneLookupError: Error {
    case couldNotFindTimezone21bin
    case couldNotOpenDatabase
}

public final class SwiftTimeZoneLookup {
    private let database: OpaquePointer
    
    public init() throws {
        guard let timezone21 = Bundle.module.url(forResource: "timezone21", withExtension: "bin") else {
            throw SwiftTimeZoneLookupError.couldNotFindTimezone21bin
        }
        guard let database = timezone21.withUnsafeFileSystemRepresentation({ timezone21 in
            ZDOpenDatabase(timezone21)
        }) else {
            throw SwiftTimeZoneLookupError.couldNotOpenDatabase
        }
        self.database = database
    }
    
    public func lookup(latitude: Float, longitude: Float) -> String? {
        guard let result = ZDLookup(database, latitude, longitude, nil) else {
            return nil
        }
        defer { ZDFreeResults(result) }
        /*var countryName: String? = nil
        var countryAlpha2: String? = nil*/
        var timezoneIdPrefix: UnsafeMutablePointer<CChar>? = nil
        var timezoneId: UnsafeMutablePointer<CChar>? = nil
        for i in 0..<result.pointee.numFields {
            /*if strcmp(result.pointee.fieldNames.advanced(by: Int(i)).pointee, "CountryAlpha2") == 0 {
                countryAlpha2 = result.pointee.data.advanced(by: Int(i)).pointee.map { String(cString: $0) }
            }
            if strcmp(result.pointee.fieldNames.advanced(by: Int(i)).pointee, "CountryName") == 0 {
                countryName = result.pointee.data.advanced(by: Int(i)).pointee.map { String(cString: $0) }
            }*/
            if strcmp(result.pointee.fieldNames.advanced(by: Int(i)).pointee, "TimezoneIdPrefix") == 0 {
                timezoneIdPrefix = result.pointee.data.advanced(by: Int(i)).pointee
            }
            if strcmp(result.pointee.fieldNames.advanced(by: Int(i)).pointee, "TimezoneId") == 0 {
                timezoneId = result.pointee.data.advanced(by: Int(i)).pointee
            }
        }
        guard let timezoneIdPrefix = timezoneIdPrefix, let timezoneId = timezoneId else {
            return nil
        }
        let timezone = String(cString: timezoneIdPrefix) + String(cString: timezoneId)
        return timezone
    }
    
    deinit {
        ZDCloseDatabase(database)
    }
}
