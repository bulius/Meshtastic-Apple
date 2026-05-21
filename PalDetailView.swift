import SwiftUI
import SwiftData

/// Full-screen pal profile matching the Meshtastic Mini "Pal Detail" design.
struct PalDetailView: View {
	let node: NodeInfoEntity

	@Environment(\.modelContext) private var context
	@Environment(\.dismiss) private var dismiss
	@State private var showingNerdStats: Bool = false

	private var palColor: Color {
		node.myInfo != nil ? MeshKitColors.palSky : MeshKitColors.palColor(for: node.num)
	}

	private var longName: String { node.user?.longName ?? "Unknown Pal" }
	private var shortName: String { node.user?.shortName ?? "?" }
	private var firstName: String {
		longName.split(separator: " ").first.map(String.init) ?? longName
	}

	private var signal: Int { signalLevel(rssi: node.rssi, snr: node.snr) }

	private var hearsCopy: String {
		switch signal {
		case 3: "we hear them clearly"
		case 2: "we hear them okay"
		case 1: "we barely hear them"
		default: "we can't hear them right now"
		}
	}

	private var hopsCopy: String? {
		guard node.hopsAway > 0 else { return nil }
		return node.hopsAway == 1
			? "hopped through 1 friend to get here"
			: "hopped through \(node.hopsAway) friends to get here"
	}

	private var latestBatteryLevel: Int? {
		let deviceMetrics = node.telemetries.filter { $0.metricsType == 0 }
		guard let telem = deviceMetrics.max(by: { ($0.time ?? .distantPast) < ($1.time ?? .distantPast) }),
			  let level = telem.batteryLevel
		else { return nil }
		return Int(level)
	}

	var body: some View {
		ZStack {
			MeshKitColors.canvas.ignoresSafeArea()

			ScrollView {
				VStack(spacing: MeshKitSpacing.card) {
					headerRow

					hero

					heartsCard

					HStack(spacing: MeshKitSpacing.small) {
						batteryCard
						verifiedCard
					}

					sendNoteButton

					nerdStatsToggle
					if showingNerdStats {
						nerdStatsDrawer
					}

					Spacer().frame(height: MeshKitSpacing.gap)
				}
				.padding(.horizontal, MeshKitSpacing.card)
				.padding(.top, MeshKitSpacing.tight)
			}
		}
	}

	// MARK: - Header row

	private var headerRow: some View {
		HStack {
			Button(action: { dismiss() }) {
				ZStack {
					Circle()
						.fill(MeshKitColors.surfaceCard)
						.frame(width: 40, height: 40)
						.meshKitSoftShadow()
					IconBack(size: 18)
				}
			}
			.buttonStyle(.plain)

			Spacer()

			Button(action: toggleFavorite) {
				ZStack {
					Circle()
						.fill(MeshKitColors.surfaceCard)
						.frame(width: 40, height: 40)
						.meshKitSoftShadow()
					IconStar(size: 20, filled: node.favorite)
				}
			}
			.buttonStyle(.plain)
		}
		.padding(.top, MeshKitSpacing.tight)
	}

	// MARK: - Hero portrait

	private var hero: some View {
		VStack(spacing: MeshKitSpacing.tight) {
			PalCharacterView(
				color: palColor,
				size: 140,
				showHalo: node.myInfo != nil,
				bobPhase: 0
			)
			.padding(.top, MeshKitSpacing.tight)

			Text(longName)
				.font(.system(size: 26, weight: .black, design: .rounded))
				.foregroundStyle(MeshKitColors.ink)

			if let lastHeard = node.lastHeard {
				Text("saw them \(relativeTime(lastHeard)) ago")
					.font(MeshKitTypography.caption)
					.foregroundStyle(MeshKitColors.inkSoft)
			}
		}
	}

	// MARK: - Hearts hero card

	private var heartsCard: some View {
		VStack(spacing: MeshKitSpacing.small) {
			Text(hearsCopy)
				.font(MeshKitTypography.heading)
				.foregroundStyle(MeshKitColors.ink)
				.multilineTextAlignment(.center)

			SignalHeartsView(level: signal, size: 26)
				.padding(.vertical, 2)

			if let hopsCopy {
				Text(hopsCopy)
					.font(MeshKitTypography.caption)
					.foregroundStyle(MeshKitColors.inkSoft)
					.multilineTextAlignment(.center)
			}
		}
		.padding(.vertical, MeshKitSpacing.card)
		.padding(.horizontal, MeshKitSpacing.card)
		.frame(maxWidth: .infinity)
		.background(MeshKitColors.surfaceCard)
		.clipShape(RoundedRectangle(cornerRadius: MeshKitRadius.xl, style: .continuous))
		.meshKitSoftShadow()
	}

	// MARK: - Battery & Verified cards

