import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/test_crud_model.dart';
import 'package:fetosense_remote_flutter/ui/widgets/test_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A StatefulWidget that displays a list of tests associated with a mother.
class MotherTestListView extends StatefulWidget {
  final dynamic mother;

  const MotherTestListView({super.key, required this.mother});

  @override
  MotherTestListViewState createState() => MotherTestListViewState();
}

class MotherTestListViewState extends State<MotherTestListView> {
  late List<Test> tests;

  @override
  Widget build(BuildContext context) {
    final testStream = widget.mother['type'] == "BabyBeat"
        ? Provider.of<TestCRUDModel>(context)
        .fetchTestsAsStreamBabyBeat(widget.mother['documentId'])
        : Provider.of<TestCRUDModel>(context)
        .fetchTestsAsStream(widget.mother['documentId']);

    return SizedBox(
      child: StreamBuilder<List<Test>>(
        stream: testStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            tests = snapshot.data!;

            return tests.isEmpty
                ? const Center(
              child: Text(
                'No test yet',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
            )
                : ListView.builder(
              itemCount: tests.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => TestCard(
                testDetails: tests[index],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading tests: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            );
          }
        },
      ),
    );
  }
}

