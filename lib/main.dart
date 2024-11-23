import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capture and Save Image',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.exo2(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge:
              GoogleFonts.abrilFatface(fontSize: 16, color: Colors.grey[700]),
        ),
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;

  Future<void> _captureImage() async {
    // Request camera permission
    final cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      // If camera permission is granted, request storage permission for images
      final storageStatus =
          await Permission.photos.request(); // Requesting READ_MEDIA_IMAGES

      if (storageStatus.isGranted) {
        // Both permissions granted, proceed to capture image
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.camera);

        if (pickedFile != null) {
          setState(() {
            _isLoading = true;
          });
          final imageTemp = File(pickedFile.path);
          await _saveImageToPublicFolder(imageTemp);
          setState(() {
            _isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected')),
          );
        }
      } else {
        // Handle storage permission denial
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } else {
      // Handle camera permission denial
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission denied')),
      );
    }
  }

  Future<void> _saveImageToPublicFolder(File image) async {
    try {
      final directory =
          await getApplicationDocumentsDirectory(); // Get the application documents directory
      final publicDir = Directory('${directory.path}/sus_app');

      if (!(await publicDir.exists())) {
        await publicDir.create(recursive: true);
      }

      final imagePath = path.join(publicDir.path,
          'captured_image_${DateTime.now().millisecondsSinceEpoch}.png');

      final savedImage = await image.copy(imagePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to ${savedImage.path}')),
      );
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }

  Future<List<File>> _getImages() async {
    try {
      final directory =
          await getApplicationDocumentsDirectory(); // Get the application documents directory
      final publicDir = Directory('${directory.path}/sus_app');

      List<File> images = [];

      if (await publicDir.exists()) {
        final List<FileSystemEntity> entities = publicDir.listSync();
        for (var entity in entities) {
          if (entity is File &&
              (entity.path.endsWith('.png') || entity.path.endsWith('.jpg'))) {
            images.add(entity);
          }
        }
      } else {
        print('Directory does not exist');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image directory does not exist')),
        );
      }

      return images;
    } catch (e) {
      print('Error fetching images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching images: $e')),
      );
      return []; // Return an empty list on error
    }
  }

  void _viewCapturedImages() async {
    List<File> images = await _getImages();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGallery(images: images),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ecowardrobe',
          style: GoogleFonts.exo2(color: Colors.white),
        ),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/background_image.png'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _captureImage(),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Capture New Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white
                              .withOpacity(0.3), // Transparent white tint
                          foregroundColor: Colors.indigoAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // Rounded corners
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _viewCapturedImages,
                        icon: const Icon(Icons.photo_album_outlined),
                        label: const Text('View Captured Images'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white
                              .withOpacity(0.3), // Transparent white tint
                          foregroundColor: Colors.indigoAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            () {}, // Add functionality for "Track Outfit"
                        icon:
                            const Icon(Icons.track_changes), // Placeholder icon
                        label: const Text('Track Outfit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white
                              .withOpacity(0.3), // Transparent white tint
                          foregroundColor: Colors.indigoAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {}, // Add functionality for "Statistics"
                        icon: const Icon(Icons.bar_chart), // Placeholder icon
                        label: const Text('Statistics'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white
                              .withOpacity(0.3), // Transparent white tint
                          foregroundColor: Colors.indigoAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class ImageGallery extends StatelessWidget {
  final List<File> images;

  const ImageGallery({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captured Images')),
      body: images.isEmpty
          ? Center(child: Text('No images found.'))
          : GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.file(images[index], fit: BoxFit.cover),
                );
              },
            ),
    );
  }
}
