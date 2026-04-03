import 'package:flutter/material.dart';
import '../../services/pdf_service.dart';
import '../../core/theme/app_theme.dart';

class DocumentationScreen extends StatefulWidget {
  const DocumentationScreen({Key? key}) : super(key: key);

  @override
  State<DocumentationScreen> createState() => _DocumentationScreenState();
}

class _DocumentationScreenState extends State<DocumentationScreen> {
  late PDFService _pdfService;
  List<PDFMetadata> _documents = [];
  List<PDFReference> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _pdfService = PDFService();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    await _pdfService.init();
    setState(() {
      _documents = _pdfService.getAllDocuments();
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    final results = _pdfService.searchAll(query);
    setState(() {
      _searchResults = results;
      _showSearchResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentation & Manuals'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search manuals... (e.g., "torque", "landing gear")',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: _showSearchResults
                ? _buildSearchResults()
                : _buildDocumentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 64, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.picture_as_pdf,
                  color: AppTheme.primaryColor, size: 28),
            ),
            title: Text(
              result.documentTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Search Term: "${result.searchTerm}"',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '📄 Page ${result.pageNumber} • ${result.ammChapter}',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            trailing:
                const Icon(Icons.open_in_new, color: AppTheme.primaryColor),
            onTap: () {
              _showPDFPreview(result);
            },
          ),
        );
      },
    );
  }

  Widget _buildDocumentList() {
    if (_documents.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final doc = _documents[index];
        return _buildDocumentCard(doc);
      },
    );
  }

  Widget _buildDocumentCard(PDFMetadata doc) {
    final categoryColors = {
      'Aircraft Maintenance Manual': Colors.blue,
      'Troubleshooting Manual': Colors.orange,
      'Tool & Equipment Manual': Colors.green,
      'Component Maintenance Manual': Colors.purple,
      'Structural Repair Manual': Colors.red,
    };

    final categoryColor =
        categoryColors[doc.description.split('.').first] ?? Colors.blue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.picture_as_pdf, color: categoryColor, size: 32),
        ),
        title: Text(
          doc.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              doc.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(doc.ammChapter),
                  backgroundColor: categoryColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: categoryColor, fontSize: 11),
                ),
                Chip(
                  label: Text('${doc.searchIndex.length} topics'),
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward, color: categoryColor),
        onTap: () => _showDocumentDetail(doc),
      ),
    );
  }

  void _showDocumentDetail(PDFMetadata doc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.picture_as_pdf,
                        color: AppTheme.primaryColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.ammChapter,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          doc.title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                doc.description,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Key Topics:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: doc.searchIndex.keys
                          .take(8)
                          .map((topic) => Chip(
                                label: Text(topic),
                                labelStyle: const TextStyle(fontSize: 11),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showPDFViewer(doc);
                  },
                  icon: const Icon(Icons.open_in_full),
                  label: const Text('Open PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPDFPreview(PDFReference result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Reference'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.documentTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Page: ${result.pageNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Chapter: ${result.ammChapter}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Search: "${result.searchTerm}"',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(result.excerpt),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPDFViewer(_pdfService.getPDFMetadata(result.ammChapter)!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child:
                const Text('View PDF', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPDFViewer(PDFMetadata doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc.ammChapter),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.picture_as_pdf,
                      size: 64, color: AppTheme.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    doc.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    doc.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // In production, this would open the actual PDF file
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening ${doc.filename}...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
