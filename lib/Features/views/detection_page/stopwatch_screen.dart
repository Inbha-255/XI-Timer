import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path_provider/path_provider.dart';

class StopwatchScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const StopwatchScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final StopwatchController controller =
        Get.put(StopwatchController(cameras: cameras));

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Full-Screen Camera Preview
            GetBuilder<StopwatchController>(
              builder: (controller) {
                if (controller.cameraController.value.isInitialized) {
                  final size = MediaQuery.of(context).size;
                  final scale = size.aspectRatio *
                      controller.cameraController.value.aspectRatio;

                  return Transform.scale(
                    scale: scale < 1 ? 1 / scale : scale,
                    child: Center(
                      child: CameraPreview(controller.cameraController),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            // Overlay for Stopwatch and Buttons
            Positioned(
              top: 16,
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
  final elapsedTime = '00:00:00'.obs;

  StopwatchController({required this.cameras});

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
    poseDetector = PoseDetector(options: PoseDetectorOptions());
  }

  Future<void> initializeCamera() async {
    cameraController = CameraController(
      cameras.first, // Use the first camera from the passed list
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController.initialize();
    cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
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
      Future.delayed(const Duration(seconds: 1), () {
        if (isRecording.value) {
          final elapsed = stopwatch.elapsed;
          elapsedTime.value =
              '${elapsed.inHours.toString().padLeft(2, '0')}:${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
          _updateElapsedTime();
        }
      });
    }
  }

  Future<void> _detectMotion() async {
    while (isRecording.value && cameraController.value.isInitialized) {
      try {
        final image = await cameraController.takePicture();
        final inputImage = InputImage.fromFilePath(image.path);
        final poses = await poseDetector.processImage(inputImage);

        if (poses.isNotEmpty) {
          _saveImage(image);
          stopRecording();
          debugPrint('Motion detected! Photo saved.');
          return;
        }
      } catch (e) {
        debugPrint('Error during motion detection: $e');
      }
    }
  }

  Future<void> _saveImage(XFile image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(path);
      await file.writeAsBytes(await image.readAsBytes());
      debugPrint('Image saved at: $path');
    } catch (e) {
      debugPrint('Error saving image: $e');
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