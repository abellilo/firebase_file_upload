import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  Future selectFile()async{
    final result = await FilePicker.platform.pickFiles();
    if(result == null) return;

    setState((){
      pickedFile = result.files.first;
    });
  }
  Future uploadFile()async{
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete((){});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    setState(() {
      uploadTask = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(pickedFile != null)
            Expanded(
                child: Container(
                    color: Colors.blue[100],
                    child: Center(
                        child: Image.file(
                            File(pickedFile!.path!),
                            width: double.infinity,
                            fit: BoxFit.cover
                        )
                    )
                )
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: (){
              selectFile();
            }, child: Text("Select File")),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: (){
              uploadFile();
            }, child: Text("Upload File")),
            buildProgress(),
          ],
        ),
      ),
    );
  }

  Widget buildProgress ()=> StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot){
        if(snapshot.hasData){
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children:[
                  LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey,
                      color: Colors.green
                  ),
                  Center(
                      child: Text(
                          '${(100 * progress).roundToDouble()}%',
                          style: const TextStyle(
                            color: Colors.white,
                          )
                      )
                  )
                ],
              )
          );

        }else{
          return const SizedBox(height:50);
        }
      }
  );

}
