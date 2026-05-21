import SwiftUI

// MARK: - Tab Icons (illustrated, no SF Symbols)

/// Map tab icon — folded paper map with a route line.
struct IconMap: View {
	var size: CGFloat = 28
	var color: Color = MeshKitColors.ink

	var body: some View {
		Canvas { context, _ in
			let sw = max(1.6, size * 0.085)
			let s = size / 28

			var outline = Path()
			outline.move(to: CGPoint(x: 3 * s, y: 6 * s))
			outline.addLine(to: CGPoint(x: 11 * s, y: 4 * s))
			outline.addLine(to: CGPoint(x: 18 * s, y: 7 * s))
			outline.addLine(to: CGPoint(x: 25 * s, y: 5 * s))
			outline.addLine(to: CGPoint(x: 25 * s, y: 23 * s))
			outline.addLine(to: CGPoint(x: 18 * s, y: 25 * s))
			outline.addLine(to: CGPoint(x: 11 * s, y: 22 * s))
			outline.addLine(to: CGPoint(x: 3 * s, y: 24 * s))
			outline.closeSubpath()
			context.fill(outline, with: .color(.white))
			context.stroke(outline, with: .color(color), style: StrokeStyle(lineWidth: sw, lineJoin: .round))

			var fold1 = Path()
			fold1.move(to: CGPoint(x: 11 * s, y: 4 * s))
			fold1.addLine(to: CGPoint(x: 11 * s, y: 22 * s))
			context.stroke(fold1, with: .color(color.opacity(0.5)), lineWidth: sw * 0.6)

			var fold2 = Path()
			fold2.move(to: CGPoint(x: 18 * s, y: 7 * s))
			fold2.addLine(to: CGPoint(x: 18 * s, y: 25 * s))
			context.stroke(fold2, with: .color(color.opacity(0.5)), lineWidth: sw * 0.6)

			let dotCenter = CGPoint(x: 14 * s, y: 14 * s)
			context.fill(
				Path(ellipseIn: CGRect(x: dotCenter.x - 1.6 * s, y: dotCenter.y - 1.6 * s, width: 3.2 * s, height: 3.2 * s)),
				with: .color(MeshKitColors.primary)
			)
		}
		.frame(width: size, height: size)
	}
}

/// Pals tab icon — a little house (home base for the neighborhood).
struct IconHouse: View {
	var size: CGFloat = 28
	var color: Color = MeshKitColors.ink

	var body: some View {
		Canvas { context, _ in
			let sw = max(1.6, size * 0.085)
			let s = size / 28

			var house = Path()
			house.move(to: CGPoint(x: 4 * s, y: 12 * s))
			house.addLine(to: CGPoint(x: 14 * s, y: 4 * s))
			house.addLine(to: CGPoint(x: 24 * s, y: 12 * s))
			house.addLine(to: CGPoint(x: 24 * s, y: 24 * s))
			house.addLine(to: CGPoint(x: 4 * s, y: 24 * s))
			house.closeSubpath()
			context.fill(house, with: .color(.white))
			context.stroke(house, with: .color(color), style: StrokeStyle(lineWidth: sw, lineJoin: .round))

			var door = Path()
			door.move(to: CGPoint(x: 11.5 * s, y: 24 * s))
			door.addLine(to: CGPoint(x: 11.5 * s, y: 18 * s))
			door.addQuadCurve(to: CGPoint(x: 16.5 * s, y: 18 * s), control: CGPoint(x: 14 * s, y: 14.5 * s))
			door.addLine(to: CGPoint(x: 16.5 * s, y: 24 * s))
			context.stroke(door, with: .color(color), style: StrokeStyle(lineWidth: sw * 0.85, lineJoin: .round))
		}
		.frame(width: size, height: size)
	}
}

/// Group / chat tab icon — a soft speech bubble with three dots.
struct IconBubble: View {
	var size: CGFloat = 28
	var color: Color = MeshKitColors.ink

