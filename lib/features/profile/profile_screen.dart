import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:parent_app/models/parent_response.dart';
import 'package:parent_app/services/auth_service.dart';
import 'package:parent_app/services/api_service.dart';
import 'package:parent_app/services/parent_service.dart';
import 'package:parent_app/storage/local_storage.dart';

import 'package:parent_app/features/auth/login/change_password_screen.dart';
import 'package:parent_app/features/auth/login/login_screen.dart';
import 'package:parent_app/models/student_response.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ParentResponse? parent;
  bool isLoading = true;
  String? errorMessage;

  static const Color primary = Color(0xff3155D9);
  static const Color primaryDark = Color(0xff2343B8);
  static const Color background = Color(0xffF6F8FC);
  static const Color textDark = Color(0xff172033);
  static const Color textMuted = Color(0xff697386);
  static const Color border = Color(0xffE5E9F0);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ParentService.getMyParentProfile();

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = ApiService.decodeResponse(response);

        if (data is Map<String, dynamic>) {
          final loadedParent = ParentResponse.fromJson(data);

          setState(() {
            parent = loadedParent;
            isLoading = false;
          });
        } else {
          setState(() {
            parent = null;
            errorMessage = 'Invalid profile data received.';
            isLoading = false;
          });
        }
      } else {
        debugPrint('Profile API failed: ${response.statusCode}');

        setState(() {
          parent = null;
          errorMessage = 'Unable to load profile.';
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('PROFILE ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        parent = null;
        errorMessage = 'Unable to load profile. Please try again.';
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Logout?',
            style: GoogleFonts.poppins(
              color: textDark,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to logout from your parent account?',
            style: GoogleFonts.poppins(
              color: textMuted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffD93025),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      await AuthService.logout();
    } catch (e) {
      debugPrint('LOGOUT API ERROR: $e');
    }

    await LocalStorage.clearLoginData();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: textDark,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            color: textDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : _loadProfile,
            icon: const Icon(Icons.refresh_rounded, color: textDark),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? _buildLoading()
            : errorMessage != null
            ? _buildError()
            : RefreshIndicator(
                color: primary,
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                  child: Column(
                    children: [
                      _buildProfileHeader(),

                      const SizedBox(height: 18),

                      _buildPersonalInformation(),

                      const SizedBox(height: 18),

                      _buildLinkedStudents(),

                      const SizedBox(height: 18),

                      _buildAccountSettings(),

                      const SizedBox(height: 18),

                      _buildLogoutButton(),

                      const SizedBox(height: 20),

                      _buildFooter(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    final name = _parentName();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryDark, primary, Color(0xff5A78E7)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(.18),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 82,
            width: 82,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.14),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded, color: primary, size: 43),
          ),

          const SizedBox(height: 13),

          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(.20)),
            ),
            child: Text(
              'PARENT ACCOUNT',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),

          const SizedBox(height: 14),

          if (_relationship().isNotEmpty)
            Text(
              _relationship(),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(.82),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PERSONAL INFORMATION
  // ============================================================

  Widget _buildPersonalInformation() {
    return _sectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline_rounded,
      children: [
        _infoRow(icon: Icons.phone_outlined, title: 'Phone', value: _phone()),

        _divider(),

        _infoRow(icon: Icons.email_outlined, title: 'Email', value: _email()),

        _divider(),

        _infoRow(
          icon: Icons.location_on_outlined,
          title: 'Address',
          value: _address(),
        ),

        if (_relationship().isNotEmpty) ...[
          _divider(),
          _infoRow(
            icon: Icons.family_restroom_rounded,
            title: 'Relationship',
            value: _relationship(),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // LINKED STUDENTS
  // ============================================================

  Widget _buildLinkedStudents() {
    final students = _students();

    return _sectionCard(
      title: 'Linked Students',
      icon: Icons.school_outlined,
      trailing: students.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xffEDF3FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${students.length}',
                style: GoogleFonts.poppins(
                  color: primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : null,
      children: [
        if (students.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No students linked to this account.',
              style: GoogleFonts.poppins(color: textMuted, fontSize: 12.5),
            ),
          )
        else
          ...List.generate(students.length, (index) {
            final student = students[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == students.length - 1 ? 0 : 10,
              ),
              child: _studentCard(student),
            );
          }),
      ],
    );
  }

Widget _studentCard(StudentResponse student) {
    final name = _studentName(student);
    final className = _studentClass(student);
    final section = _studentSection(student);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE4EAF8)),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xffEAF0FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.school_rounded, color: primary, size: 24),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (className.isNotEmpty || section.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (className.isNotEmpty) className,
                      if (section.isNotEmpty) 'Section $section',
                    ].join(' • '),
                    style: GoogleFonts.poppins(
                      color: textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xff9AA3B2),
            size: 22,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACCOUNT SETTINGS
  // ============================================================

  Widget _buildAccountSettings() {
    return _sectionCard(
      title: 'Account & Security',
      icon: Icons.security_outlined,
      children: [
        _settingsButton(
          icon: Icons.lock_reset_rounded,
          title: 'Change Password',
          subtitle: 'Update your account password',
          iconBackground: const Color(0xffEAF0FF),
          iconColor: primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          },
        ),

        const SizedBox(height: 10),

        _settingsButton(
          icon: Icons.verified_user_outlined,
          title: 'Account Security',
          subtitle: 'Your account is protected by secure login',
          iconBackground: const Color(0xffEAF8F1),
          iconColor: const Color(0xff209764),
          onTap: () {
            _showSecurityInfo();
          },
        ),
      ],
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () => _logout(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffF0D7D5)),
        ),
        child: Row(
          children: [
            Container(
              height: 43,
              width: 43,
              decoration: BoxDecoration(
                color: const Color(0xffFFF0EF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xffD93025),
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      color: const Color(0xffC62828),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sign out from this account',
                    style: GoogleFonts.poppins(
                      color: textMuted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded, color: Color(0xffB8A0A0)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // COMMON SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xffEDF3FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: primary, size: 19),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              if (trailing != null) trailing,
            ],
          ),

          const SizedBox(height: 15),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: const Color(0xffF6F8FC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xff64748B), size: 18),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? 'Not available' : value,
                style: GoogleFonts.poppins(
                  color: textDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SETTINGS BUTTON
  // ============================================================

  Widget _settingsButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBackground,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xffFAFBFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffEDF0F5)),
        ),
        child: Row(
          children: [
            Container(
              height: 43,
              width: 43,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconColor, size: 21),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: textDark,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: textMuted,
                      fontSize: 10.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xffA4ACB9),
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECURITY INFO
  // ============================================================

  void _showSecurityInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xffDCE1E9),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  color: Color(0xffEAF8F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xff209764),
                  size: 30,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Account Security',
                style: GoogleFonts.poppins(
                  color: textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Your parent account uses secure authentication. Keep your password private and do not share it with anyone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: textMuted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: const BoxDecoration(
                color: Color(0xffffefee),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xffD93025),
                size: 34,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Unable to Load Profile',
              style: GoogleFonts.poppins(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: textMuted, fontSize: 12),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: primary, strokeWidth: 2.5),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Smart School',
          style: GoogleFonts.poppins(
            color: const Color(0xff9AA3B2),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Learning Today, Leading Tomorrow',
          style: GoogleFonts.poppins(
            color: const Color(0xffB0B7C3),
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SAFE DATA HELPERS
  // ============================================================

  String _parentName() {
    final p = parent;
    if (p == null) return 'Parent';

    final father = p.fatherName?.trim();
    if (father != null && father.isNotEmpty) {
      return father;
    }

    final mother = p.motherName?.trim();
    if (mother != null && mother.isNotEmpty) {
      return mother;
    }

    final guardian = p.guardianName?.trim();
    if (guardian != null && guardian.isNotEmpty) {
      return guardian;
    }

    return 'Parent';
  }

  String _phone() {
    final p = parent;
    if (p == null) return '';

    try {
      final value = (p as dynamic).contactPhone;
      return value?.toString() ?? '';
    } catch (_) {}

    return '';
  }

  String _email() {
    final p = parent;
    if (p == null) return '';

    try {
      final value = (p as dynamic).contactEmail;
      return value?.toString() ?? '';
    } catch (_) {}

    return '';
  }

  String _address() {
    final p = parent;
    if (p == null) return '';

    try {
      final value = (p as dynamic).address;
      return value?.toString() ?? '';
    } catch (_) {}

    return '';
  }

  String _relationship() {
    final p = parent;
    if (p == null) return '';

    try {
      final value = (p as dynamic).relationship;
      return value?.toString() ?? '';
    } catch (_) {}

    return '';
  }

List<StudentResponse> _students() {
  return parent?.students ?? [];
}

String _studentName(StudentResponse student) {
  return student.name.trim().isNotEmpty ? student.name.trim() : 'Student';
}

String _studentClass(StudentResponse student) {
  return student.className?.trim() ?? '';
}

String _studentSection(StudentResponse student) {
  return student.sectionName?.trim() ?? '';
}

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Container(height: 1, color: const Color(0xffEEF1F5)),
    );
  }
}
