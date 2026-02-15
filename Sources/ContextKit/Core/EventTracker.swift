import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Thread-safe event queue and batch uploader
actor EventTracker {
    private var eventQueue: [ContextEvent] = []
    private var screenViews: [String: Date] = [:] // Track screen view start times
    private var uploadTimer: Timer?
    private var isUploading = false

    private let config: ContextKitConfig
    private let userManager: UserContextManager
    private let sessionManager: SessionManager
    private let apiClient: APIClient

    // Persistence keys
    private let queueKey = "ContextKit.eventQueue"
    private let defaults = UserDefaults.standard

    init(
        config: ContextKitConfig,
        userManager: UserContextManager,
        sessionManager: SessionManager,
        apiClient: APIClient
    ) {
        self.config = config
        self.userManager = userManager
        self.sessionManager = sessionManager
        self.apiClient = apiClient

        // Restore persisted events
        restorePersistedEvents()

        // Setup app lifecycle observers
        setupLifecycleObservers()
    }

    // MARK: - Public API

    /// Track an event with custom properties
    func track(name: String, properties: [String: Any]) async {
        // Capture context snapshot
        let context = await ContextSnapshot.capture(
            userManager: userManager,
            sessionManager: sessionManager,
            config: config
        )

        // Create event
        let event = ContextEvent(
            name: name,
            properties: properties,
            context: context
        )

        // Add to queue
        eventQueue.append(event)

        // Increment session event count
        await sessionManager.incrementEventCount()

        // Check if should upload
        if eventQueue.count >= config.maxBatchSize {
            await uploadEvents()
        }

        // Persist queue
        persistEvents()

        if config.debugMode {
            print("[ContextKit] Event tracked: \(name) (queue: \(eventQueue.count))")
        }
    }

    /// Track a screen view
    func trackScreen(name: String) async {
        // Track screen view in session
        await sessionManager.trackScreenView(name)

        // Track previous screen duration if exists
        if let startTime = screenViews[name] {
            let duration = Date().timeIntervalSince(startTime)
            // Track as event with duration
            await track(name: "screen_view", properties: [
                "screen_name": name,
                "duration": duration
            ])
        } else {
            // Track new screen view
            await track(name: "screen_view", properties: [
                "screen_name": name
            ])
        }

        // Update current screen
        screenViews[name] = Date()
    }

    /// Force upload of all queued events
    func flush() async {
        await uploadEvents()
    }

    /// Get current queue size
    func getQueueSize() -> Int {
        return eventQueue.count
    }

    /// Get all events (for debug overlay)
    func getAllEvents() -> [ContextEvent] {
        return eventQueue
    }

    // MARK: - Upload Logic

    private func uploadEvents() async {
        guard !eventQueue.isEmpty && !isUploading else { return }

        isUploading = true
        let eventsToUpload = eventQueue

        if config.debugMode {
            print("[ContextKit] Uploading \(eventsToUpload.count) events...")
        }

        do {
            try await apiClient.uploadEvents(eventsToUpload)

            // Clear uploaded events
            eventQueue.removeAll()
            persistEvents()

            if config.debugMode {
                print("[ContextKit] Successfully uploaded \(eventsToUpload.count) events")
            }
        } catch {
            if config.debugMode {
                print("[ContextKit] Upload failed: \(error.localizedDescription)")
            }
            // Events remain in queue for retry
        }

        isUploading = false
    }

    // MARK: - Persistence

    private func persistEvents() {
        guard let encoded = try? JSONEncoder().encode(eventQueue) else { return }
        defaults.set(encoded, forKey: queueKey)
    }

    private func restorePersistedEvents() {
        guard let data = defaults.data(forKey: queueKey),
              let events = try? JSONDecoder().decode([ContextEvent].self, from: data) else {
            return
        }

        eventQueue = events

        if config.debugMode && !events.isEmpty {
            print("[ContextKit] Restored \(events.count) persisted events")
        }
    }

    // MARK: - Lifecycle Observers

    private func setupLifecycleObservers() {
        #if canImport(UIKit) && !targetEnvironment(macCatalyst)
        Task { @MainActor in
            // App entering background - flush events
            NotificationCenter.default.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task {
                    await self?.handleAppBackground()
                }
            }

            // App entering foreground - start session
            NotificationCenter.default.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task {
                    await self?.handleAppForeground()
                }
            }

            // App terminating - flush events
            NotificationCenter.default.addObserver(
                forName: UIApplication.willTerminateNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task {
                    await self?.handleAppTerminate()
                }
            }
        }
        #endif
    }

    private func handleAppBackground() async {
        await sessionManager.endSession()
        await uploadEvents()
        persistEvents()
    }

    private func handleAppForeground() async {
        await sessionManager.startSession()
        await userManager.incrementSessionCount()
    }

    private func handleAppTerminate() async {
        await uploadEvents()
        persistEvents()
    }

    /// Start periodic upload timer
    func startUploadTimer() {
        Task { @MainActor in
            uploadTimer?.invalidate()
            uploadTimer = Timer.scheduledTimer(
                withTimeInterval: config.uploadInterval,
                repeats: true
            ) { [weak self] _ in
                Task {
                    await self?.uploadEvents()
                }
            }
        }
    }

    /// Stop upload timer
    func stopUploadTimer() {
        Task { @MainActor in
            uploadTimer?.invalidate()
            uploadTimer = nil
        }
    }
}
