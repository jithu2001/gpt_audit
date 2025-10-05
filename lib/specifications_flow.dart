import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'logging.dart';
import 'home_dashboard.dart';
import 'services/project_service.dart';
import 'models/project.dart';

class SpecificationsFlow extends StatefulWidget {
  const SpecificationsFlow({super.key});

  @override
  State<SpecificationsFlow> createState() => _SpecificationsFlowState();
}

class _SpecificationsFlowState extends State<SpecificationsFlow>
    with SingleTickerProviderStateMixin {
  String _selectedType = 'windows';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _projectNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _colorController = TextEditingController();
  final _ironmongeryController = TextEditingController();
  final _uValueController = TextEditingController();
  final _gValueController = TextEditingController();
  final _ventsController = TextEditingController();
  final _acousticsController = TextEditingController();
  final _sbdController = TextEditingController();
  final _pas24Controller = TextEditingController();
  final _restrictorsController = TextEditingController();
  final _specialRequirementsController = TextEditingController();

  // Image storage for specification attachment
  File? _specificationImage;

  // Image storage for individual fields
  File? _colourImage;
  File? _ironmongeryImage;
  File? _uValueImage;
  File? _gValueImage;
  File? _ventsImage;
  File? _acousticsImage;
  File? _sbdImage;
  File? _pas24Image;
  File? _restrictorsImage;

  // RFI questions list
  List<TextEditingController> _rfiControllers = [TextEditingController()];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _projectNameController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _colorController.dispose();
    _ironmongeryController.dispose();
    _uValueController.dispose();
    _gValueController.dispose();
    _ventsController.dispose();
    _acousticsController.dispose();
    _sbdController.dispose();
    _pas24Controller.dispose();
    _restrictorsController.dispose();
    _specialRequirementsController.dispose();
    for (var controller in _rfiControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _pickSpecificationImage() async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.image, color: Color(0xFF6366F1)),
              SizedBox(width: 12),
              Text('Select Image Source'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context, ImageSource.camera),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Camera',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => Navigator.pop(context, ImageSource.gallery),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.photo_library, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Gallery',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: source);

        if (image != null) {
          setState(() {
            _specificationImage = File(image.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text('Error picking image: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _convertImageToBase64(File? imageFile) async {
    if (imageFile == null) return null;

    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Please fill in all required fields'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final attachmentBase64 =
          await _convertImageToBase64(_specificationImage);

      Specification specification;

      final colourAttachment = await _convertImageToBase64(_colourImage);
      final ironmongeryAttachment = await _convertImageToBase64(_ironmongeryImage);
      final uValueAttachment = await _convertImageToBase64(_uValueImage);
      final gValueAttachment = await _convertImageToBase64(_gValueImage);
      final ventsAttachment = await _convertImageToBase64(_ventsImage);
      final acousticsAttachment = await _convertImageToBase64(_acousticsImage);
      final sbdAttachment = await _convertImageToBase64(_sbdImage);
      final pas24Attachment = await _convertImageToBase64(_pas24Image);
      final restrictorsAttachment = await _convertImageToBase64(_restrictorsImage);

      if (_selectedType == 'windows') {
        specification = Specification(
          versionNo: 1,
          colour: _colorController.text.trim(),
          colourAttachment: colourAttachment,
          ironmongery: _ironmongeryController.text.trim(),
          ironmongeryAttachment: ironmongeryAttachment,
          uValue: _uValueController.text.trim(),
          uValueAttachment: uValueAttachment,
          gValue: _gValueController.text.trim(),
          gValueAttachment: gValueAttachment,
          vents: _ventsController.text.trim(),
          ventsAttachment: ventsAttachment,
          acoustics: _acousticsController.text.trim(),
          acousticsAttachment: acousticsAttachment,
          sbd: _sbdController.text.trim(),
          sbdAttachment: sbdAttachment,
          pas24: _pas24Controller.text.trim(),
          pas24Attachment: pas24Attachment,
          restrictors: _restrictorsController.text.trim(),
          restrictorsAttachment: restrictorsAttachment,
          specialComments: _specialRequirementsController.text.trim(),
          attachmentUrl: attachmentBase64,
        );
      } else {
        specification = Specification(
          versionNo: 1,
          colour: '',
          ironmongery: '',
          uValue: '',
          gValue: '',
          vents: '',
          acoustics: '',
          sbd: '',
          pas24: '',
          restrictors: '',
          specialComments: _specialRequirementsController.text.trim(),
          attachmentUrl: attachmentBase64,
        );
      }

      final rfiQuestions = _rfiControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .map((question) => Rfi(questionText: question))
          .toList();

      final project = Project(
        projectName: _projectNameController.text.trim(),
        companyName: _companyNameController.text.trim(),
        companyAddress: _companyAddressController.text.trim(),
        projectType: _selectedType,
        specifications: [specification],
        rfis: rfiQuestions,
      );

      final createdProject = await ProjectService.instance.createProject(project);

      if (!mounted) return;

      if (createdProject != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Project "${createdProject.projectName}" created successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeDashboard()),
          (route) => false,
        );
      } else {
        throw Exception('Failed to create project');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error creating project: $e')),
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

  @override
  Widget build(BuildContext context) {
    final isWindows = _selectedType == 'windows';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Modern Gradient App Bar
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
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(60, 20, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.add_business, color: Colors.white, size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          'Create New Project',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Add specifications and RFIs',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Type Selection
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.category, color: Color(0xFF6366F1)),
                                SizedBox(width: 12),
                                Text(
                                  'Project Type',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTypeOption(
                                      'windows', 'Windows', Icons.window),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTypeOption(
                                      'doors', 'Doors', Icons.door_front_door),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Project Information
                      _buildSection(
                        'Project Information',
                        Icons.info_outline,
                        [
                          _buildModernTextField(
                            'Project Name',
                            _projectNameController,
                            Icons.business,
                            isRequired: true,
                          ),
                          _buildModernTextField(
                            'Company Name',
                            _companyNameController,
                            Icons.business_center,
                            isRequired: true,
                          ),
                          _buildModernTextField(
                            'Company Address',
                            _companyAddressController,
                            Icons.location_on,
                            isRequired: true,
                            maxLines: 2,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Specifications
                      _buildSection(
                        'Specifications',
                        Icons.settings,
                        [
                          if (isWindows) ...[
                            _buildTextFieldWithAttachment(
                              'Colour',
                              _colorController,
                              _colourImage,
                              (file) => _colourImage = file,
                              isRequired: true,
                            ),
                            _buildTextFieldWithAttachment(
                              'Ironmongery',
                              _ironmongeryController,
                              _ironmongeryImage,
                              (file) => _ironmongeryImage = file,
                              isRequired: true,
                            ),
                            _buildTextFieldWithAttachment(
                              'U-Value',
                              _uValueController,
                              _uValueImage,
                              (file) => _uValueImage = file,
                              isRequired: true,
                            ),
                            _buildTextFieldWithAttachment(
                              'G-Value',
                              _gValueController,
                              _gValueImage,
                              (file) => _gValueImage = file,
                              isRequired: true,
                            ),
                            _buildTextFieldWithAttachment(
                              'Vents',
                              _ventsController,
                              _ventsImage,
                              (file) => _ventsImage = file,
                              isRequired: true,
                            ),
                            _buildTextFieldWithAttachment(
                              'Acoustics',
                              _acousticsController,
                              _acousticsImage,
                              (file) => _acousticsImage = file,
                              isRequired: true,
                            ),
                            _buildTextFieldWithAttachment(
                              'SBD',
                              _sbdController,
                              _sbdImage,
                              (file) => _sbdImage = file,
                              isRequired: true,
                            ),
                            _buildTextFieldWithAttachment(
                              'PAS24',
                              _pas24Controller,
                              _pas24Image,
                              (file) => _pas24Image = file,
                              isRequired: true,
                            ),
                            _buildTextFieldWithAttachment(
                              'Restrictors',
                              _restrictorsController,
                              _restrictorsImage,
                              (file) => _restrictorsImage = file,
                              isRequired: true,
                            ),
                          ],
                          _buildModernTextField(
                            isWindows ? 'Special Comments' : 'Special Requirements',
                            _specialRequirementsController,
                            Icons.note_add,
                            isRequired: !isWindows,
                            maxLines: 4,
                          ),

                          // Image Attachment
                          const SizedBox(height: 16),
                          if (_specificationImage != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _specificationImage!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickSpecificationImage,
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Change Image'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        setState(() => _specificationImage = null),
                                    icon:
                                        const Icon(Icons.delete, color: Colors.red),
                                    label: const Text('Remove',
                                        style: TextStyle(color: Colors.red)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.all(16),
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else
                            InkWell(
                              onTap: _pickSpecificationImage,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade50,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF6366F1),
                                            Color(0xFF8B5CF6)
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add_photo_alternate,
                                          color: Colors.white, size: 32),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Tap to add image',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Optional',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // RFI Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.question_answer,
                                      color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'RFI Questions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _rfiControllers.add(TextEditingController());
                                    });
                                  },
                                  icon: const Icon(Icons.add_circle,
                                      color: Color(0xFF6366F1)),
                                  tooltip: 'Add RFI Question',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Add questions that need to be answered by the client',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...List.generate(
                              _rfiControllers.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _rfiControllers[index],
                                        decoration: InputDecoration(
                                          labelText: 'Question ${index + 1}',
                                          hintText: 'Enter RFI question...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          prefixIcon: const Icon(Icons.help_outline),
                                        ),
                                      ),
                                    ),
                                    if (_rfiControllers.length > 1) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _rfiControllers[index].dispose();
                                            _rfiControllers.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const HomeDashboard()),
                                        (route) => false,
                                      );
                                    },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveProject,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.grey.shade400,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, size: 20),
                                        SizedBox(width: 8),
                                        Text('Create Project'),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String value, String label, IconData icon) {
    final isSelected = _selectedType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          hintText: 'Enter $label',
          prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: isRequired
            ? (value) {
                if (value?.trim().isEmpty ?? true) {
                  return '$label is required';
                }
                if (keyboardType == TextInputType.number) {
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildTextFieldWithAttachment(
    String label,
    TextEditingController controller,
    File? imageFile,
    Function(File?) onImageChanged, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label + (isRequired ? ' *' : ''),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _pickFieldImage(onImageChanged),
                icon: Icon(
                  imageFile != null ? Icons.check_circle : Icons.add_photo_alternate,
                  size: 18,
                ),
                label: Text(imageFile != null ? 'Attached' : 'Add Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: imageFile != null ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                  side: BorderSide(
                    color: imageFile != null ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          if (imageFile != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Image.file(imageFile),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, color: Color(0xFF10B981), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'View Attached Image',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => setState(() => onImageChanged(null)),
                  tooltip: 'Remove attachment',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickFieldImage(Function(File?) onImageChanged) async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          onImageChanged(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
