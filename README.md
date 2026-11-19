# Echo

Auditory rehabilitation for children with hearing aids or cochlear implants, used by a
parent together with the child. iOS 26, SwiftUI, strict MVVM.

This release is a fully clickable app running on **hardcoded dummy data**: there is no
database or backend. Everything below the ViewModels sits behind protocols, so real
storage can replace the dummy layer later without changing any screen.

## Getting started

1. Clone the repo and open `EchoProject.xcodeproj` in Xcode 26.
2. Run the app (⌘R). The splash screen has **Start** (onboarding) and **Skip to Home**.
3. Run the tests (⌘U): all 62 should pass.

## Project structure

```
EchoProject/
├── App/                    App entry, AppContainer, AppRouter, Route, RootView, tabs, RouteDestinationView
├── Core/
│   ├── Models/             Plain data types shared by every feature (frozen)
│   ├── DummyData/          Hardcoded content and progress, one file per area
│   ├── Repositories/       Data access protocols + in-memory implementations
│   ├── Services/           Audio, recording, speech and narration protocols + implementations
│   └── Scoring/            Pronunciation scoring for Speaking
├── DesignSystem/
│   ├── Tokens/             Colours, type scale, spacing from Figma
│   └── Components/         Stateless UI building blocks (buttons, cards, Speaking controls…)
├── Shared/                 Screens every exercise uses, each with View + ViewModel
│   ├── BeforeYouStart/     Intro shown before every exercise
│   ├── LeavePractice/      The one "Leave this practice?" overlay
│   ├── Completion/         The one completion screen (art per level in Model/)
│   ├── ExerciseLibrary/    Level library and named collections ("Story Hide & Seek")
│   └── ExerciseFrame/      ExerciseScaffold and .exerciseChrome(onBack:) for exercise screens
├── Features/
│   ├── Onboarding/         Splash, ChildProfile, ChoosePath, QuickCheck, QuickCheckResult
│   ├── Home/               ListeningHome, SpeakingHome
│   ├── Listening/          Detection, Differentiation, Identification, Comprehension
│   ├── Speaking/           Sounds, Words, Sentences, Conversation
│   └── Progress/           Overview, ListeningDetail, SpeakingDetail
└── Resources/              Asset catalog
EchoProjectTests/           Unit tests, one file per area
scripts/check-mvvm.sh       Architecture check, run before every pull request
```

Every screen folder (in `Features/` and `Shared/`) has the same shape:

```
Detection/
├── AppContainer+Detection.swift   ViewModel factory for this folder's screens
├── Model/                          Types only this folder uses (optional)
├── View/                           ListenAndRespondView.swift
└── ViewModel/                      ListenAndRespondViewModel.swift
```

## MVVM rules

| Layer | Responsibility | May import | Must not |
| --- | --- | --- | --- |
| View | Layout; shows ViewModel state; forwards user actions | SwiftUI | Contain logic, read data, call services |
| ViewModel | Screen state, scoring, validation, navigation decisions | Foundation, Observation | Import SwiftUI, touch `DummyData` |
| Model | Shape of the data | Foundation | Hold UI state or call services |
| Repository / Service | Provide data and device features behind a protocol | Foundation (+ AVFoundation, Speech in Core) | Know which screen calls it |

- A View holds its ViewModel as `@State private var vm` with `init(vm:)`, so the
  ViewModel is created once and keeps its state while the screen is on show.
- ViewModels are `@Observable @MainActor final class`es that receive repositories and
  services as protocols in `init`, built by the factory file in the same folder.
- Navigation goes through `AppRouter`; destinations are built only in `RouteDestinationView`.
- Exercises never draw their own leave dialog or completion screen:
  - back button → `router.presentLeavePractice()` (RootView shows the shared overlay)
  - finished → `progress.finish(…)`, then `router.go(.completion(exerciseId:outcome:))`
- Exercises open through Before you start: libraries call `router.go(.beforeYouStart(exerciseId:))`.
- `./scripts/check-mvvm.sh` must print "MVVM check passed." before a pull request is opened.

## Conventions

- Terminology: **Level** (not Stage); Speaking's third category is **Sentences**.
- Ids are kebab-case (`detection.hide-and-seek.animal`); asset names use the prefixes
  `img_`, `snd_`, `level_` and `ex_`, so artwork added under those names appears without code changes.
- `TODO(copy)` in `Core/DummyData/` marks text still to be copied exactly from Figma.
- Changes to `Core/Models/`, `App/Route.swift` or `App/AppContainer.swift` are agreed by the
  whole team before merging.

## Git workflow

- `main` always builds and passes tests; nobody pushes to it directly.
- Each developer has one long-lived branch, synced with `main` every morning and after
  every merge (`git fetch origin && git merge origin/main`).
- After each feature, open a pull request into `main`. Your review partner approves it and
  you merge with **Create a merge commit** (not squash); keep the branch for the next feature.
- Conflicts are fixed on your own branch, never on `main`.
- Milestone tags: `v0-freeze`, `v0.9` (feature freeze), `v1.0-review` (release).
