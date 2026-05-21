import SwiftUI
import SwiftData

/// The MeshKit (Family Mode) app shell. Hosts the four illustrated tabs:
/// Map · Pals · Group · Backpack. The Map tab is the default landing tab.
struct MeshKitShellView: View {
	@State private var selectedTab: MeshKitTab = .map

	var body: some View {
		ZStack(alignment: .bottom) {
			MeshKitColors.canvas
				.ignoresSafeArea()

			Group {
				switch selectedTab {
				case .map:
					FriendMapView()
				case .pals:
					PalsListPlaceholder()
				case .group:
					GroupRoomPlaceholder()
				case .backpack:
					BackpackPlaceholder()
				}
			}

			MeshKitTabBar(selection: $selectedTab)
		}
	}
}

// MARK: - Placeholders (will be replaced with real screens)

private struct PalsListPlaceholder: View {
	var body: some View {
		MeshKitPlaceholder(title: "Your pals", subtitle: "the friends in your neighborhood")
	}
}

private struct GroupRoomPlaceholder: View {
	var body: some View {
		MeshKitPlaceholder(title: "Group", subtitle: "where the whole crew talks")
	}
}

private struct BackpackPlaceholder: View {
	@AppStorage("meshkit.feature.familyMode") private var familyMode: Bool = false

	var body: some View {
		NavigationStack {
			ZStack {
				MeshKitColors.canvas.ignoresSafeArea()

				ScrollView {
					VStack(spacing: MeshKitSpacing.card) {
						header

						familyModeCard

						BackpackNavRow(
							title: "Demo Mode",
							subtitle: "Populate the app with fake pals so you can preview the UI",
							destination: { DemoModeSettingsView() }
						)

						BackpackNavRow(
							title: "Buddy Check",
							subtitle: "Get an alert when a pal goes quiet on the mesh",
							destination: { BuddyCheckSettingsView() }
						)

						Spacer().frame(height: 96)
					}
					.padding(.horizontal, MeshKitSpacing.card)
					.padding(.top, MeshKitSpacing.gap)
				}
			}
			.toolbar(.hidden, for: .navigationBar)
		}
	}

	private var header: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text("settings")
				.font(.system(size: 13, weight: .bold, design: .rounded))
				.foregroundStyle(MeshKitColors.inkSoft)
				.frame(maxWidth: .infinity, alignment: .leading)

			Text("My backpack")
				.font(MeshKitTypography.displayL)
				.foregroundStyle(MeshKitColors.ink)
				.frame(maxWidth: .infinity, alignment: .leading)
		}
	}

	private var familyModeCard: some View {
		HStack {
			VStack(alignment: .leading, spacing: 2) {
				Text("Family Mode")
					.font(MeshKitTypography.body)
					.foregroundStyle(MeshKitColors.ink)
				Text("Turn off to use the classic Meshtastic interface")
					.font(.system(size: 13, weight: .medium, design: .rounded))
					.foregroundStyle(MeshKitColors.inkSoft)
			}
			Spacer()
			Toggle("", isOn: $familyMode)
				.labelsHidden()
				.tint(MeshKitColors.success)
		}
		.padding(.horizontal, MeshKitSpacing.card)
		.padding(.vertical, MeshKitSpacing.card)
		.background(MeshKitColors.surfaceCard)
		.clipShape(RoundedRectangle(cornerRadius: MeshKitRadius.xl, style: .continuous))
		.meshKitSoftShadow()
	}
}

private struct BackpackNavRow<Destination: View>: View {
	let title: String
	let subtitle: String
	@ViewBuilder let destination: () -> Destination

	var body: some View {
		NavigationLink {
			destination()
		} label: {
			HStack {
				VStack(alignment: .leading, spacing: 2) {
					Text(title)
						.font(MeshKitTypography.body)
						.foregroundStyle(MeshKitColors.ink)
					Text(subtitle)
						.font(.system(size: 13, weight: .medium, design: .rounded))
						.foregroundStyle(MeshKitColors.inkSoft)
						.multilineTextAlignment(.leading)
				}
				Spacer()
				IconChevron(size: 16)
			}
			.padding(.horizontal, MeshKitSpacing.card)
			.padding(.vertical, MeshKitSpacing.card)
			.background(MeshKitColors.surfaceCard)
			.clipShape(RoundedRectangle(cornerRadius: MeshKitRadius.xl, style: .continuous))
			.meshKitSoftShadow()
		}
		.buttonStyle(.plain)
	}
}

private struct MeshKitPlaceholder: View {
	let title: String
	let subtitle: String

	var body: some View {
		VStack(spacing: MeshKitSpacing.tight) {
			Spacer()

			PalCharacterView(color: MeshKitColors.palMint, size: 120)

			Text(title)
				.font(MeshKitTypography.title)
				.foregroundStyle(MeshKitColors.ink)

			Text(subtitle)
				.font(MeshKitTypography.caption)
				.foregroundStyle(MeshKitColors.inkSoft)

			Text("coming soon")
				.font(MeshKitTypography.caption)
				.foregroundStyle(MeshKitColors.inkWhisper)
				.padding(.top, MeshKitSpacing.tight)

			Spacer()
			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(MeshKitColors.canvas)
	}
}
