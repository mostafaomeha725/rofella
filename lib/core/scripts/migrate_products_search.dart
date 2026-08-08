import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MigrationScripts {
  static Future<void> addNameLowerToProducts() async {
    try {
      debugPrint('Starting migration: addNameLowerToProducts...');
      final firestore = FirebaseFirestore.instance;
      final productsRef = firestore.collection('products');
      
      // Fetch all products
      final snapshot = await productsRef.get();
      int updatedCount = 0;
      int skippedCount = 0;
      
      // Use batches for efficiency
      WriteBatch batch = firestore.batch();
      int operationCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Idempotency: only update if name_lower is missing or incorrect
        final name = data['name'] as String?;
        if (name == null) {
          skippedCount++;
          continue;
        }

        final expectedNameLower = name.toLowerCase();
        final currentNameLower = data['name_lower'] as String?;

        if (currentNameLower != expectedNameLower) {
          batch.update(doc.reference, {'name_lower': expectedNameLower});
          updatedCount++;
          operationCount++;

          // Firestore batch limit is 500 operations
          if (operationCount >= 450) {
            await batch.commit();
            batch = firestore.batch();
            operationCount = 0;
          }
        } else {
          skippedCount++;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      debugPrint('Migration complete! Updated: $updatedCount, Skipped: $skippedCount');
    } catch (e) {
      debugPrint('Migration failed: $e');
    }
  }
}
