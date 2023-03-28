import 'package:aws_s3/widgets/appBar.dart';
import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:flutter/material.dart';

import 'buckets_data.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
    required this.listBucketsTransfer,
    required this.accessKey,
    required this.secretKey,
    required this.region,
    required this.isLeading,
  }) : super(key: key);
  ListBucketsOutput listBucketsTransfer;
  String accessKey;
  String secretKey;
  String region;
  bool isLeading;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedRegion = '';
  bool loading = false;

  final _formKey = GlobalKey<FormState>();
  ListBucketsOutput? listBuckets;
  void initState() {
    listBuckets = widget.listBucketsTransfer;
    super.initState();
  }

  // Define a TextEditingController to get the value of the input field
  final bucketNameController = TextEditingController();

  FormFieldValidator<String> _bucketNameValidator = (value) {
    if (value == null || value.isEmpty) {
      return 'Bucket name is required';
    }
    if (value.length < 3 || value.length > 63) {
      return 'Bucket name must be between 3 and 63 characters long';
    }
    if (!RegExp(r'^[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?$').hasMatch(value)) {
      return 'Bucket name can only contain lower-case characters, numbers, periods, and dashes';
    }
    if (value.startsWith('.') || value.endsWith('.') || value.contains('..')) {
      return 'Bucket name cannot have consecutive periods or start/end with a period';
    }
    if (value.contains('_') || value.endsWith('-') || value.contains('-.')) {
      return 'Bucket name cannot contain underscores, end with a dash, or use dashes adjacent to periods';
    }
    return null;
  };
  dialogShow(String bodyText, {bool? delete, String? bucketsName}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            height: 170,
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
                      var deleteResp = await deleteBuckets(bucketsName ?? "");
                      if (deleteResp == "true") {
                        await gettData(widget.accessKey, widget.secretKey,
                            _selectedRegion);
                        setState(() {
                          loading = false;
                        });
                        dialogShow("Bucket Successfully Delete!");
                      }
                      if (deleteResp == "notEmpty") {
                        setState(() {
                          loading = false;
                        });
                        dialogShow(
                            "The bucket you tried to delete is not empty!");
                      }
                      if (deleteResp == "false") {
                        setState(() {
                          loading = false;
                        });
                        dialogShow("Something Error!");
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

  String bucketsRegion = "us-west-1";
  deleteBuckets(String bucketName) async {
    final credentials = AwsClientCredentials(
      accessKey: widget.accessKey,
      secretKey: widget.secretKey,
    );

    final service = S3(region: bucketsRegion, credentials: credentials);
    try {
      // var deleteVal = await service.deleteBucket(bucket: bucketName);
      var val = await service.getBucketLocation(bucket: bucketName);
      print("val--> ${val.locationConstraint!.name}");
      if (val.locationConstraint!.name.toString() == "usEast_2") {
        final service1 = S3(region: "us-east-2", credentials: credentials);
        // bucketsRegion = "us-east-2";
        var deleteVal = await service1.deleteBucket(bucket: bucketName);
        // setState(() {
        //   bucketsRegion = "us-east-2";
        // });
      } else if (val.locationConstraint!.name.toString() == "usWest_1") {
        final service1 = S3(region: "us-west-1", credentials: credentials);
        var deleteVal = await service1.deleteBucket(bucket: bucketName);
        // setState(() {
        //   bucketsRegion = "us-west-1";
        // });
      } else if (val.locationConstraint!.name.toString() == "usWest_2") {
        // bucketsRegion = "us-west-2";
        final service1 = S3(region: "us-west-2", credentials: credentials);
        var deleteVal = await service1.deleteBucket(bucket: bucketName);
        // setState(() {
        //   bucketsRegion = "us-west-2";
        // });
      } else if (val.locationConstraint!.name.toString() == "caCentral_1") {
        bucketsRegion = "ca-central-1";
        final service1 = S3(region: "ca-central-1", credentials: credentials);
        var deleteVal = await service1.deleteBucket(bucket: bucketName);
        // setState(() {
        //   bucketsRegion = "ca-central-1";
        // });
      }

      return "true";
    } catch (e) {
      print("--->   $e");
      if (e.toString() ==
          "Exception:  is not known in enum BucketLocationConstraint") {
        final service1 = S3(region: "us-east-1", credentials: credentials);
        var deleteVal = await service1.deleteBucket(bucket: bucketName);
        return "true";
      }
      if (e.toString() ==
          "BucketNotEmpty null: The bucket you tried to delete is not empty") {
        return "notEmpty";
      } else {
        return "false";
      }
    }
  }

  // dialogShow(String bodyText, {bool? delete, String? bucketName}) async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Container(
  //           height: 170,
  //           width: 250,
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               // Image.asset(
  //               //   "assets/images/success_icon.png",
  //               //   scale: 3,
  //               // ),
  //               const SizedBox(
  //                 height: 20,
  //               ),
  //               Text(
  //                 "$bodyText",
  //                 textAlign: TextAlign.center,
  //               ),
  //               const SizedBox(
  //                 height: 20,
  //               ),
  //               InkWell(
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Container(
  //                   height: 50,
  //                   width: 80,
  //                   // margin: EdgeInsets.only(right: 30),
  //                   decoration: BoxDecoration(
  //                     color: Theme.of(context).colorScheme.primary,
  //                     borderRadius: const BorderRadius.all(
  //                       Radius.circular(10),
  //                     ),
  //                   ),
  //                   child: const Center(
  //                     child: Text(
  //                       "OK",
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

// Create a function to show the dialog
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: _formKey,
          child: AlertDialog(
            title: Text('Enter bucket name'),
            content: Container(
              height: 170,
              child: Column(
                children: [
                  TextFormField(
                    controller: bucketNameController,
                    decoration: const InputDecoration(
                      hintText: 'Bucket name',
                    ),
                    validator: _bucketNameValidator,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Region',
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(32.0),
                      // ),
                    ),
                    // value: _selectedRegion,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRegion = newValue!;
                      });
                    },
                    items: <String>[
                      'us-west-1',
                      'us-west-2',
                      'us-east-2',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a region';
                      }
                      return null;
                    },
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
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      loading = true;
                    });
                    Navigator.of(context).pop();
                    var resp = await createBucket(
                        bucketNameController.text, _selectedRegion);
                    print("resp--> $resp");
                    if (resp == "true") {
                      setState(() {
                        loading = false;
                      });
                      dialogShow("Bucket Successfully Created !");
                      // setState(() {
                      gettData(
                          widget.accessKey, widget.secretKey, _selectedRegion);
                      // });
                    }
                    if (resp == "false") {
                      dialogShow(
                          "Invalid Bucket Name or Bucket already available !");
                      setState(() {
                        loading = false;
                      });
                    }
                  }

                  // Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  gettData(String accessKey, String secretKey, String selectedRegion) async {
    final credentials =
        AwsClientCredentials(accessKey: accessKey, secretKey: secretKey);

    final service = S3(region: selectedRegion, credentials: credentials);

    try {
      listBuckets = await service.listBuckets();
      print("listBuckets!.buckets![0] ${listBuckets!.buckets![0]}");
      listBuckets!.buckets!.forEach((element) {
        print("listBuckets--> ${element.name}");
      });
      setState(() {});
      return "true";
    } catch (e) {
      print("--->   $e");
      return "false";
    }
  }

  createBucket(String bucketName, String selectedRegion) async {
    print("${widget.accessKey}  ${widget.secretKey}   ${widget.region}");
    final credentials = AwsClientCredentials(
      accessKey: widget.accessKey,
      secretKey: widget.secretKey,
    );

    final service = S3(region: selectedRegion, credentials: credentials);

    try {
      var response = await service.createBucket(
        bucket: bucketName,
        createBucketConfiguration: CreateBucketConfiguration(
          locationConstraint: selectedRegion == "us-west-1"
              ? BucketLocationConstraint.usWest_1
              : selectedRegion == "us-west-2"
                  ? BucketLocationConstraint.usWest_2
                  : selectedRegion == "us-east-2"
                      ? BucketLocationConstraint.usEast_2
                      : BucketLocationConstraint.usWest_1,
        ),
      );
      print("response--> ${response}");
      // listBuckets!.buckets!.forEach((element) {
      //   print("listBuckets--> ${element.name}");
      // });
      return "true";
    } catch (e) {
      print("--->   $e");
      return "false";
    }
  }

  // getBucketLocation() async {
  //   final credentials = AwsClientCredentials(
  //     accessKey: widget.accessKey,
  //     secretKey: widget.secretKey,
  //   );
  //   final service = S3(region: "us-east-1", credentials: credentials);
  //   var data = await service.getBucketLocation(
  //     bucket: "ActionBackupServices",
  //   );
  //   print("datacdshikcd--> $data");
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: MyAppBar.getAppBar(
        context,
        isLeading: widget.isLeading,
      ),
      // appBar: AppBar(
      //   title: const Text(
      //     'Buckets Page',
      //   ),
      //   centerTitle: true,
      //   backgroundColor: Color(0xff77eddd),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(right: 40.0),
      //       child: GestureDetector(
      //         onTap: () {
      //           _showSettingDialog(context);
      //         },
      //         child: const Icon(
      //           Icons.settings,
      //           size: 35,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      body: Stack(
        children: [
          ListView(
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
                      width:
                          (size.width - (size.width / 10) - (size.width / 10)) /
                              2,
                      child: const Text(
                        "Buckets Name",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.05),
                      ),
                    ),
                    Container(
                      width:
                          (size.width - (size.width / 10) - (size.width / 10)) /
                              2,
                      child: const Text(
                        "Creation Date",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.05),
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
                listBuckets!.buckets!.length,
                (index) => GestureDetector(
                  onTap: () async {
                    // getBucketLocation();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BucketsData(
                          secretKey: widget.secretKey,
                          accessKey: widget.accessKey,
                          bucketsData: listBuckets!.buckets![index],
                        ),
                      ),
                    );
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
                              "${index + 1}.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.05),
                            ),
                          ),
                          Container(
                            width: (size.width -
                                    (size.width / 10) -
                                    (size.width / 10)) /
                                2,
                            child: Text(
                              listBuckets!.buckets![index].name ?? "",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.05),
                            ),
                          ),
                          Container(
                            width: (size.width -
                                        (size.width / 10) -
                                        (size.width / 10)) /
                                    2 -
                                8,
                            child: Text(
                              "${listBuckets!.buckets![index].creationDate}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.05),
                            ),
                          ),
                          Container(
                            width: size.width / 10,
                            child: GestureDetector(
                              onTap: () {
                                dialogShow(
                                  "Please Confirm ?",
                                  delete: true,
                                  bucketsName:
                                      listBuckets!.buckets![index].name,
                                );
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
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
            ],
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog(context);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
