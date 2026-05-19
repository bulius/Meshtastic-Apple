import Foundation
import SwiftData

@Model
final class BuddyCheckConfiguration {
	var nodeNum: Int64
	var isEnabled: Bool = true
	var thresholdMinutes: Int = 15

	init(nodeNum: Int64, thresholdMinutes: Int = 15) {
		self.nodeNum = nodeNum
		self.thresholdMinutes = thresholdMinutes
	}

	var thresholdInterval: TimeInterval {
		TimeInterval(thresholdMinutes * 60)
	}
}
