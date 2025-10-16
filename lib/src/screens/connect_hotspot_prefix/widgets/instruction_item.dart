part of '../../../../../viam_flutter_hotspot_provisioning_widget.dart';

class InstructionItem extends StatelessWidget {
  final String text;

  const InstructionItem({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, bottom: 20.0),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16.0,
        ),
      ),
    );
  }
}
