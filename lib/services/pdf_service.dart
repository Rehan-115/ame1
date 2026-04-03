import 'dart:convert';
import 'package:flutter/services.dart';

class PDFMetadata {
  final String title;
  final String filename;
  final String ammChapter;
  final String description;
  final Map<String, List<int>> searchIndex; // keyword -> [pages]

  PDFMetadata({
    required this.title,
    required this.filename,
    required this.ammChapter,
    required this.description,
    required this.searchIndex,
  });
}

class PDFReference {
  final String documentTitle;
  final String ammChapter;
  final int pageNumber;
  final String excerpt;
  final String searchTerm;

  PDFReference({
    required this.documentTitle,
    required this.ammChapter,
    required this.pageNumber,
    required this.excerpt,
    required this.searchTerm,
  });
}

class PDFService {
  // Comprehensive PDF metadata based on Airways Magazine documentation standards
  late Map<String, PDFMetadata> _pdfCatalog;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final catalogJson =
          await rootBundle.loadString('assets/data/pdf_catalog.json');
      final catalogData = jsonDecode(catalogJson) as Map<String, dynamic>;

      _pdfCatalog = {};
      catalogData.forEach((key, value) {
        final searchIndex = <String, List<int>>{};
        if (value['searchIndex'] is Map) {
          (value['searchIndex'] as Map).forEach((searchKey, pages) {
            searchIndex[searchKey] = List<int>.from(pages as List);
          });
        }

        _pdfCatalog[key] = PDFMetadata(
          title: value['title'] ?? '',
          filename: value['filename'] ?? '',
          ammChapter: value['ammChapter'] ?? '',
          description: value['description'] ?? '',
          searchIndex: searchIndex,
        );
      });

      _isInitialized = true;
    } catch (e) {
      print('Error loading PDF catalog: $e');
      _initializeDefaultCatalog();
    }
  }

  void _initializeDefaultCatalog() {
    _pdfCatalog = {
      'amm73': PDFMetadata(
        title: 'Aircraft Maintenance Manual - Engine Systems',
        filename: 'AMM-73-00-00.pdf',
        ammChapter: '73-00-00',
        description:
            'Complete engine maintenance procedures including oil changes, inspections, and repairs.',
        searchIndex: {
          'oil change': [1, 2, 3, 5],
          'torque': [4, 6, 7],
          'engine': [1, 2, 3, 4, 5, 6, 7, 8],
          'cfm56': [1, 2, 3],
          'jet oil': [3, 5],
        },
      ),
      'amm32': PDFMetadata(
        title: 'Aircraft Maintenance Manual - Landing Gear & Brakes',
        filename: 'AMM-32-00-00.pdf',
        ammChapter: '32-00-00',
        description:
            'Landing gear assembly, brake system maintenance, and hydraulic procedures.',
        searchIndex: {
          'landing gear': [1, 2, 3, 8, 9],
          'brake': [4, 5, 6, 10, 11],
          'torque': [2, 5, 9],
          'strut': [1, 2, 3],
          'hydraulic': [5, 6, 7],
          'pressure': [4, 5, 6, 7],
        },
      ),
      'amm57': PDFMetadata(
        title: 'Aircraft Maintenance Manual - Wing Group',
        filename: 'AMM-57-00-00.pdf',
        ammChapter: '57-00-00',
        description:
            'Wing attachment, structural maintenance, and fastener specifications.',
        searchIndex: {
          'wing': [1, 2, 3, 4, 5],
          'attachment': [2, 3, 4],
          'torque': [3, 4, 5],
          'fastener': [2, 3, 4, 5],
          'titanium': [2, 3, 4],
        },
      ),
      'amm29': PDFMetadata(
        title: 'Aircraft Maintenance Manual - Hydraulic Power',
        filename: 'AMM-29-00-00.pdf',
        ammChapter: '29-00-00',
        description:
            'Hydraulic system operations, maintenance, and fluid specifications.',
        searchIndex: {
          'hydraulic': [1, 2, 3, 4, 5],
          'pressure': [2, 3, 4],
          'fluid': [1, 2, 3, 5],
          'pump': [3, 4],
          'lines': [2, 3, 4],
        },
      ),
      'tsm': PDFMetadata(
        title: 'Troubleshooting Manual - System Diagnostics',
        filename: 'TSM-00-00-00.pdf',
        ammChapter: '00-00-00',
        description:
            'Comprehensive troubleshooting procedures for all aircraft systems and components.',
        searchIndex: {
          'warning': [1, 2, 3, 4],
          'fault': [1, 2, 3, 4, 5],
          'pressure': [2, 3],
          'temperature': [2, 3, 4],
          'diagnostic': [1, 2, 3, 4, 5],
        },
      ),
      'tem': PDFMetadata(
        title: 'Tool & Equipment Manual - TEM 05-00-00',
        filename: 'TEM-05-00-00.pdf',
        ammChapter: '05-00-00',
        description:
            'Required tools, test equipment, and calibration procedures for all maintenance tasks.',
        searchIndex: {
          'torque wrench': [1, 2, 3],
          'calibration': [1, 2, 3, 4],
          'wrench': [1, 2, 3],
          'tools': [1, 2, 3, 4, 5],
        },
      ),
    };
    _isInitialized = true;
  }

  /// Search across all PDF documents
  List<PDFReference> searchAll(String query) {
    final results = <PDFReference>[];
    final lowerQuery = query.toLowerCase();

    _pdfCatalog.forEach((key, metadata) {
      // Check if any search terms match
      metadata.searchIndex.forEach((term, pages) {
        if (term.contains(lowerQuery) || lowerQuery.contains(term)) {
          // Add references for each page where this term appears
          for (int page in pages) {
            results.add(PDFReference(
              documentTitle: metadata.title,
              ammChapter: metadata.ammChapter,
              pageNumber: page,
              excerpt: 'See ${metadata.ammChapter} for details on $term',
              searchTerm: term,
            ));
          }
        }
      });
    });

    return results;
  }

  /// Get PDF metadata for specific document
  PDFMetadata? getPDFMetadata(String ammChapter) {
    for (var metadata in _pdfCatalog.values) {
      if (metadata.ammChapter == ammChapter) {
        return metadata;
      }
    }
    return null;
  }

  /// Get all available documents
  List<PDFMetadata> getAllDocuments() {
    return _pdfCatalog.values.toList();
  }

  /// Get search suggestions from PDF index
  List<String> getSearchSuggestions(String prefix) {
    final suggestions = <String>{};

    _pdfCatalog.forEach((key, metadata) {
      metadata.searchIndex.forEach((term, _) {
        if (term.toLowerCase().startsWith(prefix.toLowerCase())) {
          suggestions.add(term);
        }
      });
    });

    return suggestions.toList()..sort();
  }
}
