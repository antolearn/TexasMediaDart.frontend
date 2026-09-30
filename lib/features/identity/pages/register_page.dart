import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../models/current_terms.dart';
import '../services/identity_api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _identityApiService = IdentityApiService();

  bool _isLoading = false;
  bool _isLoadingTerms = false;
  bool _termsAccepted = false;

  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _identityApiService.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_termsAccepted) {
      setState(() {
        _errorMessage = 'You must accept the Terms and Conditions to register.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _identityApiService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        acceptTerms: _termsAccepted,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _successMessage = 'Account created successfully for ${result.email}.';
      });

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } on IdentityApiException catch (exception) {
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
        _errorMessage = 'Unable to create the account. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showTermsAndConditions() async {
    if (_isLoadingTerms || _isLoading) {
      return;
    }

    setState(() {
      _isLoadingTerms = true;
      _errorMessage = null;
    });

    try {
      final terms = await _identityApiService.getCurrentTerms();

      if (!mounted) {
        return;
      }

      final accepted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return _TermsAndConditionsDialog(terms: terms);
        },
      );

      if (!mounted) {
        return;
      }

      if (accepted == true) {
        setState(() {
          _termsAccepted = true;
          _errorMessage = null;
        });

        _formKey.currentState?.validate();
      }
    } on IdentityApiException catch (exception) {
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
        _errorMessage =
            'Unable to load the Terms and Conditions. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTerms = false;
        });
      }
    }
  }

  void _removeTermsAcceptance() {
    if (_isLoading || _isLoadingTerms) {
      return;
    }

    setState(() {
      _termsAccepted = false;
    });

    _formKey.currentState?.validate();
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
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Sign up for TexasMediaDart',
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required.';
                          }

                          if (!value.contains('@')) {
                            return 'Enter a valid email address.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
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

                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
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
                      ),

                      const SizedBox(height: 16),

                      // Terms and Conditions
                      FormField<bool>(
                        initialValue: _termsAccepted,
                        validator: (_) {
                          if (!_termsAccepted) {
                            return 'You must accept the Terms and Conditions.';
                          }

                          return null;
                        },
                        builder: (formFieldState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _termsAccepted,
                                    onChanged: _isLoading || _isLoadingTerms
                                        ? null
                                        : (value) async {
                                            if (value == true) {
                                              await _showTermsAndConditions();

                                              if (mounted) {
                                                formFieldState.didChange(
                                                  _termsAccepted,
                                                );
                                              }
                                            } else {
                                              _removeTermsAcceptance();

                                              formFieldState.didChange(false);
                                            }
                                          },
                                  ),

                                  Expanded(
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        const Text('I agree to the '),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          onPressed:
                                              _isLoading || _isLoadingTerms
                                              ? null
                                              : () async {
                                                  await _showTermsAndConditions();

                                                  if (mounted) {
                                                    formFieldState.didChange(
                                                      _termsAccepted,
                                                    );
                                                  }
                                                },
                                          child: const Text(
                                            'Terms and Conditions',
                                          ),
                                        ),
                                        const Text('.'),
                                      ],
                                    ),
                                  ),

                                  if (_isLoadingTerms)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              if (formFieldState.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    top: 4,
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    formFieldState.errorText!,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      // Error Message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],

                      // Success Message
                      if (_successMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _successMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Create Account
                      FilledButton(
                        onPressed: _isLoading || _isLoadingTerms
                            ? null
                            : _register,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create Account'),
                      ),

                      const SizedBox(height: 12),

                      // Login
                      TextButton(
                        onPressed: _isLoading || _isLoadingTerms
                            ? null
                            : () {
                                Navigator.of(context)
                                    .pushReplacementNamed(AppRoutes.login);
                              },
                        child: const Text('Already have an account? Login'),
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

class _TermsAndConditionsDialog extends StatelessWidget {
  const _TermsAndConditionsDialog({required this.terms});

  final CurrentTerms terms;

  @override
  Widget build(BuildContext context) {
    final effectiveDate = _formatDate(terms.effectiveUtc.toLocal());

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      terms.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Version ${terms.version}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    'Effective: $effectiveDate',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  primary: true,
                  padding: const EdgeInsets.all(24),
                  child: SelectableText(
                    terms.content.trim(),
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(height: 1.5),
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),

                  const SizedBox(width: 12),

                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('I Agree'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}
