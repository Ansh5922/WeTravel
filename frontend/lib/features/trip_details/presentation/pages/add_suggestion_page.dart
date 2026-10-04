import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../trips/presentation/widgets/invite_screen_decorations.dart';
import '../../domain/entities/trip_suggestion.dart';

/// "Add Suggestion" screen matching the WeTravel design screenshot.
/// Allows travelers to search places, manually configure an idea with category,
/// estimated cost, and reason, or pick from popular category-filtered suggestions.
class AddSuggestionPage extends StatefulWidget {
  final String tripId;

  const AddSuggestionPage({
    super.key,
    required this.tripId,
  });

  @override
  State<AddSuggestionPage> createState() => _AddSuggestionPageState();
}

class _AddSuggestionPageState extends State<AddSuggestionPage> {
  // ── Manual Input State ─────────────────────────────────────────────────────
  bool _isManualExpanded = true;
  String _selectedCategory = 'Activity';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _costController = TextEditingController(text: '0');
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // ── Filter State ───────────────────────────────────────────────────────────
  String _selectedFilter = 'Beaches';

  final List<String> _filters = const [
    'Beaches',
    'Restaurants',
    'Adventure',
    'Cultural',
  ];

  // ── Popular Suggestions Mock Data ──────────────────────────────────────────
  final List<Map<String, dynamic>> _allPopularSuggestions = [
    {
      'id': 'pop_1',
      'title': 'Dolphin watching',
      'cost': 1500,
      'distance': '3.5 km',
      'category': 'Beaches',
      'image': 'assets/images/dolphin_watching.jpg',
    },
    {
      'id': 'pop_2',
      'title': 'Trekking at Dudhsagar',
      'cost': 1200,
      'distance': '45 km',
      'category': 'Adventure',
      'image': 'assets/images/dudhsagar_falls.jpg',
    },
    {
      'id': 'pop_3',
      'title': 'Fort Aguada Sunset',
      'cost': 300,
      'distance': '8.2 km',
      'category': 'Cultural',
      'image': 'assets/images/trip_goa.jpg',
    },
    {
      'id': 'pop_4',
      'title': 'Fisherman’s Wharf Dining',
      'cost': 1100,
      'distance': '12 km',
      'category': 'Restaurants',
      'image': 'assets/images/beach_dinner.jpg',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    _reasonController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _submitManualIdea() {
    final title = _titleController.text.trim();
    final cost = int.tryParse(_costController.text.trim()) ?? 0;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a name/title for your suggestion',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFF004E64),
        ),
      );
      return;
    }

    final newSuggestion = TripSuggestion(
      id: 'sugg_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      estimatedCost: cost,
      approvalsCount: 1,
      totalMembers: 4,
      commentsCount: 0,
      imageUrl: 'assets/images/trip_goa.jpg',
      isApprovedByMe: true,
    );

    if (context.canPop()) {
      context.pop(newSuggestion);
    }
  }

  void _addPopularSuggestion(Map<String, dynamic> item) {
    final newSuggestion = TripSuggestion(
      id: 'sugg_${DateTime.now().millisecondsSinceEpoch}',
      title: item['title'] as String,
      estimatedCost: item['cost'] as int,
      approvalsCount: 1,
      totalMembers: 4,
      commentsCount: 0,
      imageUrl: item['image'] as String,
      isApprovedByMe: true,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added "${item['title']}" to group ideas!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF004E64),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    if (context.canPop()) {
      context.pop(newSuggestion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Filter suggestions based on search or category
    final searchQuery = _searchController.text.trim().toLowerCase();
    final displayedSuggestions = _allPopularSuggestions.where((s) {
      final matchesSearch = searchQuery.isEmpty ||
          (s['title'] as String).toLowerCase().contains(searchQuery);
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // ── Scrollable Body ──────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: topPadding + 68,
              bottom: bottomPadding + 32,
              left: 18,
              right: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── 1. Search Bar ──────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search places / restaurants',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF007791),
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // ── 2. "Add manually" Expandable Card ──────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isManualExpanded = !_isManualExpanded;
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDEF2F1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Color(0xFF004E64),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Add manually',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF004E64),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFDEF2F1).withValues(alpha: 0.5),
                              ),
                              child: Icon(
                                _isManualExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: const Color(0xFF007791),
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Collapsible Content
                      if (_isManualExpanded) ...[
                        const SizedBox(height: 16),

                        // Idea Title Input
                        Text(
                          'Idea / Title',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF004E64),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: _titleController,
                            style: GoogleFonts.inter(fontSize: 13.5),
                            decoration: InputDecoration(
                              hintText: 'e.g. Scuba diving, Beach club party',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Row: Category & Estimated Cost
                        Row(
                          children: [
                            // Category Dropdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF004E64),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedCategory,
                                        isExpanded: true,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF007791),
                                        ),
                                        style: GoogleFonts.inter(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF004E64),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Activity',
                                            child: Text('Activity'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Dining',
                                            child: Text('Dining'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Sightseeing',
                                            child: Text('Sightseeing'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Nightlife',
                                            child: Text('Nightlife'),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedCategory = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Estimated Cost Input
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated cost (₹)',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF004E64),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '₹ ',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF94A3B8),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: _costController,
                                            keyboardType: TextInputType.number,
                                            style: GoogleFonts.inter(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0F172A),
                                            ),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Reason for suggestion (optional)
                        Text(
                          'Reason for suggestion (optional)',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF004E64),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: _reasonController,
                            maxLines: 3,
                            style: GoogleFonts.inter(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Why do you suggest this?',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // "Add Idea" Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _submitManualIdea,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF004E64),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'Add Idea',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ── 3. Popular Suggestions Section ─────────────────────
                Text(
                  'Popular Suggestions',
                  style: GoogleFonts.inter(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF004E64),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFDEF2F1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF67B5C6)
                                    : const Color(0xFFE2E8F0),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: const Color(0xFF004E64),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // Popular Suggestion Cards List
                ...displayedSuggestions.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: Image.asset(
                              item['image'] as String,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFFDEF2F1),
                                child: const Icon(
                                  Icons.image,
                                  color: Color(0xFF004E64),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Specs
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF004E64),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${item['cost']}  ·  ${item['distance']}',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF007791),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Circular "+" Button
                        InkWell(
                          onTap: () => _addPopularSuggestion(item),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDEF2F1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Color(0xFF004E64),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // ── Fixed Top Header ─────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, topPadding + 60),
                  painter: InviteHeaderPainter(),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: topPadding + 6,
                    left: 10,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Add Suggestion',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
