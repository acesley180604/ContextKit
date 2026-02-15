# Integration Examples

Complete code examples for SwiftUI and UIKit apps.

---

## Table of Contents

- [SwiftUI Integration](#swiftui-integration)
- [UIKit Integration](#uikit-integration)
- [Common Patterns](#common-patterns)
- [Advanced Usage](#advanced-usage)

---

## SwiftUI Integration

### Basic Setup

```swift
import SwiftUI
import ContextKit

@main
struct MyApp: App {
    init() {
        // Configure ContextKit on app launch
        ContextKit.configure(apiKey: "ck_live_YOUR_KEY")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Track Screen Views

```swift
import SwiftUI
import ContextKit

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home Screen")
            NavigationLink("Go to Details", destination: DetailsView())
        }
        .onAppear {
            // Track screen view when view appears
            ContextKit.trackScreen("home")
        }
    }
}

struct DetailsView: View {
    var body: some View {
        VStack {
            Text("Details Screen")
        }
        .onAppear {
            ContextKit.trackScreen("details")
        }
    }
}
```

### Track User Actions

```swift
struct PaywallView: View {
    @State private var selectedPlan = "annual"

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Plan")
                .font(.largeTitle)

            // Plan selection
            Picker("Plan", selection: $selectedPlan) {
                Text("Monthly").tag("monthly")
                Text("Annual").tag("annual")
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedPlan) { oldValue, newValue in
                // Track plan selection
                ContextKit.track("plan_selected", properties: [
                    "plan": newValue,
                    "previous_plan": oldValue
                ])
            }

            // Purchase button
            Button("Subscribe") {
                handlePurchase()
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            // Track paywall view
            ContextKit.trackScreen("paywall")
            ContextKit.track("paywall_viewed", properties: [
                "default_plan": selectedPlan
            ])
        }
    }

    func handlePurchase() {
        // Track purchase attempt
        ContextKit.track("purchase_initiated", properties: [
            "plan": selectedPlan
        ])

        // Simulate purchase
        Task {
            let success = await performPurchase(plan: selectedPlan)

            if success {
                ContextKit.track("purchase_completed", properties: [
                    "plan": selectedPlan,
                    "price": selectedPlan == "annual" ? 49.99 : 9.99,
                    "revenue": selectedPlan == "annual" ? 49.99 : 9.99,
                    "currency": "USD"
                ])

                // Update user segment
                ContextKit.setUserSegment("premium")
            } else {
                ContextKit.track("purchase_failed", properties: [
                    "plan": selectedPlan,
                    "error": "payment_declined"
                ])
            }
        }
    }

    func performPurchase(plan: String) async -> Bool {
        // Your purchase logic here
        return true
    }
}
```

### Track Onboarding Funnel

```swift
struct OnboardingFlow: View {
    @State private var currentStep = 1

    var body: some View {
        TabView(selection: $currentStep) {
            OnboardingStep1()
                .tag(1)
                .onAppear {
                    ContextKit.trackScreen("onboarding_step_1")
                }

            OnboardingStep2()
                .tag(2)
                .onAppear {
                    ContextKit.trackScreen("onboarding_step_2")
                }

            OnboardingStep3()
                .tag(3)
                .onAppear {
                    ContextKit.trackScreen("onboarding_step_3")
                }
        }
        .tabViewStyle(.page)
        .onAppear {
            ContextKit.track("onboarding_started")
        }
    }
}

struct OnboardingStep1: View {
    var body: some View {
        VStack {
            Text("Welcome!")
            Button("Next") {
                ContextKit.track("onboarding_step_1_completed")
            }
        }
    }
}
```

### Track Search

```swift
struct SearchView: View {
    @State private var searchQuery = ""
    @State private var searchResults: [String] = []

    var body: some View {
        VStack {
            TextField("Search...", text: $searchQuery)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    performSearch()
                }

            List(searchResults, id: \.self) { result in
                Text(result)
                    .onTapGesture {
                        // Track result selection
                        ContextKit.track("search_result_selected", properties: [
                            "query": searchQuery,
                            "result": result,
                            "position": searchResults.firstIndex(of: result) ?? 0
                        ])
                    }
            }
        }
        .onAppear {
            ContextKit.trackScreen("search")
        }
    }

    func performSearch() {
        // Track search
        ContextKit.track("search_performed", properties: [
            "query": searchQuery,
            "query_length": searchQuery.count
        ])

        // Your search logic
        searchResults = ["Result 1", "Result 2", "Result 3"]

        // Track results
        ContextKit.track("search_results", properties: [
            "query": searchQuery,
            "result_count": searchResults.count
        ])
    }
}
```

### Track Feature Usage

```swift
struct MainView: View {
    var body: some View {
        VStack {
            Button("Export Data") {
                exportData()
            }

            Button("Share") {
                shareContent()
            }

            Button("Print") {
                printDocument()
            }
        }
    }

    func exportData() {
        ContextKit.track("feature_used", properties: [
            "feature": "export",
            "format": "csv"
        ])

        // Your export logic
    }

