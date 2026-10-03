import 'package:flutter/material.dart';

import '../services/identity_api_service.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, required this.token});

  final String token;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final IdentityApiService _identityApiService = IdentityApiService();

  bool _isVerifying = true;
  bool _isVerified = false;
  String? _message;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyEmail();
    });
  }

  Future<void> _verifyEmail() async {
    final token = widget.token.trim();

    if (token.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isVerifying = false;
        _isVerified = false;
        _message = 'The email verification link is invalid.';
      });

      return;
    }

    try {
      final result = await _identityApiService.verifyEmail(token: token);

      if (!mounted) {
        return;
      }

      setState(() {
        _isVerifying = false;
        _isVerified = result.isEmailVerified;

        _message = result.isEmailVerified
            ? 'Your email address has been verified successfully.'
            : 'Unable to verify your email address.';
      });
    } on IdentityApiException catch (ex) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isVerifying = false;
        _isVerified = false;
        _message = ex.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isVerifying = false;
        _isVerified = false;
        _message = 'Unable to verify your email address. Please try again.';
      });
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _identityApiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isVerifying) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Verifying your email...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while we verify your email address.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final icon = _isVerified ? Icons.check_circle_outline : Icons.error_outline;

    final title = _isVerified ? 'Email Verified' : 'Verification Failed';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(_message ?? '', textAlign: TextAlign.center),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _goToLogin,
            child: const Text('Go to Sign In'),
          ),
        ),
      ],
    );
  }
}
