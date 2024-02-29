// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, non_constant_identifier_names, prefer_interpolation_to_compose_strings, avoid_print

import 'package:email_contact/Notes/control_contact.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class NotesPage extends StatelessWidget {
  final name = TextEditingController();
  final email = TextEditingController();

  final collection = Hive.box('dev_notes');
  ContactController contactController = Get.put(ContactController());

  NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Call refreshData() when the widget is built
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      refreshData();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[100],
        title: const Text("Notes"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          form(context, null);
        },
        foregroundColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 210, 250, 255),
        label: const Text('Add'),
        icon: const Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: contactController.items.length,
          itemBuilder: (context, index) {
            final currentItem = contactController.items[index];
            return Card(
              color: Color.fromARGB(255, 214, 218, 255),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 0.4,
              child: ListTile(
                title: Text(currentItem["name"].toString()),
                subtitle: Text(currentItem["email"].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        form(context, currentItem["key"]);
                      },
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {
                        deleteBackend(context, currentItem["key"]);
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void form(BuildContext context, int? key) {
    if (key != null) {
      final existItem = contactController.items
          .firstWhere((element) => element["key"] == key);
      name.text = existItem["name"];
      email.text = existItem["email"];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            //bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 30,
            left: 15,
            right: 15,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              TextField(
                controller: name,
                decoration: InputDecoration(
                  hintText: "Name",
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: email,
                decoration: InputDecoration(
                  hintText: "Email",
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (key != null) {
                      updateBackend({"name": name.text, "email": email.text},
                          context, key);
                    } else {
                      createBackend({"name": name.text, "email": email.text},
                          context, null);
                    }
                  },
                  child: Text(key == null ? "Create" : "Update")),
            ],
          ),
        );
      },
    );
  }

  Future<void> createBackend(
      Map<String, dynamic> map, BuildContext context, int? key) async {
    await collection.add(map).then((value) {
      Get.snackbar("Created!", "Your contact email saved successful");
      name.text = "";
      email.text = "";
      Navigator.of(context).pop();
      refreshData();
    }).onError((error, stackTrace) {
      Get.snackbar("Failed!", "Saved failed!");
    });
  }

  Future<void> updateBackend(
      Map<String, dynamic> map, BuildContext context, int? key) async {
    await collection.put(key, map).then((value) {
      Get.snackbar("Update!", "Your contact email update successful");
      name.text = "";
      email.text = "";
      Navigator.of(context).pop();
      refreshData();
    }).onError((error, stackTrace) {
      Get.snackbar("Failed!", "Update failed!");
    });
  }

  Future<void> deleteBackend(BuildContext context, int? key) async {
    await collection.delete(key).then((value) {
      Get.snackbar("Delete!", "Your contact email delete successful");
      refreshData();
    }).onError((error, stackTrace) {
      Get.snackbar("Failed!", "Delete failed!");
    });
  }

  void refreshData() {
    final data = collection.keys.map(
      (key) {
        final item = collection.get(key);
        return {"key": key, "name": item["name"], "email": item["email"]};
      },
    ).toList();

    contactController.items.value = data.reversed.toList();
  }
}
