part of '../screens.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({Key? key}) : super(key: key);

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEMO'),
        centerTitle: true,
        actions: const [
          /* IconButton(
            onPressed: () {

            },
            icon: Icon(Icons.cast),
          ),*/
        ],
      ),
      body: const Center(child: Text('hello')),
    );
  }
}
