import 'package:flutter/material.dart';
// TODO: Replace Firebase imports with API calls
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'logging.dart';

class EditProjectPage extends StatefulWidget {
  final String projectId;
  
  const EditProjectPage({super.key, required this.projectId});

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;
  
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
  final _specialRequirementsController = TextEditingController();
  
  // Image storage
  Map<String, File?> _images = {};
  Map<String, String?> _imageUrls = {};
  
  Map<String, dynamic>? _projectData;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
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
    _specialRequirementsController.dispose();
    super.dispose();
  }

  // TODO: Replace with API call to load project data
  Future<void> _loadProjectData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Replace Firestore call with API call
      // final doc = await FirebaseFirestore.instance
      //     .collection('projects')
      //     .doc(widget.projectId)
      //     .get();
      //
      // if (doc.exists) {
      //   _projectData = doc.data() as Map<String, dynamic>;
      //   _populateForm();
      // }

      // Temporary placeholder
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project loading not implemented - API call needed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading project: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateForm() {
    if (_projectData == null) return;
    
    _colorController.text = _projectData!['color'] ?? '';
    _ironmongeryController.text = _projectData!['ironmongery'] ?? '';
    _uValueController.text = _projectData!['u_value'] ?? '';
    _gValueController.text = _projectData!['g_value'] ?? '';
    _ventsController.text = _projectData!['vents'] ?? '';
    _acousticsController.text = _projectData!['acoustics'] ?? '';
    _sbdController.text = _projectData!['sbd'] ?? '';
    _pas24Controller.text = _projectData!['pas24'] ?? '';
    _restrictorsController.text = _projectData!['restrictors'] ?? '';
    _specialRequirementsController.text = _projectData!['special_requirements'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_projectData == null) {
      return const Scaffold(
        body: Center(child: Text('Project not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
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
              // Project Type
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
              
              // Specifications Form
              if (_projectData!['type'] == 'windows') ...[
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
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
              
              // Special Requirements
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Special Requirements',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _specialRequirementsController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Enter special requirements',
                          border: OutlineInputBorder(),
                        ),
                      ),
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
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving ? null : _saveProject,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Changes'),
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
    final isSelected = _projectData!['type'] == value;
    return InkWell(
      onTap: () {
        setState(() {
          _projectData!['type'] = value;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_a_photo),
                onPressed: () => _pickImage(label),
                tooltip: 'Add Image',
              ),
            ),
            validator: isRequired ? (value) {
              if (value?.trim().isEmpty ?? true) {
                return '$label is required';
              }
              return null;
            } : null,
          ),
          if (_images[label] != null) ...[
            const SizedBox(height: 8),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _images[label]!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 16),
                        onPressed: () {
                          setState(() {
                            _images.remove(label);
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickImage(String field) async {
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
            _images[field] = File(image.path);
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

  // TODO: Replace with API call to save/update project
  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // TODO: Replace Firebase auth with API authentication
      // final user = FirebaseAuth.instance.currentUser;
      // if (user == null) return;

      // Upload new images
      await _uploadImages();

      // TODO: Replace Firestore update with API call
      // // Prepare update data
      // final now = DateTime.now().toIso8601String();
      // final updateData = {
      //   'type': _projectData!['type'],
      //   'updated_by': user.email,
      //   'updated_at': now,
      //   'special_requirements': _specialRequirementsController.text.trim(),
      // };
      //
      // // Add specifications if windows
      // if (_projectData!['type'] == 'windows') {
      //   updateData.addAll({
      //     'color': _colorController.text.trim(),
      //     'ironmongery': _ironmongeryController.text.trim(),
      //     'u_value': _uValueController.text.trim(),
      //     'g_value': _gValueController.text.trim(),
      //     'vents': _ventsController.text.trim(),
      //     'acoustics': _acousticsController.text.trim(),
      //     'sbd': _sbdController.text.trim(),
      //     'pas24': _pas24Controller.text.trim(),
      //     'restrictors': _restrictorsController.text.trim(),
      //   });
      // }
      //
      // // Add new image URLs
      // updateData.addAll(_imageUrls);
      //
      // // Update project
      // await FirebaseFirestore.instance
      //     .collection('projects')
      //     .doc(widget.projectId)
      //     .update(updateData);
      //
      // // Log the update
      // await const AuditLogger().writeLog(
      //   projectId: widget.projectId,
      //   action: 'update',
      //   summary: 'Project specifications updated',
      // );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project update not implemented - API call needed'),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // TODO: Replace with API call to upload images
  Future<void> _uploadImages() async {
    // final user = FirebaseAuth.instance.currentUser;
    // if (user == null) return;
    //
    // final storage = FirebaseStorage.instance;
    //
    // for (var entry in _images.entries) {
    //   if (entry.value != null) {
    //     try {
    //       final fileName = '${DateTime.now().millisecondsSinceEpoch}_${entry.key}.jpg';
    //       final ref = storage.ref('specifications/${user.uid}/$fileName');
    //
    //       await ref.putFile(entry.value!);
    //       final url = await ref.getDownloadURL();
    //
    //       _imageUrls[entry.key] = url;
    //     } catch (e) {
    //       print('Error uploading image for ${entry.key}: $e');
    //     }
    //   }
    // }

    // Temporary placeholder - images will be uploaded via API
    print('TODO: Upload images via API');
  }
}