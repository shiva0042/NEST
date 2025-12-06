# Product Onboarding & Custom Product Feature

## Overview
This feature allows shop owners to:
1.  **Onboard Products**: Select from a master catalog (sourced from `assets/data/consolidated_products.json`).
2.  **Add Custom Products**: Add items not in the catalog with an auto-suggest feature to prevent duplicates.

## Key Components
-   **Screens**:
    -   `ProductOnboardingScreen`: Main wizard for catalog selection.
    -   `CustomProductScreen`: Form for adding custom items with auto-suggest.
-   **Services**:
    -   `CatalogService`: Mock backend for fetching catalog data and handling custom submissions.
-   **State Management**:
    -   `OnboardingProvider`: Manages the state of the onboarding flow.

## How to Run
1.  Ensure you have Flutter installed and configured.
2.  Run the app in Chrome:
    ```bash
    flutter run -d chrome
    ```
3.  Navigate to the **Inventory** screen.
4.  Tap the **+** button to start onboarding.

## Testing
Unit tests are available in `test/product_onboarding_test.dart`.
Run them with:
```bash
flutter test
```
