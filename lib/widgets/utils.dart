import 'dart:async';
import 'package:convert/convert.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:path_provider/path_provider.dart';
import '/lang/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

typedef HandleDetection = Future<List<Face>> Function(InputImage image);

Future<CameraDescription> getCamera(CameraLensDirection dir) async {
  return await availableCameras().then(
        (List<CameraDescription> cameras) => cameras.firstWhere(
          (CameraDescription camera) => camera.lensDirection == dir,
    ),
  );
}

Uint8List concatenatePlanes(List<Plane> planes) {
  final WriteBuffer allBytes = WriteBuffer();
  planes.forEach((Plane plane) => allBytes.putUint8List(plane.bytes));
  return allBytes.done().buffer.asUint8List();
}

InputImageData buildMetaData(
    CameraImage image,
    InputImageRotation rotation,
    ) {
  return InputImageData(
    inputImageFormat: InputImageFormatMethods.fromRawValue(image.format.raw) ?? InputImageFormat.NV21,
    size: Size(image.width.toDouble(), image.height.toDouble()),
    imageRotation: rotation,
    planeData: image.planes.map((Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList()
  );
}

Future<List<Face>> detect(
    CameraImage image,
    HandleDetection handleDetection,
    InputImageRotation rotation,
    ) async {
  return handleDetection(
    InputImage.fromBytes(
      bytes: concatenatePlanes(image.planes),
      inputImageData: buildMetaData(image, rotation),
    ),
  );
}

InputImageRotation rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 0:
      return InputImageRotation.Rotation_0deg;
    case 90:
      return InputImageRotation.Rotation_90deg;
    case 180:
      return InputImageRotation.Rotation_180deg;
    default:
      assert(rotation == 270);
      return InputImageRotation.Rotation_270deg;
  }
}

class Tools {
  static Future<void> playSound()async{
    try{
      // AssetsAudioPlayer().open(
      //   Audio("assets/sound/sound.mp3"),
      //   autoStart: true,
      // );
    }catch(e){
      Tools.consoleLog('[Tools.playSound]$e');
    }
  }

  static showErrorMessage(BuildContext context, String message){
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          action: SnackBarAction(onPressed: (){}, label: S.of(context).close, textColor: Colors.white,),
        )
    );
  }

  static showSuccessMessage(BuildContext context, String message){
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          action: SnackBarAction(onPressed: (){}, label: S.of(context).close, textColor: Colors.white,),
        )
    );
  }

  static Future<void> consoleLog(String log)async{
    try{
      print(log);
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/${AppConst.LOG_FILE_NAME}');
      logFile.writeAsString('\n[${DateTime.now()}]$log', mode: FileMode.writeOnlyAppend);
    }catch(e){
      print('[consoleLog]$e');
    }
  }

  static Future<DateTime?> pickTime(BuildContext context, String initTime)async{
    DateTime initDate = DateTime.parse(initTime);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initDate.hour, minute: initDate.minute),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if(picked!=null){
      return DateTime(initDate.year, initDate.month, initDate.day, picked.hour, picked.minute, initDate.second);
    }
    return null;
  }

  static String? getNFCIdentifier(Map<String, dynamic> data){
    try{
      Uint8List? identifier;
      data.forEach((k1, v1) {
        if(k1 == 'identifier' && v1 is Uint8List){
          identifier = v1;
        }else if(v1 is Map){
          v1.forEach((k2, v2) {
            if(k2 == 'identifier' && v2 is Uint8List){
              identifier = v2;
            }else if(v2 is Map){
              v2.forEach((k3, v3) {
                if(k3 == 'identifier' && v3 is Uint8List){
                  identifier = v3;
                }
              });
            }
          });
        }
      });
      print(identifier);
      if(identifier == null) return null;
      return hex.encode(identifier!);
    }catch(e){
      consoleLog('[Tools.getNFCIdentifier]$e');
    }
  }
}
