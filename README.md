# EMERGENCY: Hospital Bed Availability & Booking System

![Home Page](https://i.ibb.co.com/5hG1sm2S/dfcdf.png)

## Introduction

**EMERGENCY** is a real-time hospital bed availability and booking system designed to enhance hospital resource management and improve patient care through streamlined automation and intuitive interfaces. It allows patients to check availability, register, and book beds across various hospitals while providing administrators and staff with real-time tools for operational management.

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [System Architecture](#system-architecture)
- [UI Screens](#ui-screens)
- [Team Members](#team-members)
- [Performance](#performance)
- [Limitations](#limitations)
- [Future Work](#future-work)
- [License](#license)

---

## Features

- ✅ **Real-Time Bed Tracking** – View real-time availability of ICU, NICU, and general beds.
- 🏥 **Online Booking Portal** – Seamless registration and bed booking for patients.
- 🔐 **Role-Based Access** – Secure logins for admins, hospital staff, and patients.
- 🔄 **Trigger-Based Updates** – SQL/database triggers for instant status syncing.
- 📊 **Admin Dashboard** – Comprehensive tools for managing hospital resources.
- 💡 **Scalable & Modular** – Designed for scalability and easy integration.

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/ASSabbir/flutter-app
   cd emergency-bed-booking
   ```

2. Set up your virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Configure database credentials in `.env` or `config.py`.

5. Run the app:
   ```bash
   flask run
   ```

---

## Usage

- Patients can:
  - Register and receive a unique SRFID.
  - Check bed availability across hospitals.
  - Book beds based on availability.

- Hospital Users can:
  - Log in to manage and update bed status.
  - Monitor triggered logs.

- Admins can:
  - Add new hospitals.
  - Create and manage hospital accounts.
  - View analytics.

---

## System Architecture

- **Frontend:** HTML, CSS, JavaScript
- **Backend:** Flask (Python)
- **Database:** MySQL with SQLAlchemy
- **Authentication:** Role-Based Access (Admin, Hospital Staff, Patient)
- **Data Sync:** SQL Triggers for real-time updates

---

## UI Screens

- 🏠 Home Page – Open view of hospital seat availability.
- 🧾 Signup/Login Pages – Separate for Patient, Hospital, and Admin.
- 🧑‍⚕️ Admin Panel – Manage hospitals and view system activity.
- 🏥 Hospital Dashboard – Update bed status and view logs.
- 🙋 Patient Dashboard – Book beds, view booking history.

---

## Team Members

| Name               | Student ID     |
|--------------------|----------------|
| Atik Al Sabbir     | 221-15-5372    |
| Abid Hasan Nirjon  | 221-15-5217    |
| Farzana Afroz      | 221-15-5169    |
|--------------------|----------------|


> Supervised by: **Fahim Ahsan**, Senior Lecturer, CSE, Daffodil International University

---

## Performance

- ⏱️ **Avg Response Time:** < 1 sec under normal load; 2–3 sec under stress (1000 users).
- 🧠 **CPU/Memory Usage:** < 50% at peak.
- 🎯 **User Feedback:** 95% rated UI as intuitive and useful.

---

## Limitations

- Limited support for external health systems (e.g., government databases).
- Dependent on continuous internet connectivity.
- Scalability to large, multi-branch hospitals may require infrastructure upgrades.

---

## Future Work

- Integrate support for medical equipment (e.g., oxygen cylinders).
- Predictive analytics for patient discharge using ML.
- Mobile app development for broader access.
- Multilingual UI for diverse user groups.

---

## License

© 2025 Daffodil International University – For academic use only.
