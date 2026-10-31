import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_scenic_decorations.dart';
import '../../domain/entities/expense_entity.dart';

/// ── 1. Total Trip Expenses Card ─────────────────────────────────────────────
/// Retains the user's primary deep teal summary card with dynamic ledger values:
/// Grand Total, Your Paid, and Net Balance (Get back / You owe).
class TotalTripExpenseCard extends StatelessWidget {
  final double totalExpenses;
  final double myContributions;
  final double myBalance;

  const TotalTripExpenseCard({
    super.key,
    required this.totalExpenses,
    required this.myContributions,
    required this.myBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDeepTeal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeepTeal.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL TRIP EXPENSES',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: const Color(0xFFDEF2F1),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${totalExpenses.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFF007791), height: 1),
          const SizedBox(height: 16),

          // Balance Breakdown Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Paid',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFDEF2F1),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '₹${myContributions.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Balance',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFDEF2F1),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      myBalance >= 0
                          ? '+₹${myBalance.toStringAsFixed(0)} (Get back)'
                          : '-₹${myBalance.abs().toStringAsFixed(0)} (You owe)',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: myBalance >= 0
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFCA5A5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ── 2. Add Expense CTA Button ───────────────────────────────────────────────
/// Full-width warm golden amber pill button matching the mockup.
class ExpenseAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback? onScanReceipt;

  const ExpenseAddButton({
    super.key,
    required this.onPressed,
    this.onScanReceipt,
  });

  @override
  Widget build(BuildContext context) {
    if (onScanReceipt != null) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5A623),
                  foregroundColor: AppColors.primaryDeepTeal,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, color: AppColors.primaryDeepTeal, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      'Add Expense',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: onScanReceipt,
              icon: const Icon(Icons.document_scanner_rounded, color: Color(0xFF004E64), size: 19),
              label: Text(
                'Scan Bill',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004E64),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF004E64), width: 1.5),
                backgroundColor: const Color(0xFFDEF2F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5A623),
          foregroundColor: AppColors.primaryDeepTeal,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: AppColors.primaryDeepTeal, size: 22),
            const SizedBox(width: 6),
            Text(
              'Add Expense',
              style: GoogleFonts.inter(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDeepTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── 3. Category Filter Chips Row ───────────────────────────────────────────
/// Interactive filter chips: [ All ] [ 🍴 Food ] [ 🛏️ Stay ] [ 🚗 Transit ] [ 🏄 Activities ] [ 🛍️ Shopping ]
class ExpenseCategoryFilterRow extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const ExpenseCategoryFilterRow({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> _filters = [
    {'name': 'All', 'icon': null},
    {'name': 'Food', 'icon': Icons.restaurant_rounded},
    {'name': 'Stay', 'icon': Icons.hotel_rounded},
    {'name': 'Transit', 'icon': Icons.directions_car_rounded},
    {'name': 'Activities', 'icon': Icons.surfing_rounded},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final name = filter['name'] as String;
          final icon = filter['icon'] as IconData?;
          final isSelected = selectedCategory.toLowerCase() == name.toLowerCase();

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onCategorySelected(name),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryDeepTeal : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryDeepTeal : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.primaryDeepTeal.withValues(alpha: 0.22),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    else
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 15.5,
                        color: isSelected ? Colors.white : AppColors.primaryDeepTeal,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.primaryDeepTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// ── 4. Expense List Item Card ───────────────────────────────────────────────
class ExpenseListItemCard extends StatelessWidget {
  final ExpenseEntity expense;
  final double myShare;
  final VoidCallback? onTap;

  const ExpenseListItemCard({
    super.key,
    required this.expense,
    required this.myShare,
    this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'stay':
      case 'hotel':
      case 'villa':
        return Icons.home_rounded;
      case 'food':
      case 'restaurant':
      case 'dining':
        return Icons.restaurant_rounded;
      case 'transit':
      case 'cab':
      case 'transport':
        return Icons.directions_car_rounded;
      case 'activities':
      case 'adventure':
        return Icons.surfing_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Today';
    } else if (itemDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawName = expense.paidByFullName.trim();
    final payerName = (rawName.isNotEmpty && rawName.toLowerCase() != 'payer')
        ? rawName
        : (expense.paidByUsername.isNotEmpty ? expense.paidByUsername : 'You');
    final dateStr = _formatRelativeDate(expense.createdAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Category Badge
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF006D77),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Description & Payer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDeepTeal,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Paid by $payerName · $dateStr',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Amount, share & Chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${expense.amount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  myShare > 0
                      ? 'Your share ₹${myShare.toStringAsFixed(0)}'
                      : 'Included in pool',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF007791),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ── 5. Who Owes Whom Section Card ───────────────────────────────────────────
/// Matching the settlement cards in the mockup with member avatar, payer/payee,
/// amount, and the [ Mark as paid ] pill button.
class WhoOwesWhomSection extends StatelessWidget {
  final List<ExpenseSettlementEntity> settlements;
  final ValueChanged<ExpenseSettlementEntity> onMarkAsPaid;

  const WhoOwesWhomSection({
    super.key,
    required this.settlements,
    required this.onMarkAsPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            const Icon(
              Icons.people_alt_outlined,
              color: AppColors.primaryDeepTeal,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Who owes whom',
              style: GoogleFonts.inter(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDeepTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (settlements.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDF8F7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF006D77),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All settled up!',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDeepTeal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'No outstanding balances among trip buddies.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: settlements.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final settlement = settlements[index];
              final fromName = settlement.fromUserName;
              final toName = settlement.toUserName;
              final isCompleted = settlement.isCompleted;

              final initial = fromName.isNotEmpty ? fromName[0].toUpperCase() : '?';

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.025),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Member Avatar Circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDEF2F1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDeepTeal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Settlement description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$fromName pays $toName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDeepTeal,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Settlement · ₹${settlement.amount.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Amount & Mark as paid button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${settlement.amount.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDeepTeal,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF94A3B8),
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEF2F1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF006D77),
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Paid',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF006D77),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () => onMarkAsPaid(settlement),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF006D77),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Mark as paid',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

/// ── 6. Scenic Botanical Foliage & Golden Trail Footer ───────────────────────
/// Matching workspace and itinerary pages: leaves at bottom-left and curved dotted trail.
class ExpenseScenicFooter extends StatelessWidget {
  const ExpenseScenicFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dotted flight trail with destination pin on right
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ExpenseTrailPainter(),
              ),
            ),
          ),

          // Botanical leaf cluster shifted down and left
          const Positioned(
            left: -24,
            bottom: -18,
            child: BotanicalLeavesCluster(
              size: Size(130, 95),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentWarmYellow
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final p0 = Offset(size.width * 0.05, size.height * 0.90);
    final p1 = Offset(size.width * 0.38, size.height * 0.86);
    final p2 = Offset(size.width * 0.70, size.height * 0.65);
    final p3 = Offset(size.width * 0.96, size.height * 0.36);

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      const dashLength = 5.0;
      const dashSpace = 4.0;
      while (distance < metric.length) {
        final extractPath = metric.extractPath(
          distance,
          math.min(distance + dashLength, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance += dashLength + dashSpace;
      }
    }

    // Destination Pin marker at the end
    final pinCenter = Offset(p3.dx, p3.dy - 6);
    const pinRadius = 6.0;

    final pinPaint = Paint()
      ..color = AppColors.primaryDeepTeal
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pinCenter, pinRadius, pinPaint);

    final tipPath = Path()
      ..moveTo(pinCenter.dx - pinRadius * 0.8, pinCenter.dy + 1)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(pinCenter.dx + pinRadius * 0.8, pinCenter.dy + 1)
      ..close();
    canvas.drawPath(tipPath, pinPaint);

    final innerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pinCenter, 2.2, innerDotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
