import 'package:supabase_flutter/supabase_flutter.dart';

class SSupabaseHelper {
  static final client = Supabase.instance.client;
  static final auth = client.auth;
  static final currentUser = auth.currentUser;
}
