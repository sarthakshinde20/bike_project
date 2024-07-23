import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileModel {
  FFUploadedFile? uploadedLocalFile1;
  bool isDataUploading1 = false;

  void dispose() {}
}

class FFUploadedFile {
  final String name;
  final Uint8List? bytes;
  final double? height;
  final double? width;
  final String? blurHash;

  FFUploadedFile({
    required this.name,
    required this.bytes,
    this.height,
    this.width,
    this.blurHash,
  });
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage(
      {super.key, required this.sessionId, required this.vehicleId});

  final String sessionId;
  final String vehicleId;

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late EditProfileModel _model;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  XFile? _aadharCardImage1;
  XFile? _aadharCardImage2;
  XFile? _panCardImage;
  XFile? _drivingLicenceImage;
  XFile? _insuranceImage;
  XFile? _rcbookImage;
  Map<String, dynamic>? userDocument;

  @override
  void initState() {
    super.initState();
    _model = EditProfileModel();
    _fetchUserDocuments();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDocuments() async {
    final response = await http.get(Uri.parse(
        'http://34.93.202.185:5000/user_documents?vehicle_id=${widget.vehicleId}&session=${widget.sessionId}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        userDocument = data;
        // Parse the response data and set the image variables accordingly
        if (userDocument != null) {
          _aadharCardImage1 = userDocument!['aadharCardImage1'] != null
              ? XFile(userDocument!['aadharCardImage1'])
              : null;
          _aadharCardImage2 = userDocument!['aadharCardImage2'] != null
              ? XFile(userDocument!['aadharCardImage2'])
              : null;
          _panCardImage = userDocument!['panCardImage'] != null
              ? XFile(userDocument!['panCardImage'])
              : null;
          _insuranceImage = userDocument!['insuranceImage'] != null
              ? XFile(userDocument!['insuranceImage'])
              : null;
          _drivingLicenceImage = userDocument!['drivingLicenceImage'] != null
              ? XFile(userDocument!['drivingLicenceImage'])
              : null;
          _rcbookImage = userDocument!['rcbookImage'] != null
              ? XFile(userDocument!['rcbookImage'])
              : null;
        }
      });
    } else {
      // Handle error
      print('Failed to load user documents');
    }
  }

