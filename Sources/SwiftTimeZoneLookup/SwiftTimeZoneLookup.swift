@_implementationOnly import CZoneDetect
import Foundation

public enum SwiftTimeZoneLookupError: Error {
    case couldNotFindTimezone21bin
    case couldNotOpenDatabase
}

public struct SwiftTimeZoneLookupResult {
    /// Timezone identifier like `Europe/Berlin`
    public let timezone: String
    
    /// Country name like `Germany`
    public let countryName: String?
    
    /// 2 character country code like `DE` for Germany
    public let countryAlpha2: String?
}

public final class SwiftTimeZoneLookup {
    /// 0.00017 degrees (~20m) resolution
    private let database21: OpaquePointer
    
    /// 0.0055 degrees (~0.5km) resolution
    private let database16: OpaquePointer
    
    /// Throws if the timezone database could not be opened
    /// If an optional `databasePath` is provided, it tries first to uses this path and then uses the default bundle resources path
    public init(databasePath: String? = nil) throws {
        if let databasePath = databasePath,
            let database21 = ZDOpenDatabase("\(databasePath)timezone21.bin"),
            let database16 = ZDOpenDatabase("\(databasePath)timezone16.bin")
        {
                self.database21 = database21
                self.database16 = database16
                return
        }
        
        guard let timezone21 = Bundle.module.path(forResource: "timezone21", ofType: "bin") else {
            throw SwiftTimeZoneLookupError.couldNotFindTimezone21bin
        }
        guard let timezone16 = Bundle.module.path(forResource: "timezone16", ofType: "bin") else {
            throw SwiftTimeZoneLookupError.couldNotFindTimezone21bin
        }
        
        guard let database21 = ZDOpenDatabase(timezone21) else {
            throw SwiftTimeZoneLookupError.couldNotOpenDatabase
        }
        guard let database16 = ZDOpenDatabase(timezone16) else {
            throw SwiftTimeZoneLookupError.couldNotOpenDatabase
        }
        
        self.database21 = database21
        self.database16 = database16
    }
    
    /// Try with lower resolution first and use high resolution database if too close to the border
    private func highResLookup(latitude: Float, longitude: Float) -> UnsafeMutablePointer<ZoneDetectResult>? {
        var safezone: Float = .nan
        guard let result = ZDLookup(database16, latitude, longitude, &safezone) else {
            return nil
        }
        if safezone >= 0.0055*2 {
            return result
        }
        guard let result21 = ZDLookup(database21, latitude, longitude, &safezone) else {
            return nil
        }
        return result21
    }
    
    /// Resolve timezone by coordinate and return timezone, country name and alpha2
    public func lookup(latitude: Float, longitude: Float) -> SwiftTimeZoneLookupResult? {
        guard let result = highResLookup(latitude: latitude, longitude: longitude) else {
            return nil
        }
        defer { ZDFreeResults(result) }
        var countryName: String? = nil
        var countryAlpha2: String? = nil
        var timezoneIdPrefix: UnsafeMutablePointer<CChar>? = nil
        var timezoneId: UnsafeMutablePointer<CChar>? = nil
        for i in 0..<result.pointee.numFields {
            guard let field = result.pointee.fieldNames.advanced(by: Int(i)).pointee else {
                continue
            }
            guard let value = result.pointee.data.advanced(by: Int(i)).pointee else {
                continue
            }
            if strcmp(field, "CountryAlpha2") == 0 {
                countryAlpha2 = String(cString: value)
            }
            if strcmp(field, "CountryName") == 0 {
                countryName = String(cString: value)
            }
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
        return SwiftTimeZoneLookupResult(timezone: timezone, countryName: countryName, countryAlpha2: countryAlpha2)
    }
    
    /// Resolve the timz
    public func simple(latitude: Float, longitude: Float) -> String? {
        guard let result = highResLookup(latitude: latitude, longitude: longitude) else {
            return nil
        }
        defer { ZDFreeResults(result) }
        var timezoneIdPrefix: UnsafeMutablePointer<CChar>? = nil
        var timezoneId: UnsafeMutablePointer<CChar>? = nil
        for i in 0..<result.pointee.numFields {
            guard let field = result.pointee.fieldNames.advanced(by: Int(i)).pointee else {
                continue
            }
            guard let value = result.pointee.data.advanced(by: Int(i)).pointee else {
                continue
            }
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
        ZDCloseDatabase(database21)
    }
}
