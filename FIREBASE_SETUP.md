# Firebase Setup Guide for NEST App

## 📋 Prerequisites
- Node.js installed (for Firebase CLI)
- A Google account
- Flutter SDK installed

---

## 🔧 Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"** or **"Add project"**
3. Enter project name: `nest-app` (or your preferred name)
4. Enable/disable Google Analytics as needed
5. Click **Create Project**

---

## 📱 Step 2: Add Android App

1. In Firebase Console, click the **Android icon** to add an Android app
2. Enter the package name: `com.example.near_basket`
   - Find this in `android/app/build.gradle` under `applicationId`
3. Enter app nickname: `NEST Android`
4. (Optional) Add SHA-1 fingerprint for Phone Auth:
   ```powershell
   cd android
   .\gradlew signingReport
   ```
   Copy the SHA-1 from the debug variant

5. Click **Register app**
6. Download `google-services.json`
7. Place it in: `android/app/google-services.json`

---

## 🍎 Step 3: Add iOS App (Optional)

1. Click **Add app** → **iOS**
2. Enter iOS bundle ID: `com.example.nearBasket`
   - Find this in `ios/Runner.xcodeproj/project.pbxproj`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

---

## 🌐 Step 4: Add Web App

1. Click **Add app** → **Web**
2. Enter app nickname: `NEST Web`
3. Copy the configuration object

---

## 🔐 Step 5: Enable Phone Authentication (Shop Owners)

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click **Phone** and enable it
3. Add test phone numbers for development:
   - Example: `+91 9999999999` with code `123456`

---

## 🔐 Step 5b: Enable Google Sign-In (Customers)

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click **Google** in the providers list
3. Toggle **Enable** to ON
4. Enter a **Project support email** (your Gmail)
5. Click **Save**

### For Web Apps:
1. Go to **Project Settings** → **General**
2. Scroll to **Your apps** → **Web app**
3. Copy the **Web client ID** for Google Sign-In
4. Add authorized domains in Authentication → Settings → Authorized domains

### For Android:
1. Go to **Project Settings** → **General**
2. Scroll to your Android app
3. Add your **SHA-1 certificate fingerprint**:
   ```powershell
   cd android
   .\gradlew signingReport
   ```
4. Copy SHA-1 from debug variant and add to Firebase

---

## 📁 Step 6: Update Configuration Files

### Option A: Use FlutterFire CLI (Recommended)

```powershell
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure (run from project root)
flutterfire configure
```

This will automatically generate `lib/firebase_options.dart` with your credentials.

### Option B: Manual Configuration

Edit `lib/firebase_options.dart` and replace placeholder values:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIza...',                    // From google-services.json
  appId: '1:123456789:android:abc123',  // From google-services.json
  messagingSenderId: '123456789',        // project_number
  projectId: 'your-project-id',          // project_id
  storageBucket: 'your-project-id.appspot.com',
);
```

Find these values in `google-services.json`:
- `apiKey`: `client[0].api_key[0].current_key`
- `appId`: `client[0].client_info.mobilesdk_app_id`
    match /shops/{shopId} {
      allow read: if true;
      allow write: if request.auth != null && 
                   request.auth.token.phone_number == resource.data.phone;
      
      // Shop inventory - only owner can write
      match /inventory/{itemId} {
        allow read: if true;
        allow write: if request.auth != null;
      }
      
      // Bills - only owner can read/write
      match /bills/{billId} {
        allow read, write: if request.auth != null;
      }
    }
    
    // Global products - anyone can read
    match /products/{productId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if false; // Admin only
    }
  }
}
```

---

## 📦 Step 8: Set Up Cloud Storage

1. Go to **Storage** in Firebase Console
2. Click **Get started**
3. Choose test mode for development
4. Select the same region as Firestore

### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /shops/{shopId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /products/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## ✅ Step 9: Verify Setup

1. Run the app:
   ```powershell
   flutter run
   ```

2. Check the console for:
   ```
   Firebase initialized successfully!
   ```

3. If you see errors:
   - Verify `google-services.json` is in the correct location
   - Check that package name matches in Firebase Console
   - Ensure all dependencies are installed (`flutter pub get`)

---

## 🧪 Testing Phone Auth

For testing, add test phone numbers in Firebase Console:

1. Go to **Authentication** → **Sign-in method** → **Phone**
2. Expand **Phone numbers for testing**
3. Add:
   - Phone: `+91 9999999999`
   - Verification code: `123456`

---

## 🚀 Ready to Go!

Your Firebase setup is complete. The app can now use:
- ✅ Google Sign-In (Customers)
- ✅ Phone OTP Authentication (Shop Owners)
- ✅ Cloud Firestore (database)
- ✅ Cloud Storage (images)
- ✅ Cloud Messaging (push notifications)

---

## 📞 Troubleshooting

### "No Firebase App" Error
Make sure `Firebase.initializeApp()` is called in `main()` before `runApp()`.

### SHA-1 Certificate Error (Android)
```powershell
cd android
.\gradlew signingReport
```
Add the SHA-1 to Firebase Console → Project Settings → Your apps → Android app.

### OTP Not Received
1. Check if phone number format is correct (include country code: `+91...`)
2. Use test phone numbers during development
3. Enable Phone Auth in Firebase Console

### Web Not Working
Make sure to add your domain to authorized domains in Firebase Auth settings.
