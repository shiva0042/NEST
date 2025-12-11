# NEST - Near Easy Shop Tracker
## Complete Project Summary for Documentation

---

## PROJECT OVERVIEW

**Project Name:** NEST (Near Easy Shop Tracker)
**Version:** 1.0.0
**Platform:** Cross-platform Mobile Application (Android, iOS, Web)
**Framework:** Flutter
**Language:** Dart
**Project Type:** E-commerce / Grocery Discovery & Shopping Application

---

## PROBLEM STATEMENT

Traditional grocery shopping faces multiple challenges:
- Customers cannot easily discover nearby grocery stores
- No real-time visibility of product availability in local shops
- Shop owners lack digital tools to manage inventory and billing
- Difficult to compare prices and products across nearby stores
- No centralized platform connecting local grocery stores with customers

---

## PROPOSED SOLUTION

NEST is a comprehensive e-market platform similar to Blinkit/JioMart that:
- Helps customers discover nearby grocery stores on an interactive map
- Enables shop owners to digitally manage inventory, billing, and analytics
- Provides a centralized product catalog with 1000+ grocery items
- Offers real-time product availability and pricing information
- Facilitates seamless shopping experience with cart and billing features

---

## PROJECT OBJECTIVES

1. Create a dual-role system (Customer + Shop Owner)
2. Implement location-based shop discovery using maps
3. Develop comprehensive product catalog management
4. Enable digital inventory management for shop owners
5. Provide billing and sales analytics features
6. Create an intuitive, user-friendly mobile interface
7. Support offline-first architecture with local data storage

---

## TECH STACK

### Frontend Framework
- **Flutter 3.0+** - Cross-platform UI framework
- **Dart** - Programming language

### State Management
- **Provider 6.0.0** - State management solution

### Key Dependencies
- `flutter` - Core Flutter SDK
- `provider: ^6.0.0` - State management
- `cupertino_icons: ^1.0.2` - iOS-style icons
- `url_launcher: ^6.1.11` - URL handling
- `flutter_launcher_icons: ^0.13.1` - App icon generation

### Development Tools
- **Android Studio / VS Code** - IDE
- **Flutter DevTools** - Debugging and profiling

---

## SYSTEM ARCHITECTURE

### Application Type
- **Architecture Pattern:** MVVM (Model-View-ViewModel)
- **State Management:** Provider Pattern
- **Data Storage:** Local in-memory storage with Provider
- **Navigation:** Flutter Navigator 2.0

### Project Structure
```
lib/
├── main.dart                           # App entry point
├── core/
│   ├── theme/
│   │   └── app_theme.dart             # App-wide theming
│   ├── providers/
│   │   ├── store_provider.dart        # Shop/store state management
│   │   ├── cart_provider.dart         # Shopping cart management
│   │   └── sales_provider.dart        # Sales analytics management
│   ├── models/
│   │   └── shop_models.dart           # Data models for shop entities
│   └── services/                      # Service layer (Firebase removed)
│
├── features/
│   ├── auth/                          # Authentication Module
│   │   ├── screens/
│   │   │   ├── role_selection_screen.dart
│   │   │   ├── shop_login_screen.dart
│   │   │   └── shop_signup_screen.dart
│   │   └── models/
│   │
│   ├── map_discovery/                 # Customer Shopping Module
│   │   ├── screens/
│   │   │   ├── home_screen.dart       # Main landing page
│   │   │   ├── stores_list_screen.dart
│   │   │   ├── search_screen.dart
│   │   │   ├── cart_screen.dart
│   │   │   └── offers_screen.dart
│   │   └── models/
│   │       ├── shop_model.dart
│   │       └── product_model.dart
│   │
│   ├── shop_dashboard/                # Shop Owner Module
│   │   ├── screens/
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── inventory_screen.dart
│   │   │   ├── billing_screen.dart
│   │   │   ├── analytics_screen.dart
│   │   │   └── add_product_catalog_screen.dart
│   │   └── widgets/
│   │
│   └── product_onboarding/            # Product Catalog Module
│       ├── screens/
│       │   ├── product_onboarding_screen.dart
│       │   └── custom_product_screen.dart
│       ├── services/
│       │   └── catalog_service.dart
│       └── models/
│           └── models.dart
│
├── shared/                            # Shared components
│   └── widgets/
│
└── assets/
    ├── images/                        # App images and icons
    └── data/
        └── consolidated_products.json # 1000+ product catalog
```

