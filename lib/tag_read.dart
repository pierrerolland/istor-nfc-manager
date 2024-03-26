import 'dart:typed_data';

import 'package:istor_nfc_manager/stories_gateway.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:flutter/material.dart';

class TagRead extends StatefulWidget {
  const TagRead({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TagReadState();
  }
}

class _TagReadState extends State<TagRead> {
  String? _lastId;

  List<String> _stories = [];

  bool _listLoading = false;

  String? _titleLoading;

  String? _error;

  onTagDiscovered(NfcTag tag) async {
    try {
      setState(() {
        _lastId = (NfcA.from(tag)?.identifier ??
            NfcB.from(tag)?.identifier ??
            NfcF.from(tag)?.identifier ??
            NfcV.from(tag)?.identifier ??
            Uint8List(0)).join(".");
      });

      onIdChanged();

      await NfcManager.instance.stopSession();
    } catch (e) {
      await NfcManager.instance.stopSession().catchError((_) { /* no op */ });
    }
  }

  Future<void> onIdChanged() async {
    setState(() {
      _listLoading = true;
      _error = null;
    });

    try {
      final stories = await StoriesGateway().getUnassignedStories();

      setState(() {
        _stories = stories;
        _listLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _lastId = null;
        _listLoading = false;
      });
    }
  }

  Future<void> onAssignStoryButtonPressed(String title) async {
    if (_lastId == null) {
      return Future(() => null);
    }

    setState(() {
      _titleLoading = title;
    });

    await StoriesGateway().assignStoryToCard(title, _lastId ?? '');

    setState(() {
      _lastId = null;
      _stories = [];
      _titleLoading = null;
    });

    NfcManager.instance.startSession(onDiscovered: (tag) async { onTagDiscovered(tag); });
  }

  @override
  void initState() {
    super.initState();
    NfcManager.instance.startSession(
      onDiscovered: (tag) async { onTagDiscovered(tag); },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Istor NFC Manager"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _lastId != null ? [
            const Text(
              'Last scanned id:',
            ),
            Text(
              '$_lastId',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ..._stories.map((story) => story == _titleLoading ? const CircularProgressIndicator(color: Colors.deepPurple) : ElevatedButton(
              child: Text(story),
              onPressed: () => onAssignStoryButtonPressed(story),
            )),
            ..._listLoading ? [
              const CircularProgressIndicator(color: Colors.deepPurple)
            ] : [],
          ] : [
            Text('Please scan...', style: Theme.of(context).textTheme.headlineMedium),
            ..._error != null ? [
              Text(_error ?? '', style: const TextStyle(color: Colors.red),)
            ] : []
          ],
        ),
      ),
    );
  }
}
