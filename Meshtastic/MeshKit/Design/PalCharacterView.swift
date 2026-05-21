import SwiftUI

/// A bean-shaped pal character with dot eyes, smile, and optional role accessory.
/// Matches the Meshtastic Mini design system characters spec.
struct PalCharacterView: View {
	let color: Color
	var size: CGFloat = 64
	var mood: PalMood = .happy
	var showHalo: Bool = false
	var bobPhase: Double = 0

	@State private var bobOffset: CGFloat = 0

	enum PalMood {
		case happy, sleepy, flat
	}

	var body: some View {
		ZStack {
			if showHalo {
				Circle()
					.fill(MeshKitColors.highlight.opacity(0.3))
					.frame(width: size * 1.35, height: size * 1.35)
					.blur(radius: 6)
			}

			Canvas { context, canvasSize in
				let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
				let radius = size / 2 - 1.25
				let strokeWidth: CGFloat = max(2, size * 0.04)

				// Body circle
				let bodyPath = Path(ellipseIn: CGRect(
					x: center.x - radius, y: center.y - radius,
					width: radius * 2, height: radius * 2
				))
				context.fill(bodyPath, with: .color(color))
				context.stroke(bodyPath, with: .color(MeshKitColors.ink), lineWidth: strokeWidth)

				// Eyes
				let eyeRadius = size * 0.06
				let eyeY = center.y - size * 0.08
				let eyeOffset = size * 0.16

				let leftEyeCenter = CGPoint(x: center.x - eyeOffset, y: eyeY)
				let rightEyeCenter = CGPoint(x: center.x + eyeOffset, y: eyeY)

				if mood == .sleepy {
					// Left eye closed (arc)
					var closedEye = Path()
					closedEye.addArc(
						center: leftEyeCenter,
						radius: eyeRadius,
						startAngle: .degrees(180),
						endAngle: .degrees(0),
						clockwise: false
					)
					context.stroke(closedEye, with: .color(MeshKitColors.ink), lineWidth: strokeWidth * 0.7)
				} else {
					let leftEye = Path(ellipseIn: CGRect(
						x: leftEyeCenter.x - eyeRadius, y: leftEyeCenter.y - eyeRadius,
						width: eyeRadius * 2, height: eyeRadius * 2
					))
					context.fill(leftEye, with: .color(MeshKitColors.ink))
				}

				let rightEye = Path(ellipseIn: CGRect(
					x: rightEyeCenter.x - eyeRadius, y: rightEyeCenter.y - eyeRadius,
					width: eyeRadius * 2, height: eyeRadius * 2
				))
				context.fill(rightEye, with: .color(MeshKitColors.ink))

				// Cheeks
				let cheekRadius = size * 0.045
				let mouthY = center.y + size * 0.08
				let leftCheek = Path(ellipseIn: CGRect(
					x: leftEyeCenter.x - cheekRadius * 1.5 - cheekRadius,
					y: mouthY - 2 - cheekRadius,
					width: cheekRadius * 2, height: cheekRadius * 2
				))
				let rightCheek = Path(ellipseIn: CGRect(
					x: rightEyeCenter.x + cheekRadius * 0.5 - cheekRadius,
					y: mouthY - 2 - cheekRadius,
					width: cheekRadius * 2, height: cheekRadius * 2
				))
				context.fill(leftCheek, with: .color(MeshKitColors.danger.opacity(0.22)))
				context.fill(rightCheek, with: .color(MeshKitColors.danger.opacity(0.22)))

				// Mouth
				let mouthWidth = size * 0.20
				var mouth = Path()
				let mouthStart = CGPoint(x: center.x - mouthWidth / 2, y: mouthY)
				let mouthEnd = CGPoint(x: center.x + mouthWidth / 2, y: mouthY)

				switch mood {
				case .happy:
					mouth.move(to: CGPoint(x: mouthStart.x, y: mouthStart.y - 1))
					mouth.addQuadCurve(
						to: CGPoint(x: mouthEnd.x, y: mouthEnd.y - 1),
						control: CGPoint(x: center.x, y: mouthY + mouthWidth * 0.45)
					)
				case .sleepy:
					mouth.move(to: CGPoint(x: mouthStart.x, y: mouthY + 1))
					mouth.addQuadCurve(
						to: CGPoint(x: mouthEnd.x, y: mouthY + 1),
						control: CGPoint(x: center.x, y: mouthY - 1)
					)
				case .flat:
					mouth.move(to: mouthStart)
					mouth.addLine(to: mouthEnd)
				}

				context.stroke(mouth, with: .color(MeshKitColors.ink), style: StrokeStyle(
					lineWidth: strokeWidth * 0.85,
					lineCap: .round,
					lineJoin: .round
				))
			}
			.frame(width: size, height: size)
		}
		.offset(y: bobOffset)
		.onAppear {
			withAnimation(
				.easeInOut(duration: 3)
				.repeatForever(autoreverses: true)
				.delay(bobPhase)
			) {
				bobOffset = 1.5
			}
		}
	}
}

