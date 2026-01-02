import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'skleton/skelton.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final BoxFit fit;

  const NetworkImageWithLoader(
    this.src, {
    super.key,
    this.fit = BoxFit.cover,
    this.radius = defaultPadding,
  });

  final String src;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isNetwork = src.startsWith('http');
    final isDataUri = src.startsWith('data:image');

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: isNetwork
          ? CachedNetworkImage(
              fit: fit,
              imageUrl: src,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: fit,
                  ),
                ),
              ),
              placeholder: (context, url) => const Skeleton(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
          : isDataUri
              ? _buildFromDataUri()
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(src),
                      fit: fit,
                    ),
                  ),
                ),
    );
  }

  Widget _buildFromDataUri() {
    try {
      final parts = src.split(',');
      if (parts.length != 2) {
        return const Icon(Icons.error);
      }
      final base64Str = parts[1];
      final bytes = base64Decode(base64Str);
      return Image.memory(
        bytes,
        fit: fit,
      );
    } catch (_) {
      return const Icon(Icons.error);
    }
  }
}
