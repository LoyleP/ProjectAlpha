import Foundation
import SwiftData

@Model
class MoodEntry {
    var timestamp: Date
    var moodName: String
    
    // New Fields
    var energy: Int // 1-10 scale
    var note: String
    
    // Updated Init to include new fields (with defaults to avoid errors)
    init(mood: Mood, energy: Int = 5, note: String = "") {
        self.timestamp = Date()
        self.moodName = mood.rawValue
        self.energy = energy
        self.note = note
    }
}
