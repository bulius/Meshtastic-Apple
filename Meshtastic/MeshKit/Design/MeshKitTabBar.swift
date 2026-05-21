import SwiftUI

/// The four tabs that compose the MeshKit shell.
enum MeshKitTab: String, CaseIterable, Identifiable {
	case map
	case pals
	case group
	case backpack

	var id: String { rawValue }

	var label: String {
		switch self {
		case .map: "Map"
		case .pals: "Pals"
		case .group: "Group"
		case .backpack: "Backpack"
		}
	}
}

/// Floating four-tab bar matching the Meshtastic Mini design.
/// White card, xl corner radius, single soft shadow.
struct MeshKitTabBar: View {
	@Binding var selection: MeshKitTab

	var body: some View {
		HStack(spacing: 0) {
			ForEach(MeshKitTab.allCases) { tab in
				MeshKitTabButton(
					tab: tab,
					isActive: tab == selection,
					action: {
						guard selection != tab else { return }
						withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
							selection = tab
						}
					}
				)
			}
		}
		.padding(.vertical, 10)
		.padding(.horizontal, 6)
		.background(MeshKitColors.surfaceCard)
		.clipShape(RoundedRectangle(cornerRadius: MeshKitRadius.xl, style: .continuous))
		.shadow(color: MeshKitColors.shadowColor, radius: 14, x: 0, y: 6)
		.padding(.horizontal, 12)
		.padding(.bottom, 12)
	}
}

private struct MeshKitTabButton: View {
	let tab: MeshKitTab
	let isActive: Bool
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			VStack(spacing: 2) {
				icon
					.scaleEffect(isActive ? 1.06 : 1)
					.animation(.spring(response: 0.4, dampingFraction: 0.55), value: isActive)

				Text(tab.label)
					.font(.system(size: 11, weight: .bold, design: .rounded))
					.foregroundStyle(MeshKitColors.primary)
					.opacity(isActive ? 1 : 0.001)
					.frame(height: 13)
			}
			.frame(maxWidth: .infinity)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
	}

	@ViewBuilder
	private var icon: some View {
		let color: Color = isActive ? MeshKitColors.primary : MeshKitColors.inkSoft
		switch tab {
		case .map: IconMap(size: 26, color: color)
		case .pals: IconHouse(size: 26, color: color)
		case .group: IconBubble(size: 26, color: color)
		case .backpack: IconBackpack(size: 26, color: color)
		}
	}
}
