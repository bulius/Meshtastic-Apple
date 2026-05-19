import Foundation

enum MeshKitFeatureFlags {
	@MeshKitFlag("buddyCheck", default: true)
	static var buddyCheckEnabled: Bool

	@MeshKitFlag("quickMessages", default: true)
	static var quickMessagesEnabled: Bool

	@MeshKitFlag("familyMode", default: false)
	static var familyModeEnabled: Bool

	@MeshKitFlag("nodeProfiles", default: true)
	static var nodeProfilesEnabled: Bool

	@MeshKitFlag("trailBreadcrumbs", default: true)
	static var trailBreadcrumbsEnabled: Bool

	@MeshKitFlag("kidView", default: false)
	static var kidViewEnabled: Bool
}

@propertyWrapper
struct MeshKitFlag {
	let key: String
	let defaultValue: Bool

	init(_ key: String, default defaultValue: Bool) {
		self.key = "meshkit.feature.\(key)"
		self.defaultValue = defaultValue
	}

	var wrappedValue: Bool {
		get { UserDefaults.standard.object(forKey: key) as? Bool ?? defaultValue }
		nonmutating set { UserDefaults.standard.set(newValue, forKey: key) }
	}
}
