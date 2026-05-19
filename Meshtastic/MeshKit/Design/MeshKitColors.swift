import SwiftUI

enum MeshKitColors {
	// MARK: - Canvas & Ink
	static let canvas = Color(hex: 0xFFF8EE)
	static let canvasSoft = Color(hex: 0xFBEFDB)
	static let surfaceCard = Color.white
	static let ink = Color(hex: 0x3D2E1F)
	static let inkSoft = Color(hex: 0x7A6755)
	static let inkWhisper = Color(hex: 0xB8A691)

	// MARK: - Brand
	static let primary = Color(hex: 0xFF7A59)
	static let primaryActive = Color(hex: 0xE55F3F)
	static let secondary = Color(hex: 0x7FC8E8)
	static let secondaryActive = Color(hex: 0x5FB0D4)
	static let highlight = Color(hex: 0xFFD66B)

	// MARK: - Semantic
	static let success = Color(hex: 0x6BC68F)
	static let warning = Color(hex: 0xF5B547)
	static let danger = Color(hex: 0xE8654F)
	static let muted = Color(hex: 0xC9BFB0)

	// MARK: - Pal Palette
	static let palCoral = Color(hex: 0xFF9B7A)
	static let palSky = Color(hex: 0x94D4ED)
	static let palMint = Color(hex: 0x9BD9B8)
	static let palButter = Color(hex: 0xFFD98F)
	static let palLavender = Color(hex: 0xC9B8E8)
	static let palPeach = Color(hex: 0xFFB89B)
	static let palSage = Color(hex: 0xB8CFA0)

	static let palColors: [Color] = [palCoral, palMint, palButter, palLavender, palPeach, palSage]

	static func palColor(for nodeId: Int64) -> Color {
		let hash = abs(nodeId) % Int64(palColors.count)
		return palColors[Int(hash)]
	}

	// MARK: - Clubhouse Washes
	static let clubhouseTreehouse = Color(hex: 0x9BD9B8)
	static let clubhouseBeach = Color(hex: 0xFFD98F)
	static let clubhouseCampfire = Color(hex: 0xFF9B7A)
	static let clubhouseSpaceship = Color(hex: 0xC9B8E8)
	static let clubhouseMountain = Color(hex: 0x94D4ED)

	// MARK: - Shadow
	static let shadowColor = Color(red: 61/255, green: 46/255, blue: 31/255).opacity(0.12)
}

extension Color {
	init(hex: UInt32) {
		let r = Double((hex >> 16) & 0xFF) / 255.0
		let g = Double((hex >> 8) & 0xFF) / 255.0
		let b = Double(hex & 0xFF) / 255.0
		self.init(red: r, green: g, blue: b)
	}
}
