import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import '/lang/l10n.dart';
import '/models/app_const.dart';
import '/models/user_model.dart';
import '/models/work_model.dart';
import 'select_call_schedule.dart';
import 'select_project_task.dart';
import '/widgets/dialogs.dart';
import '/widgets/utils.dart';

class FacePunchScreen extends StatefulWidget {

  @override
  _FacePunchScreenState createState() => _FacePunchScreenState();
}

class _FacePunchScreenState extends State<FacePunchScreen>{

  final FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
    mode: FaceDetectorMode.fast,
    enableLandmarks: true,
    enableClassification: true,
    enableContours: true,
    enableTracking: true,
  ));
  List<Face>? faces;
  CameraController? cameraController;
  CameraLensDirection _direction = CameraLensDirection.front;
  InputImageRotation? rotation;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  bool _isDetecting = false;
  bool hasError = false;
  String _photoPath="";
  bool _isCameraAllowed = false;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    Tools.checkCameraPermission().then((value){
      setState(() {_isCameraAllowed = value;});
      _initializeCamera();
      _determinePosition();
    });
    Wakelock.enable();
  }


  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  _initializeCamera({CameraDescription? description}) async {
    try{
      if(_isCameraAllowed){
        if(description == null){
          description = await Tools.getCamera(_direction);
          if(!mounted)return;
        }
        rotation = Tools.rotationIntToImageRotation(description.sensorOrientation);
        cameraController = CameraController(
          description,
          Platform.isIOS? ResolutionPreset.low: ResolutionPreset.high,
          enableAudio: false,
        );
        await cameraController!.initialize();
        if(!mounted)return;
        await initDetectFace();
        if(!mounted)return;
      }else{
        Tools.showErrorMessage(context, S.of(context).allowFacePunchToTakePictures);
      }
    }on CameraException catch(e){
      Tools.consoleLog('[FacePunchScreen._initializeCamera]$e');
      Tools.showErrorMessage(context, e.toString());
    }
  }

  Future<void> initDetectFace()async{
    try{
      if(cameraController!.value.isStreamingImages)return;
      cameraController!.startImageStream((CameraImage image) {
        if (_isDetecting || !mounted) return;
        _isDetecting = true;
        Tools.detect(image, GoogleMlKit.vision.faceDetector().processImage, rotation!).then((dynamic result) {
          setState(() {faces = result;});
          _isDetecting = false;
        }).catchError((e) {
          Tools.consoleLog('[FacePunch.initDetectFace.detect]$e');
        _isDetecting = false;
        },);
      }).catchError((e){
        Tools.consoleLog('[FacePunch.initDetectFace.startImageStream]$e');
      Tools.showErrorMessage(context, e.toString());
      });
    }on CameraException catch(e){
      Tools.consoleLog('[FacePunch.initDetectFace]$e');
      Tools.showErrorMessage(context, e.toString());
    }on PlatformException catch(e){
      Tools.consoleLog('[FacePunch.initDetectFace]$e');
      Tools.showErrorMessage(context, e.toString());
    }
  }

  Future<void> cameraClose()async{
    try{
      if (cameraController!=null) {
        if(cameraController!.value.isStreamingImages){
          await cameraController!.stopImageStream();
        }
        await faceDetector.close();
        await Future.delayed(Duration(milliseconds: 100));
        await cameraController?.dispose();
      }
    }on CameraException catch(e){
      Tools.consoleLog('[FacePunch.cameraClose]$e');
      Tools.showErrorMessage(context, e.toString());
    }on PlatformException catch(e){
      Tools.consoleLog('[FacePunch.cameraClose]$e');
      Tools.showErrorMessage(context, e.toString());
    }
  }

  Future<void> takePhoto() async {
    try {
      if (!cameraController!.value.isInitialized) {
        return null;
      }
      if (cameraController!.value.isTakingPicture) {
        return ;
      }
      if(faces==null || faces!.isEmpty){
        Tools.showErrorMessage(context, S.of(context).thereIsNotAnyFaces);
        return null;
      }
      if(cameraController!.value.isStreamingImages){
        await cameraController!.stopImageStream();
      }
      await Future.delayed(Duration(milliseconds: 100));
      XFile file = await cameraController!.takePicture();
      setState(() {_photoPath = file.path;});
      await _punchWithFace(file.path);
      await File(file.path).delete().catchError((e){
        Tools.consoleLog('[FacePunch.takePhoto.delete]$e');
      });
    } on CameraException catch (e) {
      Tools.showErrorMessage(context, e.toString());
      Tools.consoleLog('[FacePunch.takePhoto]$e');
    } catch(e){
      Tools.showErrorMessage(context, e.toString());
      Tools.consoleLog('[FacePunch.takePhoto]$e');
    }
  }

  _determinePosition() async {
    Tools.checkLocationPermission().then((v){
      if(v){
        Geolocator.getCurrentPosition().then((value){currentPosition = value;}).catchError((e){
          Tools.consoleLog('[FacePunchScreen.getCurrentPosition]$e');
        });
      }else{
        Tools.showErrorMessage(context, S.of(context).locationPermissionDenied);
      }
    });
  }

  _punchWithFace(String path)async{
    try{
      Tools.playSound();
      String base64Image = base64Encode(File(path).readAsBytesSync());
      var result = await context.read<UserModel>().punchWithFace(
          photo: base64Image,
          latitude: currentPosition?.latitude,
          longitude: currentPosition?.longitude
      );
      if(result is String){
        Tools.showErrorMessage(context, result);
      }else{
        User employee = User.fromJson(result['employee']);
        Punch punch = Punch.fromJson(result['punch']);
        if(employee.type == 'call'){
          await _punchCallEmployee(employee, punch, result['calls']);
        }else if(employee.type == 'shop_daily'){
          await _punchShopDailyEmployee(employee, punch, result['schedules']);
        }else if(employee.type == 'shop_tracking'){
          await _punchShopTrackingEmployee(employee, punch, result['projects'], result['tasks']);
        }else if(employee.type == 'call_shop_daily'){
          await _punchCallShopDailyEmployee(employee, punch, result['schedules'], result['calls']);
        }else if(employee.type == 'call_shop_tracking'){
          await _punchCallShopTrackingEmployee(employee, punch, result['calls'], result['projects'], result['tasks']);
        }
        await initDetectFace();
        setState(() {_photoPath="";});
      }
    }catch(e){
      Tools.consoleLog("[EmployeeLogin.punchWithFace] $e");
      Tools.showErrorMessage(context, e.toString());
    }
  }

  Future<void> _punchCallEmployee(User employee, Punch punch, data)async{
    List<EmployeeCall> calls = [];
    for(var c in data){
      calls.add(EmployeeCall.fromJson(c));
    }
    if(calls.isEmpty){
      await showWelcomeDialog(
          userName: employee.getFullName(),
          isPunchIn: punch.punch == "In",
          context: context
      );
    }else{
      await Navigator.push(context, MaterialPageRoute(
          builder: (context)=>SelectCallScheduleScreen(
            calls: calls,
            employee: employee,
            punch: punch,
            schedules: [],
          )
      ));
    }
  }

  Future<void> _punchShopDailyEmployee(User employee, Punch punch, data)async{
    List<WorkSchedule> schedules = [];
    for(var s in data){
      schedules.add(WorkSchedule.fromJson(s));
    }
    if(schedules.isEmpty){
      await showWelcomeDialog(
          userName: employee.getFullName(),
          isPunchIn: punch.punch == "In",
          context: context
      );
    }else{
      await Navigator.push(context, MaterialPageRoute(
          builder: (context)=>SelectCallScheduleScreen(
            schedules: schedules,
            employee: employee,
            punch: punch,
            calls: [],
          )
      ));
    }
  }

  Future<void> _punchShopTrackingEmployee(User employee, Punch punch, pData, tData)async{
    List<Project> projects = [];
    for(var p in pData){
      projects.add(Project.fromJson(p));
    }
    List<ScheduleTask> tasks = [];
    for(var t in tData){
      tasks.add(ScheduleTask.fromJson(t));
    }
    if(projects.isNotEmpty && tasks.isNotEmpty){
      await Navigator.push(context, MaterialPageRoute(
          builder: (context)=>SelectProjectTask(
            employee: employee,
            projects: projects,
            tasks: tasks,
            punch: punch
          )
      ));
    }else{
      await showWelcomeDialog(
          userName: employee.getFullName(),
          isPunchIn: punch.punch == "In",
          context: context
      );
    }
  }

  Future<void> _punchCallShopDailyEmployee(User employee, Punch punch, sData, cData)async{
    List<WorkSchedule> schedules = [];
    for(var s in sData){
      schedules.add(WorkSchedule.fromJson(s));
    }
    List<EmployeeCall> calls = [];
    for(var c in cData){
      calls.add(EmployeeCall.fromJson(c));
    }
    if(schedules.isEmpty && calls.isEmpty){
      await showWelcomeDialog(
          userName: employee.getFullName(),
          isPunchIn: punch.punch == "In",
          context: context
      );
    }else{
      await Navigator.push(context, MaterialPageRoute(
          builder: (context)=>SelectCallScheduleScreen(
            schedules: schedules,
            employee: employee,
            punch: punch,
            calls: calls,
          )
      ));
    }
  }

  Future<void> _punchCallShopTrackingEmployee(User employee, Punch punch, cData, pData, tData)async{
    List<Project> projects = [];
    for(var p in pData){
      projects.add(Project.fromJson(p));
    }
    List<ScheduleTask> tasks = [];
    for(var t in tData){
      tasks.add(ScheduleTask.fromJson(t));
    }
    List<EmployeeCall> calls = [];
    for(var c in cData){
      calls.add(EmployeeCall.fromJson(c));
    }
    if(calls.isNotEmpty){
      await Navigator.push(context, MaterialPageRoute(builder: (context)=>SelectCallScheduleScreen(
        schedules: [],
        employee: employee,
        punch: punch,
        calls: calls,
      )));
    }else if(projects.isNotEmpty && tasks.isNotEmpty){
      await Navigator.push(context, MaterialPageRoute(builder: (context)=>SelectProjectTask(
          employee: employee,
          projects: projects,
          tasks: tasks,
          punch: punch
      )));
    } else{
      await showWelcomeDialog(
          userName: employee.getFullName(),
          isPunchIn: punch.punch == "In",
          context: context
      );
    }
  }

  Widget _body(){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Widget closeButton = Positioned(
      top: MediaQuery.of(context).padding.top+30,
      right: 0,
      child: MaterialButton(
        onPressed: ()async{
          await cameraClose();
          Navigator.pop(context);
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: CircleBorder(),
        padding: EdgeInsets.zero,
        color: Colors.black87,
        child: Icon(Icons.close, color: Color(primaryColor),),
      ),
    );
    Widget captureButton = Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: RoundedLoadingButton(
        child: Text(_photoPath.isEmpty?S.of(context).takePicture.toUpperCase():S.of(context).tryAgain,
          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),
        ),
        controller: _btnController,
        width: width-80,
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
    );

    if(_photoPath.isNotEmpty){
      return Stack(
        children: [
          Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: Image.file(
                File(_photoPath),
                fit: BoxFit.cover,
                width: width,
                height: height,
              ),
            ),
          ),
          closeButton,
          captureButton
        ],
      );
    }
    if(cameraController != null && cameraController!.value.isInitialized){
      var tmp = MediaQuery.of(context).size;
      final screenH = math.max(tmp.height, tmp.width);
      final screenW = math.min(tmp.height, tmp.width);
      tmp = cameraController!.value.previewSize!;
      final previewH = math.max(tmp.height, tmp.width);
      final previewW = math.min(tmp.height, tmp.width);
      final screenRatio = screenH / screenW;
      final previewRatio = previewH / previewW;

      return Stack(
        children: [
          ClipRRect(
            child: OverflowBox(
              maxHeight: screenRatio > previewRatio
                  ? screenH
                  : screenW / previewW * previewH,
              maxWidth: screenRatio > previewRatio
                  ? screenH / previewH * previewW
                  : screenW,
              child: CameraPreview(
                cameraController!,
                child: Tools.faceRect(cameraController!, faces)
              ),
            ),
          ),
          closeButton,
          captureButton
        ],
      );
    }
    return Stack(
      children: [
        Center(child: CircularProgressIndicator(),),
        closeButton,
        captureButton
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: ()async{
          await cameraClose();
          return true;
        },
        child: _body(),
      ),
      backgroundColor: Color(primaryColor),
      resizeToAvoidBottomInset: false,
    );
  }
}