import SwiftUI

struct BuddyCheckBanner: View {
	let alert: BuddyCheckMonitor.BuddyAlert
	let onDismiss: () -> Void
	let onTap: () -> Void

	var body: some View {
		Button(action: onTap) {
			HStack(spacing: MeshKitSpacing.small) {
				Circle()
					.fill(MeshKitColors.danger.opacity(0.15))
					.frame(width: 40, height: 40)
					.overlay {
						Image(systemName: "exclamationmark.triangle.fill")
							.font(.system(size: 18, weight: .bold, design: .rounded))
							.foregroundStyle(MeshKitColors.danger)
					}

				VStack(alignment: .leading, spacing: 2) {
					Text(alert.nodeName)
						.font(MeshKitTypography.body)
						.foregroundStyle(MeshKitColors.ink)

					Text("Last heard \(alert.silenceDurationText) ago")
						.font(MeshKitTypography.caption)
						.foregroundStyle(MeshKitColors.inkSoft)
				}

				Spacer()

				Button {
					onDismiss()
				} label: {
					Image(systemName: "xmark")
						.font(.system(size: 12, weight: .bold, design: .rounded))
						.foregroundStyle(MeshKitColors.inkWhisper)
						.frame(width: 28, height: 28)
						.background(MeshKitColors.canvasSoft)
						.clipShape(Circle())
				}
				.buttonStyle(.plain)
			}
			.padding(MeshKitSpacing.default)
			.background(MeshKitColors.surfaceCard)
			.clipShape(RoundedRectangle(cornerRadius: MeshKitRadius.xl))
			.shadow(color: MeshKitColors.shadowColor, radius: 12, x: 0, y: 4)
		}
		.buttonStyle(.plain)
	}
}