  Future<void> _uploadDocument(String documentType, XFile image) async {
    final uri = Uri.parse(
        'http://34.93.202.185:5000/api/v1/add_user_documents'); // Update with your endpoint

    var request = http.MultipartRequest('POST', uri)
      ..fields['documentType'] = documentType
      ..files.add(await http.MultipartFile.fromPath(
        'file', // The name of the file parameter
        image.path,
      ));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('Successfully uploaded $documentType. Response: $responseBody');
      } else {
        print(
            'Failed to upload $documentType. Status: ${response.statusCode}. Response: $responseBody');
      }
    } catch (e) {
      print('Error occurred while uploading $documentType: $e');
    }
  }

  Future<void> _handleUpload() async {
    if (_aadharCardImage1 != null) {
      await _uploadDocument('Aadhar Card Image 1', _aadharCardImage1!);
    }
    if (_aadharCardImage2 != null) {
      await _uploadDocument('Aadhar Card Image 2', _aadharCardImage2!);
    }
    if (_panCardImage != null) {
      await _uploadDocument('Pan Card', _panCardImage!);
    }
    if (_insuranceImage != null) {
      await _uploadDocument('Insurance', _insuranceImage!);
    }
    if (_drivingLicenceImage != null) {
      await _uploadDocument('Driving Licence', _drivingLicenceImage!);
    }
    if (_rcbookImage != null) {
      await _uploadDocument('RC Book', _rcbookImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double topPadding = size.height * 0.1;
    final double sidePadding = size.width * 0.05;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [
          Align(
            alignment: const AlignmentDirectional(-2, -0.9),
            child: ClipRRect(
              child: Image.asset(
                'assets/images/headline.png',
                width: screenWidth * 0.9, // 90% of screen width
                height: screenHeight * 0.3, // 30% of screen height
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.155, // 15% of screen height
              bottom: screenHeight * 0.025, // 2.5% of screen height
              right: screenWidth * 0.15, // 35% of screen width
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Manage Document',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Goldman',
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 3.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(119, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.272,
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: MediaQuery.of(context).size.width * 0.05,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: 'Goldman',
                      fontSize: MediaQuery.of(context).size.width *
                          0.045, // Adjust text size
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 250),
            child: ListView(
              padding: EdgeInsets.fromLTRB(sidePadding, 10, sidePadding, 10),
              children: [
                const Text(
                  'Manage Document',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: topPadding - 50),
                _buildDocumentSection('Aadhar Card', _aadharCardImage1,
                    _aadharCardImage2, 'Aadhar Card'),
                _buildDocumentSection(
                    'Pan Card', _panCardImage, null, 'Pan Card'),
                _buildDocumentSection(
                    'Insurance', _insuranceImage, null, 'Insurance'),
                _buildDocumentSection('Driving Licence', _drivingLicenceImage,
                    null, 'Driving Licence'),
                _buildDocumentSection('RC Book', _rcbookImage, null, 'RC Book'),
                SizedBox(height: topPadding - 60),
                Align(
                  alignment: const AlignmentDirectional(0, 0.30),
                  child: SizedBox(
                    width: 317,
                    height: 55,
                    child: TextButton(
                      onPressed: _handleUpload,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(73),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1000),
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Upload',
                            style: TextStyle(
                              fontFamily: 'Goldman',
                              color: Color.fromARGB(255, 9, 84, 94),
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(
      String title, XFile? image1, XFile? image2, String document) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title,
        style: const TextStyle(
          fontFamily: 'Raleway',
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (document == 'Aadhar Card') ...[
            _buildImagePicker(
              image: image1,
              document: document,
              index: 1,
              onRemove: () {
                setState(() {
                  _aadharCardImage1 = null;
                });
              },
            ),
            const SizedBox(width: 10),
            _buildImagePicker(
              image: image2,
              document: document,
              index: 2,
              onRemove: () {
                setState(() {
                  _aadharCardImage2 = null;
                });
              },
            ),
          ] else ...[
            _buildImagePicker(
              image: image1,
              document: document,
              index: 0,
              onRemove: () {
                setState(() {
                  if (document == 'Pan Card') {
                    _panCardImage = null;
                  } else if (document == 'Insurance') {
                    _insuranceImage = null;
                  } else if (document == 'Driving Licence') {
                    _drivingLicenceImage = null;
                  } else if (document == 'RC Book') {
                    _rcbookImage = null;
                  }
                });
              },
            ),
          ],
        ],
      ),
      const SizedBox(height: 40),
    ]);
  }

  Widget _buildImagePicker({
    required XFile? image,
    required String document,
    required int index,
    required VoidCallback onRemove,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: image == null
              ? () => _showImageSourceDialog(document, index)
              : null,
          child: image == null
              ? Image.asset(
                  'assets/images/document.png', // Replace with your image asset path
                  height: 100.0,
                  width: 100.0,
                )
              : Image.file(
                  File(image.path),
                  height: 150.0,
                  width: 100.0,
                ),
        ),
        if (image != null) ...[
          const SizedBox(
              width: 8.0), // Space between the image and remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 25.0,
              height: 25.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 242, 83, 83),
                  width: 1.0,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.close,
                  color: Color.fromARGB(255, 242, 83, 83),
                  size: 15.0,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showImageSourceDialog(String document, int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          actions: <Widget>[
            TextButton(
              child: const Text('Camera'),
              onPressed: () async {
                Navigator.of(context).pop();
                final ImagePicker _picker = ImagePicker();
                final XFile? pickedImage = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (pickedImage != null) {
                  setState(() {
                    _updateImage(document, index, pickedImage);
                  });
                }
              },
            ),
            TextButton(
              child: const Text('Gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                final ImagePicker _picker = ImagePicker();
                final XFile? pickedImage = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedImage != null) {
                  setState(() {
                    _updateImage(document, index, pickedImage);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateImage(String document, int index, XFile pickedImage) {
    if (document == 'Aadhar Card') {
      if (index == 1) {
        _aadharCardImage1 = pickedImage;
      } else if (index == 2) {
        _aadharCardImage2 = pickedImage;
      }
    } else if (document == 'Pan Card') {
      _panCardImage = pickedImage;
    } else if (document == 'Insurance') {
      _insuranceImage = pickedImage;
    } else if (document == 'Driving Licence') {
      _drivingLicenceImage = pickedImage;
    } else if (document == 'RC Book') {
      _rcbookImage = pickedImage;
    }
  }
}
