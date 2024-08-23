import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class UploadPage extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  UploadPage({required this.sessionId, required this.vehicleId});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  File? _adharFrontFile;
  File? _adharBackFile;
  File? _drivingLicenseFile;
  File? _panCardFile;
  File? _insuranceFile;
  File? _rcbookFile;
  final picker = ImagePicker();
  final String apiUrl = 'http://34.93.202.185:5000';

  Future<void> _pickImage(String documentType, String title) async {
    try {
      await _showImageSourceDialog(documentType, title);
    } catch (e) {
      _showDialog('Error picking image: $e', 'Error', Icons.error);
    }
  }

  Future<void> _showImageSourceDialog(String documentType, String title) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Position the front of your $title in the frame',
            style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the buttons horizontally
              children: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      setState(() {
                        _updateImageFile(documentType, File(pickedFile.path));
                      });
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset('assets/images/camera.png',
                          width: 50, height: 50),
                      const SizedBox(height: 8),
                      const Text(
                        'Take photo',
                        style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _updateImageFile(documentType, File(pickedFile.path));
                      });
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset('assets/images/gallery.png',
                          width: 50, height: 50),
                      const SizedBox(height: 8),
                      const Text(
                        'From gallery',
                        style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _updateImageFile(String documentType, File imageFile) {
    setState(() {
      switch (documentType) {
        case 'adharFront':
          _adharFrontFile = imageFile;
          break;
        case 'adharBack':
          _adharBackFile = imageFile;
          break;
        case 'drivingLicense':
          _drivingLicenseFile = imageFile;
          break;
        case 'panCard':
          _panCardFile = imageFile;
          break;
        case 'insurance':
          _insuranceFile = imageFile;
          break;
        case 'rcbook':
          _rcbookFile = imageFile;
          break;
      }
    });
  }

  Future<void> _uploadImage(String documentName, File? imageFile) async {
    if (imageFile == null) {
      _showDialog('Error', 'Please Select Image to Upload', Icons.error);
      return;
    }

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$apiUrl/api/v1/add_user_documents'));
      request.fields['data'] = jsonEncode({
        'vehicle_id': widget.vehicleId,
        'document_name': documentName,
        'session': widget.sessionId,
      });

      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        _showDialog('Success', 'Upload successful for $documentName',
            Icons.check_circle);
      } else {
        _showDialog('Error', 'Upload failed for $documentName: $responseBody',
            Icons.error);
      }
    } catch (e) {
      _showDialog('Error', 'Error uploading image: $e', Icons.error);
    }
  }

  void _showDialog(String title, String message, IconData icon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color:
                      icon == Icons.check_circle ? Colors.green : Colors.red),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w700,
                    fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w600,
                fontSize: 14),
          ),
          actions: <Widget>[],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Align(
            alignment: const AlignmentDirectional(-2, -0.9),
            child: ClipRRect(
              child: Image.asset(
                'assets/images/headline.png',
                width: screenWidth * 0.9,
                height: screenHeight * 0.3,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.155,
              bottom: screenHeight * 0.025,
              right: screenWidth * 0.15,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Upload Document',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Goldman',
                    color: Colors.white,
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
                vertical: screenHeight * 0.285,
                horizontal: screenWidth * 0.05,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: screenWidth * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: 'Goldman',
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.32,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDocumentSection(
                          'Adhaar Card Front',
                          'adharFront',
                          _adharFrontFile,
                          () => _pickImage('adharFront', 'Adhaar Card Front'),
                          () => _uploadImage('adharFront', _adharFrontFile),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDocumentSection(
                          'Adhaar Card Back',
                          'adharBack',
                          _adharBackFile,
                          () => _pickImage('adharBack', 'Adhaar Card Back'),
                          () => _uploadImage('adharBack', _adharBackFile),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentSection(
                    'Driving License',
                    'drivingLicense',
                    _drivingLicenseFile,
                    () => _pickImage('drivingLicense', 'Driving License'),
                    () => _uploadImage('drivingLicense', _drivingLicenseFile),
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentSection(
                    'PAN Card',
                    'panCard',
                    _panCardFile,
                    () => _pickImage('panCard', 'PAN Card'),
                    () => _uploadImage('panCard', _panCardFile),
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentSection(
                    'Insurance',
                    'insurance',
                    _insuranceFile,
                    () => _pickImage('insurance', 'Insurance'),
                    () => _uploadImage('insurance', _insuranceFile),
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentSection(
                    'RC Book',
                    'rcbook',
                    _rcbookFile,
                    () => _pickImage('rcbook', 'RC Book'),
                    () => _uploadImage('rcbook', _rcbookFile),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(
    String title,
    String documentType,
    File? imageFile,
    VoidCallback onPickImage,
    VoidCallback onUploadImage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontFamily: 'Raleway', fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(255, 43, 214, 28), width: 5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: imageFile != null
                ? Image.file(imageFile, fit: BoxFit.cover)
                : const Center(
                    child: Icon(
                      Icons.add,
                      size: 40.0,
                      color: Color.fromARGB(255, 43, 214, 28),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onUploadImage,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1000),
              side: const BorderSide(color: Colors.black, width: 2.0),
            ),
          ),
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
      ],
    );
  }
}
