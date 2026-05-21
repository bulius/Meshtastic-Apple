import SwiftUI
import SwiftData

// MARK: - Location Pin Model

@Model
final class LocationPin {
	var name: String
	var icon: String // "tent", "car", "pin"
	var colorHex: String
	var attachedToNodeNum: Int64
	var latitudeI: Int32
	var longitudeI: Int32
	var createdAt: Date

	init(name: String, icon: String, colorHex: String, attachedToNodeNum: Int64, latitudeI: Int32, longitudeI: Int32) {
		self.name = name
		self.icon = icon
		self.colorHex = colorHex
		self.attachedToNodeNum = attachedToNodeNum
		self.latitudeI = latitudeI
		self.longitudeI = longitudeI
		self.createdAt = Date()
	}

	var color: Color { Color(hex: UInt32(colorHex.dropFirst(), radix: 16) ?? 0xFF7A59) }
}

extension LocationPin: Identifiable {
	public var id: PersistentIdentifier { persistentModelID }
}

// MARK: - Pin Icon Shapes

struct TentGlyph: View {
	var size: CGFloat = 24

	var body: some View {
		Canvas { context, canvasSize in
			let sw: CGFloat = 1.6
			let scale = size / 20

			var tent = Path()
			tent.move(to: CGPoint(x: 2 * scale, y: 17 * scale))
			tent.addLine(to: CGPoint(x: 10 * scale, y: 4 * scale))
			tent.addLine(to: CGPoint(x: 18 * scale, y: 17 * scale))
			tent.closeSubpath()
			context.fill(tent, with: .color(.white))
			context.stroke(tent, with: .color(MeshKitColors.ink), style: StrokeStyle(lineWidth: sw, lineJoin: .round))

			var pole = Path()
			pole.move(to: CGPoint(x: 10 * scale, y: 4 * scale))
			pole.addLine(to: CGPoint(x: 10 * scale, y: 17 * scale))
			context.stroke(pole, with: .color(MeshKitColors.ink), style: StrokeStyle(lineWidth: sw, lineCap: .round))

			var door = Path()
			door.move(to: CGPoint(x: 8 * scale, y: 17 * scale))
			door.addLine(to: CGPoint(x: 10 * scale, y: 12 * scale))
			door.addLine(to: CGPoint(x: 12 * scale, y: 17 * scale))
			context.stroke(door, with: .color(MeshKitColors.ink), style: StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round))
		}
		.frame(width: size, height: size)
	}
}

struct CarGlyph: View {
	var size: CGFloat = 28