    func shareContent() {
        ContextKit.track("feature_used", properties: [
            "feature": "share",
            "method": "activity_sheet"
        ])

        // Your share logic
    }

    func printDocument() {
        ContextKit.track("feature_used", properties: [
            "feature": "print"
        ])

        // Your print logic
    }
}
```

---

## UIKit Integration

### Basic Setup

```swift
import UIKit
import ContextKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure ContextKit
        ContextKit.configure(apiKey: "ck_live_YOUR_KEY")

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Flush events when app goes to background
        ContextKit.flush()
    }
}
```

### Track Screen Views

```swift
import UIKit
import ContextKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Track screen view
        ContextKit.trackScreen("home")
    }

    func setupUI() {
        // Your UI setup
    }
}
```

### Track User Actions

```swift
class PaywallViewController: UIViewController {

    @IBOutlet weak var monthlyButton: UIButton!
    @IBOutlet weak var annualButton: UIButton!

    private var selectedPlan: String = "annual"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Track paywall view
        ContextKit.trackScreen("paywall")
        ContextKit.track("paywall_viewed", properties: [
            "default_plan": selectedPlan
        ])
    }

    func setupButtons() {
        monthlyButton.addTarget(self, action: #selector(selectMonthly), for: .touchUpInside)
        annualButton.addTarget(self, action: #selector(selectAnnual), for: .touchUpInside)
    }

    @objc func selectMonthly() {
        selectedPlan = "monthly"

        ContextKit.track("plan_selected", properties: [
            "plan": "monthly"
        ])
    }

    @objc func selectAnnual() {
        selectedPlan = "annual"

        ContextKit.track("plan_selected", properties: [
            "plan": "annual"
        ])
    }

    @IBAction func purchaseButtonTapped(_ sender: UIButton) {
        // Track purchase attempt
        ContextKit.track("purchase_initiated", properties: [
            "plan": selectedPlan
        ])

        performPurchase()
    }

    func performPurchase() {
        // Your purchase logic

        // On success:
        ContextKit.track("purchase_completed", properties: [
            "plan": selectedPlan,
            "price": selectedPlan == "annual" ? 49.99 : 9.99,
            "revenue": selectedPlan == "annual" ? 49.99 : 9.99,
            "currency": "USD"
        ])

        ContextKit.setUserSegment("premium")
    }
}
```

### Track Navigation

```swift
class NavigationCoordinator: NSObject, UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        // Auto-track screen views based on view controller
        let screenName = String(describing: type(of: viewController))
            .replacingOccurrences(of: "ViewController", with: "")
            .lowercased()

        ContextKit.trackScreen(screenName)
    }
}

// In your AppDelegate or SceneDelegate:
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var navigationCoordinator: NavigationCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let rootVC = HomeViewController()
        let navController = UINavigationController(rootViewController: rootVC)

        // Setup navigation tracking
        navigationCoordinator = NavigationCoordinator()
        navController.delegate = navigationCoordinator

        window.rootViewController = navController
        self.window = window
        window.makeKeyAndVisible()
    }
}
```

### Track Table View Interactions

```swift
class ProductListViewController: UITableViewController {

    var products: [Product] = []

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ContextKit.trackScreen("product_list")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]

        // Track product selection
        ContextKit.track("product_selected", properties: [
            "product_id": product.id,
            "product_name": product.name,
            "position": indexPath.row,
            "category": product.category
        ])

        // Navigate to detail
        let detailVC = ProductDetailViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
```

---

## Common Patterns

### Track User Authentication

```swift
class AuthManager {
    static let shared = AuthManager()

    func signUp(email: String, password: String) async throws {
        // Track signup attempt
        ContextKit.track("signup_initiated", properties: [
            "method": "email"
        ])

        do {
            let user = try await performSignUp(email: email, password: password)

            // Track successful signup
            ContextKit.identify(user.id)
            ContextKit.setUser(properties: [
                "email": email,
                "signup_source": "organic",
                "signup_date": ISO8601DateFormatter().string(from: Date())
            ])
            ContextKit.setUserSegment("free")

            ContextKit.track("signup_completed", properties: [
                "method": "email"
            ])

        } catch {
            // Track signup failure
            ContextKit.track("signup_failed", properties: [
                "method": "email",
                "error": error.localizedDescription
            ])

            throw error
        }
    }

    func login(email: String, password: String) async throws {
        ContextKit.track("login_initiated", properties: [
            "method": "email"
        ])

        let user = try await performLogin(email: email, password: password)

        ContextKit.identify(user.id)
        ContextKit.track("login_completed", properties: [
            "method": "email"
        ])
    }

    func performSignUp(email: String, password: String) async throws -> User {
        // Your signup logic
        return User(id: "user_123")
    }

    func performLogin(email: String, password: String) async throws -> User {
        // Your login logic
        return User(id: "user_123")
    }
}

