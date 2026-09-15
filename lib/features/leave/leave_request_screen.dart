import 'package:flutter/material.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  DateTime? fromDate;
  DateTime? toDate;

  final TextEditingController reasonController = TextEditingController();

  final List<Map<String, dynamic>> leaveRequests = [
    {
      "date": "10 Aug - 12 Aug",
      "reason": "Fever",
      "color": Colors.orange,
      "status": "Pending",
    },
    {
      "date": "15 Jul",
      "reason": "Family Function",
      "color": Colors.green,
      "status": "Approved",
    },
    {
      "date": "05 Jun",
      "reason": "Personal Work",
      "color": Colors.red,
      "status": "Rejected",
    },
  ];

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xff1565C0)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        fromDate = picked;

        // If selected from date is after existing to date,
        // clear the to date.
        if (toDate != null && toDate!.isBefore(picked)) {
          toDate = null;
        }
      });
    }
  }

  Future<void> pickToDate() async {
    if (fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select From Date first")),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? fromDate!,
      firstDate: fromDate!,
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xff1565C0)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        toDate = picked;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return "Select Date";
    }

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String formatLeaveDate() {
    if (fromDate == null) {
      return "";
    }

    if (toDate == null) {
      return formatDate(fromDate);
    }

    if (fromDate!.isAtSameMomentAs(toDate!)) {
      return formatDate(fromDate);
    }

    return "${fromDate!.day} ${monthName(fromDate!.month)} - "
        "${toDate!.day} ${monthName(toDate!.month)}";
  }

  String monthName(int month) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return months[month];
  }

  void submitLeaveRequest() {
    // ================================
    // VALIDATION
    // ================================

    if (fromDate == null) {
      showMessage("Please select From Date");
      return;
    }

    if (toDate == null) {
      showMessage("Please select To Date");
      return;
    }

    if (reasonController.text.trim().isEmpty) {
      showMessage("Please enter leave reason");
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    final submittedReason = reasonController.text.trim();
    final submittedDate = formatLeaveDate();

    // Add new request to list
    setState(() {
      leaveRequests.insert(0, {
        "date": submittedDate,
        "reason": submittedReason,
        "color": Colors.orange,
        "status": "Pending",
      });
    });

    // Show success popup
    showSuccessDialog();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================================
              // SUCCESS ICON
              // ================================
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 65,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Submitted Successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "Your leave request has been submitted successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Close popup
                    Navigator.pop(dialogContext);

                    // ================================
                    // RESET FORM
                    // ================================

                    setState(() {
                      fromDate = null;
                      toDate = null;
                      reasonController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1565C0),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IMPORTANT:
      // Keyboard open ayinappudu screen resize avutundi.
      resizeToAvoidBottomInset: true,

      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        title: const Text(
          "Student Leave Request",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================================================
            // STUDENT CARD
            // =========================================================
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(20),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),

              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/150?img=12",
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Keerthi",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          "Class UKG - A",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Leave Application",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_available,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =========================================================
            // FROM DATE
            // =========================================================
            const Text(
              "From Date",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),

            const SizedBox(height: 8),

            dateSelector(date: fromDate, onTap: pickFromDate),

            const SizedBox(height: 18),

            // =========================================================
            // TO DATE
            // =========================================================
            const Text(
              "To Date",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),

            const SizedBox(height: 8),

            dateSelector(date: toDate, onTap: pickToDate),

            const SizedBox(height: 20),

            // =========================================================
            // REASON
            // =========================================================
            const Text(
              "Reason",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: reasonController,

              maxLines: 5,

              textInputAction: TextInputAction.newline,

              decoration: InputDecoration(
                hintText: "Enter leave reason",

                hintStyle: const TextStyle(color: Colors.grey),

                filled: true,

                fillColor: Colors.white,

                contentPadding: const EdgeInsets.all(16),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xff1565C0),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // =========================================================
            // ATTACHMENT
            // =========================================================
            InkWell(
              onTap: () {
                showMessage("File attachment will be available soon");
              },

              borderRadius: BorderRadius.circular(15),

              child: Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(15),

                  border: Border.all(color: Colors.grey.shade200),
                ),

                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.upload_file,
                        color: Color(0xff1565C0),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Attach Medical Certificate",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),

                          SizedBox(height: 3),

                          Text(
                            "Optional • PDF or Image",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // =========================================================
            // SUBMIT BUTTON
            // =========================================================
            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton.icon(
                onPressed: submitLeaveRequest,

                icon: const Icon(Icons.send_rounded, color: Colors.white),

                label: const Text(
                  "Submit Leave Request",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1565C0),

                  elevation: 5,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================================================
            // PREVIOUS REQUESTS HEADER
            // =========================================================
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Previous Leave Requests",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Text(
                    "${leaveRequests.length}",
                    style: const TextStyle(
                      color: Color(0xff1565C0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // =========================================================
            // PREVIOUS REQUEST LIST
            // =========================================================
            ...leaveRequests.map(
              (leave) => leaveCard(
                leave["date"],
                leave["reason"],
                leave["color"],
                leave["status"],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // DATE SELECTOR
  // ================================================================

  Widget dateSelector({required DateTime? date, required VoidCallback onTap}) {
    final bool selected = date != null;

    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(15),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(15),

          border: Border.all(
            color: selected ? const Color(0xff1565C0) : Colors.grey.shade200,
          ),
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),

              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),

              child: const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xff1565C0),
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                formatDate(date),
                style: TextStyle(
                  fontSize: 15,

                  color: selected ? Colors.black : Colors.grey,

                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),

            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // LEAVE CARD
  // ================================================================

  Widget leaveCard(String date, String reason, Color color, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      elevation: 1,

      color: Colors.white,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                shape: BoxShape.circle,
              ),

              child: Icon(Icons.event_note_rounded, color: color),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    reason,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),

              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Text(
                status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