	var body: some View {
		Canvas { context, canvasSize in
			let sw: CGFloat = 1.4
			let scaleX = size / 28
			let scaleY = size * 0.78 / 22

			// Body
			var body = Path()
			body.move(to: CGPoint(x: 1.5 * scaleX, y: 17 * scaleY))
			body.addLine(to: CGPoint(x: 1.5 * scaleX, y: 13 * scaleY))
			body.addQuadCurve(to: CGPoint(x: 3 * scaleX, y: 11.2 * scaleY),
							  control: CGPoint(x: 1.5 * scaleX, y: 11.6 * scaleY))
			body.addLine(to: CGPoint(x: 6.5 * scaleX, y: 10 * scaleY))
			body.addLine(to: CGPoint(x: 9 * scaleX, y: 6 * scaleY))
			body.addQuadCurve(to: CGPoint(x: 10.8 * scaleX, y: 5 * scaleY),
							  control: CGPoint(x: 9.6 * scaleX, y: 5 * scaleY))
			body.addLine(to: CGPoint(x: 18 * scaleX, y: 5 * scaleY))
			body.addQuadCurve(to: CGPoint(x: 19.8 * scaleX, y: 6 * scaleY),
							  control: CGPoint(x: 19.2 * scaleX, y: 5 * scaleY))
			body.addLine(to: CGPoint(x: 22.5 * scaleX, y: 10 * scaleY))
			body.addLine(to: CGPoint(x: 25.5 * scaleX, y: 11.2 * scaleY))
			body.addQuadCurve(to: CGPoint(x: 27 * scaleX, y: 13 * scaleY),
							  control: CGPoint(x: 27 * scaleX, y: 11.6 * scaleY))
			body.addLine(to: CGPoint(x: 27 * scaleX, y: 17 * scaleY))
			body.closeSubpath()
			context.fill(body, with: .color(.white))
			context.stroke(body, with: .color(MeshKitColors.ink), style: StrokeStyle(lineWidth: sw, lineJoin: .round))

			// Belt line
			var belt = Path()
			belt.move(to: CGPoint(x: 3 * scaleX, y: 11 * scaleY))
			belt.addLine(to: CGPoint(x: 25.5 * scaleX, y: 11 * scaleY))
			context.stroke(belt, with: .color(MeshKitColors.ink), lineWidth: sw * 0.85)

			// B-pillar
			var pillar = Path()
			pillar.move(to: CGPoint(x: 14.2 * scaleX, y: 5.2 * scaleY))
			pillar.addLine(to: CGPoint(x: 14.2 * scaleX, y: 10.6 * scaleY))
			context.stroke(pillar, with: .color(MeshKitColors.ink), lineWidth: sw * 0.85)

			// Headlight
			let headlightCenter = CGPoint(x: 25.4 * scaleX, y: 13.6 * scaleY)
			let headlight = Path(ellipseIn: CGRect(
				x: headlightCenter.x - 0.7 * scaleX,
				y: headlightCenter.y - 0.7 * scaleY,
				width: 1.4 * scaleX, height: 1.4 * scaleY
			))
			context.fill(headlight, with: .color(MeshKitColors.highlight))
			context.stroke(headlight, with: .color(MeshKitColors.ink), lineWidth: sw * 0.7)

			// Wheels
			for wx in [7.0, 21.0] {
				let wheelCenter = CGPoint(x: wx * scaleX, y: 17 * scaleY)
				let outerWheel = Path(ellipseIn: CGRect(
					x: wheelCenter.x - 2.4 * scaleX, y: wheelCenter.y - 2.4 * scaleY,
					width: 4.8 * scaleX, height: 4.8 * scaleY
				))
				context.fill(outerWheel, with: .color(.white))
				context.stroke(outerWheel, with: .color(MeshKitColors.ink), lineWidth: sw)

				let hub = Path(ellipseIn: CGRect(
					x: wheelCenter.x - 0.8 * scaleX, y: wheelCenter.y - 0.8 * scaleY,
					width: 1.6 * scaleX, height: 1.6 * scaleY
				))
				context.fill(hub, with: .color(MeshKitColors.ink))
			}
		}
		.frame(width: size, height: size * 0.78)
	}
}

struct PinDotGlyph: View {
	var size: CGFloat = 20

	var body: some View {
		Canvas { context, canvasSize in
			let sw: CGFloat = 1.8
			let scale = size / 20

			// Circle body
			let center = CGPoint(x: 10 * scale, y: 10 * scale)
			let circle = Path(ellipseIn: CGRect(
				x: center.x - 4.6 * scale, y: center.y - 4.6 * scale,
				width: 9.2 * scale, height: 9.2 * scale
			))
			context.fill(circle, with: .color(.white))
			context.stroke(circle, with: .color(MeshKitColors.ink), lineWidth: sw)

			// Eyes
			let leftEye = Path(ellipseIn: CGRect(x: 8.5 * scale - 0.6 * scale, y: 9.3 * scale - 0.6 * scale, width: 1.2 * scale, height: 1.2 * scale))
			let rightEye = Path(ellipseIn: CGRect(x: 11.5 * scale - 0.6 * scale, y: 9.3 * scale - 0.6 * scale, width: 1.2 * scale, height: 1.2 * scale))
			context.fill(leftEye, with: .color(MeshKitColors.ink))
			context.fill(rightEye, with: .color(MeshKitColors.ink))

			// Smile
			var smile = Path()
			smile.move(to: CGPoint(x: 8.6 * scale, y: 10.8 * scale))
			smile.addQuadCurve(
				to: CGPoint(x: 11.4 * scale, y: 10.8 * scale),
				control: CGPoint(x: 10 * scale, y: 11.9 * scale)
			)
			context.stroke(smile, with: .color(MeshKitColors.ink), style: StrokeStyle(lineWidth: sw * 0.55, lineCap: .round))
		}
		.frame(width: size, height: size)
	}
}

