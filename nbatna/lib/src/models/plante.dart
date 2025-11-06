import 'package:cloud_firestore/cloud_firestore.dart';

class Plante {
  final String id;
  final String nomTun;
  final String nomScientifique;
  final double precision;
  final String typeSol;
  final LocationData localisation;
  final String imageUrl;
  final DateTime? date;

  Plante({
    required this.id,
    required this.nomTun,
    required this.nomScientifique,
    required this.precision,
    required this.typeSol,
    required this.localisation,
    required this.imageUrl,
    this.date,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'nom_tun': nomTun,
      'nom_scientifique': nomScientifique,
      'precision': precision,
      'type_sol': typeSol,
      'localisation': {
        'geopoint': GeoPoint(localisation.latitude, localisation.longitude),
        'adresse': localisation.adresse,
      },
      'image_url': imageUrl,
      'date': FieldValue.serverTimestamp(),
    };
  }

  factory Plante.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final locData = data['localisation'] as Map<String, dynamic>;
    final geopoint = locData['geopoint'] as GeoPoint;
    
    return Plante(
      id: data['id'] ?? doc.id,
      nomTun: data['nom_tun'] ?? '',
      nomScientifique: data['nom_scientifique'] ?? '',
      precision: (data['precision'] ?? 0.0).toDouble(),
      typeSol: data['type_sol'] ?? '',
      localisation: LocationData(
        latitude: geopoint.latitude,
        longitude: geopoint.longitude,
        adresse: locData['adresse'] ?? '',
      ),
      imageUrl: data['image_url'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate(),
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String adresse;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.adresse,
  });
}

class PlantIdentification {
  final String nomCommun;
  final String nomScientifique;
  final double precision;

  PlantIdentification({
    required this.nomCommun,
    required this.nomScientifique,
    required this.precision,
  });

  factory PlantIdentification.fromJson(Map<String, dynamic> json) {
    // Plant.id v3 API response format
    final result = json['result'];
    final classification = result['classification'];
    final suggestions = classification['suggestions'] as List;
    
    if (suggestions.isEmpty) {
      return PlantIdentification(
        nomCommun: 'مش معروف',
        nomScientifique: 'Unknown',
        precision: 0.0,
      );
    }

    final topSuggestion = suggestions[0];
    final details = topSuggestion['details'];
    
    return PlantIdentification(
      nomCommun: details['common_names']?.isNotEmpty == true 
          ? details['common_names'][0] 
          : topSuggestion['name'],
      nomScientifique: topSuggestion['name'],
      precision: (topSuggestion['probability'] ?? 0.0).toDouble(),
    );
  }
}
