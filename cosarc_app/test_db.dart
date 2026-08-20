import 'package:supabase/supabase.dart';
void main() async {
  final client = SupabaseClient('https://lgblxxixgldizfidscpz.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxnYmx4eGl4Z2xkaXpmaWRzY3B6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MDA1ODksImV4cCI6MjA5NDA3NjU4OX0.GYARRKYcjPrc2f-TGEAol7Zq1g4oiQJuiT8ZJpKayIA');
  try {
    final res = await client.from('gym_memberships').select().limit(1);
    print('SUCCESS: $res');
  } catch (e) {
    print('ERROR: $e');
  }
}