// MARK: - Pin Glyph (teardrop container + icon)

struct PinGlyphView: View {
	let icon: String
	let color: Color
	var size: CGFloat = 40

	var body: some View {
		ZStack {
			// Teardrop shape
			PinTeardropShape()
				.fill(color)
				.overlay(PinTeardropShape().stroke(MeshKitColors.ink, lineWidth: max(1.5, size * 0.045)))
				.frame(width: size, height: size * 1.15)

			// Icon inside
			Group {
				switch icon {
				case "tent": TentGlyph(size: size * 0.55)
				case "car": CarGlyph(size: size * 0.6)
				default: PinDotGlyph(size: size * 0.5)
				}
			}
			.offset(y: -size * 0.075) // Center in the bubble, not the tail
		}
	}
}

struct PinTeardropShape: Shape {
	func path(in rect: CGRect) -> Path {
		let w = rect.width
		let h = rect.height
		var path = Path()
		path.move(to: CGPoint(x: w * 0.18, y: h * 0.08))
		path.addQuadCurve(to: CGPoint(x: w * 0.5, y: 0), control: CGPoint(x: w * 0.18, y: 0))
		path.addQuadCurve(to: CGPoint(x: w * 0.82, y: h * 0.08), control: CGPoint(x: w * 0.82, y: 0))
		path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.68))
		path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.85), control: CGPoint(x: w * 0.82, y: h * 0.85))
		path.addLine(to: CGPoint(x: w * 0.5, y: h)) // tail point
		path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.85))
		path.addQuadCurve(to: CGPoint(x: w * 0.18, y: h * 0.68), control: CGPoint(x: w * 0.18, y: h * 0.85))
		path.closeSubpath()
		return path
	}
}

// MARK: - Add Location Sheet

struct AddLocationSheet: View {
	@Environment(\.modelContext) private var context
	@Environment(\.dismiss) private var dismiss

	var editingPin: LocationPin?
	let availableNodes: [NodeInfoEntity]
	let onSave: (LocationPin) -> Void
	let onDelete: ((LocationPin) -> Void)?

	@State private var name: String = ""
	@State private var icon: String = "pin"
	@State private var selectedColorHex: String = "#FF7A59"
	@State private var attachedToNodeNum: Int64 = 0
	@State private var showDeleteConfirm = false

	private let pinColors = ["#FF7A59", "#7FC8E8", "#9BD9B8", "#FFD66B", "#C9B8E8", "#FFB89B"]
	private let pinIcons = ["tent", "car", "pin"]

