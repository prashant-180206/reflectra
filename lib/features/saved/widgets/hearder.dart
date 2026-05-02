import 'package:flutter/material.dart';

class FilterHeader extends StatelessWidget {
  final bool showFilters;
  final VoidCallback onToggle;

  const FilterHeader({
    super.key,
    required this.showFilters,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Icon(showFilters ? Icons.expand_less : Icons.expand_more, size: 20),
          ],
        ),
      ),
    );
  }
}

class FilterPanel extends StatelessWidget {
  final dynamic state;
  final List<String> monthLabels;
  final dynamic notifier;

  const FilterPanel({
    super.key,
    required this.state,
    required this.monthLabels,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: state.selectedMonthLabel,
              decoration: const InputDecoration(
                labelText: 'Month',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: monthLabels
                  .map(
                    (label) =>
                        DropdownMenuItem(value: label, child: Text(label)),
                  )
                  .toList(),
              onChanged: (v) {
                notifier.setMonthLabel(v ?? 'All');
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: DropdownButtonFormField<int>(
              initialValue: state.pageSize,
              decoration: const InputDecoration(
                labelText: 'Per page',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: const [10, 20, 50]
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                  .toList(),
              onChanged: (v) {
                notifier.setPageSize(v ?? 10);
              },
            ),
          ),
        ],
      ),
    );
  }
}
