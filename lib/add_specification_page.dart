import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'models/project.dart';
import 'services/project_service.dart';

class AddSpecificationPage extends StatefulWidget {
  final Project project;

  const AddSpecificationPage({super.key, required this.project});

  @override
  State<AddSpecificationPage> createState() => _AddSpecificationPageState();
}

class _AddSpecificationPageState extends State<AddSpecificationPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _colorController = TextEditingController();
  final _ironmongeryController = TextEditingController();
  final _uValueController = TextEditingController();
  final _gValueController = TextEditingController();
  final _ventsController = TextEditingController();
  final _acousticsController = TextEditingController();
  final _sbdController = TextEditingController();
  final _pas24Controller = TextEditingController();
  final _restrictorsController = TextEditingController();
  final _specialCommentsController = TextEditingController();

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
  File? _attachmentImage;

  int get _nextVersionNo {
    if (widget.project.specifications.isEmpty) {
      return 1;
    }
    return widget.project.specifications
            .map((spec) => spec.versionNo)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _colorController.dispose();
    _ironmongeryController.dispose();
    _uValueController.dispose();
    _gValueController.dispose();
    _ventsController.dispose();
    _acousticsController.dispose();
    _sbdController.dispose();
    _pas24Controller.dispose();
    _restrictorsController.dispose();
    _specialCommentsController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachmentImage() async {
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
                      Text('Camera', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                      Text('Gallery', style: TextStyle(color: Colors.white, fontSize: 16)),
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
            _attachmentImage = File(image.path);
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

  Future<void> _saveSpecification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final attachmentBase64 = await _convertImageToBase64(_attachmentImage);
      final colourAttachment = await _convertImageToBase64(_colourImage);
      final ironmongeryAttachment = await _convertImageToBase64(_ironmongeryImage);
      final uValueAttachment = await _convertImageToBase64(_uValueImage);
      final gValueAttachment = await _convertImageToBase64(_gValueImage);
      final ventsAttachment = await _convertImageToBase64(_ventsImage);
      final acousticsAttachment = await _convertImageToBase64(_acousticsImage);
      final sbdAttachment = await _convertImageToBase64(_sbdImage);
      final pas24Attachment = await _convertImageToBase64(_pas24Image);
      final restrictorsAttachment = await _convertImageToBase64(_restrictorsImage);

      Specification newSpec;

      if (widget.project.projectType.toLowerCase() == 'windows') {
        newSpec = Specification(
          versionNo: _nextVersionNo,
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
          specialComments: _specialCommentsController.text.trim(),
          attachmentUrl: attachmentBase64,
        );
      } else {
        newSpec = Specification(
          versionNo: _nextVersionNo,
          colour: '',
          ironmongery: '',
          uValue: '',
          gValue: '',
          vents: '',
          acoustics: '',
          sbd: '',
          pas24: '',
          restrictors: '',
          specialComments: _specialCommentsController.text.trim(),
          attachmentUrl: attachmentBase64,
        );
      }

      final createdSpec = await ProjectService.instance
          .addSpecification(widget.project.id!, newSpec);

      if (createdSpec == null) {
        throw Exception('Failed to add specification');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Specification v${createdSpec.versionNo} added successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context, true);

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
                Text('Error: $e'),
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
    final isWindows = widget.project.projectType.toLowerCase() == 'windows';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Modern Gradient App Bar
          SliverAppBar(
            expandedHeight: 200,
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Version $_nextVersionNo',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add Specification',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.project.projectName,
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
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project Info Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withValues(alpha: 0.1),
                                const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isWindows ? Icons.window : Icons.door_front_door,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.project.projectType.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Current: ${widget.project.specifications.isEmpty ? 'No versions' : 'v${widget.project.specifications.map((s) => s.versionNo).reduce((a, b) => a > b ? a : b)}'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Form Fields
                        if (isWindows) ...[
                          _buildTextFieldWithAttachment(
                            'Colour',
                            _colorController,
                            Icons.palette,
                            _colourImage,
                            (file) => _colourImage = file,
                            isRequired: true,
                          ),
                          _buildTextFieldWithAttachment(
                            'Ironmongery',
                            _ironmongeryController,
                            Icons.build,
                            _ironmongeryImage,
                            (file) => _ironmongeryImage = file,
                            isRequired: true,
                          ),
                          _buildTextFieldWithAttachment(
                            'U-Value',
                            _uValueController,
                            Icons.thermostat,
                            _uValueImage,
                            (file) => _uValueImage = file,
                            isRequired: true,
                            keyboardType: TextInputType.text,
                          ),
                          _buildTextFieldWithAttachment(
                            'G-Value',
                            _gValueController,
                            Icons.wb_sunny,
                            _gValueImage,
                            (file) => _gValueImage = file,
                            isRequired: true,
                            keyboardType: TextInputType.text,
                          ),
                          _buildTextFieldWithAttachment(
                            'Vents',
                            _ventsController,
                            Icons.air,
                            _ventsImage,
                            (file) => _ventsImage = file,
                            isRequired: true,
                          ),
                          _buildTextFieldWithAttachment(
                            'Acoustics',
                            _acousticsController,
                            Icons.volume_up,
                            _acousticsImage,
                            (file) => _acousticsImage = file,
                            isRequired: true,
                          ),
                          _buildTextFieldWithAttachment(
                            'SBD',
                            _sbdController,
                            Icons.security,
                            _sbdImage,
                            (file) => _sbdImage = file,
                            isRequired: true,
                          ),
                          _buildTextFieldWithAttachment(
                            'PAS24',
                            _pas24Controller,
                            Icons.verified,
                            _pas24Image,
                            (file) => _pas24Image = file,
                            isRequired: true,
                          ),
                          _buildTextFieldWithAttachment(
                            'Restrictors',
                            _restrictorsController,
                            Icons.block,
                            _restrictorsImage,
                            (file) => _restrictorsImage = file,
                            isRequired: true,
                          ),
                        ],

                        // Special Comments (always shown)
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
                                    child: const Icon(Icons.note_add, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    isWindows ? 'Special Comments' : 'Special Requirements *',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _specialCommentsController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Enter any additional comments or requirements...',
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
                                validator: !isWindows
                                    ? (value) {
                                        if (value?.trim().isEmpty ?? true) {
                                          return 'Special requirements are required for doors';
                                        }
                                        return null;
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Image Attachment
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
                                  Icon(Icons.attach_file, color: Color(0xFF6366F1)),
                                  SizedBox(width: 12),
                                  Text(
                                    'Attachment',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_attachmentImage != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _attachmentImage!,
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
                                        onPressed: _pickAttachmentImage,
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
                                        onPressed: () => setState(() => _attachmentImage = null),
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        label: const Text('Remove', style: TextStyle(color: Colors.red)),
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
                                  onTap: _pickAttachmentImage,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 2,
                                        style: BorderStyle.solid,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add_photo_alternate, color: Colors.white, size: 32),
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
                        ),

                        const SizedBox(height: 32),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveSpecification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBackgroundColor: Colors.grey.shade400,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save, size: 24),
                                      SizedBox(width: 12),
                                      Text(
                                        'Save Specification',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
                  label + (isRequired ? ' *' : ''),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: 'Enter $label',
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
                      return null;
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithAttachment(
    String label,
    TextEditingController controller,
    IconData icon,
    File? imageFile,
    Function(File?) onImageChanged, {
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
                Expanded(
                  child: Text(
                    label + (isRequired ? ' *' : ''),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: 'Enter $label',
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
                      return null;
                    }
                  : null,
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
      ),
    );
  }

  Future<void> _pickFieldImage(Function(File?) onImageChanged) async {
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
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF6366F1)),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF6366F1)),
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
