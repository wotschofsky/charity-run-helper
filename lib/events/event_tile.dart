import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

import '../models/event.dart';
import '../ui/icon_info_item.dart';

class EventTile extends StatelessWidget {
  const EventTile(this.data);

  final Event data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => VxNavigator.of(context).push(
            Uri(path: '/events/details', queryParameters: {'id': data.id})),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  data.title,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 24),
                ),
              ),
              IconInfoItem(
                  icon: Icons.calendar_today,
                  label: DateFormat.yMd().format(data.startTime)),
            ],
          ),
        ),
      ),
    );
  }
}
