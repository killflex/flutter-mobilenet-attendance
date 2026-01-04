# Flutter MobileNet Attendance

A face recognition-based attendance system built with Flutter and MobileNet.

## Overview

This mobile application uses facial recognition to track attendance. It captures faces through the camera, generates embeddings using a MobileNet model (FaceNet), and stores user data locally in an SQLite database.

## Features

- Face registration with name and image capture
- Real-time face recognition for attendance tracking
- Local SQLite database for storing face embeddings and user information
- TensorFlow Lite integration for on-device ML inference

## Technical Stack

- Flutter for cross-platform mobile development
- TensorFlow Lite (FaceNet) for face recognition
- Google ML Kit for face detection
- SQLite for local data persistence
- Camera and image picker integration

## Setup

1. Install Flutter SDK
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Ensure TFLite models are in the `assets/` directory
5. Run `flutter run` to launch the app

## Database Schema

The app stores face data with the following structure:

- ID (auto-increment)
- Name
- Face embedding (as text)
- Image (as BLOB)

## Requirements

- Flutter 3.0 or higher
- Android 5.0+ / iOS 11.0+
- Camera permissions
