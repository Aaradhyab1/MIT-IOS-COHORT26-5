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
