import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExercisesListScreen extends StatefulWidget {
  final String title = 'Exercises List';

  const ExercisesListScreen({super.key});

  @override
  State<ExercisesListScreen> createState() => _ExercisesListScreenState();
}

class _ExercisesListScreenState extends State<ExercisesListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(widget.title),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                context.pushNamed(
                  'exercise',
                  pathParameters: {'index': index.toString()},
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
