# NEST - Near Easy Shop Tracker

A Flutter-based grocery discovery and shopping application that helps users find nearby grocery stores and manage their shopping experience.

## 📥 Download APK

**[Download NEST APK](https://github.com/shiva0042/NEST/raw/main/NEST.apk)**

Get the latest version of the app and install it directly on your Android device.

## Features

- 🗺️ **Map Discovery**: Find nearby grocery stores on an interactive map
- 🏪 **Shop Details**: View detailed information about each store including products and inventory
- 📦 **Product Catalog**: Browse extensive product listings with multiple brands
- 🛒 **Shopping Cart**: Add items to cart and manage your shopping list
- 💳 **Billing System**: Integrated billing screen for shop owners
- 📊 **Inventory Management**: Shop dashboard with inventory tracking

## Tech Stack

- **Framework**: Flutter
- **Maps**: Google Maps integration
- **State Management**: Provider/Riverpod
- **Location Services**: Geolocator

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Android SDK for Android development
- Xcode for iOS development (macOS only)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/shiva0042/NEST.git
cd NEST
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building APK

Use the provided PowerShell script:
```powershell
.\build_apk.ps1
```

## Project Structure

```
lib/
├── features/
│   ├── map_discovery/     # Map and location features
│   ├── shop_dashboard/    # Shop owner dashboard
│   └── ...
├── models/                # Data models
├── services/              # API and business logic
└── main.dart             # App entry point
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Contact

For any queries, please reach out through GitHub issues.
