import 'package:ez_grid_view/ez_grid_view.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('EzGridView Demo')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Problem: EzGridView inside a Column',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // This would normally crash, but EzGridView handles it.
            // In debug mode, you will see a red border and a console message.
            EzGridView.builder(
              itemCount: 50,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) =>
                  Card(child: Center(child: Text('Item #$index'))),
            ),
            const Divider(height: 30, thickness: 2),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Solution: Wrap EzGridView in an Expanded',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // To fix the layout permanently, wrap EzGridView in a widget
            // that provides bounded height, like Expanded.
            Expanded(
              child: EzGridView.builder(
                itemCount: 50,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) =>
                    Card(child: Center(child: Text('Corrected Item #$index'))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
