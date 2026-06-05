<p align="center">
  <img src="assets/Gistnu_new_logo.webp" alt="GIST NU Logo" width="120"/>
</p>

<h1 align="center">Employee Task Tracker</h1>

<p align="center">
  <strong>A Flutter mini-project for learning & practicing mobile development fundamentals</strong>
</p>

<p align="center">
  <a href="README_TH.md">Read in Thai (TH)</a>
</p>

---

## About This Project

**Employee Task Tracker** is a mini-project I built **while waiting for the official project requirements** to be finalized. The goal was to **practice and deepen my understanding of Flutter development fundamentals** — from state management and Firebase integration to role-based access control and real-time data synchronization.

> **Note:** This is **not** a production application. It is a personal learning project created to explore Flutter concepts hands-on.

---

## Key Features

| Feature | Description |
|---|---|
| **Authentication** | Email/password login & registration via Firebase Auth, including password reset |
| **Role-Based Access** | Two roles — **Admin** (full access) and **Employee** (sees only assigned tasks) |
| **Task Management** | Create, edit, update status, assign, and delete tasks (CRUD) |
| **Task Status Tracking** | Three statuses — `To Do` → `In Progress` → `Done` |
| **Real-Time Sync** | Firestore streams for instant data updates across devices |
| **In-App Notifications** | Notify task creators/admins when status changes occur |
| **Task Chat & Comments** | Message thread per task with emoji reactions and file attachments |
| **Checklist** | Sub-task checklist within each task for detailed progress tracking |
| **Map View** | Google Maps integration to visualize task locations (GIST NU campus) |
| **Activity Log** | Track all actions performed on each task |
| **Custom Theme** | Consistent Material Design theming across the app |

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) — SDK ^3.7.2 |
| **Authentication** | Firebase Auth |
| **Database** | Cloud Firestore (real-time NoSQL) |
| **Maps** | Google Maps Flutter |
| **Location** | Geolocator |
| **Utilities** | intl (date formatting), url_launcher |
| **Architecture** | Service-based pattern with models, services, screens, and widgets |

---

## Project Structure

```
lib/
├── main.dart                  # App entry point & route config
├── firebase_options.dart      # Firebase configuration (auto-generated)
│
├── auth/
│   └── auth_service.dart      # Login, register, logout, password reset
│
├── models/
│   ├── task.dart              # Task data model
│   ├── user_model.dart        # User model with role (admin/employee)
│   ├── task_message.dart      # Chat messages & attachments model
│   ├── task_location.dart     # Location data model
│   ├── checklist_item.dart    # Checklist sub-items model
│   ├── activity_log.dart      # Activity log model
│   └── notification_model.dart # Notification model
│
├── services/
│   ├── task_service.dart      # CRUD operations & role-based queries
│   ├── task_detail_service.dart # Task detail operations (chat, checklist, etc.)
│   ├── notification_service.dart # In-app notification logic
│   └── location_service.dart  # GPS & location utilities
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart      # Login page
│   │   └── register_screen.dart   # Registration page
│   ├── task_list_screen.dart      # Main task list (filtered by role)
│   ├── task_form_screen.dart      # Create/edit task form
│   ├── task_detail_dialog.dart    # Task detail with chat & checklist
│   └── task_map_screen.dart       # Google Maps task view
│
├── widgets/
│   ├── task_card.dart         # Task list item card
│   └── status_chip.dart       # Status badge widget
│
├── theme/
│   └── app_theme.dart         # App-wide Material theme
│
└── utils/
    └── date_formatter.dart    # Date/time formatting helpers
```

---

## What I Learned

Through building this project, I practiced the following Flutter & Firebase concepts:

- **Firebase Integration** — Auth, Firestore setup, and real-time streams
- **State Management** — Using `StreamBuilder` for reactive UI updates
- **Role-Based Access Control** — Filtering data and UI based on user roles
- **CRUD Operations** — Full create, read, update, delete flow with Firestore
- **Google Maps Integration** — Displaying map markers with task locations
- **Clean Code Structure** — Separating concerns into models, services, screens, and widgets
- **Material Design** — Building consistent, themed UI components

---

## Getting Started

### Prerequisites

- Flutter SDK ^3.7.2
- Dart SDK
- Firebase project (Auth + Firestore enabled)
- Google Maps API key (for map features)

### Installation

```bash
# Clone the repository
git clone https://github.com/putianan65/employee_task_tracker.git

# Navigate to the project
cd employee_task_tracker

# Install dependencies
flutter pub get

# Run the app
flutter run
```

> You will need to configure your own Firebase project and update `firebase_options.dart` accordingly.

---

## License

This project is for **educational purposes only**. Feel free to reference it for learning.

---

<p align="center">
  Built with Flutter & Firebase
</p>
