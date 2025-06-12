//
//  Friend.swift
//  Squest
//
//  Created by Star Feng on 6/12/25.
//

import Foundation

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let username: String
    let lastActive: String // e.g., "1h ago", "Just now", "2d ago"
    let onQuest: String?
    let profileInitials: String // e.g., "JR"
    let level: Int
}
