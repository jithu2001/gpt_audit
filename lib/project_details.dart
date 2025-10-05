import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:ui';
import 'edit_project_page.dart';
import 'audit_log_page.dart';
import 'add_specification_page.dart';
import 'models/project.dart';
import 'services/project_service.dart';
import 'services/rfi_service.dart';
import 'services/auth_service.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project? project;
  final String? projectId;

  const ProjectDetailsPage({super.key, this.project, this.projectId});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage>
    with SingleTickerProviderStateMixin {
  Project? _project;
  bool _isLoading = true;
  String? _error;
  AnimationController? _animController;
  List<Animation<double>>? _animations;

  // Expansion states
  bool _isSpecsExpanded = false;
  bool _isRFIExpanded = false;
  bool _isDetailsExpanded = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animations = List.generate(
      5,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animController!,
          curve: Interval(
            (index * 0.1).clamp(0.0, 0.8),
            (0.6 + (index * 0.1)).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _loadProject();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  Animation<double> _getAnimation(int index) {
    if (_animations != null && index < _animations!.length) {
      return _animations![index];
    }
    return const AlwaysStoppedAnimation(1.0);
  }

  Future<void> _loadProject() async {
    if (widget.project != null) {
      setState(() {
        _project = widget.project;
        _isLoading = false;
      });
      _animController?.forward();
    } else if (widget.projectId != null) {
      try {
        final projectId = int.tryParse(widget.projectId!);
        if (projectId != null) {
          final project = await ProjectService.instance.getProjectById(projectId);
          if (mounted) {
            setState(() {
              _project = project;
              _isLoading = false;
              _error = project == null ? 'Project not found' : null;
            });
            _animController?.forward();
          }
        } else {
          setState(() {
            _error = 'Invalid project ID';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _error = 'Failed to load project: $e';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _error = 'No project or project ID provided';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _project == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, size: 64, color: Colors.red.shade700),
              ),
              const SizedBox(height: 24),
              Text(
                _error ?? 'Project not found',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getProjectTypeColor(_project!.projectType),
                      _getProjectTypeColor(_project!.projectType).withOpacity(0.7),
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
                          opacity: _getAnimation(0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getProjectTypeIcon(_project!.projectType),
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _project!.projectName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _project!.companyName,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                  child: const Icon(Icons.edit_attributes, color: Colors.white),
                ),
                onPressed: () => _showStatusUpdateDialog(_project!),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.history, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AuditLogPage(projectId: _project?.id?.toString()),
                    ),
                  );
                },
              ),
              if (AuthService.instance.currentUser?.isAdmin ?? false)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onPressed: () => _confirmDeleteProject(_project!),
                ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  FadeTransition(
                    opacity: _getAnimation(0),
                    child: _buildStatusCard(),
                  ),

                  const SizedBox(height: 20),

                  // Specifications Section
                  FadeTransition(
                    opacity: _getAnimation(1),
                    child: _buildExpandableCard(
                      title: 'Specifications',
                      icon: Icons.description_rounded,
                      isExpanded: _isSpecsExpanded,
                      onToggle: () => setState(() => _isSpecsExpanded = !_isSpecsExpanded),
                      trailing: _project!.specifications.isNotEmpty
                          ? TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddSpecificationPage(project: _project!),
                                  ),
                                ).then((_) => _loadProject());
                              },
                              icon: const Icon(Icons.add_circle_outline, size: 18),
                              label: const Text('New'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF6366F1),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                            )
                          : null,
                      child: _buildSpecificationsContent(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // RFI Section
                  FadeTransition(
                    opacity: _getAnimation(2),
                    child: _buildExpandableCard(
                      title: 'RFI (Request for Information)',
                      icon: Icons.question_answer_rounded,
                      isExpanded: _isRFIExpanded,
                      onToggle: () => setState(() => _isRFIExpanded = !_isRFIExpanded),
                      trailing: TextButton.icon(
                        onPressed: () => _addNewRFI(),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('Add'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                      child: _buildRFIContent(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Project Details Section
                  FadeTransition(
                    opacity: _getAnimation(3),
                    child: _buildExpandableCard(
                      title: 'Project Details',
                      icon: Icons.info_rounded,
                      isExpanded: _isDetailsExpanded,
                      onToggle: () => setState(() => _isDetailsExpanded = !_isDetailsExpanded),
                      child: _buildProjectDetailsContent(),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusColor = _getProjectStatusColor(_project!.status);

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(_project!.status),
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Status',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDisplayName(_project!.status),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (_project!.createdAt != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Created',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, y').format(_project!.createdAt!),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
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
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (trailing != null) trailing,
                    if (trailing != null) const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: child,
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsContent() {
    if (_project!.specifications.isEmpty) {
      return Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 48,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Specifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add specification details for this project',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddSpecificationPage(project: _project!),
                      ),
                    ).then((_) => _loadProject());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Specification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final latestSpec = _project!.specifications.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 16),

        // Version Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Version ${latestSpec.versionNo}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const Spacer(),
            if (_project!.specifications.length > 1)
              TextButton(
                onPressed: () => _showAllVersions(),
                child: Text('View All (${_project!.specifications.length})'),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Specification Fields - Different for Windows vs Doors
        if (_project!.projectType.toLowerCase() == 'windows') ...[
          _buildSpecRow('Colour', latestSpec.colour, attachment: latestSpec.colourAttachment),
          _buildSpecRow('Ironmongery', latestSpec.ironmongery, attachment: latestSpec.ironmongeryAttachment),
          _buildSpecRow('U-Value', latestSpec.uValue, attachment: latestSpec.uValueAttachment),
          _buildSpecRow('G-Value', latestSpec.gValue, attachment: latestSpec.gValueAttachment),
          _buildSpecRow('Vents', latestSpec.vents, attachment: latestSpec.ventsAttachment),
          _buildSpecRow('Acoustics', latestSpec.acoustics, attachment: latestSpec.acousticsAttachment),
          _buildSpecRow('SBD', latestSpec.sbd, attachment: latestSpec.sbdAttachment),
          _buildSpecRow('PAS24', latestSpec.pas24, attachment: latestSpec.pas24Attachment),
          _buildSpecRow('Restrictors', latestSpec.restrictors, attachment: latestSpec.restrictorsAttachment),
          _buildSpecRow('Special Comments', latestSpec.specialComments),
        ] else ...[
          // For doors, only show special comments
          _buildSpecRow('Special Comments', latestSpec.specialComments),
        ],

        // Attached Image
        if (latestSpec.attachmentUrl != null && latestSpec.attachmentUrl!.isNotEmpty) ...[
          const SizedBox(height: 20),
          InkWell(
            onTap: () => _showImageDialog(latestSpec.attachmentUrl!),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Specification Attachment',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Click to view full image',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Color(0xFF6366F1), size: 16),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecRow(String label, dynamic value, {String? attachment}) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          if (attachment != null && attachment.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.image,
                color: Color(0xFF6366F1),
                size: 20,
              ),
              onPressed: () => _showImageDialog(attachment),
              tooltip: 'View attachment',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildRFIContent() {
    if (_project!.rfis.isEmpty) {
      return Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.question_answer_outlined,
                  size: 48,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No RFI Questions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add questions to request information about this project',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _addNewRFI,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _project!.rfis.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final rfi = _project!.rfis[index];
            return _buildRFICard(rfi, index);
          },
        ),
      ],
    );
  }

  Widget _buildRFICard(dynamic rfi, int index) {
    final isAnswered = rfi.answerValue != null && rfi.answerValue!.isNotEmpty;
    final answerIsYes = rfi.answerValue?.toLowerCase() == 'yes';
    final statusColor = isAnswered ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAnswered ? 'ANSWERED' : 'PENDING',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '#${index + 1}',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.help_outline, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rfi.questionText ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: answerIsYes,
                onChanged: (value) => _toggleRFIAnswer(rfi, value ?? false),
                activeColor: const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              Text(
                answerIsYes ? 'Yes' : 'No',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: answerIsYes ? const Color(0xFF10B981) : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetailsContent() {
    return Column(
      children: [
        const Divider(height: 1),
        const SizedBox(height: 16),
        _buildDetailRow(Icons.business_rounded, 'Company', _project!.companyName),
        _buildDetailRow(Icons.location_on_rounded, 'Address', _project!.companyAddress),
        _buildDetailRow(Icons.category_rounded, 'Type', _project!.projectType.toUpperCase()),
        if (_project!.createdAt != null)
          _buildDetailRow(
            Icons.calendar_today_rounded,
            'Created',
            DateFormat('MMM d, y • h:mm a').format(_project!.createdAt!),
          ),
        if (_project!.updatedAt != null)
          _buildDetailRow(
            Icons.update_rounded,
            'Updated',
            DateFormat('MMM d, y • h:mm a').format(_project!.updatedAt!),
          ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF6366F1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBase64Image(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (e) {
      return Container(
        height: 200,
        color: Colors.grey.shade200,
        child: Center(
          child: Icon(Icons.broken_image, color: Colors.grey.shade400, size: 48),
        ),
      );
    }
  }

  void _showImageDialog(String base64String) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildBase64Image(base64String),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black87,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllVersions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  const Text(
                    'All Versions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _project!.specifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final spec = _project!.specifications[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: index == 0 ? const Color(0xFF6366F1).withOpacity(0.05) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: index == 0 ? const Color(0xFF6366F1).withOpacity(0.3) : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: index == 0 ? const Color(0xFF6366F1) : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Version ${spec.versionNo}',
                                style: TextStyle(
                                  color: index == 0 ? Colors.white : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (index == 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'LATEST',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_project!.projectType.toLowerCase() == 'windows') ...[
                          Text(
                            'U-Value: ${spec.uValue} • G-Value: ${spec.gValue}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          spec.specialComments.isNotEmpty
                              ? spec.specialComments
                              : 'No special comments',
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewRFI() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _AddRFIDialog(),
    );

    if (result != null && result.isNotEmpty && _project?.id != null) {
      try {
        final success = await RFIService.instance.createRFI(_project!.id!, result);
        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('RFI question added successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          _loadProject();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Failed to add RFI question'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Error: $e')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  void _toggleRFIAnswer(dynamic rfi, bool isYes) async {
    final answer = isYes ? 'yes' : 'no';

    try {
      final success = await RFIService.instance.answerRfi(rfi.id!, answer);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('RFI answered: ${answer.toUpperCase()}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
        _loadProject();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Failed to update RFI'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showStatusUpdateDialog(Project project) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Project Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption('not_yet_started', 'Not Started', Colors.grey),
            _buildStatusOption('progress', 'In Progress', const Color(0xFF6366F1)),
            _buildStatusOption('completed', 'Completed', const Color(0xFF10B981)),
          ],
        ),
      ),
    );

    if (newStatus != null) {
      try {
        await ProjectService.instance.updateProjectStatus(project.id!, newStatus);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Status updated successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          _loadProject();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Failed to update status: $e')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  Widget _buildStatusOption(String status, String displayName, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_getStatusIcon(status), color: color, size: 20),
      ),
      title: Text(displayName),
      onTap: () => Navigator.pop(context, status),
    );
  }

  Future<void> _confirmDeleteProject(Project project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.delete, color: Colors.red.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Delete Project'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this project?'),
            const SizedBox(height: 12),
            Text(
              project.projectName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && project.id != null) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        final success = await ProjectService.instance.deleteProject(project.id!);
        Navigator.pop(context); // Close loading

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Project deleted successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Failed to delete project'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Error: $e')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
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
        return const Color(0xFF6366F1);
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

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'progress':
        return Icons.autorenew_rounded;
      case 'not_yet_started':
        return Icons.schedule_rounded;
      default:
        return Icons.help_outline_rounded;
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

// Dialog for adding new RFI
class _AddRFIDialog extends StatefulWidget {
  const _AddRFIDialog();

  @override
  State<_AddRFIDialog> createState() => _AddRFIDialogState();
}

class _AddRFIDialogState extends State<_AddRFIDialog> {
  late final TextEditingController _questionController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Add RFI Question')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your question for this project',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _questionController,
            maxLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Question',
              hintText: 'e.g., What is the required lead time for delivery?',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_questionController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Please enter a question'),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
              return;
            }
            Navigator.pop(context, _questionController.text.trim());
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
          ),
          child: const Text('Add Question'),
        ),
      ],
    );
  }
}

