import 'package:flutter/material.dart';

class OperationInputPanel extends StatefulWidget {
  final String operation;
  final bool animating;
  final VoidCallback Sort;
  final void Function(int value, int index) onInsert;
  final void Function(int value, int index) onUpdate;
  final void Function(int index) onDelete;

  const OperationInputPanel({
    super.key,
    required this.operation,
    required this.animating,
    required this.Sort,
    required this.onInsert,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<OperationInputPanel> createState() => _OperationInputPanelState();
}

class _OperationInputPanelState extends State<OperationInputPanel> {
  final _valCtrl = TextEditingController();
  final _idxCtrl = TextEditingController();

  @override
  void dispose() {
    _valCtrl.dispose();
    _idxCtrl.dispose();
    super.dispose();
  }

  Widget _buildInput(TextEditingController ctrl, String hint) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF30363D)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 13,
            fontFamily: 'monospace',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: widget.animating ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: widget.animating ? const Color(0xFF21262D) : const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: widget.animating ? const Color(0xFF8B949E) : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.operation) {
      case 'sort':
        return GestureDetector(
          onTap: widget.animating ? null : widget.Sort,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: widget.animating ? const Color(0xFF21262D) : const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.animating ? 'Sorting...' : '▶   Sort',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.animating ? const Color(0xFF8B949E) : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
        );

      case 'insert':
        return Row(
          children: [
            _buildInput(_valCtrl, 'Value'),
            const SizedBox(width: 8),
            _buildInput(_idxCtrl, 'Index (i)'),
            const SizedBox(width: 8),
            _buildActionBtn('Insert', () {
              final v = int.tryParse(_valCtrl.text.trim());
              final i = int.tryParse(_idxCtrl.text.trim());
              if (v != null && i != null) widget.onInsert(v, i);
            }),
          ],
        );

      case 'update':
        return Row(
          children: [
            _buildInput(_valCtrl, 'New Value'),
            const SizedBox(width: 8),
            _buildInput(_idxCtrl, 'Index (i)'),
            const SizedBox(width: 8),
            _buildActionBtn('Update', () {
              final v = int.tryParse(_valCtrl.text.trim());
              final i = int.tryParse(_idxCtrl.text.trim());
              if (v != null && i != null) widget.onUpdate(v, i);
            }),
          ],
        );

      case 'delete':
        return Row(
          children: [
            _buildInput(_idxCtrl, 'Index (i)'),
            const SizedBox(width: 8),
            _buildActionBtn('Delete', () {
              final i = int.tryParse(_idxCtrl.text.trim());
              if (i != null) widget.onDelete(i);
            }),
          ],
        );

      default:
        return const SizedBox();
    }
  }
}