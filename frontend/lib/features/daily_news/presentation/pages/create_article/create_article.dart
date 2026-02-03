import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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
              const SnackBar(content: Text('Article Published!')),
            );
            Navigator.pop(context);
          } else if (state is CreateArticleError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Publish Article', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: BlocBuilder<CreateArticleCubit, CreateArticleState>(
            builder: (context, state) {
              if (state is CreateArticleLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Write your title here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Category
                      TextFormField(
                         controller: _categoryController,
                         decoration: InputDecoration(
                           hintText: 'Category (Optional)',
                           border: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(12),
                             borderSide: BorderSide.none,
                           ),
                           filled: true,
                           fillColor: Colors.grey[100],
                         ),
                      ),
                      const SizedBox(height: 16),

                      
                      // Attach Image Button
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.purple.shade100),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.purple),
                              SizedBox(width: 8),
                              Text('Attach Image', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Image Preview
                      if (_imagePath != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(_imagePath!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                       const SizedBox(height: 16),

                      // Content
                       TextFormField(
                        controller: _contentController,
                        maxLines: 10,
                        decoration: InputDecoration(
                          hintText: 'Add article here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Content is required' : null,
                      ),
                      const SizedBox(height: 30),
                      
                      // Publish Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => _submit(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Publish Article', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8), 
                              Icon(Icons.arrow_forward, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
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
