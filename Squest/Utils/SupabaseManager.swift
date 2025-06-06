import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://zlxtalqevxjvygtthrcf.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpseHRhbHFldnhqdnlndHRocmNmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgxMDE5ODUsImV4cCI6MjA2MzY3Nzk4NX0.NB39SLQqJyKISsPxWGhkvKYu-Gjg_-CA12jQwGvKq34"
        )
    }
} 
