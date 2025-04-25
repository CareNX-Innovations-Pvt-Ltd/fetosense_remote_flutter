import 'dart:core';
import 'package:fetosense_remote_flutter/core/model/marker_indices.dart';

/// A class that provides methods to interpret fetal heart rate (FHR) data.
class Interpretation {
  static final int NO_OF_SAMPLES_PER_MINUTE =
      16; // 60;//16;   // 16 datapoints (3.75 ms for 1 sample) per minute
  static final int TOTAL_SAMPLES = 160; // 16*10 = 160 samples in 10 minutes
  static final int SIXTY_THOUSAND_MS = 60000; // 1 minute = 60 seconds
  static final List highFHREpisodePercentiles = [
    //criteria for confirming high FHR episodes
    // gestAge, 3rd percentile, 10th percentile of healthy fetus
    [26, 11.75, 12.75],
    [27, 11.75, 12.75],
    [28, 11.5, 12.75],
    [29, 11.5, 13],
    [30, 11.5, 13],
    [31, 11.75, 13],
    [32, 11.75, 13.25],
    [33, 12, 13.25],
    [34, 12, 13.5],
    [35, 12.25, 14],
    [36, 12.5, 14.25],
    [37, 12.5, 14.5],
    [38, 12.75, 14.5],
    [39, 12.75, 14.75],
    [40, 12.5, 14.75],
    [41, 12.75, 14.75]
  ];
  final double factor = 3.75;
  double? baselineFHR;

  /// bradycardia basal heart rate < 110 bpm | tachycardia basal heart rate > 160 bpm
  bool? isBradycardia, isTachycardia;
  List<int>? baseLineFHRArrayList;
  late List<int?> millisecondsEpoch;
  List<int>? beatsArray;
  late List<int?> beatsInMilliseconds;

  /// Gestetional age in weeks
  ///
  int gestAge = 32;

  /// array of mean heartbeat inter-arrival intervals (60 minutes maximum)
  /// one sample each 3.75 seconds = 16 samples per minute
  ///
  String? baselineB2bVariability;

  /// baseline FHR calculated with Dawos-Redman criteria
  ///
  List<int?>? baselineFHRDR;
  int? nAccelerations, nDeaccelerations;
  double? signalLossPercent;

  /// Episodes of low and high FHR variation (calculated in minutes and bpm
  ///
  double? lengthOfHighFHREpisodes;
  double? lengthOfLowFHREpisodes;
  int? highFHRVariationBpm;
  int? lowFHRVariationBpm;

  /// Short-term variability (STV) (calculated in ms and bpm)
  ///
  double? shortTermVariabilityMs;
  double? shortTermVariabilityBpm;

  /// basal heart rate = average FHR over low variation episodes
  ///
  int? basalHeartRate;
  List<MarkerIndices>? nAccelerationsList;
  List<MarkerIndices>? nDecelerationList;

  /// Default constructor
  Interpretation() {
    gestAge = 0;
    gestAge = 0;
    baselineB2bVariability = "";
    baselineFHR = 0.0;
    baselineFHRDR = List.filled(TOTAL_SAMPLES, null, growable: false);
    nAccelerations = 0;
    nDeaccelerations = 0;
    signalLossPercent = 0.0;
    lengthOfHighFHREpisodes = 0;
    lengthOfLowFHREpisodes = 0;
    highFHRVariationBpm = 0;
    lowFHRVariationBpm = 0;
    shortTermVariabilityMs = 0;
    shortTermVariabilityBpm = 0;
    basalHeartRate = 0;
    isBradycardia = false;
    isTachycardia = false;
  }

  Interpretation.fromList(int gAge, List<int> beats) {
    gestAge = gAge;
    baselineB2bVariability = "";
    baselineFHR = 0.0;
    baselineFHRDR = List.filled(beats.length, null, growable: false);
    nAccelerations = 0;
    nDeaccelerations = 0;
    signalLossPercent = 0.0;
    lengthOfHighFHREpisodes = 0;
    lengthOfLowFHREpisodes = 0;
    highFHRVariationBpm = 0;
    lowFHRVariationBpm = 0;
    shortTermVariabilityMs = 0;
    shortTermVariabilityBpm = 0;
    basalHeartRate = 0;
    isBradycardia = false;
    isTachycardia = false;

    beatsArray = beats;
    beatsInMilliseconds = convertBPMToMilliseconds(beats);
    millisecondsEpoch = convertMillisecondsToEpochArray();
    baseLineFHRArrayList = calculateBaselineFHRDR();
    calculateNAccelerations();
    calculateNDecelerations();
    calculateBasalHeartRate();
    calculateShortTermVariability();
  }

  /// Converts a list of beats per minute (BPM) to a list of milliseconds.
  ///
  /// [beatsBPM] - The list of beats per minute.
  ///
  /// Returns a list of milliseconds.
  List<int?> convertBPMArrayListArray(List<int> beatsBPM) {
    int size = (beatsBPM.length / factor).truncate();
    List<int?> list = List.filled(size, null, growable: false);
    for (int i = 0; i < size; i++) {
      int bpm = 0;
      for (int j = (i * factor).truncate(), k = 0;
          j < beatsBPM.length && k < 4;
          j++, k++) {
        bpm += beatsBPM[j];
      }
      bpm = (bpm / 4).truncate();
      list[i] = bpm;
    }
    return list;
  }

