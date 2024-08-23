import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Import for File class
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final String sessionId;
  final String vehicleId;

  const EditProfilePage({
    Key? key,
    required this.sessionId,
    required this.vehicleId,
  }) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _model = EditProfileModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  final uri = Uri.parse('http://34.93.202.185:5000/api/v1/add_user_documents');

  Future<void> _showImageSourceDialog(String document, int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            document,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white, // Set dialog background color
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Position the front of your $document in the frame',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Raleway',
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.photo, size: 50, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop(); // Close the dialog
                          final pickedImage = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          _handlePickedImage(pickedImage, document, index);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/gallery.png',
                                height: 50, width: 50),
                            const SizedBox(height: 8),
                            const Text('from gallery',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Raleway',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop(); // Close the dialog
                          final pickedImage = await ImagePicker()
                              .pickImage(source: ImageSource.camera);
                          _handlePickedImage(pickedImage, document, index);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/camera.png',
                                height: 50, width: 50),
                            const SizedBox(height: 8),
                            const Text('Take photo',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Raleway',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handlePickedImage(XFile? pickedImage, String document, int index) {
    if (pickedImage != null) {
      setState(() {
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
      });
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
                  'Upload Document',
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
                vertical: MediaQuery.of(context).size.height * 0.285,
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showImageSourceDialog('Aadhar Card', 1),
                      child: _buildDocumentImage(
                          _aadharCardImage1, 'assets/images/document.png'),
                    ),
                    if (_aadharCardImage1 != null) ...[
                      const SizedBox(width: 8.0),
                      GestureDetector(
                        onTap: _removeAadharCardImage1,
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
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showImageSourceDialog('Aadhar Card', 2),
                      child: _buildDocumentImage(
                          _aadharCardImage2, 'assets/images/document.png'),
                    ),
                    if (_aadharCardImage2 != null) ...[
                      const SizedBox(width: 8.0),
                      GestureDetector(
                        onTap: _removeAadharCardImage2,
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
                ),
                const SizedBox(height: 20),
                _buildDocumentSection('Pan Card', _panCardImage, null,
                    'Pan Card', _removePanCardImage),
                _buildDocumentSection('Insurance', _insuranceImage, null,
                    'Insurance', _removeInsuranceImage),
                _buildDocumentSection('Driving Licence', _drivingLicenceImage,
                    null, 'Driving Licence', _removeDrivingLicenceImage),
                _buildDocumentSection('RC Book', _rcbookImage, null, 'RC Book',
                    _removeRcBookImage),
                SizedBox(height: topPadding - 60),
                Align(
                  alignment: const AlignmentDirectional(0, 0.30),
                  child: SizedBox(
                    width: 317,
                    height: 55,
                    child: TextButton(
                      onPressed: _uploadDocuments,
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
                            color: const Color.fromARGB(255, 9, 84, 94),
                            width: 2.0,
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Upload',
                            style: TextStyle(
                              fontFamily: 'Goldman',
                              color: Colors.black,
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
          )
        ],
      ),
    );
  }

  Widget _buildDocumentSection(String documentName, XFile? image1,
      XFile? image2, String dialogDocument, void Function()? onRemove) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          documentName,
          style: const TextStyle(
            fontFamily: 'Raleway',
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Image 1
            GestureDetector(
              onTap: () => _showImageSourceDialog(dialogDocument, 1),
              child: _buildDocumentImage(image1, 'assets/images/document.png'),
            ),
            if (image2 != null) ...[
              const SizedBox(width: 10),
              // Image 2
              GestureDetector(
                onTap: () => _showImageSourceDialog(dialogDocument, 2),
                child:
                    _buildDocumentImage(image2, 'assets/images/document.png'),
              ),
            ],
            // Remove Button
            if (image1 != null || image2 != null) ...[
              const SizedBox(width: 8.0),
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
                      size: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDocumentImage(XFile? image, String placeholderAsset) {
    return Container(
      height: 100,
      width: 100,
      child: image == null
          ? Image.asset(
              placeholderAsset,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
          : Image.file(
              File(image.path),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
    );
  }

  Future<void> _uploadDocuments() async {
    final request = http.MultipartRequest('POST', uri)
      ..fields['data'] = jsonEncode({
        "vehicle_id": widget.vehicleId,
        "document_name": "profile_picture",
        "session": widget.sessionId
      });

    // Add files to request if they exist
    _addFileToRequest(_aadharCardImage1, request);
    _addFileToRequest(_aadharCardImage2, request);
    _addFileToRequest(_panCardImage, request);
    _addFileToRequest(_drivingLicenceImage, request);
    _addFileToRequest(_insuranceImage, request);
    _addFileToRequest(_rcbookImage, request);

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        // Handle success
        print('Documents uploaded successfully');
      } else {
        // Handle failure
        print('Failed to upload documents');
      }
    } catch (e) {
      // Handle error
      print('Error: $e');
    }
  }

  void _addFileToRequest(XFile? file, http.MultipartRequest request) {
    if (file != null) {
      final fileStream = file.readAsBytes().asStream();
      final fileLength = File(file.path).lengthSync();
      request.files.add(
        http.MultipartFile(
          'file',
          fileStream,
          fileLength,
          filename: file.name,
        ),
      );
    }
  }

  void _removeAadharCardImage1() {
    setState(() {
      _aadharCardImage1 = null;
    });
  }

  void _removeAadharCardImage2() {
    setState(() {
      _aadharCardImage2 = null;
    });
  }

  void _removePanCardImage() {
    setState(() {
      _panCardImage = null;
    });
  }

  void _removeInsuranceImage() {
    setState(() {
      _insuranceImage = null;
    });
  }

  void _removeDrivingLicenceImage() {
    setState(() {
      _drivingLicenceImage = null;
    });
  }

  void _removeRcBookImage() {
    setState(() {
      _rcbookImage = null;
    });
  }
}
