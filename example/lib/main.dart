import 'package:flutter/material.dart';
import 'package:flutter_flipperkit/flutter_flipperkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlipperClient flipperClient = FlipperClient.getDefault();

  flipperClient.addPlugin(FlipperNetworkPlugin());
  flipperClient.addPlugin(FlipperSharedPreferencesPlugin());
  // flipperClient.addPlugin(new FlipperDatabaseBrowserPlugin());
  flipperClient.addPlugin(FlipperReduxInspectorPlugin());
  flipperClient.start();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void _testNetwork() {
    FlipperNetworkPlugin flipperNetworkPlugin =
        FlipperClient.getDefault().getPlugin("Network") as FlipperNetworkPlugin;

    String uniqueId = const Uuid().v4();
    RequestInfo requestInfo = RequestInfo(
      requestId: uniqueId,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      uri: 'https://example.com/account/login',
      headers: {}..putIfAbsent("Content-Type", () => "application/json"),
      method: 'POST',
      body: {}
        ..putIfAbsent("username", () => "example")
        ..putIfAbsent("password", () => "123456"),
    );

    flipperNetworkPlugin.reportRequest(requestInfo);

    ResponseInfo responseInfo = ResponseInfo(
      requestId: uniqueId,
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      statusCode: 200,
      headers: {}..putIfAbsent("Content-Type", () => "application/json"),
      body: {}
        ..putIfAbsent("username", () => "lijy91")
        ..putIfAbsent("age", () => 28)
        ..putIfAbsent("name", () => "LiJianying"),
    );

    flipperNetworkPlugin.reportResponse(responseInfo);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            ListTile(
              title: const Text("Preferences"),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                int counter = (prefs.getInt('counter') ?? 0) + 1;
                await prefs.setInt('counter', counter);
              },
            ),
            ListTile(
              title: const Text("Network"),
              onTap: _testNetwork,
            ),
            ListTile(
              title: const Text("ReduxInspector"),
              onTap: () {
                FlipperReduxInspectorPlugin flipperReduxInspectorPlugin =
                    FlipperClient.getDefault()
                            .getPlugin("flipper-plugin-reduxinspector")
                        as FlipperReduxInspectorPlugin;

                ActionInfo actionInfo = ActionInfo(
                  uniqueId: const Uuid().v4(),
                  actionType: 'LoginSuccess',
                  timeStamp: DateTime.now().millisecondsSinceEpoch,
                  payload: {}
                    ..putIfAbsent("username", () => "lijy91@foxmail.com")
                    ..putIfAbsent("password", () => "123456"),
                  nextState: {}
                    ..putIfAbsent("user", () => {"name": "LiJianying"}),
                );
                flipperReduxInspectorPlugin.report(actionInfo);
              },
            ),
          ],
        ),
      ),
    );
  }
}
