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
        let electricBlue = Color(hex: 0x73787C) // Changed to Charcoal
        let vibrantTeal = Color(hex: 0x75d27e) // Changed to Soft Green
        
        // Secondary Colors
        let softPurple = Color(hex: 0xC5C6C7) // Changed to Gray
        let brightMagenta = Color(hex: 0xf87559) // Changed to Beige
        
        // Accent Colors
        let gold = Color(hex: 0xD7E5F0) // Changed to Pale Blue
        let amber = Color(hex: 0x554940) // Changed to Taupe
        
        // Neutral Colors
        let richBlack = Color(hex: 0xFFFFFF) // Kept as Black
        let darkGray = Color(hex: 0x73787C) // Changed to Charcoal
        let offWhite = Color(hex: 0xF2F2F7) // Kept the same
        let lightGray = Color(hex: 0x8E8E93) // Kept the same
        
        //Habit Colors
        let pastelRed = Color(hex: 0xFFA0A8)
        let pastelOrange = Color(hex: 0xFFCCA8)
        let pastelYellow = Color(hex: 0xFFEEA8)
        let pastelGreen = Color(hex: 0xA8FFA8)
        let pastelBlue = Color(hex: 0xA8CEFF)
        let pastelPurple = Color(hex: 0xD6A8FF)
        
        let deepPastelRed = Color(hex: 0xFF8D96)
        let deepPastelOrange = Color(hex: 0xFFB996)
        let deepPastelYellow = Color(hex: 0xFFDF96)
        let deepPastelGreen = Color(hex: 0x96FF96)
        let deepPastelBlue = Color(hex: 0x96BBFF)
        let deepPastelPurple = Color(hex: 0xC496FF)

        subscript(colorName: String) -> Color {
            switch colorName {
            case "pastelRed": return pastelRed
            case "pastelOrange": return pastelOrange
            case "pastelYellow": return pastelYellow
            case "pastelGreen": return pastelGreen
            case "pastelBlue": return pastelBlue
            case "pastelPurple": return pastelPurple
            case "deepPastelRed": return deepPastelRed
            case "deepPastelOrange": return deepPastelOrange
            case "deepPastelYellow": return deepPastelYellow
            case "deepPastelGreen": return deepPastelGreen
            case "deepPastelBlue": return deepPastelBlue
            case "deepPastelPurple": return deepPastelPurple
            default: return .gray
            }
        }
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