  /**
   * helper method
   **/
  /// Calculates the average of the last minute of input data.
  ///
  /// [input] - The input list of data.
  /// [size] - The size of the input list.
  ///
  /// Returns the average as an integer.
  static int avgLastMin(List<int?>? input, int size) {
    int sum = 0;
    if (size > 4) {
      // last 15 sec
      for (int i = 0; i < 4; i++) {
        sum += input![size - i]!;
      }
      sum = (sum / 4).truncate();
    } else {
      for (int i = 0; i < size; i++) {
        sum += input![i]!;
      }
      sum = (sum / size).truncate();
    }
    return sum;
  }

  /**
   * baseline fetal heart rate = heart rate during first 10 minutes
   * (160 com.luckcome.data points) rounded to nearest 5 bpm increment excluding
   * 1. Marked FHR variability
   * 2. Periodic (due to uterine contractions)/episodic changes (due to non-uterine contractions)
   * 3. Segments of baseline that differ by more than 25 bpm (2400 ms)
   **/

  /// Calculates the baseline fetal heart rate (FHR).
  ///
  /// [beats] - The list of beats.
  /// [size] - The size of the list.
  ///
  /// Returns the baseline FHR as an integer.
  int calculateBaselineFHR(List<int> beats, int size) {
    //assert size > 15 : "Input size insufficient!" ;

    //List<double> beats = convertBPMArrayListArray(beatsBPM);
    //size = beats.length;
    int noOfSamplesPerMinute = 60;
    int minutes = (size / noOfSamplesPerMinute).truncate();
    List<int?> beatsBpm = List.filled(size, null, growable: false);
    double meanHr = 0, meanHrLb = 0, meanHrUb = 0;
    List<double?> variabilityHr = List.filled(minutes, null, growable: false);
    List<double?> meanHrList = List.filled(minutes, null, growable: false);
    double min = beats[0].toDouble();
    double max = 0;

    for (int j = 0; j < size; j++) {
      if (beats[j] != 0) {
        beatsBpm[j] = (SIXTY_THOUSAND_MS / beats[j]).truncate();
      } else {
        beatsBpm[j] = 0;
      }
    }

    for (int j = 0; j < minutes; j++) {
      min = 1000000;
      max = 0;
      meanHr = 0;
      for (int i = 0; i < noOfSamplesPerMinute; i++) {
        if (beatsBpm[j * noOfSamplesPerMinute + i]! < min) {
          min = beatsBpm[j * noOfSamplesPerMinute + i]!.toDouble();
        }
        if (beatsBpm[j * noOfSamplesPerMinute + i]! > max) {
          max = beatsBpm[j * noOfSamplesPerMinute + i]!.toDouble();
        }

        meanHr += beatsBpm[j * noOfSamplesPerMinute + i]!;
      }
      meanHr /= noOfSamplesPerMinute;
      variabilityHr[j] = max - min;
      meanHrList[j] = meanHr;
    }

    int howManyLb = 0, howManyUb = 0;

    for (int j = 0; j < minutes; j++) {
      if (variabilityHr[j]! <= (SIXTY_THOUSAND_MS / 25)) {
        meanHrLb += meanHrList[j]!;
        howManyLb++;
      } else {
        meanHrUb += meanHrList[j]!;
        howManyUb++;
      }
    }

    baselineFHR = meanHrLb / howManyLb;
    if (baselineFHR! > 0) {
      baselineFHR = ((baselineFHR! / 5) * 5);
    } else {
      baselineFHR = meanHrUb / howManyUb;
      baselineFHR = ((baselineFHR! / 5) * 5);
    }
    if (baselineFHR! > 0 && SIXTY_THOUSAND_MS / baselineFHR! < 300) {
      return (SIXTY_THOUSAND_MS / baselineFHR!).truncate();
    } else {
      return 0;
    }
  }

  /// Converts a list of baseline epochs to a list of beats per minute (BPM).
  ///
  /// [baseline] - The list of baseline epochs.
  ///
  /// Returns a list of BPM.
  List<int> convertBPMArrayArrayList(List<int> baseline) {
    //int size = (int)(beatsBPM.length*factor);
    List<int> list = [];
    for (int i = 0; i < baseline.length - 1; i++) {
      for (int j = (i * factor).truncate();
          j < ((i + 1) * factor).truncate();
          j++) {
        list.add(baseline[i]);
      }
    }
    return list;
  }

  /// Converts a list of baseline epochs to a list of beats per minute (BPM).
  ///
  /// [baseline] - The list of baseline epochs.
  ///
  /// Returns a list of BPM.
  List<int> convertBaselineEpochToBPMArrayList(List<int?> baseline) {
    //int size = (int)(beatsBPM.length*factor);
    List<int> list = [];
    for (int i = 0; i < baseline.length - 1; i++) {
      for (int j = (i * factor).truncate();
          j < ((i + 1) * factor).truncate();
          j++) {
        if (baseline[i] == 0) {
          list.add(0);
        } else {
          list.add((SIXTY_THOUSAND_MS / baseline[i]!).truncate());
        }
      }
    }
    return list;
  }

  /// Converts a list of beats per minute (BPM) to a list of milliseconds.
  ///
  /// [beatsBPM] - The list of beats per minute.
  ///
  /// Returns a list of milliseconds.
  List<int?> convertBPMToMilliseconds(List<int> beatsBPM) {
    int size = beatsBPM.length;
    List<int?> list = List.filled(size, null, growable: false);
    for (int i = 0; i < size; i++) {
      list[i] = 0;
      if (beatsBPM[i] != 0) {
        list[i] = (SIXTY_THOUSAND_MS / beatsBPM[i]).truncate();
      } else {
        list[i] = 0;
      }
    }
    return list;
  }