/// Signal hearts indicator — replaces RSSI/SNR numbers.
/// Hand-drawn heart shapes (no SF Symbols) with a cloud glyph at level 0.
struct SignalHeartsView: View {
	let level: Int // 0-3
	var size: CGFloat = 14

	var body: some View {
		HStack(spacing: size * 0.22) {
			if level == 0 {
				CloudGlyph(size: size * 1.3)
			} else {
				ForEach(0..<3, id: \.self) { i in
					HeartShape()
						.fill(i < level ? heartColor : Color.clear)
						.overlay(
							HeartShape().stroke(
								MeshKitColors.ink,
								style: StrokeStyle(lineWidth: max(1.2, size * 0.09), lineJoin: .round)
							)
						)
						.frame(width: size, height: size * 0.92)
				}
			}
		}
	}

	private var heartColor: Color {
		switch level {
		case 3: MeshKitColors.success
		case 2: MeshKitColors.warning
		case 1: MeshKitColors.danger
		default: MeshKitColors.muted
		}
	}
}

/// A hand-drawn heart path normalized to a unit square.
struct HeartShape: Shape {
	func path(in rect: CGRect) -> Path {
		let w = rect.width
		let h = rect.height
		var path = Path()
		path.move(to: CGPoint(x: w * 0.5, y: h * 0.95))
		path.addCurve(
			to: CGPoint(x: w * 0.05, y: h * 0.32),
			control1: CGPoint(x: w * 0.15, y: h * 0.78),
			control2: CGPoint(x: w * 0.05, y: h * 0.55)
		)
		path.addArc(
			center: CGPoint(x: w * 0.27, y: h * 0.28),
			radius: w * 0.24,
			startAngle: .degrees(180),
			endAngle: .degrees(0),
			clockwise: false
		)
		path.addArc(
			center: CGPoint(x: w * 0.73, y: h * 0.28),
			radius: w * 0.24,
			startAngle: .degrees(180),
			endAngle: .degrees(0),
			clockwise: false
		)
		path.addCurve(
			to: CGPoint(x: w * 0.5, y: h * 0.95),
			control1: CGPoint(x: w * 0.95, y: h * 0.55),
			control2: CGPoint(x: w * 0.85, y: h * 0.78)
		)
		path.closeSubpath()
		return path
	}
}

/// A small puffy cloud glyph used for the offline state.
struct CloudGlyph: View {
	var size: CGFloat = 18

	var body: some View {
		Canvas { context, canvasSize in
			let sw = max(1.4, size * 0.09)
			let scale = size / 24
			var cloud = Path()
			cloud.move(to: CGPoint(x: 5 * scale, y: 17 * scale))
			cloud.addArc(
				center: CGPoint(x: 8 * scale, y: 14 * scale),
				radius: 4 * scale,
				startAngle: .degrees(110),
				endAngle: .degrees(270),
				clockwise: false
			)
			cloud.addArc(
				center: CGPoint(x: 13 * scale, y: 11 * scale),
				radius: 4 * scale,
				startAngle: .degrees(220),
				endAngle: .degrees(340),
				clockwise: false
			)
			cloud.addArc(
				center: CGPoint(x: 18 * scale, y: 14 * scale),
				radius: 3.6 * scale,
				startAngle: .degrees(270),
				endAngle: .degrees(70),
				clockwise: false
			)
			cloud.addLine(to: CGPoint(x: 5 * scale, y: 17 * scale))
			cloud.closeSubpath()
			context.fill(cloud, with: .color(MeshKitColors.canvasSoft))
			context.stroke(cloud, with: .color(MeshKitColors.muted), style: StrokeStyle(lineWidth: sw, lineJoin: .round))
		}
		.frame(width: size, height: size * 0.78)
	}
}

