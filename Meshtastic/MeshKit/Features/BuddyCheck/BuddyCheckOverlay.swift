import SwiftUI
import SwiftData

struct BuddyCheckOverlay: ViewModifier {
	@Environment(\.modelContext) private var context
	@State private var monitor = BuddyCheckMonitor()

	func body(content: Content) -> some View {
		content
			.overlay(alignment: .top) {
				if let firstAlert = monitor.alerts.first {
					BuddyCheckBanner(
						alert: firstAlert,
						onDismiss: { monitor.dismissAlert(for: firstAlert.nodeNum) },
						onTap: {}
					)
					.padding(.horizontal, MeshKitSpacing.default)
					.padding(.top, 60)
					.transition(.move(edge: .top).combined(with: .opacity))
					.animation(.spring(response: 0.4, dampingFraction: 0.8), value: monitor.alerts)
				}
			}
			.onAppear { monitor.start(context: context) }
			.onDisappear { monitor.stop() }
	}
}

extension View {
	func buddyCheckOverlay() -> some View {
		modifier(BuddyCheckOverlay())
	}
}
