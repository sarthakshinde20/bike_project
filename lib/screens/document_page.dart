import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class DocumentPage extends StatefulWidget {
  final String sessionId;
  final String vehicleId;

  DocumentPage({required this.sessionId, required this.vehicleId});

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  bool hasAdhar = false;
  bool hasPanCard = false;
  bool hasDrivingLicense = false;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    checkAndUploadDocuments();
  }

  Future<void> checkAndUploadDocuments() async {
    try {
      // Step 1: Get the list of documents
      var documentsResponse = await http.get(
        Uri.parse(
            'http://34.93.202.185:5000/user_documents?vehicle_id=${widget.vehicleId}&session=${widget.sessionId}'),
      );

      if (documentsResponse.statusCode == 200) {
        var documents = jsonDecode(documentsResponse.body);

        // Step 2: Check for existing documents
        hasAdhar = documents.any((doc) => doc['document_name'] == 'adhar');
        hasPanCard = documents.any((doc) => doc['document_name'] == 'pan_card');
        hasDrivingLicense =
            documents.any((doc) => doc['document_name'] == 'driving_license');

        // Step 3: Upload missing documents
        if (!hasAdhar) {
          await uploadDocument('adhar', '/path/to/adhar.jpg');
        }
        if (!hasPanCard) {
          await uploadDocument('pan_card', '/path/to/pan_card.jpg');
        }
        if (!hasDrivingLicense) {
          await uploadDocument(
              'driving_license', '/path/to/driving_license.jpg');
        }
      } else {
        hasError = true;
      }
    } catch (e) {
      hasError = true;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> uploadDocument(String documentName, String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://34.93.202.185:5000/api/v1/add_user_documents'),
      );

      request.fields.addAll({
        'data': jsonEncode({
          'vehicle_id': widget.vehicleId,
          'document_name': documentName,
          'session': widget.sessionId,
        }),
      });

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        print('$documentName uploaded successfully');
        setState(() {
          if (documentName == 'adhar') hasAdhar = true;
          if (documentName == 'pan_card') hasPanCard = true;
          if (documentName == 'driving_license') hasDrivingLicense = true;
        });
      } else {
        print('Failed to upload $documentName');
      }
    } catch (e) {
      print('Error occurred during upload: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documents'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Error occurred while fetching documents'))
              : ListView(
                  children: [
                    ListTile(
                      title: Text('Adhar'),
                      trailing: Icon(
                        hasAdhar ? Icons.check : Icons.close,
                        color: hasAdhar ? Colors.green : Colors.red,
                      ),
                    ),
                    ListTile(
                      title: Text('PAN Card'),
                      trailing: Icon(
                        hasPanCard ? Icons.check : Icons.close,
                        color: hasPanCard ? Colors.green : Colors.red,
                      ),
                    ),
                    ListTile(
                      title: Text('Driving License'),
                      trailing: Icon(
                        hasDrivingLicense ? Icons.check : Icons.close,
                        color: hasDrivingLicense ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
    );
  }
}
