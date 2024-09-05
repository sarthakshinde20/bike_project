import 'dart:io';
import 'dart:typed_data';

import 'package:bike_project/screens/document_page.dart';
import 'package:bike_project/screens/editprofile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileModel {
  void dispose() {}
}

class ProfilePage extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  const ProfilePage(
      {super.key, required this.sessionId, required this.vehicleId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileModel _model;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String? _phoneNumber;
  Uint8List? _profilePhoto;
  File? _profilePhotoFile;
  String? _userName;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _model = ProfileModel();
    _fetchUserDetails(); // Fetch user details on page load
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
    final url = Uri.parse(
        'http://34.93.202.185:5000/api/v1/get_user_details?vehicle_id=${widget.vehicleId}&session=${widget.sessionId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Log the entire JSON response for debugging
        print('Fetched data: $jsonData');

        // Access the 'data' object
        final data = jsonData['data'];
        if (data is Map<String, dynamic>) {
          // Extract the phone number
          final phoneNumber = data['phone_number'];
          final userName = data['user_name'];

          if (phoneNumber is String) {
            setState(() {
              _phoneNumber = phoneNumber;
            });
          } else {
            print('Unexpected type for phone_number');
          }

          if (userName is String) {
            setState(() {
              _userName = userName; // Store the user_name
            });
          }

          // Extract and decode the profile picture
          final profilePicture = data['profile_picture'];
          if (profilePicture is String) {
            setState(() {
              _profilePhoto = base64Decode(profilePicture);
            });
          } else if (profilePicture is Map<String, dynamic>) {
            // Handle case if profile_picture is not a string but another Map
            final imageData = profilePicture['data'];
            if (imageData is String) {
              setState(() {
                _profilePhoto = base64Decode(imageData);
              });
            } else {
              print('Unexpected type for profile_picture data');
            }
          } else {
            print('Unexpected type for profile_picture');
          }
        } else {
          print('Unexpected data structure');
        }
      } else {
        print('Failed to load user details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching user details: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePhotoFile = File(pickedFile.path);
      });
      // Upload the selected image
      await _uploadImage('profile_picture', _profilePhotoFile);
      // Re-fetch user details to update profile picture
      _fetchUserDetails();
    }
  }

  Future<void> _uploadImage(String documentName, File? imageFile) async {
    if (imageFile == null) {
      _showDialog('No image selected for $documentName',
          Image.asset('assets/images/upload.png'));
      return;
    }

    try {
      var request = http.MultipartRequest('POST',
          Uri.parse('http://34.93.202.185:5000/api/v1/add_user_documents'));
      request.fields['data'] = jsonEncode({
        'vehicle_id': widget.vehicleId,
        'document_name': documentName,
        'session': widget.sessionId,
      });

      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Upload Response for $documentName: $responseBody');

      if (response.statusCode == 200) {
        _showDialog('Profile Photo Uploaded Successfully',
            Image.asset('assets/images/upload.png'));
      } else {
        _showDialog('Upload failed for $documentName: $responseBody',
            Image.asset('assets/images/error.png'));
      }
    } catch (e) {
      _showDialog(
          'Error uploading image: $e', Image.asset('assets/images/error.png'));
    }
  }

  void _showDialog(String message, Widget image, {VoidCallback? onOK}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              SizedBox(
                height: 50, // Set desired height
                width: 50, // Set desired width
                child: image, // Display the image with specified size
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
        if (onOK != null) {
          onOK();
        }
      }
    });
  }

  Future<void> _logout() async {
    // Clear session data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionId');
    await prefs.remove('vehicleId');

    // Navigate back to login page
    Navigator.of(context).pushNamedAndRemoveUntil(
      'login', // Replace with your login route
      (Route<dynamic> route) => false,
    );
  }

  void _showFullScreenImage(Uint8List imageData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20), // Adjust top corners radius
              bottom: Radius.circular(20), // Adjust bottom corners radius
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Center(
                    child: Image.memory(
                      imageData,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width *
                          1.5, // 25% of the screen width
                      height: MediaQuery.of(context).size.width *
                          1.0, // Maintaining square aspect ratio (100x100 approx)
                    ),
                  ),
                  Positioned(
                    top: 05,
                    right: 06,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Color.fromARGB(255, 0, 0, 0)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 250, // Adjust this width as needed
                child: Ink(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 9, 84, 94),
                      width: 2.5,
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white,
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: () {
                      Navigator.of(context).pop(); // Close the dialog
                      _pickImage(); // Trigger image picking functionality
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: const Text(
                        'Change Profile Photo',
                        style: TextStyle(
                          fontFamily: 'Goldman',
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16), // Optional spacing below the button
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Align(
              alignment: const AlignmentDirectional(-2, -0.9),
              child: ClipRRect(
                child: Image.asset(
                  'assets/images/headline.png',
                  width: screenWidth * 0.85, // 90% of screen width
                  height: screenHeight * 0.3, // 30% of screen height
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.152, // 15% of screen height
                bottom: screenHeight * 0.025, // 2.5% of screen height
                right: screenWidth * 0.28, // 35% of screen width
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 34,
                      fontFamily: 'Goldman',
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 3.0),
                          color: Color.fromARGB(119, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Positioned(
            //   top: MediaQuery.of(context).size.height * 0.55,
            //   left: MediaQuery.of(context).size.width * 0.1,
            //   right: MediaQuery.of(context).size.width * 0.1,
            //   child: GestureDetector(
            //     onTap: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => EditProfilePage(
            //             sessionId: widget.sessionId,
            //             vehicleId: widget.vehicleId,
            //           ),
            //         ),
            //       );
            //     },
            //     child: Container(
            //       height: 27,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       child: const Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text(
            //             'Manage Document',
            //             style: TextStyle(
            //               fontFamily: 'Raleway',
            //               fontSize: 20,
            //               letterSpacing: 0,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //           Icon(
            //             Icons.arrow_forward_ios,
            //             color: Color.fromARGB(255, 32, 32, 32),
            //             size: 20,
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            // Positioned to display the phone number and profile photo
            Positioned(
              top: MediaQuery.of(context).size.height * 0.345,
              left: MediaQuery.of(context).size.width * 0.1,
              child: Row(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_profilePhoto != null) {
                            _showFullScreenImage(_profilePhoto!);
                          }
                        },
                        child: ClipOval(
                          child: _profilePhoto != null
                              ? Image.memory(
                                  _profilePhoto!,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 52,
                                  height: 52,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: const CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 44, 44, 44),
                            radius: 12,
                            child: Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height *
                  0.38, // Adjust based on screen height
              left: MediaQuery.of(context).size.width *
                  0.07, // Adjust based on screen width
              right: MediaQuery.of(context).size.width *
                  0.1, // Adjust right padding if needed
              child: Text(
                _phoneNumber ??
                    'Loading...', // Show loading text if phone number is not yet fetched
                style: TextStyle(
                  fontSize: 16, // Adjust font size based on screen width
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
                textAlign:
                    TextAlign.center, // Optional: center the text horizontally
              ),
            ),
            Positioned(
              top:
                  MediaQuery.of(context).size.height * 0.34, // Adjust as needed
              left: MediaQuery.of(context).size.width * 0.32,
              right: MediaQuery.of(context).size.width * 0.1,
              child: Text(
                _userName ?? 'No Data Found...', // Display the user's name
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.start,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.48,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadPage(
                        sessionId: widget.sessionId,
                        vehicleId: widget.vehicleId,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 27,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upload Document',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color.fromARGB(255, 32, 32, 32),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.54,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FetchPage(
                        sessionId: widget.sessionId,
                        vehicleId: widget.vehicleId,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 27,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'View Document',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color.fromARGB(255, 32, 32, 32),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(-0.76, 0.25),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/logout.png',
                                width: 60.0,
                                height: 60.0,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 3),
                              const Flexible(
                                child: Text(
                                  'Are you sure you want to logout?',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontFamily: 'Raleway',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100, // Adjust width as needed
                                height: 40, // Adjust height as needed
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color.fromARGB(
                                        255, 9, 84, 94), // Border color
                                    width: 2.0, // Border width
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _logout(); // Call logout function
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Ok',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Raleway',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: Text(
                  'Logout',
                  style: Theme.of(context).textTheme.bodyLarge!.merge(
                        const TextStyle(
                          fontFamily: 'Montserrat',
                          color: Color(0xFFFF693B),
                          fontSize: 18,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0, 0.9),
              child: GestureDetector(
                onTap: () {
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.14,
                  height: MediaQuery.of(context).size.width * 0.14,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/home.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
