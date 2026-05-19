# MeshKit (with Pals) — CLAUDE.md

## What is this?

MeshKit is a family-oriented fork of [Meshtastic-Apple](https://github.com/meshtastic/Meshtastic-Apple), customized for off-grid camping and hiking in the Bay Area. It uses the "Meshtastic Mini" visual language — a warm, picture-book aesthetic inspired by Sago Mini apps.

## Build & Run

```bash
# Open in Xcode (requires Xcode 16+, iOS 17+ deployment target)
open Meshtastic.xcworkspace

# Build from command line (requires xcode-select pointed to Xcode.app)
xcodebuild -workspace Meshtastic.xcworkspace -scheme Meshtastic -sdk iphoneos build

# Run tests
xcodebuild -workspace Meshtastic.xcworkspace -scheme Meshtastic -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Branch Strategy

- `meshkit.with.pals` — main customization branch
- `main` — tracks upstream meshtastic/Meshtastic-Apple
- Periodically merge upstream/main into meshkit.with.pals
- One feature per branch, squash-merge into meshkit.with.pals

## Architecture

### Upstream (don't modify unless necessary)
- `Meshtastic/Accessory/` — BLE communication (AccessoryManager)
- `Meshtastic/Helpers/MeshPackets.swift` — protobuf packet handling
- `Meshtastic/Model/` — SwiftData entities (NodeInfoEntity, MessageEntity, etc.)
- `MeshtasticProtobufs/` — generated protobuf Swift code
- `Meshtastic/Router/` — navigation state management

### MeshKit additions (all new code goes here)
- `Meshtastic/MeshKit/` — root for all MeshKit-specific code
  - `Features/BuddyCheck/` — absence alerting
  - `Features/QuickMessages/` — canned one-tap messages
  - `Features/FamilyMode/` — simplified home screen
  - `Features/NodeProfiles/` — friendly names, colors, avatars
  - `Features/TrailBreadcrumbs/` — GPS track history overlay
  - `Features/KidView/` — locked-down view for kids
  - `Design/` — design tokens, colors, typography (Meshtastic Mini system)
  - `Shared/` — shared utilities, extensions, feature flags

## Conventions

### Code
- SwiftUI + MVVM, @Observable for new view models
- No business logic in views — views are purely declarative
- Feature-flag all MeshKit features via `MeshKitFeatureFlags`
- Group files by feature, not by type
- Prefer additive changes — don't restructure upstream code
- Keep new code in `Meshtastic/MeshKit/` to minimize merge conflicts

### Naming
- "Nodes" → "Pals" in user-facing UI
- "Channels" → "Clubhouses" in user-facing UI
- "Connect" tab → accessible in settings only
- Technical terms get friendly aliases (see DESIGN.md voice table)

### Design System (Meshtastic Mini)
- Canvas: #FFF8EE (warm cream, never pure white)
- Ink: #3D2E1F (warm brown, never pure black)
- Primary: #FF7A59 (Coral Sun)
- Secondary: #7FC8E8 (Sky — user's identity color)
- Typography: SF Rounded (all weights, minimum 17pt body)
- Corner radius: 28pt signature radius on cards/bubbles
- Shadow: single depth only — `0px 4px 12px rgba(61, 46, 31, 0.12)`
- No SF Symbols — custom illustrated icons with 2.5pt warm brown strokes
- No dark mode in v1 (Campfire Mode planned later)
- Light mode only, spring animations, no glassmorphism/gradients on UI
- Pal characters: bean shapes with dot eyes + smile + role accessory

### Testing
- Write tests for new feature logic (not views)
- Existing upstream tests should continue passing
