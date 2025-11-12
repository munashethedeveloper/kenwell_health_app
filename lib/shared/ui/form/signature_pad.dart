import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePad extends StatefulWidget {
  final SignatureController? controller;
  final double height;
  final BoxDecoration? decoration;
  final Future<void> Function(Uint8List?)? onSave; // called with PNG bytes

  const SignaturePad({
    Key? key,
    this.controller,
    this.height = 150,
    this.decoration,
    this.onSave,
  }) : super(key: key);

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
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

  Future<void> _save() async {
    final png = await _controller.toPngBytes();
    if (widget.onSave != null) await widget.onSave!(png);
  }

  void _clear() {
    _controller.clear();
    setState(() {});
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
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}