  /// Converts a list of milliseconds to a list of epoch values.
  ///
  /// Returns a list of epoch values.
  List<int?> convertMillisecondsToEpochArray() {
    int size = (beatsInMilliseconds.length / factor).truncate();
    List<int?> list = List.filled(size, null, growable: false);
    for (int i = 0; i < size; i++) {
      int milli = 0;
      for (int j = (i * factor).truncate(), k = 0;
          j < beatsInMilliseconds.length && k < 4;
          j++, k++) {
        milli += beatsInMilliseconds[j]!;
      }
      milli = (milli / 4).truncate();
      list[i] = milli;
    }
    return list;
  }

  /// Getter methods
  ///
  int getGestAge() {
    return gestAge;
  }

  /// Methods for interpretation
  ///
  void setGestAge(int gestAge) {
    this.gestAge = gestAge;
  }

  String? getBaselineB2bVariability() {
    return baselineB2bVariability;
  }

  double? getBaselineFHR() {
    return baselineFHR;
  }

  List<int?>? getBaselineFHRDR() {
    return baselineFHRDR;
  }

  double? getSignalLossPercent() {
    return signalLossPercent;
  }

  double? getLengthOfHighFHREpisodes() {
    return lengthOfHighFHREpisodes;
  }

  double? getLengthOfLowFHREpisodes() {
    return lengthOfLowFHREpisodes;
  }

  int? getHighFHRVariationBpm() {
    return highFHRVariationBpm;
  }

  int? getLowFHRVariationBpm() {
    return lowFHRVariationBpm;
  }

  double? getShortTermVariabilityMs() {
    return shortTermVariabilityMs;
  }

  double? getShortTermVariabilityBpm() {
    return shortTermVariabilityBpm;
  }

  int? getBasalHeartRate() {
    return basalHeartRate;
  }

  int? getNAccelerations() {
    return nAccelerations;
  }

  int? getNDeaccelerations() {
    return nDeaccelerations;
  }

  bool? getIsBradycardia() {
    return isBradycardia;
  }

  bool? getIsTachycardia() {
    return isTachycardia;
  }

  /// baseline b2b variability criteria
  /// 1. Increased or marked > 25 bpm
  /// 2. Normal or moderate 5 - 25 bpm
  /// 3. Reduced or minimal 3 - 5 bpm
  /// 4. Absent < 3 bpm
  ///

  void calculateBaselineB2bVariability(List<double> beats, int size) {
    int? min = 0, max = 0;
    List<int?> beatsBpm = List.filled(size, null, growable: false);

    for (int j = 0; j < size; j++) {
      if (beats[j] != 0) {
        beatsBpm[j] = (SIXTY_THOUSAND_MS / beats[j]).truncate();
      } else {
        beatsBpm[j] = 0;
      }
      //System.out.println(beatsBpm[j]+" " + beats[j]);
    }

    min = beatsBpm[0];

    for (int i = 0; i < size; i++) {
      if (beatsBpm[i]! < min!) min = beatsBpm[i];
      if (beatsBpm[i]! > max!) max = beatsBpm[i];
    }

    if (max! - min! > 0 && max - min >= 25) {
      // 25 bpm ~ 2400 ms
      baselineB2bVariability = "Increased or Marked";
    } else if (max - min >= 5 && max - min < 25) // 5 bpm ~ 12000 ms
      baselineB2bVariability = "Normal or Moderate";
    else if (max - min >= 3 && max - min < 5) // 3 bpm ~ 20000 ms
      baselineB2bVariability = "Reduced or Minimal";
    else
      baselineB2bVariability = "Absent";
  }

  /**
   * baseline FHR calculated with Dawos-Redman criteria
   * 1. Plot histogram of distribution of atleast 10 minute or 160 samples' mean intervals
   * 2. Scan from higher to lower mean intervals to choose limiting parameter value that appears first and satisfies
   * a. atleast 12.5% of all sample lie right to the value
   * b. value should exceed atleast 5 next values to the left
   * c. contains atleast 0.5% of total samples in the distribution
   * d. not differ by 30ms than the peak value (mode) of the distribution
   * 3. If unable to find limiting parameter, use mode as a limiting parameter
   * 4. Create a band pass filter with
   * a. Upper limit = limiting parameter + 60
   * b. Lower limit = limiting parameter - 60
   * 5. Apply this band filter to the original heartbeat interval array and output will be a baseline over time
   **/

