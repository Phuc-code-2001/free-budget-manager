import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {

  final List<Category> categories;
  final SharedPreferences prefs;

  const CategoryScreen({
    required this.categories,
    required this.prefs,
    Key? key,
  }) : super(key: key);

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends State<CategoryScreen> {

  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    categories = widget.categories;
  }

  @override
  void dispose() {
    super.dispose();
    saveCategories();
  }

  void saveCategories() {
    List<String> categoryStrings = categories.map((category) {
      return json.encode(category.toJson());
    }).toList();
    widget.prefs.setStringList('categories', categoryStrings);
  }

  void addCategoryDialog() {

    // Hiển thị hộp thoại để nhập thông tin danh mục mới
    showDialog(
      context: context,
      builder: (BuildContext context) {

        TextEditingController nameController = TextEditingController();
        TextEditingController iconController = TextEditingController();
    
        return StatefulBuilder(
          builder: (context, setState) {
            
            return AlertDialog(
              title: const Text('Add Category'),
              content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: iconController,
                  decoration: const InputDecoration(
                    labelText: 'Icon',
                  ),
                ),
              ],
            ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {

                    Category newCategory = Category(
                      name: nameController.text,
                      iconText: iconController.text,
                    );

                    if(categories.contains(newCategory)) {
                      showDialog(context: context, builder: (context) => AlertDialog(
                        title: const Text("Invalid data!"),
                        iconColor: Colors.red,
                        titleTextStyle: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 22,
                        ),
                        icon: const Icon(Icons.error),
                        content: Text("Category with name '${newCategory.name}' already exist."),
                      ));
                    }
                    else {
                      setState(() {
                        categories.add(newCategory);
                      });
            
                      Navigator.of(context).pop();
                    }
                  },
                ),
            ],
            );
          }
        );
      },
    )
    .then((_) {
      setState(() {}); // Cập nhật lại widget khi trở lại từ dialog
    });
  }

  void showEditDialog(Category category) {

    showDialog(
      context: context,
      builder: (BuildContext context) {

        TextEditingController nameController = TextEditingController();
        TextEditingController iconController = TextEditingController();
        nameController.text = category.name;
        iconController.text = category.iconText;
    
        return StatefulBuilder(

          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Category'),
              content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: iconController,
                  decoration: const InputDecoration(
                    labelText: 'Icon',
                  ),
                ),
              ],
            ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    
                    category.name = nameController.text;
                    category.iconText = iconController.text;

                    Navigator.of(context).pop();
                  },
                ),
            ],
            );
          }
        );
      },
    )
    .then((_) {
      setState(() {});
    });
  }

  void showDeleteDialog(Category category) {
    // Hiển thị hộp thoại xác nhận xóa danh mục
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa danh mục'),
        content: const Text('Bạn có chắc chắn muốn xóa danh mục này?'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Xóa'),
            onPressed: () {
              // Xóa danh mục và cập nhật giao diện
              deleteCategory(category);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void deleteCategory(Category category) {
    setState(() {
      categories.remove(category);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
      
            final category = categories[index];
      
            return Card(
              color: Colors.lightBlueAccent,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(category.iconText),
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Ink(
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4))
                        ),
                        color: Colors.white
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 2.0, right: 8.0, bottom: 2.0),
                        child: Text(
                          category.name, 
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          )
                        ),
                      ),
                    )
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Ink(
                      decoration: const ShapeDecoration(
                        shape: CircleBorder(),
                        color: Colors.white,
                      ),
                      child: IconButton.filled(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // show dialog chỉnh sửa danh mục
                          showEditDialog(category);
                        },
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Ink(
                      decoration: const ShapeDecoration(
                        shape: CircleBorder(),
                        color: Colors.white,
                      ),
                      child: IconButton.filled(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDeleteDialog(category);
                        },
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addCategoryDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
