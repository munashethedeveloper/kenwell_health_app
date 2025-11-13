import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class KenwellSignaturePad extends StatefulWidget {
  final SignatureController? controller;
  final double height;
  final BoxDecoration? decoration;

  const KenwellSignaturePad({
    Key? key,
    this.controller,
    this.height = 150,
    this.decoration,
  }) : super(key: key);

  @override
  State<KenwellSignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<KenwellSignaturePad> {
  late final SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        SignatureController(
          penStrokeWidth: 2,
          penColor: Colors.black,
        );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() {}); // Refresh UI after clearing
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: widget.decoration ??
              BoxDecoration(border: Border.all(color: Colors.grey)),
          height: widget.height,
          child: Signature(
            controller: _controller,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
          ),
        ),
      ],
    );
  }
}