  /// Calculates the baseline fetal heart rate (FHR) using Dawes-Redman criteria.
  ///
  /// Returns a list of baseline FHR values.
  List<int> calculateBaselineFHRDR() {
    int size = millisecondsEpoch.length;

    baselineFHRDR = List.filled(size, null, growable: false);

    int buckets = 1001, modeIndex = 0;
    List<int?> freq = List.filled(buckets, null, growable: false);
    int? mode = 0,
        sumOfValues = 0,
        limitingValue = 0; // 60-220 bpm = 1000-272 ms

    /** calculate frequency distribution of intervals**/
    for (int i = 0; i < buckets; i++) {
      freq[i] = 0;
    }
    for (var epoch in millisecondsEpoch) {
      if (epoch == 0 || epoch! >= buckets) {
        freq[0] = freq[0]! + 1;
      } else {
        freq[epoch] = freq[epoch]! + 1;
      }
      /*for (int i = 0; i < buckets; i++) {
                if (Math.round(beat) == (double) i) {
                    freq[i]++;
                }
            }*/
    }

    /** calculate peak frequency or mode **/
    for (int i = 1; i < buckets - 1; i++) {
      if (freq[i]! > mode!) {
        mode = freq[i];
        modeIndex = i;
      }
    }

    int peak = 0;
    /** calculate limiting parameter **/
    for (int i = buckets - 1; i >= 5; i--) {
      if (sumOfValues! > (0.125 * (size - freq[0]!))) {
        if (freq[i]! >= freq[i - 5]! &&
            freq[i]! >= freq[i - 4]! &&
            freq[i]! >= freq[i - 3]! &&
            freq[i]! >= freq[i - 2]! &&
            freq[i]! >= freq[i - 1]!) {
          if (freq[i]! > 0.005 * size || (modeIndex - i) <= 30) {
            limitingValue = i;
            peak = i;
            break;
          }
        }
      }
      sumOfValues += freq[i]!;
    }

    if (limitingValue == 0) limitingValue = modeIndex;

    /** apply band filter with the use of limiting value **/
    baselineFHRDR![0] = millisecondsEpoch[0];
    for (int i = 1; i < size - 1; i++) {
      if (millisecondsEpoch[i] == 0) {
        baselineFHRDR![i] =
            millisecondsEpoch[i]; //avgLastMin(baselineFHRDR, i - 1);;

      } else {
        if (millisecondsEpoch[i]! >= (limitingValue! - 60) &&
            millisecondsEpoch[i]! <=
                (limitingValue + 60)) {
          // 60 is given in the literature
          baselineFHRDR![i] = millisecondsEpoch[i];
        } else {
          baselineFHRDR![i] = baselineFHRDR![i -
              1]; //avgLastMin(baselineFHRDR, i - 1); //interpolate over previous values
        }
      }
      if (baselineFHRDR![i]!.isNaN) baselineFHRDR![i] = baselineFHRDR![0];
    }
    baselineFHRDR![size - 1] = avgLastMin(baselineFHRDR, size - 2);
    return convertBaselineEpochToBPMArrayList(baselineFHRDR!);
  }

  /**
   * accelerations:
   * accelerations <32 weeks: >=10 bpm above baseline for >= 10 seconds
   * accelerations >=32 weeks: >=15 bpm above baseline for >= 15 seconds
   **/
  /*int calculateNAccelerations(List<int> beatsBpm) {
        return calculateNAccelerations(convertBPMArrayListArray(beatsBpm), baselineFHRDR);
    }*/

  /// Calculates the number of accelerations.
  void calculateNAccelerations() {
    List<MarkerIndices> accelerations = [];
    int size = millisecondsEpoch.length;
    //assert size > 15 : "Input size insufficient!" ;
    int counter1 = 0, counter2 = 0, n = 0;
    //List<int> beatsBpm = millisecondsEpoch;
    bool isAcceleration = false;

    /*for (int j = 0; j < size; j++) {

            if (beats[j] != 0)
                beatsBpm[j] = SIXTY_THOUSAND_MS / (int) beats[j];
            else
                beatsBpm[j] = 0;
        }*/

    for (int i = 0; i < size; i++) {
      MarkerIndices acceleration = MarkerIndices();
      /** gestetional age <32 weeks **/
      print("milisec${baselineFHRDR![i]} ${millisecondsEpoch[i]}");
      if ((baselineFHRDR![i]! - millisecondsEpoch[i]!) == 0) {
        if (isAcceleration) {
          acceleration = MarkerIndices();
          acceleration.setFrom(
              ((i - (gestAge <= 32 ? counter1 : counter2)) * factor)
                  .truncate());
          acceleration.setTo(((i) * factor).truncate());
          accelerations.add(acceleration);
        }
        counter1 = 0;
        counter2 = 0;
        isAcceleration = false;
        continue;
      }
      if (gestAge <= 32 &&
          SIXTY_THOUSAND_MS / (baselineFHRDR![i]! - millisecondsEpoch[i]!) >= 10) {
        // 10bpm = 6000ms
        counter1++;
        if (counter1 >= 3 && !isAcceleration) {
          // 10 seconds = 3 samples
          // acceleration detected
          isAcceleration = true;
          n++;
        }
      } else if (gestAge <= 32) {
        if (isAcceleration) {
          acceleration = MarkerIndices();
          acceleration.setFrom(((i - counter1) * factor).truncate());
          acceleration.setTo((((i) * factor).truncate()));
          accelerations.add(acceleration);
        }
        counter1 = 0;
        isAcceleration = false;
      }

      /** gestetional age >=32 weeks **/
      if (gestAge > 32 &&
          SIXTY_THOUSAND_MS / (baselineFHRDR![i]! - millisecondsEpoch[i]!) >= 15) {
        // 15bpm = 4000ms
        counter2++;
        if (counter2 >= 4 && !isAcceleration) {
          // 15 seconds = 4 samples
          isAcceleration = true;
          n++;
        }
      } else if (gestAge > 32) {
        if (isAcceleration) {
          acceleration = MarkerIndices();
          acceleration.setFrom(((i - counter2) * factor).truncate());
          acceleration.setTo(((i) * factor).truncate());
          accelerations.add(acceleration);
        }
        counter2 = 0;
        isAcceleration = false;
      }
    }
    nAccelerations = n;
    nAccelerationsList = accelerations;
    return;
  }

