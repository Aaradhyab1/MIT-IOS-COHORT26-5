# Echo

Auditory rehabilitation for children with hearing aids or cochlear implants, used by a
parent together with the child. iOS 26, SwiftUI, strict MVVM.

This release is a fully clickable app running on **hardcoded dummy data**: there is no
database or backend yet. Everything below the ViewModels sits behind protocols, so real
storage can replace the dummy layer later without changing any screen.

## Getting started

1. Clone the repo and open `EchoProject.xcodeproj` in Xcode 26.
2. Run the app (⌘R): a Splash placeholder appears; **Skip to Home** opens the three tabs.
3. Run the tests (⌘U): all 17 should pass.

## Project structure

```
EchoProject/
├── App/                 Composition root: app entry, AppContainer, AppRouter, routes, tab shell
├── Core/
│   ├── Models/          Plain data types shared by every feature (frozen)
│   ├── DummyData/       Hardcoded sample content and progress
│   ├── Repositories/    Data access protocols + in-memory implementations
│   └── Services/        Audio and recording protocols + dummy implementations
├── DesignSystem/
│   ├── Tokens/          Colours and type scale from the Figma design
│   └── Components/      Reusable UI pieces
├── Features/            One folder per feature; each screen = View + ViewModel + factory
│   ├── Onboarding/      Splash, child profile, path choice, Quick Check
│   ├── Home/            Listening and Speaking home screens
│   ├── Practice/        Before you start, completion, leave overlay (shared by all exercises)
│   ├── Listening/       ListenAndRespond, OddOneOut, PictureChoice
│   ├── Speaking/        ListenAndRecord, ReadAlong, Conversation
│   ├── Comprehension/   StoryPlayer, Ordering, Matching
│   ├── LevelLibrary/    Exercise list for any level, both tracks
│   └── Progress/        Overview, Listening and Speaking detail
└── Resources/           Asset catalog
EchoProjectTests/        Unit tests for models, repositories and ViewModels
scripts/check-mvvm.sh    Architecture check, run before every pull request
```

## MVVM rules

| Layer | Responsibility | May import | Must not |
| --- | --- | --- | --- |
| View | Layout; shows ViewModel state; forwards user actions | SwiftUI | Contain logic, read data, call services |
| ViewModel | Screen state, scoring, validation, navigation decisions | Foundation, Observation | Import SwiftUI, touch `DummyData` |
| Model | Shape of the data | Foundation | Hold UI state or call services |
| Repository / Service | Provide data and device features behind a protocol | Foundation | Know which screen calls it |

- Each screen is a `XxxView.swift` and `XxxViewModel.swift` pair in the same folder.
- ViewModels are `@Observable @MainActor final class`es that receive repositories and
  services as protocols in `init`, built by a factory method in the feature's
  `AppContainer+<Feature>.swift` file.
- Navigation goes through `AppRouter`; destinations are built only in `RouteDestinationView`.
- `./scripts/check-mvvm.sh` must print "MVVM check passed." before a pull request is opened.

## Conventions

- Terminology: the app uses **Level** (not Stage) in code and UI.
- Ids are kebab-case (`detection.hide-and-seek.animal`); asset names use the prefixes
  `img_`, `snd_`, `level_` and `ex_`, so artwork added under those names appears without code changes.
- `TODO(copy)` in `Core/DummyData/` marks text still to be copied exactly from the Figma design.
- Changes to `Core/Models/` are agreed by the whole team before merging.

## Git workflow

- `main` always builds and passes tests; nobody pushes to it directly.
- Work on `feature/<area>-<thing>` branches cut from the latest `main`.
- Open a pull request into `main` (under ~400 changed lines). Your review partner approves it;
  you merge it yourself with **Squash and merge**, then delete the branch.
- Conflicts are fixed on your own branch (merge `origin/main` into it), never on `main`.
- Milestone tags: `v0-freeze` (architecture frozen), `v0.9` (feature freeze), `v1.0-review` (release).
