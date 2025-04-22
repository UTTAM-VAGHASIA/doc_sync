# Project Rules
---

# 🧠 DocSync AI Project Rules  
> For Flutter 3.29.3 • Dart 3.7.2 • All Platforms • MVC + GetX Vibes  
*Let these be the rules, etched in digital stone, guiding both code and AI alike...*

---

## 1. ⚙️ Framework & Environment  
- **Flutter Version**: `3.29.3` — lock it in; no downgrades.
- **Dart SDK**: `^3.7.2`, with **null safety enabled**.
- Target **all platforms**: Android, iOS, Web, macOS, Linux, and Windows.
- All code must **respect null safety** and be free from deprecated APIs.

---

## 2. 📦 Dependencies: The Approved Arsenal  
Only the following dependencies are allowed (from your `pubspec.yaml`):

> Utility: `intl`, `lottie`, `shimmer`, `clipboard`, `image_picker`, `url_launcher`, `connectivity_plus`, `cached_network_image`, `package_info_plus`, `logger`, `device_preview`, `open_file`, `flutter_markdown`, `path_provider`, `dynamic_path_url_strategy`, `permission_handler`, `flutter_secure_storage`  
> Web-specific: `http`, `data_table_2`  
> State Management: `get`, `get_storage`  
> UI & Icons: `cupertino_icons`, `iconsax`, `google_fonts`, `flutter_svg`, `flutter_launcher_icons`

**🚫 Forbidden Packages:**  
- No use of `provider`, `bloc`, or `riverpod` – this project is **GetX-only**.  
- No **external state management** tools beyond GetX.
- Do **not** use platform-specific APIs unless behind a platform guard.

---

## 3. 🧪 Testing (for Future You)
While testing isn't set up *yet*, keep these in mind:
- All future tests must use `flutter_test`.
- Write testable, modular code — no monolith widgets.
- Use `mockito` or `get_test` when mocking is required (optional for now).
- **Do not** skip writing tests for business logic.

---

## 4. 🧬 Architecture Rules (a.k.a. The Sacred Structure)
- Stick to your **custom MVC architecture**. That means:  
  - 🧠 **Models** hold data  
  - 🧩 **Views** display UI (widgets)  
  - 🧙 **Controllers** handle logic and route flow
- Keep code **organized by feature**, not type. (e.g., `lib/features/auth/view`, `lib/features/auth/controller`)
- Every screen should have a **corresponding controller**.

---

## 5. 🚫 Forbidden Practices  
- **NEVER** use `setState()` outside of development/testing hacks.
- No `BuildContext` access inside controllers. Use GetX utilities like `Get.find()` or `Get.put()` responsibly.
- Don’t use global variables or static state unless absolutely necessary.
- Never hardcode sensitive strings (API keys, tokens). Use `flutter_secure_storage` or environment configs.
- All async functions must use `await` – no `.then()` callbacks unless streaming.

---

## 6. 🔍 Linting & Formatting
- Follow `flutter_lints: ^5.0.0` rules.
- Use `dart format .` regularly.
- All files must include proper doc comments if logic is non-trivial.

---

## 7. 💡 AI Assistant Instructions (if integrated)
- Follow **this rulebook** strictly when suggesting code.
- Never suggest `setState`, even if asked.
- Always prioritize **GetX** practices and match the project’s MVC layout.
- Prefer clarity over cleverness; use **explicit widget trees**, not overly abstracted helper functions unless reused.

---

Ohhh you're *that* kind of organized — you’ve got `build_debug` and `build_release` scripts chilling in the root like mini bodyguards for your build process. I respect it. Real devs automate the boring stuff.

You're using **FVM** too? That’s *chef's kiss* — now we’re playing the game right.

Let’s tack this onto your rulebook, nice and clean, so your AI (or any curious contributor) doesn’t go rogue with raw `flutter run` or some chaotic manual builds.

---

## 🛠️ 8. Build & Run Commands

### 🎮 For Development & Testing:
> Always use **FVM-managed Flutter**.  
> Run your project using the following commands:

- **Debug Mode (default device)**  
  ```bash
  fvm flutter run
  ```

- **Debug on Chrome**  
  ```bash
  fvm flutter run -d chrome
  ```

- **Debug on Windows**  
  ```bash
  fvm flutter run -d windows
  ```

**🚫 NEVER** use `flutter run` directly without `fvm`.

---

### 📦 For Building the Project:

Custom build scripts are already defined at the root level.  
All builds must use these **only**:

- **Debug Build**  
  ```bash
  ./build_debug
  ```

- **Release Build**  
  ```bash
  ./build_release
  ```

AI tools and contributors must **not bypass these scripts**. They're there for a reason — maybe you're setting up extra flags, running cleanup tasks, or injecting environment configs.

---