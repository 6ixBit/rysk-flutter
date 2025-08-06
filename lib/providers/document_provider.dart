import 'package:flutter/material.dart';
import 'dart:io';
import '../models/document.dart';
import '../services/document_service.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentService _documentService = DocumentService();
  final List<Document> _documents = [];

  List<Document> get documents => List.unmodifiable(_documents);

  Future<void> processDocument(List<File> images, String title) async {
    try {
      print('🚀 Starting document processing: $title');

      // Create document with uploading status
      final document = Document(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        images: images,
        uploadDate: DateTime.now(),
        status: DocumentStatus.uploading,
      );

      print('📝 Created document with uploading status');

      // Add to list and notify listeners
      _documents.insert(0, document);
      notifyListeners();

      print('📤 Starting upload...');

      // Upload document
      final documentId = await _documentService.uploadDocument(images, title);

      print('✅ Upload completed, got ID: $documentId');

      // Update with processing status
      final uploadedDocument = document.copyWith(
        id: documentId,
        status: DocumentStatus.processing,
      );
      _updateDocument(uploadedDocument);

      print('🔄 Updated status to processing');

      // Process document
      print('🔍 Starting document analysis...');
      final analysis = await _documentService.processDocument(documentId);

      print('✅ Analysis completed');

      // Update with completed status
      final completedDocument = uploadedDocument.copyWith(
        status: DocumentStatus.completed,
        analysis: analysis,
      );
      _updateDocument(completedDocument);

      print('🎉 Document processing completed successfully');
    } catch (e, stackTrace) {
      print('❌ Error in document processing: $e');
      print('Stack trace: $stackTrace');

      // Handle error - make sure we have at least one document to update
      if (_documents.isNotEmpty) {
        final errorDocument = _documents.first.copyWith(
          status: DocumentStatus.failed,
          errorMessage: e.toString(),
        );
        _updateDocument(errorDocument);
      }
    }
  }

  void _updateDocument(Document updatedDocument) {
    final index = _documents.indexWhere((doc) => doc.id == updatedDocument.id);
    if (index != -1) {
      _documents[index] = updatedDocument;
      notifyListeners();
    }
  }

  Document? getDocument(String id) {
    try {
      return _documents.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  void removeDocument(String id) {
    _documents.removeWhere((doc) => doc.id == id);
    notifyListeners();
  }
}
