// crypto_list_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icrypto/data/models/currency.dart';

class CryptoListItem extends StatelessWidget {
  final double width;
  final Currency crypto;
  static const double AVATAR_RADIUS = 20.0;
  static const double PRICE_CHANGE_HEIGHT_FACTOR = 0.07;
  static const backgrand = Color(0xFF000000); // Define your color

  const CryptoListItem({
    Key? key,
    required this.width,
    required this.crypto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: width * 0.17,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        textDirection: TextDirection.rtl,
        children: [
          _buildCryptoInfo(),
          _buildPriceInfo(),
          SizedBox(width: (width - 20) * 0.08),
          _buildPriceChange(),
        ],
      ),
    );
  }

  Widget _buildCryptoInfo() {
    return SizedBox(
      width: (width - 20) * 0.45,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          _buildCryptoAvatar(),
          const SizedBox(width: 10),
          _buildCryptoDetails(),
        ],
      ),
    );
  }

  Widget _buildCryptoAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: AVATAR_RADIUS,
      child: CachedNetworkImage(
        imageUrl: crypto.iconUrl!,
        placeholder: (context, url) => _buildAvatarPlaceholder(),
        errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 5)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            decoration: BoxDecoration(
              color: hexToColor(crypto.color!),
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                colors: [
                  hexToColor(crypto.color!),
                  hexToColor(crypto.color!).withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          );
        }
        return const SpinKitPulse(
          color: backgrand,
          size: 25,
        );
      },
    );
  }

  Widget _buildCryptoDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(crypto.symbol!, style: const TextStyle(fontSize: 14)),
            const Text(
              ' / IRT',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        Text(
          crypto.volumeSrc?.toString() ?? 'Unavailable',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInfo() {
    return SizedBox(
      width: (width - 20) * 0.29,
      child: Text(
        crypto.latestPrice ?? 'Unavailable',
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriceChange() {
    final double? numericChange = _parseChange(crypto.dayChange);
    final color = _getPriceChangeColor(numericChange);

    return SizedBox(
      width: (width - 20) * 0.18,
      child: Container(
        width: width * 0.15,
        height: width * PRICE_CHANGE_HEIGHT_FACTOR,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: Text(
            numericChange == null
                ? '0%'
                : '${numericChange.toStringAsFixed(2)}%',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  double? _parseChange(dynamic change) {
    if (change == null) return null;
    if (change is double) return change;
    if (change is String) {
      try {
        return double.parse(change);
      } catch (e) {
        debugPrint('Error parsing price change: $e');
        return null;
      }
    }
    return null;
  }

  Color _getPriceChangeColor(double? change) {
    if (change == null || change == 0) return Colors.grey;
    return change > 0 ? Colors.greenAccent : Colors.redAccent;
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    return Color(int.parse("FF$hex", radix: 16));
  }
}