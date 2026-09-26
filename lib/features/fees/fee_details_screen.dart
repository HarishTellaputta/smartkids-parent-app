
import 'package:flutter/material.dart';
import 'package:parent_app/models/student_response.dart';
import 'package:parent_app/services/api_service.dart';

class FeeDetailsScreen extends StatefulWidget {
  final StudentResponse student;

  const FeeDetailsScreen({
    super.key,
    required this.student,
  });

  @override
  State<FeeDetailsScreen> createState() => _FeeDetailsScreenState();
}

class _FeeDetailsScreenState extends State<FeeDetailsScreen> {
  bool isLoading = true;
  String? errorMessage;

  // Actual payment transactions
  List<Map<String, dynamic>> paymentHistory = [];

  // Assigned fee records
  double totalPending = 0;
  double totalOutstanding = 0;

  // Actual payments
  double totalPaid = 0;

  @override
  void initState() {
    super.initState();

    debugPrint('💰 FeeDetailsScreen opened');
    debugPrint('👤 Student ID: ${widget.student.id}');
    debugPrint('👤 Student Name: ${widget.student.name}');

    _loadFees();
  }

  // ============================================================
  // LOAD FEES + ACTUAL PAYMENT HISTORY
  // ============================================================

  Future<void> _loadFees() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      debugPrint('════════════════════════════════════════════════════');
      debugPrint('💰 Loading fee details');
      debugPrint('👤 Student ID: ${widget.student.id}');
      debugPrint('════════════════════════════════════════════════════');

      // ----------------------------------------------------------
      // 1. LOAD ASSIGNED FEES
      // ----------------------------------------------------------

      final feeResponse = await ApiService.getStudentFees(
        widget.student.id,
        pending: false,
      );

      debugPrint(
        '💰 Assigned Fees Status: ${feeResponse.statusCode}',
      );

      double pendingAmount = 0;

      if (feeResponse.statusCode == 200) {
        final feeData = ApiService.decodeResponse(feeResponse);

        debugPrint('💰 Assigned Fees Response: $feeData');

        if (feeData is List) {
          pendingAmount = _calculateOutstanding(feeData);
        }
      } else {
        debugPrint(
          '⚠️ Assigned Fees API failed: ${feeResponse.statusCode}',
        );
      }

      // ----------------------------------------------------------
      // 2. LOAD ACTUAL PAYMENT HISTORY
      // ----------------------------------------------------------

      final paymentResponse =
          await ApiService.getStudentPayments(widget.student.id);

      debugPrint(
        '💳 Payment History Status: ${paymentResponse.statusCode}',
      );

      debugPrint(
        '💳 Payment History Response: ${paymentResponse.body}',
      );

      if (paymentResponse.statusCode != 200) {
        if (mounted) {
          setState(() {
            errorMessage =
                'Unable to load payment history. '
                '(${paymentResponse.statusCode})';
          });
        }
        return;
      }

      final paymentData = ApiService.decodeResponse(paymentResponse);

      debugPrint('💳 Decoded Payment Data: $paymentData');

      double paidAmount = 0;
      final List<Map<String, dynamic>> payments = [];

      if (paymentData is List) {
        for (final item in paymentData) {
          if (item is! Map) continue;

          final map = Map<String, dynamic>.from(item);

          final double amount = _parseAmount(map['amount']);

          paidAmount += amount;

          payments.add({
            'id': map['id'],
            'studentFeeId': map['studentFeeId'],
            'studentId': map['studentId'],
            'studentName': map['studentName'],
            'receiptNumber': map['receiptNumber'],
            'paymentMethod': map['paymentMethod'],
            'remarks': map['remarks'],
            'amount': amount,
            'paymentDate': _formatPaymentDate(
              map['paymentDate'],
            ),
          });

          debugPrint(
            '💳 Payment: '
            'ID=${map['id']} '
            'Amount=${map['amount']} '
            'Receipt=${map['receiptNumber']} '
            'Date=${map['paymentDate']}',
          );
        }
      }

      // Latest payments first
      payments.sort((a, b) {
        final dateA = _parseDate(a['paymentDate']);
        final dateB = _parseDate(b['paymentDate']);

        return dateB.compareTo(dateA);
      });

      if (!mounted) return;

      setState(() {
        paymentHistory = payments;

        totalPaid = paidAmount;

        totalPending = pendingAmount;
        totalOutstanding = pendingAmount;

        isLoading = false;
      });

