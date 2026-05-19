# Meshtastic Mini — DESIGN.md

> A fork of [Meshtastic-Apple](https://github.com/meshtastic/Meshtastic-Apple) reimagined in the visual language of [Sago Mini](https://sagomini.com/) apps. Off-grid LoRa mesh radio messaging for iOS, iPadOS, and macOS — restyled as a warm, hand-drawn picture book where every node is a smiling little pal.

---

## Overview

Meshtastic Mini takes a piece of survival-radio infrastructure software — meant for hikers, ham operators, and disaster-prep crowds — and reskins it in the visual register of a preschool app. The base canvas is warm cream `{colors.canvas}` (#FFF8EE), never clinical white. Ink is warm dark brown `{colors.ink}` (#3D2E1F), never pure black. Every primary surface is rounded generously (`{rounded.xl}` 28px on cards, fully circular on buttons where possible).

The system runs **SF Rounded** at heavy weights for everything UI-facing, with a single hand-drawn display face `{type.display.family}` (Quicksand Bold as the available stand-in, or a custom rounded face like Filson Soft or Mali) used sparingly for headlines that should feel storybook-narrated. Body copy is generous — 17pt minimum, 1.45 line height — because nothing on this screen is meant to be skimmed.

The signature visual move is **anthropomorphism of infrastructure**. A mesh node is not a row in a table; it is a bean-shaped character with two dot eyes, a small smile, and one defining accessory (a postal hat for routers, a backpack for clients, a long neck for repeaters). Signal strength is not a dBm readout; it is a cluster of floating hearts or radio-wave puffs above the pal's head. Battery is not a percentage bar; it is a battery-shaped character whose face changes from beaming (full) to sleepy (low) to one-eye-open (critical).

The brand voltage is **Coral Sun** `{colors.primary}` (#FF7A59) reserved for primary CTAs, the "Send" affordance, and the active state of the tab bar. Used scarcely — the cream + characters do the heavy lifting. A secondary accent **Sky** `{colors.secondary}` (#7FC8E8) carries the "you" identity throughout (your speech bubbles, your map marker, your character).

The "machined precision" of the original Meshtastic app is replaced with a **picture-book voice**. Distances are phrased "about 1.2 miles away," not "1.93 km." Last-heard is "saw them 2 minutes ago," not "2m ago." Encryption keys are "Secret Handshakes." Settings are pockets inside "My Backpack." But the underlying information density of a real off-grid tool is preserved — a serious user in the woods at 11pm still needs to read signal quality and last-heard time at a glance, even if those readouts are now hearts and friendly phrases.

This is **light mode only** for v1. A future "Campfire Mode" dark variant for nighttime use is planned but out of scope for this document.

---

## Color Palette

The palette is **soft and saturated**, not pastel-washed-out and not screamy. Every color earns its place by mapping to a feeling: cream is "home," coral is "send/go," sky is "you," mint is "good signal/healthy," butter is "warmth/highlight," lavender is "secrets/encryption."

### Canvas & Ink

- **Canvas** `{colors.canvas}` — #FFF8EE — warm cream. The default page surface for every screen. Never use pure white anywhere in the app.
- **Canvas Soft** `{colors.canvas-soft}` — #FBEFDB — a slightly deeper cream for grouped-list backgrounds and the area behind cards, providing gentle contrast.
- **Surface Card** `{colors.surface-card}` — #FFFFFF — the only legitimate use of pure white in the system, and only inside elevated card surfaces sitting on Canvas Soft.
- **Ink** `{colors.ink}` — #3D2E1F — warm dark brown for all primary body copy and display type. Pure black `#000000` never appears.
- **Ink Soft** `{colors.ink-soft}` — #7A6755 — secondary copy, metadata, "saw them 2 minutes ago" timestamps, settings sub-labels.
- **Ink Whisper** `{colors.ink-whisper}` — #B8A691 — placeholder text, disabled labels, separator stroke color.

### Brand Voltages

- **Coral Sun (Primary)** `{colors.primary}` — #FF7A59 — the single brand action color. All primary CTAs ("Send a note," "Make a new friend," tab bar active icon). Press shifts to `{colors.primary-active}` (#E55F3F).
- **Sky (Secondary / You)** `{colors.secondary}` — #7FC8E8 — represents the user throughout the app. Your speech bubbles, your map marker, your pal's color. Press shifts to `{colors.secondary-active}` (#5FB0D4).
- **Butter Highlight** `{colors.highlight}` — #FFD66B — used behind "new!" stickers, notification dot, and the glow halo around the active pal on the Friend Map.

### Pal Palette (Friend Colors)

Each pal is auto-assigned one of six character colors based on a hash of their node ID. These are NOT semantic colors — they are identity colors, and no UI meaning should be attached to which color a pal is.

- **Pal Coral** `{colors.pal-coral}` — #FF9B7A
- **Pal Sky** `{colors.pal-sky}` — #94D4ED  *(reserved — only used for "you")*
- **Pal Mint** `{colors.pal-mint}` — #9BD9B8
- **Pal Butter** `{colors.pal-butter}` — #FFD98F
- **Pal Lavender** `{colors.pal-lavender}` — #C9B8E8
- **Pal Peach** `{colors.pal-peach}` — #FFB89B
- **Pal Sage** `{colors.pal-sage}` — #B8CFA0

### Semantic / Status Colors

These are the **only** colors that carry meaning. They appear in signal hearts, battery faces, alert stickers, and connection status pills.

- **Healthy Mint** `{colors.success}` — #6BC68F — good signal (3+ hearts), full battery, encrypted-and-verified, connected.
- **Warm Butter** `{colors.warning}` — #F5B547 — fair signal (2 hearts), medium battery, "haven't seen them in a while," unverified key.
- **Soft Coral** `{colors.danger}` — #E8654F — poor signal (1 heart), low battery, connection lost, error sticker. Distinct from `{colors.primary}` — slightly desaturated, more rust-ward.
- **Cloud Grey** `{colors.muted}` — #C9BFB0 — offline, unknown, no-data state.

### Themed Clubhouse Backgrounds

Channels ("Clubhouses") have themed background tints applied at 8% opacity over `{colors.canvas}`. These are not the channel's primary surface color — the cream stays — but a wash that distinguishes the room.

- **Treehouse** `{colors.clubhouse-treehouse}` — #9BD9B8 wash
- **Beach** `{colors.clubhouse-beach}` — #FFD98F wash
- **Campfire** `{colors.clubhouse-campfire}` — #FF9B7A wash
- **Spaceship** `{colors.clubhouse-spaceship}` — #C9B8E8 wash
- **Mountain** `{colors.clubhouse-mountain}` — #94D4ED wash
- **Default Clubhouse** — no wash. Pure `{colors.canvas}`.

### Notes on the palette

Pure black `#000000` and pure white `#FFFFFF` outside of card surfaces are **forbidden**. They read clinical against this system. Everything is warm. Stroke colors on illustrations are always `{colors.ink}` (warm brown), never black.

Coral `{colors.primary}` and Coral `{colors.danger}` are intentionally close but distinct. The danger color is desaturated and rust-leaning so a "low battery" sticker doesn't read as a primary CTA.

The Pal Sky `{colors.pal-sky}` is reserved exclusively for the user's own character. No other pal can be Sky. This is how users find themselves at a glance on the Friend Map.

---

## Typography

The system runs a **two-family stack**: SF Rounded for everything UI, and a single rounded display face for headlines that should feel storybook-narrated. No monospace. No serif. Nothing in the app should feel like it was set on a computer.

### Font Families

- **Display** `{type.display.family}` — "Mali", "Filson Soft", or as a system fallback: **SF Rounded** at weight Black. Used for screen titles, onboarding panel headlines, and the names above pal portraits. Sparingly — never for body copy.
- **UI** `{type.ui.family}` — **SF Rounded**. The workhorse. Used for everything else: nav bar titles, button labels, list rows, settings, message bubbles, timestamps.
- **Fallback stack** — `-apple-system-rounded, "SF Pro Rounded", "Avenir Next Rounded", system-ui, sans-serif`. Never fall back to Helvetica, Arial, or anything geometric — the rounded terminals are non-negotiable.

### Weights in use

- **Black (900)** — display headlines only.
- **Bold (700)** — screen titles, pal names, button labels, tab bar active label.
- **Semibold (600)** — list-row primary text, message-bubble body, section headers.
- **Medium (500)** — secondary copy, "saw them 2 minutes ago" metadata.
- **Regular (400)** — never used. The system always carries at least medium weight; nothing in this app should feel thin.

### Scale

- **Display XL** `{type.display-xl}` — 40px / 1.1 / Black — onboarding hero ("Hello, friend!")
- **Display L** `{type.display-l}` — 32px / 1.15 / Black — screen-level welcome titles (the giant "Pals" header on the list screen).
- **Title** `{type.title}` — 24px / 1.2 / Bold — pal-detail name, sheet titles.
- **Heading** `{type.heading}` — 20px / 1.25 / Bold — list-row primary text (pal name in row), section dividers.
- **Body** `{type.body}` — 17px / 1.45 / Semibold — message bubbles, settings rows, default reading size. **Minimum body size in the app.**
- **Caption** `{type.caption}` — 15px / 1.4 / Medium — timestamps, "saw them 2 minutes ago," metadata, hint text below inputs.
- **Sticker** `{type.sticker}` — 13px / 1.0 / Bold — used **only** inside stickers and badges (e.g., "NEW!", "3").

### Tracking and line-height

- **No negative tracking, anywhere.** Rounded faces don't take tightening well. Default tracking everywhere.
- **Positive tracking +1.0** on the tiny `{type.sticker}` size only, to keep "NEW!" readable on a coral sticker background.
- Line heights are deliberately generous — 1.45 on body, 1.4 on caption. The app is meant to feel uncramped, like a picture book.
- **No uppercase.** Sentence case only, everywhere. Even on stickers, "NEW!" is the only allowed all-caps token, and that's because it's a single word with an exclamation point and reads as a sound effect, not a label.

---

## Iconography

**SF Symbols are forbidden.** The single largest deviation from a standard iOS app — every icon in Meshtastic Mini is custom-illustrated, hand-drawn, with visible imperfection.

### Style rules

- **Stroke weight** — uniform 2.5pt strokes on all icons at 24pt nominal size, scaled proportionally at other sizes. No thin hairlines.
- **Stroke color** — always `{colors.ink}` (warm brown), never black, never the icon's fill color.
- **Corner treatment** — rounded line caps and rounded line joins always. No mitered corners.
- **Fill** — soft saturated color (one of the Pal Palette colors), at full opacity. No gradients on icons.
- **Wobble** — strokes should have a slight hand-drawn imperfection. Perfect Bézier curves read as clinical. A small amount of irregularity in stroke width (+/- 0.3pt) and path smoothness reads as warmth.
- **Two-dot-and-smile rule** — any icon representing a "thing that does something" (a node, a battery, a signal tower, an envelope) gets two small dot eyes and a tiny smile. Static objects (a map pin, a star, a checkmark) do not.

### Icon families

- **Pal Characters** — bean-shaped body, two dot eyes, small smile, one defining accessory. Role-derived (see "Characters" section).
- **Status Glyphs** — hearts (signal), radio-wave puffs (also signal, alternate metaphor), stars (favorite), clouds (offline), little flag (saved location).
- **Navigation** — tab bar uses friendly-house (Home/Pals), little-map (Friend Map), speech-bubble-with-tail (Clubhouses), backpack (Settings).
- **Actions** — paper-airplane (Send), magnifying-glass-character (Search/Scan), wrapped-present (New device found), padlock-character (Secret Handshake), gift-tag (Add favorite).

---

## Components

### Buttons

#### Primary Button — "The Coral Pill"

The single most important affordance in the app. Used for "Send a note," "Make a new friend," "Let's go," "Save."

- **Shape** — fully circular ends (`{rounded.full}`), height `{spacing.12}` (48pt), horizontal padding `{spacing.6}` (24pt).
- **Fill** — `{colors.primary}` (Coral Sun).
- **Label** — `{type.body}` weight Bold, color `{colors.surface-card}` (white).
- **Icon** — optional, custom-illustrated, 20pt, leading the label with `{spacing.2}` (8pt) gap.
- **Press state** — fill shifts to `{colors.primary-active}`, scale 0.96, spring back on release. Soft "pop" haptic.
- **Disabled** — fill `{colors.ink-whisper}`, label `{colors.canvas-soft}`. No coral at rest if not actionable.

#### Secondary Button — "The Cream Pill"

Used for cancel, dismiss, secondary actions on dialogs.

- **Shape** — fully circular ends, same dimensions as primary.
- **Fill** — `{colors.canvas-soft}`.
- **Border** — 2pt `{colors.ink-whisper}`.
- **Label** — `{type.body}` weight Bold, color `{colors.ink}`.
- **No icon by default.**

#### Tertiary / Text Button

- **Shape** — no fill, no border. Just text.
- **Label** — `{type.body}` weight Bold, color `{colors.primary}`. Underline appears on press.

#### Icon Button — "The Round One"

Floating action buttons, message-send button, scan button.

- **Shape** — perfect circle, diameter 56pt for primary FAB, 44pt for in-line.
- **Fill** — `{colors.primary}` for primary action (send), `{colors.canvas-soft}` with `{colors.ink}` icon for secondary (cancel, close).
- **Shadow** — soft, warm, single-direction: `0px 4px 12px rgba(61, 46, 31, 0.12)`. No multi-layer Material shadows.
- **Press state** — scale 0.92, spring back. Soft pop haptic on FAB only.

### Cards — "The Pal Card"

The primary content surface throughout the app. Used in the Pals list, the Bluetooth-scan results, the channel list.

- **Shape** — `{rounded.xl}` (28pt) corner radius. The roundness is the single biggest visual signal of "this is Meshtastic Mini, not Meshtastic."
- **Fill** — `{colors.surface-card}` (white) when sitting on `{colors.canvas-soft}`. Reverses to `{colors.canvas-soft}` when sitting on white (rare).
- **Shadow** — same soft single-direction shadow as the icon button. Never use elevation layering — there is exactly one shadow depth in the system.
- **Padding** — `{spacing.5}` (20pt) on all sides.
- **Internal layout** — pal character avatar leading (64pt circle), text stack center (name + status), trailing element (signal hearts cluster, time, or chevron).
- **Press state** — entire card scales to 0.98 and springs back. Background tint shifts toward `{colors.canvas-soft}` momentarily.

### Speech Bubbles — "The Note"

Message bubbles in Clubhouses. The single most ambitious component in the system because they need to feel like cartoon speech balloons without becoming illegible.

- **Shape** — `{rounded.xl}` (28pt) on three corners, with a small rounded tail on the fourth corner pointing toward the sender's avatar. Tail is asymmetric, hand-drawn-feeling.
- **From-you bubble** — fill `{colors.secondary}` (Sky), text color `{colors.ink}`. Tail on bottom-right. Aligned right.
- **From-pal bubble** — fill `{colors.canvas-soft}`, text color `{colors.ink}`. Tail on bottom-left. Aligned left.
- **Reaction stickers** — small `{rounded.full}` pills hanging off the bottom-right of the bubble, overlapping slightly. Heart, thumbs-up-pal, star, exclamation point.
- **Timestamp** — `{type.caption}` color `{colors.ink-soft}`, placed beneath the bubble, never inside it.
- **Sender pal avatar** — 32pt circle beside the bubble, only shown on the first bubble of a contiguous sequence from the same sender. Subsequent bubbles in a run hide the avatar to reduce noise.

### Signal Indicator — "Hearts"

How signal strength is communicated throughout the app. Replaces all RSSI/SNR numbers in the surface UI. Numbers are available in pal detail for users who want them.

- **3 hearts** — `{colors.success}` (mint), good signal.
- **2 hearts** — `{colors.warning}` (butter), fair.
- **1 heart** — `{colors.danger}` (coral), poor.
- **0 hearts** (replaced by a small cloud glyph) — `{colors.muted}`, offline / unheard.
- **Layout** — hearts arc gently above the pal character's head when shown on the Friend Map. In list rows, they sit as a horizontal cluster in the trailing slot.
- **Subtle bob animation** — the hearts gently rise and fall, 0.5pt amplitude, 2.5s period, slightly offset between hearts. Pause when scrolling.

### Battery — "The Battery Pal"

A small battery-shaped character with two dot eyes and an expression that changes with charge level.

- **Full (80–100%)** — beaming smile, full mint fill `{colors.success}`.
- **Healthy (40–79%)** — small smile, mint fill at 75% width.
- **Tired (15–39%)** — neutral mouth, butter fill `{colors.warning}` at 35% width.
- **Sleepy (5–14%)** — one eye closed, coral fill `{colors.danger}` at 15% width.
- **Critical (<5%)** — one-eye-open looking sideways, coral fill at 5% width, gentle wobble animation.
- **Placement** — top of Pal Detail, beside the pal's portrait. Also a smaller version on the Connect screen for "your" device.

### Stickers — "Not Badges"

The system has stickers, not badges. The difference is tonal: a badge is an alert; a sticker is decoration that happens to carry information.

- **Unread count sticker** — `{colors.primary}` fill, `{colors.surface-card}` text, `{type.sticker}`, fully circular if single-digit, pill-shaped if 2+. Placed overlapping the top-right of a clubhouse row or pal avatar.
- **NEW! sticker** — `{colors.highlight}` (butter) fill, `{colors.ink}` text, `{type.sticker}`, slightly rotated -8° for hand-placed feel. Used on a clubhouse the user hasn't visited yet or a new pal that just joined.
- **Status stickers** — small illustrated stickers (heart, star, exclamation, sleepy moon) used to denote favorite, popular, important, asleep. Never use a text sticker where an illustrated sticker fits.

### Input Fields — "The Speech Box"

Message composer, search bar, name field.

- **Shape** — `{rounded.full}` (pill) for the message composer and search; `{rounded.lg}` (16pt) for multi-line fields like the pal name editor.
- **Fill** — `{colors.canvas-soft}` at rest, `{colors.surface-card}` when focused.
- **Border** — 2pt `{colors.ink-whisper}` at rest, `{colors.primary}` when focused. The border thickens — this is a strong, hand-drawn-feeling stroke, not a hairline.
- **Padding** — horizontal `{spacing.5}` (20pt), vertical `{spacing.3}` (12pt).
- **Placeholder** — `{type.body}` weight Medium (one step lighter than typed text), color `{colors.ink-whisper}`.
- **Send button** — when used inside the message composer, the trailing icon button is the paper-airplane-character on a `{colors.primary}` fill, 36pt circle, inset 6pt from the field's trailing edge.

### Tab Bar — "The Bottom Shelf"

Custom tab bar replacing the standard SwiftUI TabView chrome.

- **Background** — `{colors.surface-card}` with the same single-direction shadow as cards, but flipped (shadow above the bar, not below). Floats 12pt above the screen bottom.
- **Shape** — `{rounded.xl}` (28pt) corners, full width minus 16pt insets.
- **Tab items** — four tabs: Pals (friendly-house), Friend Map (little-map), Clubhouses (speech-bubble), My Backpack (backpack). Each is a custom illustrated icon, 28pt.
- **Active state** — icon fill shifts from `{colors.ink-soft}` to `{colors.primary}`. Label appears beneath the icon in `{type.caption}` weight Bold, color `{colors.primary}`. Inactive tabs show icon only, no label.
- **Press** — soft spring, icon scales 1.1 momentarily on selection.

---

## Spacing

The system runs on an **8pt grid with a 4pt half-step**. Every spacing token is a multiple of 4pt. The system is generous — Meshtastic Mini uses more whitespace than its parent app by roughly 1.4×.

- `{spacing.1}` — 4pt — micro gaps (between a sticker and what it's attached to).
- `{spacing.2}` — 8pt — tight gaps (icon-to-label inside a button).
- `{spacing.3}` — 12pt — small (gap between message bubbles in a contiguous run).
- `{spacing.4}` — 16pt — default (horizontal screen padding on iPhone).
- `{spacing.5}` — 20pt — card internal padding.
- `{spacing.6}` — 24pt — section internal padding, button horizontal padding.
- `{spacing.8}` — 32pt — gap between sections.
- `{spacing.10}` — 40pt — gap between major page regions (above a screen title from the nav bar).
- `{spacing.12}` — 48pt — primary button height; rare in pure spacing use.
- `{spacing.16}` — 64pt — pal avatar diameter in list rows; major hero spacing.

**Horizontal screen padding** on iPhone is `{spacing.4}` (16pt). **List row vertical padding** is `{spacing.5}` (20pt) top and bottom — generous, because every row carries a character. **Between cards in a list**, gap is `{spacing.3}` (12pt). **Major section gaps** are `{spacing.8}` (32pt).

---

## Layout

### iPhone

- Content caps at full width minus `{spacing.4}` (16pt) horizontal padding.
- The custom tab bar floats 12pt above the safe area bottom, full width minus `{spacing.4}` (16pt) horizontal insets.
- Nav bar uses large-title style: screen title in `{type.display-l}` (32pt Black), left-aligned, with `{spacing.10}` (40pt) of breathing room above the first content card.
- List rows are full-width cards (no zero-edge separators — every row is a discrete card with shadow).

### iPad

- Two-column split: Pals list (320pt fixed) on the left, detail (flexible) on the right.
- The illustrated Friend Map expands to fill the detail pane and feels most at home on iPad.
- Tab bar moves to the leading edge as a vertical sidebar, same `{rounded.xl}` floating-shelf treatment.

### macOS

- Same sidebar pattern as iPad. The Friend Map becomes the centerpiece — designed at iPad+ sizes, this is where the illustrated terrain has room to breathe.
- Window background is `{colors.canvas-soft}` (the deeper cream) so floating card surfaces in `{colors.surface-card}` (white) still read as elevated.

### Responsive behavior

- Below 380pt width (small iPhones, partial-width iPad slide-overs): pal character avatars in list rows shrink from 64pt to 48pt; signal hearts cluster compresses from horizontal to vertical stack.
- The Friend Map is the only screen with a real adaptive challenge: on phone it collapses real-coordinate accuracy in favor of "are they near me / far / very far" zones. On iPad it shows a wider illustrated terrain with real spatial relationships.

---

## Characters

The most distinct part of the system. Documented as a component family because every node on the mesh is rendered as a character.

### Anatomy of a Pal

- **Body** — a vertical bean shape, roughly 1.4× tall as wide. Single-color fill from the Pal Palette.
- **Stroke** — 2.5pt `{colors.ink}` warm brown, hand-drawn-feeling (slight wobble in stroke width).
- **Eyes** — two solid `{colors.ink}` dots, equally spaced, in the upper third. No eyelashes, no pupils, no whites. The dots are the eyes.
- **Mouth** — a small upward curve, single stroke, `{colors.ink}`. Width about 1/3 of the body width. Always smiling at rest; alternate expressions exist for status (sleepy, surprised, sad-but-encouraging) but are never used for negative states the user could feel attacked by.
- **Accessory** — exactly one defining detail per role. Never two. The accessory is the role.
- **Color** — assigned from the Pal Palette by hashing the node ID. Stable across sessions — the same node ID always produces the same pal color.

### Roles and their accessories

- **Client (default node)** — a small backpack on the back, peeking over the shoulder.
- **Client Mute (receive-only)** — earmuffs, both ears.
- **Router** — a postal cap with a small star on the brim. (Routers carry messages.)
- **Router Client** — postal cap + small backpack. The "carries their own and helps others" pal.
- **Repeater** — a giraffe-like long neck. (Stretches to reach far.) This is the only role that breaks the bean silhouette.
- **Tracker** — binoculars hanging around the neck.
- **Sensor** — a small antenna with a heart at the tip.

### The User's Pal

- **Color** — always `{colors.pal-sky}`. The user is the only Sky pal in the system.
- **Accessory** — defaults to a small house badge ("you're home"). Customizable in My Backpack.
- **Map marker** — same character, with a subtle butter glow halo `{colors.highlight}` at 30% opacity behind it.

### Animation

- **Idle** — gentle bob, 1.5pt vertical amplitude, 3s period. Slight phase offset between pals on the same screen so they don't all bob in unison (that would feel mechanical).
- **Speaking / sending** — small wave above the head, like a single "blip" rising and fading, 600ms duration.
- **Receiving** — three radio-wave puff arcs expanding from the body, 800ms duration, fade as they expand.
- **Lost connection** — the pal slowly sinks 4pt and the smile relaxes to a small straight line. Hearts above the head fade to a small cloud. Returns to normal when reconnected.

---

## Voice

The voice of the UI is **picture-book narrator**, not technical reference. Concrete reframings of every Meshtastic concept:

| Meshtastic term | Meshtastic Mini term |
|---|---|
| Node | Pal / Friend |
| Mesh network | The neighborhood |
| Channel | Clubhouse |
| Channel encryption key | Secret Handshake |
| RSSI / SNR | Hearts (or "how clearly we hear them") |
| Hop count | "Hopped through 2 friends to get here" |
| Last heard | "Saw them 2 minutes ago" |
| Battery level | The Battery Pal's mood |
| Bluetooth pairing | "Make a new friend!" |
| Distance | "About 1.2 miles away" (always rounded, always approximate) |
| Position broadcast | "Sharing where you are" |
| Settings | My Backpack |
| Region (frequency band) | "Where in the world" |
| GPS lock | "Found yourself!" |

The voice is **never condescending**. The app is for grown-ups using a kid-app aesthetic — distances are still real distances, signal is still real signal. The voice is warm, not cutesy-baby-talk. "Saw them 2 minutes ago" is friendly; "Saw them 2 minutes ago, silly!" is wrong.

Error states are **kind**. "I can't find any pals nearby — want to try moving outside?" not "Error: No nodes detected." The app never blames the user, and never blames the hardware too dramatically — the most negative the voice gets is "something seems off."

---

## Motion

- **Default easing** — spring physics. Stiffness 200, damping 22 as the system default. Never use cubic-bezier curves; every transition in this app is a spring.
- **Press feedback** — every interactive element scales to 0.96 (or 0.92 for icon buttons) on press, springs back on release. ~150ms total.
- **Screen transitions** — push from trailing edge with a small overshoot. Sheets rise from below with the same spring.
- **Pal idle bobbing** — see Characters section. Always running, never paused except during scroll (perf).
- **Send confirmation** — when a message sends, the paper-airplane icon button briefly transforms: the airplane glyph flies up and to the right, off the button, while the new message bubble appears in the conversation. ~500ms choreography.
- **New pal arrival** — when a node first appears on the network, its card slides in from the leading edge with a small bounce and a butter "NEW!" sticker appears with a slight rotation.
- **Haptics** — soft pop on primary button press, light tick on tab change, success notification haptic on message-sent confirmation. Never use error notification haptic — too aggressive for the brand voice.

---

## Tokens

### Radius

- `{rounded.sm}` — 8pt — used only on stickers and the smallest illustrated elements.
- `{rounded.md}` — 16pt — multi-line input fields, small alert cards.
- `{rounded.lg}` — 20pt — secondary surfaces.
- `{rounded.xl}` — 28pt — the system default for primary cards, the tab bar, message bubbles. **This is the signature radius of the system.**
- `{rounded.full}` — 9999pt — fully circular: primary buttons, the message composer, pill stickers.

### Shadow

- `{shadow.soft}` — `0px 4px 12px rgba(61, 46, 31, 0.12)` — the one and only elevation shadow in the system. Warm tinted because the alpha is on warm brown, not black. Used on cards, icon buttons, the tab bar, and the FAB. No `{shadow.md}` or `{shadow.lg}` — the system has one shadow depth.

### Stroke

- `{stroke.thin}` — 1pt — never used in UI surfaces, reserved for hairline separators inside grouped lists if absolutely required.
- `{stroke.default}` — 2pt — input field borders, secondary button borders.
- `{stroke.bold}` — 2.5pt — illustration stroke weight, the visual signature.

---

## What the system isn't

A short list of moves that would be tonally wrong, useful as guardrails:

- **No glassmorphism, no Liquid Glass effects.** The system is matte and warm. Translucency reads cold.
- **No gradients on UI surfaces.** Flat fills only. (Gradients are acceptable inside illustrated terrain on the Friend Map, where they evoke painted picture-book skies.)
- **No skeuomorphic textures.** No paper textures, no felt, no woodgrain. The warmth comes from color and shape, not from imitating physical materials.
- **No emoji as iconography.** Emoji are user-supplied reaction content only. The app's own glyphs are all custom-illustrated.
- **No iOS-default SF Symbols visible anywhere.** Including in alerts and system sheets where possible.
- **No pure-grey neutrals.** Every "grey" in the system is a warm cream-derived tone (`{colors.ink-soft}`, `{colors.ink-whisper}`, `{colors.muted}`). Pure grey reads as Material Design and breaks the warmth.
- **No dark mode in v1.** A "Campfire Mode" is planned but out of scope. Forcing the cream palette into dark mode without dedicated tokens produces muddy results.
- **No baby-talk in the voice.** Warm, not infantilizing.
- **No purely decorative animation that gets in the way of the function.** Every animation either confirms an action, signals state, or adds gentle life — never blocks the user from completing their task.

---

## Anti-patterns from the source app

Meshtastic-Apple uses dense, technical SwiftUI patterns appropriate for its audience: grouped form-style settings, SF Symbol icons, monospaced node IDs, RSSI/SNR numeric readouts, raw distance values. In Meshtastic Mini, **every one of these is replaced**:

- Grouped form lists → card lists with `{rounded.xl}` corners and pal-character avatars.
- SF Symbols → custom illustrated icons with `{stroke.bold}` warm brown strokes.
- Monospaced node IDs → pal names (auto-generated from the node ID if the user hasn't named them: "Friendly Mountain Goat", "Cheerful Lantern", "Sleepy Pinecone").
- RSSI/SNR numeric → hearts cluster, with the real numbers tucked into pal detail under "Nerd stats" for users who want them.
- Distance in km → "about 1.2 miles away" (or km, locale-respecting), always rounded, always softened by "about."
- Raw timestamps → "Saw them 2 minutes ago" / "Saw them yesterday" / "Haven't seen them in a while."

The "Nerd stats" disclosure section on the Pal Detail screen is the **escape valve**: serious users who actually need dBm and exact coordinates can tap to expand it. The default surface stays warm.

---
