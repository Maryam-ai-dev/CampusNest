import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../data/dummy_hostels.dart';
import '../../models/hostel.dart';
import '../../widgets/hostel_card.dart';

enum _Filter {
  under1km('< 1km'),
  ac('AC'),
  wifi('WiFi');

  const _Filter(this.label);
  final String label;

  bool matches(Hostel h) {
    switch (this) {
      case _Filter.under1km:
        return h.distanceKm < 1;
      case _Filter.ac:
        return h.hasAc;
      case _Filter.wifi:
        return h.hasWifi;
    }
  }
}

/// Student home: list of hostels near the campus (dummy data for now).
class HostelSearchScreen extends StatefulWidget {
  const HostelSearchScreen({super.key});

  @override
  State<HostelSearchScreen> createState() => _HostelSearchScreenState();
}

class _HostelSearchScreenState extends State<HostelSearchScreen> {
  // TODO: take these from the student's profile / preferences.
  static const _campus = 'NUST';
  static const _budget = 'Rs 15,000–25,000 / mo';

  final Set<_Filter> _active = {};

  void _toggle(_Filter f) {
    setState(() => _active.contains(f) ? _active.remove(f) : _active.add(f));
  }

  @override
  Widget build(BuildContext context) {
    final hostels = dummyHostels
        .where((h) => _active.every((f) => f.matches(h)))
        .toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hostels near $_campus',
                  style: GoogleFonts.fraunces(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Budget $_budget',
                  style: GoogleFonts.workSans(
                    fontSize: 13.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                _FilterPill(
                  label: 'All',
                  selected: _active.isEmpty,
                  onTap: () => setState(_active.clear),
                ),
                for (final f in _Filter.values) ...[
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: f.label,
                    selected: _active.contains(f),
                    onTap: () => _toggle(f),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: hostels.isEmpty
                ? Center(
                    child: Text(
                      'No hostels match these filters.',
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: hostels.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, i) => HostelCard(
                      hostel: hostels[i],
                      campus: _campus,
                      onTap: () => ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Hostel details coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.textDark : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.textDark : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}