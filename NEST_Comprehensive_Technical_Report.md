# NEST (Near Easy Shop Tracker) - Comprehensive Technical Report

## 1. ABSTRACT
The retail landscape is currently divided between large-scale quick-commerce giants (like Blinkit, Zepto) and traditional unorganized local retailers ("Kirana" stores). While the former relies on massive infrastructure, local shops struggle with visibility and operational inefficiency. **NEST** is a cross-platform mobile application designed to bridge this gap. It provides a **Hyperlocal Marketplace** where:
1.  **Shop Owners** can digitize their inventory, generate bills, and view analytics without expensive hardware.
2.  **Customers** can discover nearby shops, search for specific products across multiple stores, and place orders.

This project democratizes e-commerce technology, offering a robust, offline-first solution that empowers small businesses to compete in the digital age.

---

## 2. SYSTEM ARCHITECTURE

The application follows a **Modular MVVM (Model-View-ViewModel)** architecture, ensuring separation of concerns and scalability.

### A. High-Level Data Flow
1.  **View Layer (UI):** Flutter Widgets (Screens like Maps, Dashboard) that observe changes.
2.  **ViewModel Layer (Providers):** `StoreProvider`, `CartProvider`, and `SalesProvider` act as the "Brain". They hold the state and business logic.
3.  **Service Layer:** Dedicated classes for complex logic (`LocationService`, `BillingCalculator`, `SearchEngine`).
4.  **Data Layer:**
    *   **Local:** `SharedPreferences` for session/settings validity.
    *   **Remote:** `Firebase Firestore` for persistent data storage.

### B. Offline-First Design
Given the target demographic (local shops with spotty internet), the architecture prioritizes local execution:
*   **Billing & Inventory:** Runs entirely in-memory for zero-latency.
*   **Sync Logic:** Data is written locally first, then synced to Cloud Firestore in the background when connectivity is available.

---

## 3. FRONTEND TECHNOLOGIES

The frontend is built to deliver a native experience on both Android and iOS from a single codebase.

*   **Framework:** **Flutter 3.x**
*   **Language:** **Dart 3.x** (Null Safety enabled)
*   **Key Dependencies:**
    *   `provider`: For efficient state management (avoiding unnecessary rebuilds).
    *   `google_maps_flutter`: For rendering the interactive discovery map.
    *   `fl_chart`: For rendering high-performance sales graphs (Bar/Line charts).
    *   `cached_network_image`: For efficient image loading and caching.
    *   `geolocator`: To access device GPS hardware.

---

## 4. BACKEND TECHNOLOGIES

The backend connects the diverse user base into a single cohesive system.

*   **Cloud Database:** **Google Firebase Firestore** (NoSQL).
    *   *Why?* flexible schema allows for products to have varying attributes (Size/Color/Brand) without strict table joins.
*   **Local Persistence:** **Shared Preferences** is used to store lightweight data like "User Role" (Customer vs. Owner) and "Login State", enabling instant app launch without waiting for a server response.

---

## 5. KEY ALGORITHMS & LOGIC

The application intelligence relies on several core algorithms:

### A. Geospatial Sorting (Haversine Formula)
Used to rank shops by proximity to the customer.
*   **Input:** User GPS (Lat1, Lon1), Shop GPS (Lat2, Lon2).
*   **Logic:** Calculates the great-circle distance on a sphere.
    ```
    a = sin²(Δlat/2) + cos(lat1) * cos(lat2) * sin²(Δlon/2)
    c = 2 * atan2(√a, √(1-a))
    d = Radius * c
    ```
*   **Output:** Sorted list of Shop Objects from nearest to farthest.

### B. Fuzzy Product Search (Levenshtein Distance)
Allows customers to find items even with spelling mistakes.
*   **Logic:** Calculates the minimum number of single-character edits (insertions, deletions, substitutions) required to change the user's query into the product name.
*   **Example:** User types "Biskt" -> Algorithm matches "Biscuit" (Distance: 2).

### C. Atomic Inventory Reconciliation
Ensures stock counts are always accurate during billing.
*   **Process:**
    1.  User creates a Bill with items [A (Qty: 2), B (Qty: 1)].
    2.  User clicks "Confirm".
    3.  **Critical Section:** The system locks the inventory state.
    4.  Decrements Item A by 2, Item B by 1.
    5.  Checks for `Negative Stock` (Validation).
    6.  Commits Transaction -> Generates Bill ID -> Updates Sales Analytics.

### D. Time-Series Aggregation
Used for generating Analytics Reports.
*   **Logic:**
    1.  Fetch all transactions.
    2.  Filter by Date Range (Start Date, End Date).
    3.  Bucket transactions by Day/Week.
    4.  Sum(Total Amount) per bucket.
*   **Output:** Data points compatible with Line Charts [Day 1: $500, Day 2: $700...].

---

## 6. FUTURE ENHANCEMENTS

To scale NEST into a commercial SaaS product:

1.  **Multi-Device Cloud Sync:**
    *   Currently, data is heavily local. Moving to a "Real-time Stream" architecture would allow a Shop Owner to see sales on their phone while a staff member bills on a tablet.
2.  **Fintech Integration:**
    *   Integrate **UPI (Unified Payments Interface)** and Payment Gateways (Razorpay/Stripe) to allow customers to pay directly in-app.
    *   Add a "Khata" (Credit) management system for loyal customers.
3.  **AI-Driven Smart Stocking:**
    *   Use Machine Learning to analyze past sales data and predict "Stock Outs".
    *   *Example:* "You usually sell 50 packets of Milk on Sundays. You currently have 10. Restock advised."
4.  **Hyperlocal Delivery:**
    *   Partner with 3rd-party logistics APIs (Dunzo, Uber Direct) to offer tracked home delivery within 30 minutes.

---

## 7. CONCLUSION
NEST successfully demonstrates that sophisticated retail technology can be accessible to the smallest of businesses. By combining a clean, modular architecture with robust algorithms for discovery and management, the app solves real-world pain points. It is a production-ready foundation capable of transforming the unorganized retail sector into a digitally connected ecosystem.
