import SwiftUI
import SwiftData
import MapKit

/// DBZ Dragon Radar-inspired friend map showing pal positions
/// with a sage-green grid background, vignette, and radar sweep animation.
struct FriendMapView: View {
	@Query(
		filter: #Predicate<PositionEntity> { $0.latest == true },
		sort: \PositionEntity.time, order: .reverse
	)
	private var positions: [PositionEntity]

	@State private var radarAngle: Double = 0
	@State private var appeared = false

	var body: some View {
		ZStack {
			// DBZ radar grid background
			RadarGridBackground()

			// MapKit layer with node pins
			if !positions.isEmpty {
				FriendMapContent(positions: positions)
			}

			// Floating chrome
			VStack {
				floatingHeader
				Spacer()
			}
		}
		.ignoresSafeArea()
		.onAppear {
			withAnimation(.easeOut(duration: 0.3)) {
				appeared = true
			}
		}
	}

	private var floatingHeader: some View {
		VStack(alignment: .leading, spacing: 2) {
			Spacer().frame(height: 54)

			HStack {
				Spacer()
				// Nearby count pill
				HStack(spacing: 6) {
					Circle()
						.fill(MeshKitColors.success)
						.frame(width: 8, height: 8)
					Text("\(positions.count) nearby")
						.font(MeshKitTypography.caption)
						.fontWeight(.bold)
						.foregroundStyle(MeshKitColors.inkSoft)
				}
				.padding(.horizontal, 14)
				.padding(.vertical, 6)
				.background(MeshKitColors.surfaceCard)
				.clipShape(Capsule())
				.meshKitSoftShadow()
				Spacer()
			}
			.padding(.horizontal, MeshKitSpacing.default)

			VStack(alignment: .leading, spacing: 2) {
				Text("where everyone is")
					.font(.system(size: 13, weight: .bold, design: .rounded))
					.foregroundStyle(MeshKitColors.ink.opacity(0.7))
					.shadow(color: .white.opacity(0.45), radius: 2, x: 0, y: 1)

				Text("Friend map")
					.font(.system(size: 30, weight: .bold, design: .rounded))
					.foregroundStyle(MeshKitColors.ink)
					.shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 1)
			}
			.padding(.horizontal, MeshKitSpacing.card)
			.padding(.top, MeshKitSpacing.tight)
		}
	}
}

// MARK: - Radar Grid Background

/// The DBZ Dragon Radar-inspired green grid with vignette
struct RadarGridBackground: View {
	var body: some View {
		ZStack {
			// Base sage green
			Color(red: 191/255, green: 217/255, blue: 194/255) // #BFD9C2

			// Grid lines
			Canvas { context, size in
				let cellSize: CGFloat = 96
				let lineColor = Color(red: 112/255, green: 160/255, blue: 128/255).opacity(0.55)

				// Vertical lines
				var x: CGFloat = 0
				while x <= size.width {
					var path = Path()
					path.move(to: CGPoint(x: x, y: 0))
					path.addLine(to: CGPoint(x: x, y: size.height))
					context.stroke(path, with: .color(lineColor), lineWidth: 1)
					x += cellSize
				}

				// Horizontal lines
				var y: CGFloat = 0
				while y <= size.height {
					var path = Path()
					path.move(to: CGPoint(x: 0, y: y))
					path.addLine(to: CGPoint(x: size.width, y: y))
					context.stroke(path, with: .color(lineColor), lineWidth: 1)
					y += cellSize
				}
			}

			// Vignette
			RadialGradient(
				gradient: Gradient(stops: [
					.init(color: Color(red: 60/255, green: 110/255, blue: 80/255).opacity(0), location: 0.55),
					.init(color: Color(red: 60/255, green: 110/255, blue: 80/255).opacity(0.14), location: 0.88),
					.init(color: Color(red: 40/255, green: 80/255, blue: 55/255).opacity(0.22), location: 1.0),
				]),
				center: .center,
				startRadius: 0,
				endRadius: UIScreen.main.bounds.height * 0.7
			)
		}
		.ignoresSafeArea()
	}
}

// MARK: - Map Content with Pal Markers

struct FriendMapContent: View {
	let positions: [PositionEntity]

	@State private var camera: MapCameraPosition = .automatic
	@State private var selectedNode: NodeInfoEntity?

