import 'package:flutter/material.dart';
import '../../models/tag.dart';

class TagCard extends StatelessWidget {
  final Tag tag;
  
  const TagCard({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(tag.name),
        subtitle: Text('${tag.value} ${tag.unit}'),
        trailing: Text(tag.quality.toString()),
      ),
    );
  }
}