import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase/supabase_config.dart';

/// Handles all Supabase database (PostgREST) operations.
///
/// All queries run under the anon key and are scoped by Row Level Security (RLS).
/// For admin operations that bypass RLS, use a server-side Edge Function with
/// the service-role key from `.env.server`.
class DatabaseService {
  const DatabaseService();

  SupabaseClient get _db => SupabaseConfig.client;

  // ── Generic helpers ────────────────────────────────────────────────────

  /// Insert a single [data] row into [table].
  Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, Object?> data,
  }) async {
    final result = await _db.from(table).insert(data).select().single();
    return result;
  }

  /// Fetch all rows from [table].
  Future<List<Map<String, dynamic>>> fetchAll({
    required String table,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
        _db.from(table).select();

    if (orderBy != null) {
      final ordered = query.order(orderBy, ascending: ascending);
      if (limit != null) {
        final result = await ordered.limit(limit);
        return List<Map<String, dynamic>>.from(result);
      }
      final result = await ordered;
      return List<Map<String, dynamic>>.from(result);
    }

    if (limit != null) {
      final result = await query.limit(limit);
      return List<Map<String, dynamic>>.from(result);
    }

    final result = await query;
    return List<Map<String, dynamic>>.from(result);
  }

  /// Fetch a single row by [id] from [table].
  Future<Map<String, dynamic>?> fetchById({
    required String table,
    required String id,
  }) async {
    final result = await _db
        .from(table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return result;
  }

  /// Update a row by [id] in [table] with [data].
  Future<Map<String, dynamic>> update({
    required String table,
    required String id,
    required Map<String, Object?> data,
  }) async {
    final result = await _db
        .from(table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return result;
  }

  /// Delete a row by [id] from [table].
  Future<void> delete({
    required String table,
    required String id,
  }) async {
    await _db.from(table).delete().eq('id', id);
  }

  // ── Domain-specific helpers ────────────────────────────────────────────

  /// Save or update a user profile in the `profiles` table.
  Future<void> upsertUserProfile({
    required String userId,
    required String fullName,
    required String email,
    required bool isFarmer,
    String? phone,
    String? location,
  }) async {
    await _db.from('profiles').upsert({
      'id': userId,
      'full_name': fullName,
      'email': email,
      'is_farmer': isFarmer,
      'phone': phone,
      'location': location,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Fetch all products, optionally filtered by [category].
  Future<List<Map<String, dynamic>>> fetchProducts({
    String? category,
    int limit = 20,
  }) async {
    var query = _db
        .from('products')
        .select('*, profiles(full_name)')
        .order('created_at', ascending: false);

    if (category != null) {
      final result = await query.eq('category', category).limit(limit);
      return List<Map<String, dynamic>>.from(result);
    }

    final result = await query.limit(limit);
    return List<Map<String, dynamic>>.from(result);
  }

  /// Create a new product listing (farmer use).
  Future<Map<String, dynamic>> createProduct({
    required String farmerId,
    required String name,
    required double pricePerKg,
    required String unit,
    required double availableQuantity,
    required String category,
    String? description,
  }) async {
    final result = await _db.from('products').insert({
      'farmer_id': farmerId,
      'name': name,
      'price_per_kg': pricePerKg,
      'unit': unit,
      'available_quantity': availableQuantity,
      'category': category,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();
    return result;
  }

  /// Create an order (buyer use).
  Future<Map<String, dynamic>> createOrder({
    required String buyerId,
    required String productId,
    required double quantity,
    required double totalPrice,
  }) async {
    final result = await _db.from('orders').insert({
      'buyer_id': buyerId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();
    return result;
  }
}
