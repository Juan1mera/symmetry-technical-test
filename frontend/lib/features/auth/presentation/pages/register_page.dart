import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../injection_container.dart'; 
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.principal,
        appBar: AppBar(
          title: const Text('Crear Cuenta'),
          backgroundColor: AppColors.principal,
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushReplacementNamed(context, '/'); 
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error?.toString() ?? 'Error al registrarse'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.secundario.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_outlined,
                      size: 60,
                      color: AppColors.secundario,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontFamily: 'Butler',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textoPrincipal,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Regístrate para empezar',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textoSecundario,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // First Name
                  CustomTextField(
                    controller: _firstNameController,
                    labelText: 'Nombre',
                    hintText: 'Tu nombre',
                    prefixIcon: Icons.person_outline,
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Last Name
                  CustomTextField(
                    controller: _lastNameController,
                    labelText: 'Apellido',
                    hintText: 'Tu apellido',
                    prefixIcon: Icons.person_outline,
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Email
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'tu@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Password
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 32),

                  // Register Button
                  CustomButton(
                    text: 'Crear Cuenta',
                    onPressed: () {
                      if (_firstNameController.text.trim().isEmpty ||
                          _lastNameController.text.trim().isEmpty ||
                          _emailController.text.trim().isEmpty ||
                          _passwordController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Por favor completa todos los campos'),
                            backgroundColor: AppColors.secundario,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }
                      context.read<AuthBloc>().add(
                            RegisterEvent(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              firstName: _firstNameController.text.trim(),
                              lastName: _lastNameController.text.trim(),
                            ),
                          );
                    },
                    width: double.infinity,
                    isLoading: isLoading,
                    trailingIcon: Icons.arrow_forward,
                  ),

                  const SizedBox(height: 16),

                  // Login Link
                  CustomButton(
                    text: '¿Ya tienes cuenta? Inicia sesión',
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(context, '/Login');
                          },
                    type: CustomButtonType.outline,
                    width: double.infinity,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
