import 'package:flutter/material.dart';

class LogWidget extends StatefulWidget {
  final Stream<String> stream;
  final int maxLines;

  const LogWidget({
    super.key,
    required this.stream,
    this.maxLines = 50,
  });

  @override
  State<LogWidget> createState() => _LogWidgetState();
}

class _LogWidgetState extends State<LogWidget> {
  final List<String> _log = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.stream.listen(_onNewMessage);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(8),
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _log.length,
          itemBuilder: (context, index) {
            return Text(
              _log[index],
              style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
            );
          },
        ),
      ),
    );
  }

  void _onNewMessage(line) {
    setState(() {
      _log.add(line);

      if (_log.length > widget.maxLines) {
        _log.removeRange(0, _log.length - widget.maxLines);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
