import 'package:uuid/uuid.dart';
import 'drill.dart';

enum MessageRole {
  user,
  assistant,
}

class DrillAttachment {
  final String title;
  final String subtitle;
  final String imageURL;
  final String duration;
  final String? linkedDrillID;

  DrillAttachment({
    required this.title,
    required this.subtitle,
    required this.imageURL,
    required this.duration,
    this.linkedDrillID,
  });

  factory DrillAttachment.fromDrill(Drill drill) {
    return DrillAttachment(
      title: drill.title,
      subtitle:
          '${drill.category.displayName.toUpperCase()} • ${drill.durationFormatted}',
      imageURL: drill.imageURL,
      duration: drill.durationFormatted,
      linkedDrillID: drill.id,
    );
  }

  factory DrillAttachment.fromJson(Map<String, dynamic> json) {
    return DrillAttachment(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageURL: json['imageURL'] as String,
      duration: json['duration'] as String,
      linkedDrillID: json['linkedDrillID'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'imageURL': imageURL,
      'duration': duration,
      'linkedDrillID': linkedDrillID,
    };
  }
}

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final DrillAttachment? drillAttachment;
  final List<String> suggestedQuestions;

  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.drillAttachment,
    this.suggestedQuestions = const [],
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String?,
      role: MessageRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => MessageRole.assistant,
      ),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      drillAttachment: json['drillAttachment'] == null
          ? null
          : DrillAttachment.fromJson(
              Map<String, dynamic>.from(json['drillAttachment'] as Map),
            ),
      suggestedQuestions: (json['suggestedQuestions'] as List<dynamic>?)
              ?.map((question) => question as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'drillAttachment': drillAttachment?.toJson(),
      'suggestedQuestions': suggestedQuestions,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ChatMessage && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
