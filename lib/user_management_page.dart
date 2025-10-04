import 'package:flutter/material.dart';
import 'services/user_service.dart';
import 'models/user.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    final users = await UserService.instance.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _createUser() async {
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'user';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create User'),
          ),
        ],
      ),
    );

    if (result == true) {
      final user = await UserService.instance.createUser(
        fullName: fullNameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: selectedRole,
      );

      if (user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create user'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> _toggleUserStatus(User user) async {
    // Determine current status - if null or not 'active', treat as disabled
    final isCurrentlyActive = user.status?.toLowerCase() == 'active';
    final newStatus = isCurrentlyActive ? 'disabled' : 'active';
    final actionText = isCurrentlyActive ? 'Disable' : 'Activate';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionText User'),
        content: Text(
          'Are you sure you want to ${actionText.toLowerCase()} ${user.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: isCurrentlyActive ? Colors.red : Colors.green,
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await UserService.instance.updateUserStatus(
        user.userId,
        newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'User ${actionText.toLowerCase()}d successfully'
                  : 'Failed to update user status',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          _loadUsers();
        }
      }
    }
  }

  Future<void> _resetPassword(User user) async {
    final passwordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password for ${user.fullName}'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );

    if (result == true && passwordController.text.isNotEmpty) {
      final success = await UserService.instance.resetUserPassword(
        user.userId,
        passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Password reset successfully'
                  : 'Failed to reset password',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }

    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.isAdmin
                              ? Colors.purple
                              : Colors.blue,
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.isAdmin
                                        ? Colors.purple[100]
                                        : Colors.blue[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    user.role.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: user.isAdmin
                                          ? Colors.purple[900]
                                          : Colors.blue[900],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (user.status?.toLowerCase() == 'active')
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    (user.status?.toUpperCase() ?? 'DISABLED'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: (user.status?.toLowerCase() == 'active')
                                          ? Colors.green[900]
                                          : Colors.red[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'toggle_status':
                                _toggleUserStatus(user);
                                break;
                              case 'reset_password':
                                _resetPassword(user);
                                break;
                            }
                          },
                          itemBuilder: (context) {
                            final isCurrentlyActive = user.status?.toLowerCase() == 'active';
                            return [
                              PopupMenuItem(
                                value: 'toggle_status',
                                child: Row(
                                  children: [
                                    Icon(
                                      isCurrentlyActive
                                          ? Icons.block
                                          : Icons.check_circle,
                                      size: 20,
                                      color: isCurrentlyActive
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(isCurrentlyActive
                                        ? 'Disable User'
                                        : 'Activate User'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'reset_password',
                                child: Row(
                                  children: [
                                    Icon(Icons.lock_reset,
                                        size: 20, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text('Reset Password'),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createUser,
        icon: const Icon(Icons.person_add),
        label: const Text('Create User'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
