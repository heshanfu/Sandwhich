import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:simple_share/simple_share.dart';

class ImageReviewPage extends StatefulWidget {
  final String imagePath;

  const ImageReviewPage({Key key, @required this.imagePath}) : super(key: key);

  @override
  _ImageReviewPageState createState() => _ImageReviewPageState();
}

class _ImageReviewPageState extends State<ImageReviewPage> {
  String _res = "";
  List classes;
  bool sandwich;

  void initState() {
    super.initState();
    initModel();
  }

  initModel() async {
    _res = await Tflite.loadModel(
      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/ssd_mobilenet.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = File(widget.imagePath);

    final style = TextStyle(
      color: Colors.purpleAccent,
      fontSize: 36,
      fontWeight: FontWeight.w800,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: FileImage(image), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: FutureBuilder(
                  future: Tflite.detectObjectOnImage(
                    path: widget.imagePath,
                    model: "SSDMobileNet",
                    numResultsPerClass: 1,
                    threshold: 0.3,
                    imageStd: 255.0,
                    blockSize: 16,
                  ),
                  initialData: [],
                  builder: (context, snapshot) {
                    List recs = snapshot.data;
                    if (recs == null ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }
                    final classes =
                        recs.map((rec) => rec["detectedClass"]).toList();
                    print(classes);

                    return Column(
                      children: <Widget>[
                        classes.contains("sandwich")
                            ? Text(
                                "SANDWICH!",
                                style: style,
                              )
                            : Text(
                                "not sandwich",
                                style: style,
                              ),
                        Text(
                          classes.join(", "),
                          style: style,
                        )
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.purpleAccent,
                        size: 48,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: () => {},
                      child: Text(
                        "MM",
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 36),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => SimpleShare.share(uri: widget.imagePath),
        tooltip: 'Return to Camera',
        child: Icon(Icons.file_upload),
      ),
    );
  }
}