---

## MODULES & FEATURES

### 1. AUTHENTICATION MODULE
**Screens:**
- Role Selection Screen
- Shop Login Screen  
- Shop Signup Screen

**Features:**
- Dual-role selection (Customer/Shop Owner)
- Phone-based authentication for shop owners
- Shop registration with business details
- Password-protected login
- Session management

---

### 2. CUSTOMER MODULE (Map Discovery)

#### 2.1 Home Screen
- Interactive map showing nearby grocery stores
- Store cards with distance, rating, and status
- Quick access to cart and search
- Category browsing

#### 2.2 Store List Screen
- List view of all nearby stores
- Filter by distance, rating, open/closed
- Quick navigation to store details

#### 2.3 Search Screen
- Search products across all stores
- Auto-suggest from catalog
- Filter by category, brand, price

#### 2.4 Cart Screen
- Add/remove products
- Quantity management
- Total price calculation
- Checkout functionality

#### 2.5 Offers Screen
- View ongoing offers and discounts
- Featured products
- Promotional banners

**Key Features:**
- 🗺️ Google Maps integration for shop discovery
- 📍 Location-based search with distance calculation
- 🏪 Detailed shop information (address, hours, rating)
- 🛒 Shopping cart with persistent storage
- 🔍 Real-time product search across stores

---

### 3. SHOP OWNER MODULE (Dashboard)

#### 3.1 Dashboard Screen
**Components:**
- Sales overview cards
- Quick stats (daily sales, orders, items sold)
- Recent transactions list
- Shop status toggle (Open/Closed)
- Navigation to all features

#### 3.2 Inventory Management Screen
**Features:**
- Product listing with stock levels
- Add/Edit/Delete products
- Stock quantity tracking
- Low stock alerts
- Product categorization
- Image management
- Price updates

#### 3.3 Billing Screen
**Features:**
- Create new bills/invoices
- Barcode scanning integration
- Product search and selection
- Quantity input
- Automatic total calculation
- Tax calculation
- Bill history
- Print/Share invoice

#### 3.4 Analytics Screen
**Metrics:**
- Sales trends (Daily/Weekly/Monthly/Yearly)
- Revenue charts and graphs
- Top-selling products
- Customer analytics
- Date range filters (custom date selection)
- Category-wise sales breakdown

**Charts:**
- Line charts for sales trends
- Bar charts for product comparison
- Pie charts for category distribution

#### 3.5 Add Product Catalog Screen
**Features:**
- Wizard-based product addition
- Multi-step process:
  - Step 1: Category selection
  - Step 2: Subcategory selection
  - Step 3: Product type selection
  - Step 4: Brand selection
  - Step 5: Variant/Size selection
  - Step 6: Price and stock input
- Auto-suggest from master catalog
- Custom product creation
- Bulk product import (future)

---

### 4. PRODUCT ONBOARDING MODULE

#### 4.1 Catalog Service
**Master Catalog:**
- 1000+ pre-loaded grocery products
- Structured JSON database
- Categories: Biscuits, Snacks, Dairy, Beverages, Staples, Personal Care, etc.
- Multiple brands per category
- Size variants for each product
- Auto-generated product images

**Structure:**
```
Category → Subcategory → Product Type → Brand → Variant → Size
```

**Key Functionality:**
- Dynamic category loading from JSON
- Brand filtering by category
- Size parsing and standardization
- Image URL generation
- Search with auto-suggestion
- Product duplication prevention

