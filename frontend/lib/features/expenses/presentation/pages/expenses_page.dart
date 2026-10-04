import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TripMember {
  final String id;
  final String name;

  const TripMember({required this.id, required this.name});
}

class TripExpenseItem {
  final String id;
  final String title;
  final double amount;
  final String paidById;
  final String paidByName;
  final List<String> includedMemberNames;
  final DateTime date;

  const TripExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidById,
    required this.paidByName,
    required this.includedMemberNames,
    required this.date,
  });
}

/// Expenses screen matching the WeTravel design screenshot.
/// Shows:
/// - "23 Expenses" count header
/// - Total Trip Expenses card (Shared expenses, Your contributions, Your balance, Member totals)
/// - "+ Add Expense" action which opens a split modal:
///   Allows choosing "All" or "Name-wise selection" and divides the expense between them in real-time.
class ExpensesPage extends StatefulWidget {
  final String tripId;

  const ExpensesPage({
    super.key,
    required this.tripId,
  });

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final List<TripMember> _members = const [
    TripMember(id: 'you', name: 'You'),
    TripMember(id: 'rashi', name: 'Rashi'),
    TripMember(id: 'aakansha', name: 'Aakansha'),
    TripMember(id: 'anshl', name: 'Anshl'),
  ];

  late List<TripExpenseItem> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = [
      TripExpenseItem(
        id: '1',
        title: 'Villa Stay in Candolim',
        amount: 32000,
        paidById: 'rashi',
        paidByName: 'Rashi',
        includedMemberNames: ['You', 'Rashi', 'Aakansha', 'Anshl'],
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      TripExpenseItem(
        id: '2',
        title: 'Seafood Dinner at Brittos',
        amount: 8400,
        paidById: 'you',
        paidByName: 'You',
        includedMemberNames: ['You', 'Rashi', 'Aakansha', 'Anshl'],
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TripExpenseItem(
        id: '3',
        title: 'Scuba Diving at Grande Island',
        amount: 14000,
        paidById: 'anshl',
        paidByName: 'Anshl',
        includedMemberNames: ['You', 'Rashi', 'Aakansha', 'Anshl'],
        date: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      TripExpenseItem(
        id: '4',
        title: 'Scooter Rentals (4 Bikes)',
        amount: 5600,
        paidById: 'you',
        paidByName: 'You',
        includedMemberNames: ['You', 'Rashi', 'Aakansha', 'Anshl'],
        date: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      TripExpenseItem(
        id: '5',
        title: 'Sunset Drinks & Snacks at Thalassa',
        amount: 2400,
        paidById: 'aakansha',
        paidByName: 'Aakansha',
        includedMemberNames: ['Rashi', 'Aakansha', 'Anshl'],
        date: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  double get _totalTripExpenses =>
      _expenses.fold(0.0, (acc, item) => acc + item.amount);

  double get _yourContributions => _expenses
      .where((item) => item.paidById == 'you')
      .fold(0.0, (acc, item) => acc + item.amount);

  double get _yourShare {
    double total = 0.0;
    for (final exp in _expenses) {
      if (exp.includedMemberNames.contains('You')) {
        total += exp.amount / exp.includedMemberNames.length;
      }
    }
    return total;
  }

  double get _yourBalance => _yourContributions - _yourShare;

  void _showAddExpenseModal() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String paidById = 'you';
    bool splitEquallyAll = true;
    final selectedMembers = Set<String>.from(_members.map((m) => m.name));

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
            final count = splitEquallyAll ? _members.length : selectedMembers.length;
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
                    // Header Bar
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF004E64),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Add Trip Expense',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF004E64),
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
                        color: const Color(0xFF004E64),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Dinner at Fisherman\'s Wharf',
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

                    // Amount & Paid By Row
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
                                  color: const Color(0xFF004E64),
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
                                    color: const Color(0xFF004E64),
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

                        // Paid By Dropdown
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paid By',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF004E64),
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
                                    items: _members.map((m) {
                                      return DropdownMenuItem(
                                        value: m.id,
                                        child: Text(
                                          m.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF004E64),
                                          ),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Who is included in this expense? Section
                    Text(
                      'Who is included in this expense?',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF004E64),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Choice chips: All vs Choose Name-wise
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text(
                            'All (${_members.length})',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: splitEquallyAll ? Colors.white : const Color(0xFF004E64),
                            ),
                          ),
                          selected: splitEquallyAll,
                          selectedColor: const Color(0xFF004E64),
                          backgroundColor: const Color(0xFFF1F5F9),
                          onSelected: (val) {
                            setModalState(() {
                              splitEquallyAll = true;
                              selectedMembers.clear();
                              selectedMembers.addAll(_members.map((m) => m.name));
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(
                            'Choose Name-wise',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: !splitEquallyAll ? Colors.white : const Color(0xFF004E64),
                            ),
                          ),
                          selected: !splitEquallyAll,
                          selectedColor: const Color(0xFF004E64),
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

                    // Name-wise checkboxes if custom mode
                    if (!splitEquallyAll) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: _members.map((member) {
                            final isChecked = selectedMembers.contains(member.name);
                            return CheckboxListTile(
                              dense: true,
                              value: isChecked,
                              activeColor: const Color(0xFF004E64),
                              title: Text(
                                member.name,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF004E64),
                                ),
                              ),
                              onChanged: (bool? checked) {
                                setModalState(() {
                                  if (checked == true) {
                                    selectedMembers.add(member.name);
                                  } else {
                                    if (selectedMembers.length > 1) {
                                      selectedMembers.remove(member.name);
                                    }
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Real-time Split summary banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEF2F1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF67B5C6).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.groups_rounded,
                            color: Color(0xFF004E64),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Split equally between $count members',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF004E64),
                                  ),
                                ),
                                Text(
                                  '₹${perPerson.toStringAsFixed(1)} per person',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF007791),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final amount = double.tryParse(amountController.text) ?? 0.0;
                          if (title.isEmpty || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enter valid title and amount.',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                ),
                                backgroundColor: const Color(0xFF004E64),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          final paidMember = _members.firstWhere((m) => m.id == paidById);
                          final newExpense = TripExpenseItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: title,
                            amount: amount,
                            paidById: paidById,
                            paidByName: paidMember.name,
                            includedMemberNames: splitEquallyAll
                                ? _members.map((m) => m.name).toList()
                                : selectedMembers.toList(),
                            date: DateTime.now(),
                          );

                          setState(() {
                            _expenses.insert(0, newExpense);
                          });

                          Navigator.of(modalCtx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added "₹$amount" expense divided among ${newExpense.includedMemberNames.length} members!',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: const Color(0xFF004E64),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004E64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Save Expense',
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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2229), // Dark card theme matching screenshot
      body: Stack(
        children: [
          // ── Scrollable Body ──────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: topPadding + 64,
              bottom: bottomPadding + 30,
              left: 18,
              right: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── 1. Top Count Header Card: "23 Expenses" ─────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C323D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF3F4654),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${_expenses.length}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Expenses',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 2. Total Trip Expenses Card ────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C323D),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF3F4654),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL TRIP EXPENSES',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          Text(
                            '₹${_totalTripExpenses.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Breakdown Rows
                      _buildDarkStatRow(
                        'Shared expenses',
                        '₹${(_totalTripExpenses * 0.8).toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 8),
                      _buildDarkStatRow(
                        'Your contributions',
                        '₹${_yourContributions.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 8),
                      _buildDarkStatRow(
                        'Your balance',
                        '${_yourBalance >= 0 ? '+' : ''}₹${_yourBalance.toStringAsFixed(0)}',
                        highlightPositive: _yourBalance >= 0,
                      ),
                      const SizedBox(height: 18),

                      const Divider(color: Color(0xFF3F4654), height: 1),
                      const SizedBox(height: 14),

                      // Member totals pill
                      Text(
                        'rashi ₹17k  •  Aakansha ₹15k  •  anshl ₹16k  •  You ₹${(_yourContributions / 1000).toStringAsFixed(0)}k',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── 3. "• Add Expense" Button ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _showAddExpenseModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B4353),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF4F586B), width: 1.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add Expense',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── 4. Recent Expenses List ───────────────────────────
                Text(
                  'Recent Transactions',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                const SizedBox(height: 12),

                ...List.generate(_expenses.length, (index) {
                  final item = _expenses[index];
                  final perPersonSplit = item.amount / item.includedMemberNames.length;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C323D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF3F4654)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              '₹${item.amount.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Paid by ${item.paidByName}',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2229),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '₹${perPersonSplit.toStringAsFixed(0)} / person (${item.includedMemberNames.length})',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF67B5C6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Split between: ${item.includedMemberNames.join(", ")}',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
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
            child: Container(
              color: const Color(0xFF1E2229),
              padding: EdgeInsets.only(
                top: topPadding + 4,
                left: 12,
                right: 16,
                bottom: 12,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Trip Expenses',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.pie_chart_outline_rounded, color: Colors.white, size: 22),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkStatRow(String label, String value, {bool highlightPositive = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF94A3B8),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: highlightPositive ? const Color(0xFF10B981) : Colors.white,
          ),
        ),
      ],
    );
  }
}
