import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/plante.dart';
import '../services/plant_id_service.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';

// Services providers
final plantIdServiceProvider = Provider<PlantIdService>((ref) {
  return PlantIdService();
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final imagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

// State providers
final selectedImageProvider = StateProvider<File?>((ref) => null);

final typeSolProvider = StateProvider<String>((ref) => '');

final adresseManuelleProvider = StateProvider<String>((ref) => '');

final locationDataProvider = StateProvider<LocationData?>((ref) => null);

final isLoadingProvider = StateProvider<bool>((ref) => false);

final resultMessageProvider = StateProvider<String>((ref) => '');

// Async provider pour prendre une photo
final takePictureProvider = FutureProvider.autoDispose.family<File?, ImageSource>(
  (ref, source) async {
    final picker = ref.read(imagePickerProvider);
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      ref.read(selectedImageProvider.notifier).state = imageFile;
      return imageFile;
    }
    return null;
  },
);

// Provider pour obtenir la localisation GPS
final getGpsLocationProvider = FutureProvider.autoDispose<LocationData>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  final location = await locationService.getCurrentLocation();
  ref.read(locationDataProvider.notifier).state = location;
  ref.read(adresseManuelleProvider.notifier).state = location.adresse;
  return location;
});

// Provider pour l'analyse complète
final analyzeAndSavePlantProvider = FutureProvider.autoDispose<String>((ref) async {
  final imageFile = ref.read(selectedImageProvider);
  final typeSol = ref.read(typeSolProvider);
  final adresseManuelle = ref.read(adresseManuelleProvider);
  final locationData = ref.read(locationDataProvider);

  if (imageFile == null) {
    throw Exception('لازم تختار صورة أولاً');
  }

  if (typeSol.isEmpty) {
    throw Exception('لازم تكتب نوع التربة');
  }

  if (adresseManuelle.isEmpty && locationData == null) {
    throw Exception('لازم تكتب الموقع ولا تستعمل GPS');
  }

  ref.read(isLoadingProvider.notifier).state = true;

  try {
    // 1. Identifier la plante avec Plant.id
    final plantIdService = ref.read(plantIdServiceProvider);
    final identification = await plantIdService.identifyPlant(imageFile);

    // 2. Générer un UUID unique
    const uuid = Uuid();
    final planteId = uuid.v4();

    // 3. Upload l'image vers Firebase Storage
    final firebaseService = ref.read(firebaseServiceProvider);
    final imageUrl = await firebaseService.uploadImage(imageFile, planteId);

    // 4. Créer l'objet Plante
    final location = locationData ?? LocationData(
      latitude: 0.0,
      longitude: 0.0,
      adresse: adresseManuelle,
    );

    final plante = Plante(
      id: planteId,
      nomTun: identification.nomCommun,
      nomScientifique: identification.nomScientifique,
      precision: identification.precision,
      typeSol: typeSol,
      localisation: location,
      imageUrl: imageUrl,
    );

    // 5. Sauvegarder dans Firestore
    await firebaseService.savePlante(plante);

    // 6. Réinitialiser les states
    ref.read(selectedImageProvider.notifier).state = null;
    ref.read(typeSolProvider.notifier).state = '';
    ref.read(adresseManuelleProvider.notifier).state = '';
    ref.read(locationDataProvider.notifier).state = null;

    final resultMessage = 
        'النبات: ${plante.nomTun} (${plante.nomScientifique})\n'
        'دقة: ${(plante.precision * 100).toStringAsFixed(1)}%\n'
        'نوع التربة: ${plante.typeSol}\n'
        'الموقع: ${plante.localisation.adresse}';

    ref.read(resultMessageProvider.notifier).state = resultMessage;
    
    return resultMessage;
  } catch (e) {
    throw Exception('فشلت العملية: $e');
  } finally {
    ref.read(isLoadingProvider.notifier).state = false;
  }
});