#### 4.2 Product Onboarding Screen
- Step-by-step wizard interface
- Real-time validation
- Progress indicator
- Back/Next navigation
- Final confirmation screen

#### 4.3 Custom Product Screen
- Manual product entry
- Image upload/selection
- Custom pricing
- Category assignment
- Barcode linking

---

## DATA MODELS

### Shop Model
```dart
{
  id: String,
  name: String,
  address: String,
  phoneNumber: String,
  password: String,
  category: String,
  distance: double,
  rating: double,
  isOpen: bool,
  imageUrl: String
}
```

### Product Model
```dart
{
  id: String,
  category: String,
  subcategory: String,
  productType: String,
  brand: String,
  variant: String,
  canonicalSize: String,
  sizeValue: double,
  sizeUnit: String,
  canonicalName: String,
  tags: List<String>,
  imageUrl: String
}
```

### Inventory Item Model
```dart
{
  productId: String,
  productName: String,
  brand: String,
  category: String,
  variant: String,
  price: double,
  stockQty: int,
  imageUrl: String,
  source: String,
  status: String
}
```

### Shopping Cart Item
```dart
{
  productId: String,
  name: String,
  price: double,
  quantity: int,
  imageUrl: String,
  shopId: String
}
```

### Bill/Transaction Model
```dart
{
  id: String,
  shopId: String,
  items: List<CartItem>,
  subtotal: double,
  tax: double,
  total: double,
  timestamp: DateTime,
  paymentMethod: String
}
```

---

## STATE MANAGEMENT (PROVIDERS)

### 1. StoreProvider
**Responsibilities:**
- Manage shop list and data
- Handle user authentication
- Track current logged-in shop
- Shop registration and login
- Toggle shop open/closed status

**Key Methods:**
- `setUserRole(String role)`
- `loginShopOwner(String phone, String password)`
- `registerShop(String name, phone, password, address)`
- `toggleShopStatus(String shopId)`
- `logout()`

### 2. CartProvider
**Responsibilities:**
- Shopping cart management
- Add/remove items to cart
- Update quantities
- Calculate totals
- Clear cart

**Key Methods:**
- `addToCart(Product product, String shopId)`
- `removeFromCart(String productId)`
- `updateQuantity(String productId, int quantity)`
- `clearCart()`
- `getTotalAmount()`
- `getItemCount()`

### 3. SalesProvider
**Responsibilities:**
- Track sales and transactions
- Sales analytics computation
- Filter by date ranges
- Generate reports

**Key Methods:**
- `addTransaction(Bill bill)`
- `getTransactionsByDateRange(DateTime start, DateTime end)`
- `getTotalSales(String period)` // daily, weekly, monthly, yearly
- `getTopProducts(int limit)`
- `getSalesByCategory()`

---

## KEY ALGORITHMS & LOGIC

### 1. Distance Calculation
- Haversine formula for calculating distance between two GPS coordinates
- Sort shops by proximity to user location

### 2. Product Search Algorithm
- Multi-field search (name, brand, category, tags)
- Fuzzy matching for auto-suggest
- Result ranking by relevance

### 3. Inventory Management
- Stock level tracking
- Low stock alerts (when quantity < threshold)
- Automatic stock decrement on sales

### 4. Sales Analytics
- Time-series data aggregation
- Date range filtering (daily, weekly, monthly, yearly, custom)
- Revenue calculations with tax
- Top products identification (sort by quantity sold)

### 5. Catalog Service Logic
- JSON parsing and caching
- Hierarchical data navigation (Category → Type → Brand → Size)
- Product variant generation
- Image URL generation using Bing Image Search API

---

## USER WORKFLOWS

### Customer Journey:
1. Launch app → Select "Customer" role
2. View map with nearby shops
3. Select a shop → Browse products
4. Add products to cart
5. View cart → Proceed to checkout
6. Place order (future: payment integration)

