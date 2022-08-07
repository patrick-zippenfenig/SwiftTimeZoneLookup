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
            guard let field = result.pointee.fieldNames.advanced(by: Int(i)).pointee else {
                continue
            }
            guard let value = result.pointee.data.advanced(by: Int(i)).pointee else {
                continue
            }
            /*if strcmp(field, "CountryAlpha2") == 0 {
                countryAlpha2 = String(cString: value)
            }
            if strcmp(field, "CountryName") == 0 {
                countryName = String(cString: value)
            }*/
            if strcmp(field, "TimezoneIdPrefix") == 0 {
                timezoneIdPrefix = value
            }
            if strcmp(field, "TimezoneId") == 0 {
                timezoneId = value
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
