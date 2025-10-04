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

class _SpecificationsFlowState extends State<SpecificationsFlow> {
  String _selectedType = 'windows';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
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

  // RFI questions list
  List<TextEditingController> _rfiControllers = [TextEditingController()];

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project - Specifications'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Type Selection
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Project Type',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeOption('windows', 'Windows', Icons.window),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTypeOption('doors', 'Doors', Icons.door_front_door),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Project Details Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Project Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _projectNameController,
                        decoration: const InputDecoration(
                          labelText: 'Project Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Project name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _companyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Company name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _companyAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Company Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                        validator: (value) =>
                            value!.isEmpty ? 'Company address is required' : null,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Specifications Form
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Specifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (_selectedType == 'windows') ...[
                        _buildSpecificationField(
                          'Color',
                          _colorController,
                          Icons.palette,
                          isRequired: true,
                        ),
                        _buildSpecificationField(
                          'Ironmongery',
                          _ironmongeryController,
                          Icons.build,
                          isRequired: true,
                        ),
                        _buildSpecificationField(
                          'U-Value',
                          _uValueController,
                          Icons.thermostat,
                          isRequired: true,
                        ),
                        _buildSpecificationField(
                          'G-Value',
                          _gValueController,
                          Icons.wb_sunny,
                          isRequired: true,
                        ),
                        _buildSpecificationField(
                          'Vents',
                          _ventsController,
                          Icons.air,
                          isRequired: true,
                        ),
                        _buildSpecificationField(
                          'Acoustics',
                          _acousticsController,
                          Icons.volume_up,
                          isRequired: true,
                        ),
                        _buildSpecificationField(
                          'SBD',
                          _sbdController,
                          Icons.security,
                          isRequired: true,
                        ),
                        _buildSpecificationField(
                          'PAS24',
                          _pas24Controller,
                          Icons.verified,
                          isRequired: true,
                        ),
                        _buildSpecificationField(
                          'Restrictors',
                          _restrictorsController,
                          Icons.block,
                          isRequired: true,
                        ),
                      ],
                      
                      // Special Requirements (always shown)
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _specialRequirementsController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Special Requirements',
                          hintText: 'Enter any special requirements or comments',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note_add),
                        ),
                      ),

                      // Image Attachment for Specification
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickSpecificationImage,
                              icon: const Icon(Icons.attach_file),
                              label: Text(_specificationImage == null
                                  ? 'Attach Specification Image'
                                  : 'Image Attached'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _specificationImage == null
                                    ? null
                                    : Colors.green,
                              ),
                            ),
                          ),
                          if (_specificationImage != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _specificationImage = null;
                                });
                              },
                              icon: const Icon(Icons.close, color: Colors.red),
                              tooltip: 'Remove image',
                            ),
                          ],
                        ],
                      ),

                      if (_specificationImage != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _specificationImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // RFI Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'RFI Questions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: _addRFIField,
                            icon: const Icon(Icons.add_circle),
                            tooltip: 'Add RFI Question',
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add questions that need clarification from the client',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_rfiControllers.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _rfiControllers[index],
                                  decoration: InputDecoration(
                                    labelText: 'RFI Question ${index + 1}',
                                    hintText: 'Enter question text',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.help_outline),
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              if (_rfiControllers.length > 1) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _removeRFIField(index),
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  tooltip: 'Remove question',
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () {
                        // Navigate back to home dashboard
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeDashboard()),
                          (route) => false,
                        );
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _saveProject,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Project'),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected 
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter $label',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: isRequired ? (value) {
          if (value?.trim().isEmpty ?? true) {
            return '$label is required';
          }
          return null;
        } : null,
      ),
    );
  }

  void _addRFIField() {
    setState(() {
      _rfiControllers.add(TextEditingController());
    });
  }

  void _removeRFIField(int index) {
    setState(() {
      _rfiControllers[index].dispose();
      _rfiControllers.removeAt(index);
    });
  }

  Future<void> _pickSpecificationImage() async {
    try {
      // Show dialog to choose between camera and gallery
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
          SnackBar(content: Text('Error picking image: $e')),
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert image to base64 if present
      final attachmentBase64 = await _convertImageToBase64(_specificationImage);

      // Collect RFI questions (only non-empty ones)
      final rfiQuestions = _rfiControllers
          .where((controller) => controller.text.trim().isNotEmpty)
          .map((controller) => Rfi(questionText: controller.text.trim()))
          .toList();

      // Create specification based on project type
      List<Specification> specifications = [];

      if (_selectedType == 'windows') {
        // For windows: include all fields
        specifications.add(Specification(
          versionNo: 1,
          colour: _colorController.text.trim(),
          ironmongery: _ironmongeryController.text.trim(),
          uValue: double.tryParse(_uValueController.text.trim()) ?? 0.0,
          gValue: double.tryParse(_gValueController.text.trim()) ?? 0.0,
          vents: _ventsController.text.trim(),
          acoustics: _acousticsController.text.trim(),
          sbd: _sbdController.text.trim(),
          pas24: _pas24Controller.text.trim(),
          restrictors: _restrictorsController.text.trim(),
          specialComments: _specialRequirementsController.text.trim(),
          attachmentUrl: attachmentBase64,
        ));
      } else if (_selectedType == 'doors') {
        // For doors: only special_comments
        specifications.add(Specification(
          versionNo: 1,
          colour: '',
          ironmongery: '',
          uValue: 0.0,
          gValue: 0.0,
          vents: '',
          acoustics: '',
          sbd: '',
          pas24: '',
          restrictors: '',
          specialComments: _specialRequirementsController.text.trim(),
          attachmentUrl: attachmentBase64,
        ));
      }

      // Create project with specifications and RFIs
      final project = Project(
        projectName: _projectNameController.text.trim().isNotEmpty
            ? _projectNameController.text.trim()
            : 'New ${_capitalize(_selectedType)} Project',
        companyName: _companyNameController.text.trim().isNotEmpty
            ? _companyNameController.text.trim()
            : 'Your Company',
        companyAddress: _companyAddressController.text.trim().isNotEmpty
            ? _companyAddressController.text.trim()
            : 'Your Address',
        projectType: _selectedType,
        status: 'active',
        specifications: specifications,
        rfis: rfiQuestions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save project via API
      print('📤 Creating project with ${rfiQuestions.length} RFIs');
      final createdProject = await ProjectService.instance.createProject(project);

      if (createdProject == null) {
        throw Exception('Failed to create project');
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project created successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to home dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeDashboard(),
        ),
        (route) => false,
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
