import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/document.dart';
import '../config/supabase_config.dart';

class SupabaseDocumentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Document>> fetchDocuments({int limit = 20}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final rows = await _supabase
        .from('documents')
        .select(
          'id, title, status, upload_date, overall_risk_score, risk_level, metadata',
        )
        .eq('user_id', user.id)
        .order('upload_date', ascending: false)
        .limit(limit);

    final List<Document> docs = [];
    for (final row in rows as List) {
      final String docId = row['id'] as String;
      final images = await _fetchDocumentImages(docId);

      final statusStr = row['status'] as String? ?? 'completed';
      final status = _mapStatus(statusStr);

      final double? riskScore = row['overall_risk_score'] != null
          ? (row['overall_risk_score'] as num).toDouble()
          : null;
      final String? riskLevel = row['risk_level'] as String?;

      final analysis = (riskScore != null && riskLevel != null)
          ? DocumentAnalysis(
              overallRiskScore: riskScore,
              riskLevel: riskLevel,
              topRiskyClauses: const [],
              extractedText: '',
              metadata:
                  (row['metadata'] as Map?)?.cast<String, dynamic>() ?? {},
            )
          : null;

      docs.add(
        Document(
          id: docId,
          title: row['title'] as String? ?? 'Untitled Document',
          images: const [],
          imageUrls: images,
          uploadDate:
              DateTime.tryParse(row['upload_date']?.toString() ?? '') ??
              DateTime.now(),
          status: status,
          analysis: analysis,
        ),
      );
    }

    return docs;
  }

  Future<List<String>> _fetchDocumentImages(String documentId) async {
    final rows = await _supabase
        .from('document_images')
        .select('image_url, page_number')
        .eq('document_id', documentId)
        .order('page_number');

    final List<String> urls = [];
    for (final row in rows as List) {
      final path = row['image_url'] as String; // expecting storage path
      try {
        final signedUrl = await _supabase.storage
            .from(SupabaseConfig.documentImagesBucket)
            .createSignedUrl(path, 60 * 60); // 1 hour
        urls.add(signedUrl);
      } catch (_) {
        // Fallback to public URL if signed fails (e.g., bucket accidentally public)
        final publicUrl = _supabase.storage
            .from(SupabaseConfig.documentImagesBucket)
            .getPublicUrl(path);
        urls.add(publicUrl);
      }
    }
    return urls;
  }

  DocumentStatus _mapStatus(String status) {
    switch (status) {
      case 'uploading':
        return DocumentStatus.uploading;
      case 'processing':
        return DocumentStatus.processing;
      case 'failed':
        return DocumentStatus.failed;
      case 'completed':
      default:
        return DocumentStatus.completed;
    }
  }

  Future<String> createDocument({
    required String title,
    int? pageCount,
    int? fileSizeBytes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final row = await _supabase
        .from('documents')
        .insert({
          'user_id': user.id,
          'title': title,
          'status': 'uploading',
          'page_count': pageCount,
          'file_size_bytes': fileSizeBytes,
        })
        .select('id')
        .single();

    return row['id'] as String;
  }

  Future<List<String>> uploadImagesAndInsert({
    required String documentId,
    required List<File> files,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final List<String> storagePaths = [];
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final ext = p.extension(file.path).toLowerCase();
      final pageNum = i + 1;
      final objectPath = '${user.id}/$documentId/page_$pageNum$ext';

      final bytes = await file.readAsBytes();
      await _supabase.storage
          .from(SupabaseConfig.documentImagesBucket)
          .uploadBinary(
            objectPath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      storagePaths.add(objectPath);

      await _supabase.from('document_images').insert({
        'document_id': documentId,
        'image_url': objectPath,
        'page_number': pageNum,
        'file_name': p.basename(file.path),
        'file_size_bytes': await file.length(),
      });
    }

    // Update page count and status to processing after upload
    await _supabase
        .from('documents')
        .update({'status': 'processing', 'page_count': files.length})
        .eq('id', documentId);

    return storagePaths;
  }

  Future<void> updateDocumentStatus(String documentId, String status) async {
    await _supabase
        .from('documents')
        .update({'status': status})
        .eq('id', documentId);
  }

  Future<Document?> getDocumentById(String id) async {
    final rows = await _supabase
        .from('documents')
        .select(
          'id, title, status, upload_date, overall_risk_score, risk_level, metadata',
        )
        .eq('id', id)
        .limit(1);
    if (rows is List && rows.isNotEmpty) {
      final row = rows.first;
      final images = await _fetchDocumentImages(id);
      final status = _mapStatus(row['status'] as String? ?? 'processing');
      final riskScore = row['overall_risk_score'] != null
          ? (row['overall_risk_score'] as num).toDouble()
          : null;
      final riskLevel = row['risk_level'] as String?;
      final analysis = (riskScore != null && riskLevel != null)
          ? DocumentAnalysis(
              overallRiskScore: riskScore,
              riskLevel: riskLevel,
              topRiskyClauses: const [],
              extractedText: '',
              metadata:
                  (row['metadata'] as Map?)?.cast<String, dynamic>() ?? {},
            )
          : null;

      return Document(
        id: id,
        title: row['title'] as String? ?? 'Untitled Document',
        images: const [],
        imageUrls: images,
        uploadDate:
            DateTime.tryParse(row['upload_date']?.toString() ?? '') ??
            DateTime.now(),
        status: status,
        analysis: analysis,
      );
    }
    return null;
  }
}
