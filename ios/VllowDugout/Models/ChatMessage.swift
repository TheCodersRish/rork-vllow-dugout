import Foundation

nonisolated struct ChatMessage: Identifiable, Hashable, Sendable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    let drillAttachment: DrillAttachment?
    let suggestedQuestions: [String]

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        drillAttachment: DrillAttachment? = nil,
        suggestedQuestions: [String] = []
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.drillAttachment = drillAttachment
        self.suggestedQuestions = suggestedQuestions
    }
}

nonisolated enum MessageRole: String, Sendable {
    case user
    case assistant
}

nonisolated struct DrillAttachment: Hashable, Sendable {
    let title: String
    let subtitle: String
    let imageURL: String
    let duration: String
    let linkedDrillID: UUID?

    init(title: String, subtitle: String, imageURL: String, duration: String, linkedDrillID: UUID? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.duration = duration
        self.linkedDrillID = linkedDrillID
    }

    static func fromDrill(_ drill: Drill) -> DrillAttachment {
        DrillAttachment(
            title: drill.title,
            subtitle: "\(drill.category.rawValue.uppercased()) • \(drill.durationFormatted)",
            imageURL: drill.imageURL,
            duration: drill.durationFormatted,
            linkedDrillID: drill.id
        )
    }
}
