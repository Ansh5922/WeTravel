import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/services/destination_photo_service.dart';

void main() {
  group('DestinationPhotoService Tests', () {
    test('Paris returns accurate Paris Eiffel Tower photo, NOT an Indian city', () {
      final url = DestinationPhotoService.resolveCoverImageUrl('Paris');
      expect(url, contains('photo-1502602898657-3e91760cbb34'));
      expect(url, isNot(contains('photo-1570168007204-dfb528c6958f'))); // Not Mumbai
    });

    test('Dubai returns Dubai Burj Khalifa photo', () {
      final url = DestinationPhotoService.resolveCoverImageUrl('Dubai, UAE');
      expect(url, contains('photo-1512453979798-5ea266f8880c'));
    });

    test('Tokyo returns Tokyo Tower & Fuji photo', () {
      final url = DestinationPhotoService.resolveCoverImageUrl('Tokyo, Japan');
      expect(url, contains('photo-1503899036084-c55cdd92da26'));
    });

    test('London returns Big Ben & London photo', () {
      final url = DestinationPhotoService.resolveCoverImageUrl('London, UK');
      expect(url, contains('photo-1513635269975-59663e0ac1ad'));
    });

    test('Goa returns Goa beach photo', () {
      final url = DestinationPhotoService.resolveCoverImageUrl('Goa, India');
      expect(url, contains('photo-1512343879784-a960bf40e7f2'));
    });

    test('Manali returns Himalayan snow peaks', () {
      final url = DestinationPhotoService.resolveCoverImageUrl('Manali, Himachal Pradesh');
      expect(url, contains('photo-1626621341517-bbf3d9990a23'));
    });

    test('Jaipur returns Hawa Mahal / Amber Fort photo', () {
      final url = DestinationPhotoService.resolveCoverImageUrl('Jaipur, Rajasthan');
      expect(url, contains('photo-1599661046289-e31897846e41'));
    });

    test('Agra returns Taj Mahal photo', () {
      final url = DestinationPhotoService.resolveCoverImageUrl('Agra, Uttar Pradesh');
      expect(url, contains('photo-1564507592333-c60657eea523'));
    });

    test('Varanasi returns Sacred Ganga Ghats photo', () {
      final url = DestinationPhotoService.resolveCoverImageUrl('Varanasi, Kashi');
      expect(url, contains('photo-1561361513-2d000a50f0dc'));
    });

    test('Amritsar returns Golden Temple photo', () {
      final url = DestinationPhotoService.resolveCoverImageUrl('Amritsar, Punjab');
      expect(url, contains('photo-1609137144822-0a13876007b8'));
    });

    test('Kerala returns Alleppey backwaters houseboat photo', () {
      final url = DestinationPhotoService.resolveCoverImageUrl('Alleppey, Kerala');
      expect(url, contains('photo-1602216056096-3b40cc0c9944'));
    });
  });
}
