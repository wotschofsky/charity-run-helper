import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SponsorTile extends StatelessWidget {
  SponsorTile({required this.id, required this.name, required this.amount});

  final String id;
  final String name;
  final double amount;

  void delete() {
    FirebaseFirestore.instance.collection(('participations')).doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      title: Text(name, style: TextStyle(fontSize: 20)),
      subtitle: Text('${amount.toStringAsFixed(2)}€ / km'),
      trailing: IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: const Text('This sponsor will be lost forever!'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Abort')),
                      TextButton(
                          onPressed: delete, child: const Text('Confirm')),
                    ],
                  ));
        },
        icon: Icon(Icons.delete_forever),
      ),
    ));
  }
}