### Shop Owner Journey:
1. Launch app → Select "Shop Owner" role
2. Login/Register with phone and password
3. Access Dashboard → View sales overview
4. Manage Inventory:
   - Add products from catalog
   - Update stock and prices
   - Monitor low stock items
5. Process sales through Billing screen
6. View Analytics for business insights
7. Toggle shop status (Open/Closed)

---

## PLATFORM SUPPORT

### Android
- Minimum SDK: 21 (Android 5.0 Lollipop)
- Target SDK: 34 (Android 14)
- Build output: APK (25MB)

### iOS
- Minimum version: iOS 12.0
- Build output: IPA

### Web
- Responsive web app
- Progressive Web App (PWA) capable

### Windows/Linux/macOS
- Desktop support available (experimental)

---

## HARDWARE & SOFTWARE REQUIREMENTS

### Development Environment
**Hardware:**
- Processor: Intel i5 or higher / AMD Ryzen 5
- RAM: 8GB minimum (16GB recommended)
- Storage: 10GB free space
- Internet: Required for dependencies

**Software:**
- OS: Windows 10/11, macOS 10.14+, Linux (Ubuntu 18.04+)
- Flutter SDK: 3.0.0 or higher
- Dart SDK: 3.0.0 or higher
- Android Studio / VS Code
- Git for version control

### End User (Mobile)
**Hardware:**
- Android device (Android 5.0+) or iOS device (iOS 12+)
- RAM: 2GB minimum
- Storage: 100MB free space
- GPS enabled
- Camera (for barcode scanning - optional)

**Software:**
- Android OS 5.0+ or iOS 12+
- Internet connection (Wi-Fi or mobile data)
- Location services enabled

---

## ADVANTAGES OF PROPOSED SYSTEM

### For Customers:
1. ✅ Discover nearby shops instantly with GPS integration
2. ✅ View real-time product availability
3. ✅ Compare prices across multiple shops
4. ✅ Save time with digital shopping list
5. ✅ No need to visit multiple stores

### For Shop Owners:
1. ✅ Digital inventory management
2. ✅ Automated billing system
3. ✅ Sales analytics and insights
4. ✅ Increased online visibility
5. ✅ Reduced manual paperwork
6. ✅ Better stock management
7. ✅ Customer reach expansion

### Overall:
1. ✅ Bridges digital divide for local grocery stores
2. ✅ Supports small businesses digitally
3. ✅ No heavy infrastructure required
4. ✅ Works offline (local storage)
5. ✅ Cross-platform compatibility
6. ✅ Scalable architecture

---

## TESTING PERFORMED

### Unit Testing
- Provider state management tests
- Model serialization/deserialization tests
- Utility function tests (distance calculation, date formatting)

### Integration Testing
- Navigation flow testing
- Provider integration with UI
- Cart operations with inventory updates

### Manual Testing
- Authentication flows (login, signup)
- Product addition to inventory
- Billing process
- Analytics date filtering
- Cart operations

### Test Scenarios
| Module | Test Case | Expected Result | Status |
|--------|-----------|-----------------|--------|
| Auth | Shop Login with correct credentials | Navigate to Dashboard | ✅ Pass |
| Auth | Shop Login with incorrect credentials | Show error message | ✅ Pass |
| Cart | Add product to cart | Cart count increases | ✅ Pass |
| Cart | Remove product from cart | Cart count decreases | ✅ Pass |
| Billing | Calculate total with tax | Correct total displayed | ✅ Pass |
| Inventory | Update stock quantity | Stock updated in UI | ✅ Pass |
| Analytics | Filter by date range | Show filtered transactions | ✅ Pass |

---

## CURRENT LIMITATIONS

1. No real backend integration (using local storage)
2. No payment gateway integration
3. No real-time sync between devices
4. Map features require internet
5. Single device operation (no multi-device sync)
6. Limited to mock data for shops

---

## FUTURE ENHANCEMENTS

