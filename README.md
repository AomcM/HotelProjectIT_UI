# Hotel IT Support System

## 📌 Overview

The **Hotel IT Support System** is a role-based ticket management application developed to improve communication between hotel employees, IT technicians, and IT managers.

Instead of contacting the IT department manually, employees can create support tickets directly from the application. Technicians can view available tickets, update their status, add notes, and resolve issues. Managers can monitor all tickets, assign technicians, manage ticket progress, and view statistics.

The project was developed as part of a hotel IT internship.

---

## 👥 User Roles

The application supports three user roles:

| Role ID | Role       | Description                                                 |
| ------- | ---------- | ----------------------------------------------------------- |
| 1       | Employee   | Creates and tracks IT support tickets                       |
| 2       | Technician | Handles assigned tickets and updates their status           |
| 3       | Manager    | Manages tickets, assigns technicians, and monitors activity |

---

# ✨ Features

## 👨‍💼 Employee

Employees can:

* Log in securely
* Create IT support tickets
* View their tickets
* Track ticket status
* View ticket details
* View technician notes
* View AI analysis when available
* Edit or delete tickets where allowed
* View their profile
* Log out

---

## 🛠️ Technician

Technicians can:

* View available unassigned Open tickets
* View their assigned tickets
* Search tickets
* Filter tickets by status
* View ticket statistics
* Update ticket status
* Update ticket priority
* Add technician notes
* Mark tickets as In Progress, Resolved, or Closed
* View their profile
* Log out

Ticket statuses include:

```text
Open
In Progress
Resolved
Closed
```

---

## 👨‍💻 IT Manager

Managers can:

* View all tickets
* Search tickets
* Filter tickets by status
* View ticket statistics
* Assign technicians to tickets
* Reassign technicians
* Monitor ticket progress
* Close tickets
* View ticket details
* Access reports and statistics
* View their profile
* Log out

---

# 🔄 Ticket Workflow

The general ticket workflow is:

```text
Employee creates ticket
        ↓
Open
        ↓
Manager assigns technician
        ↓
In Progress
        ↓
Technician resolves the issue
        ↓
Resolved
        ↓
Manager closes the ticket
        ↓
Closed
```

Unassigned Open tickets can be viewed by technicians and are not tied to a specific technician.

Once a ticket is assigned, it becomes associated with the selected technician.

---

# 🤖 AI Integration

The system includes AI analysis for IT support tickets.

AI can analyze ticket information and provide:

* Issue category
* Suggested priority
* Suggested solution

This information helps technicians and managers understand and prioritize support requests.

---

# 🏗️ Technologies Used

## Frontend

* Flutter
* Dart
* Material Design

## Backend

* ASP.NET Core Web API
* C#
* Entity Framework Core

## Database

* MySQL
* MariaDB
* XAMPP
* phpMyAdmin

## Security

* BCrypt password hashing
* JWT Authentication

## Other Tools

* Visual Studio
* Visual Studio Code
* Android Studio
* Git
* GitHub
* Swagger

---

# 📂 Project Structure

## Backend

```text
HotelIT.API
│
├── Controllers
│   ├── AuthController.cs
│   ├── TicketsController.cs
│   └── UsersController.cs
│
├── Data
│   └── HotelITDbContext.cs
│
├── DTOs
│
├── Models
│
├── Services
│   └── GeminiService.cs
│
├── Program.cs
└── appsettings.json
```

## Flutter Application

```text
lib
│
├── models
│   ├── ticket.dart
│   ├── technician.dart
│   └── ...
│
├── services
│   └── api_service.dart
│
├── screens
│   ├── login_page.dart
│   ├── home_page.dart
│   ├── tickets_list_page.dart
│   ├── ticket_details_page.dart
│   ├── create_ticket_page.dart
│   └── profile_page.dart
│
├── technician
│   ├── technician_home_page.dart
│   ├── technician_tickets_list_page.dart
│   ├── technician_ticket_details_page.dart
│   ├── technician_update_ticket_page.dart
│   └── technician_profile_page.dart
│
└── manager
    ├── manager_home_page.dart
    └── manager_ticket_details_page.dart
```

---

# 🔐 Authentication

User passwords are not stored as plain text.

Passwords are hashed using **BCrypt** before being saved in the database.

Example:

```text
User password
     ↓
BCrypt.HashPassword()
     ↓
Encrypted password hash stored in database
```

During login:

```text
User enters password
        ↓
API receives login request
        ↓
BCrypt.Verify()
        ↓
Authentication successful or failed
```

JWT tokens are used to support secure authentication between the Flutter application and the ASP.NET Core API.

---

# 🗄️ Database

The main database is:

```text
hotelitservicedb
```

Main tables include:

```text
Users
Roles
Departments
Tickets
Assets
Aianalysis
Notification
```

Relationships include:

```text
User
 ├── Role
 └── Department

Ticket
 ├── Employee
 ├── Technician
 ├── Department
 └── AI Analysis
```

---

# 🚀 Running the Backend

### 1. Clone the repository

```bash
git clone YOUR_REPOSITORY_URL
```

### 2. Open the backend project

Open the solution using Visual Studio.

### 3. Configure the database connection

Update the connection string inside:

```text
appsettings.json
```

Example:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "server=localhost;database=hotelitservicedb;user=root;password=YOUR_PASSWORD"
  }
}
```

### 4. Install dependencies

Restore NuGet packages:

```bash
dotnet restore
```

### 5. Run the API

```bash
dotnet run
```

The API will display addresses similar to:

```text
Now listening on: http://localhost:5262
Now listening on: https://localhost:7021
```

Swagger can be accessed at:

```text
http://localhost:5262/swagger
```

---

# 📱 Running the Flutter Application

### 1. Install Flutter dependencies

Inside the Flutter project:

```bash
flutter pub get
```

### 2. Configure the API URL

For Flutter Web:

```dart
static const String baseUrl =
    "http://localhost:5262/api";
```

For a physical Android device, `localhost` will not work because it refers to the phone itself.

Use your computer's local IP address instead:

```dart
static const String baseUrl =
    "http://192.168.X.X:5262/api";
```

Both the computer and phone must be connected to the same network.

### 3. Run the application

```bash
flutter run
```

---

# 🔮 Future Improvements

Possible future improvements include:

* Push notifications
* File and image attachments for tickets
* Email notifications
* Advanced manager reports
* Charts and analytics
* Asset management improvements
* Password reset functionality
* Role-based JWT authorization
* Ticket comments and activity history
* Improved AI recommendations
* Deployment to a cloud server

---

# 📊 Current Project Status

| Feature                   | Status         |
| ------------------------- | -------------- |
| Employee ticket creation  | ✅ Completed    |
| Employee ticket tracking  | ✅ Completed    |
| Technician dashboard      | ✅ Completed    |
| Technician ticket updates | ✅ Completed    |
| Ticket assignment         | ✅ Completed    |
| Manager ticket management | 🔄 In Progress |
| Ticket statistics         | ✅ Completed    |
| Search and filtering      | ✅ Completed    |
| Password hashing          | ✅ Completed    |
| JWT Authentication        | 🔄 In Progress |
| AI ticket analysis        | ✅ Implemented  |
| Reports dashboard         | 🔄 In Progress |

---

# 👨‍💻 Author

**Mourad**

Computer Science / IT Student
Hotel IT Internship Project

---

# 📄 License

This project was developed for educational and internship purposes.
