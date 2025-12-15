

---


# Monthly Expense - Wealth Tracker

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Riverpod](https://img.shields.io/badge/State-Riverpod-purple?style=for-the-badge)

**Monthly Expense** is a robust, cross-platform (Mobile & Web) application designed to help users track their wealth, manage multiple wallets, and visualize spending habits. Built with Flutter and powered by Firebase, it features real-time synchronization, offline persistence, and a modern, theme-aware UI.

## 📱 Features

### 💰 Wallet & Expense Management
* **Multi-Wallet Support:** Create separate wallets for different needs (e.g., Personal, Business, Travel).
* **Budget Tracking:** Set monthly budgets and get visual alerts when overspending.
* **Smart Rollover:** Automatically calculate and rollover surplus or deficits when creating new monthly budgets.
* **Negative Balance Alerts:** UI adapts to show red warnings and "Over Budget" badges when a wallet goes into debt.

### 📊 Analytics & Insights
* **Interactive Charts:**
    * **Category Breakdown:** Pie charts to visualize where money is going.
    * **Spending Trends:** Bar charts showing daily spending activity.
    * **Weekly & Yearly Summaries:** Dedicated tabs for long-term financial analysis.
* **PDF Export:** Generate professional PDF expense reports for any wallet.

### 🎯 Savings Goals
* **Goal Tracking:** Create saving targets (e.g., "New Laptop") with deadlines.
* **Fund Transfer:** specialized UI to securely move funds from Wallets to Savings Goals.
* **Visual Progress:** Linear progress bars indicating completion percentage.

### ⚙️ User Experience & Customization
* **Dark/Light Mode:** Fully adaptive UI that respects system settings or user preference.
* **Cross-Platform Profile:** Profile picture support for both Mobile (File System) and Web (Base64).
* **Secure Authentication:** Email/Password login and signup via Firebase Auth.
* **Offline First:** Works without internet; syncs data when connection is restored.

## 📸 Screenshots

| Home Dashboard | Dark Mode Analytics 1 | Dark Mode Analytics 2 |
|:---:|:---:|:---:|
| <img src="screenshots/Screenshot 2025-12-15 at 7.34.36 AM.png" width="250"> | <img src="screenshots/Screenshot 2025-12-15 at 7.36.51 AM.png" width="250"> | <img src="screenshots/Screenshot 2025-12-15 at 7.37.10 AM.png" width="250"> |

| Savings Goals | Wallet Detailed with Over Budget | Wallet Detailed with under budget |
|:---:|:---:|:---:|
| <img src="screenshots/Screenshot 2025-12-15 at 7.40.28 AM.png" width="250"> | <img src="screenshots/Screenshot 2025-12-15 at 7.35.13 AM.png" width="250"> | <img src="screenshots/Screenshot 2025-12-15 at 7.39.39 AM.png" width="250"> |

| Side Bar | Global Summary(Weekly) | Global Summary(yearly)  |
|:---:|:---:|:---:|
| <img src="screenshots/Screenshot 2025-12-15 at 7.46.18 AM.png" width="250"> | <img src="screenshots/Screenshot 2025-12-15 at 7.46.59 AM.png" width="250"> | <img src="screenshots/Screenshot 2025-12-15 at 7.47.09 AM.png" width="250"> |

| PDF Export | Settings | Create wallet dialog |
|:---:|:---:|:---:|
| <img src="screenshots/Screenshot 2025-12-15 at 7.44.15 AM.png" width="250"> | <img src="screenshots/Screenshot 2025-12-15 at 7.46.38 AM.png" width="250"> | <img src="screenshots/Screenshot 2025-12-15 at 7.56.33 AM.png" width="250"> |

| Create expanse dialog | Saving goal dialog | deleting/Refund  goal Dialog |
|:---:|:---:|:---:|
| <img src="screenshots/Screenshot 2025-12-15 at 7.56.53 AM.png" width="250"> | <img src="screenshots/Screenshot 2025-12-15 at 7.57.10 AM.png" width="250"> | <img src="screenshots/Screenshot 2025-12-15 at 7.57.50 AM.png" width="250"> |

## 🛠 Tech Stack

* **Framework:** Flutter (Dart)
* **State Management:** [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod) (v2.5.1)
* **Backend:** Firebase (Auth, Firestore)
* **Charts:** [FL Chart](https://pub.dev/packages/fl_chart)
* **PDF Generation:** [Pdf](https://pub.dev/packages/pdf) & [Printing](https://pub.dev/packages/printing)
* **Utilities:**
    * `intl` for currency and date formatting.
    * `image_picker` for profile photos.
    * `shared_preferences` for local settings.

## 📂 Project Structure

The project follows a **Feature-First** architecture for scalability and maintainability:

```text
lib/
├── core/               # Shared utilities (CurrencyHelper, PDFHelper, etc.)
├── features/
│   ├── analytics/      # Charts, Summary Screen, Repository
│   ├── auth/           # Login, Signup, User Model, Auth Repository
│   ├── expenses/       # Expense CRUD, Dialogs
│   ├── home/           # Home Screen, Drawer
│   ├── savings/        # Savings Goals, Deposit Dialog
│   ├── settings/       # Theme Switcher, Profile Edit
│   ├── wallet/         # Wallet Logic, Repository, Detail Screen
│   └── providers/      # Global providers (Theme, etc.)
├── firebase_options.dart
└── main.dart

```

## 🚀 Getting Started 
### Prerequisites *Flutter SDK* (3.9.2 or higher)
* Dart SDK
* A Firebase Project

## Installation. 

**Clone the repository:**
```bash
git clone [https://github.com/yourusername/monthly-expense-tracker.git](https://github.com/yourusername/monthly-expense-tracker.git)
cd monthly-expense-tracker

```


2. **Install dependencies:**
```bash
flutter pub get

```


3. **Firebase Setup:**
* Create a project in the [Firebase Console](https://console.firebase.google.com/).
* Enable **Authentication** (Email/Password).
* Enable **Cloud Firestore** (Create database in test mode or set appropriate rules).
* Configure your app using FlutterFire CLI:
```bash
flutterfire configure

```


* This will update `lib/firebase_options.dart` with your specific API keys.


4. **Run the app:**
```bash
flutter run

```


# 🚀 Future Roadmap & Improvements

## 🌟 New Features (Functional)

### ☁️ Cloud Storage for Profile Pictures
* **Current State:** Profile images are stored locally using file paths in `SharedPreferences`. Images do not sync across devices.
* **Improvement:** Integrate **Firebase Storage** to upload user profile pictures. Save the download URL in the Firestore `users` collection to ensure the profile picture persists across all devices and logins.

### 🔄 Recurring Expenses / Subscriptions
* **Idea:** Allow users to mark specific expenses (e.g., Rent, Netflix, Internet) as "Recurring."
* **Implementation:** Implement a background service or a startup check logic that automatically adds these expenses to the current wallet when their due date passes.

### 🔐 Biometric Authentication
* **Idea:** Enhance privacy by requiring biometric verification (Fingerprint or Face ID) to open the app.
* **Library:** Utilize the `local_auth` package to implement secure access control.

### 💱 Multi-Currency Support
* **Current State:** Currency formatting is hardcoded to Bangladesh Taka (৳).
* **Improvement:** Add a setting in the "Preferences" screen allowing users to select their preferred currency symbol ($, €, £, ৳, ₹). Update the `CurrencyHelper` to respect this global setting.

### 🔍 Search & Filter
* **Idea:** Improve navigation within large wallets.
* **Implementation:** Add a search bar in the `WalletDetailScreen` to filter expenses by title (e.g., "Dinner"), category, or specific date ranges.

---

## 🛠 Technical Improvements

### 📄 CSV / Excel Export
* **Current State:** Basic PDF export is implemented; `csv_helper.dart` exists but is currently disabled.
* **Improvement:** Enable CSV export functionality. This allows power users to export their data for detailed analysis in tools like Microsoft Excel or Google Sheets.

### 🌍 Localization (l10n)
* **Current State:** All UI text is hardcoded in English.
* **Improvement:** Implement the `flutter_localizations` package. Extract strings into resource files to support multiple languages (e.g., English & Bengali), making the app accessible to a wider audience.

### 🏗 State Management Refactoring
* **Current State:** Logic is sometimes mixed within UI `build` methods.
* **Improvement:** Strictly separate **Business Logic** from **UI**. Move calculations (like `totalSpent`, progress percentages, and filtering) out of widgets and into Riverpod Providers or View Models for cleaner, testable code.

---

## 🎨 UI/UX Enhancements

### 🏷️ Custom Category Management
* **Current State:** Categories (Food, Transport, etc.) are hardcoded.
* **Improvement:** Build a "Manage Categories" screen where users can create custom categories, assign unique colors, and select specific icons.

### 🚀 Onboarding Screen
* **Idea:** Improve the first-time user experience.
* **Implementation:** Introduce a 3-page slider upon initial app launch explaining key features: "Create a Wallet," "Track Expenses," and "View Analytics."

### ✨ Hero Animations
* **Idea:** Create seamless visual transitions.
* **Implementation:** Use `Hero` widgets when navigating from the Home Screen to the `WalletDetailScreen`. This will make the wallet card appear to expand naturally into the detail view header.

---

## 🔒 Backend (Firebase)

### 🛡️ Firestore Security Rules
* **Critical:** Secure user data.
* **Action:** Implement strict Firestore rules to ensure users can **only** read and write documents belonging to their own `uid`.
    ```javascript
    allow read, write: if request.auth != null && request.auth.uid == userId;
    ```

### 🤖 Automated Monthly Rollover
* **Current State:** Rollovers are manual actions taken when creating a new wallet.
* **Improvement:** Deploy **Firebase Cloud Functions** to run scheduled jobs (CRON) that detect the end of a month, automatically calculate the balance, and potentially draft a new budget for the upcoming month.



## 🤝 Contributing
Contributions are welcome! Please follow these steps:

1. Fork the project.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.





## 👨‍💻 Developer

Developed by **Abdullah Nazmus-Sakib** CSE, Jahangirnagar University

-----
**Developed with ❤️ using Flutter.**



## 📄 License
This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.