import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallpaper.dart';

class FullscreenScreen extends StatefulWidget {
  final Wallpaper item;
  const FullscreenScreen({super.key, required this.item});

  @override
  State<FullscreenScreen> createState() => _FullscreenScreenState();
}

class _FullscreenScreenState extends State<FullscreenScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: SizedBox.expand(
          child: widget.item.thumbnailUrl != null
              ? CachedNetworkImage(
                  imageUrl: widget.item.thumbnailUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.black),
                  errorWidget: (context, url, error) => Container(color: Colors.black),
                )
              : Container(color: Colors.black),
        ),
      ),
    );
  }
}