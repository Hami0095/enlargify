// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ImageProcessingApp extends StatefulWidget {
  const ImageProcessingApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ImageProcessingAppState createState() => _ImageProcessingAppState();
}

class _ImageProcessingAppState extends State<ImageProcessingApp> {
  Uint8List? _imageData;
  String? _selectedAlgorithm;
  double _scaleFactor = 2.0;
  String? _fileName;
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageData = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _sendImageForProcessing() async {
    if (_imageData == null || _selectedAlgorithm == null) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    var uri = Uri.parse('http://127.0.0.1:5000/enlarge_image');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      _imageData!,
      filename: _fileName!,
    ));
    request.fields['algorithm'] = _selectedAlgorithm!;
    request.fields['scaleFactor'] = _scaleFactor.toString();

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        // Read the response as bytes
        Uint8List responseBytes = await response.stream.toBytes();

        // Create a Blob and trigger download
        final blob = html.Blob([responseBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.Url.revokeObjectUrl(url);

        // Optional: Show alert or update UI
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Image Processed',
                style: GoogleFonts.exo2(
                    color: const Color.fromARGB(255, 10, 54, 90)),
              ),
              content:
                  const Text('The image has been processed and downloaded.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: GoogleFonts.exo2(color: Colors.blue),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        // Handle server errors
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Error',
                style: GoogleFonts.exo(color: Colors.red),
              ),
              content: Text(
                  'Failed to process image. Status code: ${response.statusCode}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: GoogleFonts.exo2(color: Colors.blue),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle exceptions
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error', style: GoogleFonts.exo(color: Colors.red)),
            content: Text('An error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: GoogleFonts.exo2(color: Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Enlargify",
            style: GoogleFonts.barriecito(
              color: Colors.white,
              fontSize: 50,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 60, 90),
      ),
      backgroundColor: const Color.fromARGB(255, 48, 104, 133),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 2, 79, 116),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _fileName == null
                  ? Text("No image selected.",
                      style: GoogleFonts.exo(color: Colors.white))
                  : Text("Selected Image: $_fileName",
                      style: GoogleFonts.exo(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 56, 78)),
                child: Text("Pick an image",
                    style: GoogleFonts.exo().copyWith(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                hint: Text("Select algorithm",
                    style: GoogleFonts.exo(color: Colors.white)),
                value: _selectedAlgorithm,
                onChanged: (value) {
                  setState(() {
                    _selectedAlgorithm = value;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 'zero_order_hold',
                    child: Text(
                      "Zero Order Hold",
                      style: GoogleFonts.exo2().copyWith(color: Colors.white),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'bilinear_interpolation',
                    child: Text(
                      "Bilinear Interpolation",
                      style: GoogleFonts.exo2().copyWith(color: Colors.white),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'linear_interpolation',
                    child: Text(
                      "Linear Interpolation",
                      style: GoogleFonts.exo2().copyWith(color: Colors.white),
                    ),
                  ),
                ],
                dropdownColor: const Color.fromARGB(255, 1, 60, 90),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Scale Factor",
                      style: GoogleFonts.exo(color: Colors.white)),
                  Expanded(
                    child: Slider(
                      value: _scaleFactor,
                      min: 1.0,
                      activeColor: Colors.blue,
                      max: 10.0,
                      divisions: 9,
                      label: _scaleFactor.toString(),
                      onChanged: (value) {
                        setState(() {
                          _scaleFactor = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isProcessing ? null : _sendImageForProcessing,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 56, 78)),
                child: _isProcessing
                    ? const CircularProgressIndicator(
                        color: Colors.blue,
                        backgroundColor: Colors.white,
                      )
                    : Text("Enlarge Image",
                        style: GoogleFonts.exo().copyWith(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              _imageData != null
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Image.memory(_imageData!),
                    )
                  : const SizedBox.shrink(), // Show the image if available
            ],
          ),
        ),
      ),
    );
  }
}
