import Foundation

struct DemoConfig: Codable {
	var pals: [DemoPal]
	var messages: [DemoMessage]
	var features: DemoFeatures

	struct DemoPal: Codable, Identifiable {
		var id: String
		var name: String
		var shortName: String
		var role: DemoRole
		var isOnline: Bool
		var lastHeardMinutesAgo: Int
		var batteryLevel: Int
		var hopsAway: Int
		var rssi: Int
		var snr: Float
		var encrypted: Bool

		// Position
		var hasPosition: Bool
		var latitude: Double
		var longitude: Double
		var altitude: Int

		// Buddy Check
		var buddyCheckEnabled: Bool
		var buddyCheckThresholdMinutes: Int

		// MeshKit display
		var palColorIndex: Int
	}

	struct DemoMessage: Codable {
		var fromPalId: String
		var text: String
		var minutesAgo: Int
		var acked: Bool
		var read: Bool
	}

	struct DemoFeatures: Codable {
		var buddyCheckEnabled: Bool
		var quickMessagesEnabled: Bool
		var familyModeEnabled: Bool
		var nodeProfilesEnabled: Bool
		var trailBreadcrumbsEnabled: Bool
		var kidViewEnabled: Bool
	}

	enum DemoRole: Int, Codable {
		case client = 0
		case clientMute = 1
		case router = 2
		case routerClient = 3
		case repeater = 4
		case tracker = 5
		case sensor = 6
	}
}

extension DemoConfig {
	/// Bay Area camping scenario with 5 family members
	static let `default` = DemoConfig(
		pals: [
			DemoPal(
				id: "dad",
				name: "Dad",
				shortName: "DAD",
				role: .client,
				isOnline: true,
				lastHeardMinutesAgo: 1,
				batteryLevel: 87,
				hopsAway: 0,
				rssi: -62,
				snr: 10.5,
				encrypted: true,
				hasPosition: true,
				latitude: 37.9040,
				longitude: -122.5965,
				altitude: 220,
				buddyCheckEnabled: true,
				buddyCheckThresholdMinutes: 15,
				palColorIndex: 0
			),
			DemoPal(
				id: "mom",
				name: "Mom",
				shortName: "MOM",
				role: .client,
				isOnline: true,
				lastHeardMinutesAgo: 3,
				batteryLevel: 74,
				hopsAway: 0,
				rssi: -71,
				snr: 7.2,
				encrypted: true,
				hasPosition: true,
				latitude: 37.9045,
				longitude: -122.5958,
				altitude: 225,
				buddyCheckEnabled: true,
				buddyCheckThresholdMinutes: 15,
				palColorIndex: 1
			),
			DemoPal(
				id: "mia",
				name: "Mia",
				shortName: "MIA",
				role: .client,
				isOnline: true,
				lastHeardMinutesAgo: 7,
				batteryLevel: 52,
				hopsAway: 1,
				rssi: -88,
				snr: 3.1,
				encrypted: true,
				hasPosition: true,
				latitude: 37.9058,
				longitude: -122.5940,
				altitude: 280,
				buddyCheckEnabled: true,
				buddyCheckThresholdMinutes: 15,
				palColorIndex: 2
			),
			DemoPal(
				id: "jake",
				name: "Jake",
				shortName: "JKE",
				role: .client,
				isOnline: true,
				lastHeardMinutesAgo: 12,
				batteryLevel: 34,
				hopsAway: 2,
				rssi: -95,
				snr: 0.8,
				encrypted: true,
				hasPosition: true,
				latitude: 37.9020,
				longitude: -122.5980,
				altitude: 195,
				buddyCheckEnabled: true,
				buddyCheckThresholdMinutes: 15,
				palColorIndex: 3
			),
			DemoPal(
				id: "repeater",
				name: "Camp Repeater",
				shortName: "RPT",
				role: .repeater,
				isOnline: true,
				lastHeardMinutesAgo: 0,
				batteryLevel: 95,
				hopsAway: 0,
				rssi: -55,
				snr: 12.0,
				encrypted: true,
				hasPosition: true,
				latitude: 37.9035,
				longitude: -122.5970,
				altitude: 350,
				buddyCheckEnabled: false,
				buddyCheckThresholdMinutes: 30,
				palColorIndex: 4
			)
		],
		messages: [
			DemoMessage(fromPalId: "mom", text: "Heading back to camp", minutesAgo: 5, acked: true, read: true),
			DemoMessage(fromPalId: "mia", text: "Found a cool tide pool!", minutesAgo: 8, acked: true, read: false),
			DemoMessage(fromPalId: "jake", text: "At the creek", minutesAgo: 15, acked: true, read: true),
			DemoMessage(fromPalId: "dad", text: "Starting the fire soon", minutesAgo: 2, acked: true, read: true),
		],
		features: DemoFeatures(
			buddyCheckEnabled: true,
			quickMessagesEnabled: true,
			familyModeEnabled: false,
			nodeProfilesEnabled: true,
			trailBreadcrumbsEnabled: true,
			kidViewEnabled: false
		)
	)
}
