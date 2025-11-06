# نباتنا - Nbatna

Application Flutter d'identification de plantes en darija tunisienne avec Plant.id API v3 et Firebase.

## 🌱 Fonctionnalités

- ✅ Interface entièrement en **darija tunisienne** (arabe tunisien écrit en latin)
- 📸 Prise de photo via caméra ou galerie
- 🔍 Identification automatique avec **Plant.id API v3**
- 📍 Géolocalisation GPS ou saisie manuelle
- 🌾 Saisie du type de sol
- ☁️ Sauvegarde automatique dans **Firebase** (Storage + Firestore)
- ⚡ Gestion d'état avec **Riverpod** (pas de setState)
- 🎯 Architecture async/await avec Future

## 🛠️ Configuration Firebase

### 1. Créer un projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Créez un nouveau projet "Nbatna"
3. Activez **Firestore Database** (mode test pour développement)
4. Activez **Firebase Storage** (mode test pour développement)

### 2. Configuration Android

```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter à Firebase
firebase login

# Initialiser Firebase dans le projet
cd nbatna
firebase init

# Sélectionner : Firestore, Storage, Android

# Télécharger google-services.json
# Placer dans : nbatna/android/app/google-services.json
```

Modifier `android/build.gradle` :
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

Modifier `android/app/build.gradle` :
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
    }
}
```

### 3. Configuration iOS

```bash
# Télécharger GoogleService-Info.plist
# Placer dans : nbatna/ios/Runner/GoogleService-Info.plist
```

Modifier `ios/Podfile` :
```ruby
platform :ios, '12.0'
```

### 4. Permissions

**android/app/src/main/AndroidManifest.xml** :
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

**ios/Runner/Info.plist** :
```xml
<key>NSCameraUsageDescription</key>
<string>باش نصوّروا النبات</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>باش نختاروا صورة من الجاليري</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>باش نعرفوا وين لقيتو النبات</string>
```

## 📦 Installation

```bash
cd nbatna

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## 🔑 API Plant.id v3

**Clé API incluse** : `O7vcxQzJuwKZ3zaTq9QNsyxx6wwuNZ7fZsJITHbTdDTckiBm3f`

URL : `https://api.plant.id/v3/identification`

## 📂 Structure du projet

```
nbatna/
├── lib/
│   ├── main.dart                      # Point d'entrée
│   └── src/
│       ├── models/
│       │   └── plante.dart            # Modèles de données
│       ├── services/
│       │   ├── plant_id_service.dart  # Service Plant.id API
│       │   ├── firebase_service.dart  # Service Firebase
│       │   └── location_service.dart  # Service GPS
│       ├── controllers/
│       │   └── app_providers.dart     # Providers Riverpod
│       └── ui/
│           └── home_screen.dart       # Interface principale
├── pubspec.yaml
└── README.md
```

## 🎯 Utilisation

1. **Prendre une photo** : Cliquer sur "صوّر النبات" ou "من الجاليري"
2. **Saisir le type de sol** : Par exemple "رملي", "طيني", "خصب"
3. **Indiquer la localisation** :
   - Saisir manuellement : "سيدي بوسعيد", "تونس العاصمة"
   - Ou cliquer sur "GPS" pour récupérer automatiquement
4. **Analyser** : Cliquer sur "إعرف شنوة هذا!"
5. **Résultat** : Affichage du nom, précision, et sauvegarde automatique dans Firebase

## 🗄️ Structure Firestore

Collection `plantes` :
```json
{
  "id": "uuid-v4",
  "nom_tun": "نعناع",
  "nom_scientifique": "Mentha spicata",
  "precision": 0.94,
  "type_sol": "طيني",
  "localisation": {
    "geopoint": GeoPoint(36.8065, 10.1815),
    "adresse": "سيدي بوسعيد"
  },
  "image_url": "https://firebasestorage.../plantes/uuid.jpg",
  "date": Timestamp
}
```

## 🚀 Technologies

- **Flutter** : Framework UI
- **Riverpod** : State management
- **Firebase** : Backend (Firestore + Storage)
- **Plant.id v3** : Identification de plantes
- **Geolocator** : GPS
- **Image Picker** : Caméra/Galerie

## 📝 Notes

- Pas de `setState()` - 100% Riverpod
- Architecture async/await avec Future
- Interface RTL-friendly pour l'arabe
- Validation des champs obligatoires
- Gestion des erreurs en darija tunisienne

---

**Développé avec ❤️ pour la Tunisie 🇹🇳**
