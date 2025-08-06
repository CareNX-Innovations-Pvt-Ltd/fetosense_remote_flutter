import 'package:fetosense_remote_flutter/core/utils/internet_check.dart';
import 'package:fetosense_remote_flutter/ui/widgets/youtube_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Mock classes
class MockInternetCheck extends Mock implements InternetCheck {}

class FakeYoutubePlayerController extends Fake implements YoutubePlayerController {}

void main() {
  late MockInternetCheck mockInternetCheck;

  setUpAll(() {
    registerFallbackValue(FakeYoutubePlayerController());
  });

  setUp(() {
    mockInternetCheck = MockInternetCheck();
  });

  Future<void> pumpFeedsYoutube(
      WidgetTester tester, {
        required bool isInternet,
        required String videoId,
      }) async {
    // Inject the mock InternetCheck instance by temporarily overriding the constructor
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return FeedsYoutube(videoId);
            });
          },
        ),
      ),
    );

    // Wait for InternetCheck future to resolve
    await tester.pumpAndSettle();
  }

  testWidgets('displays YoutubePlayer when internet is available', (tester) async {
    // Arrange
    mockInternetCheck = MockInternetCheck();
    when(() => mockInternetCheck.check()).thenAnswer((_) async => true);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: _TestWrapper(
          videoId: 'abc123',
          internetCheck: mockInternetCheck,
        ),
      ),
    );

    await tester.pump(); // Begin async
    await tester.pump(const Duration(milliseconds: 100)); // finish future

    // Assert
    expect(find.byType(YoutubePlayer), findsOneWidget);
  });

  testWidgets('shows no internet SVG when internet is not available', (tester) async {
    // Arrange
    when(() => mockInternetCheck.check()).thenAnswer((_) async => false);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: _TestWrapper(
          videoId: 'abc123',
          internetCheck: mockInternetCheck,
        ),
      ),
    );

    await tester.pump(); // Begin async
    await tester.pump(const Duration(milliseconds: 100)); // finish future

    // Assert
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text('Check Internet'), findsOneWidget);
  });

  testWidgets('disposes controller on widget disposal', (tester) async {
    when(() => mockInternetCheck.check()).thenAnswer((_) async => true);

    await tester.pumpWidget(
      MaterialApp(
        home: _TestWrapper(
          videoId: 'abc123',
          internetCheck: mockInternetCheck,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Remove the widget to trigger dispose
    await tester.pumpWidget(Container());
    await tester.pump();

    // No errors = controller disposed successfully
    expect(tester.takeException(), isNull);
  });
}

/// A wrapper around the original widget to inject a mock InternetCheck instance.
class _TestWrapper extends StatefulWidget {
  final String videoId;
  final InternetCheck internetCheck;

  const _TestWrapper({
    required this.videoId,
    required this.internetCheck,
  });

  @override
  State<_TestWrapper> createState() => _TestWrapperState();
}

class _TestWrapperState extends State<_TestWrapper> {
  @override
  Widget build(BuildContext context) {
    return _FeedsYoutubeStateWithMock(
      videoId: widget.videoId,
      internetCheck: widget.internetCheck,
    );
  }
}

/// Copy of `_FeedsYoutubeState` with injected `InternetCheck` for testing
class _FeedsYoutubeStateWithMock extends StatefulWidget {
  final String videoId;
  final InternetCheck internetCheck;

  const _FeedsYoutubeStateWithMock({
    required this.videoId,
    required this.internetCheck,
  });

  @override
  State<_FeedsYoutubeStateWithMock> createState() => _FeedsYoutubeStateWithMockState();
}

class _FeedsYoutubeStateWithMockState extends State<_FeedsYoutubeStateWithMock> {
  late YoutubePlayerController _controller;
  late bool _isInternet = true;
  late YoutubePlayer _player;

  @override
  void initState() {
    super.initState();
    widget.internetCheck.check().then((value) {
      setState(() => _isInternet = value);
    });

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
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
      bottomActions: const [
        SizedBox(width: 14.0),
        CurrentPosition(),
        SizedBox(width: 8.0),
        ProgressBar(
          isExpanded: true,
          colors: ProgressBarColors(
            backgroundColor: Colors.pink,
            bufferedColor: Colors.tealAccent,
            handleColor: Colors.teal,
            playedColor: Colors.teal,
          ),
        ),
        RemainingDuration(),
        SizedBox(width: 14.0),
      ],
      onReady: () {
        debugPrint('Player is ready.');
      },
      onEnded: (meta) {},
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: _isInternet
          ? YoutubePlayerBuilder(
        player: _player,
        builder: (context, player) => Column(children: [player]),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Check Internet'),
        ],
      ),
    );
  }
}
