import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../models/user_model.dart';
import 'academic_resources_screen.dart';
import 'cafe_admin_panel.dart';
import 'library_admin_panel.dart';
import 'query_board_screen.dart';
import 'manage_users_screen.dart';
import 'notice_board_screen.dart';
import 'transport_screen.dart';
import 'cgpa_calculator_screen.dart';
import 'progress_tracker_screen.dart';
import 'edit_campus_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final role = user?.role ?? '';
    final isAdmin = role == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E295B),
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () {
              auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        bottom: isAdmin
            ? TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3.5,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(
                    text: 'Pending',
                    icon: Icon(Icons.more_horiz_rounded, size: 22),
                  ),
                  Tab(
                    text: 'Edit',
                    icon: Icon(Icons.edit_outlined, size: 22),
                  ),
                  Tab(
                    text: 'Features',
                    icon: Icon(Icons.grid_view_rounded, size: 22),
                  ),
                ],
              )
            : null,
      ),
      body: isAdmin
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTab(auth),
                _buildEditTab(context),
                _buildFeaturesTab(context),
              ],
            )
          : _buildFeaturesTab(context),
    );
  }

  // ============ PENDING APPROVALS TAB ============
  Widget _buildPendingTab(AuthService auth) {
    return FutureBuilder<List<UserModel>>(
      future: auth.getPendingUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1E295B)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error loading data',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E295B),
                  ),
                  child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        final pending = snapshot.data ?? [];

        if (pending.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA5D6A7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 54,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No pending requests!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'All users have been approved',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            itemBuilder: (context, i) {
              final user = pending[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: const Color(0xFF1A1E36),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${user.role.toUpperCase()} • ${user.department ?? 'N/A'}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 32),
                        onPressed: () async {
                          await auth.approveUser(user.id);
                          if (!context.mounted) return;
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ ${user.name} approved!'),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: 'Approve',
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_rounded,
                            color: AppColors.error, size: 32),
                        onPressed: () async {
                          await auth.rejectUser(user.id);
                          if (!context.mounted) return;
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ ${user.name} rejected!'),
                              backgroundColor: AppColors.error,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: 'Reject',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============ EDIT TAB ============
  Widget _buildEditTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6F00).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  'Edit Campus Info',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _editCard(
            Icons.school_rounded,
            'Edit Library Hours',
            'Update opening/closing times',
            const Color(0xFF4CAF50),
            const Color(0xFFE8F5E9),
            () => _editLibraryDialog(context),
          ),
          _editCard(
            Icons.restaurant_rounded,
            'Edit Cafeteria Menu',
            'Update daily/weekly menu & prices',
            const Color(0xFFE53935),
            const Color(0xFFFFEBEE),
            () => _editCafeteriaDialog(context),
          ),
          _editCard(
            Icons.directions_bus_rounded,
            'Edit Bus Schedule',
            'Update routes, timings & fares',
            const Color(0xFF1E88E5),
            const Color(0xFFE3F2FD),
            () => _editTransportDialog(context),
          ),
          _editCard(
            Icons.campaign_rounded,
            'Post New Notice',
            'Add academic/exam/event notices',
            const Color(0xFFFB8C00),
            const Color(0xFFFFF8E1),
            () => _addNoticeDialog(context),
          ),
          _editCard(
            Icons.calendar_month_rounded,
            'Update Academic Calendar',
            'Update semester dates & holidays',
            const Color(0xFF1A237E),
            const Color(0xFFEDE7F6),
            () => _editCalendarDialog(context),
          ),
          _editCard(
            Icons.checkroom_rounded,
            'Update Dress Code',
            'Modify dress code guidelines',
            const Color(0xFF8E24AA),
            const Color(0xFFF3E5F5),
            () => _editDressCodeDialog(context),
          ),
        ],
      ),
    );
  }

  // ============ FEATURES TAB ============
  Widget _buildFeaturesTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFC62828), Color(0xFFE53935)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC62828).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Admin Controls',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.12,
            children: [
              _featureCard(
                Icons.people_alt_rounded,
                'Manage\nUsers',
                const Color(0xFF1A237E),
                const [Color(0xFFF0F3FF), Color(0xFFDCE2FF)],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
                ),
              ),
              _featureCard(
                Icons.edit_rounded,
                'Edit\nCampus',
                const Color(0xFFF57C00),
                const [Color(0xFFFFF7ED), Color(0xFFFFEAD0)],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditCampusScreen()),
                ),
              ),
              _featureCard(
                Icons.restaurant_rounded,
                'Cafeteria\nAdmin',
                const Color(0xFFE53935),
                const [Color(0xFFFFF1F2), Color(0xFFFFD6D9)],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CafeAdminPanel()),
                ),
              ),
              _featureCard(
                Icons.school_rounded,
                'Library\nAdmin',
                const Color(0xFF4CAF50),
                const [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LibraryAdminPanel()),
                ),
              ),
              _featureCard(
                Icons.menu_book_rounded,
                'Academic\nResources',
                const Color(0xFF1E88E5),
                const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AcademicResourcesScreen()),
                ),
              ),
              _featureCard(
                Icons.campaign_rounded,
                'Notice\nBoard',
                const Color(0xFFFB8C00),
                const [Color(0xFFFEFCE8), Color(0xFFFEF08A)],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NoticeBoardScreen()),
                ),
              ),
              _featureCard(
                Icons.directions_bus_rounded,
                'Transport',
                const Color(0xFF00ACC1),
                const [Color(0xFFECFEFF), Color(0xFFCFFAFE)],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransportScreen()),
                ),
              ),
              _featureCard(
                Icons.calculate_rounded,
                'CGPA\nCalculator',
                const Color(0xFF7B1FA2),
                const [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CGPACalculatorScreen()),
                ),
              ),
              _featureCard(
                Icons.trending_up_rounded,
                'Progress\nTracker',
                const Color(0xFF2E7D32),
                const [Color(0xFFF0FDF4), Color(0xFFBBF7D0)],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProgressTrackerScreen()),
                ),
              ),
              _featureCard(
                Icons.forum_rounded,
                'Query\nBoard',
                const Color(0xFF00897B),
                const [Color(0xFFF0FDFA), Color(0xFFCCFBF1)],
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QueryBoardScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ HELPER WIDGETS ============
  Widget _featureCard(
    IconData icon,
    String title,
    Color iconColor,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 30, color: iconColor),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E295B),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _editCard(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
    Color bgTint,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: bgTint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: const Color(0xFF1A1E36),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[500]),
        onTap: onTap,
      ),
    );
  }

  // ============ EDIT DIALOGS ============
  void _editLibraryDialog(BuildContext context) {
    final c1 = TextEditingController(text: '8:00 AM - 5:00 PM');
    final c2 =
        TextEditingController(text: 'Administration Building, Ground Floor');
    _showCustomDialog(
      context,
      'Edit Library Info',
      [
        _buildDialogInput(label: 'Hours', controller: c1),
        const SizedBox(height: 12),
        _buildDialogInput(label: 'Location', controller: c2),
      ],
      () => _showSnackBar(context, '✅ Library info updated!'),
    );
  }

  void _editCafeteriaDialog(BuildContext context) {
    final c = TextEditingController(text: 'Porota, Dal, Egg, Tea - 45 Tk');
    _showCustomDialog(
      context,
      'Edit Menu Item',
      [
        _buildDialogInput(label: 'Menu Item', controller: c),
      ],
      () => _showSnackBar(context, '✅ Menu updated!'),
    );
  }

  void _editTransportDialog(BuildContext context) {
    final c1 = TextEditingController(text: '7:00 AM');
    final c2 = TextEditingController(text: '40 Tk');
    _showCustomDialog(
      context,
      'Edit Bus Schedule',
      [
        _buildDialogInput(label: 'Timing', controller: c1),
        const SizedBox(height: 12),
        _buildDialogInput(label: 'Fare', controller: c2),
      ],
      () => _showSnackBar(context, '✅ Schedule updated!'),
    );
  }

  void _addNoticeDialog(BuildContext context) {
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    _showCustomDialog(
      context,
      'Post New Notice',
      [
        _buildDialogInput(label: 'Title', controller: c1),
        const SizedBox(height: 12),
        _buildDialogInput(label: 'Description', controller: c2, maxLines: 3),
      ],
      () => _showSnackBar(context, '✅ Notice posted!'),
    );
  }

  void _editCalendarDialog(BuildContext context) {
    final c = TextEditingController(text: 'January - May 2026');
    _showCustomDialog(
      context,
      'Update Calendar',
      [
        _buildDialogInput(label: 'Semester Dates', controller: c),
      ],
      () => _showSnackBar(context, '✅ Calendar updated!'),
    );
  }

  void _editDressCodeDialog(BuildContext context) {
    final c =
        TextEditingController(text: AppConstants.dressCode['male_summer']);
    _showCustomDialog(
      context,
      'Update Dress Code',
      [
        _buildDialogInput(label: 'Dress Code', controller: c, maxLines: 3),
      ],
      () => _showSnackBar(context, '✅ Dress code updated!'),
    );
  }

  Widget _buildDialogInput({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1E36),
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomDialog(
    BuildContext context,
    String title,
    List<Widget> fields,
    VoidCallback onSave,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFF4F5FB),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1E36),
                ),
              ),
              const SizedBox(height: 20),
              ...fields,
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5C6BC0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onSave();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E295B),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}