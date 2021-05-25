import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/app_const.dart';
import 'package:facepunch/models/user_model.dart';
import 'package:facepunch/widgets/dialogs.dart';
import '../../../widgets/face_painter.dart';
import '../../../widgets/utils.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class FacePunchScreen extends StatefulWidget {
  @override
  _FacePunchScreenState createState() => _FacePunchScreenState();
}

class _FacePunchScreenState extends State<FacePunchScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(FaceDetectorOptions(
    mode: FaceDetectorMode.fast,
    enableLandmarks: true,
    enableClassification: true,
    enableContours: true,
    enableTracking: true,
  ));
  List<Face> faces;
  CameraController cameraController;
  CameraLensDirection _direction = CameraLensDirection.front;
  ImageRotation rotation;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  bool _isDetecting = false;
  bool hasError = false;
  String _photoPath="";
  bool _isCameraAllowed = false;

  @override
  void initState() {
    super.initState();
    cameraPermission().whenComplete((){
      _initializeCamera();
    });
  }

  Future cameraPermission()async{
    final status = await Permission.camera.status;
    if(status.isGranted){
      setState(() {_isCameraAllowed = true;});
    }else{
      Permission.camera.request().then((status){
        if(status.isGranted){setState(() {_isCameraAllowed = true;});}
      });
    }
  }

  _initializeCamera() async {
    try{
      if(_isCameraAllowed){
        CameraDescription description = await getCamera(_direction);
        rotation = rotationIntToImageRotation(
          description.sensorOrientation,
        );
        cameraController = CameraController(
          description,
          Platform.isIOS? ResolutionPreset.low: ResolutionPreset.high,
          enableAudio: false,
        );
        await cameraController.initialize();
        await initDetectFace();
      }else{
        showMessage(S.of(context).allowFacePunchToTakePictures);
      }
    }on CameraException catch(e){
      print(e);
      showMessage(e.toString());
    }
  }

  Future<void> initDetectFace()async{
    try{
      if(cameraController.value.isStreamingImages)return;
      cameraController.startImageStream((CameraImage image) {
        if (_isDetecting || !mounted) return;
        _isDetecting = true;
        detect(image, FirebaseVision.instance.faceDetector().processImage, rotation)
            .then((dynamic result) {
          setState(() {faces = result;});
          _isDetecting = false;
        },
        ).catchError((e) {print(e);_isDetecting = false;},);
      }).catchError((e){print(e);showMessage(e.toString());});
    }on CameraException catch(e){
      print(e);
      showMessage(e.toString());
    }
  }

  Future<void> cameraClose()async{
    try{
      if (cameraController!=null) {
        await cameraController.stopImageStream();
        await faceDetector.close();
        await Future.delayed(Duration(milliseconds: 100));
        await cameraController?.dispose();
      }
    }on CameraException catch(e){
      print(e);
      showMessage(e.toString());
    }
  }


  showMessage(String message){
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          action: SnackBarAction(onPressed: (){},label: S.of(context).close,textColor: Colors.white,),
        )
    );
  }

  Widget faceRect() {
    if (faces == null || cameraController == null || !cameraController.value.isInitialized) {
      return SizedBox();
    }
    CustomPainter painter;
    final Size imageSize = Size(cameraController.value.previewSize.height, cameraController.value.previewSize.width,);
    if (faces is! List<Face>) return SizedBox();
    painter = FaceDetectorPainter(imageSize, faces);
    return CustomPaint(painter: painter,);
  }

  Future<void> takePhoto() async {
    try {
      if (!cameraController.value.isInitialized) {
        return null;
      }
      if (cameraController.value.isTakingPicture) {
        return ;
      }
      if(faces==null || faces.isEmpty){
        showMessage(S.of(context).thereIsNotAnyFaces);
        return null;
      }
      if(cameraController.value.isStreamingImages){
        await cameraController.stopImageStream();
      }
      await Future.delayed(new Duration(milliseconds: 100));
      XFile file = await cameraController.takePicture();
      print(file.path);
      setState(() {_photoPath = file.path;});
      await punchWithFace(file.path);
    } on CameraException catch (e) {
      print(e);
    } catch(e){
      print(e);
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      showMessage(S.of(context).locationPermissionDenied);
      return null;
    }
    if (permission == LocationPermission.denied) {
      await showLocationPermissionDialog(context);
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        showMessage(S.of(context).locationPermissionDenied);
        return null;
      }
    }
    return await Geolocator.getCurrentPosition();
  }


  punchWithFace(String path)async{
    try{
      Position currentPosition = await _determinePosition();
      String base64Image = base64Encode(File(path).readAsBytesSync());
      var result = await context.read<UserModel>().punchWithFace(
          photo: base64Image,
          latitude: currentPosition?.latitude,
          longitude: currentPosition?.longitude
      );
      if(result is String){
        showMessage(result);
      }else{
        User employee = User.fromJson(result['employee']);
        Punch punch = Punch.fromJson(result['punch']);
        await showWelcomeDialog("${employee.firstName} ${employee.lastName}", punch.punch=="In");
        await initDetectFace();
        setState(() {_photoPath="";});
        _btnController.reset();
      }
    }catch(e){
      print("[EmployeeLogin.punchWithFace] $e");
      showMessage(e.toString());
    }
  }

  showWelcomeDialog(String userName, bool isPunchIn)async{
    await showDialog(
      context: context,
      builder: (_context){
        Future.delayed(Duration(seconds: 3)).whenComplete((){
          try{
            Navigator.of(_context).pop();
          }catch(e){
            print(e);
          }
        });
        return Align(
          alignment: Alignment.center,
          child: AnimatedContainer(
            height: MediaQuery.of(context).size.height*0.25,
            width: MediaQuery.of(context).size.width-80,
            duration: const Duration(milliseconds: 300),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Material(
                color: isPunchIn?Colors.green:Colors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(isPunchIn?S.of(context).welcome:S.of(context).bye,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("$userName",style: TextStyle(fontSize: 25),textAlign: TextAlign.center,),
                    ),
                  ],
                ),
                type: MaterialType.card,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final deviceRatio = MediaQuery.of(context).size.aspectRatio;
    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: ()async{
          await cameraClose();
          return true;
        },
        child: Stack(
          children: [
            _photoPath.isNotEmpty?
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: Image.file(
                File(_photoPath),
                fit: BoxFit.cover,
                width: width,
                height: height,
              ),
            ):
            (cameraController!=null && cameraController.value.isInitialized)?Transform.scale(
                scale: cameraController.value.aspectRatio/deviceRatio,
                child: Center(
                    child: AspectRatio(
                        aspectRatio: cameraController.value.aspectRatio,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CameraPreview(cameraController),
                            Platform.isIOS? faceRect():
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: faceRect(),
                            )
                          ],
                        )
                    )
                )
            ):Center(child: CircularProgressIndicator(),),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: RoundedLoadingButton(
                child: Text(_photoPath.isEmpty?S.of(context).takePicture.toUpperCase():S.of(context).tryAgain,
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),
                ),
                controller: _btnController,
                width: width/2,
                onPressed: ()async{
                  if(_photoPath.isEmpty){
                    await takePhoto();
                    _btnController.reset();
                  }else{
                    await initDetectFace();
                    setState(() {_photoPath="";});
                    _btnController.reset();
                  }
                },
                height: 40,
                color: Colors.black87,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top+30,
              right: 0,
              child: RaisedButton(
                onPressed: ()async{
                  await cameraClose();
                  Navigator.pop(context);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: CircleBorder(),
                padding: EdgeInsets.zero,
                color: Colors.black87,
                child: Icon(Icons.close,color: Color(primaryColor),),
              ),
            )
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}