import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class FetchPage extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  FetchPage({required this.sessionId, required this.vehicleId});

  @override
  _FetchPageState createState() => _FetchPageState();
}

class _FetchPageState extends State<FetchPage> {
  List<Map<String, dynamic>> _fetchedDocuments = [];
  final String apiUrl = 'http://34.93.202.185:5000';
  bool _loading = true;
  String _errorMessage = '';

  Future<void> _fetchDocuments() async {
    List<String> documentNames = [
      'adharFront',
      'adharBack',
      'drivingLicense',
      'panCard',
      'insurance',
      'rcbook'
    ];

    List<Map<String, dynamic>> documents = [];
    for (String name in documentNames) {
      try {
        final response = await http.get(Uri.parse(
            '$apiUrl/get_document?vehicle_id=${widget.vehicleId}&session=${widget.sessionId}&user_document_name=$name'));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['data'] is Map && data['data']['data'] is String) {
            final doc = data['data'];
            documents.add({
              'name': _getDocumentName(name),
              'data': base64Decode(doc['data']),
            });
          } else {
            print('Unexpected data format for $name');
          }
        } else {
          print('Failed to fetch $name');
        }
      } catch (e) {
        print('Error fetching $name: $e');
        setState(() {
          _errorMessage = 'Failed to load documents. Please try again later.';
        });
      }
    }

    setState(() {
      _fetchedDocuments = documents;
      _loading = false;
    });
  }

  String _getDocumentName(String documentType) {
    const Map<String, String> documentNames = {
      'adharFront': 'Adhaar Card Front',
      'adharBack': 'Adhaar Card Back',
      'drivingLicense': 'Driving License',
      'panCard': 'PAN Card',
      'insurance': 'Insurance',
      'rcbook': 'RC Book',
    };

    return documentNames[documentType] ?? 'Unknown Document';
  }

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                  'View Document',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Goldman',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
                    size: screenWidth * 0.07,
                  ),
                  SizedBox(width: screenWidth * 0.005),
                  const Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'View Document',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            ..._fetchedDocuments.map((doc) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FullScreenImagePage(
                                          imageName: doc['name'],
                                          imageData: doc['data'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Montserrat',
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Image.memory(
                                          doc['data'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final Uint8List imageData;
  final String imageName;

  FullScreenImagePage({required this.imageData, required this.imageName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(imageName),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Center(
        child: Image.memory(
          imageData,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.error));
          },
        ),
      ),
    );
  }
}
