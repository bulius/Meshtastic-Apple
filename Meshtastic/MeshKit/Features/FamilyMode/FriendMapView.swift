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

	@Query(sort: \LocationPin.createdAt) private var pins: [LocationPin]

	@State private var appeared = false
	@State private var showAddPinSheet = false
	@State private var editingPin: LocationPin?

	private var availableNodes: [NodeInfoEntity] {
		let nodes = positions.compactMap { $0.nodePosition }
		// "You" first, then others in stable order
		return nodes.sorted { lhs, rhs in
			let lhsIsMe = lhs.myInfo != nil
			let rhsIsMe = rhs.myInfo != nil
			if lhsIsMe != rhsIsMe { return lhsIsMe }
			return lhs.num < rhs.num
		}
	}

	var body: some View {
		ZStack {
			// DBZ radar grid background
			RadarGridBackground()

			// MapKit layer with node pins (rendered above the radar grid).
			if !positions.isEmpty {
				FriendMapContent(
					positions: positions,
					pins: pins,
					onPinTap: { editingPin = $0 }
				)
			}

			// Floating chrome
			VStack {
				floatingHeader
				Spacer()
				floatingFooter
			}
		}
		.ignoresSafeArea()
		.onAppear {
			withAnimation(.easeOut(duration: 0.3)) {
				appeared = true
			}
		}
		.sheet(isPresented: $showAddPinSheet) {
			AddLocationSheet(
				editingPin: nil,
				availableNodes: availableNodes,
				onSave: { _ in },
				onDelete: nil
			)
			.presentationDetents([.medium, .large])
			.presentationDragIndicator(.visible)
			.presentationBackground(MeshKitColors.canvas)
		}
		.sheet(item: $editingPin) { pin in
			AddLocationSheet(
				editingPin: pin,
				availableNodes: availableNodes,
				onSave: { _ in editingPin = nil },
				onDelete: { p in
					editingPin = nil
					// SwiftData delete handled by AddLocationSheet's modelContext
					if let context = pin.modelContext {
						context.delete(p)
						try? context.save()
					}
				}
			)
			.presentationDetents([.medium, .large])
			.presentationDragIndicator(.visible)
			.presentationBackground(MeshKitColors.canvas)
		}
	}

	private var floatingFooter: some View {
		HStack {
			Spacer()
			AddPinFAB { showAddPinSheet = true }
				.disabled(availableNodes.isEmpty)
				.opacity(availableNodes.isEmpty ? 0.4 : 1)
		}
		.padding(.horizontal, MeshKitSpacing.card)
		.padding(.bottom, 96) // leaves room above the future tab bar
	}

	private var floatingHeader: some View {
		VStack(alignment: .leading, spacing: 0) {
			Spacer().frame(height: 54)

			HStack(alignment: .bottom) {
				VStack(alignment: .leading, spacing: 2) {
					Text("where everyone is")
						.font(.system(size: 13, weight: .bold, design: .rounded))
						.foregroundStyle(MeshKitColors.ink.opacity(0.7))
						.shadow(color: .white.opacity(0.45), radius: 2, x: 0, y: 1)

					Text("Friend map")
						.font(.system(size: 32, weight: .heavy, design: .rounded))
						.foregroundStyle(MeshKitColors.ink)
						.shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 1)
				}

				Spacer()

				nearbyPill
			}
			.padding(.horizontal, MeshKitSpacing.card)
			.padding(.top, MeshKitSpacing.tight)
		}
	}

	private var nearbyPill: some View {
		HStack(spacing: 6) {
			HeartShape()
				.fill(MeshKitColors.danger)
				.overlay(
					HeartShape().stroke(MeshKitColors.ink, style: StrokeStyle(lineWidth: 1.2, lineJoin: .round))
				)
				.frame(width: 14, height: 13)
			Text("\(positions.count) nearby")
				.font(.system(size: 13, weight: .bold, design: .rounded))
				.foregroundStyle(MeshKitColors.ink)
		}
		.padding(.horizontal, 12)
		.padding(.vertical, 7)
		.background(MeshKitColors.surfaceCard)
		.clipShape(Capsule())
		.overlay(
			Capsule().stroke(MeshKitColors.ink.opacity(0.12), lineWidth: 1)
		)
		.meshKitSoftShadow()
	}
}

// MARK: - Radar Grid Background

