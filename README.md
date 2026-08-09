# Mantra Tuner 🕉️

A comprehensive, fully functional offline Flutter application for precise mantra tuning, chakra meditation, drone synthesis, and session analytics.

## Features

*   **Real-Time Tuner Engine**: Captures device microphone input and uses the YIN algorithm for precise, real-time pitch detection.
*   **Acoustic Drones & Synthesis**: Features gapless, fully adjustable acoustic Tanpura and bowed Sarangi drone loops, alongside custom pure sine wave generators that scale dynamically to match your target tuning.
*   **Chakra Meditation Studio**: Built-in 4-4-4 box breathing animations synced perfectly to a centralized background session timer, with automatic chakra frequency alignment.
*   **Session Analytics**: Utilizes `hive_flutter` for local, persistent storage of your meditation history, displaying lifetime trends for session counts, durations, and average pitch accuracy.

## Architecture

This app uses Clean Architecture with **Riverpod** for reactive state management across all services.

*   `lib/core`: App initialization, global services (`AudioService`, `InstrumentService`), and theme data.
*   `lib/features`: Independent, modular features (`tuner`, `chakra`, `meditation`, `analytics`).
*   `lib/common`: Reusable, responsive Flutter widgets.

## Running the App

1. Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
2. Clone this repository and run `flutter pub get` to fetch dependencies.
3. Connect your Android/iOS device (or emulator) and run:
   ```bash
   flutter run
   ```
