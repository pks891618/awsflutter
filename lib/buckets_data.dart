import 'dart:io';
import 'dart:typed_data';

import 'package:aws_s3/widgets/appBar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:aws_s3_api/s3-2006-03-01.dart';
// import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BucketsData extends StatefulWidget {
  BucketsData({
    Key? key,
    required this.accessKey,
    required this.secretKey,
    required this.bucketsData,
  }) : super(key: key);

  String accessKey;
  String secretKey;
  Bucket bucketsData;

  @override
  State<BucketsData> createState() => _BucketsDataState();
}

class _BucketsDataState extends State<BucketsData> {
  ListObjectsV2Output? bucketResponse;

  ListObjectsV2Output? bucketResponseV2;
  bool loading = false;
  bool uploading = false;
  bool downloading = false;
  String bucketsRegion = "us-west-1";
  int objectPage = 0;
  bool isTruncated = false;

  void initState() {
    super.initState();
    getObjectList();
  }

  getObjectList({String? key, String? startAfter}) async {
    final credentials = AwsClientCredentials(
      accessKey: widget.accessKey,
      secretKey: widget.secretKey,
    );

    final service = S3(region: bucketsRegion, credentials: credentials);
    final service2 = S3(region: bucketsRegion, credentials: credentials);
    try {
      // print("bucketsData ${widget.bucketsData.creationDate}");
      setState(() {
        loading = true;
      });
      var val =
          await service.getBucketLocation(bucket: "${widget.bucketsData.name}");
      print("val--> ${val.locationConstraint!.name}");
      print("--if-------key $key");
      if (val.locationConstraint!.name.toString() == "usEast_2") {
        final service1 = S3(region: "us-east-2", credentials: credentials);
        // bucketsRegion = "us-east-2";
        bucketResponse = await service1.listObjectsV2(
          continuationToken: key,
          bucket: "${widget.bucketsData.name}",
          maxKeys: 10,
        );
        setState(() {
          bucketsRegion = "us-east-2";
          loading = false;
          isTruncated = bucketResponse!.isTruncated!;
        });
      } else if (val.locationConstraint!.name.toString() == "usWest_1") {
        final service1 = S3(region: "us-west-1", credentials: credentials);
        bucketResponse = await service1.listObjectsV2(
          continuationToken: key,
          bucket: "${widget.bucketsData.name}",
          // startAfter: null,
          maxKeys: 10,
        );
        setState(() {
          bucketsRegion = "us-west-1";
          loading = false;
          isTruncated = bucketResponse!.isTruncated!;
        });
        print("isTruncated ${bucketResponse!.isTruncated}");
      } else if (val.locationConstraint!.name.toString() == "usWest_2") {
        // bucketsRegion = "us-west-2";
        final service1 = S3(region: "us-west-2", credentials: credentials);
        bucketResponse = await service1.listObjectsV2(
          continuationToken: key,
          bucket: "${widget.bucketsData.name}",
          // startAfter: key,
          maxKeys: 10,
        );
        setState(() {
          bucketsRegion = "us-west-2";
          loading = false;
          isTruncated = bucketResponse!.isTruncated!;
        });
      } else if (val.locationConstraint!.name.toString() == "caCentral_1") {
        bucketsRegion = "ca-central-1";
        final service1 = S3(region: "ca-central-1", credentials: credentials);
        bucketResponse = await service1.listObjectsV2(
          continuationToken: key,
          bucket: "${widget.bucketsData.name}",
          // startAfter: key,
          maxKeys: 10,
        );
        setState(() {
          bucketsRegion = "ca-central-1";
          loading = false;
          isTruncated = bucketResponse!.isTruncated!;
        });
      }

      // setState(() {});
      // bucketResponseV2 = await service.listObjectsV2(
      //   bucket: "${widget.bucketsData.name}",
      //   prefix: 'MBS-bb4a582a-89ba-4d00-ae28-90bfaf44d253/',
      //   delimiter: '/',
      //   // delimiter: '/',
      //   // prefix:
      //   //     'MBS-bb4a582a-89ba-4d00-ae28-90bfaf44d253/CBB_MIKE-PC/C:/Users/Mike/Contacts',

      //   // maxKeys: 10,
      // );
      // var data = await service.getBucketLocation(bucket: "${bucketsData.name}",);

      print("bucketResponse--> ${bucketResponse!.contents![0].key}");
      // print("owner--> ${data.locationConstraint}");

      return "true";
    } catch (e) {
      print("--====>tt>   $e");
      if (e.toString() ==
          "Exception:  is not known in enum BucketLocationConstraint") {
        // bucketsRegion = "us-east-1";
        print("---key $key");
        print("---startAfter $startAfter");
        // setState(() {
        //   loading = true;
        // });
        final service2 = S3(region: "us-east-1", credentials: credentials);
        bucketResponse = await service2.listObjectsV2(
          bucket: "${widget.bucketsData.name}",
          maxKeys: 10,
          continuationToken: key,
          startAfter: startAfter,
          fetchOwner: false,
        );
        setState(() {
          bucketsRegion = "us-east-1";
          loading = false;
          isTruncated = bucketResponse!.isTruncated!;
        });

        // print("bucketResponse!.prefix ===>> ${bucketResponse!}");
      }

      return "false";
    }
  }

