import 'package:fetosense_remote_flutter/core/utils/internet_check.dart';
import 'package:fetosense_remote_flutter/ui/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A widget that displays a YouTube player.
class FeedsYoutube extends StatefulWidget {
  /// The ID of the YouTube video to be played.
  String? _videoId;

  FeedsYoutube(String videoId, {super.key}) {
    _videoId = videoId;
  }

  @override
  _FeedsYoutubeState createState() => _FeedsYoutubeState(_videoId);
}

class _FeedsYoutubeState extends State<FeedsYoutube> {
  /// The controller for the YouTube player.
  late YoutubePlayerController _controller;

  /// The ID of the YouTube video to be played.
  final String? _videoId;

  /// The internet check utility.
  late InternetCheck _internetCheck;

  /// Indicates whether there is an internet connection.
  bool _isInternet = true;

  /// The YouTube player widget.
  late YoutubePlayer _player;

  _FeedsYoutubeState(this._videoId);

  @override
  void initState() {
    // TODO: implement initState
    _internetCheck = InternetCheck();

    _internetCheck.check().then((value) {
      if (value) {
        setState(() {
          _isInternet = true;
        });
      } else {
        setState(() {
          _isInternet = false;
        });
      }
    });
    _controller = YoutubePlayerController(
      initialVideoId: _videoId!,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
//          forceHideAnnotation: false,
        disableDragSeek: true,
        loop: false,
        hideControls: false,
        controlsVisibleAtStart: true,
        hideThumbnail: false,
        enableCaption: true,
      ),
    );
    _player = YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.teal,
      bottomActions: <Widget>[
        const SizedBox(width: 14.0),
        CurrentPosition(),
        const SizedBox(width: 8.0),
        ProgressBar(
          isExpanded: true,
          colors: ProgressBarColors(
              backgroundColor: lightPinkColor,
              bufferedColor: lightTealColor,
              handleColor: Colors.teal,
              playedColor: Colors.teal),
        ),
        RemainingDuration(),
        const SizedBox(width: 14.0),
        /*IconButton(
              icon: Icon(
                _controller.value.isFullScreen
                    ? Icons.fullscreen_exit
                    : Icons.fullscreen,
                color: AppColors.lightPinkColor,
              ),
              onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) =>
                              FullScreenVideo(
                                player: _player,
                                controller: _controller,
                              )));
              },
            ),*/
      ],
      onReady: () {
        debugPrint('Player is ready.');
        //_controller.load(widget.img);
      },
      onEnded: (data) {},
    );

    super.initState();
  }

  @override
  void dispose() {

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        child: _isInternet
            ? YoutubePlayerBuilder(
                player: _player,
                builder: (context, player) {
                  return Column(
                    children: [
                      player,
                    ],
                  );
                },
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/no_internet.svg',
                      height: MediaQuery.of(context).size.height / 3.5,
                      width: MediaQuery.of(context).size.width,
                      allowDrawingOutsideViewBox: true,
                      fit: BoxFit.cover,
                    ),
                    Text(
                      'Check Internet',
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              )

        /*YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.themeColor,
        bottomActions: <Widget>[Container()],
        onReady: () {
          debugPrint('Player is ready.');
          //_controller.load(widget.img);
        },
        onEnded: (data) {},
      ),*/
        );
  }

  /// Handles the back button press.
  /// [context] is the build context.
  /// Returns a [Future] that resolves to a boolean indicating whether to pop the route.
  Future<bool> _onWillPop(BuildContext context) async {
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    if (currentOrientation == Orientation.portrait) {
      _controller.toggleFullScreenMode();
    }
    return true;
  }
}
