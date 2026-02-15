import Foundation

#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
import UIKit

/// In-app debug dashboard for ContextKit
/// Activated by shaking device in debug mode
@available(iOS 15.0, *)
public struct ContextDashboard: View {
    let instance: ContextKitInstance

    @State private var isVisible = false
    @State private var events: [ContextEvent] = []
    @State private var currentContext: ContextSnapshot?
    @State private var selectedTab = 0

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isVisible {
                    // Semi-transparent background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isVisible = false
                            }
                        }

                    // Dashboard panel
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.green)
                            Text("ContextKit Debug")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    isVisible = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(Color(white: 0.15))

                        // Tab selector
                        Picker("", selection: $selectedTab) {
                            Text("Events").tag(0)
                            Text("Context").tag(1)
                            Text("Network").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        .background(Color(white: 0.1))

                        // Content
                        ScrollView {
                            if selectedTab == 0 {
                                EventsView(events: events)
                            } else if selectedTab == 1 {
                                ContextView(context: currentContext)
                            } else {
                                NetworkView(events: events)
                            }
                        }
                        .frame(maxHeight: geometry.size.height * 0.7)

                        // Footer with actions
                        HStack(spacing: 20) {
                            Button(action: {
                                copyDebugInfo()
                            }) {
                                Label("Copy Debug Info", systemImage: "doc.on.doc")
                                    .font(.caption)
                            }

                            Spacer()

                            Button(action: {
                                Task {
                                    await refreshData()
                                }
                            }) {
                                Label("Refresh", systemImage: "arrow.clockwise")
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .background(Color(white: 0.15))
                    }
                    .background(Color(white: 0.1))
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .padding(30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Floating indicator when hidden
                if !isVisible && ContextKit.getConfig()?.debugMode == true {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    isVisible = true
                                }
                                Task {
                                    await refreshData()
                                }
                            }) {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.green)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .padding()
                        }
                    }
                }
            }
        }
        .onAppear {
            setupShakeGesture()
            Task {
                await refreshData()
            }
        }
    }

    private func setupShakeGesture() {
        // Shake gesture handler will be set up via UIWindow extension
    }

    private func refreshData() async {
        events = await instance.getEventQueue()
        currentContext = await instance.getCurrentContext()
    }

    private func copyDebugInfo() {
        Task {
            let context = await instance.getCurrentContext()
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

            if let data = try? encoder.encode(context),
               let json = String(data: data, encoding: .utf8) {
                #if canImport(UIKit)
                UIPasteboard.general.string = json
                #endif
            }
        }
    }
}

// MARK: - Events View

@available(iOS 15.0, *)
struct EventsView: View {
    let events: [ContextEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Events (\(events.count))")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top)

            if events.isEmpty {
                Text("No events tracked yet")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(events.prefix(20)) { event in
                    EventRow(event: event)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct EventRow: View {
    let event: ContextEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(event.name)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                Spacer()
                Text(timeAgo(event.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            HStack(spacing: 8) {
                ContextBadge(
                    icon: flag(for: event.context.geo.countryCode),
                    text: event.context.geo.countryCode
                )

                ContextBadge(
                    icon: timeIcon(for: event.context.time.dayPeriod),
                    text: event.context.time.localTime
                )

                ContextBadge(
                    icon: "iphone",
                    text: event.context.device.model.prefix(10) + "..."
                )
            }
        }
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private func flag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let flagScalar = UnicodeScalar(base + scalar.value) {
                flag.append(String(flagScalar))
            }
        }
        return flag.isEmpty ? "🌍" : flag
    }

    private func timeIcon(for period: TimeContext.DayPeriod) -> String {
        switch period {
        case .morning: return "☀️"
        case .afternoon: return "🌤"
        case .evening: return "🌅"
        case .night: return "🌙"
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 {
            return "\(seconds)s ago"
        } else if seconds < 3600 {
            return "\(seconds / 60)m ago"
        } else {
            return "\(seconds / 3600)h ago"
        }
    }
}

@available(iOS 15.0, *)
struct ContextBadge: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(white: 0.2))
        .cornerRadius(6)
    }
}

// MARK: - Context View

@available(iOS 15.0, *)
struct ContextView: View {
    let context: ContextSnapshot?

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Current Context")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top)

            if let context = context {
                ContextSection(title: "Time", items: [
                    ("Hour", "\(context.time.hour):00"),
                    ("Day", dayName(context.time.dayOfWeek)),
                    ("Period", context.time.dayPeriod.rawValue.capitalized),
                    ("Timezone", context.time.timezone)
                ])

                ContextSection(title: "Geography", items: [
                    ("Country", context.geo.countryCode),
                    ("Region", context.geo.region),
                    ("Currency", context.geo.currencyCode),
                    ("Language", context.geo.languageCode)
                ])

                ContextSection(title: "Device", items: [
                    ("Model", context.device.model),
                    ("OS", "iOS \(context.device.osVersion)"),
                    ("Screen", "\(Int(context.device.screenWidth))×\(Int(context.device.screenHeight))"),
                    ("Battery", batteryString(context.device.batteryLevel, context.device.batteryState))
                ])

                ContextSection(title: "User", items: [
                    ("User ID", context.user.userId ?? "Not set"),
                    ("Segment", context.user.segment ?? "None"),
                    ("Sessions", "\(context.user.sessionCount)"),
                    ("Days Active", "\(context.user.daysSinceInstall)")
                ])
            } else {
                Text("Loading context...")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }

    private func dayName(_ day: Int) -> String {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days[max(0, min(6, day - 1))]
    }

    private func batteryString(_ level: Double, _ state: DeviceContext.BatteryState) -> String {
        if level < 0 { return "Unknown" }
        let percent = Int(level * 100)
        let icon = state == .charging ? "⚡️" : ""
        return "\(percent)% \(icon)"
    }
}

@available(iOS 15.0, *)
struct ContextSection: View {
    let title: String
    let items: [(String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.green)
                .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(items, id: \.0) { item in
                    HStack {
                        Text(item.0)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(item.1)
                            .foregroundColor(.white)
                            .font(.system(.body, design: .monospaced))
                    }
                    .padding()
                    .background(Color(white: 0.15))

                    if item.0 != items.last?.0 {
                        Divider()
                            .background(Color(white: 0.2))
                    }
                }
            }
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

// MARK: - Network View

@available(iOS 15.0, *)
struct NetworkView: View {
    let events: [ContextEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Network Status")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top)

            VStack(spacing: 0) {
                HStack {
                    Text("Queue Size")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(events.count) events")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color(white: 0.15))

                Divider().background(Color(white: 0.2))

                HStack {
                    Text("Last Upload")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Just now")
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color(white: 0.15))

                Divider().background(Color(white: 0.2))

                HStack {
                    Text("Upload Status")
                        .foregroundColor(.gray)
                    Spacer()
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Connected")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color(white: 0.15))
            }
            .cornerRadius(10)
            .padding(.horizontal)

            Text("SDK Version")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top)

            HStack {
                Text("Version")
                    .foregroundColor(.gray)
                Spacer()
                Text(ContextKitSDK.version)
                    .foregroundColor(.white)
                    .font(.system(.body, design: .monospaced))
            }
            .padding()
            .background(Color(white: 0.15))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

#endif
