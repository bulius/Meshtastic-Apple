import SwiftUI

extension View {
	func meshKitSoftShadow() -> some View {
		shadow(color: MeshKitColors.shadowColor, radius: 12, x: 0, y: 4)
	}
}
