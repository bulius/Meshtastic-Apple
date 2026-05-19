import Foundation
import SwiftData
import OSLog
import UserNotifications

@MainActor
@Observable
final class BuddyCheckMonitor {
	private(set) var alerts: [BuddyAlert] = []
	private var timer: Timer?
	private let checkInterval: TimeInterval = 60

	private let logger = Logger(subsystem: "com.meshkit", category: "BuddyCheck")

	struct BuddyAlert: Identifiable, Equatable {
		let id: Int64
		let nodeNum: Int64
		let nodeName: String
		let lastHeard: Date
		let thresholdMinutes: Int

		var silenceDuration: TimeInterval {
			Date.now.timeIntervalSince(lastHeard)
		}

		var silenceDurationText: String {
			let minutes = Int(silenceDuration / 60)
			if minutes < 60 {
				return "\(minutes)m"
			}
			let hours = minutes / 60
			let remaining = minutes % 60
			return remaining > 0 ? "\(hours)h \(remaining)m" : "\(hours)h"
		}
	}

	func start(context: ModelContext) {
		guard MeshKitFeatureFlags.buddyCheckEnabled else { return }
		stop()
		logger.info("Buddy Check monitor started")
		timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
			Task { @MainActor in
				self?.check(context: context)
			}
		}
		check(context: context)
	}

	func stop() {
		timer?.invalidate()
		timer = nil
	}

	func dismissAlert(for nodeNum: Int64) {
		alerts.removeAll { $0.nodeNum == nodeNum }
	}

	func check(context: ModelContext) {
		guard MeshKitFeatureFlags.buddyCheckEnabled else {
			alerts = []
			return
		}

		let configs = fetchEnabledConfigs(context: context)
		guard !configs.isEmpty else {
			alerts = []
			return
		}

		var newAlerts: [BuddyAlert] = []

		for config in configs {
			guard let node = fetchNode(num: config.nodeNum, context: context) else { continue }
			guard let lastHeard = node.lastHeard else { continue }

			let elapsed = Date.now.timeIntervalSince(lastHeard)
			if elapsed > config.thresholdInterval {
				let name = node.user?.longName ?? "Unknown Pal"
				let alert = BuddyAlert(
					id: config.nodeNum,
					nodeNum: config.nodeNum,
					nodeName: name,
					lastHeard: lastHeard,
					thresholdMinutes: config.thresholdMinutes
				)
				newAlerts.append(alert)

				if !alerts.contains(where: { $0.nodeNum == config.nodeNum }) {
					sendNotification(for: alert)
				}
			}
		}

		alerts = newAlerts
	}

	private func fetchEnabledConfigs(context: ModelContext) -> [BuddyCheckConfiguration] {
		let descriptor = FetchDescriptor<BuddyCheckConfiguration>(
			predicate: #Predicate<BuddyCheckConfiguration> { $0.isEnabled }
		)
		return (try? context.fetch(descriptor)) ?? []
	}

	private func fetchNode(num: Int64, context: ModelContext) -> NodeInfoEntity? {
		var descriptor = FetchDescriptor<NodeInfoEntity>(
			predicate: #Predicate<NodeInfoEntity> { $0.num == num }
		)
		descriptor.fetchLimit = 1
		return try? context.fetch(descriptor).first
	}

	private func sendNotification(for alert: BuddyAlert) {
		let content = UNMutableNotificationContent()
		content.title = "Buddy Check"
		content.body = "Haven't heard from \(alert.nodeName) in \(alert.silenceDurationText)"
		content.sound = .default
		content.interruptionLevel = .timeSensitive

		let request = UNNotificationRequest(
			identifier: "meshkit.buddycheck.\(alert.nodeNum)",
			content: content,
			trigger: nil
		)

		UNUserNotificationCenter.current().add(request) { [logger] error in
			if let error {
				logger.error("Failed to send buddy check notification: \(error.localizedDescription)")
			}
		}
	}
}
