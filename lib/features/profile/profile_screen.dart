
import 'package:flutter/material.dart';

import '../../models/parent_response.dart';
import '../../storage/local_storage.dart';
import '../../services/api_service.dart';
import '../auth/login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ParentResponse? parent;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ============================================================
  // LOAD PARENT PROFILE FROM BACKEND
  // GET /api/v1/parents/me
  // ============================================================

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getMyParentProfile();

      debugPrint("========== PARENT PROFILE ==========");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");
      debugPrint("====================================");

      if (response.statusCode == 200) {
        final data = ApiService.decodeResponse(response);

        if (data is Map<String, dynamic>) {
          final parentData = ParentResponse.fromJson(data);

          if (!mounted) return;

          setState(() {
            parent = parentData;
            isLoading = false;
          });
        } else {
          if (!mounted) return;

          setState(() {
            errorMessage = "Invalid profile data received.";
            isLoading = false;
          });
        }
      } else {
        if (!mounted) return;

        setState(() {
          errorMessage =
              "Unable to load profile. (${response.statusCode})";
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("PROFILE API ERROR: $e");

      if (!mounted) return;

      setState(() {
        errorMessage = "Failed to load profile.";
        isLoading = false;
      });
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    final tokenBeforeLogout = await LocalStorage.getToken();

    debugPrint("========== LOGOUT DEBUG ==========");
    debugPrint("TOKEN BEFORE LOGOUT:");
    debugPrint(tokenBeforeLogout);
    debugPrint("==================================");

    try {
      final response = await ApiService.logout();

      debugPrint("LOGOUT API STATUS: ${response.statusCode}");
      debugPrint("LOGOUT API BODY: ${response.body}");
    } catch (e) {
      debugPrint("LOGOUT API ERROR: $e");
    }

    // Always clear local login data
    await LocalStorage.clearLoginData();

    final tokenAfterLogout = await LocalStorage.getToken();

    debugPrint("========== AFTER CLEAR ==========");
    debugPrint("TOKEN AFTER LOGOUT:");
    debugPrint("$tokenAfterLogout");
    debugPrint("================================");

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Parent Profile",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: _loadProfile,
            icon: const Icon(
              Icons.refresh,
              color: Colors.blue,
            ),
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
                  onRefresh: _loadProfile,
                  child: _buildProfile(),
                ),
    );
  }

  // ============================================================
  // PROFILE CONTENT
  // ============================================================

  Widget _buildProfile() {
    if (parent == null) {
      return const Center(
        child: Text("Profile not available"),
      );
    }

    final p = parent!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // --------------------------------------------------------
        // PROFILE HEADER
        // --------------------------------------------------------

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xff1565C0),
                Color(0xff42A5F5),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                _parentName(p),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                _childrenText(p),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // --------------------------------------------------------
        // PERSONAL INFORMATION
        // --------------------------------------------------------

        const Text(
          "Personal Information",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        if (p.contactPhone != null &&
            p.contactPhone!.trim().isNotEmpty)
          profileCard(
            Icons.phone,
            "Mobile Number",
            p.contactPhone!,
          ),

        if (p.contactEmail != null &&
            p.contactEmail!.trim().isNotEmpty)
          profileCard(
            Icons.email,
            "Email",
            p.contactEmail!,
          ),

        if (p.address != null &&
            p.address!.trim().isNotEmpty)
          profileCard(
            Icons.location_on,
            "Address",
            p.address!,
          ),

        if (p.relationship != null &&
            p.relationship!.trim().isNotEmpty)
          profileCard(
            Icons.family_restroom,
            "Relationship",
            p.relationship!,
          ),

        if ((p.contactPhone == null ||
                p.contactPhone!.trim().isEmpty) &&
            (p.contactEmail == null ||
                p.contactEmail!.trim().isEmpty) &&
            (p.address == null ||
                p.address!.trim().isEmpty) &&
            (p.relationship == null ||
                p.relationship!.trim().isEmpty))
          _noPersonalInfo(),

        const SizedBox(height: 25),

        // --------------------------------------------------------
        // LINKED CHILDREN
        // --------------------------------------------------------

        const Text(
          "Linked Children",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        if (p.students.isEmpty)
          _noChildren()
        else
          ...p.students.map(
            (student) => childCard(
              student.name,
              _studentClass(student),
              student.admissionNo != null
                  ? "Admission No: ${student.admissionNo}"
                  : "Student ID: ${student.id}",
            ),
          ),

        const SizedBox(height: 25),

        // --------------------------------------------------------
        // ACTIONS
        // --------------------------------------------------------

        actionButton(
          Icons.lock,
          "Change Password",
          onTap: () {
            // Change password screen can be added later.
          },
        ),

        actionButton(
          Icons.logout,
          "Logout",
          onTap: () => _logout(context),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ============================================================
  // PARENT NAME
  // ============================================================

  String _parentName(ParentResponse p) {
    if (p.fatherName != null &&
        p.fatherName!.trim().isNotEmpty) {
      return p.fatherName!;
    }

    if (p.motherName != null &&
        p.motherName!.trim().isNotEmpty) {
      return p.motherName!;
    }

    if (p.guardianName != null &&
        p.guardianName!.trim().isNotEmpty) {
      return p.guardianName!;
    }

    return "Parent";
  }

  // ============================================================
  // CHILDREN TEXT
  // ============================================================

  String _childrenText(ParentResponse p) {
    if (p.students.isEmpty) {
      return "Parent";
    }

    if (p.students.length == 1) {
      return "Parent of ${p.students.first.name}";
    }

    return "Parent of ${p.students.length} children";
  }

  // ============================================================
  // STUDENT CLASS
  // ============================================================

  String _studentClass(dynamic student) {
    if (student.className != null &&
        student.className!.trim().isNotEmpty) {
      if (student.sectionName != null &&
          student.sectionName!.trim().isNotEmpty) {
        return "${student.className} - ${student.sectionName}";
      }

      return student.className!;
    }

    if (student.sectionName != null &&
        student.sectionName!.trim().isNotEmpty) {
      return "Section ${student.sectionName}";
    }

    return "Class information unavailable";
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================

  Widget profileCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(value),
      ),
    );
  }

  // ============================================================
  // CHILD CARD
  // ============================================================

  Widget childCard(
    String name,
    String className,
    String admission,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: const Icon(
            Icons.person,
            color: Colors.blue,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "$className | $admission",
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }

  // ============================================================
  // NO PERSONAL INFO
  // ============================================================

  Widget _noPersonalInfo() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "No personal information available.",
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NO CHILDREN
  // ============================================================

  Widget _noChildren() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 50,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              "No linked children found.",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR VIEW
  // ============================================================

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 15),
            Text(
              errorMessage ?? "Unable to load profile.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget actionButton(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue,
        ),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}

