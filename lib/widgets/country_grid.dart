import 'package:flutter/material.dart';

import '../models/location.dart';

/// Displays a 3-column grid of country cards.
///
/// Each card shows the country flag emoji and name. Tapping a card
/// triggers [onCountrySelected] with the corresponding [Location].
class CountryGrid extends StatelessWidget {
  const CountryGrid({
    super.key,
    required this.countries,
    required this.onCountrySelected,
  });

  final List<Location> countries;
  final ValueChanged<Location> onCountrySelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: countries.length,
      itemBuilder: (BuildContext context, int index) {
        final Location country = countries[index];

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onCountrySelected(country),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Flag emoji
                  Text(
                    country.flag,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),

                  // Country name
                  Text(
                    country.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  // Package count (optional)
                  if (country.packageCount != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${country.packageCount} plans',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}