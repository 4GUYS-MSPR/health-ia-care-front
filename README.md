# Health IA Care App

Flutter application for health coaching with AI-assisted features.

## Overview

This repository contains a cross-platform Flutter app (`android`, `ios`, `web`, `windows`, `macos`, `linux`) built with:

- `bloc` / `flutter_bloc` for state management
- `go_router` for navigation
- `get_it` for dependency injection
- `dio` for networking
- `flutter_dotenv` for runtime configuration
- `logging` for structured logs

## Prerequisites

- Flutter SDK compatible with Dart `^3.10.4`
- A configured Flutter environment (`flutter doctor` should be clean enough for your target platform)

## Getting Started

1. Install dependencies:

```bash
flutter pub get
```

2. Create your local environment file:

```bash
# PowerShell (Windows)
Copy-Item .env.example .env

# Bash
cp .env.example .env
```

3. Update `.env` values, especially:

- `API_URL`

4. Run the app:

```bash
flutter run
```

## Environment Variables

The app expects `.env` to be present and includes it as an asset.

Main variables from `.env.example`:

- `API_URL`: backend base URL
- `LOG_ROOT_LEVEL`: global log level
- `LOG_FEATURE_LEVELS`: optional per-feature log levels
- `LOG_CONSOLE_ENABLED`: enable console logs
- `LOG_FILE_ENABLED`: enable file logs (non-web targets)
- `LOG_FILE_PATH`: relative path for log file storage

## Localization

Localization files live in `l10n/` (`app_en.arb`, `app_fr.arb`).

To regenerate localizations:

```bash
flutter gen-l10n
```

## Quality Checks

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Project Structure

```text
lib/
	app/                # App bootstrap, router, service locator
	core/               # Shared utilities, errors, networking, theme, logging
	features/           # Domain features (authentication, health, ...)
	l10n/               # Generated localization code
	main.dart           # Entry point
```

## Build Web with Docker

The repository includes a `Dockerfile` that builds the Flutter web app and serves it with Nginx.

Build image:

```bash
docker build -t health-ia-care-web .
```

Run container:

```bash
docker run --rm -p 8080:80 health-ia-care-web
```

Then open `http://localhost:8080`.

## Useful Commands

```bash
flutter clean
flutter pub get
flutter run
flutter analyze
flutter test
flutter build web
```