	var body: some View {
		VStack(spacing: MeshKitSpacing.default) {
			// Grabber
			Capsule()
				.fill(MeshKitColors.inkWhisper)
				.frame(width: 40, height: 5)
				.padding(.top, 6)

			Text(editingPin == nil ? "Add a location" : "Edit pin")
				.font(.system(size: 22, weight: .bold, design: .rounded))
				.foregroundStyle(MeshKitColors.ink)
				.frame(maxWidth: .infinity, alignment: .leading)

			// Name input
			VStack(alignment: .leading, spacing: 6) {
				Text("WHAT TO CALL IT")
					.font(.system(size: 12, weight: .bold, design: .rounded))
					.foregroundStyle(MeshKitColors.inkSoft)
					.tracking(0.5)

				TextField("my tent · the car · trailhead", text: $name)
					.font(MeshKitTypography.body)
					.foregroundStyle(MeshKitColors.ink)
					.padding(.horizontal, 14)
					.padding(.vertical, 12)
					.background(MeshKitColors.surfaceCard)
					.clipShape(RoundedRectangle(cornerRadius: MeshKitRadius.md))
					.overlay(
						RoundedRectangle(cornerRadius: MeshKitRadius.md)
							.stroke(MeshKitColors.inkWhisper, lineWidth: 2)
					)
			}

			// Icon picker
			VStack(alignment: .leading, spacing: 8) {
				Text("PICK AN ICON")
					.font(.system(size: 12, weight: .bold, design: .rounded))
					.foregroundStyle(MeshKitColors.inkSoft)
					.tracking(0.5)

				HStack(spacing: 10) {
					ForEach(pinIcons, id: \.self) { ic in
						Button {
							icon = ic
						} label: {
							VStack(spacing: 6) {
								Group {
									switch ic {
									case "tent": TentGlyph(size: 48)
									case "car": CarGlyph(size: 52)
									default: PinDotGlyph(size: 44)
									}
								}
								.frame(width: 64, height: 64)

								Text(ic.capitalized)
									.font(.system(size: 12, weight: .bold, design: .rounded))
									.foregroundStyle(icon == ic ? MeshKitColors.ink : MeshKitColors.inkSoft)
							}
							.frame(maxWidth: .infinity)
							.padding(.vertical, 14)
							.background(icon == ic ? MeshKitColors.surfaceCard : MeshKitColors.canvasSoft)
							.clipShape(RoundedRectangle(cornerRadius: MeshKitRadius.lg))
							.overlay(
								RoundedRectangle(cornerRadius: MeshKitRadius.lg)
									.stroke(icon == ic ? MeshKitColors.ink : .clear, lineWidth: 2.5)
							)
						}
						.buttonStyle(.plain)
					}
				}
			}

			// Color picker
			VStack(alignment: .leading, spacing: 8) {
				Text("PAINT IT")
					.font(.system(size: 12, weight: .bold, design: .rounded))
					.foregroundStyle(MeshKitColors.inkSoft)
					.tracking(0.5)

				HStack(spacing: 10) {
					ForEach(pinColors, id: \.self) { hex in
						Button {
							selectedColorHex = hex
						} label: {
							Circle()
								.fill(Color(hex: UInt32(hex.dropFirst(), radix: 16) ?? 0))
								.frame(width: 36, height: 36)
								.overlay(
									Circle().stroke(
										selectedColorHex == hex ? MeshKitColors.ink : .clear,
										lineWidth: 2.5
									)
								)
								.overlay(
									Circle()
										.stroke(.white, lineWidth: selectedColorHex == hex ? 2 : 0)
										.padding(2.5)
								)
						}
						.buttonStyle(.plain)
					}
				}
			}

			// Attach to picker
			VStack(alignment: .leading, spacing: 8) {
				Text("PIN IT WHERE")
					.font(.system(size: 12, weight: .bold, design: .rounded))
					.foregroundStyle(MeshKitColors.inkSoft)
					.tracking(0.5)

				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: 8) {
						ForEach(availableNodes, id: \.num) { node in
							let isSelected = attachedToNodeNum == node.num
							let dotColor = node.myInfo != nil ? MeshKitColors.secondary : MeshKitColors.palColor(for: node.num)

							Button {
								attachedToNodeNum = node.num
							} label: {
								HStack(spacing: 6) {
									Circle()
										.fill(dotColor)
										.frame(width: 10, height: 10)
										.overlay(Circle().stroke(MeshKitColors.ink, lineWidth: 1.5))

									Text(node.myInfo != nil ? "You" : (node.user?.shortName ?? "?"))
										.font(.system(size: 13, weight: .bold, design: .rounded))
										.foregroundStyle(isSelected ? MeshKitColors.ink : MeshKitColors.inkSoft)
								}
								.padding(.horizontal, 12)
								.padding(.vertical, 6)
								.background(isSelected ? MeshKitColors.surfaceCard : MeshKitColors.canvasSoft)
								.clipShape(Capsule())
								.overlay(
									Capsule().stroke(isSelected ? MeshKitColors.ink : .clear, lineWidth: 2)
								)
							}
							.buttonStyle(.plain)
						}
					}
				}
			}

