import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CryptoImage extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Color fallbackColor;

  const CryptoImage({
    Key? key,
    required this.imageUrl,
    required this.radius,
    required this.fallbackColor,
  }) : super(key: key);

  bool get isSvg => imageUrl.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: radius,
      child: ClipOval(
        child: isSvg
            ? SvgPicture.network(
          imageUrl,
          placeholderBuilder: (context) => _buildPlaceholder(),
          height: radius * 2,
          width: radius * 2,
          fit: BoxFit.cover,
        )
            : CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildFallback(),
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          height: radius * 2,
          width: radius * 2,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return SpinKitPulse(
      color: fallbackColor,
      size: radius,
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        color: fallbackColor,
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            fallbackColor,
            fallbackColor.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}