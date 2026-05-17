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
  final String drillPrescription;
  final DateTime createdAt;

  VideoAnalysisItem({
    required this.title,
    required this.tag,
    required this.status,
    this.strengths = const [],
    this.priorities = const [],
    this.drillPrescription = '',
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
      drillPrescription: json['drillPrescription'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  VideoAnalysisItem copyWith({
    VideoStatus? status,
    List<String>? strengths,
    List<String>? priorities,
    String? drillPrescription,
  }) {
    return VideoAnalysisItem(
      title: title,
      tag: tag,
      status: status ?? this.status,
      strengths: strengths ?? this.strengths,
      priorities: priorities ?? this.priorities,
      drillPrescription: drillPrescription ?? this.drillPrescription,
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
      'drillPrescription': drillPrescription,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CoachReviewRequest {
  final String coachName;
  final String tier;
  final String notes;
  final bool delivered;
  final String feedback;
  final DateTime createdAt;

  CoachReviewRequest({
    required this.coachName,
    required this.tier,
    required this.notes,
    this.delivered = false,
    this.feedback = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CoachReviewRequest.fromJson(Map<String, dynamic> json) {
    return CoachReviewRequest(
      coachName: json['coachName'] as String,
      tier: json['tier'] as String,
      notes: json['notes'] as String? ?? '',
      delivered: json['delivered'] as bool? ?? false,
      feedback: json['feedback'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  CoachReviewRequest copyWith({bool? delivered, String? feedback}) {
    return CoachReviewRequest(
      coachName: coachName,
      tier: tier,
      notes: notes,
      delivered: delivered ?? this.delivered,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coachName': coachName,
      'tier': tier,
      'notes': notes,
      'delivered': delivered,
      'feedback': feedback,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CommunityPost {
  final String author;
  final String body;
  final int reactions;
  final int comments;
  final bool reported;
  final bool blocked;
  final DateTime createdAt;

  CommunityPost({
    required this.author,
    required this.body,
    this.reactions = 0,
    this.comments = 0,
    this.reported = false,
    this.blocked = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      author: json['author'] as String,
      body: json['body'] as String,
      reactions: json['reactions'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      reported: json['reported'] as bool? ?? false,
      blocked: json['blocked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  CommunityPost copyWith({
    int? reactions,
    int? comments,
    bool? reported,
    bool? blocked,
  }) {
    return CommunityPost(
      author: author,
      body: body,
      reactions: reactions ?? this.reactions,
      comments: comments ?? this.comments,
      reported: reported ?? this.reported,
      blocked: blocked ?? this.blocked,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'body': body,
      'reactions': reactions,
      'comments': comments,
      'reported': reported,
      'blocked': blocked,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ShareCardDraft {
  final String format;
  final String caption;
  final bool includeStats;
  final bool saved;
  final bool shared;
  final DateTime createdAt;

  ShareCardDraft({
    required this.format,
    required this.caption,
    required this.includeStats,
    this.saved = false,
    this.shared = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ShareCardDraft.fromJson(Map<String, dynamic> json) {
    return ShareCardDraft(
      format: json['format'] as String,
      caption: json['caption'] as String,
      includeStats: json['includeStats'] as bool? ?? true,
      saved: json['saved'] as bool? ?? false,
      shared: json['shared'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  ShareCardDraft copyWith({bool? saved, bool? shared}) {
    return ShareCardDraft(
      format: format,
      caption: caption,
      includeStats: includeStats,
      saved: saved ?? this.saved,
      shared: shared ?? this.shared,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'caption': caption,
      'includeStats': includeStats,
      'saved': saved,
      'shared': shared,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