	var body: some View {
		Canvas { context, _ in
			let sw = max(1.6, size * 0.085)
			let s = size / 28

			let rect = CGRect(x: 3 * s, y: 5 * s, width: 22 * s, height: 16 * s)
			let bubble = Path(roundedRect: rect, cornerRadius: 7 * s)
			var tail = Path()
			tail.move(to: CGPoint(x: 9 * s, y: 21 * s))
			tail.addLine(to: CGPoint(x: 7 * s, y: 25 * s))
			tail.addLine(to: CGPoint(x: 13 * s, y: 21 * s))
			tail.closeSubpath()

			context.fill(bubble, with: .color(.white))
			context.fill(tail, with: .color(.white))
			context.stroke(bubble, with: .color(color), style: StrokeStyle(lineWidth: sw, lineJoin: .round))
			context.stroke(tail, with: .color(color), style: StrokeStyle(lineWidth: sw, lineJoin: .round))

			let dotR = 1.6 * s
			let dotY = 13 * s
			for cx in [9.0, 14.0, 19.0] {
				context.fill(
					Path(ellipseIn: CGRect(x: cx * s - dotR, y: dotY - dotR, width: dotR * 2, height: dotR * 2)),
					with: .color(color.opacity(0.75))
				)
			}
		}
		.frame(width: size, height: size)
	}
}

/// Backpack (settings) tab icon — a small backpack silhouette.
struct IconBackpack: View {
	var size: CGFloat = 28
	var color: Color = MeshKitColors.ink

	var body: some View {
		Canvas { context, _ in
			let sw = max(1.6, size * 0.085)
			let s = size / 28

			var handle = Path()
			handle.addArc(
				center: CGPoint(x: 14 * s, y: 6 * s),
				radius: 3 * s,
				startAngle: .degrees(180),
				endAngle: .degrees(0),
				clockwise: false
			)
			context.stroke(handle, with: .color(color), style: StrokeStyle(lineWidth: sw * 0.85, lineCap: .round))

			let body = Path(roundedRect: CGRect(x: 5 * s, y: 7 * s, width: 18 * s, height: 17 * s), cornerRadius: 4.5 * s)
			context.fill(body, with: .color(.white))
			context.stroke(body, with: .color(color), style: StrokeStyle(lineWidth: sw, lineJoin: .round))

			let pocket = Path(roundedRect: CGRect(x: 8.5 * s, y: 14 * s, width: 11 * s, height: 8 * s), cornerRadius: 2.4 * s)
			context.stroke(pocket, with: .color(color), style: StrokeStyle(lineWidth: sw * 0.85, lineJoin: .round))

			var clasp = Path()
			clasp.move(to: CGPoint(x: 11 * s, y: 17.6 * s))
			clasp.addLine(to: CGPoint(x: 17 * s, y: 17.6 * s))
			context.stroke(clasp, with: .color(color), lineWidth: sw * 0.7)
		}
		.frame(width: size, height: size)
	}
}

// MARK: - Decorative / chrome icons

struct IconBack: View {
	var size: CGFloat = 22
	var color: Color = MeshKitColors.ink

	var body: some View {
		Canvas { context, _ in
			let sw = max(1.6, size * 0.13)
			let s = size / 22

			var path = Path()
			path.move(to: CGPoint(x: 14 * s, y: 5 * s))
			path.addLine(to: CGPoint(x: 7 * s, y: 11 * s))
			path.addLine(to: CGPoint(x: 14 * s, y: 17 * s))
			context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round))
		}
		.frame(width: size, height: size)
	}
}

struct IconChevron: View {
	var size: CGFloat = 16
	var color: Color = MeshKitColors.inkSoft

	var body: some View {
		Canvas { context, _ in
			let sw = max(1.4, size * 0.14)
			let s = size / 16

			var path = Path()
			path.move(to: CGPoint(x: 6 * s, y: 4 * s))
			path.addLine(to: CGPoint(x: 11 * s, y: 8 * s))
			path.addLine(to: CGPoint(x: 6 * s, y: 12 * s))
			context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round))
		}
		.frame(width: size, height: size)
	}
}

