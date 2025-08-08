import 'dart:io';

enum DocumentStatus { uploading, processing, completed, failed }

class RiskyClause {
  final String id;
  final String title;
  final String description;
  final String clause;
  final int riskLevel; // 1-10
  final String explanation;
  final List<String> recommendations;

  RiskyClause({
    required this.id,
    required this.title,
    required this.description,
    required this.clause,
    required this.riskLevel,
    required this.explanation,
    required this.recommendations,
  });

  factory RiskyClause.fromJson(Map<String, dynamic> json) {
    return RiskyClause(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      clause: json['clause'] ?? '',
      riskLevel: json['riskLevel'] ?? 0,
      explanation: json['explanation'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

class DocumentAnalysis {
  final double overallRiskScore; // 0-100
  final String riskLevel; // Low, Medium, High, Critical
  final List<RiskyClause> topRiskyClauses;
  final String extractedText;
  final Map<String, dynamic> metadata;

  DocumentAnalysis({
    required this.overallRiskScore,
    required this.riskLevel,
    required this.topRiskyClauses,
    required this.extractedText,
    required this.metadata,
  });

  factory DocumentAnalysis.fromJson(Map<String, dynamic> json) {
    return DocumentAnalysis(
      overallRiskScore: (json['overallRiskScore'] ?? 0).toDouble(),
      riskLevel: json['riskLevel'] ?? 'Low',
      topRiskyClauses: (json['topRiskyClauses'] as List? ?? [])
          .map((clause) => RiskyClause.fromJson(clause))
          .toList(),
      extractedText: json['extractedText'] ?? '',
      metadata: json['metadata'] ?? {},
    );
  }
}

class Document {
  final String id;
  final String title;
  final List<File> images;
  final List<String> imageUrls; // For images stored in Supabase storage
  final DateTime uploadDate;
  final DocumentStatus status;
  final DocumentAnalysis? analysis;
  final String? errorMessage;

  Document({
    required this.id,
    required this.title,
    required this.images,
    required this.uploadDate,
    required this.status,
    this.analysis,
    this.errorMessage,
    this.imageUrls = const [],
  });

  Document copyWith({
    String? id,
    String? title,
    List<File>? images,
    List<String>? imageUrls,
    DateTime? uploadDate,
    DocumentStatus? status,
    DocumentAnalysis? analysis,
    String? errorMessage,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      images: images ?? this.images,
      imageUrls: imageUrls ?? this.imageUrls,
      uploadDate: uploadDate ?? this.uploadDate,
      status: status ?? this.status,
      analysis: analysis ?? this.analysis,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