### Phase 2 - Backend Integration
1. Real backend with Firebase/REST API
2. Cloud Firestore for real-time data sync
3. User authentication with OTP
4. Multi-device sync

### Phase 3 - Advanced Features
1. Payment gateway integration (Razorpay, Stripe)
2. Order management system
3. Delivery tracking
4. Push notifications
5. In-app chat between customer and shop owner
6. QR code-based billing

### Phase 4 - AI & ML Features
1. Personalized product recommendations
2. Demand forecasting for inventory
3. Price optimization suggestions
4. Customer behavior analytics

### Phase 5 - Business Expansion
1. Multi-language support (Tamil, Hindi, etc.)
2. Subscription plans for shop owners
3. Advertisement platform
4. Loyalty programs and rewards
5. B2B wholesale ordering

---

## INSTALLATION & DEPLOYMENT

### For Development:
```bash
# Clone repository
git clone https://github.com/username/nest.git
cd nest

# Install dependencies
flutter pub get

# Run on connected device
flutter run
```

### Building APK:
```bash
# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Building for iOS:
```bash
flutter build ios --release
```

### Building for Web:
```bash
flutter build web --release
```

---

## SCREENSHOTS DESCRIPTION

The app includes the following screens (to be captured):
1. **Role Selection Screen** - Choose Customer or Shop Owner
2. **Shop Login Screen** - Phone and password login
3. **Customer Home Screen** - Map with nearby shops
4. **Shop Details** - Products and shop information
5. **Shopping Cart** - Cart items and checkout
6. **Shop Dashboard** - Sales overview and quick stats
7. **Inventory Management** - Product list with stock
8. **Billing Screen** - Create invoice/bill
9. **Analytics Screen** - Sales charts and graphs
10. **Product Onboarding Wizard** - Step-by-step product addition

---

## CONCLUSION

NEST successfully creates a comprehensive e-market platform connecting local grocery stores with customers through a modern, user-friendly mobile application. The system addresses real-world problems of grocery discovery and shop management through digital innovation.

**Key Achievements:**
- ✅ Dual-role system implemented
- ✅ 1000+ product catalog integrated
- ✅ Complete shop management dashboard
- ✅ Analytics and reporting features
- ✅ Cross-platform mobile application
- ✅ Clean, maintainable code architecture

The project demonstrates proficiency in:
- Mobile app development with Flutter
- State management patterns
- UI/UX design principles
- Data modeling and architecture
- Problem-solving and system design

---

## REFERENCES & RESOURCES

### Official Documentation:
1. Flutter Official Documentation - https://flutter.dev/docs
2. Dart Language Tour - https://dart.dev/guides/language/language-tour
3. Provider Package - https://pub.dev/packages/provider

### Inspiration:
1. Blinkit (formerly Grofers) - Instant grocery delivery
2. JioMart - Online grocery shopping
3. Zepto - Quick commerce platform
4. Swiggy Instamart - Grocery delivery

### Technical Resources:
1. Flutter Community - https://flutter.dev/community
2. Pub.dev - Flutter packages repository
3. Stack Overflow - Developer Q&A
4. GitHub - Code repositories and examples

### Design Resources:
1. Material Design Guidelines - https://material.io/design
2. Human Interface Guidelines (iOS) - https://developer.apple.com
3. Unsplash - Free stock images
4. Bing Image Search API - Dynamic product images

---

## PROJECT STATISTICS

- **Total Screens:** 15+
- **Total Dart Files:** 50+
- **Lines of Code:** ~5000+
- **Product Catalog Size:** 1000+ items
- **Categories:** 20+
- **Brands:** 100+
- **Development Time:** 4-6 weeks
- **Team Size:** 1-2 developers
- **APK Size:** ~25MB

---

## CONTACT & SUPPORT

**GitHub Repository:** https://github.com/shiva0042/NEST
**License:** MIT License
**Version:** 1.0.0
**Last Updated:** December 2025

---

**END OF PROJECT SUMMARY**
