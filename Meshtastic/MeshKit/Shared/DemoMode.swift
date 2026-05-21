import Foundation
import SwiftData
import OSLog

/// Drives the app with simulated data for UI testing without real nodes.
///
/// Edit `demo_config.json` in the app bundle (or Documents dir) to control:
/// - Which pals appear and their states
/// - GPS positions, signal, battery
/// - Messages, buddy check triggers
/// - Feature flag overrides
///
/// Toggle demo mode via Settings or by setting `meshkit.demoMode` in UserDefaults.
@MainActor
@Observable
final class DemoMode {
	static let shared = DemoMode()

	private(set) var isActive: Bool = false
	private(set) var config: DemoConfig = .default
	private let logger = Logger(subsystem: "com.meshkit", category: "DemoMode")

	var palCount: Int { config.pals.count }

	func activate(context: ModelContext) {
		guard !isActive else { return }
		loadConfig()
		isActive = true
		logger.info("Demo mode activated with \(self.config.pals.count) pals")
		seedData(context: context)
	}

	func deactivate(context: ModelContext) {
		guard isActive else { return }
		isActive = false
		clearDemoData(context: context)
		logger.info("Demo mode deactivated")
	}

	func reload(context: ModelContext) {
		if isActive {
			clearDemoData(context: context)
			loadConfig()
			seedData(context: context)
			logger.info("Demo data reloaded")
		}
	}

	// MARK: - Config Loading

	private func loadConfig() {
		// Check Documents dir first (user-editable), then bundle
		if let docsURL = documentsConfigURL, let data = try? Data(contentsOf: docsURL) {
			if let decoded = try? JSONDecoder().decode(DemoConfig.self, from: data) {
				config = decoded
				logger.info("Loaded demo config from Documents")
				return
			}
		}

		if let bundleURL = Bundle.main.url(forResource: "demo_config", withExtension: "json"),
		   let data = try? Data(contentsOf: bundleURL),
		   let decoded = try? JSONDecoder().decode(DemoConfig.self, from: data) {
			config = decoded
			logger.info("Loaded demo config from bundle")
			return
		}

		config = .default
		logger.info("Using default demo config")
	}

	private var documentsConfigURL: URL? {
		FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
			.first?
			.appendingPathComponent("demo_config.json")
	}

	/// Writes the current config to Documents so the user can edit it
	func exportConfig() {
		guard let url = documentsConfigURL else { return }
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		if let data = try? encoder.encode(config) {
			try? data.write(to: url)
			logger.info("Demo config exported to \(url.path)")
		}
	}

	// MARK: - Data Seeding

	/// Demo nodes use num range 900_000_001+ to avoid collisions with real nodes
	static let demoNodeNumBase: Int64 = 900_000_001

	private func seedData(context: ModelContext) {
		for (index, pal) in config.pals.enumerated() {
			let nodeNum = Self.demoNodeNumBase + Int64(index)

			let node = NodeInfoEntity()
			node.num = nodeNum
			node.lastHeard = pal.isOnline
				? Date(timeIntervalSinceNow: -TimeInterval(pal.lastHeardMinutesAgo * 60))
				: Date(timeIntervalSinceNow: -86400)
			node.hopsAway = Int32(pal.hopsAway)
			node.rssi = Int32(pal.rssi)
			node.snr = pal.snr
			context.insert(node)

			let user = UserEntity()
			user.num = nodeNum
			user.longName = pal.name
			user.shortName = pal.shortName
			user.role = Int32(pal.role.rawValue)
			user.pkiEncrypted = pal.encrypted
			user.userNode = node
			context.insert(user)

			if pal.hasPosition {
				let position = PositionEntity()
				position.latitudeI = Int32(pal.latitude * 1e7)
				position.longitudeI = Int32(pal.longitude * 1e7)
				position.altitude = Int32(pal.altitude)
				position.time = node.lastHeard
				position.latest = true
				position.nodePosition = node
				context.insert(position)
			}

			// Seed a battery telemetry entry
			let telemetry = TelemetryEntity()
			telemetry.batteryLevel = Int32(pal.batteryLevel)
			telemetry.metricsType = 0
			telemetry.time = Date()
			telemetry.nodeTelemetry = node
			context.insert(telemetry)

			// If buddy check is enabled for this pal, create config
			if pal.buddyCheckEnabled {
				let buddyConfig = BuddyCheckConfiguration(
					nodeNum: nodeNum,
					thresholdMinutes: pal.buddyCheckThresholdMinutes
				)
				context.insert(buddyConfig)
			}
		}

		// Seed demo messages if configured
		for msg in config.messages {
			guard let palIndex = config.pals.firstIndex(where: { $0.id == msg.fromPalId }) else { continue }
			let nodeNum = Self.demoNodeNumBase + Int64(palIndex)

			let message = MessageEntity()
			message.messageId = Int64.random(in: 100_000...999_999)
			message.messageTimestamp = Int32(Date(timeIntervalSinceNow: -TimeInterval(msg.minutesAgo * 60)).timeIntervalSince1970)
			message.receivedACK = msg.acked
			message.read = msg.read
			message.isEmoji = false
			message.admin = false
			message.channel = 0
			context.insert(message)
		}

		try? context.save()
	}

	private func clearDemoData(context: ModelContext) {
		let baseNum = Self.demoNodeNumBase
		let maxNum = baseNum + 100

		// Delete demo nodes
		let nodePredicate = #Predicate<NodeInfoEntity> { node in
			node.num >= baseNum && node.num < maxNum
		}
		try? context.delete(model: NodeInfoEntity.self, where: nodePredicate)

		// Delete demo buddy check configs
		let buddyPredicate = #Predicate<BuddyCheckConfiguration> { config in
			config.nodeNum >= baseNum && config.nodeNum < maxNum
		}
		try? context.delete(model: BuddyCheckConfiguration.self, where: buddyPredicate)

		try? context.save()
	}
}