  deleteObjects(String keyName) async {
    final credentials = AwsClientCredentials(
      accessKey: widget.accessKey,
      secretKey: widget.secretKey,
    );

    final service = S3(region: bucketsRegion, credentials: credentials);
    try {
      var val = await service.deleteObject(
        bucket: "${widget.bucketsData.name}",
        key: "$keyName",
      );
      // var data = await service.getBucketLocation(bucket: "${bucketsData.name}",);

      print("bucketResponse--> ${val}");
      // print("owner--> ${data.locationConstraint}");

      return "true";
    } catch (e) {
      print("--->   $e");

      return "false";
    }
  }

  downloadFileFromS3(String bucket, String key) async {
    // print("bucket $bucket");
    // print("bucketsRegion $bucketsRegion");
    // print("key $key");
    // print("widget.accessKey--> ${widget.accessKey}");
    // print("widget.secretKey--> ${widget.secretKey}");
    final credentials = AwsClientCredentials(
      accessKey: widget.accessKey,
      secretKey: widget.secretKey,
    );

    final service = S3(region: bucketsRegion, credentials: credentials);
    try {
      setState(() {
        downloading = true;
      });
      final getObjectResponse = await service.getObject(
        bucket: bucket,
        key: key,
      );
      await functionOccur(getObjectResponse.body);
      setState(() {
        downloading = false;
      });
      print("getObjectResponse--->? ${getObjectResponse.contentType}");
      return "true";
    } catch (e) {
      print("------>+ $e");
      setState(() {
        downloading = false;
      });
      return "false";
    }
  }

  createFolder(String bucket, String key) async {
    final credentials = AwsClientCredentials(
      accessKey: widget.accessKey,
      secretKey: widget.secretKey,
    );

    final service = S3(region: bucketsRegion, credentials: credentials);

    try {
      final putObjectResponse =
          await service.putObject(bucket: bucket, key: "${key}/");
      getObjectList();
      setState(() {});
      print("getObjectResponse22-->? ${putObjectResponse}");
      return "true";
    } catch (e) {
      print("createFolder--> $e");
      return "false";
    }
  }

