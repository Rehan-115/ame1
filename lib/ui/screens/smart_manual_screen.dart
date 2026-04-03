import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import '../../core/theme/app_theme.dart';

class SmartManualScreen extends StatefulWidget {
  const SmartManualScreen({super.key});

  @override
  State<SmartManualScreen> createState() => _SmartManualScreenState();
}

class _SmartManualScreenState extends State<SmartManualScreen> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _filteredResults = [];
  List<Map<String, dynamic>> _allData = [];
  bool _isSearching = false;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load maintenance procedures
      final procJson = await rootBundle.loadString(
        'assets/data/maintenance_procedures.json',
      );
      final procData = jsonDecode(procJson);
      final procedures = procData['procedures'] as List<dynamic>? ?? [];

      // Load torque specs
      final torqueJson = await rootBundle.loadString(
        'assets/data/torque_specs.json',
      );
      final torqueData = jsonDecode(torqueJson);
      final specs = torqueData['specs'] as List<dynamic>? ?? [];

      final allData = <Map<String, dynamic>>[];

      // Add procedures
      for (final proc in procedures) {
        allData.add({
          'type': 'procedure',
          'category': 'Procedures',
          'title': proc['name']?.toString() ?? '',
          'subtitle': 'Aircraft: ${proc['aircraftType']?.toString() ?? ''}',
          'details':
              '${proc['description']?.toString() ?? ''}\n\nEstimated Time: ${proc['estimatedTime']?.toString() ?? 'N/A'}\nSteps: ${(proc['steps'] as List?)?.length ?? 0}',
          'icon': Icons.build,
          'color': Colors.blue,
        });
      }

      // Add torque specs
      for (final spec in specs) {
        allData.add({
          'type': 'torque',
          'category': 'Torque Specs',
          'title': '${spec['component']} - ${spec['bolt']}',
          'subtitle': 'Torque: ${spec['value']} ${spec['unit']}',
          'details':
              'Range: ${spec['range']}\nProcedure: ${spec['procedure']}\nSafety: ${spec['safety'] ?? 'Standard practice'}',
          'icon': Icons.settings,
          'color': Colors.orange,
        });
      }

      setState(() => _allData = allData);
      _updateResults();
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  void _updateResults() {
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      final query = _searchController.text.toLowerCase();
      final filtered = _allData.where((item) {
        final matchesCategory =
            _selectedCategory == 'all' || item['category'] == _selectedCategory;
        final matchesQuery = query.isEmpty ||
            item['title'].toString().toLowerCase().contains(query) ||
            item['subtitle'].toString().toLowerCase().contains(query);
        return matchesCategory && matchesQuery;
      }).toList();

      setState(() {
        _filteredResults = filtered;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Smart Manual'),
          elevation: 2,
        ),
        body: Column(
          children: [
            // Category Filter
            Padding(
              padding: EdgeInsets.all(12.w),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('All', 'all'),
                    SizedBox(width: 8.w),
                    _buildCategoryChip('Procedures', 'Procedures'),
                    SizedBox(width: 8.w),
                    _buildCategoryChip('Torque Specs', 'Torque Specs'),
                  ],
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _updateResults(),
                decoration: InputDecoration(
                  hintText: 'Search procedures and specs...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppTheme.textMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _updateResults();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryColor, width: 2),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                ),
              ),
            ),

            // Results
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredResults.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          itemCount: _filteredResults.length,
                          itemBuilder: (context, index) =>
                              _buildResultCard(_filteredResults[index]),
                        ),
            ),
          ],
        ),
      );

  Widget _buildCategoryChip(String label, String value) => FilterChip(
        label: Text(label),
        selected: _selectedCategory == value,
        onSelected: (_) {
          setState(() => _selectedCategory = value);
          _updateResults();
        },
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 48.sp, color: const Color(0xFFE0E0E0)),
            SizedBox(height: 16.h),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textGrey,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try searching for procedures,\ntorque specs, or components',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      );

  Widget _buildResultCard(Map<String, dynamic> item) => InkWell(
        onTap: () => _showDetailDialog(item),
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppTheme.textGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textGrey,
                size: 16.sp,
              ),
            ],
          ),
        ),
      );

  void _showDetailDialog(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            item['category'] as String,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: item['color'] as Color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item['details'] as String,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.textGrey,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
