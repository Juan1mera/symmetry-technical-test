import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/core/widgets/custom_button.dart';
import 'package:news_app_clean_architecture/core/widgets/custom_text_area.dart';
import 'package:news_app_clean_architecture/core/widgets/custom_text_field.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class CreateArticleScreen extends StatefulWidget {
  const CreateArticleScreen({Key? key}) : super(key: key);

  @override
  State<CreateArticleScreen> createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController(); 
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<CreateArticleCubit>().submitArticle(
        title: _titleController.text,
        content: _contentController.text,
        category: _categoryController.text.isEmpty ? 'General' : _categoryController.text,
        imagePath: _imagePath,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateArticleCubit>(),
      child: BlocListener<CreateArticleCubit, CreateArticleState>(
        listener: (context, state) {
          if (state is CreateArticleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('¡Artículo publicado exitosamente!'),
                backgroundColor: AppColors.secundario,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            Navigator.pop(context);
          } else if (state is CreateArticleError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.principal,
          appBar: AppBar(
            title: const Text('Publicar Artículo'),
            backgroundColor: AppColors.principal,
          ),
          body: BlocBuilder<CreateArticleCubit, CreateArticleState>(
            builder: (context, state) {
              final isLoading = state is CreateArticleLoading;
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Icon
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.secundario.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_note,
                            size: 48,
                            color: AppColors.secundario,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Center(
                        child: Text(
                          'Crear Nuevo Artículo',
                          style: TextStyle(
                            fontFamily: 'Butler',
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textoPrincipal,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      CustomTextField(
                        controller: _titleController,
                        labelText: 'Título',
                        hintText: 'Escribe el título de tu artículo...',
                        prefixIcon: Icons.title,
                        enabled: !isLoading,
                        validator: (value) => value == null || value.isEmpty 
                            ? 'El título es requerido' 
                            : null,
                      ),

                      const SizedBox(height: 16),
                      
                      // Category
                      CustomTextField(
                        controller: _categoryController,
                        labelText: 'Categoría',
                        hintText: 'Tecnología, Deportes, etc. (Opcional)',
                        prefixIcon: Icons.category_outlined,
                        enabled: !isLoading,
                      ),

                      const SizedBox(height: 24),

                      // Image Section
                      const Text(
                        'Imagen del artículo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textoPrincipal,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Attach Image Button
                      CustomButton(
                        text: _imagePath == null 
                            ? 'Seleccionar Imagen' 
                            : 'Cambiar Imagen',
                        onPressed: isLoading ? null : _pickImage,
                        type: CustomButtonType.outline,
                        leadingIcon: Icons.image_outlined,
                        width: double.infinity,
                        height: 50,
                      ),

                      const SizedBox(height: 16),
                      
                      // Image Preview
                      if (_imagePath != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(_imagePath!),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _imagePath = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),

                      // Content
                      const Text(
                        'Contenido',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textoPrincipal,
                        ),
                      ),

                      const SizedBox(height: 12),

                      CustomTextArea(
                        controller: _contentController,
                        hintText: 'Escribe el contenido de tu artículo aquí...',
                        minLines: 8,
                        maxLines: 15,
                        enabled: !isLoading,
                        validator: (value) => value == null || value.isEmpty 
                            ? 'El contenido es requerido' 
                            : null,
                      ),

                      const SizedBox(height: 32),
                      
                      // Publish Button
                      CustomButton(
                        text: 'Publicar Artículo',
                        onPressed: () => _submit(context),
                        width: double.infinity,
                        isLoading: isLoading,
                        trailingIcon: Icons.send,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
