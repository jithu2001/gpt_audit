import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../auth.dart';
import '../home_dashboard.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isAuth = AuthService.instance.isAuthenticated;
    setState(() {
      _isAuthenticated = isAuth;
      _isLoading = false;
    });
  }

  Future<void> _onAuthStateChanged() async {
    print('🔄 Auth state changed callback START');
    if (mounted) {
      final isAuth = AuthService.instance.isAuthenticated;
      print('🔄 Auth state changed. isAuthenticated: $isAuth, current _isAuthenticated: $_isAuthenticated');
      setState(() {
        _isAuthenticated = isAuth;
      });
      print('🔄 setState completed. _isAuthenticated is now: $_isAuthenticated');
    } else {
      print('🔄 Widget not mounted, cannot update state');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔧 AuthWrapper build: _isAuthenticated=$_isAuthenticated, _isLoading=$_isLoading');

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      print('🔧 AuthWrapper: Building HomeDashboard with onSignOut callback');
      return HomeDashboard(onSignOut: _onAuthStateChanged);
    } else {
      print('🔧 AuthWrapper: Building AuthPage');
      return AuthPage(onAuthSuccess: _onAuthStateChanged);
    }
  }
}
