# LocalHub Project 🌐📱

Welcome to the LocalHub project! This repository contains both the backend API and the frontend Flutter app for LocalHub, a platform designed to connect users with their local communities.

## Project Structure 📂

- **api/**: Contains the backend API code written in bun(nodejs drop in replacement), responsible for handling server-side logic, database operations, and serving data to the Flutter app.
- **flutter/**: Houses the Flutter app code, responsible for the user interface, client-side logic, and interaction with the backend API.

## Features ✨

### Backend API (api/)
- Handles user authentication, registration, and user management.
- Manages community creation, membership, and interaction.
- Provides endpoints for posting, commenting, and liking content.
- Supports file uploads for user avatars and post images.

### Flutter App (flutter/)
- User-friendly interface for accessing LocalHub features.
- Allows users to discover and join communities.
- Enables posting, commenting, and engaging with community content.
- Supports user profile customization and management.

## Getting Started 🚀

### Prerequisites
- Ensure bun.sh and postgresql are installed for running the backend API.
- Install Flutter SDK for building and running the Flutter app.

### Backend Setup
1. Navigate to the `api/` directory.
2. Install dependencies using `bun install`.
3. Set up environment variables for database and server configuration.
4. Run the API server using `bun start`.

### Flutter App Setup
1. Navigate to the `flutter/localhub` directory.
2. Install dependencies using `flutter pub get`.
3. Build and run the app using `flutter run`.
4. Connect the app to the backend API by updating the server URL in the app settings.

## Contributors 👨‍💻👩‍💻

- [Vedant Jain](https://github.com/vedantjain8)
- [Bhavya Jain](https://github.com/bhavyaj19)
- [Mayank Gupta](https://github.com/mayankggupta)

## License 📝

This project is licensed under the [GNU General Public License v3.0](https://github.com/vedantjain8/localhub/blob/dev/LICENSE)
