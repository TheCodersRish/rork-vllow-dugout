enum ConditioningCategory {
  power('Power'),
  endurance('Endurance'),
  mobility('Mobility'),
  cricketMovement('Cricket Movement');

  final String displayName;
  const ConditioningCategory(this.displayName);
}

enum VideoStatus {
  pending('Pending'),
  uploading('Uploading'),
  analyzing('Analyzing'),
  completed('Completed');

  final String displayName;
  const VideoStatus(this.displayName);
}

enum SubscriptionTier {
  rookie('Rookie Kit', 1.0),
  dugout('Dugout Pro', 1.25),
  pavilion('Pavilion Elite', 1.5),
  nextGen('Next Gen Youth', 1.3);

  final String displayName;
  final double coinMultiplier;
  const SubscriptionTier(this.displayName, this.coinMultiplier);
}

class MentalCheckIn {
  final int mood;
  final int focus;
  final int confidence;
  final String note;
  final DateTime createdAt;

  MentalCheckIn({
    required this.mood,
    required this.focus,
    required this.confidence,
    required this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MentalCheckIn.fromJson(Map<String, dynamic> json) {
    return MentalCheckIn(
      mood: json['mood'] as int,
      focus: json['focus'] as int,
      confidence: json['confidence'] as int,
      note: json['note'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  double get averageScore => (mood + focus + confidence) / 3;

  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'focus': focus,
      'confidence': confidence,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class JournalEntry {
  final String prompt;
  final String response;
  final DateTime createdAt;

  JournalEntry({
    required this.prompt,
    required this.response,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      prompt: json['prompt'] as String,
      response: json['response'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'response': response,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ConditioningLog {
  final ConditioningCategory category;
  final int effort;
  final String notes;
  final bool niggleFlagged;
  final DateTime createdAt;

  ConditioningLog({
    required this.category,
    required this.effort,
    required this.notes,
    required this.niggleFlagged,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ConditioningLog.fromJson(Map<String, dynamic> json) {
    return ConditioningLog(
      category: ConditioningCategory.values.firstWhere(
        (category) => category.name == json['category'],
        orElse: () => ConditioningCategory.power,
      ),
      effort: json['effort'] as int,
      notes: json['notes'] as String? ?? '',
      niggleFlagged: json['niggleFlagged'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'effort': effort,
      'notes': notes,
      'niggleFlagged': niggleFlagged,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MealLog {
  final String title;
  final String context;
  final DateTime createdAt;

  MealLog({
    required this.title,
    required this.context,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      title: json['title'] as String,
      context: json['context'] as String? ?? 'Training day',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'context': context,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class VideoAnalysisItem {
  final String title;
  final String tag;
  final VideoStatus status;
  final List<String> strengths;
  final List<String> priorities;
  final DateTime createdAt;

  VideoAnalysisItem({
    required this.title,
    required this.tag,
    required this.status,
    this.strengths = const [],
    this.priorities = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory VideoAnalysisItem.fromJson(Map<String, dynamic> json) {
    return VideoAnalysisItem(
      title: json['title'] as String,
      tag: json['tag'] as String,
      status: VideoStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => VideoStatus.pending,
      ),
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          const [],
      priorities: (json['priorities'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  VideoAnalysisItem copyWith({
    VideoStatus? status,
    List<String>? strengths,
    List<String>? priorities,
  }) {
    return VideoAnalysisItem(
      title: title,
      tag: tag,
      status: status ?? this.status,
      strengths: strengths ?? this.strengths,
      priorities: priorities ?? this.priorities,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'tag': tag,
      'status': status.name,
      'strengths': strengths,
      'priorities': priorities,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CoachReviewRequest {
  final String coachName;
  final String tier;
  final String notes;
  final bool delivered;
  final DateTime createdAt;

  CoachReviewRequest({
    required this.coachName,
    required this.tier,
    required this.notes,
    this.delivered = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CoachReviewRequest.fromJson(Map<String, dynamic> json) {
    return CoachReviewRequest(
      coachName: json['coachName'] as String,
      tier: json['tier'] as String,
      notes: json['notes'] as String? ?? '',
      delivered: json['delivered'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  CoachReviewRequest copyWith({bool? delivered}) {
    return CoachReviewRequest(
      coachName: coachName,
      tier: tier,
      notes: notes,
      delivered: delivered ?? this.delivered,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coachName': coachName,
      'tier': tier,
      'notes': notes,
      'delivered': delivered,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CommunityPost {
  final String author;
  final String body;
  final int reactions;
  final bool reported;
  final DateTime createdAt;

  CommunityPost({
    required this.author,
    required this.body,
    this.reactions = 0,
    this.reported = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      author: json['author'] as String,
      body: json['body'] as String,
      reactions: json['reactions'] as int? ?? 0,
      reported: json['reported'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  CommunityPost copyWith({int? reactions, bool? reported}) {
    return CommunityPost(
      author: author,
      body: body,
      reactions: reactions ?? this.reactions,
      reported: reported ?? this.reported,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'body': body,
      'reactions': reactions,
      'reported': reported,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ShareCardDraft {
  final String format;
  final String caption;
  final bool includeStats;
  final DateTime createdAt;

  ShareCardDraft({
    required this.format,
    required this.caption,
    required this.includeStats,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ShareCardDraft.fromJson(Map<String, dynamic> json) {
    return ShareCardDraft(
      format: json['format'] as String,
      caption: json['caption'] as String,
      includeStats: json['includeStats'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'caption': caption,
      'includeStats': includeStats,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