  /**
   * deaccelerations:
   * >=10 bpm below baseline for >=60 seconds
   * >=20 bpm below baseline for >=30 seconds
   **/

  /*int calculateNDecelerations(List<int> beatsBpm) {
        return calculateNDecelerations(convertBPMArrayListArray(beatsBpm), baselineFHRDR);
    }*/
  /// Calculates the number of decelerations.
  void calculateNDecelerations() {
    List<MarkerIndices> decelerations = [];
    int size = millisecondsEpoch.length;

    MarkerIndices deceleration = MarkerIndices();
    int counter1 = 0, counter2 = 0, n = 0;
    //List<int> beatsBpm = new int[size];
    bool isDeacceleration = false;

    /*for (int j = 0; j < size; j++) {

            if (beats[j] != 0)
                beatsBpm[j] = SIXTY_THOUSAND_MS / (int) beats[j];
            else
                beatsBpm[j] = 0;
        }*/

    for (int i = 0; i < size; i++) {
      if ((millisecondsEpoch[i]! - baselineFHRDR![i]!) == 0) {
        if (isDeacceleration) {
          deceleration = MarkerIndices();
          deceleration.setFrom(((i - counter1) * factor).truncate());
          deceleration.setTo(((i) * factor).truncate());
          decelerations.add(deceleration);
        }
        counter1 = 0;
        isDeacceleration = false;
        continue;
      }
      /** first criteria **/
      if (SIXTY_THOUSAND_MS /
              (millisecondsEpoch[i]! - baselineFHRDR![i]!).truncate() >=
          10) {
        counter1++;
        if (counter1 >= 16 && !isDeacceleration) {
          // 60 seconds = 16 samples
          isDeacceleration = true;
          n++;
        }
      } else {
        if (isDeacceleration) {
          deceleration = MarkerIndices();
          deceleration.setFrom(((i - counter1) * factor).truncate());
          deceleration.setTo(((i) * factor).truncate());
          decelerations.add(deceleration);
        }
        counter1 = 0;
        isDeacceleration = false;
      }
    }

    isDeacceleration = false; //restore after first for loop

    for (int i = 0; i < size; i++) {
      if ((millisecondsEpoch[i]! - baselineFHRDR![i]!) == 0) {
        if (isDeacceleration) {
          deceleration = MarkerIndices();
          deceleration.setFrom(((i - counter2) * factor).truncate());
          deceleration.setTo(((i) * factor).truncate());
          decelerations.add(deceleration);
        }
        counter2 = 0;
        isDeacceleration = false;
        continue;
      }
      /** second criteria **/
      if (SIXTY_THOUSAND_MS / (millisecondsEpoch[i]! - baselineFHRDR![i]!) >= 20) {
        counter2++;
        if (counter2 >= 8 && counter2 < 16 && !isDeacceleration) {
          // 30 seconds = 8 samples
          isDeacceleration = true;
          n++;
        } else {
          if (isDeacceleration) {
            deceleration = MarkerIndices();
            deceleration.setFrom(((i - counter2) * factor).truncate());
            deceleration.setTo(((i) * factor).truncate());
            decelerations.add(deceleration);
          }
          counter2 = 0;
          isDeacceleration = false;
        }
      }
    }

    nDeaccelerations = n;
    nDecelerationList = decelerations;
    return;
  }

  /// Signal loss %
  /// 1. calculate area under all deaccelerations (number of lost beats)
  /// 2. add them up
  /// 3. calculate % of those beats against total beats
  /// <p>
  /// TODO: How to consider parallel scanning of signal for deaccelerations and processing? Are we loosing some part of signal here?
  ///

  double? calculateSignalLossPercent(List<int> beats, List<int> baselineFHRDR) {
    int size = beats.length;

    int counter1 = 0, counter2 = 0;
    List<int?> beatsBpm = List.filled(size, null, growable: false);
    double noOfBeatsLost = 0, totalBeats = 0;

    for (int j = 0; j < size; j++) {
      if (beats[j] != 0) {
        beatsBpm[j] = (SIXTY_THOUSAND_MS / beats[j]).truncate();
      } else {
        beatsBpm[j] = 0;
      }
    }

    for (int i = 0; i < size; i++) {
      /** first criteria **/
      if (SIXTY_THOUSAND_MS / baselineFHRDR[i] - beatsBpm[i]! >= 5) {
        counter1++;
        if (counter1 == 16) {
          // 60 seconds = 16 samples

          for (int j = 0; j < counter1; j++) {
            noOfBeatsLost += baselineFHRDR[i - j] - beatsBpm[i - j]!;
            totalBeats += baselineFHRDR[i - j];
          }
        }

        if (counter1 > 16) {
          noOfBeatsLost += baselineFHRDR[i] - beatsBpm[i]!;
          totalBeats += baselineFHRDR[i];
        }
      } else {
        counter1 = 0;
      }

      /** second criteria **/
      if (SIXTY_THOUSAND_MS / baselineFHRDR[i] - beatsBpm[i]! >= 10) {
        counter2++;
        if (counter2 == 8) {
          // 30 seconds = 8 samples

          for (int j = 0; j < counter2; j++) {
            noOfBeatsLost += baselineFHRDR[i - j] - beatsBpm[i - j]!;
            totalBeats += baselineFHRDR[i - j];
          }
        }

        if (counter2 > 8 && counter2 < 16) {
          noOfBeatsLost += baselineFHRDR[i] - beatsBpm[i]!;
          totalBeats += baselineFHRDR[i];
        }
      } else {
        counter2 = 0;
      }
    }

    if (totalBeats != 0) {
      signalLossPercent = noOfBeatsLost * 100 / totalBeats;
    } else {
      signalLossPercent = 0;
    }
    return signalLossPercent;
  }

