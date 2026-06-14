import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/repository.dart';
import '../widgets/async_view.dart';
import '../widgets/brand_spinner.dart';
import 'add_expense_sheet.dart';

/// Drives the OCR flow: pick a photo → scan → open Add Expense prefilled with
/// whatever was detected. Returns true if an expense was created.
class ScanReceipt {
  static Future<bool> run(BuildContext context, {String? groupId}) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery, // simulator has no camera; gallery works
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (file == null || !context.mounted) return false;

    // Loading dialog while OCR runs.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: BrandSpinner(label: 'Reading your receipt…'),
      ),
    );

    Map<String, dynamic> ocr = {};
    String? error;
    try {
      ocr = await Repository.instance.scanReceipt(await file.readAsBytes());
    } catch (e) {
      error = e.toString();
    }
    if (!context.mounted) return false;
    Navigator.of(context).pop(); // close loading

    if (error != null) {
      showFailure(context, error);
      return false;
    }

    final total = (ocr['total'] as num?)?.toDouble();
    final merchant = ocr['merchant'] as String?;
    final category = ocr['category'] as String?;
    if (ocr['used_ocr'] != true || total == null) {
      showFailure(context,
          "Couldn't read the total — add the details manually.");
    } else {
      showSuccess(context, 'Detected ${merchant ?? 'receipt'} · ₹$total');
    }

    // Prefill Add Expense with the detected values.
    return AddExpenseSheet.show(
      context,
      groupId: groupId,
      prefillName: merchant,
      prefillAmount: total,
      prefillCategory: category,
    );
  }
}
