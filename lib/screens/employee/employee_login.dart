import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:facepunch/widgets/dialogs.dart';
import '../../models/company_model.dart';
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
  Company selectedCompany;
  String userName = "";

  @override
  void initState() {
    super.initState();
    cameraPermission();
  }


  @override
  void dispose() {
    cameraClose();
    super.dispose();
  }

  cameraPermission()async{
    final status = await Permission.camera.status;
    if(status.isGranted){
      setState(() {
        _isCameraAllowed = true;
      });
    }else{
      Permission.camera.request().then((status){
        if(status.isGranted){
          setState(() {_isCameraAllowed = true;});
        }
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
            Platform.isIOS? ResolutionPreset.medium
                : ResolutionPreset.high,
            enableAudio: false,
        );
        await cameraController.initialize();
        await initDetectFace();
      }else{
        widget.showMessage("Allow FACE PUNCH to take pictures.");
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
        widget.showMessage("There is not any faces.");
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
      String result = await context.read<UserModel>().loginWithFace(selectedCompany.id, base64Image);
      if(result==null){
        final user = context.read<UserModel>().user;
        bool check = await pinCodeCheckDialog(user.pin, context);
        if(check){
          if(mounted){setState(() {_pageIndex = 2; userName = "${user.firstName} ${user.lastName}";});}
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmployeeHomePage()));
        }else{
          widget.showMessage("PIN Code is not correct.");
        }
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
    final size = MediaQuery.of(context).size.width*0.6;
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
                  child: _photoPath.isEmpty?(cameraController==null || !cameraController.value.isInitialized)?Center(child: CircularProgressIndicator(),):
                  ClipRect(
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
                  ):
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: Image.file(
                      File(_photoPath),
                      fit: BoxFit.cover,
                    ),
                  )
                ),
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Image.asset(
                    "assets/images/overlay.png",
                    width: size,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          RoundedLoadingButton(
            child: Text(_photoPath.isEmpty?"TAKE A PICTURE":"TRY AGAIN",
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
                if(!result)_btnController.reset();
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
      final size = MediaQuery.of(context).size.width*0.6;
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
                if(selectedCompany!=null){
                  _initializeCamera();
                  setState(() {_pageIndex=1;});
                }else{
                  widget.showMessage("Choose your company");
                }
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.black87,
              child: Text("FACE SCAN LOGIN",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
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
        Text("Welcome",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
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
    List<Company> companies = context.watch<CompanyModel>().companies;
    if(selectedCompany!=null){
      selectedCompany = companies.firstWhere((c) => c.id==selectedCompany.id,orElse: ()=>null);
    }
    return Container(
      width: width,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text("Employee Sign In",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 8,),
          Column(
            children: [
              Text("Select your Company",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
              SizedBox(height: 4,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black87)
                ),
                height: 40,
                child: DropdownButton<Company>(
                  items: companies.map((Company value) {
                    return DropdownMenuItem<Company>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 8),
                        child: Text(value.name),
                      ),
                    );
                  }).toList(),
                  underline: SizedBox(),
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.black87),
                  hint: Text("Choose Company"),
                  isExpanded: true,
                  onChanged: (v) {
                    setState(() {
                      selectedCompany = v;
                    });
                  },
                  value: selectedCompany,
                ),
              )
            ],
          ),
          SizedBox(height: 10,),
          Expanded(
              child: mainWidget()
          ),
          SizedBox(height: 5,),
        ],
      ),
    );
  }

}