  /// Episodes of low and high FHR variation (calculated in minutes and bpm)
  /// 1. discard all deaccelerations + more than 50% signal loss
  /// 2. for each minute calculate minuteRange = (max-baseline)+(baseline-min)
  /// a. if no max or min, use baseline value as it is
  /// 3. meanMinuteRange = average of consecutive minuteRanges
  /// 4. Episode of low FHR variation
  /// a. mean of atleast 5-6 minuteRanges < 30 ms
  /// 5. Episode of high FHR variation
  /// a. mean of atleast 5-6 minuteRanges > 32 ms
  /// b. use gestetional age and percentile range to confirm (not implemented yet)
  /// <p>
  /// TODO: How to consider parallel scanning of signal for deaccelerations and processing? Are we loosing some part of signal here?
  ///

  void calculateLengthOfFHREpisodes(List<int?> beats, List<int?>? baselineFHRDR) {
    try {
      int size = beats.length;

      List<double?> maxVariationsPerMinute =
          List.filled((size / NO_OF_SAMPLES_PER_MINUTE).truncate(), null, growable: false);
      double maxDiffAboveBaseline = 0, maxDiffBelowBaseline = 0;
      int counter1 = 0, counter2 = 0;
      List<int?> beatsBpm = List.filled(size, null, growable: false);

      for (int j = 0; j < size; j++) {
        if (beats[j] != 0) {
          beatsBpm[j] = (SIXTY_THOUSAND_MS / beats[j]!).truncate();
        } else {
          beatsBpm[j] = 0;
        }
      }

      /** processing only parts of signal which contain no deacceleration **/
      for (int i = 0; i < size / NO_OF_SAMPLES_PER_MINUTE; i++) {
        for (int j = 0; j < NO_OF_SAMPLES_PER_MINUTE; j++) {
          /** first criteria **/
          if (baselineFHRDR![i * NO_OF_SAMPLES_PER_MINUTE + j]! -
                  beatsBpm[i * NO_OF_SAMPLES_PER_MINUTE + j]! >=
              5) {
            counter1++;
            if (counter1 == 16) {
              // 60 seconds = 16 samples
              // deacceleration is detected here

              for (int k = 0; k < counter1; k++) {
                if (maxDiffAboveBaseline <
                    baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j - k]! -
                        beats[i * NO_OF_SAMPLES_PER_MINUTE + j - k]!) {
                  maxDiffAboveBaseline =
                      (baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j - k]! -
                              beats[i * NO_OF_SAMPLES_PER_MINUTE + j - k]!)
                          .toDouble();
                }

                if (maxDiffBelowBaseline <
                    beats[i * NO_OF_SAMPLES_PER_MINUTE + j - k]! -
                        baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j - k]!) {
                  maxDiffBelowBaseline = (beats[
                              i * NO_OF_SAMPLES_PER_MINUTE + j - k]! -
                          baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j - k]!)
                      .toDouble();
                }
              }
            }
          } else {
            counter1 = 0;
            if (maxDiffAboveBaseline <
                baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j]! -
                    beats[i * NO_OF_SAMPLES_PER_MINUTE + j]!) {
              maxDiffAboveBaseline =
                  (baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j]! -
                          beats[i * NO_OF_SAMPLES_PER_MINUTE + j]!)
                      .toDouble();
            }

            if (maxDiffBelowBaseline <
                beats[i * NO_OF_SAMPLES_PER_MINUTE + j]! -
                    baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j]!) {
              maxDiffBelowBaseline = (beats[i * NO_OF_SAMPLES_PER_MINUTE + j]! -
                      baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j]!)
                  .toDouble();
            }
          }

          /** second criteria **/
          if (baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j]! -
                  beatsBpm[i * NO_OF_SAMPLES_PER_MINUTE + j]! >=
              10) {
            counter2++;
            if (counter2 == 8) {
              // 30 seconds = 8 samples
              // deacceleration is occuring here
              for (int k = 0; k < counter2; k++) {
                if (maxDiffAboveBaseline <
                    baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j - k]! -
                        beats[i * NO_OF_SAMPLES_PER_MINUTE + j - k]!) {
                  maxDiffAboveBaseline =
                      (baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j - k]! -
                              beats[i * NO_OF_SAMPLES_PER_MINUTE + j - k]!)
                          .toDouble();
                }

                if (maxDiffBelowBaseline <
                    beats[i * NO_OF_SAMPLES_PER_MINUTE + j - k]! -
                        baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j - k]!) {
                  maxDiffBelowBaseline = (beats[
                              i * NO_OF_SAMPLES_PER_MINUTE + j - k]! -
                          baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j - k]!)
                      .toDouble();
                }
              }
            }
          } else {
            counter2 = 0;
            if (maxDiffAboveBaseline <
                baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j]! -
                    beats[i * NO_OF_SAMPLES_PER_MINUTE + j]!) {
              maxDiffAboveBaseline =
                  (baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j]! -
                          beats[i * NO_OF_SAMPLES_PER_MINUTE + j]!)
                      .toDouble();
            }

            if (maxDiffBelowBaseline <
                beats[i * NO_OF_SAMPLES_PER_MINUTE + j]! -
                    baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j]!) {
              maxDiffBelowBaseline = (beats[i * NO_OF_SAMPLES_PER_MINUTE + j]! -
                      baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j]!)
                  .toDouble();
            }
          }
        }

        maxVariationsPerMinute[i] = maxDiffAboveBaseline + maxDiffBelowBaseline;
      }

      double meanMinuteInterval = 0,
          sum = 0,
          meanLowEpisodeBpm = 0,
          meanHighEpisodeBpm = 0;
      int highEpisodes = 0, lowEpisodes = 0, howManyLow = 0, howManyHigh = 0;

      for (int i = 0; i < size / NO_OF_SAMPLES_PER_MINUTE - 6; i++) {
        for (int j = i; j < i + 6; j++) {
          sum += maxVariationsPerMinute[j]!;
        }

        meanMinuteInterval = sum / 6;
        sum = 0;

        for (int j = i; j < i + 6; j++) {
          if ((meanMinuteInterval * 6 - maxVariationsPerMinute[j]!) / 5 <= 30) {
            howManyLow++;
          }

          if ((meanMinuteInterval * 6 - maxVariationsPerMinute[j]!) / 5 >= 32) {
            howManyHigh++;
          }
        }

        if (howManyLow >= 5) {
          lowEpisodes++;
          meanLowEpisodeBpm += meanMinuteInterval;
        }

        if (howManyHigh >= 5) {
          // ignoring correlation and distribution of original traces for now
          highEpisodes++;
          meanHighEpisodeBpm += meanMinuteInterval;
          if (gestAge <= 25) {
            // Do nothing
          } else if (meanHighEpisodeBpm / highEpisodes <
              highFHREpisodePercentiles[gestAge - 26][1]) {
            // checking 3rd percentile criteria

            highEpisodes--;
            meanHighEpisodeBpm -= meanMinuteInterval;
          }
        }

        howManyLow = howManyHigh = 0;
      }

      lengthOfHighFHREpisodes = highEpisodes.toDouble();
      lengthOfLowFHREpisodes = lowEpisodes.toDouble();

      if (meanHighEpisodeBpm != 0) {
        highFHRVariationBpm =
            (SIXTY_THOUSAND_MS / meanHighEpisodeBpm).truncate();
      }
      if (meanLowEpisodeBpm != 0) {
        lowFHRVariationBpm = (SIXTY_THOUSAND_MS / meanLowEpisodeBpm).truncate();
      }
    } catch (Exception) {
      //todo:
    }
  }

  /// Short-term variability (STV) (calculated in ms and bpm)
  /// 1. discard all deaccelerations + more than 50% signal loss
  /// 2. 1 minute mean of difference between FHR of consecutive samples
  /// 3. take mean of 1 minute means
  /// <p>
  /// TODO: How to consider parallel scanning of signal for deaccelerations and processing? Are we loosing some part of signal here?
  ///

  void calculateShortTermVariability() {
    try {
      List<int?> epoch = cleanMillisecondsEpoch(millisecondsEpoch);
      int size = epoch.length;
      int minMeanLength = (size / NO_OF_SAMPLES_PER_MINUTE).truncate();
      List<double?> meanIatPerMinute =
          List.filled((size / NO_OF_SAMPLES_PER_MINUTE).truncate(), null, growable: false);
      List<double?> meanEpochPerMinute =
          List.filled((size / NO_OF_SAMPLES_PER_MINUTE).truncate(), null, growable: false);
      List<double?> iatBeats = List.filled(size - 1, null, growable: false);
      List<int?> epochBeats = List.filled(size - 1, null, growable: false);
      double shortTermVariation = 0;
      double shortTermEpochVariation = 0;
      int counter = 0, meanIatCounter = 0;

      /** first calculate iat of beats **/
      for (int i = 0; i < size - 1; i++) {
        iatBeats[i] = (epoch[i + 1]! - epoch[i]!).toDouble().abs();
        epochBeats[i] = (((SIXTY_THOUSAND_MS / epoch[i + 1]!) -
                    (SIXTY_THOUSAND_MS / epoch[i]!))
                .truncate())
            .abs();
      }

      for (int i = 0; i < minMeanLength; i++) {
        meanIatPerMinute[i] = 0;
        meanEpochPerMinute[i] = 0;
      }

      /** processing only parts of signal which contain no deacceleration **/
      for (int i = 0; i < minMeanLength - 1; i++) {
        for (int j = 0; j < NO_OF_SAMPLES_PER_MINUTE; j++) {
          meanIatPerMinute[i] = meanIatPerMinute[i]! + iatBeats[i * NO_OF_SAMPLES_PER_MINUTE + j]!;
          meanEpochPerMinute[i] = meanEpochPerMinute[i]! + epochBeats[i * NO_OF_SAMPLES_PER_MINUTE + j]!;

          /** first criteria **/ /*
                if (millisecondsEpoch[i * NO_OF_SAMPLES_PER_MINUTE + j] - baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j] <= 6000) {
                    counter++;
                    if (counter >= 16) { // 60 seconds = 16 samples
                        // deacceleration is occuring here
                    }
                } else {
                    counter = 0;
                    meanIatPerMinute[i] += iatBeats[i * NO_OF_SAMPLES_PER_MINUTE + j];
                    meanIatCounter++;
                }

                */ /** second criteria **/ /*
                if (millisecondsEpoch[i * NO_OF_SAMPLES_PER_MINUTE + j] - baselineFHRDR[i * NO_OF_SAMPLES_PER_MINUTE + j] <= 3000) {
                    counter++;
                    if (counter >= 8 && counter < 16) { // 30 seconds = 8 samples
                        // deacceleration is occuring here
                    }
                } else {
                    counter = 0;
                    meanIatPerMinute[i] += iatBeats[i * NO_OF_SAMPLES_PER_MINUTE + j];
                    meanIatCounter++;
                }*/
        }
        meanIatPerMinute[i] = meanIatPerMinute[i]!/ NO_OF_SAMPLES_PER_MINUTE;
        meanEpochPerMinute[i] = meanEpochPerMinute[i]!/ NO_OF_SAMPLES_PER_MINUTE;

        /*if (meanIatCounter != 0)
                meanIatPerMinute[i] = meanIatPerMinute[i] / meanIatCounter;*/
      }

      for (int i = 0; i < minMeanLength; i++) {
        shortTermVariation += meanIatPerMinute[i]!;
        shortTermEpochVariation += meanEpochPerMinute[i]!;
      }
      shortTermVariabilityMs = shortTermVariation / (minMeanLength - 1);
      shortTermVariabilityBpm = shortTermEpochVariation / (minMeanLength - 1);

      //shortTermVariabilityMs = shortTermVariation * NO_OF_SAMPLES_PER_MINUTE / size;

      //if (shortTermVariabilityMs != 0)
      //    shortTermVariabilityBpm = SIXTY_THOUSAND_MS / shortTermVariation;

      print("STV   $shortTermVariabilityMs  $shortTermVariabilityBpm");
      //return shortTermVariabilityBpm;
    } catch (exception) {
      print(exception);
    }
  }

  List<int?> cleanMillisecondsEpoch(List<int?> millisecondsEpoch) {
    List<int> dec = [];
    int count = 0;
    List<int?> cleanMilli;
    if (nDecelerationList!.isNotEmpty) {
      for (int i = 1; i < nDecelerationList!.length; i++) {
        for (int j = nDecelerationList![i].getFrom();
            j <= nDecelerationList![i].getTo();
            j++) {
          dec.add(j);
        }
      }
    }
    for (int i = 0; i < millisecondsEpoch.length; i++) {
      if (millisecondsEpoch[i] == 0) {
        dec.add(i);
      }
      /*if (millisecondsEpoch[i] == 0 || millisecondsEpoch[i] > (SIXTY_THOUSAND_MS /210) || millisecondsEpoch[i] < (SIXTY_THOUSAND_MS /60) || Math.abs(millisecondsEpoch[i-1] - millisecondsEpoch[i]) > (SIXTY_THOUSAND_MS /35)) {
                dec.add(i);
            }*/
    }

    cleanMilli = List.filled(millisecondsEpoch.length - dec.length, null, growable: false);
    int j = 0;
    for (int i = 0; i < cleanMilli.length; i++) {
      if (!dec.contains(i)) {
        cleanMilli[j] = millisecondsEpoch[i];
        j++;
      }
    }
    return cleanMilli;
  }

  /// basalHeartRate = average FHR over low variation episodes
  /// 1. bradycardia basalHeartRate <= 110 bpm
  /// 2. tachycardia basalHeartRate >= 160 bpm
  /// 3. If no episodes of low variation are identified, it is derived
  /// from the frequency distribution of pulse intervals used in the
  /// baseline fitting algorithm (not implemented yet)
  /// <p>
  /// TODO: How to consider parallel scanning of signal for deaccelerations and processing? Are we loosing some part of signal here?
  ///

  void calculateBasalHeartRate() {
    int size = millisecondsEpoch.length;

    calculateLengthOfFHREpisodes(millisecondsEpoch, baselineFHRDR);

    if (lowFHRVariationBpm! > 0) {
      basalHeartRate = lowFHRVariationBpm;
    } else {
      // calculate it from frequency distribution of intervals. Consider mean?
      double sumOfValuesBpm = 0, zeroValuesBpm = 0;
      for (int i = 0; i < size; i++) {
        if (millisecondsEpoch[i] != 0) {
          sumOfValuesBpm += (SIXTY_THOUSAND_MS / millisecondsEpoch[i]!).truncate();
        } else {
          zeroValuesBpm++;
        }
      }
      basalHeartRate = (sumOfValuesBpm / size).truncate();
    }


    if (basalHeartRate! <= 110) {
      isBradycardia = true;
    } else {
      isBradycardia = false;
    }

    if (basalHeartRate! >= 160) {
      isTachycardia = true;
    } else {
      isTachycardia = false;
    }

    //rounding off to 5
    if(basalHeartRate!%5>=3){
      basalHeartRate = basalHeartRate! - (basalHeartRate!%5);
      basalHeartRate = basalHeartRate! + 5;
    }else{
      basalHeartRate = basalHeartRate! - (basalHeartRate!%5);
    }
    //return basalHeartRate;
  }

  List<int>? getBaseLineFHRArrayList() {
    return baseLineFHRArrayList;
  }

  List<MarkerIndices>? getAccelerationsList() {
    return nAccelerationsList;
  }

  List<MarkerIndices>? getDecelerationsList() {
    return nDecelerationList;
  }
}
