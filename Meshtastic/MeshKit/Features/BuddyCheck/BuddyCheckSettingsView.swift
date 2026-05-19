import SwiftUI
import SwiftData

struct BuddyCheckSettingsView: View {
	@Environment(\.modelContext) private var context
	@Query private var configs: [BuddyCheckConfiguration]
	@Query(sort: \NodeInfoEntity.num) private var nodes: [NodeInfoEntity]

	@State private var isAddingNode = false

	var body: some View {
		List {
			Section {
				Toggle("Buddy Check", isOn: .init(
					get: { MeshKitFeatureFlags.buddyCheckEnabled },
					set: { MeshKitFeatureFlags.buddyCheckEnabled = $0 }
				))
				.font(MeshKitTypography.body)
				.tint(MeshKitColors.primary)
			} header: {
				Text("Feature")
			} footer: {
				Text("Get alerted when a pal hasn't been heard from in a while.")
					.font(MeshKitTypography.caption)
			}

			if MeshKitFeatureFlags.buddyCheckEnabled {
				Section("Watched Pals") {
					ForEach(configs) { config in
						if let node = nodes.first(where: { $0.num == config.nodeNum }) {
							BuddyCheckNodeRow(config: config, node: node)
						}
					}
					.onDelete { indexSet in
						for index in indexSet {
							context.delete(configs[index])
						}
					}

					Button {
						isAddingNode = true
					} label: {
						Label("Add a pal to watch", systemImage: "plus.circle.fill")
							.font(MeshKitTypography.body)
							.foregroundStyle(MeshKitColors.primary)
					}
				}
			}
		}
		.navigationTitle("Buddy Check")
		.sheet(isPresented: $isAddingNode) {
			BuddyCheckNodePicker(
				nodes: unwatchedNodes,
				onSelect: { node in
					let config = BuddyCheckConfiguration(nodeNum: node.num)
					context.insert(config)
					isAddingNode = false
				}
			)
		}
	}

	private var unwatchedNodes: [NodeInfoEntity] {
		let watchedNums = Set(configs.map(\.nodeNum))
		return nodes.filter { node in
			!watchedNums.contains(node.num) &&
			node.user != nil &&
			node.lastHeard != nil
		}
	}
}

private struct BuddyCheckNodeRow: View {
	@Bindable var config: BuddyCheckConfiguration
	let node: NodeInfoEntity

	var body: some View {
		VStack(alignment: .leading, spacing: MeshKitSpacing.micro) {
			HStack {
				Text(node.user?.longName ?? "Unknown")
					.font(MeshKitTypography.body)
					.foregroundStyle(MeshKitColors.ink)

				Spacer()

				Toggle("", isOn: $config.isEnabled)
					.tint(MeshKitColors.primary)
					.labelsHidden()
			}

			HStack(spacing: MeshKitSpacing.tight) {
				Text("Alert after")
					.font(MeshKitTypography.caption)
					.foregroundStyle(MeshKitColors.inkSoft)

				Picker("", selection: $config.thresholdMinutes) {
					Text("5 min").tag(5)
					Text("10 min").tag(10)
					Text("15 min").tag(15)
					Text("30 min").tag(30)
					Text("1 hour").tag(60)
				}
				.pickerStyle(.segmented)
				.frame(maxWidth: 280)
			}
		}
		.padding(.vertical, MeshKitSpacing.micro)
	}
}

private struct BuddyCheckNodePicker: View {
	let nodes: [NodeInfoEntity]
	let onSelect: (NodeInfoEntity) -> Void

	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			List(nodes, id: \.num) { node in
				Button {
					onSelect(node)
				} label: {
					HStack {
						Text(node.user?.longName ?? "Node \(node.num)")
							.font(MeshKitTypography.body)
							.foregroundStyle(MeshKitColors.ink)

						Spacer()

						if let lastHeard = node.lastHeard {
							Text(lastHeard, style: .relative)
								.font(MeshKitTypography.caption)
								.foregroundStyle(MeshKitColors.inkSoft)
						}
					}
				}
			}
			.navigationTitle("Add a Pal")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") { dismiss() }
				}
			}
		}
	}
}