	var body: some View {
		Map(position: $camera) {
			ForEach(positions, id: \.persistentModelID) { position in
				if let node = position.nodePosition {
					let coord = CLLocationCoordinate2D(
						latitude: Double(position.latitudeI) / 1e7,
						longitude: Double(position.longitudeI) / 1e7
					)
					let sig = signalLevel(rssi: node.rssi, snr: node.snr)
					let isMe = node.myInfo != nil
					let palColor = MeshKitColors.palColor(for: node.num)

					Annotation(
						node.user?.longName ?? "Pal",
						coordinate: coord,
						anchor: .bottom
					) {
						PalMapMarker(
							name: node.user?.shortName ?? "?",
							color: isMe ? MeshKitColors.palSky : palColor,
							signalLevel: sig,
							isMe: isMe,
							batteryLevel: nil
						)
						.onTapGesture {
							selectedNode = node
						}
					}
				}
			}
		}
		.mapStyle(.imagery)
		.mapControls {
			MapScaleView()
			MapCompass()
		}
		.opacity(0.35) // Blend map under the radar grid
		.allowsHitTesting(true)
		.sheet(item: $selectedNode) { node in
			PalDetailSheet(node: node)
		}
	}
}

// MARK: - Pal Map Marker

struct PalMapMarker: View {
	let name: String
	let color: Color
	let signalLevel: Int
	let isMe: Bool
	let batteryLevel: Int?

	@State private var bobOffset: CGFloat = 0
	@State private var appeared = false

	var body: some View {
		VStack(spacing: 4) {
			if signalLevel > 0 && !isMe {
				SignalHeartsView(level: signalLevel, size: 11)
					.padding(.bottom, 2)
			}

			PalCharacterView(
				color: color,
				size: isMe ? 52 : 44,
				showHalo: isMe,
				bobPhase: Double.random(in: 0...2)
			)

			// Name pill
			Text(name)
				.font(.system(size: 11, weight: .bold, design: .rounded))
				.foregroundStyle(MeshKitColors.ink)
				.padding(.horizontal, 8)
				.padding(.vertical, 2)
				.background(isMe ? MeshKitColors.secondary : .white)
				.clipShape(Capsule())
				.overlay(
					Capsule()
						.stroke(MeshKitColors.ink, lineWidth: 1.5)
				)
				.meshKitSoftShadow()
		}
		.scaleEffect(appeared ? 1 : 0)
		.animation(
			.spring(response: 0.5, dampingFraction: 0.6),
			value: appeared
		)
		.onAppear {
			appeared = true
		}
	}
}

// MARK: - Radar Sweep Animation (overlay on the grid)

struct RadarSweepView: View {
	let centerX: CGFloat
	let centerY: CGFloat

	@State private var ringScales: [CGFloat] = [0, 0, 0]

	var body: some View {
		ZStack {
			ForEach(0..<3, id: \.self) { i in
				Circle()
					.strokeBorder(
						Color(red: 242/255, green: 251/255, blue: 244/255).opacity(0.55),
						style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
					)
					.frame(width: 200, height: 200)
					.scaleEffect(ringScales[i])
					.opacity(Double(1.0 - ringScales[i]) * 0.55)
			}
		}
		.position(x: centerX, y: centerY)
		.onAppear {
			for i in 0..<3 {
				withAnimation(
					.easeOut(duration: 3.2)
					.repeatForever(autoreverses: false)
					.delay(Double(i) * 0.4)
				) {
					ringScales[i] = 1.0
				}
			}
		}
	}
}

// MARK: - Pal Detail Sheet (placeholder)

struct PalDetailSheet: View {
	let node: NodeInfoEntity

	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			VStack(spacing: MeshKitSpacing.card) {
				PalCharacterView(
					color: MeshKitColors.palColor(for: node.num),
					size: 120,
					bobPhase: 0
				)

				Text(node.user?.longName ?? "Unknown Pal")
					.font(MeshKitTypography.title)
					.foregroundStyle(MeshKitColors.ink)

				if let lastHeard = node.lastHeard {
					Text("Saw them \(lastHeard, style: .relative) ago")
						.font(MeshKitTypography.caption)
						.foregroundStyle(MeshKitColors.inkSoft)
				}

				HStack(spacing: MeshKitSpacing.default) {
					SignalHeartsView(
						level: signalLevel(rssi: node.rssi, snr: node.snr),
						size: 18
					)

					if node.hopsAway > 0 {
						Text("Hopped through \(node.hopsAway) friend\(node.hopsAway == 1 ? "" : "s")")
							.font(MeshKitTypography.caption)
							.foregroundStyle(MeshKitColors.inkSoft)
					}
				}

				Spacer()
			}
			.padding(.top, MeshKitSpacing.gap)
			.background(MeshKitColors.canvas)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Done") { dismiss() }
						.font(MeshKitTypography.body)
						.foregroundStyle(MeshKitColors.primary)
				}
			}
		}
		.presentationDetents([.medium, .large])
		.presentationDragIndicator(.visible)
	}
}

extension NodeInfoEntity: @retroactive Identifiable {}
