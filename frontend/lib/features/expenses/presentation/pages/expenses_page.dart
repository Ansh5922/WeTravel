import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/we_travel_drawer.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../trip_details/presentation/widgets/trip_bottom_nav_bar.dart';
import '../../../trips/domain/entities/trip_entity.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_state.dart';
import '../../domain/entities/expense_entity.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/expense_screen_widgets.dart';

/// Dynamic Expenses screen connected to ExpenseBloc, TripBloc & AuthBloc.
/// Features:
/// - Dynamic Total Trip Expenses card (Grand Total, Your Paid, Net Balance)
/// - Warm Amber "+ Add Expense" action button
/// - Category filters: All, Food, Stay, Transit, Activities, Shopping
/// - Expense List with category icons, payer info, share calculation, and details view
/// - "Who owes whom" settlement cards with real-time "Mark as paid" action
/// - Scenic botanical foliage & golden dashed trail footer
class ExpensesPage extends StatefulWidget {
  final String tripId;
  final bool isEmbedded;

  const ExpensesPage({
    super.key,
    required this.tripId,
    this.isEmbedded = false,
  });

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    final isTestEnv = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTestEnv) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ExpenseBloc>().add(ExpensesFetchRequested(tripId: widget.tripId));
        }
      });
    }
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.trips);
    }
  }

  void _showAddExpenseModal(List<TripGroupMemberEntity> tripMembers) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Food';
    final categories = ['Food', 'Stay', 'Transit', 'Activities', 'Shopping', 'Other'];

    final defaultPayerId = tripMembers.isNotEmpty ? tripMembers.first.userId : 'you';
    String paidById = defaultPayerId;
    bool splitEquallyAll = true;

    // Use member userIds for splitting
    final selectedMemberIds = Set<String>.from(tripMembers.map((m) => m.userId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final enteredAmount = double.tryParse(amountController.text) ?? 0.0;
            final count = splitEquallyAll ? tripMembers.length : selectedMemberIds.length;
            final perPerson = count > 0 ? enteredAmount / count : 0.0;

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded, color: AppColors.primaryDeepTeal, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Add Trip Expense',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDeepTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Expense Title
                    Text(
                      'Expense Title',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Seafood dinner at Fisherman\'s Wharf',
                        hintStyle: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Amount & Category Row
                    Row(
                      children: [
                        // Amount Field
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount (₹)',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDeepTeal,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setModalState(() {}),
                                decoration: InputDecoration(
                                  prefixText: '₹ ',
                                  prefixStyle: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDeepTeal,
                                  ),
                                  hintText: '0',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Category Dropdown
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDeepTeal,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedCategory,
                                    isExpanded: true,
                                    menuMaxHeight: 220,
                                    borderRadius: BorderRadius.circular(16),
                                    dropdownColor: Colors.white,
                                    elevation: 4,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.primaryDeepTeal,
                                      size: 20,
                                    ),
                                    items: categories.map((cat) {
                                      final icon = _getCategoryIcon(cat);
                                      final color = _getCategoryColor(cat);
                                      return DropdownMenuItem(
                                        value: cat,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 26,
                                              height: 26,
                                              decoration: BoxDecoration(
                                                color: color.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Icon(icon, color: color, size: 15),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              cat,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryDeepTeal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() {
                                          selectedCategory = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Paid By
                    if (tripMembers.isNotEmpty) ...[
                      Text(
                        'Paid By',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDeepTeal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: paidById,
                            isExpanded: true,
                            menuMaxHeight: 220,
                            borderRadius: BorderRadius.circular(16),
                            dropdownColor: Colors.white,
                            elevation: 4,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primaryDeepTeal,
                              size: 20,
                            ),
                            items: tripMembers.map((m) {
                              final initial = m.fullName.trim().isNotEmpty
                                  ? m.fullName.trim()[0].toUpperCase()
                                  : 'M';
                              return DropdownMenuItem(
                                value: m.userId,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: const Color(0xFF004E64),
                                      child: Text(
                                        initial,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        m.fullName,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryDeepTeal,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  paidById = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Split distribution
                    Text(
                      'Who is included in this expense?',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        ChoiceChip(
                          label: Text(
                            'All (${tripMembers.length})',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: splitEquallyAll ? Colors.white : AppColors.primaryDeepTeal,
                            ),
                          ),
                          selected: splitEquallyAll,
                          selectedColor: AppColors.primaryDeepTeal,
                          backgroundColor: const Color(0xFFF1F5F9),
                          onSelected: (val) {
                            setModalState(() {
                              splitEquallyAll = true;
                              selectedMemberIds.clear();
                              selectedMemberIds.addAll(tripMembers.map((m) => m.userId));
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(
                            'Select Members',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: !splitEquallyAll ? Colors.white : AppColors.primaryDeepTeal,
                            ),
                          ),
                          selected: !splitEquallyAll,
                          selectedColor: AppColors.primaryDeepTeal,
                          backgroundColor: const Color(0xFFF1F5F9),
                          onSelected: (val) {
                            setModalState(() {
                              splitEquallyAll = false;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Custom checkboxes
                    if (!splitEquallyAll && tripMembers.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: tripMembers.map((member) {
                            final isChecked = selectedMemberIds.contains(member.userId);
                            return CheckboxListTile(
                              dense: true,
                              value: isChecked,
                              activeColor: AppColors.primaryDeepTeal,
                              title: Text(
                                member.fullName,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDeepTeal,
                                ),
                              ),
                              onChanged: (bool? checked) {
                                setModalState(() {
                                  if (checked == true) {
                                    selectedMemberIds.add(member.userId);
                                  } else {
                                    if (selectedMemberIds.length > 1) {
                                      selectedMemberIds.remove(member.userId);
                                    }
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Split breakdown preview
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEF2F1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF67B5C6).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calculate_rounded, color: Color(0xFF007791), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '₹${enteredAmount.toStringAsFixed(0)} split across $count person(s) = ₹${perPerson.toStringAsFixed(0)} each',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDeepTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Submit CTA
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter an expense title')),
                            );
                            return;
                          }
                          if (enteredAmount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid amount')),
                            );
                            return;
                          }

                          Navigator.pop(modalCtx);

                          final splitIds = splitEquallyAll
                              ? tripMembers.map((m) => m.userId).toList()
                              : selectedMemberIds.toList();

                          context.read<ExpenseBloc>().add(
                                ExpenseCreateRequested(
                                  tripId: widget.tripId,
                                  amount: enteredAmount,
                                  description: titleController.text.trim(),
                                  category: selectedCategory,
                                  splitMemberIds: splitIds,
                                ),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDeepTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Save & Split Expense',
                          style: GoogleFonts.inter(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showExpenseDetailsModal(ExpenseEntity expense, List<TripGroupMemberEntity> tripMembers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final rawName = expense.paidByFullName.trim();
        final payerName = (rawName.isNotEmpty && rawName.toLowerCase() != 'payer')
            ? rawName
            : (expense.paidByUsername.isNotEmpty ? expense.paidByUsername : 'You');

        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEF2F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      expense.category.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${expense.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDeepTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                expense.description,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Paid by $payerName',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),
              Text(
                'Split Members (${expense.splitMemberIds.isNotEmpty ? expense.splitMemberIds.length : tripMembers.length}):',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (expense.splitMemberIds.isNotEmpty
                        ? tripMembers.where((m) => expense.splitMemberIds.contains(m.userId)).toList()
                        : tripMembers)
                    .map((m) {
                  return Chip(
                    backgroundColor: const Color(0xFFF1F5F9),
                    label: Text(
                      m.fullName,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    final tripState = context.watch<TripBloc>().state;
    List<TripGroupMemberEntity> tripMembers = [];
    if (tripState is TripDetailLoadedState) {
      tripMembers = tripState.trip.members;
    } else if (tripState is TripCreatedState) {
      tripMembers = tripState.trip.members;
    }

    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';

    final content = BlocConsumer<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpensesLoadedState && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.primaryDeepTeal,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ExpenseErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        List<ExpenseEntity> expenses = [];
        ExpenseLedgerEntity? ledger;
        List<ExpenseSettlementEntity> settlements = [];

        if (state is ExpensesLoadedState) {
          expenses = state.expenses;
          ledger = state.ledger;
          settlements = state.settlements;
        }

        final totalExpenses = ledger?.grandTotal ??
            expenses.fold<double>(0.0, (acc, e) => acc + e.amount);
        final myContributions = ledger?.myPaidAmount ?? 0.0;
        final myBalance = ledger?.myBalance ?? 0.0;

        // Dynamic category filtering
        final filteredExpenses = _selectedCategory == 'All'
            ? expenses
            : expenses.where((e) => e.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Standalone Topbar (only shown when page is opened standalone)
              if (!widget.isEmbedded)
                Container(
                  padding: EdgeInsets.only(
                    top: topPadding + 10,
                    left: 10,
                    right: 18,
                    bottom: 12,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.primaryDeepTeal, size: 24),
                        onPressed: _handleBack,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Trip Expenses & Split',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDeepTeal,
                        ),
                      ),
                      const Spacer(),
                      Builder(
                        builder: (ctx) => IconButton(
                          icon: const Icon(Icons.menu_rounded, color: AppColors.primaryDeepTeal, size: 24),
                          tooltip: 'Open navigation menu',
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Total Trip Expense Card (as-is, dynamic) ───────
                    TotalTripExpenseCard(
                      totalExpenses: totalExpenses,
                      myContributions: myContributions,
                      myBalance: myBalance,
                    ),
                    const SizedBox(height: 16),

                    // ── 2. Add Expense CTA Button ─────────────────────────
                    ExpenseAddButton(
                      onPressed: () => _showAddExpenseModal(tripMembers),
                    ),
                    const SizedBox(height: 16),

                    // ── 3. Category Filter Chips ──────────────────────────
                    ExpenseCategoryFilterRow(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (cat) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── 4. Expense List Section ───────────────────────────
                    Row(
                      children: [
                        const Icon(
                          Icons.format_list_bulleted_rounded,
                          color: AppColors.primaryDeepTeal,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expense List',
                          style: GoogleFonts.inter(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDeepTeal,
                          ),
                        ),
                        const Spacer(),
                        if (state is ExpenseLoadingState)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryDeepTeal,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (filteredExpenses.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              size: 40,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _selectedCategory == 'All'
                                  ? 'No Expenses Logged Yet'
                                  : 'No $_selectedCategory Expenses',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDeepTeal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add expenses to track your vacation spending and automatically split costs.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredExpenses.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filteredExpenses[index];
                          final isIncluded = item.splitMemberIds.isEmpty ||
                              item.splitMemberIds.contains(currentUserId);
                          final splitCount = item.splitMemberIds.isNotEmpty
                              ? item.splitMemberIds.length
                              : (tripMembers.isNotEmpty ? tripMembers.length : 1);
                          final myShare = isIncluded ? (item.amount / splitCount) : 0.0;

                          return ExpenseListItemCard(
                            expense: item,
                            myShare: myShare,
                            onTap: () => _showExpenseDetailsModal(item, tripMembers),
                          );
                        },
                      ),
                    const SizedBox(height: 24),

                    // ── 5. Who owes whom Section ──────────────────────────
                    WhoOwesWhomSection(
                      settlements: settlements,
                      onMarkAsPaid: (settlement) {
                        context.read<ExpenseBloc>().add(
                              SettlementCompleteRequested(
                                tripId: widget.tripId,
                                settlementId: settlement.id,
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── 6. Scenic Botanical Foliage & Golden Trail Footer ─
                    const ExpenseScenicFooter(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (widget.isEmbedded) {
      return content;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWarm,
        drawer: const WeTravelDrawer(),
        bottomNavigationBar: TripBottomNavBar(
          currentIndex: 2,
          onTabSelected: (index) {
            if (index == 0) {
              context.push(RouteNames.tripDetailsPath(widget.tripId));
            } else if (index == 1) {
              context.push(RouteNames.itineraryPath(widget.tripId));
            }
          },
        ),
        body: content,
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'dining':
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
      case 'transit':
        return Icons.directions_car_rounded;
      case 'lodging':
      case 'stay':
      case 'hotel':
        return Icons.hotel_rounded;
      case 'activities':
      case 'entertainment':
        return Icons.local_activity_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'fuel':
        return Icons.local_gas_station_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'dining':
      case 'food':
        return const Color(0xFFEA580C);
      case 'transport':
      case 'transit':
        return const Color(0xFF0284C7);
      case 'lodging':
      case 'stay':
      case 'hotel':
        return const Color(0xFF9333EA);
      case 'activities':
      case 'entertainment':
        return const Color(0xFF16A34A);
      case 'shopping':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF004E64);
    }
  }
}