  final folderNameController = TextEditingController();
  FormFieldValidator<String> _folderNameValidator = (value) {
    if (value == null || value.isEmpty) {
      return 'Folder name is required';
    }
    if (value.length < 3 || value.length > 63) {
      return 'Folder name must be between 3 and 63 characters long';
    }
    if (!RegExp(r'^[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?$').hasMatch(value)) {
      return 'Folder name can only contain lower-case characters, numbers, periods, and dashes';
    }
    if (value.startsWith('.') || value.endsWith('.') || value.contains('..')) {
      return 'Folder name cannot have consecutive periods or start/end with a period';
    }
    if (value.contains('_') || value.endsWith('-') || value.contains('-.')) {
      return 'Folder name cannot contain underscores, end with a dash, or use dashes adjacent to periods';
    }
    return null;
  };

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          // key: _formKey,
          child: AlertDialog(
            title: Text('Enter bucket name'),
            content: Container(
              height: 170,
              child: Column(
                children: [
                  TextFormField(
                    controller: folderNameController,
                    decoration: InputDecoration(hintText: 'Folder Name'),
                    validator: _folderNameValidator,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Save'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    loading = true;
                  });
                  var createResp = await createFolder(
                      widget.bucketsData.name ?? "",
                      folderNameController.text ?? "");
                  folderNameController.clear();

                  if (createResp == "true") {
                    setState(() {
                      loading = false;
                    });
                    dialogShow("Folder Successfully Created !");
                  }
                  if (createResp == "false") {
                    dialogShow(
                        "Invalid folder Name or folder already available !");
                    setState(() {
                      loading = false;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  dialogShow(String bodyText, {bool? delete, String? key, bool? error}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            height: error == true ? 250 : 170,
            width: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image.asset(
                //   "assets/images/success_icon.png",
                //   scale: 3,
                // ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "$bodyText",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);

                    if (delete == true) {
                      setState(() {
                        loading = true;
                      });
                      var deleteResp = await deleteObjects(key ?? "");
                      if (deleteResp == "true") {
                        await getObjectList();
                        setState(() {
                          loading = false;
                        });
                        dialogShow("Folder Successfully Delete !");
                      }
                      if (deleteResp == "false") {
                        setState(() {
                          loading = false;
                        });
                        dialogShow("Something Error !");
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 80,
                    // margin: EdgeInsets.only(right: 30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${delete == true ? "Delete" : "Ok"}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  chooseFile(String? name, String key) async {
    print("chooseFile-->");
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    print("result--> $result");
    if (result != null) {
      File file = await File(result.files.single.path ?? "");
      print("file---> ${file}");
      setState(() {
        uploading = true;
      });
      var dataResp =
          await uploadFile(name ?? "", key, file, result.files.single.name);
      if (dataResp == "true") {
        await getObjectList();
        setState(() {
          uploading = false;
        });
        dialogShow("File Uploaded Successfully");
      }
      //  if()
    } else {
      // User canceled the picker
    }
  }

  uploadFile(String bucket, String key, File file, String name) async {
    final credentials = AwsClientCredentials(
      accessKey: widget.accessKey,
      secretKey: widget.secretKey,
    );

    final service = S3(region: bucketsRegion, credentials: credentials);
    // String fileName = file.path;

    try {
      final putObjectResponse = await service.putObject(
        bucket: bucket,
        key: "${key}/$name",
        body: file.readAsBytesSync(),
      );
      // final data = await FileSaver.instance
      // .saveFile("mg5", file.readAsBytesSync(), ".png");
      // functionOccur(file);

      print("getObjectResponse22-->? ${putObjectResponse}");
      return "true";
    } catch (e) {
      print("uploadFile error--> $e");
      return "false";
    }
  }

  Future<void> functionOccur(Uint8List? body) async {
    final date =
        "aws_file_${DateFormat("yyyyMMdd'T'HHmmss").format(DateTime.now())}";
    print("data--> $date");

    final prefs = await SharedPreferences.getInstance();
    final getPath = await prefs.getString("downloadPath");
    final result1 = List<int>.from(body!);
    print("getPath--->  $getPath");
    if (getPath != null) {
      final file = File("${getPath}/${date}");
      await file.writeAsBytes(result1);
    } else {
      final documentsDir = await getDownloadsDirectory();
      final file = File("${documentsDir!.path}/${date}");
      await file.writeAsBytes(result1);
    }

    // var result = await FilePicker.platform.getDirectoryPath();
    // print("result->>>> $result");
    // final documentsDir = await getDownloadsDirectory();
    // final file = File("${result}/${date}");
    // final file = File("/Users/vqcodes/Documents/${date}");

    // await file.writeAsBytes(result1);
    // String appDocPath = appDocDir.path;
    // documentsDir.
    // print("tempDir---> $documentsDir");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // functionOccur();
    return Scaffold(
      appBar: MyAppBar.getAppBar(
        context,
        title: '${widget.bucketsData.name}',
        isLeading: true,
      ),
      // appBar: AppBar(
      //   title: Text('${widget.bucketsData.name}'),
      //   backgroundColor: Color(0xff77eddd),
      //   centerTitle: true,
      //   actions: const [
      //     Padding(
      //       padding: EdgeInsets.only(right: 40.0),
      //       child: Icon(
      //         Icons.settings,
      //         size: 35,
      //       ),
      //     ),
      //   ],
      // ),
      body: Stack(
        children: [
          FutureBuilder(
            // future: getObjectList(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (bucketResponse == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (bucketResponse!.contents!.length == 0) {
                return const Center(
                  child: Text(
                    "Data Not Found !",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return ListView(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // padding: EdgeInsets.only(left: 20),
                          width: size.width / 10,
                          child: const Text(
                            "Sr. no",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.05),
                          ),
                        ),
                        Container(
                          width: (size.width -
                                  (size.width / 10) -
                                  (size.width / 10)) /
                              2,
                          child: const Text(
                            "Path",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.05),
                          ),
                        ),
                        Container(
                          width: (size.width -
                                  (size.width / 10) -
                                  (size.width / 10)) /
                              2,
                          child: const Text(
                            "Last Modified",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.05,
                            ),
                          ),
                        ),
                        Container(
                          width: size.width / 10,
                          child: const Text(
                            "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ...List.generate(
                    bucketResponse!.contents!.length,
                    (index) => GestureDetector(
                      onTap: () async {
                        // getBucketLocation();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => BucketsData(
                        //       secretKey: widget.secretKey,
                        //       accessKey: widget.accessKey,
                        //       bucketsData: bucketResponse!.contents![index],
                        //     ),
                        //   ),
                        // );
                      },
                      child: Card(
                        elevation: 5,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                // padding: EdgeInsets.only(left: 20),
                                width: size.width / 10,
                                child: Text(
                                  "${(objectPage * 10) + index + 1}.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.05,
                                  ),
                                ),
                              ),
                              Container(
                                width: (size.width -
                                        (size.width / 10) -
                                        (size.width / 10)) /
                                    2,
                                child: Text(
                                  bucketResponse!.contents![index].key ?? "",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.05,
                                  ),
                                ),
                              ),
                              Container(
                                width: (size.width -
                                            (size.width / 10) -
                                            (size.width / 10)) /
                                        2 -
                                    8,
                                child: Text(
                                  "${bucketResponse!.contents![index].lastModified}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.05,
                                  ),
                                ),
                              ),
                              Container(
                                width: (size.width / 10),
                                child: GestureDetector(
                                  onTap: () {
                                    // deleteObjects(
                                    //     bucketResponse!.contents![index].key ?? "");
                                  },
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          var downloadResp =
                                              await downloadFileFromS3(
                                                  widget.bucketsData.name ?? "",
                                                  bucketResponse!
                                                          .contents![index]
                                                          .key ??
                                                      "");

                                          if (downloadResp == "true") {
                                            dialogShow(
                                                "Successfully Downloaded!");
                                          } else {
                                            dialogShow(
                                                "This object is stored in the Glacier Flexible Retrieval (formerly Glacier) storage class.So you have to first Restore.",
                                                error: true);
                                          }
                                        },
                                        child: const Icon(
                                          Icons.download,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          dialogShow("Please Confirm ?",
                                              delete: true,
                                              key: bucketResponse!
                                                      .contents![index].key ??
                                                  "");
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //  ListTile(
                        //   title: Text(
                        //     listBuckets!.buckets![index].name ?? "",
                        //     style: TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.w500,
                        //         letterSpacing: 1.05),
                        //   ),
                        // ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: objectPage > 0
                              ? () async {
                                  await getObjectList(
                                      key: bucketResponse!
                                              .nextContinuationToken ??
                                          "",
                                      startAfter:
                                          bucketResponse!.contents!.first.key);
                                  setState(() {
                                    objectPage -= 1;
                                  });
                                }
                              : null,
                          child: const Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios,
                              ),
                              Text(
                                "Previous",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: isTruncated == true
                              ? () async {
                                  await getObjectList(
                                    key:
                                        bucketResponse!.nextContinuationToken ??
                                            "",
                                  );
                                  setState(() {
                                    objectPage += 1;
                                  });
                                }
                              : null,
                          child: const Row(
                            children: [
                              Text(
                                "Next",
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.arrow_forward_ios)
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          ),
          if (loading == true)
            Container(
              height: size.height,
              width: size.width,
              color: Colors.grey.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              ),
            ),
          if (uploading == true)
            Container(
              height: size.height,
              width: size.width,
              color: Colors.grey.withOpacity(0.4),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.green,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "File Uploading !",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (downloading == true)
            Container(
              height: size.height,
              width: size.width,
              color: Colors.grey.withOpacity(0.4),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.green,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "File Downloading !",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: Container(
        // height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {
                chooseFile(widget.bucketsData.name, "public");
                //
              },
              tooltip: 'Add File',
              child: const Icon(Icons.file_copy),
            ),
            const SizedBox(
              height: 20,
            ),
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () {
                _showDialog(context);
              },
              tooltip: 'Create Folder',
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
