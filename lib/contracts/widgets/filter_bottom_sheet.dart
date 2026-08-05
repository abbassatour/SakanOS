// contracts/widgets/filter_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class ContractFilters {
  const ContractFilters({
    required this.status,
    required this.type,
    required this.handover,
  });

  final String status;
  final String type;
  final String handover;
}

Future<ContractFilters?> showFilterBottomSheet({
  required BuildContext context,
  required String currentStatus,
  required String currentType,
  required String currentHandover,
}) {
  return showModalBottomSheet<ContractFilters>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return _FilterBottomSheetContent(
        initialStatus: currentStatus,
        initialType: currentType,
        initialHandover: currentHandover,
      );
    },
  );
}

class _FilterBottomSheetContent extends StatefulWidget {
  const _FilterBottomSheetContent({
    required this.initialStatus,
    required this.initialType,
    required this.initialHandover,
  });

  final String initialStatus;
  final String initialType;
  final String initialHandover;

  @override
  State<_FilterBottomSheetContent> createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  late String _tempStatus;
  late String _tempType;
  late String _tempHandover;

  @override
  void initState() {
    super.initState();
    _tempStatus = widget.initialStatus;
    _tempType = widget.initialType;
    _tempHandover = widget.initialHandover;
  }

  Widget _buildChipRadio(
    String value,
    String title,
    String groupValue,
    Color color,
    ValueChanged<String> onChanged,
  ) {
    final isSelected = groupValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _applyFilters() {
    final result = ContractFilters(
      status: _tempStatus,
      type: _tempType,
      handover: _tempHandover,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt, color: Colors.teal, size: 28),
              const SizedBox(width: 8),
              Text(
                l10n.contractFilterTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.contractFilterStatusHeader,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChipRadio(
                'all',
                l10n.contractFilterStatusAll,
                _tempStatus,
                Colors.blueGrey,
                (v) => setState(() => _tempStatus = v),
              ),
              _buildChipRadio(
                'active',
                l10n.contractFilterStatusActive,
                _tempStatus,
                Colors.teal,
                (v) => setState(() => _tempStatus = v),
              ),
              _buildChipRadio(
                'completed',
                l10n.contractFilterStatusCompleted,
                _tempStatus,
                Colors.green,
                (v) => setState(() => _tempStatus = v),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1.5),
          Text(
            l10n.contractFilterTypeHeader,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChipRadio(
                'all',
                l10n.contractFilterTypeAll,
                _tempType,
                Colors.blueGrey,
                (v) => setState(() => _tempType = v),
              ),
              _buildChipRadio(
                'allocated',
                l10n.contractFilterTypeAllocated,
                _tempType,
                Colors.indigo,
                (v) => setState(() => _tempType = v),
              ),
              _buildChipRadio(
                'unallocated',
                l10n.contractFilterTypeUnallocated,
                _tempType,
                Colors.deepOrange,
                (v) => setState(() => _tempType = v),
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1.5),
          Text(
            l10n.contractFilterHandoverHeader,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChipRadio(
                'all',
                l10n.contractFilterHandoverAll,
                _tempHandover,
                Colors.blueGrey,
                (v) => setState(() => _tempHandover = v),
              ),
              _buildChipRadio(
                'delivered',
                l10n.contractFilterHandoverDelivered,
                _tempHandover,
                Colors.green,
                (v) => setState(() => _tempHandover = v),
              ),
              _buildChipRadio(
                'pending',
                l10n.contractFilterHandoverPending,
                _tempHandover,
                Colors.orange,
                (v) => setState(() => _tempHandover = v),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.check_circle),
              label: Text(
                l10n.contractFilterApply,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _applyFilters,
            ),
          ),
        ],
      ),
    );
  }
}
