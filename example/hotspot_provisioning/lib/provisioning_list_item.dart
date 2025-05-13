import 'package:flutter/material.dart';

class ProvisioningListItem extends StatelessWidget {
  final String textString;
  final Widget leading;
  final bool add;

  const ProvisioningListItem({super.key, required this.textString, required this.leading, required this.add});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            width: 1.0,
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: ListTile(
            minLeadingWidth: 16.0,
            leading: !add ? leading : Icon(Icons.add, size: 24.0, color: Color(0xFFD9D9D9)),
            title: Text(
              textString,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
