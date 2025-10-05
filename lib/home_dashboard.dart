import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'add_project.dart';
import 'project_list.dart';
import 'account_page.dart';
import 'project_details.dart';
import 'services/auth_service.dart';
import 'services/project_service.dart';
import 'models/project.dart';

class HomeDashboard extends StatefulWidget {
  final Future<void> Function()? onSignOut;

  const HomeDashboard({super.key, this.onSignOut});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _fabController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );

    // Animate FAB on tab change
    _fabController.reset();
    _fabController.forward();
  }

  Future<void> _handleSignOut() async {
    print('🏠 HomeDashboard: onSignOut handler called');
    if (widget.onSignOut != null) {
      await widget.onSignOut!();
      print('🏠 HomeDashboard: onSignOut callback completed');
    } else {
      print('🏠 HomeDashboard: onSignOut callback is NULL!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          _fabController.reset();
          _fabController.forward();
        },
        children: [
          const _DashboardContent(),
          const AddProjectPage(),
          AccountPage(onSignOut: _handleSignOut),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, 'Home'),
                _buildNavItem(1, Icons.add_circle_rounded, 'Add'),
                _buildNavItem(2, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent>
    with SingleTickerProviderStateMixin {
  Future<List<Project>>? _projectsFuture;
  late AnimationController _animController;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _refreshProjects();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create staggered animations for cards
    _cardAnimations = List.generate(
      4,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(
            (index * 0.1).clamp(0.0, 0.8),
            (0.6 + (index * 0.1)).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _refreshProjects() {
    setState(() {
      _projectsFuture = ProjectService.instance.getAllProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshProjects();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: const Color(0xFF6366F1),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                        Color(0xFFA855F7),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FadeTransition(
                            opacity: _cardAnimations[0],
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.wb_sunny_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('EEEE, MMM d').format(now),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          FadeTransition(
                            opacity: _cardAnimations[0],
                            child: Text(
                              'Hello, ${user?.fullName?.split(' ').first ?? 'User'}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FadeTransition(
                            opacity: _cardAnimations[0],
                            child: Text(
                              'Ready to manage your projects?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    _buildStatsCards(),

                    const SizedBox(height: 32),

                    // Recent Projects Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeTransition(
                          opacity: _cardAnimations[2],
                          child: const Text(
                            'Recent Projects',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _cardAnimations[2],
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProjectListPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('View All'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Projects List
                    _buildProjectsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return FutureBuilder<List<Project>>(
      future: _projectsFuture,
      builder: (context, snapshot) {
        final projects = snapshot.data ?? [];
        final total = projects.length;
        final inProgress = projects.where((p) => p.status == 'progress').length;
        final completed = projects.where((p) => p.status == 'completed').length;
        final notStarted = projects.where((p) => p.status == 'not_yet_started').length;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                total.toString(),
                Icons.folder_rounded,
                const Color(0xFF6366F1),
                _cardAnimations[1],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Active',
                inProgress.toString(),
                Icons.autorenew_rounded,
                const Color(0xFF8B5CF6),
                _cardAnimations[1],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Done',
                completed.toString(),
                Icons.check_circle_rounded,
                const Color(0xFF10B981),
                _cardAnimations[1],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Animation<double> animation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOutCubic,
        )),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsList() {
    return FutureBuilder<List<Project>>(
      future: _projectsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error.toString());
        }

        final projects = snapshot.data ?? [];

        if (projects.isEmpty) {
          return _buildEmptyState();
        }

        final recentProjects = projects.take(5).toList();

        return Column(
          children: recentProjects.asMap().entries.map((entry) {
            final index = entry.key;
            final project = entry.value;

            return FadeTransition(
              opacity: _cardAnimations[3],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 0.2 + (index * 0.05)),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animController,
                  curve: Interval(
                    (0.3 + (index * 0.1)).clamp(0.0, 0.8),
                    (0.8 + (index * 0.1)).clamp(0.0, 1.0),
                    curve: Curves.easeOutCubic,
                  ),
                )),
                child: _buildProjectCard(project),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    final statusColor = _getProjectStatusColor(project.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ProjectDetailsPage(projectId: project.id?.toString()),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;
                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Project Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getProjectTypeColor(project.projectType),
                          _getProjectTypeColor(project.projectType).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getProjectTypeIcon(project.projectType),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Project Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.projectName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.companyName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusDisplayName(project.status),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (project.createdAt != null)
                              Text(
                                DateFormat('MMM d').format(project.createdAt!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _cardAnimations[3],
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 60,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Projects Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by creating your first project',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error loading projects: $error',
              style: TextStyle(color: Colors.red.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProjectStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'progress':
        return const Color(0xFF6366F1);
      case 'not_yet_started':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getProjectTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'windows':
        return const Color(0xFF3B82F6);
      case 'doors':
        return const Color(0xFF10B981);
      case 'curtain_wall':
        return const Color(0xFF8B5CF6);
      case 'cladding':
        return const Color(0xFFF59E0B);
      case 'roofing':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getProjectTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'windows':
        return Icons.window_rounded;
      case 'doors':
        return Icons.door_front_door_rounded;
      case 'curtain_wall':
        return Icons.view_quilt_rounded;
      case 'cladding':
        return Icons.layers_rounded;
      case 'roofing':
        return Icons.roofing_rounded;
      default:
        return Icons.work_rounded;
    }
  }

  String _getStatusDisplayName(String? status) {
    switch (status) {
      case 'not_yet_started':
        return 'Not Started';
      case 'progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }
}