			// Action buttons
			HStack(spacing: 10) {
				if editingPin != nil {
					Button {
						showDeleteConfirm = true
					} label: {
						Text("Delete")
							.font(.system(size: 15, weight: .bold, design: .rounded))
							.foregroundStyle(MeshKitColors.danger)
							.frame(height: 50)
							.padding(.horizontal, 18)
							.overlay(
								Capsule().stroke(MeshKitColors.danger, lineWidth: 2)
							)
					}
					.buttonStyle(.plain)
				}

				Button {
					dismiss()
				} label: {
					Text("Cancel")
						.font(.system(size: 15, weight: .bold, design: .rounded))
						.foregroundStyle(MeshKitColors.ink)
						.frame(maxWidth: .infinity, maxHeight: 50)
						.background(MeshKitColors.canvasSoft)
						.clipShape(Capsule())
				}
				.buttonStyle(.plain)

				Button {
					save()
				} label: {
					Text(editingPin == nil ? "Add pin" : "Save")
						.font(.system(size: 15, weight: .bold, design: .rounded))
						.foregroundStyle(.white)
						.frame(maxWidth: .infinity, maxHeight: 50)
						.background(name.isEmpty ? MeshKitColors.inkWhisper : MeshKitColors.primary)
						.clipShape(Capsule())
						.meshKitSoftShadow()
				}
				.buttonStyle(.plain)
				.disabled(name.isEmpty)
			}
			.padding(.top, 6)
		}
		.padding(.horizontal, MeshKitSpacing.card)
		.padding(.bottom, MeshKitSpacing.section)
		.background(MeshKitColors.canvas)
		.clipShape(
			UnevenRoundedRectangle(
				topLeadingRadius: 32,
				topTrailingRadius: 32
			)
		)
		.shadow(color: Color(red: 61/255, green: 46/255, blue: 31/255).opacity(0.22), radius: 32, x: 0, y: -8)
		.onAppear {
			if let pin = editingPin {
				name = pin.name
				icon = pin.icon
				selectedColorHex = pin.colorHex
				attachedToNodeNum = pin.attachedToNodeNum
			} else if let firstNode = availableNodes.first {
				attachedToNodeNum = firstNode.num
			}
		}
		.alert("Delete this pin?", isPresented: $showDeleteConfirm) {
			Button("Delete", role: .destructive) {
				if let pin = editingPin {
					onDelete?(pin)
				}
				dismiss()
			}
			Button("Keep it", role: .cancel) {}
		} message: {
			Text("It'll be gone from the map. You can always add it back.")
		}
	}

	private func save() {
		guard !name.isEmpty else { return }
		let trimmed = name.trimmingCharacters(in: .whitespaces)
		let coord = currentCoordinate(for: attachedToNodeNum)

		if let pin = editingPin {
			pin.name = trimmed
			pin.icon = icon
			pin.colorHex = selectedColorHex
			if pin.attachedToNodeNum != attachedToNodeNum {
				pin.attachedToNodeNum = attachedToNodeNum
				if let coord {
					pin.latitudeI = coord.lat
					pin.longitudeI = coord.lon
				}
			}
			onSave(pin)
		} else {
			let pin = LocationPin(
				name: trimmed,
				icon: icon,
				colorHex: selectedColorHex,
				attachedToNodeNum: attachedToNodeNum,
				latitudeI: coord?.lat ?? 0,
				longitudeI: coord?.lon ?? 0
			)
			context.insert(pin)
			onSave(pin)
		}
		dismiss()
	}

	private func currentCoordinate(for nodeNum: Int64) -> (lat: Int32, lon: Int32)? {
		guard let node = availableNodes.first(where: { $0.num == nodeNum }),
			  let position = node.positions.first(where: { $0.latest }) ?? node.positions.last
		else { return nil }
		return (position.latitudeI, position.longitudeI)
	}
}
