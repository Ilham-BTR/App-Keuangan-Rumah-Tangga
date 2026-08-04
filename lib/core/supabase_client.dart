import 'package:supabase_flutter/supabase_flutter.dart';

/// Akses cepat ke instance Supabase yang sudah diinisialisasi di main().
SupabaseClient get supabase => Supabase.instance.client;
