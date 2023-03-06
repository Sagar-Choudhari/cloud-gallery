import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudgallery/Model/images.dart';
import 'package:cloudgallery/Views/view_image.dart';
import 'package:cloudgallery/providers/cloud_state_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class Cloud extends StatefulWidget {
  const Cloud({Key? key}) : super(key: key);

  @override
  State<Cloud> createState() => _CloudState();
}

class _CloudState extends State<Cloud> {
  late List<Images> images;
  List<String> _selectedImageIds = [];
  List<String> _selectedImageUrls = [];

  List<String> imageIds = [];
  List<String> imageUrls = [];

  final FirebaseStorage storage = FirebaseStorage.instance;

  final FirebaseFirestore fb = FirebaseFirestore.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;
  QuerySnapshot<Map<String, dynamic>>? cachedResult;

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
    );

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        isLoading = true;
        uploadFile();
      } else {
        debugPrint('No image selected from gallery.');
        // showSnack('No image selected from gallery.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 20,
    );

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        isLoading = true;
        uploadFile();
      } else {
        debugPrint('No image clicked from camera.');
        // showSnack('No image clicked from camera.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;

    final fileName = basename(_photo!.path);
    final destination = 'files/$fileName';

    try {
      TaskSnapshot snapshot =
          await storage.ref().child(destination).putFile(_photo!);

      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();

        final images = Images(name: fileName, url: downloadUrl);
        final docUser = FirebaseFirestore.instance.collection('images').doc();
        images.id = docUser.id;
        final json = images.toJson();
        await docUser.set(json);

        /*
        await FirebaseFirestore.instance
            .collection("images")
            .add({"id": id, "url": downloadUrl, "name": fileName});
            */

        setState(() {
          isLoading = false;
        });
        const snackBar = SnackBar(content: Text('Yay! Success'));
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar);
      } else {
        debugPrint('Error from image repo ${snapshot.state.toString()}');
        throw ('This file is not an image');
      }
    } catch (e) {
      debugPrint('error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedImageIds.isEmpty
            ? "Cloud Gallery"
            : "${_selectedImageIds.length} selected"),
        centerTitle: true,
        actions: _selectedImageIds.isNotEmpty
            ? <Widget>[
                PopupMenuButton(
                    // icon: Icon(Icons.book),
                    itemBuilder: (context) {
                  return [
                    PopupMenuItem<int>(
                      value: 0,
                      child: TextButton.icon(
                        onPressed: () {
                          // Select all images
                          setState(() {
                            _selectedImageIds = List.from(imageIds);
                            _selectedImageUrls = List.from(imageUrls);
                          });
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.select_all_rounded,
                          size: 24.0,
                        ),
                        label: const Text('Select All'),
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: TextButton.icon(
                        onPressed: () {
                          // Delete selected images
                          setState(() {
                            imageIds.removeWhere(
                                (id) => _selectedImageIds.contains(id));
                            _selectedImageIds = [];
                            imageUrls.removeWhere(
                                (url) => _selectedImageUrls.contains(url));
                            _selectedImageUrls = [];
                          });
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.deselect_rounded,
                          size: 24.0,
                        ),
                        label: const Text('Deselect All'),
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.download,
                          size: 24.0,
                        ),
                        label: const Text('Download'),
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 3,
                      child: TextButton.icon(
                        onPressed: () {
                          deleteFilesAndDocs(
                              _selectedImageUrls, _selectedImageIds);
                          debugPrint(_selectedImageIds.toString());
                          debugPrint(_selectedImageUrls.toString());
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.delete,
                          size: 24.0,
                        ),
                        label: const Text('Delete'),
                      ),
                    ),
                  ];
                }, onSelected: (value) {
                  if (value == 0) {
                    debugPrint("Select All menu is selected.");
                  } else if (value == 1) {
                    debugPrint("Deselect All menu is selected.");
                  } else if (value == 2) {
                    debugPrint("Download menu is selected.");
                  } else if (value == 3) {
                    debugPrint("Delete menu is selected.");
                  }
                }),
              ]
            : [],
        /*actionsIconTheme: const IconThemeData(
          size: 30.0,
          color: Colors.black,
          opacity: 10.0
      ),*/
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 14,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xffFDCF09),
                child: _photo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.file(
                          _photo!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.fitHeight,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(50)),
                        width: 60,
                        height: 60,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Container(
            padding: const EdgeInsets.all(6.0),
            child: ChangeNotifierProvider<CloudStateProvider>(
              create: (context) => CloudStateProvider(),
              child: Consumer<CloudStateProvider>(
                  builder: (context, provider, child) {
                return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: getImages(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        imageUrls = snapshot.data!.docs
                            .map((doc) => doc.get('url') as String)
                            .toList();
                        imageIds = snapshot.data!.docs
                            .map((doc) => doc.get('id') as String)
                            .toList();
                        return GridView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(0),
                            itemCount: imageIds.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 3.0,
                                    crossAxisSpacing: 3.0),
                            itemBuilder: (BuildContext context, int index) {
                              String id = imageIds[index];
                              bool isSelected = _selectedImageIds.contains(id);
                              return GestureDetector(
                                onTap: () {
                                  String imgName = snapshot.data?.docs[index].data()["name"];
                                  String imgUrl = snapshot.data?.docs[index].data()["url"];
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewImage(imgName, imgUrl)));
                                  debugPrint("$imgName tapped!!!");
                                },
                                onLongPress: () {
                                  String imgId =
                                      snapshot.data?.docs[index].data()["id"];
                                  String imgUrl =
                                      snapshot.data?.docs[index].data()["url"];
                                  // debugPrint("$imgUrl Long pressed!!!");
                                  setState(() {
                                    if (isSelected) {
                                      _selectedImageIds.remove(imgId);
                                      _selectedImageUrls.remove(imgUrl);
                                    } else {
                                      _selectedImageIds.add(imgId);
                                      _selectedImageUrls.add(imgUrl);
                                    }
                                    // debugPrint('${_selectedImageIds.toString()}, ${_selectedImageUrls.toString()}');
                                  });
                                },
                                child: GridTile(
                                  child: Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      textDirection: TextDirection.ltr,
                                      clipBehavior: Clip.hardEdge,
                                      children: <Widget>[
                                        Image.network(
                                            snapshot.data?.docs[index]
                                                .data()["url"],
                                            fit: BoxFit.cover),
                                        Column(
                                          children: [
                                            const Expanded(
                                              child: SizedBox(),
                                            ),
                                            Text(
                                              snapshot.data?.docs[index]
                                                  .data()["name"],
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                backgroundColor: Colors.black54
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (isSelected)
                                          Positioned.fill(
                                            child: Container(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              child: const Icon(
                                                Icons.check,
                                                size: 40,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      } else if (snapshot.connectionState ==
                          ConnectionState.none) {
                        return const Text('Error loading images');
                      } else {
                        return const CircularProgressIndicator();
                      }
                    });
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getImages() {
    return fb.collection("images").get();
  }

  Future<void> deleteFilesAndDocs(List<String> fileUrls, List<String> docIds) async {
    setState(() {
      isLoading = true;
    });
    final storage = FirebaseStorage.instance;
    final firestore = FirebaseFirestore.instance;

    for (String url in fileUrls) {
      final ref = storage.refFromURL(url);
      try {
        await ref.delete();
        debugPrint('File deleted successfully.');
      } catch (e) {
        debugPrint('Error deleting file: $e');
      }
    }

    for (String id in docIds) {
      try {
        await firestore.collection('images').doc(id).delete();
        debugPrint('Document deleted successfully.');
      } catch (e) {
        debugPrint('Error deleting document: $e');
      }
    }
    setState(() {
      isLoading = false;

      imageIds.removeWhere((id) => _selectedImageIds.contains(id));
      _selectedImageIds = [];
      imageUrls.removeWhere((url) => _selectedImageUrls.contains(url));
      _selectedImageUrls = [];
    });
  }
}

