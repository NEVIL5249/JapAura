import 'package:flutter/material.dart';
import '../models/mantra.dart';
import '../models/mantra_data.dart';

class MantraSelectionSheet extends StatelessWidget {
  final Mantra currentMantra;
  final Function(Mantra) onMantraSelected;

  const MantraSelectionSheet({
    Key? key,
    required this.currentMantra,
    required this.onMantraSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentMantra.primaryColor.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.format_list_bulleted,
                    color: currentMantra.primaryColor.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Mantra',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: MantraData.mantras.length,
              itemBuilder: (context, index) {
                final mantra = MantraData.mantras[index];
                final isSelected = mantra.id == currentMantra.id;

                return _buildMantraTile(mantra, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMantraTile(Mantra mantra, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onMantraSelected(mantra),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? mantra.primaryColor.shade50
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? mantra.primaryColor.shade200
                    : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? mantra.primaryColor.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 10 : 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        mantra.primaryColor.shade400,
                        mantra.secondaryColor.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: mantra.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      mantra.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image,
                        color: mantra.primaryColor.shade400,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mantra.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? mantra.primaryColor.shade700
                              : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSelected ? 'Currently Selected' : 'Tap to select',
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? mantra.primaryColor.shade500
                              : Colors.grey.shade600,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkmark
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: mantra.primaryColor.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
