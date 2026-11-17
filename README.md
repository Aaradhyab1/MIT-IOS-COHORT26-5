# Echo — iOS app (clickable build for the Nov 30 review)

Auditory rehabilitation for children with hearing aids or cochlear implants.
SwiftUI, strict MVVM, **hardcoded dummy data only** (no database, no backend).

## One-time setup (Dev A, today)

1. In Xcode 26: **File → New → Project → iOS App**.
   - Product Name: `Echo` · Interface: SwiftUI · Language: Swift
   - Testing System: Swift Testing · Storage: **None**
   - Save it anywhere; Xcode creates `Echo/Echo.xcodeproj`, `Echo/Echo/` and `Echo/EchoTests/`.
2. In Finder, delete the template files `Echo/Echo/EchoApp.swift`, `Echo/Echo/ContentView.swift`
   and `Echo/EchoTests/EchoTests.swift`.
3. Copy this package in:
   - everything inside `Echo/` here → into `Echo/Echo/`
   - everything inside `EchoTests/` here → into `Echo/EchoTests/`
   - `scripts/`, `README.md`, `.gitignore` → into the top `Echo/` folder (next to `Echo.xcodeproj`)
4. Move `Echo/Echo/Assets.xcassets` into `Echo/Echo/Resources/` (Xcode follows the move).
5. Target **Echo → Build Settings**: iOS Deployment Target `26.0`, Swift Language Version `Swift 5`.
6. Build (⌘B), run (⌘R), test (⌘U). You should see a Splash placeholder; **Skip to Home**
   opens the three tabs. All 17 tests should pass.
7. `git init`, push to GitHub, protect `main`, tag `v0-freeze`. Everyone clones from there.

New Xcode projects use synchronized folders, so any file added to these folders in
Finder or Xcode is picked up without touching `project.pbxproj`.

## Where things live

| Folder | What | Owner |
| --- | --- | --- |
| `App/` | `EchoApp`, `AppContainer` (builds services + ViewModels), `AppRouter`, `Route`, tab shell | A |
| `Core/Models/` | Frozen data shapes (Level, Exercise, ChildProfile, Outcome, …) | D (changes need all 4) |
| `Core/DummyData/` | All sample content and progress | D |
| `Core/Repositories/` | Content / Profile / Progress protocols + in-memory versions | D |
| `Core/Services/` | Audio / Recording protocols + dummy versions | C |
| `DesignSystem/` | Colours, type scale, shared components | A |
| `Features/Onboarding`, `Features/Home` | Splash → Quick Check → Home | A |
| `Features/Listening/` | Level libraries + ListenAndRespond, OddOneOut, PictureChoice | B |
| `Features/Speaking/` | ListenAndRecord, ReadAlong, Conversation | C |
| `Features/Progress/` + StoryPlayer | Progress tab, Comprehension stories | D |

## MVVM rules (checked on every PR)

- One `XxxView.swift` + one `XxxViewModel.swift` per screen, side by side.
- Views: layout only. No logic, no data access, no service calls.
- ViewModels: `@Observable @MainActor final class`, `import Foundation` + `import Observation` only,
  services passed into `init` as protocols, navigation via `router.go(...)`.
- Nothing in `Features/` touches `DummyData` or creates a service directly.
- Run `./scripts/check-mvvm.sh` before opening a PR. Any output = fix before merging.

## Conventions

- Branches: `feature/<area>-<thing>`; PRs under ~400 lines; merged by 9 pm daily.
- Exercise and asset ids are kebab-case; asset names follow `img_…`, `snd_…`, `level_…`, `ex_…`.
- `TODO(copy)` in DummyData = text still to be copied exactly from the PRECODING page in Figma.
- "Stage" is called **Level** everywhere in code and UI.
