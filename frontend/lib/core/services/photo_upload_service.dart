import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import '../theme/app_colors.dart';

enum _PhotoAction { gallery, camera, remove }

/// Service responsible for device photo picking, ImageKit CDN direct upload,
/// and fallback base64 Data URI persistence.
class PhotoUploadService {
  final Dio _dio;
  final ImagePicker _picker;

  PhotoUploadService({Dio? dio, ImagePicker? picker})
      : _dio = dio ?? Dio(),
        _picker = picker ?? ImagePicker();

  /// Displays a modal sheet to pick from Camera or Gallery, or remove the photo.
  /// Returns the new avatarUrl (or '' if removed, or null if cancelled).
  Future<String?> promptAndUploadAvatar({
    required BuildContext context,
    required String token,
    bool hasExistingPhoto = false,
  }) async {
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Profile Photo',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a photo from your device to use as your profile picture.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDeepTeal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primaryDeepTeal),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                ),
                subtitle: Text(
                  'Pick an image from your device photos',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
                onTap: () => Navigator.pop(ctx, _PhotoAction.gallery),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentWarmYellow.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFB45309)),
                ),
                title: Text(
                  'Take Photo',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                ),
                subtitle: Text(
                  'Use your device camera',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
                onTap: () => Navigator.pop(ctx, _PhotoAction.camera),
              ),
              if (hasExistingPhoto) ...[
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                  title: Text(
                    'Remove Photo',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.red),
                  ),
                  subtitle: Text(
                    'Reset to initials badge',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                  ),
                  onTap: () => Navigator.pop(ctx, _PhotoAction.remove),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (action == null) return null;

    if (action == _PhotoAction.remove) {
      await _syncAvatarToBackend(token: token, avatarUrl: null);
      return '';
    }

    final source = action == _PhotoAction.camera ? ImageSource.camera : ImageSource.gallery;
    final uploadedUrl = await pickAndUpload(source: source, token: token);
    if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
      await _syncAvatarToBackend(token: token, avatarUrl: uploadedUrl);
      return uploadedUrl;
    }
    return null;
  }

  /// Picks an image and uploads to ImageKit (or falls back to Data URI).
  Future<String?> pickAndUpload({
    required ImageSource source,
    required String token,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null) return null;

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;

      // 1. Try ImageKit direct upload
      try {
        final authEndpoint = '${ApiConstants.backendBaseUrl}${ApiConstants.userAvatarAuth}';
        final authRes = await _dio.get(
          authEndpoint,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (authRes.statusCode == 200 && authRes.data is Map<String, dynamic>) {
          final data = authRes.data['data'] as Map<String, dynamic>?;
          final publicKey = data?['publicKey']?.toString() ?? '';
          final signature = data?['signature']?.toString() ?? '';
          final expire = data?['expire']?.toString() ?? '';
          final tokenParam = data?['token']?.toString() ?? '';

          if (publicKey.isNotEmpty && signature.isNotEmpty && tokenParam.isNotEmpty) {
            final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final formData = FormData.fromMap({
              'file': MultipartFile.fromBytes(bytes, filename: fileName),
              'fileName': fileName,
              'publicKey': publicKey,
              'signature': signature,
              'expire': expire,
              'token': tokenParam,
              'folder': '/avatars',
            });

            final uploadRes = await Dio().post(
              'https://upload.imagekit.io/api/v1/files/upload',
              data: formData,
            );

            if (uploadRes.statusCode == 200 && uploadRes.data is Map<String, dynamic>) {
              final cdnUrl = uploadRes.data['url']?.toString();
              if (cdnUrl != null && cdnUrl.isNotEmpty) {
                return cdnUrl;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[PHOTO_UPLOAD] ImageKit CDN upload unavailable or skipped ($e). Falling back to base64 Data URI.');
      }

      // 2. Fallback: Base64 Data URI (supported by PostgreSQL @db.Text)
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('[PHOTO_UPLOAD] ❌ Image pick/upload error: $e');
      return null;
    }
  }

  Future<void> _syncAvatarToBackend({
    required String token,
    required String? avatarUrl,
  }) async {
    try {
      final endpoint = '${ApiConstants.backendBaseUrl}${ApiConstants.userAvatar}';
      await _dio.patch(
        endpoint,
        data: {'avatarUrl': avatarUrl},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      debugPrint('[PHOTO_UPLOAD] ✅ Backend avatar synchronized.');
    } catch (e) {
      debugPrint('[PHOTO_UPLOAD] ⚠️ Backend avatar sync error: $e');
    }
  }

  /// Picks a receipt image from camera or gallery and uploads to ImageKit (or falls back to Data URI).
  Future<String?> pickAndUploadReceipt({
    required ImageSource source,
    required String tripId,
    required String token,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );

      if (file == null) return null;

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;

      // 1. Try ImageKit direct upload
      try {
        final authEndpoint = '${ApiConstants.backendBaseUrl}${ApiConstants.tripExpenseImageKitAuth(tripId)}';
        final authRes = await _dio.get(
          authEndpoint,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (authRes.statusCode == 200 && authRes.data is Map<String, dynamic>) {
          final data = authRes.data['data'] as Map<String, dynamic>?;
          final publicKey = data?['publicKey']?.toString() ?? '';
          final signature = data?['signature']?.toString() ?? '';
          final expire = data?['expire']?.toString() ?? '';
          final tokenParam = data?['token']?.toString() ?? '';

          if (publicKey.isNotEmpty && signature.isNotEmpty && tokenParam.isNotEmpty) {
            final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final formData = FormData.fromMap({
              'file': MultipartFile.fromBytes(bytes, filename: fileName),
              'fileName': fileName,
              'publicKey': publicKey,
              'signature': signature,
              'expire': expire,
              'token': tokenParam,
              'folder': '/receipts',
            });

            final uploadRes = await Dio().post(
              'https://upload.imagekit.io/api/v1/files/upload',
              data: formData,
            );

            if (uploadRes.statusCode == 200 && uploadRes.data is Map<String, dynamic>) {
              final cdnUrl = uploadRes.data['url']?.toString();
              if (cdnUrl != null && cdnUrl.isNotEmpty) {
                return cdnUrl;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[PHOTO_UPLOAD] Receipt ImageKit upload failed/skipped ($e). Falling back to base64 Data URI.');
      }

      // 2. Fallback: Base64 Data URI
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('[PHOTO_UPLOAD] ❌ Receipt pick/upload error: $e');
      return null;
    }
  }

}