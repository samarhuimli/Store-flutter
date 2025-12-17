import 'package:flutter/material.dart';
import 'package:shop/screens/category/views/components/category_form.dart';
import 'package:shop/services/category_service.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final categories = await CategoryService.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _showForm({String? id, String? name, String? description}) {
    showDialog(
      context: context,
      builder: (_) => CategoryForm(
        id: id,
        initialName: name,
        initialDescription: description,
        onSubmit: (newName, newDesc) async {
          if (id == null) {
            // Ajout
            await CategoryService.addCategory({
              'name': newName,
              'description': newDesc,
            });
          } else {
            // Modification
            await CategoryService.updateCategory(id, {
              'name': newName,
              'description': newDesc,
            });
          }

          fetchCategories();
        },
      ),
    );
  }

  Future<void> deleteCategory(String id) async {
    await CategoryService.deleteCategory(id);
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion des Catégories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(), // Ajouter
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return Card(
              child: ListTile(
                title: Text(category['name']),
                subtitle: Text(category['description'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showForm(
                        id: category['_id'],
                        name: category['name'],
                        description: category['description'],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteCategory(category['_id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
