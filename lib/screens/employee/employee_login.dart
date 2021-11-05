import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:facepunch/lang/l10n.dart';
import 'package:facepunch/models/company_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:wakelock/wakelock.dart';
import '../../models/user_model.dart';
import '../../screens/employee/employee_home.dart';
import '../../models/app_const.dart';
import '../../widgets/face_painter.dart';
import '../../widgets/utils.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';

class EmployeeLogin extends StatefulWidget {

  final Function showMessage;
  EmployeeLogin({this.showMessage});

  @override
  _EmployeeLoginState createState() => _EmployeeLoginState();
}

class _EmployeeLoginState extends State<EmployeeLogin> {
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
  String _photoPath="";
  bool _isCameraAllowed = false;
  int _pageIndex = 0;
  String userName = "";

  @override
  void initState() {
    super.initState();
    cameraPermission();
    Wakelock.enable();
  }

  @override
  void dispose() {
    cameraClose();
    Wakelock.disable();
    super.dispose();
  }

  cameraPermission()async{
    var status = await Permission.camera.status;
    if(status.isGranted){
      setState(() {
        _isCameraAllowed = true;
      });
    }else{
      status = await Permission.camera.request();
      if(status.isGranted){
        setState(() {_isCameraAllowed = true;});
      }
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
            Platform.isIOS? ResolutionPreset.medium
                : ResolutionPreset.high,
            enableAudio: false,
        );
        await cameraController.initialize();
        await initDetectFace();
      }else{
        widget.showMessage(S.of(context).allowFacePunchToTakePictures);
      }
    }on CameraException catch(e){
      print(e);
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
      }).catchError((e){print(e);widget.showMessage(e.toString());});
    }on CameraException catch(e){
      print(e);
      widget.showMessage(e.toString());
    }
  }

  Future<void> cameraClose()async{
    try{
      if (cameraController!=null) {
        await Future.delayed(new Duration(milliseconds: 100));
        await cameraController?.dispose();
      }
    }on CameraException catch(e){
      print(e);
      widget.showMessage(e.toString());
    }
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
        widget.showMessage(S.of(context).thereIsNotAnyFaces);
        return null;
      }
      if(cameraController.value.isStreamingImages){
        await cameraController.stopImageStream();
      }
      await Future.delayed(new Duration(milliseconds: 100));
      XFile file = await cameraController.takePicture();
      print(file.path);
      setState(() {_photoPath = file.path;});
    } on CameraException catch (e) {
      print(e);
    }
  }

  Future<bool> loginWithFace(String path)async{
    try{
      String base64Image = base64Encode(File(path).readAsBytesSync());
      String result = await context.read<UserModel>().loginWithFace(base64Image);
      if(result==null){
        return true;
      }else{
        widget.showMessage(result);
      }
    }catch(e){
      print("[EmployeeLogin.loginWithFace] $e");
      widget.showMessage(e.toString());
    }
    return false;
  }

  Widget faceRect() {
    try{
      if (faces == null || cameraController == null || !cameraController.value.isInitialized) {
        return SizedBox();
      }
      CustomPainter painter;
      final Size imageSize = Size(cameraController.value.previewSize.height, cameraController.value.previewSize.width,);
      if (faces is! List<Face>) return SizedBox();
      painter = FaceDetectorPainter(imageSize, faces);
      return CustomPaint(painter: painter,);
    }catch(e){
      print("[EmployeeLogin.faceRect] $e");
      return SizedBox();
    }
  }

  Widget loginWithFaceWidget(){
    final size = MediaQuery.of(context).size.width*0.7;
    try{
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size,
                  height: size,
                  padding: EdgeInsets.all(8),
                  child: _photoPath.isEmpty
                    ?(cameraController==null || !cameraController.value.isInitialized)
                    ?Center(child: CircularProgressIndicator(),)
                    :ClipRect(
                      child: Transform.scale(
                          scale: 1/cameraController.value.aspectRatio,
                          child: Center(
                              child: AspectRatio(
                                  aspectRatio: cameraController.value.aspectRatio,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CameraPreview(cameraController),
                                      Platform.isIOS?faceRect():
                                      Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.rotationY(math.pi),
                                        child: faceRect(),
                                      )
                                    ],
                                  )
                              )
                          )
                      ),
                    )
                    :Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Image.file(
                        File(_photoPath),
                        fit: BoxFit.cover,
                    ),
                  )
                ),
                Image.asset(
                  "assets/images/overlay.png",
                  width: size,
                  height: size,
                  fit: BoxFit.fill,
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          RoundedLoadingButton(
            child: Text(_photoPath.isEmpty?S.of(context).takePicture.toUpperCase():S.of(context).tryAgain.toUpperCase(),
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),
            ),
            controller: _btnController,
            width: size,
            onPressed: ()async{
              if(_photoPath.isEmpty){
                bool result = false;
                await takePhoto();
                if(_photoPath!=null && _photoPath.isNotEmpty){
                  result = await loginWithFace(_photoPath);
                }
                _btnController?.reset();
                if(result){
                  final user = context.read<UserModel>().user;
                  if(mounted){setState(() {_pageIndex = 2; userName = "${user.getFullName()}";});}
                  await context.read<CompanyModel>().getMyCompany(user.companyId);
                  if(mounted)Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmployeeHomePage()));
                }
              }else{
                await initDetectFace();
                setState(() {_photoPath="";});
                _btnController.reset();
              }
            },
            height: 40,
            color: Colors.black87,
          )
        ],
      );
    }catch(e){
      print("[EmployeeLogin.loginWithFaceWidget] $e");
      return SizedBox();
    }
  }

  Widget mainWidget(){
    if(_pageIndex==0){
      final size = MediaQuery.of(context).size.width*0.7;
      return Column(
        children: [
          Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/images/overlay.png",width: size,),
                  Image.asset("assets/images/person.png",width: size,),
                ],
              )
          ),
          SizedBox(height: 10,),
          ButtonTheme(
            minWidth: size,
            height: 40,
            splashColor: Color(primaryColor),
            child: RaisedButton(
              onPressed: (){
                _initializeCamera();
                setState(() {_pageIndex=1;});
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.black87,
              child: Text(S.of(context).faceScanLogin,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
            ),
          )
        ],
      );
    }
    if(_pageIndex==1){
      return loginWithFaceWidget();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(S.of(context).welcome,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
        Text(userName,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(S.of(context).employeeSignIn,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 10,),
          Expanded(
              child: mainWidget()
          ),
        ],
      ),
    );
  }

}