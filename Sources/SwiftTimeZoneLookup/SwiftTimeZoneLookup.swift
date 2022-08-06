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
        guard let cTimezone = ZDHelperSimpleLookupString(database, latitude, longitude) else {
            return nil
        }
        let timezone = String(cString: cTimezone)
        ZDHelperSimpleLookupStringFree(cTimezone)
        return timezone
    }
    
    deinit {
        ZDCloseDatabase(database)
    }
}
