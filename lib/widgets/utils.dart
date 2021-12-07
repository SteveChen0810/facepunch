import 'dart:async';
import 'dart:math' as math;
import 'package:convert/convert.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/app_const.dart';
import '/lang/l10n.dart';
import 'face_painter.dart';

typedef HandleDetection = Future<List<Face>> Function(InputImage image);

class Tools {
  static Future<void> playSound()async{
    try{
      AssetsAudioPlayer().open(
        Audio("assets/sound/sound.mp3"),
        autoStart: true,
      );
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
      print('$log');
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/${AppConst.LOG_FILE_PREFIX}${DateTime.now().toString().split(' ')[0]}');
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

  static Future<bool> checkCameraPermission()async{
    try{
      var status = await Permission.camera.status;
      if(status.isGranted){
        return true;
      }else{
        status = await Permission.camera.request();
        if(status.isGranted){
          return true;
        }
      }
    } on PlatformException catch(e){
      consoleLog('[Tools.getCameraPermission]$e');
    }catch(e){
      consoleLog('[Tools.getCameraPermission]$e');
    }
    return false;
  }

  static Future<bool> checkLocationPermission()async{
    try{
      var status = await Permission.location.status;
      if(status.isGranted){
        return true;
      }else{
        status = await Permission.location.request();
        if(status.isGranted){
          return true;
        }
      }
    }on PlatformException catch(e){
      consoleLog('[Tools.checkLocationPermission]$e');
    }catch(e){
      consoleLog('[Tools.checkLocationPermission]$e');
    }
    return false;
  }

  static String generateRandomString(int length){
    const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    math.Random r = math.Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }

  static void setupFirebaseNotification(Function onMessage)async{
    var status = await Permission.notification.status;
    if(!status.isGranted){
      await Permission.notification.request();
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onMessage(message);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message){
      if(message != null)onMessage(message);
    });

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<CameraDescription> getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
          (List<CameraDescription> cameras) => cameras.firstWhere(
            (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

  static Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    planes.forEach((Plane plane) => allBytes.putUint8List(plane.bytes));
    return allBytes.done().buffer.asUint8List();
  }

  static InputImageData buildMetaData(
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

  static Future<List<Face>> detect(
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

  static InputImageRotation rotationIntToImageRotation(int rotation) {
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

  static Widget faceRect(CameraController cameraController, List<Face>? faces, double strokeWidth) {
    try{
      if(faces == null || !(faces is List<Face>)) return SizedBox();
      final Size imageSize = Size(cameraController.value.previewSize!.height, cameraController.value.previewSize!.width,);
      CustomPainter painter = FaceDetectorPainter(imageSize, faces, strokeWidth);
      if(Platform.isIOS){
        return CustomPaint(painter: painter,);
      }else{
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi),
          child: CustomPaint(painter: painter,),
        );
      }
    }catch(e){
      Tools.consoleLog("[Tools.faceRect.err] $e");
      return SizedBox();
    }
  }

  static Future<String> getPunchKey()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? punchKey = prefs.getString('face_punch_key');
    if(punchKey == null){
      punchKey = Tools.generateRandomString(20);
      prefs.setString('face_punch_key', punchKey);
    }
    return punchKey;
  }
}
