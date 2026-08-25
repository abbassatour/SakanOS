

# 🏢 SakanOS — Real Estate ERP & Property Management System

[![Flutter](https://img.shields.io/badge/Flutter-3.41%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11%2B-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture%20%7C%20BLoC-blueviolet)](#-architecture--design-patterns)
[![Database](https://img.shields.io/badge/Storage-Drift%20(SQLite)%20%2B%20Supabase-00C7B7)](https://supabase.com)
[![CI](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=github-actions)](https://github.com)

**SakanOS** is an enterprise-grade, offline-first Enterprise Resource Planning (ERP) and property management platform built using Flutter and Dart. Designed for real estate development and investment firms, it handles complex installment scheduling, inflation-hedging calculations, automated document generation, and bidirectional cloud synchronization.

---

## 🌟 Key Features

- 🔄 **Offline-First Architecture & Cloud Sync:** Built on top of a local SQLite database (via Drift) with automatic bidirectional push/pull synchronization to Supabase when network connectivity is available.
- 📐 **Dynamic Engineering & Cost Calculations:** Automated calculations for square-meter valuation, construction materials indices (rebar, cement, aggregates, labor wages), and flexible payment amortization schedules.
- 🛡️ **Role-Based Access Control (RBAC) & PIN Security:** Granular user permissions for viewing, modifying, or deleting financial ledgers, backed by timed administrative PIN sessions.
- 🕒 **Cryptographic Anti-Tamper Time Tracking:** Implements network-verified true time offsets to prevent local device clock manipulation during offline auditing.
- 📊 **Executive KPI & Trend Analytics:** Real-time dashboards visualizing cash flow, debt aging (pre- and post-handover), portfolio occupancy, and historical construction material trends using interactive charts.
- 📄 **Automated Document Generation:** Generates localized contractual ledgers, preliminary handover pledges, and payment receipts in PDF format, alongside full data exports to Microsoft Excel.
- 🌐 **Full Internationalization (i18n):** Native bilingual support (Arabic & English) with right-to-left (RTL) dynamic interface layout adjustments.

---

## 🏗 Architecture & Design Patterns

The project is structured as a **modular monorepo** following Clean Architecture and Domain-Driven Design (DDD) principles:

├── packages/ │ ├── local_storage_api/ # Local persistence layer (Drift / SQLite
tables & DAOs) │ ├── cloud_storage_api/ # Remote backend interface (Supabase API
& Realtime) │ └── erp_repository/ # Unified business logic facade orchestrating
local & cloud APIs ├── lib/ │ ├── app/ # App-level entry points and multi-bloc
orchestration │ ├── auth/ # Authentication, PIN session timeout, & RBAC state
management │ ├── contracts/ # Contract creation, coefficients, and scheduling
workflows │ ├── dashboard/ # Core navigation and shell routing │ ├── home/ #
Real-time financial KPIs, charts, and activity streams │ ├── payments/ #
Transaction ledger, vouchers, and reverse accounting entries │ ├── schedule/ #
Overdue radar, tracking interaction checkpoints │ ├── settings/ # Material price
adjustments, dollar rates, & backup management │ └── l10n/ # Localization files
(.arb) for Arabic and English └── .github/workflows/ # CI pipelines for
automated linting, formatting, and analysis


### Design Patterns Utilized:
- **BLoC Pattern (`flutter_bloc`):** Decoupled presentation from business logic using predictable event-state transformations.
- **Facade Pattern (`erp_repository`):** Abstracts low-level database transactions and cloud networking behind high-level, business-oriented repository interfaces.
- **Atomic Database Transactions:** Multi-entity operations (e.g., signing a contract, creating an initial payment, and marking property units as reserved) are encapsulated in database transactions to guarantee ACID compliance.

---

## 🚀 Tech Stack & Libraries

- **Frontend / Client:** [Flutter Desktop & Mobile](https://flutter.dev), Material 3 Design
- **State Management:** [BLoC](https://pub.dev/packages/flutter_bloc) & [Equatable](https://pub.dev/packages/equatable)
- **Local Database:** [Drift](https://drift.simonbinder.eu/) (formerly Moor) with SQLite Native bindings
- **Backend / Cloud:** [Supabase](https://supabase.com) (PostgreSQL, Auth, Realtime, Storage)
- **Visualizations:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Document & File Handling:** [pdf](https://pub.dev/packages/pdf), [printing](https://pub.dev/packages/printing), [excel](https://pub.dev/packages/excel), [file_picker](https://pub.dev/packages/file_picker)
- **Configuration Security:** [envied](https://pub.dev/packages/envied) for compile-time environment variable obfuscation

---

## ⚙️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.41.0` or higher)
- [Dart SDK](https://dart.dev/get-dart) (`^3.11.0` or higher)
- C++ build tools (for Windows/macOS desktop development)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/sakanos.git
   cd sakanos

2.  Install root and subpackage dependencies:

    flutter pub get

3.  Configure Environment Variables: Create a .env file in the project root:

    SUPABASE_URL=your_supabase_project_url
    SUPABASE_ANON_KEY=your_supabase_anon_key

4.  Generate Code (Drift & Envied):

    dart run build_runner build --delete-conflicting-outputs

5.  Run the application:

    flutter run -d windows # Or macos / linux

🧪 Code Quality & CI

Continuous Integration is set up via GitHub Actions (main.yaml) to ensure code
quality on every pull request and push:

  - Format Verification: dart format --set-exit-if-changed .
  - Static Analysis: flutter analyze . with strict linting rules from
    very_good_analysis.



