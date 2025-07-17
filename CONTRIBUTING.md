# Contributing to Fetosense Remote Flutter

Thank you for your interest in contributing to **fetosense_remote_flutter**! Your feedback, ideas, and code help us improve this product for everyone.

## 🧭 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
  - [Reporting Issues](#reporting-issues)
  - [Submitting Pull Requests](#submitting-pull-requests)
- [Code Style Guidelines](#code-style-guidelines)
- [Commit Message Format](#commit-message-format)
- [CI & Testing](#ci--testing)
- [Help](#help)

---

## 📜 Code of Conduct

Please read and follow our [Code of Conduct](https://github.com/CareNX-Innovations-Pvt-Ltd/fetosense_remote_flutter/blob/main/CODE_OF_CONDUCT.md) to ensure a welcoming and respectful community.

---

## 🚀 Getting Started

To contribute:

1. **Fork** the repository.
2. **Clone** your fork:
   ```bash
   git clone https://github.com/<your-username>/fetosense_remote_flutter.git
   cd fetosense_remote_flutter
   ```
3. **Set up Flutter** (make sure Flutter SDK is installed and available):
   ```bash
   flutter doctor
   flutter pub get
   ```
4. **Run the app** to verify everything works:
   ```bash
   flutter run -d chrome
   ```

---

## How to Contribute

### 🐞 Reporting Issues

If you find a bug or have a feature request, open an [issue](https://github.com/CareNX-Innovations-Pvt-Ltd/fetosense_remote_flutter/issues/new). Please include:

- A clear description
- Steps to reproduce (if applicable)
- Screenshots/logs if helpful
- Environment info (Flutter version, browser/device, OS)

### 🛠️ Submitting Pull Requests

1. Create a new branch from `main`:
   ```bash
   git checkout -b your-feature-name
   ```

2. Make your changes, write/modify tests if necessary.

3. Format and analyze:
   ```bash
   flutter format .
   flutter analyze
   ```

4. Commit and push:
   ```bash
   git commit -m "feat: add your feature summary"
   git push origin your-feature-name
   ```

5. Open a **Pull Request** on GitHub. Ensure:
   - Clear description of your change
   - Reference related issues (e.g. `Closes #123`)
   - All checks pass (CI, tests, formatting)

---

## 🧹 Code Style Guidelines

- Follow Flutter's default [Dart style guide](https://dart.dev/guides/language/effective-dart/style).
- Use `flutter format .` and `flutter analyze` before pushing.
- Keep widgets modular and reusable.
- Use `Cubit` or `Bloc` for state management where applicable.
- Name files according to feature (e.g., `login_view.dart`, `device_registration_cubit.dart`).

---

## Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>(<optional scope>): <description>
```

Examples:
- `feat(auth): add OTP verification`
- `fix: resolve crash on back navigation`
- `refactor: restructure bluetooth service class`
- `test: add unit tests for login view`

---

## 🧪 CI & Testing

- Write `unit` and `widget` tests when applicable.
- Test files should be placed under `test/` with matching folder structure.
- Run all tests with:
  ```bash
  flutter test
  ```

---

## Help

If you need help setting up or understanding the project:
- Open a [discussion](https://github.com/CareNX-Innovations-Pvt-Ltd/fetosense_remote_flutter/discussions)
- Contact the maintainers via issues

---

Thank you for being a part of the community 💙
