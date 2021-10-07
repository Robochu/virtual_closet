import 'all_camera.dart';

class CameraScreen {

  void callScreen(String name) async{

    if (name == "camera"){
      print("In camera");
        getCamera().then((CameraDescription camera) {
          TakePictureScreen(camera:camera);
        });
    } else if (name == "gallery") {

    }
  }

  Future<CameraDescription> getCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    List<CameraDescription> cameras = await availableCameras();
    return cameras.first;
  }
}