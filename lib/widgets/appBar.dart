import 'dart:ffi';

import 'package:aws_s3/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar {
  static getAppBar(BuildContext context, {String? title, bool? isLeading}) {
    void _showSettingDialog(BuildContext context, String? getPath) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Settings'),
              content: Container(
                height: 170,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        "Downloads",
                      ),
                      subtitle: Text(
                        "$getPath",
                      ),
                      trailing: TextButton(
                        child: const Text("Select"),
                        onPressed: () async {
                          var pathResult =
                              await FilePicker.platform.getDirectoryPath();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                              "downloadPath", pathResult ?? "");
                          setState(() {
                            getPath = pathResult!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.clear();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: const ListTile(
                        title: Row(
                          children: [
                            Icon(Icons.logout),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Logout"),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
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
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        },
      );
    }

    return AppBar(
      title: Text(
        title == null ? 'Buckets Page' : '$title',
      ),
      automaticallyImplyLeading: isLeading ?? true,
      centerTitle: true,
      backgroundColor: Color(0xff77eddd),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 40.0),
          child: GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final getPath = await prefs.getString("downloadPath");
              print("getPath--->  $getPath");
              if (getPath != null) {
                _showSettingDialog(context, getPath);
              } else {
                final documentsDir = await getDownloadsDirectory();
                _showSettingDialog(
                  context,
                  "${documentsDir!.path}",
                );
              }
            },
            child: const Icon(
              Icons.settings,
              size: 35,
            ),
          ),
        ),
      ],
    );
  }
}
