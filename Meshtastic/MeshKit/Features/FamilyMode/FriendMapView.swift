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

			// MapKit layer with node pins
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
	let pins: [LocationPin]
	let onPinTap: (LocationPin) -> Void

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

			ForEach(pins) { pin in
				let coord = CLLocationCoordinate2D(
					latitude: Double(pin.latitudeI) / 1e7,
					longitude: Double(pin.longitudeI) / 1e7
				)
				Annotation(pin.name, coordinate: coord, anchor: .bottom) {
					LocationPinMarker(pin: pin)
						.onTapGesture { onPinTap(pin) }
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
			PalDetailView(node: node)
		}
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