/// The DBZ Dragon Radar-inspired green grid with vignette
struct RadarGridBackground: View {
	var body: some View {
		ZStack {
			// Base sage green
			Color(red: 191/255, green: 217/255, blue: 194/255) // #BFD9C2

			// Grid + concentric rings + decorative heart sprinkles
			Canvas { context, size in
				let cellSize: CGFloat = 64
				let lineColor = Color(red: 112/255, green: 160/255, blue: 128/255).opacity(0.55)
				let ringColor = Color(red: 92/255, green: 142/255, blue: 110/255).opacity(0.32)
				let heartColor = Color(red: 92/255, green: 142/255, blue: 110/255).opacity(0.35)

				// --- Grid ---
				var x: CGFloat = 0
				while x <= size.width {
					var path = Path()
					path.move(to: CGPoint(x: x, y: 0))
					path.addLine(to: CGPoint(x: x, y: size.height))
					context.stroke(path, with: .color(lineColor), lineWidth: 1)
					x += cellSize
				}
				var y: CGFloat = 0
				while y <= size.height {
					var path = Path()
					path.move(to: CGPoint(x: 0, y: y))
					path.addLine(to: CGPoint(x: size.width, y: y))
					context.stroke(path, with: .color(lineColor), lineWidth: 1)
					y += cellSize
				}

				// --- Concentric radar rings centered on screen ---
				let center = CGPoint(x: size.width / 2, y: size.height / 2)
				let maxRadius = min(size.width, size.height) * 0.46
				let ringCount = 4
				for i in 1...ringCount {
					let radius = maxRadius * CGFloat(i) / CGFloat(ringCount)
					let ring = Path(ellipseIn: CGRect(
						x: center.x - radius, y: center.y - radius,
						width: radius * 2, height: radius * 2
					))
					context.stroke(ring, with: .color(ringColor), style: StrokeStyle(lineWidth: 1.4))
				}

				// --- Decorative heart sprinkles (deterministic) ---
				var rng = SplitMix64(seed: 0xC0FFEE_BEAD)
				let columns = Int(size.width / cellSize)
				let rows = Int(size.height / cellSize)
				let centerCellX = columns / 2
				let centerCellY = rows / 2
				for col in 0..<columns {
					for row in 0..<rows {
						// Skip the central 3x3 cluster so hearts don't crowd the "You" pal
						let dx = abs(col - centerCellX)
						let dy = abs(row - centerCellY)
						if dx <= 1 && dy <= 1 { _ = rng.next(); _ = rng.next(); _ = rng.next(); continue }

						// ~28% of remaining cells get a heart
						let roll = rng.nextUnit()
						let jitterX = rng.nextUnit()
						let jitterY = rng.nextUnit()
						guard roll < 0.28 else { continue }

						let cellOriginX = CGFloat(col) * cellSize
						let cellOriginY = CGFloat(row) * cellSize
						let heartSize: CGFloat = 9
						let px = cellOriginX + cellSize * (0.25 + CGFloat(jitterX) * 0.5)
						let py = cellOriginY + cellSize * (0.25 + CGFloat(jitterY) * 0.5)

						let heartRect = CGRect(
							x: px - heartSize / 2,
							y: py - heartSize / 2,
							width: heartSize,
							height: heartSize * 0.92
						)
						let heartPath = HeartShape().path(in: heartRect)
						context.fill(heartPath, with: .color(heartColor))
					}
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

/// Tiny deterministic PRNG so the heart sprinkle layout is stable across launches.
private struct SplitMix64 {
	private var state: UInt64
	init(seed: UInt64) { self.state = seed }
	mutating func next() -> UInt64 {
		state &+= 0x9E3779B97F4A7C15
		var z = state
		z = (z ^ (z &>> 30)) &* 0xBF58476D1CE4E5B9
		z = (z ^ (z &>> 27)) &* 0x94D049BB133111EB
		return z ^ (z &>> 31)
	}
	mutating func nextUnit() -> Double {
		Double(next() >> 11) / Double(1 << 53)
	}
}

// MARK: - Map Content with Pal Markers

struct FriendMapContent: View {
	let positions: [PositionEntity]
	let pins: [LocationPin]
	let onPinTap: (LocationPin) -> Void

	@State private var selectedNode: NodeInfoEntity?

	/// How far the outermost radar ring represents in real meters.
	/// 2 km is a reasonable LoRa-range default for a campsite scenario.
	private let radarRangeMeters: Double = 2_000

	/// Position of the user's own node ("You" — Dad, in the demo).
	private var meCoordinate: CLLocationCoordinate2D? {
		guard let mePosition = positions.first(where: { $0.nodePosition?.myInfo != nil })
		else { return nil }
		return CLLocationCoordinate2D(
			latitude: Double(mePosition.latitudeI) / 1e7,
			longitude: Double(mePosition.longitudeI) / 1e7
		)
	}

	var body: some View {
		GeometryReader { proxy in
			let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
			let maxRadius = min(proxy.size.width, proxy.size.height) * 0.46
			let ptsPerMeter = maxRadius / CGFloat(radarRangeMeters)

			ZStack {
				if let me = meCoordinate {
					ForEach(positions, id: \.persistentModelID) { position in
						if let node = position.nodePosition {
							let coord = CLLocationCoordinate2D(
								latitude: Double(position.latitudeI) / 1e7,
								longitude: Double(position.longitudeI) / 1e7
							)
							let isMe = node.myInfo != nil
							let palColor = MeshKitColors.palColor(for: node.num)
							let sig = signalLevel(rssi: node.rssi, snr: node.snr)
							let displayName = isMe ? "You" : (node.user?.longName ?? "Pal")
							let pt = project(
								coord, relativeTo: me,
								ptsPerMeter: ptsPerMeter,
								maxRadius: maxRadius, center: center
							)

							PalMapMarker(
								name: displayName,
								color: isMe ? MeshKitColors.palSky : palColor,
								signalLevel: sig,
								isMe: isMe,
								batteryLevel: nil
							)
							.position(pt)
							.onTapGesture { selectedNode = node }
						}
					}

					ForEach(pins) { pin in
						let coord = CLLocationCoordinate2D(
							latitude: Double(pin.latitudeI) / 1e7,
							longitude: Double(pin.longitudeI) / 1e7
						)
						let pt = project(
							coord, relativeTo: me,
							ptsPerMeter: ptsPerMeter,
							maxRadius: maxRadius, center: center
						)
						LocationPinMarker(pin: pin)
							.position(pt)
							.onTapGesture { onPinTap(pin) }
					}
				}
			}
		}
		.sheet(item: $selectedNode) { node in
			PalDetailView(node: node)
		}
	}

	/// Flat-earth projection: convert a lat/lng to a screen point relative to `me`,
	/// then clamp inside the outermost radar ring.
	private func project(
		_ coord: CLLocationCoordinate2D,
		relativeTo me: CLLocationCoordinate2D,
		ptsPerMeter: CGFloat,
		maxRadius: CGFloat,
		center: CGPoint
	) -> CGPoint {
		let metersPerDegreeLat: Double = 111_000
		let metersPerDegreeLng: Double = 111_000 * cos(me.latitude * .pi / 180)

		let dxMeters = (coord.longitude - me.longitude) * metersPerDegreeLng
		let dyMeters = (coord.latitude - me.latitude) * metersPerDegreeLat

		var dx = CGFloat(dxMeters) * ptsPerMeter
		var dy = -CGFloat(dyMeters) * ptsPerMeter  // screen Y grows downward

		let dist = sqrt(dx * dx + dy * dy)
		if dist > maxRadius && dist > 0 {
			let scale = maxRadius / dist
			dx *= scale
			dy *= scale
		}

		return CGPoint(x: center.x + dx, y: center.y + dy)
	}
}

// MARK: - Location Pin Map Marker

struct LocationPinMarker: View {
	let pin: LocationPin

	@State private var appeared = false

	var body: some View {
		VStack(spacing: 4) {
			PinGlyphView(icon: pin.icon, color: pin.color, size: 44)
			Text(pin.name)
				.font(.system(size: 11, weight: .bold, design: .rounded))
				.foregroundStyle(MeshKitColors.ink)
				.padding(.horizontal, 8)
				.padding(.vertical, 2)
				.background(.white)
				.clipShape(Capsule())
				.overlay(Capsule().stroke(MeshKitColors.ink, lineWidth: 1.5))
				.meshKitSoftShadow()
		}
		.scaleEffect(appeared ? 1 : 0)
		.animation(.spring(response: 0.5, dampingFraction: 0.6), value: appeared)
		.onAppear { appeared = true }
	}
}

// MARK: - Add Pin FAB

struct AddPinFAB: View {
	let action: () -> Void

	@State private var pressed = false

	var body: some View {
		Button {
			action()
		} label: {
			ZStack {
				Circle()
					.fill(MeshKitColors.primary)
					.frame(width: 56, height: 56)
					.shadow(color: MeshKitColors.shadowColor, radius: 8, x: 0, y: 3)

				// "+" glyph, drawn (no SF Symbols)
				Canvas { context, size in
					let center = CGPoint(x: size.width / 2, y: size.height / 2)
					let arm: CGFloat = size.width * 0.30
					var horiz = Path()
					horiz.move(to: CGPoint(x: center.x - arm, y: center.y))
					horiz.addLine(to: CGPoint(x: center.x + arm, y: center.y))
					var vert = Path()
					vert.move(to: CGPoint(x: center.x, y: center.y - arm))
					vert.addLine(to: CGPoint(x: center.x, y: center.y + arm))
					context.stroke(horiz, with: .color(.white), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
					context.stroke(vert, with: .color(.white), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
				}
				.frame(width: 56, height: 56)
			}
			.scaleEffect(pressed ? 0.92 : 1)
		}
		.buttonStyle(.plain)
		.simultaneousGesture(
			DragGesture(minimumDistance: 0)
				.onChanged { _ in
					if !pressed { withAnimation(.spring(response: 0.15)) { pressed = true } }
				}
				.onEnded { _ in withAnimation(.spring(response: 0.25)) { pressed = false } }
		)
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

extension NodeInfoEntity: @retroactive Identifiable {}
