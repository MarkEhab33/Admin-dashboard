import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewer({
    Key? key,
    required this.pdfUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  late PdfViewerController _pdfViewerController;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  String _correctPdfUrl(String url) {
    if (url.contains('image/upload')) {
      return url.replaceFirst('image/upload', 'raw/upload');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final correctedUrl = _correctPdfUrl(widget.pdfUrl);
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate container dimensions
    final containerWidth = screenSize.width * 0.8; // 40% of screen width
    final containerHeight = screenSize.height * 0.9; // 60% of screen height

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              _pdfViewerController.zoomLevel = _zoomLevel + 0.25;
              setState(() => _zoomLevel = _pdfViewerController.zoomLevel);
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              if (_zoomLevel > 1.0) {
                _pdfViewerController.zoomLevel = _zoomLevel - 0.25;
                setState(() => _zoomLevel = _pdfViewerController.zoomLevel);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: containerWidth,
          height: containerHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          margin: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SfPdfViewer.network(
              correctedUrl,
              controller: _pdfViewerController,
              enableDoubleTapZooming: true,
              enableTextSelection: true,
              pageLayoutMode: PdfPageLayoutMode.single,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                print('Error loading PDF: ${details.error}');
                print('PDF URL attempted: $correctedUrl');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to load PDF. Please try again later.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'prev',
            mini: true, // Makes the FAB smaller
            onPressed: () {
              _pdfViewerController.previousPage();
            },
            child: const Icon(Icons.keyboard_arrow_up),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'next',
            mini: true, // Makes the FAB smaller
            onPressed: () {
              _pdfViewerController.nextPage();
            },
            child: const Icon(Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}



