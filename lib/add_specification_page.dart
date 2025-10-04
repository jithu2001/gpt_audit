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

class _AddSpecificationPageState extends State<AddSpecificationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

  // Image storage
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
  void dispose() {
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
            _attachmentImage = File(image.path);
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

  Future<void> _saveSpecification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert image to base64 if present
      final attachmentBase64 = await _convertImageToBase64(_attachmentImage);

      // Create specification based on project type
      Specification newSpec;

      if (widget.project.projectType == 'windows') {
        // For windows: include all fields
        newSpec = Specification(
          versionNo: _nextVersionNo,
          colour: _colorController.text.trim(),
          ironmongery: _ironmongeryController.text.trim(),
          uValue: double.tryParse(_uValueController.text.trim()) ?? 0.0,
          gValue: double.tryParse(_gValueController.text.trim()) ?? 0.0,
          vents: _ventsController.text.trim(),
          acoustics: _acousticsController.text.trim(),
          sbd: _sbdController.text.trim(),
          pas24: _pas24Controller.text.trim(),
          restrictors: _restrictorsController.text.trim(),
          specialComments: _specialCommentsController.text.trim(),
          attachmentUrl: attachmentBase64,
        );
      } else {
        // For doors: only special_comments
        newSpec = Specification(
          versionNo: _nextVersionNo,
          colour: '',
          ironmongery: '',
          uValue: 0.0,
          gValue: 0.0,
          vents: '',
          acoustics: '',
          sbd: '',
          pas24: '',
          restrictors: '',
          specialComments: _specialCommentsController.text.trim(),
          attachmentUrl: attachmentBase64,
        );
      }

      // Save specification via API
      final createdSpec = await ProjectService.instance
          .addSpecification(widget.project.id!, newSpec);

      if (createdSpec == null) {
        throw Exception('Failed to add specification');
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Specification v${createdSpec.versionNo} added successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back
      Navigator.pop(context, true); // Return true to indicate success

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding specification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Specification v$_nextVersionNo'),
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
              // Project Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project.projectName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Project Type: ${widget.project.projectType.toUpperCase()}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Version: ${widget.project.specifications.isEmpty ? 'None' : 'v${widget.project.specifications.first.versionNo}'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Specifications Form
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Specification Details',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (widget.project.projectType == 'windows') ...[
                        _buildTextField(
                          'Color',
                          _colorController,
                          Icons.palette,
                          isRequired: true,
                        ),
                        _buildTextField(
                          'Ironmongery',
                          _ironmongeryController,
                          Icons.build,
                          isRequired: true,
                        ),
                        _buildTextField(
                          'U-Value',
                          _uValueController,
                          Icons.thermostat,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextField(
                          'G-Value',
                          _gValueController,
                          Icons.wb_sunny,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextField(
                          'Vents',
                          _ventsController,
                          Icons.air,
                          isRequired: true,
                        ),
                        _buildTextField(
                          'Acoustics',
                          _acousticsController,
                          Icons.volume_up,
                          isRequired: true,
                        ),
                        _buildTextField(
                          'SBD',
                          _sbdController,
                          Icons.security,
                          isRequired: true,
                        ),
                        _buildTextField(
                          'PAS24',
                          _pas24Controller,
                          Icons.verified,
                          isRequired: true,
                        ),
                        _buildTextField(
                          'Restrictors',
                          _restrictorsController,
                          Icons.block,
                          isRequired: true,
                        ),
                      ],

                      // Special Requirements (always shown)
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _specialCommentsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: widget.project.projectType == 'doors'
                              ? 'Special Requirements *'
                              : 'Special Requirements',
                          hintText: 'Enter any additional comments or changes',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.note_add),
                        ),
                        validator: widget.project.projectType == 'doors'
                            ? (value) {
                                if (value?.trim().isEmpty ?? true) {
                                  return 'Special requirements are required for doors';
                                }
                                return null;
                              }
                            : null,
                      ),

                      // Image Attachment
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickAttachmentImage,
                              icon: const Icon(Icons.attach_file),
                              label: Text(_attachmentImage == null
                                  ? 'Attach Image (Optional)'
                                  : 'Image Attached'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _attachmentImage == null
                                    ? null
                                    : Colors.green,
                              ),
                            ),
                          ),
                          if (_attachmentImage != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _attachmentImage = null;
                                });
                              },
                              icon: const Icon(Icons.close, color: Colors.red),
                              tooltip: 'Remove image',
                            ),
                          ],
                        ],
                      ),

                      if (_attachmentImage != null) ...[
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
                              _attachmentImage!,
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

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _saveSpecification,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Specification'),
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

  Widget _buildTextField(
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
          labelText: isRequired ? '$label *' : label,
          hintText: 'Enter $label',
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
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
    );
  }
}
