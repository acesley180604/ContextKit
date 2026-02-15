import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Device hardware and state context for an event
/// IMPORTANT: Uses only publicly available APIs - NO special permissions required
public struct DeviceContext: Codable, Sendable {
    /// Device model (e.g., "iPhone 15 Pro", "iPad Air")
    public let model: String

    /// Operating system version (e.g., "17.2.1")
    public let osVersion: String

    /// Screen width in points
    public let screenWidth: Double

    /// Screen height in points
    public let screenHeight: Double

    /// Screen scale factor (e.g., 2.0 for @2x, 3.0 for @3x)
    public let screenScale: Double

    /// Battery level (0.0 to 1.0, or -1 if unavailable)
    public let batteryLevel: Double

    /// Battery state
    public let batteryState: BatteryState

    /// Network connection type
    public let networkType: NetworkType

    /// Whether low power mode is enabled
    public let isLowPowerMode: Bool

    /// Available disk space in bytes (-1 if unavailable)
    public let availableDiskSpace: Int64

    /// Total memory in bytes
    public let totalMemory: UInt64

    /// Battery state enumeration
    public enum BatteryState: String, Codable, Sendable {
        case unknown
        case unplugged
        case charging
        case full
    }

    /// Network connection type
    public enum NetworkType: String, Codable, Sendable {
        case unknown
        case wifi
        case cellular
        case offline
    }

    /// Capture current device context
    /// - Returns: DeviceContext with current device information
    public static func capture() -> DeviceContext {
        #if canImport(UIKit) && !targetEnvironment(macCatalyst)
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true

        let model = deviceModel()
        let osVersion = device.systemVersion
        let screen = UIScreen.main
        let screenWidth = Double(screen.bounds.width)
        let screenHeight = Double(screen.bounds.height)
        let screenScale = Double(screen.scale)

        let batteryLevel = device.batteryLevel >= 0 ? Double(device.batteryLevel) : -1.0
        let batteryState: BatteryState
        switch device.batteryState {
        case .unknown:
            batteryState = .unknown
        case .unplugged:
            batteryState = .unplugged
        case .charging:
            batteryState = .charging
        case .full:
            batteryState = .full
        @unknown default:
            batteryState = .unknown
        }

        let networkType = detectNetworkType()
        let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        let availableDiskSpace = getAvailableDiskSpace()
        let totalMemory = ProcessInfo.processInfo.physicalMemory

        return DeviceContext(
            model: model,
            osVersion: osVersion,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            screenScale: screenScale,
            batteryLevel: batteryLevel,
            batteryState: batteryState,
            networkType: networkType,
            isLowPowerMode: isLowPowerMode,
            availableDiskSpace: availableDiskSpace,
            totalMemory: totalMemory
        )
        #else
        // macOS or Mac Catalyst fallback
        return DeviceContext(
            model: "Mac",
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            screenWidth: 0,
            screenHeight: 0,
            screenScale: 1.0,
            batteryLevel: -1,
            batteryState: .unknown,
            networkType: .wifi,
            isLowPowerMode: false,
            availableDiskSpace: getAvailableDiskSpace(),
            totalMemory: ProcessInfo.processInfo.physicalMemory
        )
        #endif
    }

    /// Get human-readable device model name
    private static func deviceModel() -> String {
        #if canImport(UIKit) && !targetEnvironment(macCatalyst)
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        // Map identifiers to readable names
        let modelMap: [String: String] = [
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 14",
            "iPhone15,5": "iPhone 14 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone16,3": "iPhone 15",
            "iPhone16,4": "iPhone 15 Plus",
            "iPad13,1": "iPad Air (4th gen)",
            "iPad13,2": "iPad Air (4th gen)",
            "iPad14,1": "iPad mini (6th gen)",
            "iPad14,2": "iPad mini (6th gen)",
        ]

        return modelMap[identifier] ?? identifier
        #else
        return "Mac"
        #endif
    }

    /// Detect network connection type (simplified, no permissions)
    private static func detectNetworkType() -> NetworkType {
        // Without using Network framework (which requires entitlements),
        // we can only make basic assumptions
        // In production, you might integrate with NWPathMonitor
        return .wifi // Default assumption
    }

    /// Get available disk space
    private static func getAvailableDiskSpace() -> Int64 {
        do {
            let fileURL = URL(fileURLWithPath: NSHomeDirectory())
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            if let capacity = values.volumeAvailableCapacity {
                return Int64(capacity)
            }
        } catch {
            // Silently fail
        }
        return -1
    }

    private enum CodingKeys: String, CodingKey {
        case model
        case osVersion = "os_version"
        case screenWidth = "screen_width"
        case screenHeight = "screen_height"
        case screenScale = "screen_scale"
        case batteryLevel = "battery_level"
        case batteryState = "battery_state"
        case networkType = "network_type"
        case isLowPowerMode = "is_low_power_mode"
        case availableDiskSpace = "available_disk_space"
        case totalMemory = "total_memory"
    }
}
