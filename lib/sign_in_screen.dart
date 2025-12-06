import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show json;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  GoogleSignInUserData? _currentUser;
  String _errorMessage = '';
  Future<void>? _initialization;

  @override
  void initState() {
    super.initState();
    _ensureInitialized();
  }

  Future<void> _ensureInitialized() {
    return _initialization ??=
    GoogleSignInPlatform.instance.init(const InitParameters())
      ..catchError((dynamic _) {
        _initialization = null;
      });
  }

  void _setUser(GoogleSignInUserData? user) {
    setState(() {
      _currentUser = user;
      _errorMessage = '';
    });
  }

  Future<void> _handleSignIn() async {
    try {
      await _ensureInitialized();
      final AuthenticationResults result = await GoogleSignInPlatform.instance
          .authenticate(const AuthenticateParameters());
      _setUser(result.user);
    } on GoogleSignInException catch (e) {
      setState(() {
        _errorMessage = e.code == GoogleSignInExceptionCode.canceled
            ? ''
            : 'GoogleSignInException ${e.code}: ${e.description}';
      });
    }
  }

  Future<void> _handleSignOut() async {
    await _ensureInitialized();
    await GoogleSignInPlatform.instance.disconnect(const DisconnectParams());
    _setUser(null);
  }

  Widget _buildBody() {
    final GoogleSignInUserData? user = _currentUser;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        if (user != null) ...<Widget>[
          ListTile(
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email ?? ''),
          ),
          const Text('Signed in successfully.'),
          ElevatedButton(
            onPressed: _handleSignOut,
            child: const Text('SIGN OUT'),
          ),
        ] else ...<Widget>[
          const Text('You are not currently signed in.'),
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('SIGN IN'),
          ),
        ],
        if (_errorMessage.isNotEmpty) Text(_errorMessage),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign In')),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
    );
  }
}
