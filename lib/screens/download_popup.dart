import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import '../models/wallpaper.dart';

class DownloadPopup extends StatefulWidget {
  final Wallpaper item;
  const DownloadPopup({super.key, required this.item});

  @override
  State<DownloadPopup> createState() => _DownloadPopupState();
}

class _DownloadPopupState extends State<DownloadPopup> {
  bool _downloading = false;
  bool _done = false;
  double _progress = 0;
  String _status = '';

  Future<void> _download() async {
    if (widget.item.videoUrl == null) {
      setState(() => _status = '영상 파일이 없습니다');
      return;
    }

    setState(() { _downloading = true; _status = '권한 확인 중...'; });

    try {
      // 권한 요청
      if (Platform.isAndroid) {
        final hasAccess = await Gal.hasAccess(toAlbum: false);
        if (!hasAccess) {
          await Gal.requestAccess(toAlbum: false);
        }
      } else if (Platform.isIOS) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          setState(() { _downloading = false; _status = '사진 앱 접근 권한이 필요합니다'; });
          return;
        }
      }

      setState(() => _status = '다운로드 중...');

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${widget.item.title}_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final dio = Dio();
      await dio.download(
        widget.item.videoUrl!,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() => _progress = received / total);
          }
        },
      );

      setState(() => _status = '갤러리에 저장 중...');

      await Gal.putVideo(filePath);

      // 임시 파일 삭제
      final file = File(filePath);
      if (await file.exists()) await file.delete();

      setState(() {
        _downloading = false;
        _done = true;
        _status = Platform.isIOS ? '사진 앱에 저장됐습니다' : '갤러리에 저장됐습니다';
      });
    } on GalException catch (e) {
      setState(() { _downloading = false; _status = '저장 오류: ${e.type}'; });
    } catch (e) {
      setState(() { _downloading = false; _status = '오류: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_done)
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 48)
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.item.thumbnailUrl != null
                    ? Image.network(
                        widget.item.thumbnailUrl!,
                        height: 160,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 160,
                        color: const Color(0xFF111111),
                      ),
              ),
            const SizedBox(height: 20),
            Text(
              _done ? '구매 완료' : widget.item.title,
              style: GoogleFonts.josefinSans(
                fontSize: 16, fontWeight: FontWeight.w600,
                color: Colors.white, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Text(
              _done ? _status : '${widget.item.priceLabel} · 일회성 구매',
              style: GoogleFonts.josefinSans(
                fontSize: 11, fontWeight: FontWeight.w300,
                color: Colors.white70, letterSpacing: 1),
            ),
            if (_downloading) ...[
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _progress > 0 ? '${(_progress * 100).toInt()}%' : _status,
                style: GoogleFonts.josefinSans(
                  fontSize: 10, color: Colors.white54, letterSpacing: 1)),
            ],
            if (_status.isNotEmpty && !_downloading && !_done) ...[
              const SizedBox(height: 12),
              Text(_status,
                style: GoogleFonts.josefinSans(
                  fontSize: 10, color: Colors.redAccent, letterSpacing: 1)),
            ],
            const SizedBox(height: 24),
            if (!_done && !_downloading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _download,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    Platform.isIOS ? '사진 앱에 저장' : '갤러리에 저장',
                    style: GoogleFonts.josefinSans(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      letterSpacing: 3)),
                ),
              ),
            if (_done)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('확인',
                    style: GoogleFonts.josefinSans(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      letterSpacing: 3)),
                ),
              ),
            if (!_done) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('나중에',
                  style: GoogleFonts.josefinSans(
                    fontSize: 11, color: Colors.white38, letterSpacing: 2)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}