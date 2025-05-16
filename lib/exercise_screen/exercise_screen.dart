import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExerciseScreen extends StatefulWidget {
  final String title = 'Exercise';
  final int index;

  const ExerciseScreen({
    super.key,
    required this.index,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.pop(),
        ),
        title: Center(
          child: Text('${widget.title} ${widget.index}'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                context.pushNamed(
                  'train_zone_page',
                  pathParameters: {
                    'title': 'Train Zone Page',
                    'repetitions': '4',
                    'accuracy': '0.8',
                    'tempo': '80.0',
                  },
                );
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.purple,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
