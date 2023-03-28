import 'package:aws_s3/home_page.dart';
import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await storedData();
  runApp(MyApp());
}

String? accessKey;
String? serviceKey;
String? selectedRegion;
ListBucketsOutput? listBuckets;

storedData() async {
  final prefs = await SharedPreferences.getInstance();
  accessKey = await prefs.getString("accessKey");
  serviceKey = await prefs.getString("serviceKey");
  selectedRegion = await prefs.getString("selectedRegion");
  accessKey == null && serviceKey == null && selectedRegion == null
      ? null
      : await gettData(accessKey ?? "", serviceKey ?? "", selectedRegion ?? "");
  print("accessKey---> $accessKey");
}

gettData(String accessKey, String secretKey, String selectedRegion) async {
  final credentials =
      AwsClientCredentials(accessKey: accessKey, secretKey: secretKey);

  final service = S3(region: selectedRegion, credentials: credentials);

  try {
    listBuckets = await service.listBuckets();
    print("listBuckets!.buckets![0] ${listBuckets!.buckets![0]}");
    listBuckets!.buckets!.forEach((element) async {
      // print("listBuckets1--> ${val.bucketName}");
      // print("listBuckets2--> ${val.cannedACL}");
      // print("listBuckets3--> ${val.userMetadata}");
      // print("listBuckets4--> ${val.encryption}");
      // print("listBuckets5--> ${val.prefix}");
    });

    return "true";
  } catch (e) {
    print("--->   $e");
    return "false";
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      initialRoute:
          accessKey == null && serviceKey == null && selectedRegion == null
              ? '/loginpage'
              : '/homepage',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/loginpage': (context) => const LoginPage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/homepage': (context) => HomePage(
              accessKey: accessKey ?? "",
              listBucketsTransfer: listBuckets!,
              secretKey: serviceKey ?? "",
              region: selectedRegion ?? "",
              isLeading: false,
            ),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: accessKey == null
      //     ? LoginPage()
      //     : HomePage(
      //         accessKey: accessKey ?? "",
      //         listBucketsTransfer: listBuckets!,
      //         secretKey: serviceKey ?? "",
      //         region: selectedRegion ?? "",
      //       ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool error = false;

  final _accessKeyController = TextEditingController(
      // text: "AKIAQUUQNGZ5U47VP5VO"
      );
  final _serverKeyController = TextEditingController(
      // text: "TGRho2HbGEJWEmvFYvU3qXjYkGU3S/WZ9Oi+zv/N"
      );
  String _selectedRegion = '';

  @override
  void initState() {
    super.initState();
  }

  // }
  ListBucketsOutput? listBuckets;
  gettData(String accessKey, String secretKey, String selectedRegion) async {
    final credentials =
        AwsClientCredentials(accessKey: accessKey, secretKey: secretKey);

    final service = S3(region: selectedRegion, credentials: credentials);

    try {
      listBuckets = await service.listBuckets();
      print("listBuckets!.buckets![0] ${listBuckets!.buckets![0]}");
      listBuckets!.buckets!.forEach((element) async {
        // print("listBuckets1--> ${val.bucketName}");
        // print("listBuckets2--> ${val.cannedACL}");
        // print("listBuckets3--> ${val.userMetadata}");
        // print("listBuckets4--> ${val.encryption}");
        // print("listBuckets5--> ${val.prefix}");
      });

      return "true";
    } catch (e) {
      print("--->   $e");
      return "false";
    }
  }

  @override
  void dispose() {
    _accessKeyController.dispose();
    _serverKeyController.dispose();
    super.dispose();
  }

  dialogShow() async {
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
                const Text(
                  "Invalid AccessKeyId/ServerKeyId !",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
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
                    child: const Center(
                      child: Text(
                        "OK",
                        style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Login Page'),
      // ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xff77eddd), Color(0xff043831).withOpacity(0.8)],
                radius: 0.75,
                // focal: Alignment(0.7, -0.7),
                tileMode: TileMode.clamp,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Container(
                  width: size.width / 2.5,
                  // height: size.height / 2,
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // CircleAvatar(
                          //   backgroundColor: Colors.transparent,
                          //   radius: 48.0,
                          //   child: Image.asset('assets/images/logo.png'),
                          // ),
                          const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 32.0,
                          ),
                          if (error == true)
                            const Text(
                              "Invalid AccessKeyId/ServerKeyId !",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red),
                            ),

                          const SizedBox(
                            height: 32.0,
                          ),
                          RawKeyboardListener(
                            child: TextFormField(
                              controller: _accessKeyController,
                              decoration: InputDecoration(
                                labelText: 'Access Key',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your access key';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _accessKeyController.text = value;
                              },
                            ),
                            focusNode: FocusNode(),
                            onKey: (RawKeyEvent event) async {
                              // print(event.data.logicalKey.keyLabel);
                              if (event.data.logicalKey.keyLabel.toString() ==
                                  "Enter") {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  var responseVal = await gettData(
                                      _accessKeyController.text,
                                      _serverKeyController.text,
                                      _selectedRegion);

                                  // Perform login action here
                                  if (responseVal == "true") {
                                    // ignore: use_build_context_synchronously
                                    setState(() {
                                      loading = false;
                                      error = false;
                                    });
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                        "accessKey", _accessKeyController.text);
                                    await prefs.setString("serviceKey",
                                        _serverKeyController.text);
                                    await prefs.setString(
                                        "selectedRegion", _selectedRegion);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(
                                          listBucketsTransfer: listBuckets!,
                                          secretKey: _serverKeyController.text,
                                          accessKey: _accessKeyController.text,
                                          region: _selectedRegion,
                                          isLeading: false,
                                        ),
                                      ),
                                    );
                                  }
                                  if (responseVal == "false") {
                                    // ignore: use_build_context_synchronously
                                    setState(() {
                                      loading = false;
                                      error = true;
                                    });
                                    // dialogShow();
                                  }
                                }
                              }
                            },
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          RawKeyboardListener(
                            child: TextFormField(
                              controller: _serverKeyController,
                              decoration: InputDecoration(
                                labelText: 'Server Key',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your server key';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _serverKeyController.text = value;
                              },
                            ),
                            focusNode: FocusNode(),
                            onKey: (RawKeyEvent event) async {
                              // print(event.data.logicalKey.keyLabel);
                              if (event.data.logicalKey.keyLabel.toString() ==
                                  "Enter") {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  var responseVal = await gettData(
                                      _accessKeyController.text,
                                      _serverKeyController.text,
                                      _selectedRegion);

                                  // Perform login action here
                                  if (responseVal == "true") {
                                    // ignore: use_build_context_synchronously
                                    setState(() {
                                      loading = false;
                                      error = false;
                                    });
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString(
                                        "accessKey", _accessKeyController.text);
                                    await prefs.setString("serviceKey",
                                        _serverKeyController.text);
                                    await prefs.setString(
                                        "selectedRegion", _selectedRegion);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(
                                          listBucketsTransfer: listBuckets!,
                                          secretKey: _serverKeyController.text,
                                          accessKey: _accessKeyController.text,
                                          region: _selectedRegion,
                                          isLeading: false,
                                        ),
                                      ),
                                    );
                                  }
                                  if (responseVal == "false") {
                                    // ignore: use_build_context_synchronously
                                    setState(() {
                                      loading = false;
                                      error = true;
                                    });
                                    // dialogShow();
                                  }
                                }
                              }
                            },
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Region',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0),
                              ),
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
                              'us-east-1',
                              'us-east-2'
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
                          const SizedBox(height: 32.0),

                          ElevatedButton(
                            onPressed: () async {
                              // createAndUploadFile();
                              // downloadFile();
                              // listItems();
                              // function();
                              // getObjects();

                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  loading = true;
                                });
                                var responseVal = await gettData(
                                    _accessKeyController.text,
                                    _serverKeyController.text,
                                    _selectedRegion);

                                // Perform login action here
                                if (responseVal == "true") {
                                  // ignore: use_build_context_synchronously
                                  setState(() {
                                    loading = false;
                                    error = false;
                                  });
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      "accessKey", _accessKeyController.text);
                                  await prefs.setString(
                                      "serviceKey", _serverKeyController.text);
                                  await prefs.setString(
                                      "selectedRegion", _selectedRegion);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(
                                        listBucketsTransfer: listBuckets!,
                                        secretKey: _serverKeyController.text,
                                        accessKey: _accessKeyController.text,
                                        region: _selectedRegion,
                                        isLeading: false,
                                      ),
                                    ),
                                  );
                                }
                                if (responseVal == "false") {
                                  // ignore: use_build_context_synchronously
                                  setState(() {
                                    loading = false;
                                    error = true;
                                  });
                                  // dialogShow();
                                }
                              }
                            },
                            child: loading == false
                                ? const Text('Confirm')
                                : const Text('Loading'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
    );
  }
}