/// Battery pal — a battery-shaped character whose face changes with charge.
/// Face is hidden below ~18pt to keep small renderings legible.
struct BatteryPalView: View {
	let level: Int // 0-100
	var size: CGFloat = 36

	@State private var wobble: CGFloat = 0

	enum Mood {
		case beam, happy, flat, sleepy, critical
	}

	private var mood: Mood {
		switch level {
		case 80...100: .beam
		case 40..<80: .happy
		case 25..<40: .flat
		case 12..<25: .sleepy
		default: .critical
		}
	}

	private var fillColor: Color {
		switch mood {
		case .beam, .happy: MeshKitColors.success
		case .flat: MeshKitColors.warning
		case .sleepy: MeshKitColors.warning
		case .critical: MeshKitColors.danger
		}
	}

	var body: some View {
		Canvas { context, canvasSize in
			let strokeWidth = max(2.0, size * 0.065)
			let bodyW = size * 0.92
			let bodyH = size
			let bodyX = (canvasSize.width - bodyW) / 2
			let bodyY = (canvasSize.height - bodyH) / 2
			let corner = size * 0.18

			// Battery tip on top
			let tipW = size * 0.32
			let tipH = size * 0.10
			let tipRect = CGRect(
				x: bodyX + (bodyW - tipW) / 2,
				y: bodyY - tipH + 0.5,
				width: tipW,
				height: tipH
			)
			let tip = Path(roundedRect: tipRect, cornerRadius: tipH * 0.4)
			context.fill(tip, with: .color(MeshKitColors.ink))

			// Body outline
			let bodyRect = CGRect(x: bodyX, y: bodyY, width: bodyW, height: bodyH)
			let bodyPath = Path(roundedRect: bodyRect, cornerRadius: corner)
			context.fill(bodyPath, with: .color(MeshKitColors.canvasSoft))

			// Fill (rises from bottom proportional to charge)
			let charge = max(0.04, min(1.0, CGFloat(level) / 100.0))
			let inset: CGFloat = strokeWidth * 1.1
			let innerH = bodyH - inset * 2
			let fillH = innerH * charge
			let fillRect = CGRect(
				x: bodyX + inset,
				y: bodyY + inset + (innerH - fillH),
				width: bodyW - inset * 2,
				height: fillH
			)
			let fillCorner = max(2, corner - inset * 0.6)
			context.fill(
				Path(roundedRect: fillRect, cornerRadius: fillCorner),
				with: .color(fillColor)
			)
			context.stroke(bodyPath, with: .color(MeshKitColors.ink), style: StrokeStyle(lineWidth: strokeWidth, lineJoin: .round))

			// Face — only render at reasonable sizes
			guard size >= 24 else { return }

			let faceCenter = CGPoint(x: bodyX + bodyW / 2, y: bodyY + bodyH * 0.58)
			let eyeRadius = size * 0.055
			let eyeOffset = size * 0.16
			let eyeY = faceCenter.y - size * 0.06

			let leftEyeCenter = CGPoint(x: faceCenter.x - eyeOffset, y: eyeY)
			let rightEyeCenter = CGPoint(x: faceCenter.x + eyeOffset, y: eyeY)

			switch mood {
			case .beam, .happy:
				// Two filled dot eyes
				drawDot(in: &context, center: leftEyeCenter, radius: eyeRadius)
				drawDot(in: &context, center: rightEyeCenter, radius: eyeRadius)
			case .flat:
				// Two filled dots, smaller
				drawDot(in: &context, center: leftEyeCenter, radius: eyeRadius * 0.85)
				drawDot(in: &context, center: rightEyeCenter, radius: eyeRadius * 0.85)
			case .sleepy:
				// Closed-arc eyes
				drawSleepyEye(in: &context, center: leftEyeCenter, radius: eyeRadius, strokeWidth: strokeWidth * 0.6)
				drawSleepyEye(in: &context, center: rightEyeCenter, radius: eyeRadius, strokeWidth: strokeWidth * 0.6)
			case .critical:
				// One eye open, one closed (worried)
				drawDot(in: &context, center: leftEyeCenter, radius: eyeRadius)
				drawSleepyEye(in: &context, center: rightEyeCenter, radius: eyeRadius, strokeWidth: strokeWidth * 0.6)
			}

			// Mouth
			let mouthY = faceCenter.y + size * 0.10
			let mouthWidth = size * 0.22
			var mouth = Path()
			let mouthStart = CGPoint(x: faceCenter.x - mouthWidth / 2, y: mouthY)
			let mouthEnd = CGPoint(x: faceCenter.x + mouthWidth / 2, y: mouthY)
			switch mood {
			case .beam:
				mouth.move(to: mouthStart)
				mouth.addQuadCurve(to: mouthEnd, control: CGPoint(x: faceCenter.x, y: mouthY + mouthWidth * 0.7))
			case .happy:
				mouth.move(to: mouthStart)
				mouth.addQuadCurve(to: mouthEnd, control: CGPoint(x: faceCenter.x, y: mouthY + mouthWidth * 0.45))
			case .flat:
				mouth.move(to: mouthStart)
				mouth.addLine(to: mouthEnd)
			case .sleepy:
				mouth.move(to: CGPoint(x: mouthStart.x, y: mouthY - 0.5))
				mouth.addQuadCurve(to: CGPoint(x: mouthEnd.x, y: mouthY - 0.5), control: CGPoint(x: faceCenter.x, y: mouthY - mouthWidth * 0.25))
			case .critical:
				// Wobbly small frown
				mouth.move(to: mouthStart)
				mouth.addQuadCurve(to: mouthEnd, control: CGPoint(x: faceCenter.x, y: mouthY - mouthWidth * 0.35))
			}
			context.stroke(
				mouth,
				with: .color(MeshKitColors.ink),
				style: StrokeStyle(lineWidth: strokeWidth * 0.75, lineCap: .round, lineJoin: .round)
			)
		}
		.frame(width: size * 1.05, height: size * 1.18)
		.rotationEffect(.degrees(mood == .critical ? Double(wobble) : 0))
		.onAppear {
			guard mood == .critical else { return }
			withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
				wobble = 4
			}
		}
	}

	private func drawDot(in context: inout GraphicsContext, center: CGPoint, radius: CGFloat) {
		let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
		context.fill(Path(ellipseIn: rect), with: .color(MeshKitColors.ink))
	}

	private func drawSleepyEye(in context: inout GraphicsContext, center: CGPoint, radius: CGFloat, strokeWidth: CGFloat) {
		var path = Path()
		path.addArc(
			center: center,
			radius: radius,
			startAngle: .degrees(180),
			endAngle: .degrees(0),
			clockwise: false
		)
		context.stroke(path, with: .color(MeshKitColors.ink), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
	}
}

/// Short mood-driven phrase for the battery pal (e.g. "your battery pal is beaming").
func batteryMoodPhrase(level: Int) -> String {
	switch level {
	case 80...100: "beaming"
	case 40..<80: "doing fine"
	case 25..<40: "feeling tired"
	case 12..<25: "getting sleepy"
	default: "needs a nap"
	}
}

/// Converts RSSI/SNR to a 0-3 signal level for hearts display
func signalLevel(rssi: Int32, snr: Float) -> Int {
	if rssi == 0 && snr == 0 { return 0 }
	let rssiScore: Int = switch rssi {
	case ...(-110): 0
	case (-110)...(-95): 1
	case (-95)...(-75): 2
	default: 3
	}
	let snrScore: Int = switch snr {
	case ...(-5): 0
	case (-5)...0: 1
	case 0...5: 2
	default: 3
	}
	return max(rssiScore, snrScore)
}