struct IconStar: View {
	var size: CGFloat = 22
	var filled: Bool = false
	var color: Color = MeshKitColors.ink

	var body: some View {
		Canvas { context, _ in
			let sw = max(1.6, size * 0.11)
			let s = size / 22
			let center = CGPoint(x: 11 * s, y: 11 * s)
			let outer: CGFloat = 8 * s
			let inner: CGFloat = 3.4 * s

			var path = Path()
			for i in 0..<10 {
				let angle = Double(i) * .pi / 5 - .pi / 2
				let r = i.isMultiple(of: 2) ? outer : inner
				let pt = CGPoint(
					x: center.x + r * CGFloat(cos(angle)),
					y: center.y + r * CGFloat(sin(angle))
				)
				if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
			}
			path.closeSubpath()

			if filled {
				context.fill(path, with: .color(MeshKitColors.highlight))
			}
			context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: sw, lineJoin: .round))
		}
		.frame(width: size, height: size)
	}
}

struct IconPlane: View {
	var size: CGFloat = 22
	var color: Color = .white

	var body: some View {
		Canvas { context, _ in
			let sw = max(1.4, size * 0.10)
			let s = size / 22

			var plane = Path()
			plane.move(to: CGPoint(x: 4 * s, y: 11 * s))
			plane.addLine(to: CGPoint(x: 19 * s, y: 4 * s))
			plane.addLine(to: CGPoint(x: 13 * s, y: 19 * s))
			plane.addLine(to: CGPoint(x: 11 * s, y: 12.5 * s))
			plane.closeSubpath()
			context.fill(plane, with: .color(color))
			context.stroke(plane, with: .color(MeshKitColors.ink), style: StrokeStyle(lineWidth: sw, lineJoin: .round))

			var crease = Path()
			crease.move(to: CGPoint(x: 11 * s, y: 12.5 * s))
			crease.addLine(to: CGPoint(x: 19 * s, y: 4 * s))
			context.stroke(crease, with: .color(MeshKitColors.ink), lineWidth: sw * 0.6)
		}
		.frame(width: size, height: size)
	}
}

struct IconLock: View {
	var size: CGFloat = 18
	var color: Color = MeshKitColors.ink
	var locked: Bool = true

	var body: some View {
		Canvas { context, _ in
			let sw = max(1.4, size * 0.10)
			let s = size / 18

			var shackle = Path()
			shackle.addArc(
				center: CGPoint(x: 9 * s, y: 8 * s),
				radius: 3.4 * s,
				startAngle: .degrees(180),
				endAngle: .degrees(0),
				clockwise: false
			)
			shackle.addLine(to: CGPoint(x: 12.4 * s, y: 10 * s))
			if locked {
				shackle.move(to: CGPoint(x: 5.6 * s, y: 8 * s))
				shackle.addLine(to: CGPoint(x: 5.6 * s, y: 10 * s))
			}
			context.stroke(shackle, with: .color(color), style: StrokeStyle(lineWidth: sw, lineCap: .round, lineJoin: .round))

			let body = Path(roundedRect: CGRect(x: 3.4 * s, y: 9.5 * s, width: 11.2 * s, height: 7 * s), cornerRadius: 1.8 * s)
			context.fill(body, with: .color(MeshKitColors.canvasSoft))
			context.stroke(body, with: .color(color), style: StrokeStyle(lineWidth: sw, lineJoin: .round))

			let hole = Path(ellipseIn: CGRect(x: 8.2 * s, y: 11.2 * s, width: 1.6 * s, height: 1.6 * s))
			context.fill(hole, with: .color(color))
		}
		.frame(width: size, height: size)
	}
}

struct IconHeartSticker: View {
	var size: CGFloat = 16
	var color: Color = MeshKitColors.danger

	var body: some View {
		HeartShape()
			.fill(color)
			.overlay(
				HeartShape().stroke(
					MeshKitColors.ink,
					style: StrokeStyle(lineWidth: max(1.2, size * 0.09), lineJoin: .round)
				)
			)
			.frame(width: size, height: size * 0.92)
	}
}
