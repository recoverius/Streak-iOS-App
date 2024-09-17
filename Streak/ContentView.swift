//
//  ContentView.swift
//  Streak
//
//  Created by Ilya Golubev on 17/09/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        DashboardView()
            .environment(\.managedObjectContext, viewContext)
    }
}


extension Color {
    static let customPalette = CustomPalette()
    
    struct CustomPalette {
        // Primary Colors
        let electricBlue = Color(hex: 0x007AFF)
        let vibrantTeal = Color(hex: 0x34C759)
        
        // Secondary Colors
        let softPurple = Color(hex: 0xAF52DE)
        let brightMagenta = Color(hex: 0xFF2D55)
        
        // Accent Colors
        let gold = Color(hex: 0xFFD700)
        let amber = Color(hex: 0xFF9500)
        
        // Neutral Colors
        let richBlack = Color(hex: 0x000000)
        let darkGray = Color(hex: 0x1C1C1E)
        let offWhite = Color(hex: 0xF2F2F7)
        let lightGray = Color(hex: 0x8E8E93)
    }
    
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

//
//extension Color {
//    static let customPalette = CustomPalette()
//    
//    struct CustomPalette {
//        // Primary Colors
//        let electricBlue = Color(hex: 0x007AFF)
//        let vibrantTeal = Color(hex: 0x34C759)
//        
//        // Secondary Colors
//        let softPurple = Color(hex: 0xAF52DE)
//        let brightMagenta = Color(hex: 0xFF2D55)
//        
//        // Accent Colors
//        let gold = Color(hex: 0xFFD700)
//        let amber = Color(hex: 0xFF9500)
//        
//        // Neutral Colors
//        let richBlack = Color(hex: 0x000000)
//        let darkGray = Color(hex: 0x1C1C1E)
//        let offWhite = Color(hex: 0xF2F2F7)
//        let lightGray = Color(hex: 0x8E8E93)
//    }
//    
//    init(hex: UInt, alpha: Double = 1) {
//        self.init(
//            .sRGB,
//            red: Double((hex >> 16) & 0xff) / 255,
//            green: Double((hex >> 08) & 0xff) / 255,
//            blue: Double((hex >> 00) & 0xff) / 255,
//            opacity: alpha
//        )
//    }
//}
