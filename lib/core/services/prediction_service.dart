import 'dart:convert';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

import '../model/test_model.dart';


class PredictionResult {
  final String birthOutcome;
  final String deliveryType;
  final String ctgInterpretation;

  PredictionResult({
    required this.birthOutcome,
    required this.deliveryType,
    required this.ctgInterpretation,
  });

  @override
  String toString() =>
      "BirthOutcome: $birthOutcome, DeliveryType: $deliveryType, CTG: $ctgInterpretation";
}

class BirthPredictionService {
  Interpreter? _interpreter;
  Map<String, dynamic>? _labelEncoders;

  Future<void> init() async {
    // Load TFLite model
    _interpreter = await Interpreter.fromAsset('assets/model.tflite');

    // Load label encoders
    final jsonStr = await rootBundle.loadString("assets/label_encoders.json");
    _labelEncoders = jsonDecode(jsonStr);

    print("✅ Model loaded");
    print("Inputs: ${_interpreter!.getInputTensors()}");
    print("Outputs: ${_interpreter!.getOutputTensors()}");
  }

  /// Convert a [Test] + [Interpretations2] into ML-ready features
  List<double> _extractFeatures(Test test, Interpretations2 interp) {
    final basal = interp.getBasalHeartRate().toDouble();
    final stv = interp.getShortTermVariationBpm();
    final ltv = interp.getLongTermVariation().toDouble();
    final accels = (interp.getnAccelerations() ?? 0).toDouble();
    final decels = (interp.getnDecelerations() ?? 0).toDouble();

    final fisher = (test.fisherScore ?? 0).toDouble();
    final fisher2 = (test.fisherScore2 ?? 0).toDouble();
    final gAge = (test.gAge ?? 0).toDouble();
    final weight = (test.weight ?? 0).toDouble();
    final avgFhr = (test.averageFHR ?? 0).toDouble();

    return [
      basal,
      stv,
      ltv,
      accels,
      decels,
      fisher,
      fisher2,
      gAge,
      weight,
      avgFhr,
    ];
  }

  Future<PredictionResult> predict(Test test, Interpretations2 interp) async {
    if (_interpreter == null || _labelEncoders == null) {
      throw Exception("BirthPredictionService not initialized. Call init() first.");
    }

    // Extract features (10)
    final coreFeatures = _extractFeatures(test, interp);
    print("🔍 Extracted Features: $coreFeatures");

    // Pad to match [1,1362] input
    final features = List<double>.filled(1362, 0.0);
    for (int i = 0; i < coreFeatures.length; i++) {
      features[i] = coreFeatures[i];
    }

    final input = [features];
    final output = List.filled(1 * 5, 0.0).reshape([1, 5]);

    _interpreter!.run(input, output);

    final probs = output[0];
    print("📤 Raw output: $probs");

    final predictedIdx = _argmax(probs);

    // Map to labels (your encoders.json should have 5 entries under "Birth Outcome")
    final encoders = _labelEncoders!["encoders"];
    final label = encoders["Birth Outcome"][predictedIdx.toString()] ?? "Unknown";

    return PredictionResult(
      birthOutcome: label,
      deliveryType: "Unknown",
      ctgInterpretation: "Unknown",
    );
  }

  int _argmax(List<double> probs) {
    double maxVal = probs[0];
    int maxIdx = 0;
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > maxVal) {
        maxVal = probs[i];
        maxIdx = i;
      }
    }
    return maxIdx;
  }
}
