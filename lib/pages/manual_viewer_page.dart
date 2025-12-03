
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/washer_model.dart';
import '../services/washer_service.dart';

class ManualViewerPage extends StatefulWidget {
  final WasherModel? washer;
  final int? initialPage;

  const ManualViewerPage({super.key, this.washer, this.initialPage});

  @override
  State<ManualViewerPage> createState() => _ManualViewerPageState();
}

class _ManualViewerPageState extends State<ManualViewerPage> {
  late final PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    // widget.washer가 있으면 그것을 사용하고, 없으면 Provider를 통해 현재 설정된 세탁기 정보를 가져옵니다.
    final washerModel = widget.washer ?? Provider.of<WasherService>(context).currentWasher;

    return Scaffold(
      appBar: AppBar(title: const Text('사용 설명서'), centerTitle: true),
      body: washerModel == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '표시할 설명서가 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('뒤로 가기'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(washerModel.washerName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('기종: ${washerModel.washerCode}', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    ],
                  ),
                ),
                Expanded(
                  child: SfPdfViewer.asset(
                    washerModel.manualPath,
                    controller: _pdfViewerController,
                    onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                      if (widget.initialPage != null) {
                        _pdfViewerController.jumpToPage(widget.initialPage!);
                      }
                    },
                    onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('PDF 로드 실패: ${details.error}'), backgroundColor: Colors.red),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
