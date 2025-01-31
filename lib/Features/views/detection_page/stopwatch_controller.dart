import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dtetected_page.dart';

class StopwatchScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const StopwatchScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final StopwatchController controller =
        Get.put(StopwatchController(cameras: cameras));//This creates an instance of StopwatchController and passes the camera list (cameras) as a parameter.

    return SafeArea(//This code is responsible for displaying the camera preview correctly on the screen while maintaining the aspect ratio.
      child: Scaffold(
        body: Stack(
          children: [
            // Full-Screen Camera Preview with Correct Aspect Ratio
            GetBuilder<StopwatchController>(//GetBuilder<StopwatchController> is used to rebuild only the necessary parts of the UI when the state in StopwatchController changes.
              builder: (controller) {
                if (controller.cameraController.value.isInitialized) {//Checks if the camera is ready to use.If not initialized, it will show a loading indicator.
                  final previewSize =
                      controller.cameraController.value.previewSize!;//Retrieves the size of the camera preview.previewSize.width and previewSize.height tell us the camera's resolution.
                  final screenSize = MediaQuery.of(context).size;//Retrieves the screen width and height of the device.

                  // Calculate the aspect ratio and scale
                  final previewAspectRatio =
                      previewSize.height / previewSize.width;
                  final screenAspectRatio =
                      screenSize.width / screenSize.height;

                  return Transform.rotate(
                    angle: Platform.isAndroid
                        ? 3.1416 / 2
                        : 0, // Maintain Android rotation
                    child: AspectRatio(
                      aspectRatio: previewAspectRatio,
                      child: OverflowBox(
                        maxWidth: screenAspectRatio > previewAspectRatio
                            ? screenSize.width
                            : screenSize.height * previewAspectRatio,
                        maxHeight: screenAspectRatio > previewAspectRatio
                            ? screenSize.width / previewAspectRatio
                            : screenSize.height,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: previewSize.width,
                            height: previewSize.height,
                            child: CameraPreview(controller.cameraController),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            // Overlay for Stopwatch and Buttons
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(() => Text(
                        'Elapsed Time: ${controller.elapsedTime.value}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 2, color: Colors.black),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isRecording.value
                            ? null
                            : controller.startRecording,
                        child: const Text('Click to Start'),
                      )),
                  Obx(() => controller.isRecording.value
                      ? ElevatedButton(
                          onPressed: controller.stopRecording,
                          child: const Text('Stop Recording'),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StopwatchController extends GetxController {
  final List<CameraDescription> cameras;
  late CameraController cameraController;
  late PoseDetector poseDetector;
  final stopwatch = Stopwatch();
  final isRecording = false.obs;
  final elapsedTime = '00:00'.obs;

  StopwatchController({required this.cameras});

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
    poseDetector = PoseDetector(options: PoseDetectorOptions());
  }

  Future<void> initializeCamera() async {
    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high, // Use high resolution for better preview quality
      enableAudio: false,
    );

    await cameraController.initialize();
    await cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
    update();
  }

  void startRecording() {
    if (!cameraController.value.isInitialized) return;

    isRecording.value = true;
    stopwatch.start();
    _updateElapsedTime();
    _detectMotion();
  }

  void stopRecording() {
    isRecording.value = false;
    stopwatch.stop();
    stopwatch.reset();
    update();
  }

  void _updateElapsedTime() {
    if (isRecording.value) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (isRecording.value) {
          final elapsed = stopwatch.elapsed;
          elapsedTime.value =
              '${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}:'
              '${((elapsed.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0')}';
          _updateElapsedTime();
        }
      });
    }
  }

  Future<void> _detectMotion() async {
    while (isRecording.value && cameraController.value.isInitialized) {
      try {
        final image = await cameraController.takePicture();//ca[tures image]
        final inputImage = InputImage.fromFilePath(image.path);//takes to ml kit the captured img
        final poses = await poseDetector.processImage(inputImage);//ml kit analysing for human pose
        if (poses.isNotEmpty) {
          final elapsed = elapsedTime.value; // Capture the elapsed time
          stopRecording();
          Get.to(() => DetectionResultScreen(
                imagePath: image.path,
                elapsedTime: elapsed,
              ));
          debugPrint('Motion detected! Photo saved.');
          return;
        }
      } catch (e) {
        debugPrint('Error during motion detection: $e');
      }
    }
  }

  @override
  void onClose() {
    cameraController.dispose();
    poseDetector.close();
    stopwatch.stop();
    super.onClose();
  }
}
