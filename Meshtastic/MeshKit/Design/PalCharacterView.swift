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

/// Signal hearts indicator — replaces RSSI/SNR numbers
struct SignalHeartsView: View {
	let level: Int // 0-3
	var size: CGFloat = 14

	var body: some View {
		HStack(spacing: size * 0.2) {
			if level == 0 {
				// Cloud glyph for offline
				Image(systemName: "cloud.fill")
					.font(.system(size: size, weight: .bold, design: .rounded))
					.foregroundStyle(MeshKitColors.muted)
			} else {
				ForEach(0..<3, id: \.self) { i in
					Image(systemName: i < level ? "heart.fill" : "heart")
						.font(.system(size: size, weight: .bold, design: .rounded))
						.foregroundStyle(heartColor)
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

/// Battery pal — a small battery character with face that changes with charge
struct BatteryPalView: View {
	let level: Int // 0-100
	var size: CGFloat = 20

	var body: some View {
		HStack(spacing: 2) {
			ZStack(alignment: .leading) {
				RoundedRectangle(cornerRadius: size * 0.15)
					.stroke(MeshKitColors.ink, lineWidth: max(1.5, size * 0.06))
					.frame(width: size, height: size * 0.55)

				RoundedRectangle(cornerRadius: size * 0.1)
					.fill(fillColor)
					.frame(width: max(2, size * fillFraction), height: size * 0.55 - size * 0.14)
					.padding(.leading, size * 0.07)
			}

			// Battery tip
			RoundedRectangle(cornerRadius: 1)
				.fill(MeshKitColors.ink)
				.frame(width: size * 0.06, height: size * 0.22)
		}
	}

	private var fillFraction: CGFloat {
		CGFloat(level) / 100.0 * 0.86
	}

	private var fillColor: Color {
		switch level {
		case 80...100: MeshKitColors.success
		case 40..<80: MeshKitColors.success
		case 15..<40: MeshKitColors.warning
		case 5..<15: MeshKitColors.danger
		default: MeshKitColors.danger
		}
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
