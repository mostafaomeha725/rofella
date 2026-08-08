# 🚨 AI Coding Conventions
These rules are automatically generated based on the detected Framework (`lib/core`) and Project Patterns (`lib/features`).
**You must follow these rules strictly.**

## 0. Rule Priority Order
1. **Framework Rules**: Mandatory architectural rules defined in `.ai/VALIDATION_RULES.json` and `.ai/CONVENTIONS.md`.
2. **Project Conventions**: Settings explicitly defined for this project.
3. **Repository Patterns**: Patterns detected dynamically from the existing code.
*Framework rules always have higher priority than detected repository patterns.*

## 1. UI & Widgets
- **Buttons**: Never use `TextButton`, `ElevatedButton`, `OutlinedButton`, or `FilledButton`. Always use the framework button (`AppButton` or `CustomButton`).
- **Text**: Never use raw `Text`. Always use `AppText` or `CustomText`.
- **Forms**: Never use `TextFormField`. Always use `AppFormField`.
- **Images**: Never use `Image.network`. Always use `AppImage`.
- **Widget Reuse**: Always search `lib/core/widgets` before creating a new widget. Never duplicate widgets.

## 2. Typography & Typography Resolver
## 3. Loading & Feedback
- **Loading**: Never use `SnackBar` or `ScaffoldMessenger`. Always use the existing `EasyLoading` implementation.

## 4. Colors & Spacing
- **Colors**: Never use hardcoded colors (`Colors.white`, `Colors.black`, `Colors.blue`, `Colors.red`). Always use project theme colors.
- **Spacing**: Avoid repeated `SizedBox` values. Reuse spacing utilities from the framework.


## 5. Responsive System (MANDATORY)
- **Responsive Framework Detected**: `flutter_screenutil`
  - Design Size: 420.0x910.0
- **Rules**:
  - Never use raw dimensions.
  - Always use the detected responsive system.
  - Never use raw font sizes if the framework already provides typography.
  - Always reuse the project's typography styles.
  - Width Extension: `.w`
  - Height Extension: `.h`
  - Radius Extension: `.r`
  - Font Extension: `.sp`
  - Padding Extension: `.w or .h`
  - Margin Extension: `.w or .h`
  - Icon Size Extension: `.sp or .w`

## 6. Feature Structure & Patterns
- Every feature must follow Clean Architecture: `data`, `domain`, `presentation` (with `screens`, `widgets`, `cubit`).
- **Focused Cubit Architecture (MANDATORY)**:
  - Never create a large Cubit responsible for multiple independent user flows.
  - Every independent user flow (e.g., Login, Register, Forgot Password, OTP, Checkout) must have its own Cubit and State.
  - Flow Cubits handle only one user flow, have one responsibility, and depend only on required UseCases.
  - Feature Cubit (if any) should handle only shared feature-level state and never contain business logic belonging to independent flows.
  - Organize Cubits in separate folders by flow (e.g., `presentation/cubits/<flow_name>/<flow_name>_cubit.dart`).
- **Flow Pattern**: `Screen -> ScreenBody -> Custom Widgets\nRULE: Every ScreenBody MUST be generated inside presentation/screens/widgets/` (Confidence: 100%)
  - Detected in: lib/features/auth/presentation/screens/widgets/forget_password, lib/features/auth/presentation/screens/widgets/login, lib/features/banking/presentation/screens/widgets/banking_dashboard, lib/features/ecommerce_home/presentation/screens/widgets/ecommerce_home, lib/features/home/presentation/screens/widgets/home, lib/features/notifications/presentation/screens/widgets/notifications, lib/features/product_details/presentation/screens/widgets/product_details, lib/features/profile/presentation/screens/widgets/profile
- **Flow Pattern**: `Cubit -> UseCase -> Repository -> Datasource` (Confidence: 100%)
  - Detected in: auth, addbeneficiary, bankingdashboard, bankingstatistics, bills, transactions, transactiondetails, transfermoney, ecommercehome, home, notifications, productdetails, profile
- **Flow Pattern**: `Form -> AppFormField -> Validation -> Cubit` (Confidence: 100%)
  - Detected in: AppFormField
- **Screen Structure**: The Screen file must contain only `Scaffold`, `AppBar`, `BlocListener`/`BlocConsumer`, and Navigation. All UI must be extracted into a `ScreenBody`. Never place UI directly inside Screen.
- **UI Logic**: Never put business logic inside UI. UI only renders state. Business logic belongs inside Cubit.

## 7. Pre-Generation Verification (MANDATORY)
- **Repository Search**: Run semantic searches for existing implementations before creating anything new.
- **API Verification**: Check the actual method signatures in `framework.json` or by reading the file before calling any service. Never invent methods.
- **Dependency & Collision Checks**: Verify `getIt` registrations and class names to avoid duplicates. Extend existing features (like Auth) rather than duplicating them.

## 8. Constants & Hardcoded Values
- **Rule**: Never hardcode a literal (String, number, etc.) if an equivalent reusable constant already exists in the framework.
- The AI must automatically prefer reusable constants over literals.
- Example: Do not use `'/api/login'` if `EndPoints.login` is available.

## 9. Clean Code Rules
- **Maximum File Size**: 250 lines
- **Maximum Widget Size**: 120 lines
- **Maximum Method Size**: 25 lines
- Extract widgets and methods aggressively.

## 10. UI Composition Architecture (MANDATORY)
### Screen Responsibility
Every `*_screen.dart` must be as small as possible. A screen is responsible ONLY for: Scaffold, AppBar, BlocConsumer / BlocBuilder, Navigation, Dialogs, Bottom Sheets, EasyLoading, Page orchestration.
A screen must NEVER contain business UI.

### Screen Body
Every screen must have a dedicated body widget extracted into `presentation/screens/widgets/*_screen_body.dart`.
The body contains the page layout only. Never place the ScreenBody class inside the Screen file.

### UI Composition
Large UI must always be split into small widgets. Never keep a large Column, ListView, or SingleChildScrollView inside ScreenBody.
Extract every logical UI section into its own widget (e.g. `login_header.dart`, `login_form.dart`, `login_footer.dart`).

### Widget Extraction
Private UI builder methods are forbidden. Never generate `_buildCard()`, `_buildItem()`, `_buildHeader()`, etc.
Any method that returns a Widget must become its own widget class in a separate file.

### Widget Size Rules
If any of these limits are exceeded, the UI MUST be automatically split:
- Maximum screen.dart: 100 lines
- Maximum screen_body.dart: 150 lines
- Maximum widget: 100 lines
- Maximum method: 25 lines

### Framework Philosophy
The AI must optimize for maintainability. It should always prefer:
- Smaller files
- Smaller widgets
- Reusable components
- Single Responsibility
- Composition over large screens
- Reuse over duplication

