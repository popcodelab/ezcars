import 'package:ezcars/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

import '../models/place.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Widget for Location Picker Tile
class LocationPickerTile extends StatelessWidget {
  final Place? selectedPlace;
  final Function onLocationTap;

  const LocationPickerTile({super.key, this.selectedPlace, required this.onLocationTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onLocationTap(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Align icon and text vertically
        children: [
          Icon(
            Icons.location_on,
            color: theme.colorScheme.primary,
            size: 14.0, // Small size for the icon
          ),
          const SizedBox(width: 4.0), // Minimal space between icon and text
          Expanded(
            child: Text(
              selectedPlace?.name ?? AppLocalizations.of(context)!.current_location.capitalize(),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.left, // Ensure the text is aligned left
              overflow: TextOverflow.ellipsis, // In case the text is too long, it will be truncated
            ),
          ),
        ],
      ),
    );
  }
}
