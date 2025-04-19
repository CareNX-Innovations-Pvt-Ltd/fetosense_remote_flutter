import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/mother_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/crud_view_model.dart';
import 'package:fetosense_remote_flutter/ui/widgets/motherCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

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
  List<Mother>? mothers;


  final FocusNode _focus = FocusNode();
  final searchController = TextEditingController();

  String query = "*";

  bool isReplay = false;

  int? count;
  Stream<List<Mother>>? stream;

  /// Fetches mothers based on the search query.
  ///
  /// [query] is the search query.
  /// Returns a Future containing the search results.
  Future<dynamic> fetchMother(String query) async {
    debugPrint("fetchMother");
    try {
      if (query.trim().length > 2) {
        String body;

        body = json.encode({
          "searchDocumentId": widget.doctor!.documentId,
          "orgDocumentId": widget.doctor!.organizationId ?? "NANANANANNANA",
          "searchString": query,
          "apiKey": "ay7px0rjojzbtz0ym0"
        });
        final response = await http.post(
            Uri.parse(
                'https://backend.carenx.com:3006/api/search/searchMother'),
            headers: {"Content-Type": "application/json"},
            body: body);
        debugPrint("dasdasdddd $body");
        if (response.statusCode == 200) {
          // debugPrint(response.body.toLowerCase());
          return json.decode(response.body);
        } else {
          throw Exception('Failed to load post');
        }
      }
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  /// Fetches mothers as a stream based on the search query.
  ///
  /// [query] is the search query.
  /// Returns a Stream containing the search results.
  Stream<dynamic> fetchMothers(String query) async* {
    while (true) {
      yield await fetchMother(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    stream = Provider.of<CRUDModel>(context)
        .fetchMothersAsStreamSearchMothers(widget.doctor!.organizationId!, "A");

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 7),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.5,
                    color: Colors.grey,
                  ),
                ),
              ),
              child: ListTile(
                title: const Text(
                  "fetosense",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                  ),
                ),
                subtitle: TextField(
                  autofocus: false,
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Color(0xFFbdc6cf),
                  ),
                  textCapitalization: TextCapitalization.words,
                  controller: searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search mothers...',
                    contentPadding:
                        const EdgeInsets.only(left: 16, bottom: 8.0, top: 8.0),
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
                      query = '*';
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: FutureBuilder(
                  future: fetchMother(query.toLowerCase()),
                  builder: (context, AsyncSnapshot<dynamic> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text('No Data Found'));
                    }
                    final mothers =
                        snapshot.data!['data'].map((doc) => doc).toList();
                    return ListView.builder(
                      itemCount: mothers.length,
                      itemBuilder: (buildContext, index) =>
                          MotherCard(motherDetails: mothers[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //_focus.addListener(_onFocusChange);
    searchController.addListener(() {
      debugPrint(searchController.text);
      setState(() {
        query = searchController.text.isEmpty ? "*" : searchController.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _focus.dispose();
  }
}
