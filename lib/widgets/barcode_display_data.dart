import 'package:flutter/material.dart';

class BarcodeDisplayData extends StatelessWidget {
  const BarcodeDisplayData(
      {super.key, required this.text, this.maxLines, this.prefixIcon});

  final String? text;
  final int? maxLines;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(8)),
        child: RichText(
          text: TextSpan(
            children: [
              if (prefixIcon != null) WidgetSpan(child: prefixIcon!),
              if (prefixIcon != null)
                WidgetSpan(
                    child: SizedBox(
                  width: 10,
                )),
              WidgetSpan(
                  child: Text(
                text!,
                overflow: maxLines == null ? null : TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    // fontSize: 16,
                    color: Theme.of(context).colorScheme.onTertiary),
              ))
            ],
          ),
          maxLines: maxLines,
        ));
  }
}
