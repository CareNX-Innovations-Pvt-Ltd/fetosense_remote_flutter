import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/mother_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/crud_view_model.dart';
import 'package:fetosense_remote_flutter/ui/widgets/mother_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

/// A StatefulWidget that provides a search interface for mothers.
///
/// This widget allows users to search for mothers associated with a doctor's organization.
class SearchView extends StatefulWidget  {
  final Doctor? doctor;
  final Organization? organization;

  /// [doctor] is the doctor model containing the details to be displayed.
  /// [organization] is the organization model.
  const SearchView({super.key, this.doctor, this.organization});

  @override
  SearchViewState createState() => SearchViewState();
}

class SearchViewState extends State<SearchView> {
  final searchController = TextEditingController();
  final FocusNode _focus = FocusNode();
  String query = "";

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        query = searchController.text;
      });
    });
  }

  Stream<List<Mother>> getMotherStream(String query) {
    final searchQuery = query.isEmpty ? "" : query;
    return Provider.of<CRUDModel>(context, listen: false)
        .fetchMothersAsStreamSearchMothers(widget.doctor!.organizationId!, searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Search bar
            ListTile(
              title: const Text("fetosense", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14)),
              subtitle: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search mothers...',
                  contentPadding: const EdgeInsets.only(left: 16, bottom: 8.0, top: 8.0),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 35),
                onPressed: () {
                  setState(() {
                    searchController.clear();
                    query = '';
                  });
                },
              ),
            ),
            // List of mothers
            Expanded(
              child: StreamBuilder<List<Mother>>(
                stream: getMotherStream(query),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No Data Found'));
                  }
                  final mothers = snapshot.data!;
                  return ListView.builder(
                    itemCount: mothers.length,
                    itemBuilder: (context, index) =>
                        MotherCard(mother: mothers[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _focus.dispose();
    super.dispose();
  }
}
