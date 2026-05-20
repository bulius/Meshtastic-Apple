import SwiftUI
import SwiftData

struct DemoModeSettingsView: View {
	@Environment(\.modelContext) private var context
	@State private var demoMode = DemoMode.shared
	@State private var showExportConfirmation = false

	var body: some View {
		List {
			Section {
				Toggle("Demo Mode", isOn: Binding(
					get: { demoMode.isActive },
					set: { newValue in
						if newValue {
							demoMode.activate(context: context)
						} else {
							demoMode.deactivate(context: context)
						}
					}
				))
				.font(MeshKitTypography.body)
				.tint(MeshKitColors.primary)
			} header: {
				Text("Simulation")
			} footer: {
				Text("Populates the app with fake pals, positions, and messages so you can test the UI without real nodes.")
					.font(MeshKitTypography.caption)
			}

			if demoMode.isActive {
				Section("Current Config") {
					LabeledContent("Pals", value: "\(demoMode.config.pals.count)")
					LabeledContent("Messages", value: "\(demoMode.config.messages.count)")

					ForEach(demoMode.config.pals) { pal in
						HStack {
							Circle()
								.fill(MeshKitColors.palColors[pal.palColorIndex % MeshKitColors.palColors.count])
								.frame(width: 12, height: 12)
							Text(pal.name)
								.font(MeshKitTypography.body)
							Spacer()
							if pal.isOnline {
								Text("\(pal.lastHeardMinutesAgo)m ago")
									.font(MeshKitTypography.caption)
									.foregroundStyle(MeshKitColors.inkSoft)
							} else {
								Text("offline")
									.font(MeshKitTypography.caption)
									.foregroundStyle(MeshKitColors.muted)
							}
							Text("\(pal.batteryLevel)%")
								.font(MeshKitTypography.caption)
								.foregroundStyle(pal.batteryLevel < 20 ? MeshKitColors.danger : MeshKitColors.inkSoft)
						}
					}
				}

				Section("Actions") {
					Button("Reload Demo Data") {
						demoMode.reload(context: context)
					}
					.font(MeshKitTypography.body)
					.foregroundStyle(MeshKitColors.primary)

					Button("Export Config to Files App") {
						demoMode.exportConfig()
						showExportConfirmation = true
					}
					.font(MeshKitTypography.body)
					.foregroundStyle(MeshKitColors.primary)
				} footer: {
					Text("Edit demo_config.json in the Files app → Meshtastic folder, then tap Reload.")
						.font(MeshKitTypography.caption)
				}
			}
		}
		.navigationTitle("Demo Mode")
		.alert("Config Exported", isPresented: $showExportConfirmation) {
			Button("OK", role: .cancel) {}
		} message: {
			Text("demo_config.json is now in the Meshtastic folder in Files. Edit it, then come back and tap Reload.")
		}
	}
}
