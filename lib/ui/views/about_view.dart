import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A stateless widget that represents the About view of the application.
/// This view displays information about the app, including version, website,
/// support email, contact number, and privacy policy.
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SizedBox(
        child: ListView(
          children: <Widget>[
            Hero(
              tag: 'hero',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 150.0,
                  child: Image.asset('images/ic_banner.png'),
                ),
              ),
            ),
            const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Align(
                    alignment: Alignment.topCenter,
                    child: Text("v2.0", style: TextStyle(fontSize: 22)))),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey))),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: MaterialButton(
                        onPressed: _launchURL,
                        child: TextFormField(
                          enabled: false,
                          initialValue: "www.fetosense.com",
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            icon: Icon(
                              Icons.web,
                              color: Colors.grey,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Material(
                        child: TextFormField(
                          enabled: false,
                          initialValue: "support@carenx.in",
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            icon: Icon(
                              Icons.email,
                              color: Colors.grey,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: MaterialButton(
                        onPressed: () => launch("tel://02249738863"),
                        child: TextFormField(
                          enabled: false,
                          initialValue: "022 4973 8863",
                          decoration: const InputDecoration(
                              hintText: 'Name',
                              icon: Icon(
                                Icons.call,
                                color: Colors.grey,
                              )),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: MaterialButton(
                        onPressed: _launchTerms,
                        child: TextFormField(
                          enabled: false,
                          initialValue: "PRIVACY POLICY",
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            icon: Icon(
                              Icons.open_in_browser,
                              color: Colors.grey,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Launches the URL for the website.
  _launchURL() async {
    const url = 'https://www.fetosense.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Launches the URL for the website.
  _launchTerms() async {
    const url = 'https://ios-fetosense.firebaseapp.com/privacy-policy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
