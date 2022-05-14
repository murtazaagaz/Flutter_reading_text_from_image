import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> paragraphs = [];
  final List<String> lines = [];
  final List<String> words = [];

  ReadText read = ReadText.Paragraph;
  @override
  void initState() {
    super.initState();
    getCameraPermission();
  }

  File? imageFile;

  Widget _buildParagraph() => Expanded(
        child: ListView(
            children: paragraphs
                .map((e) => Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        e,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ))
                .toList()),
      );
  Widget _buildLines() => Expanded(
        child: ListView(
            children: lines
                .map((e) => Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        e,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ))
                .toList()),
      );
  Widget _buildWords() => Expanded(
        child: SingleChildScrollView(
          child: Wrap(
              children: lines
                  .map((e) => Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          e,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ))
                  .toList()),
        ),
      );

  Widget _buildSelectorButton(ReadText read, placeholder) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: this.read == read ? Colors.purple : Colors.grey[800]),
          onPressed: () {
            setState(() {
              this.read = read;
            });
          },
          child: Text(placeholder),
        ),
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recognize Text')),
      body: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: getImageFromCamera,
                    child: const Text('Pick Image')),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSelectorButton(ReadText.Paragraph, 'Paragraph'),
                  _buildSelectorButton(ReadText.Lines, 'Lines'),
                  _buildSelectorButton(ReadText.Words, 'Word'),
                ],
              ),
              if (read == ReadText.Paragraph) _buildParagraph(),
              if (read == ReadText.Lines) _buildLines(),
              if (read == ReadText.Words) _buildWords()
            ],
          )),
    );
  }

  getImageFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    imageFile = File(image!.path);
    readTextFromImage();
  }

  readTextFromImage() async {
    if (imageFile != null) {
      final textDetecor = GoogleMlKit.vision.textDetector();

      final inputImageFile = InputImage.fromFile(imageFile!);

      RecognisedText recognisedText =
          await textDetecor.processImage(inputImageFile);

      List<TextBlock> textBlocks = recognisedText.blocks;

      paragraphs.clear();
      lines.clear();
      words.clear();
      for (var textBlock in textBlocks) {
        // we are getting paragraphs in text block

        String paragraph = textBlock.text;
        paragraphs.add(paragraph);
        for (TextLine line in textBlock.lines) {
          // we are getting line of every paragraph
          lines.add(line.text);

          for (TextElement element in line.elements) {
            // We are getting words from lines
            words.add(element.text);
          }
        }
      }
      setState(() {});
    }
  }

  getCameraPermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      Permission.photos.request();
    }
  }
}

enum ReadText { Paragraph, Lines, Words }
