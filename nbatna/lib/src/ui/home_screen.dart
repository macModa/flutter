import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/app_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImage = ref.watch(selectedImageProvider);
    final typeSol = ref.watch(typeSolProvider);
    final adresseManuelle = ref.watch(adresseManuelleProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'نباتنا - Nbatna',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'إعرف النبات اللي قدامك!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Boutons Caméra et Galerie
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _takePicture(context, ref, ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('صوّر النبات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _takePicture(context, ref, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('من الجاليري'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Aperçu de l'image
            if (selectedImage != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade300, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    selectedImage,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'ماكش مختار صورة',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Champ type de sol
            TextField(
              enabled: !isLoading,
              onChanged: (value) {
                ref.read(typeSolProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                labelText: 'نوع التربة؟',
                hintText: 'مثل: رملي، طيني، خصب...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.terrain, color: Colors.brown),
              ),
            ),
            const SizedBox(height: 20),

            // Champ localisation avec bouton GPS
            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: !isLoading,
                    onChanged: (value) {
                      ref.read(adresseManuelleProvider.notifier).state = value;
                    },
                    controller: TextEditingController(text: adresseManuelle)
                      ..selection = TextSelection.collapsed(offset: adresseManuelle.length),
                    decoration: InputDecoration(
                      labelText: 'وين لقيتو؟',
                      hintText: 'مثل: سيدي بوسعيد',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : () => _getGpsLocation(context, ref),
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text('GPS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Bouton d'analyse
            ElevatedButton.icon(
              onPressed: (isLoading || selectedImage == null || typeSol.isEmpty || adresseManuelle.isEmpty)
                  ? null
                  : () => _analyzePlant(context, ref),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(
                isLoading ? 'قاعد نحلل...' : 'إعرف شنوة هذا!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Affichage du résultat
            Consumer(
              builder: (context, ref, child) {
                final resultMessage = ref.watch(resultMessageProvider);
                if (resultMessage.isNotEmpty) {
                  return Card(
                    color: Colors.green.shade100,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                              const SizedBox(width: 10),
                              Text(
                                'النتيجة:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            resultMessage,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePicture(BuildContext context, WidgetRef ref, ImageSource source) async {
    try {
      ref.read(takePictureProvider(source));
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'فشل اختيار الصورة: $e');
      }
    }
  }

  Future<void> _getGpsLocation(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(getGpsLocationProvider.future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الحصول على الموقع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'فشل الحصول على الموقع: $e');
      }
    }
  }

  Future<void> _analyzePlant(BuildContext context, WidgetRef ref) async {
    try {
      final result = await ref.read(analyzeAndSavePlantProvider.future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الحفظ بنجاح في Firebase!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('خطأ'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
