import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/network/api_exception.dart';
import '../services/user_invitation_service.dart';

class AcceptInvitationPage extends StatefulWidget {
  const AcceptInvitationPage({super.key, required this.token});

  final String token;

  @override
  State<AcceptInvitationPage> createState() => _AcceptInvitationPageState();
}

class _AcceptInvitationPageState extends State<AcceptInvitationPage> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get _hasToken => widget.token.trim().isNotEmpty;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _acceptInvitation() async {
    if (!_hasToken) {
      setState(() {
        _errorMessage = 'The invitation link is invalid or missing its token.';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final service = context.read<UserInvitationService>();

      await service.acceptInvitation(
        token: widget.token,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _successMessage =
            'Invitation accepted successfully. Redirecting to login...';
      });

      // Allow the user to briefly see the success message.
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = exception.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Unable to accept the invitation. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Accept Invitation',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Create your password to join TexasMediaDart.',
                        textAlign: TextAlign.center,
                      ),

                      if (!_hasToken) ...[
                        const SizedBox(height: 24),
                        Text(
                          'The invitation link is invalid or missing its token.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _passwordController,
                        enabled:
                            !_isLoading && _hasToken && _successMessage == null,
                        obscureText: true,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required.';
                          }

                          if (value.length < 8) {
                            return 'Password must be at least 8 characters.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPasswordController,
                        enabled:
                            !_isLoading && _hasToken && _successMessage == null,
                        obscureText: true,
                        autofillHints: const [AutofillHints.newPassword],
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm password is required.';
                          }

                          if (value != _passwordController.text) {
                            return 'Passwords do not match.';
                          }

                          return null;
                        },
                        onFieldSubmitted: (_) {
                          if (!_isLoading &&
                              _hasToken &&
                              _successMessage == null) {
                            _acceptInvitation();
                          }
                        },
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],

                      if (_successMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _successMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      FilledButton(
                        onPressed:
                            _isLoading || !_hasToken || _successMessage != null
                            ? null
                            : _acceptInvitation,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Accept Invitation'),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: _isLoading || _successMessage != null
                            ? null
                            : () {
                                Navigator.of(context)
                                    .pushReplacementNamed(AppRoutes.login);
                              },
                        child: const Text('Back to Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
