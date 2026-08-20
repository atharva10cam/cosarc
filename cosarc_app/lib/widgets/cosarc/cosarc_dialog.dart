import 'package:flutter/material.dart';
import '../../core/theme/cosarc_spacing.dart';
import 'cosarc_button.dart';

Future<T?> showCosarcDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  String confirmLabel = 'OK',
  String? cancelLabel,
  VoidCallback? onConfirm,
  bool destructive = false,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: message != null ? Text(message) : null,
      actionsPadding: const EdgeInsets.fromLTRB(
        CosarcSpacing.lg,
        0,
        CosarcSpacing.lg,
        CosarcSpacing.lg,
      ),
      actions: [
        if (cancelLabel != null)
          CosarcButton(
            label: cancelLabel,
            variant: CosarcButtonVariant.ghost,
            expand: false,
            onPressed: () => Navigator.pop(context),
          ),
        CosarcButton(
          label: confirmLabel,
          variant: destructive
              ? CosarcButtonVariant.primary
              : CosarcButtonVariant.primary,
          expand: false,
          onPressed: () {
            Navigator.pop(context);
            onConfirm?.call();
          },
        ),
      ],
    ),
  );
}
