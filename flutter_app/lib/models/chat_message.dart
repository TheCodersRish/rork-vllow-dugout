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

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ChatMessage && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
