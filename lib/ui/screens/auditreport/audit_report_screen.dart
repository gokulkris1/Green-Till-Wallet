import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:greentill/base/base_screen.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/models/responses/getreceiptlist_response.dart';
import 'package:greentill/ui/res/color_resources.dart';
import 'package:greentill/ui/res/dimen_resources.dart';
import 'package:greentill/ui/res/image_resources.dart';
import 'package:greentill/utils/app_constants.dart';
import 'package:greentill/utils/common_widgets.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:greentill/utils/strings.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class AuditReportScreen extends BaseStatefulWidget {
  const AuditReportScreen({super.key});

  @override
  _AuditReportScreenState createState() => _AuditReportScreenState();
}

class _AuditReportScreenState extends BaseState<AuditReportScreen>
    with BasicScreen {
  static const int _defaultTrialDays = 30;
  final String userid = prefs.getString(SharedPrefHelper.USER_ID);
  bool isLoadingLocal = true;
  bool isExporting = false;
  List<Datum> receipts = [];
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    setState(() {
      isLoadingLocal = true;
    });
    final response = await bloc.userRepository.getreceiptList(
      int.tryParse(userid) ?? 0,
      direction: "DESC",
      timezone: DateTime.now().timeZoneName.toString(),
    );
    if (!mounted) {
      return;
    }
    if (response.status == 1) {
      setState(() {
        receipts = response.data?.receiptList ?? [];
        isLoadingLocal = false;
      });
      return;
    }
    if (response.apiStatusCode == 401) {
      showMessage(response.message ?? "", () {
        if (mounted) {
          setState(() {
            isShowMessage = false;
            isLoadingLocal = false;
            logoutaccount();
            return bloc.add(Login());
          });
        }
      });
      return;
    }
    showMessage(response.message ?? "Unable to load report data", () {
      if (mounted) {
        setState(() {
          isShowMessage = false;
          isLoadingLocal = false;
        });
      }
    });
  }

  List<Datum> get _filteredReceipts {
    return receipts.where((r) {
      final date = r.purchaseDate ?? r.updatedAt;
      if (date == null) {
        return false;
      }
      return date.month == selectedMonth && date.year == selectedYear;
    }).toList();
  }

  double _parseAmount(dynamic value) {
    if (value == null) {
      return 0;
    }
    final text = value.toString().replaceAll(RegExp(r"[^0-9\.\-]"), "");
    return double.tryParse(text) ?? 0;
  }

  double _estimatedVatFromGross(double grossAmount) {
    if (grossAmount <= 0) {
      return 0;
    }
    return grossAmount * 0.23 / 1.23;
  }

  String _inferCategory(Datum receipt) {
    final haystack =
        "${receipt.storeName ?? ""} ${receipt.description ?? ""}".toLowerCase();
    if (haystack.contains("fuel") ||
        haystack.contains("diesel") ||
        haystack.contains("petrol")) {
      return "Fuel";
    }
    if (haystack.contains("tool") ||
        haystack.contains("hardware") ||
        haystack.contains("screwfix") ||
        haystack.contains("wickes") ||
        haystack.contains("b&q")) {
      return "Tools & Materials";
    }
    if (haystack.contains("meal") ||
        haystack.contains("coffee") ||
        haystack.contains("restaurant")) {
      return "Meals";
    }
    if (haystack.contains("hotel") || haystack.contains("stay")) {
      return "Accommodation";
    }
    if (haystack.contains("office") || haystack.contains("stationery")) {
      return "Office Supplies";
    }
    return "Other";
  }

  Map<String, double> _categoryTotals(List<Datum> source) {
    final output = <String, double>{};
    for (final receipt in source) {
      final category = _inferCategory(receipt);
      output[category] = (output[category] ?? 0) + _parseAmount(receipt.amount);
    }
    return output;
  }

  List<String> _buildCsvLines(List<Datum> filtered, String monthLabel) {
    final businessTotal = filtered
        .where((r) => (r.tagType ?? "").toUpperCase() == "BUSINESS")
        .fold<double>(0, (sum, r) => sum + _parseAmount(r.amount));
    final personalTotal = filtered
        .where((r) => (r.tagType ?? "").toUpperCase() != "BUSINESS")
        .fold<double>(0, (sum, r) => sum + _parseAmount(r.amount));
    final estimatedVat = _estimatedVatFromGross(businessTotal);
    final categoryTotals = _categoryTotals(filtered);
    final lines = <String>[
      "Green Till Accounting Export,$monthLabel",
      "Generated At,${DateTime.now().toIso8601String()}",
      "Receipt Count,${filtered.length}",
      "Business Total,${businessTotal.toStringAsFixed(2)}",
      "Personal Total,${personalTotal.toStringAsFixed(2)}",
      "Estimated VAT Reclaim,${estimatedVat.toStringAsFixed(2)}",
      "",
      "Category,Amount"
    ];
    for (final entry in categoryTotals.entries) {
      lines.add("${entry.key},${entry.value.toStringAsFixed(2)}");
    }
    lines
      ..add("")
      ..add(
          "Date,Store,Category,Tag,Amount,Currency,Estimated VAT,Receipt URL,Warranty Cards");
    for (final receipt in filtered) {
      final date = receipt.purchaseDate ?? receipt.updatedAt;
      final formattedDate =
          date != null ? DateFormat("yyyy-MM-dd").format(date) : "";
      final store = (receipt.storeName ?? "").toString().replaceAll(",", " ");
      final tag = (receipt.tagType ?? "PERSONAL").replaceAll(",", " ");
      final category = _inferCategory(receipt).replaceAll(",", " ");
      final amountValue = _parseAmount(receipt.amount);
      final amount = amountValue.toStringAsFixed(2);
      final currency = (receipt.currency ?? "").toString();
      final estimatedVat = (tag.toUpperCase() == "BUSINESS")
          ? _estimatedVatFromGross(amountValue).toStringAsFixed(2)
          : "0.00";
      final url = (receipt.path ?? "").replaceAll(",", " ");
      final warrantyCount = (receipt.warrantyCards?.length ?? 0).toString();
      lines.add(
          "$formattedDate,$store,$category,$tag,$amount,$currency,$estimatedVat,$url,$warrantyCount");
    }
    return lines;
  }

  String _buildHtmlReport(List<Datum> filtered, String monthLabel,
      Map<String, double> categoryMap) {
    final businessTotal = filtered
        .where((r) => (r.tagType ?? "").toUpperCase() == "BUSINESS")
        .fold<double>(0, (sum, r) => sum + _parseAmount(r.amount));
    final personalTotal = filtered
        .where((r) => (r.tagType ?? "").toUpperCase() != "BUSINESS")
        .fold<double>(0, (sum, r) => sum + _parseAmount(r.amount));
    final estimatedVat = _estimatedVatFromGross(businessTotal);
    final rows = filtered.map((receipt) {
      final date = receipt.purchaseDate ?? receipt.updatedAt;
      final formattedDate =
          date != null ? DateFormat("yyyy-MM-dd").format(date) : "";
      final store = (receipt.storeName ?? "").toString();
      final tag = (receipt.tagType ?? "PERSONAL").toString().toUpperCase();
      final category = _inferCategory(receipt);
      final amountValue = _parseAmount(receipt.amount);
      final amount = amountValue.toStringAsFixed(2);
      final currency = (receipt.currency ?? "").toString();
      final receiptUrl = (receipt.path ?? "").toString();
      return "<tr><td>$formattedDate</td><td>$store</td><td>$category</td><td>$tag</td><td>$amount</td><td>$currency</td><td>$receiptUrl</td></tr>";
    }).join();
    final categoryRows = categoryMap.entries
        .map((e) =>
            "<tr><td>${e.key}</td><td>${e.value.toStringAsFixed(2)}</td></tr>")
        .join();
    return """
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Green Till Accounting Report $monthLabel</title>
  <style>
    body { font-family: Arial, sans-serif; color: #0f172a; margin: 20px; }
    h1, h2 { margin-bottom: 8px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
    th, td { border: 1px solid #e2e8f0; padding: 8px; text-align: left; font-size: 12px; }
    th { background: #f8fafc; }
    .summary { margin-bottom: 16px; }
  </style>
</head>
<body>
  <h1>Green Till Accounting Report</h1>
  <div class="summary">
    <div>Month: $monthLabel</div>
    <div>Generated at: ${DateTime.now().toIso8601String()}</div>
    <div>Receipt count: ${filtered.length}</div>
    <div>Business total: EUR ${businessTotal.toStringAsFixed(2)}</div>
    <div>Personal total: EUR ${personalTotal.toStringAsFixed(2)}</div>
    <div>Estimated VAT reclaim: EUR ${estimatedVat.toStringAsFixed(2)}</div>
  </div>
  <h2>Category Breakdown</h2>
  <table>
    <thead><tr><th>Category</th><th>Amount (EUR)</th></tr></thead>
    <tbody>$categoryRows</tbody>
  </table>
  <h2>Receipt Register</h2>
  <table>
    <thead><tr><th>Date</th><th>Store</th><th>Category</th><th>Tag</th><th>Amount</th><th>Currency</th><th>Receipt URL</th></tr></thead>
    <tbody>$rows</tbody>
  </table>
</body>
</html>
""";
  }

  String _normalizeFileSegment(String raw, {String fallback = "file"}) {
    final cleaned = raw
        .replaceAll(RegExp(r"[^a-zA-Z0-9\-_ ]"), "")
        .trim()
        .replaceAll(RegExp(r"\s+"), "_");
    if (cleaned.isEmpty) {
      return fallback;
    }
    return cleaned;
  }

  String _resolveFileExtension(String source, {String fallback = "jpg"}) {
    if (source.trim().isEmpty) {
      return fallback;
    }
    final uri = Uri.tryParse(source);
    final ext = p.extension(uri?.path ?? source).replaceAll(".", "").trim();
    if (ext.isEmpty) {
      return fallback;
    }
    return ext.toLowerCase();
  }

  String _resolveCurrency(List<Datum> source) {
    for (final receipt in source) {
      final value = (receipt.currency ?? "").toString().trim();
      if (value.isNotEmpty) {
        return value.toUpperCase();
      }
    }
    return "EUR";
  }

  Future<File?> _downloadRemoteFile(String url, File destination) async {
    final normalized = url.trim();
    if (normalized.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(normalized);
    if (uri == null || (!uri.isScheme("http") && !uri.isScheme("https"))) {
      return null;
    }
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 30));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      await destination.parent.create(recursive: true);
      await destination.writeAsBytes(response.bodyBytes, flush: true);
      return destination;
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _buildPdfReport(
    List<Datum> filtered,
    String monthLabel,
    Map<String, double> categoryMap,
  ) async {
    final businessTotal = filtered
        .where((r) => (r.tagType ?? "").toUpperCase() == "BUSINESS")
        .fold<double>(0, (sum, r) => sum + _parseAmount(r.amount));
    final personalTotal = filtered
        .where((r) => (r.tagType ?? "").toUpperCase() != "BUSINESS")
        .fold<double>(0, (sum, r) => sum + _parseAmount(r.amount));
    final currency = _resolveCurrency(filtered);
    final pdf = pw.Document();

    final categoryRows = categoryMap.entries
        .map((entry) =>
            [entry.key, "${entry.value.toStringAsFixed(2)} $currency"])
        .toList();

    final receiptRows = filtered.map((receipt) {
      final date = receipt.purchaseDate ?? receipt.updatedAt;
      final dateText =
          date == null ? "-" : DateFormat("yyyy-MM-dd").format(date);
      final amount = _parseAmount(receipt.amount).toStringAsFixed(2);
      final tagType = (receipt.tagType ?? "PERSONAL").toUpperCase();
      final category = _inferCategory(receipt);
      return [
        dateText,
        (receipt.storeName ?? "Unknown").toString(),
        category,
        tagType,
        "$amount $currency",
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
        ),
        build: (context) {
          return [
            pw.Text(
              "Green Till Accounting Report",
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text("Month: $monthLabel"),
            pw.Text("Generated: ${DateTime.now().toIso8601String()}"),
            pw.SizedBox(height: 12),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Receipts: ${filtered.length}"),
                        pw.Text(
                            "Business total: ${businessTotal.toStringAsFixed(2)} $currency"),
                        pw.Text(
                            "Personal total: ${personalTotal.toStringAsFixed(2)} $currency"),
                        pw.Text(
                            "VAT reclaim estimate: ${_estimatedVatFromGross(businessTotal).toStringAsFixed(2)} $currency"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Text(
              "Category Breakdown",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: const ["Category", "Amount"],
              data: categoryRows,
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerStyle:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey100),
            ),
            pw.SizedBox(height: 14),
            pw.Text(
              "Receipt Register",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            if (receiptRows.isEmpty)
              pw.Text("No receipts for selected month")
            else
              pw.TableHelper.fromTextArray(
                headers: const [
                  "Date",
                  "Store",
                  "Category",
                  "Tag",
                  "Amount",
                ],
                data: receiptRows,
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerStyle:
                    pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey100),
              ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _generatePdfReport() async {
    if (!_canExport) {
      await _guardOrOpenBilling();
      return;
    }

    final monthLabel =
        DateFormat("yyyy-MM").format(DateTime(selectedYear, selectedMonth, 1));
    final filtered = _filteredReceipts;
    if (filtered.isEmpty) {
      showMessage("No receipts found for $monthLabel", () {
        if (mounted) {
          setState(() {
            isShowMessage = false;
          });
        }
      });
      return;
    }

    setState(() {
      isExporting = true;
    });

    try {
      final bytes = await _buildPdfReport(
        filtered,
        monthLabel,
        _categoryTotals(filtered),
      );
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/greentill-expense-report-$monthLabel.pdf");
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: "Green Till PDF report ($monthLabel)",
        subject: "PDF report ($monthLabel)",
      );
    } catch (e) {
      showMessage("Unable to generate PDF: $e", () {
        if (mounted) {
          setState(() {
            isShowMessage = false;
          });
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          isExporting = false;
        });
      }
    }
  }

  double get _totalAmount =>
      _filteredReceipts.fold(0, (sum, e) => sum + _parseAmount(e.amount));

  int get _attachmentCount => _filteredReceipts.fold(
      0, (sum, e) => sum + (e.warrantyCards?.length ?? 0) + 1);

  bool get _isPro =>
      prefs.getBool(SharedPrefHelper.BILLING_PRO_ACTIVE, defaultValue: false);

  bool get _isTrialActive {
    final startedAtMs =
        prefs.getInt(SharedPrefHelper.BILLING_TRIAL_STARTED_AT_MS);
    if (startedAtMs <= 0) {
      return false;
    }
    final trialDays = prefs.getInt(SharedPrefHelper.BILLING_TRIAL_DAYS,
        defaultValue: _defaultTrialDays);
    final startedAt = DateTime.fromMillisecondsSinceEpoch(startedAtMs);
    final expiresAt = startedAt.add(Duration(days: trialDays));
    return DateTime.now().isBefore(expiresAt);
  }

  bool get _canExport => _isPro || _isTrialActive;

  Future<void> _guardOrOpenBilling() async {
    if (_canExport) {
      return;
    }
    showMessage(reportExportLocked, () {
      if (mounted) {
        setState(() {
          isShowMessage = false;
          bloc.add(BillingEvent());
        });
      }
    });
  }

  Future<void> _generateCsvReport() async {
    if (!_canExport) {
      await _guardOrOpenBilling();
      return;
    }

    final monthLabel =
        DateFormat("yyyy-MM").format(DateTime(selectedYear, selectedMonth, 1));
    final filtered = _filteredReceipts;
    final lines = _buildCsvLines(filtered, monthLabel);

    final fileName = "greentill-expense-report-$monthLabel.csv";
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsString(lines.join("\n"));

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Green Till expense report ($monthLabel)",
      subject: "Expense report ($monthLabel)",
    );
  }

  Future<void> _generateArchiveManifest() async {
    if (!_canExport) {
      await _guardOrOpenBilling();
      return;
    }

    final monthLabel =
        DateFormat("yyyy-MM").format(DateTime(selectedYear, selectedMonth, 1));
    final filtered = _filteredReceipts;
    if (filtered.isEmpty) {
      showMessage("No receipts found for $monthLabel", () {
        if (mounted) {
          setState(() {
            isShowMessage = false;
          });
        }
      });
      return;
    }

    setState(() {
      isExporting = true;
    });

    final businessTotal = filtered
        .where((r) => (r.tagType ?? "").toUpperCase() == "BUSINESS")
        .fold<double>(0, (sum, r) => sum + _parseAmount(r.amount));
    final personalTotal = filtered
        .where((r) => (r.tagType ?? "").toUpperCase() != "BUSINESS")
        .fold<double>(0, (sum, r) => sum + _parseAmount(r.amount));
    final currency = _resolveCurrency(filtered);
    final categoryMap = _categoryTotals(filtered);
    final payload = {
      "month": monthLabel,
      "generatedAt": DateTime.now().toIso8601String(),
      "receiptCount": filtered.length,
      "totalAmount": _totalAmount,
      "currency": currency,
      "businessTotal": businessTotal,
      "personalTotal": personalTotal,
      "estimatedVatReclaim": _estimatedVatFromGross(businessTotal),
      "categoryBreakdown": categoryMap.map((key, value) =>
          MapEntry<String, String>(key, value.toStringAsFixed(2))),
      "receipts": filtered
          .map((r) => {
                "receiptId": r.receiptId,
                "storeName": r.storeName,
                "tagType": r.tagType,
                "amount": r.amount,
                "currency": r.currency,
                "purchaseDate": r.purchaseDate?.toIso8601String(),
                "receiptUrl": r.path,
                "warrantyCards":
                    r.warrantyCards?.map((w) => w.path ?? "").toList() ?? [],
              })
          .toList(),
    };

    try {
      final nowStamp = DateFormat("yyyyMMdd-HHmmss").format(DateTime.now());
      final tempDir = await getTemporaryDirectory();
      final packageRoot = Directory(
          "${tempDir.path}/greentill-accounting-$monthLabel-$nowStamp");
      await packageRoot.create(recursive: true);

      final reportsDir = Directory("${packageRoot.path}/reports");
      final receiptsDir = Directory("${packageRoot.path}/receipts");
      final warrantyDir = Directory("${packageRoot.path}/warranty_cards");
      await reportsDir.create(recursive: true);
      await receiptsDir.create(recursive: true);
      await warrantyDir.create(recursive: true);

      final csvFile =
          File("${reportsDir.path}/greentill-expense-report-$monthLabel.csv");
      await csvFile
          .writeAsString(_buildCsvLines(filtered, monthLabel).join("\n"));

      final jsonFile =
          File("${reportsDir.path}/greentill-archive-$monthLabel.json");
      await jsonFile
          .writeAsString(const JsonEncoder.withIndent("  ").convert(payload));

      final htmlFile =
          File("${reportsDir.path}/greentill-expense-report-$monthLabel.html");
      await htmlFile.writeAsString(
        _buildHtmlReport(filtered, monthLabel, categoryMap),
      );

      final pdfFile =
          File("${reportsDir.path}/greentill-expense-report-$monthLabel.pdf");
      final pdfBytes = await _buildPdfReport(filtered, monthLabel, categoryMap);
      await pdfFile.writeAsBytes(pdfBytes, flush: true);

      int downloadedReceipts = 0;
      int failedReceipts = 0;
      int downloadedWarranty = 0;
      int failedWarranty = 0;

      for (int i = 0; i < filtered.length; i++) {
        final receipt = filtered[i];
        final baseName = _normalizeFileSegment(
          (receipt.storeName ?? "receipt").toString(),
          fallback: "receipt",
        );
        final receiptUrl = (receipt.path ?? "").toString();
        if (receiptUrl.trim().isNotEmpty) {
          final ext = _resolveFileExtension(
            receiptUrl,
            fallback: _resolveFileExtension(receipt.generatedName ?? "",
                fallback: "jpg"),
          );
          final output = File(
              "${receiptsDir.path}/${(i + 1).toString().padLeft(3, "0")}_$baseName.$ext");
          final file = await _downloadRemoteFile(receiptUrl, output);
          if (file != null) {
            downloadedReceipts++;
          } else {
            failedReceipts++;
          }
        }

        final cards = receipt.warrantyCards ?? [];
        for (int j = 0; j < cards.length; j++) {
          final cardUrl = (cards[j].path ?? "").toString();
          if (cardUrl.trim().isEmpty) {
            continue;
          }
          final ext = _resolveFileExtension(cardUrl, fallback: "jpg");
          final output = File(
              "${warrantyDir.path}/${(i + 1).toString().padLeft(3, "0")}_${(j + 1).toString().padLeft(2, "0")}_$baseName.$ext");
          final file = await _downloadRemoteFile(cardUrl, output);
          if (file != null) {
            downloadedWarranty++;
          } else {
            failedWarranty++;
          }
        }
      }

      final readmeFile = File("${packageRoot.path}/README.txt");
      await readmeFile.writeAsString([
        "Green Till Accounting Export Package",
        "Month: $monthLabel",
        "Generated: ${DateTime.now().toIso8601String()}",
        "",
        "Reports:",
        "- reports/greentill-expense-report-$monthLabel.pdf",
        "- reports/greentill-expense-report-$monthLabel.csv",
        "- reports/greentill-expense-report-$monthLabel.html",
        "- reports/greentill-archive-$monthLabel.json",
        "",
        "Receipt files downloaded: $downloadedReceipts",
        "Receipt files failed: $failedReceipts",
        "Warranty files downloaded: $downloadedWarranty",
        "Warranty files failed: $failedWarranty",
      ].join("\n"));

      final docsDir = await getApplicationDocumentsDirectory();
      final zipFile = File(
          "${docsDir.path}/greentill-accounting-package-$monthLabel-$nowStamp.zip");
      if (await zipFile.exists()) {
        await zipFile.delete();
      }

      final encoder = ZipFileEncoder();
      encoder.create(zipFile.path);
      encoder.addDirectory(packageRoot, includeDirName: false);
      encoder.close();

      await Share.shareXFiles(
        [XFile(zipFile.path)],
        text: "Green Till accounting package ($monthLabel)",
        subject: "Accounting package ($monthLabel)",
      );
    } catch (e) {
      showMessage("Unable to build archive package: $e", () {
        if (mounted) {
          setState(() {
            isShowMessage = false;
          });
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          isExporting = false;
        });
      }
    }
  }

  void _showPreviewSheet() {
    final monthLabel =
        DateFormat("yyyy-MM").format(DateTime(selectedYear, selectedMonth, 1));
    final filtered = _filteredReceipts;
    final categoryTotals = _categoryTotals(filtered);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(HORIZONTAL_PADDING),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  getTitle("Export Preview · $monthLabel",
                      weight: FontWeight.w700,
                      fontSize: BUTTON_FONT_SIZE,
                      color: gpTextPrimary),
                  const SizedBox(height: 8),
                  getSmallText(
                    "${filtered.length} receipts · EUR ${_totalAmount.toStringAsFixed(2)}",
                    color: gpTextSecondary,
                    weight: FontWeight.w600,
                    fontSize: CAPTION_TEXT_FONT_SIZE,
                  ),
                  const SizedBox(height: 14),
                  getSmallText(
                    categoryBreakdown,
                    color: gpTextPrimary,
                    weight: FontWeight.w700,
                    fontSize: CAPTION_TEXT_FONT_SIZE,
                  ),
                  const SizedBox(height: 8),
                  ...categoryTotals.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: getSmallText(entry.key,
                                  color: gpTextSecondary,
                                  fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE),
                            ),
                            getSmallText(
                              "EUR ${entry.value.toStringAsFixed(2)}",
                              color: gpTextPrimary,
                              weight: FontWeight.w700,
                              fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  getSmallText(
                    "First 5 receipt rows",
                    color: gpTextPrimary,
                    weight: FontWeight.w700,
                    fontSize: CAPTION_TEXT_FONT_SIZE,
                  ),
                  const SizedBox(height: 8),
                  ...filtered.take(5).map((receipt) {
                    final amount = _parseAmount(receipt.amount);
                    final date = receipt.purchaseDate ?? receipt.updatedAt;
                    final dateText = date == null
                        ? "-"
                        : DateFormat("dd MMM yyyy").format(date);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: gpBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: getSmallText(
                                "${receipt.storeName ?? "Unknown"} · $dateText",
                                color: gpTextSecondary,
                                fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                                lines: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            getSmallText(
                              "EUR ${amount.toStringAsFixed(2)}",
                              color: gpTextPrimary,
                              weight: FontWeight.w700,
                              fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final months = List.generate(12, (i) => i + 1);
    final years = [selectedYear - 1, selectedYear, selectedYear + 1];
    final monthName =
        DateFormat("MMMM").format(DateTime(selectedYear, selectedMonth));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: gpLight,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(deviceHeight * 0.07),
        child: Container(
          height: deviceHeight * 0.07,
          width: deviceWidth,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            color: gpLight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HORIZONTAL_PADDING,
              vertical: VERTICAL_PADDING,
            ),
            child: Row(
              children: [
                GestureDetector(
                  child: Image.asset(
                    IC_BACK_ARROW_TWO_COLOR,
                    height: 24,
                    width: 24,
                    fit: BoxFit.fill,
                  ),
                  onTap: () {
                    bloc.add(SideMenu());
                  },
                ),
                SizedBox(width: deviceWidth * 0.025),
                appBarHeader(
                  monthlyReportExport,
                  fontSize: BUTTON_FONT_SIZE,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadReceipts,
                  icon: const Icon(Icons.refresh, color: gpTextSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoadingLocal
          ? loader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(HORIZONTAL_PADDING),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selectedMonth,
                          decoration: const InputDecoration(
                            labelText: "Month",
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: months
                              .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(DateFormat("MMMM")
                                      .format(DateTime(selectedYear, m, 1)))))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              selectedMonth = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selectedYear,
                          decoration: const InputDecoration(
                            labelText: "Year",
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: years
                              .map((y) => DropdownMenuItem(
                                  value: y, child: Text(y.toString())))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              selectedYear = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: gpBorder),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getSmallText(
                            "Report preview · $monthName $selectedYear",
                            color: gpTextSecondary,
                            fontSize: CAPTION_TEXT_FONT_SIZE,
                            weight: FontWeight.w600),
                        const SizedBox(height: 6),
                        getTitle(
                            "${_filteredReceipts.length} receipts · EUR ${_totalAmount.toStringAsFixed(2)}",
                            weight: FontWeight.w700,
                            color: gpTextPrimary,
                            fontSize: BUTTON_FONT_SIZE),
                        const SizedBox(height: 4),
                        getSmallText("Attachments: $_attachmentCount",
                            color: gpTextSecondary,
                            fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE),
                        if (!_canExport) ...[
                          const SizedBox(height: 8),
                          getSmallText(reportExportLocked,
                              color: gpError,
                              fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                              weight: FontWeight.w600),
                        ],
                        if (isExporting) ...[
                          const SizedBox(height: 8),
                          getSmallText("Building export package...",
                              color: gpTextSecondary,
                              fontSize: CAPTION_SMALLER_TEXT_FONT_SIZE,
                              weight: FontWeight.w600),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  getButton(generateReport, _generateCsvReport,
                      width: deviceWidth * 0.9),
                  const SizedBox(height: 10),
                  getButton("Generate PDF", _generatePdfReport,
                      width: deviceWidth * 0.9,
                      color: Colors.white,
                      textColor: gpTextPrimary),
                  const SizedBox(height: 10),
                  getButton(
                    previewExport,
                    _showPreviewSheet,
                    width: deviceWidth * 0.9,
                    color: Colors.white,
                    textColor: gpTextPrimary,
                  ),
                  const SizedBox(height: 10),
                  getButton(downloadArchive, _generateArchiveManifest,
                      width: deviceWidth * 0.9,
                      color: gpLight,
                      textColor: gpGreen),
                  const SizedBox(height: 10),
                  getButton(
                    billingAndSubscription,
                    () {
                      bloc.add(BillingEvent());
                    },
                    width: deviceWidth * 0.9,
                    color: Colors.white,
                    textColor: gpTextPrimary,
                  ),
                  SizedBox(height: deviceHeight * 0.03),
                ],
              ),
            ),
    );
  }
}