struct User {
    let id: String
}
```

### Track App Lifecycle

```swift
import UIKit
import ContextKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var appLaunchTime: Date?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure ContextKit
        ContextKit.configure(apiKey: "ck_live_YOUR_KEY")

        // Track app launch
        appLaunchTime = Date()
        ContextKit.track("app_launched")

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Track app open
        ContextKit.track("app_opened")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Track app close
        if let launchTime = appLaunchTime {
            let sessionDuration = Date().timeIntervalSince(launchTime)
            ContextKit.track("app_closed", properties: [
                "session_duration": sessionDuration
            ])
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Flush events
        ContextKit.flush()
    }
}
```

### Track Errors

```swift
func performNetworkRequest() async {
    ContextKit.track("api_request_started", properties: [
        "endpoint": "/api/users"
    ])

    do {
        let result = try await fetchData()

        ContextKit.track("api_request_completed", properties: [
            "endpoint": "/api/users",
            "duration": 1.5,
            "status": "success"
        ])

    } catch {
        ContextKit.track("api_request_failed", properties: [
            "endpoint": "/api/users",
            "error": error.localizedDescription,
            "error_code": (error as NSError).code
        ])
    }
}

func fetchData() async throws -> Data {
    // Your network logic
    return Data()
}
```

### Track A/B Tests

```swift
class ABTestManager {
    static let shared = ABTestManager()

    func getUserVariant() -> String {
        // Your A/B test logic
        let variants = ["control", "variant_a", "variant_b"]
        let variant = variants.randomElement() ?? "control"

        // Track variant assignment
        ContextKit.track("ab_test_assigned", properties: [
            "test_name": "paywall_redesign",
            "variant": variant
        ])

        return variant
    }
}

// In your paywall view:
struct PaywallView: View {
    let variant = ABTestManager.shared.getUserVariant()

    var body: some View {
        if variant == "control" {
            // Original paywall
        } else {
            // New paywall variant
        }
    }
}
```

---

## Advanced Usage

### Custom Event Wrapper

```swift
import ContextKit

class Analytics {
    static let shared = Analytics()

    private init() {}

    func configure() {
        ContextKit.configure(apiKey: "ck_live_YOUR_KEY")
    }

    // Typed event tracking
    enum Event {
        case appOpened
        case paywallViewed(plan: String)
        case purchaseCompleted(plan: String, price: Double)
        case featureUsed(feature: String)

        var name: String {
            switch self {
            case .appOpened: return "app_opened"
            case .paywallViewed: return "paywall_viewed"
            case .purchaseCompleted: return "purchase_completed"
            case .featureUsed: return "feature_used"
            }
        }

        var properties: [String: Any] {
            switch self {
            case .appOpened:
                return [:]
            case .paywallViewed(let plan):
                return ["plan": plan]
            case .purchaseCompleted(let plan, let price):
                return ["plan": plan, "price": price, "revenue": price]
            case .featureUsed(let feature):
                return ["feature": feature]
            }
        }
    }

    func track(_ event: Event) {
        ContextKit.track(event.name, properties: event.properties)
    }

    func trackScreen(_ screen: String) {
        ContextKit.trackScreen(screen)
    }
}

// Usage:
Analytics.shared.track(.paywallViewed(plan: "annual"))
Analytics.shared.track(.purchaseCompleted(plan: "annual", price: 49.99))
```

### Debug Mode Integration

```swift
import ContextKit

@main
struct MyApp: App {
    init() {
        #if DEBUG
        let config = ContextKitConfig(
            apiKey: "ck_test_development_12345",
            debugMode: true  // Enable debug overlay in development
        )
        ContextKit.configure(apiKey: "ck_test_development_12345", config: config)
        #else
        ContextKit.configure(apiKey: "ck_live_production_key")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

## Best Practices

### 1. Track Screen Views Consistently

✅ **Good:**
```swift
// Every screen tracks on appear
.onAppear {
    ContextKit.trackScreen("home")
}
```

❌ **Bad:**
```swift
// Inconsistent tracking
// Some screens tracked, others not
```

### 2. Use Meaningful Event Names

✅ **Good:**
```swift
ContextKit.track("purchase_completed")
ContextKit.track("paywall_viewed")
```

❌ **Bad:**
```swift
ContextKit.track("button_click")
ContextKit.track("event_1")
```

### 3. Include Relevant Properties

✅ **Good:**
```swift
ContextKit.track("search_performed", properties: [
    "query": searchText,
    "result_count": results.count,
    "filter": selectedFilter
])
```

❌ **Bad:**
```swift
ContextKit.track("search_performed")
// Missing useful context
```

### 4. Don't Track PII

✅ **Good:**
```swift
ContextKit.identify("user_\(hashedId)")
```

❌ **Bad:**
```swift
ContextKit.track("signup", properties: [
    "email": "user@example.com",  // PII!
    "phone": "+1-555-0123"        // PII!
])
```

---

## More Resources

- **API Reference:** [API_REFERENCE.md](API_REFERENCE.md)
- **Migration Guide:** [MIGRATION_FROM_MIXPANEL.md](MIGRATION_FROM_MIXPANEL.md)
- **Best Practices:** [BEST_PRACTICES.md](BEST_PRACTICES.md)
- **Troubleshooting:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

**Need more examples?** Open an issue: https://github.com/acesley180604/ContextKit/issues