	private var batteryCard: some View {
		let level = latestBatteryLevel
		return VStack(spacing: 6) {
			if let level {
				BatteryPalView(level: level, size: 36)
			} else {
				BatteryPalView(level: 50, size: 36)
					.opacity(0.3)
			}

			Text(level.map { "battery pal is \(batteryMoodPhrase(level: $0))" } ?? "battery unknown")
				.font(.system(size: 12, weight: .medium, design: .rounded))
				.foregroundStyle(MeshKitColors.inkSoft)
				.multilineTextAlignment(.center)
				.lineLimit(2)
		}
		.padding(.vertical, MeshKitSpacing.small)
		.padding(.horizontal, MeshKitSpacing.tight)
		.frame(maxWidth: .infinity)
		.background(MeshKitColors.surfaceCard)
		.clipShape(RoundedRectangle(cornerRadius: MeshKitRadius.lg, style: .continuous))
		.meshKitSoftShadow()
	}

	private var verifiedCard: some View {
		VStack(spacing: 6) {
			IconLock(size: 28, locked: true)
				.padding(.bottom, 2)

			Text("secret handshake")
				.font(.system(size: 12, weight: .medium, design: .rounded))
				.foregroundStyle(MeshKitColors.inkSoft)
				.multilineTextAlignment(.center)
				.lineLimit(2)
		}
		.padding(.vertical, MeshKitSpacing.small)
		.padding(.horizontal, MeshKitSpacing.tight)
		.frame(maxWidth: .infinity)
		.background(MeshKitColors.surfaceCard)
		.clipShape(RoundedRectangle(cornerRadius: MeshKitRadius.lg, style: .continuous))
		.meshKitSoftShadow()
	}

	// MARK: - Send a note

	private var sendNoteButton: some View {
		Button(action: {}) {
			HStack(spacing: 10) {
				Text("Send \(firstName) a note")
					.font(MeshKitTypography.body)
					.foregroundStyle(.white)
				IconPlane(size: 20)
			}
			.frame(maxWidth: .infinity, minHeight: 56)
			.background(MeshKitColors.primary)
			.clipShape(Capsule())
			.shadow(color: MeshKitColors.shadowColor, radius: 10, x: 0, y: 4)
		}
		.buttonStyle(.plain)
		.disabled(true) // wired in next pass when PalNote screen exists
		.opacity(0.85)
	}

	// MARK: - Nerd stats

	private var nerdStatsToggle: some View {
		Button {
			withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
				showingNerdStats.toggle()
			}
		} label: {
			HStack {
				Text(showingNerdStats ? "Hide nerd stats" : "Show nerd stats")
					.font(.system(size: 14, weight: .semibold, design: .rounded))
					.foregroundStyle(MeshKitColors.inkSoft)
				Spacer()
				IconChevron(size: 14)
					.rotationEffect(.degrees(showingNerdStats ? 90 : 0))
			}
			.padding(.horizontal, MeshKitSpacing.card)
			.padding(.vertical, MeshKitSpacing.tight + 2)
		}
		.buttonStyle(.plain)
	}

	private var nerdStatsDrawer: some View {
		VStack(spacing: MeshKitSpacing.tight) {
			StatBox(label: "RSSI", value: "\(node.rssi) dBm")
			StatBox(label: "SNR", value: String(format: "%.1f dB", node.snr))
			StatBox(label: "Hops", value: "\(node.hopsAway)")
			if let role = DeviceRoles(rawValue: Int(node.user?.role ?? 0)) {
				StatBox(label: "Role", value: roleName(role))
			}
			StatBox(label: "Node ID", value: String(format: "!%08x", UInt32(truncatingIfNeeded: node.num)))
		}
		.padding(MeshKitSpacing.default)
		.background(MeshKitColors.canvasSoft)
		.clipShape(RoundedRectangle(cornerRadius: MeshKitRadius.lg, style: .continuous))
		.transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
	}

	private func roleName(_ role: DeviceRoles) -> String {
		switch role {
		case .client: "Client"
		case .clientMute: "Client (mute)"
		case .clientHidden: "Client (hidden)"
		case .clientBase: "Client (base)"
		case .tracker: "Tracker"
		case .sensor: "Sensor"
		case .tak: "TAK"
		case .takTracker: "TAK tracker"
		case .lostAndFound: "Lost & found"
		case .router: "Router"
		case .routerLate: "Router (late)"
		}
	}

	private func relativeTime(_ date: Date) -> String {
		let interval = -date.timeIntervalSinceNow
		return switch interval {
		case ..<60: "just now"
		case 60..<3600: "\(Int(interval / 60))m"
		case 3600..<86_400: "\(Int(interval / 3600))h"
		default: "\(Int(interval / 86_400))d"
		}
	}

	private func toggleFavorite() {
		node.favorite.toggle()
		try? context.save()
	}
}

// MARK: - Stat row

private struct StatBox: View {
	let label: String
	let value: String

	var body: some View {
		HStack {
			Text(label)
				.font(.system(size: 13, weight: .medium, design: .rounded))
				.foregroundStyle(MeshKitColors.inkSoft)
				.tracking(0.3)
			Spacer()
			Text(value)
				.font(.system(size: 14, weight: .semibold, design: .rounded))
				.foregroundStyle(MeshKitColors.ink)
				.monospacedDigit()
		}
		.padding(.horizontal, MeshKitSpacing.small)
		.padding(.vertical, 8)
		.background(MeshKitColors.surfaceCard)
		.clipShape(RoundedRectangle(cornerRadius: MeshKitRadius.sm, style: .continuous))
	}
}
