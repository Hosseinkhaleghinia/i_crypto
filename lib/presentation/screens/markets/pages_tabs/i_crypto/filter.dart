// filters.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

enum FilterState { none, ascending, descending }
enum SortOrder2 { none, ascending, descending }

class CryptoFilterButton {
  final String title;
  FilterState state;

  CryptoFilterButton(this.title, [this.state = FilterState.none]);
}

class CryptoFilters extends StatelessWidget {
  final Map<String, CryptoFilterButton> filterButtons;
  final Function(CryptoFilterButton) onFilterTap;
  final double width;

  const CryptoFilters({
    Key? key,
    required this.filterButtons,
    required this.onFilterTap,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonWidth = width - 20;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: buttonWidth * 0.18,
          child: _buildFilterButton(filterButtons['24h تغییر']!),
        ),
        SizedBox(width: buttonWidth * 0.08),
        SizedBox(
          width: buttonWidth * 0.29,
          child: _buildFilterButton(filterButtons['آخرین قیمت']!),
        ),
        SizedBox(
          width: buttonWidth * 0.45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildFilterButton(filterButtons['حجم']!),
              const Text(' / '),
              _buildFilterButton(filterButtons['رمزارز']!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(CryptoFilterButton button) {
    return InkWell(
      onTap: () => onFilterTap(button),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterIcon(button.state),
          const SizedBox(width: 2),
          Text(
            button.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterIcon(FilterState state) {
    const double FILTER_ICON_WIDTH = 15.0;

    switch (state) {
      case FilterState.none:
        return SvgPicture.asset(
          'images/equal.svg',
          fit: BoxFit.fill,
          width: FILTER_ICON_WIDTH,
        );
      case FilterState.ascending:
      case FilterState.descending:
        return Transform.rotate(
          angle: state == FilterState.ascending ? 0 : 3.14159,
          child: Shimmer.fromColors(
            baseColor: Colors.blueAccent,
            highlightColor: Colors.grey,
            direction: ShimmerDirection.btt,
            child: SvgPicture.asset(
              'images/upward.svg',
              fit: BoxFit.fill,
              width: FILTER_ICON_WIDTH,
            ),
          ),
        );
    }
  }
}
