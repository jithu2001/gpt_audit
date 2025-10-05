import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'project_details.dart';
import 'services/project_service.dart';
import 'models/project.dart';

class ProjectListPage extends StatefulWidget {
  final String? filter;

  const ProjectListPage({super.key, this.filter});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Future<List<Project>>? _projectsFuture;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    if (widget.filter != null) {
      _selectedFilter = widget.filter!;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _refreshProjects();
    _animController.forward();
  }

  void _refreshProjects() {
    setState(() {
      _projectsFuture = ProjectService.instance.getAllProjects();
    });
    if (mounted) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 120,
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
                    padding: const EdgeInsets.fromLTRB(60, 20, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeTransition(
                          opacity: _animController,
                          child: const Text(
                            'All Projects',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.refresh_rounded, color: Colors.white),
                ),
                onPressed: _refreshProjects,
              ),
            ],
          ),

          // Search and Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Search Bar
                  FadeTransition(
                    opacity: _animController,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search projects, companies...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close_rounded, color: Colors.grey.shade600),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value.toLowerCase());
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Filter Chips
                  FadeTransition(
                    opacity: _animController,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'All', Icons.folder_rounded, const Color(0xFF6366F1)),
                          const SizedBox(width: 12),
                          _buildFilterChip('not_yet_started', 'Not Started', Icons.schedule_rounded, Colors.grey),
                          const SizedBox(width: 12),
                          _buildFilterChip('progress', 'In Progress', Icons.autorenew_rounded, const Color(0xFF8B5CF6)),
                          const SizedBox(width: 12),
                          _buildFilterChip('completed', 'Completed', Icons.check_circle_rounded, const Color(0xFF10B981)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Projects List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: _buildProjectsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon, Color color) {
    final isSelected = _selectedFilter == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedFilter = value),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: [color, color.withOpacity(0.8)])
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade200,
                width: isSelected ? 0 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
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
                  size: 18,
                  color: isSelected ? Colors.white : color,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
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
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red.shade900),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final allProjects = snapshot.data ?? [];

        // Apply filters
        List<Project> filteredProjects = allProjects;
        if (_selectedFilter != 'all') {
          filteredProjects = allProjects.where((p) => p.status?.toLowerCase() == _selectedFilter).toList();
        }

        if (_searchQuery.isNotEmpty) {
          filteredProjects = filteredProjects.where((p) {
            return p.companyName.toLowerCase().contains(_searchQuery) ||
                p.projectName.toLowerCase().contains(_searchQuery) ||
                p.companyAddress.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        if (filteredProjects.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: FadeTransition(
                opacity: _animController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No projects found'
                          : 'No projects in this category',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Try searching with different keywords'
                          : 'Create a new project to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final project = filteredProjects[index];
              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animController,
                    curve: Interval(
                      (index * 0.1).clamp(0.0, 1.0),
                      ((index * 0.1) + 0.5).clamp(0.0, 1.0),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: Interval(
                        (index * 0.1).clamp(0.0, 1.0),
                        ((index * 0.1) + 0.5).clamp(0.0, 1.0),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  child: _buildProjectCard(project),
                ),
              );
            },
            childCount: filteredProjects.length,
          ),
        );
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    final statusColor = _getStatusColor(project.status);
    final typeColor = _getProjectTypeColor(project.projectType);

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
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(position: animation.drive(tween), child: child);
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
              border: Border.all(color: Colors.grey.shade200),
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
                  // Project Type Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [typeColor, typeColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getProjectTypeIcon(project.projectType),
                      color: Colors.white,
                      size: 28,
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
                        Row(
                          children: [
                            Icon(Icons.business_rounded, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                project.companyName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                DateFormat('MMM d, y').format(project.createdAt!),
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

                  // Arrow
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

  Color _getStatusColor(String? status) {
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
