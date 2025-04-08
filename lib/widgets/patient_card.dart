import 'package:flutter/material.dart';
import '../models/patient.dart';
import 'dart:math' as math;

/// A beautifully styled card widget that displays patient information
/// with a modern, clean design and subtle animations.
class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientCard({
    Key? key,
    required this.patient,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract theme colors for consistent styling
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine avatar background color based on patient ID for visual variety
    final Color avatarColor = Color(
            (math.Random(patient.id.hashCode).nextDouble() * 0xFFFFFF)
                    .toInt() <<
                0)
        .withOpacity(1.0);

    // Create a contrasting text color for the avatar
    final bool isDark = avatarColor.computeLuminance() < 0.5;
    final Color avatarTextColor = isDark ? Colors.white : Colors.black87;

    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: colorScheme.primary.withOpacity(0.3),
        highlightColor: colorScheme.primary.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Patient avatar or initials
              CircleAvatar(
                radius: 28,
                backgroundColor: avatarColor,
                child: Text(
                  _getInitials(patient.name ?? ''),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: avatarTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Patient information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name with status indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            patient.name ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusIndicator(
                            patient.criticalCondition ?? false),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // ID number
                    Text(
                      'ID: ${patient.id ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Key patient information chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (patient.age != null)
                          _buildInfoChip(
                            icon: Icons.cake,
                            label: '${patient.age} years',
                            color: colorScheme.primary,
                          ),
                        if (patient.gender != null &&
                            patient.gender!.isNotEmpty)
                          _buildInfoChip(
                            icon: _getGenderIcon(patient.gender!),
                            label: patient.gender!,
                            color: colorScheme.secondary,
                          ),
                        if (patient.phoneNumber != null &&
                            patient.phoneNumber!.isNotEmpty)
                          _buildInfoChip(
                            icon: Icons.phone,
                            label: patient.phoneNumber!,
                            color: Colors.green.shade700,
                          ),
                        if (patient.medicalHistory != null &&
                            patient.medicalHistory!.isNotEmpty)
                          _buildInfoChip(
                            icon: Icons.history,
                            label: '${patient.medicalHistory!.length} records',
                            color: Colors.purple.shade700,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Navigation indicator
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a status indicator based on patient's critical condition status
  Widget _buildStatusIndicator(bool isCritical) {
    final Color color = isCritical ? Colors.red : Colors.green;
    final IconData icon = isCritical ? Icons.warning : Icons.check_circle;
    final String label = isCritical ? 'Critical' : 'Stable';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an info chip for patient details
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Gets patient initials from name
  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    // Split the name by spaces and get the first character of each part
    final parts = name.split(' ');
    if (parts.length == 1) {
      // If there's only one part, return the first letter
      return parts[0][0].toUpperCase();
    } else {
      // Return first letter of first and last parts
      return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
    }
  }

  /// Gets the appropriate icon for patient gender
  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      default:
        return Icons.person;
    }
  }
}
