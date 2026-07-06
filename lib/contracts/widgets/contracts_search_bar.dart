// contracts/widgets/contracts_search_bar.dart

import 'package:flutter/material.dart';

class ContractsSearchBar extends StatelessWidget {
  const ContractsSearchBar({
    required this.searchQuery,
    required this.onChanged,
    required this.resultCount,
    super.key,
  });

  final String searchQuery;
  final ValueChanged<String> onChanged;
  final int resultCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.teal.shade50, width: 2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                onChanged: onChanged,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  hintText: 'ابحث عن اسم العميل، الوصف، أو رقم العقد...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.teal.shade400,
                      width: 2,
                    ),
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.grey,
                          ),
                          onPressed: () => onChanged(''),
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Text(
              'النتيجة: $resultCount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