      debugPrint('════════════════════════════════════════════════════');
      debugPrint('💰 FINAL FEE SUMMARY');
      debugPrint('💳 Total Paid: $totalPaid');
      debugPrint('⏳ Total Pending: $totalPending');
      debugPrint('💰 Outstanding: $totalOutstanding');
      debugPrint('💳 Payment Count: ${paymentHistory.length}');
      debugPrint('════════════════════════════════════════════════════');
    } catch (e, stackTrace) {
      debugPrint('❌ FeeDetailsScreen Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');

      if (!mounted) return;

      setState(() {
        errorMessage = 'Failed to load fee details.';
        isLoading = false;
      });
    }
  }

  // ============================================================
  // CALCULATE OUTSTANDING FROM FEE RECORDS
  // ============================================================

  double _calculateOutstanding(List<dynamic> data) {
    double outstanding = 0;

    for (final item in data) {
      if (item is! Map) continue;

      final map = Map<String, dynamic>.from(item);

      final double amount = _parseAmount(
        map['amount'] ??
            map['feeAmount'] ??
            map['totalAmount'] ??
            map['payableAmount'] ??
            map['outstandingAmount'] ??
            map['balanceAmount'],
      );

      final String status =
          (map['status'] ??
                  map['paymentStatus'] ??
                  map['feeStatus'] ??
                  'PENDING')
              .toString()
              .toUpperCase();

      final bool isFullyPaid =
          status == 'PAID' ||
          status == 'COMPLETED' ||
          status == 'SUCCESS' ||
          status == 'FULLY_PAID';

      if (!isFullyPaid) {
        outstanding += amount;
      }
    }

    return outstanding;
  }

  // ============================================================
  // AMOUNT PARSER
  // ============================================================

  double _parseAmount(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    final cleaned = value
        .toString()
        .replaceAll('₹', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(cleaned) ?? 0;
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatPaymentDate(dynamic value) {
    if (value == null) return '-';

    final parsed = DateTime.tryParse(value.toString());

    if (parsed == null) {
      return value.toString();
    }

    return '${parsed.day.toString().padLeft(2, '0')} '
        '${_monthName(parsed.month)} '
        '${parsed.year}';
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime(1970);
    }

    final parsed = DateTime.tryParse(value.toString());

    return parsed ?? DateTime(1970);
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  // ============================================================
  // AMOUNT FORMAT
  // ============================================================

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.toInt()}';
    }

    return '₹${amount.toStringAsFixed(2)}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Fee Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: _loadFees,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: _loadFees,
                  child: _buildContent(),
                ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        _studentCard(),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Outstanding',
                _formatAmount(totalOutstanding),
                Colors.red,
                Icons.account_balance_wallet_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                'Paid',
                _formatAmount(totalPaid),
                Colors.green,
                Icons.check_circle_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _summaryCard(
          'Pending',
          _formatAmount(totalPending),
          Colors.orange,
          Icons.pending_actions_rounded,
        ),

        const SizedBox(height: 28),

        Row(
          children: [
            const Expanded(
              child: Text(
                'Payment History',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            if (paymentHistory.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${paymentHistory.length} Payments',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (paymentHistory.isEmpty)
          _emptyView()
        else
          ...paymentHistory.map(
            (payment) => _paymentHistoryCard(payment),
          ),
      ],
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _studentCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3949AB),
            Color(0xFF5C6BC0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3949AB).withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                widget.student.name.isNotEmpty
                    ? widget.student.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.student.className ??
                      widget.student.sectionName ??
                      'Class information unavailable',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (widget.student.admissionNo != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Admission No: ${widget.student.admissionNo}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white70,
            size: 28,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT HISTORY CARD
  // ============================================================

  Widget _paymentHistoryCard(Map<String, dynamic> payment) {
    final double amount = payment['amount'] is num
        ? (payment['amount'] as num).toDouble()
        : 0;

    final String receipt =
        payment['receiptNumber']?.toString() ?? '-';

    final String paymentMethod =
        payment['paymentMethod']?.toString() ?? '-';

    final String remarks =
        payment['remarks']?.toString() ?? '';

    final String date =
        payment['paymentDate']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Received',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                _formatAmount(amount),
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _paymentInfo(
                  Icons.receipt_long_outlined,
                  'Receipt',
                  receipt,
                ),
              ),

              Expanded(
                child: _paymentInfo(
                  Icons.payment_rounded,
                  'Method',
                  paymentMethod,
                ),
              ),
            ],
          ),

          if (remarks.isNotEmpty &&
              remarks != 'null') ...[
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      remarks,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT INFO
  // ============================================================

  Widget _paymentInfo(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyView() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 42,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color: Colors.grey.shade400,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No payment history',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'No payments have been recorded for this student yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red.shade300,
            ),

            const SizedBox(height: 16),

            Text(
              errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _loadFees,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

