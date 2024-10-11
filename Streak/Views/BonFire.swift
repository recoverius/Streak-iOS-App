import SwiftUI

// MARK: - Background View
struct BackgroundView: View {
    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: [Color(red: 85/255, green: 13/255, blue: 57/255),
                                       Color(red: 39/255, green: 5/255, blue: 55/255)]),
            center: .center,
            startRadius: 0,
            endRadius: 600
        )
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Log and Streak Views
struct LogView: View {
    var body: some View {
        ZStack {
            // Log base
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(red: 120/255, green: 30/255, blue: 32/255))
                .frame(width: 238, height: 70)
                .opacity(0.99)
                .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 0)
            
            // Streaks
            ForEach(0..<10) { index in
                StreakView(index: index)
            }
        }
        .frame(width: 238, height: 70)
    }
}

struct StreakView: View {
    let index: Int
    
    var body: some View {
        Rectangle()
            .fill(Color(red: 179/255, green: 80/255, blue: 80/255))
            .frame(height: 2)
            .cornerRadius(20)
            .offset(x: getOffsetX(index: index), y: 0)
            .frame(width: getWidth(index: index), height: 2)
            .position(x: getPositionX(index: index), y: 35) // Center Y
    }
    
    func getOffsetX(index: Int) -> CGFloat {
        // Mirror CSS left positions to SwiftUI
        switch index {
        case 0: return -84
        case 1: return -59
        case 2: return -24
        case 3: return -14
        case 4: return 4
        case 5: return 62
        case 6: return -32
        case 7: return 40
        case 8: return -68
        case 9: return 20
        default: return 0
        }
    }
    
    func getWidth(index: Int) -> CGFloat {
        switch index {
        case 0: return 90
        case 1: return 80
        case 2: return 30
        case 3: return 132
        case 4: return 48
        case 5: return 28
        case 6: return 160
        case 7: return 40
        case 8: return 54
        case 9: return 110
        default: return 50
        }
    }
    
    func getPositionX(index: Int) -> CGFloat {
        // Base position x is 119 (half of 238)
        return 119 + getOffsetX(index: index) + getWidth(index: index)/2
    }
}

// MARK: - Stick Views
struct SticksView: View {
    var body: some View {
        ZStack {
            ForEach(0..<4) { index in
                StickView(index: index)
            }
        }
        .frame(width: 600, height: 600)
    }
}

struct StickView: View {
    let index: Int
    
    var body: some View {
        ZStack {
            // Stick base
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 120/255, green: 30/255, blue: 32/255))
                .frame(width: 68, height: 20)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 0)
            
            // Decorative elements
            Rectangle()
                .fill(Color(red: 120/255, green: 30/255, blue: 32/255))
                .frame(width: 6, height: 20)
                .offset(x: 30, y: -10) // Adjusted to mimic CSS translateY(50%) rotate(32deg)
                .rotationEffect(.degrees(32))
            
            Circle()
                .fill(Color(red: 179/255, green: 80/255, blue: 80/255))
                .frame(width: 20, height: 20)
                .offset(x: 20, y: 0)
        }
        .rotationEffect(.degrees(getRotation(index: index)))
        .scaleEffect(getScale(index: index))
        .offset(x: getOffsetX(index: index), y: getOffsetY(index: index))
        .zIndex(getZIndex(index: index))
    }
    
    func getRotation(index: Int) -> Double {
        switch index {
        case 0: return -152
        case 1: return 20
        case 2: return 170
        case 3: return 80
        default: return 0
        }
    }
    
    func getScale(index: Int) -> CGFloat {
        switch index {
        case 0, 3: return 0.8
        case 1, 2: return 0.9
        default: return 1.0
        }
    }
    
    func getOffsetX(index: Int) -> CGFloat {
        switch index {
        case 0: return 158
        case 1: return 180
        case 2: return 400
        case 3: return 370
        default: return 0
        }
    }
    
    func getOffsetY(index: Int) -> CGFloat {
        switch index {
        case 0: return 164
        case 1: return 30
        case 2: return 38
        case 3: return 150
        default: return 0
        }
    }
    
    func getZIndex(index: Int) -> Double {
        switch index {
        case 0: return 12
        case 1: return 0
        case 2: return 0
        case 3: return 20
        default: return 0
        }
    }
}

// MARK: - Fire Views
struct FireView: View {
    let heightMultiplier: Double
    
    var body: some View {
        ZStack {
            FireLayerView(
                heightMultiplier: heightMultiplier,
                color: Color(red: 226/255, green: 15/255, blue: 0/255),
                shadowColor: Color(red: 226/255, green: 15/255, blue: 0/255, opacity: 0.4),
                flameData: [
                    (138, 160, 0.15),
                    (186, 240, 0.35),
                    (234, 300, 0.1),
                    (282, 360, 0.0),
                    (330, 310, 0.45),
                    (378, 232, 0.3),
                    (426, 140, 0.1)
                ]
            )
            
            FireLayerView(
                heightMultiplier: heightMultiplier,
                color: Color(red: 255/255, green: 156/255, blue: 0/255),
                shadowColor: Color(red: 255/255, green: 156/255, blue: 0/255, opacity: 0.4),
                flameData: [
                    (138, 140, 0.05),
                    (186, 210, 0.1),
                    (234, 250, 0.35),
                    (282, 300, 0.4),
                    (330, 260, 0.5),
                    (378, 202, 0.35),
                    (426, 110, 0.1)
                ]
            )
            
            FireLayerView(
                heightMultiplier: heightMultiplier,
                color: Color(red: 255/255, green: 235/255, blue: 110/255),
                shadowColor: Color(red: 255/255, green: 235/255, blue: 110/255, opacity: 0.4),
                flameData: [
                    (186, 140, 0.6),
                    (234, 172, 0.4),
                    (282, 240, 0.38),
                    (330, 200, 0.22),
                    (378, 142, 0.18)
                ]
            )
            
            FireLayerView(
                heightMultiplier: heightMultiplier,
                color: Color(red: 254/255, green: 241/255, blue: 217/255),
                shadowColor: Color(red: 254/255, green: 241/255, blue: 217/255, opacity: 0.4),
                flameData: [
                    (156, 100, 0.22),
                    (181, 120, 0.42),
                    (234, 170, 0.32),
                    (282, 210, 0.8),
                    (330, 170, 0.85),
                    (378, 110, 0.64),
                    (408, 100, 0.32)
                ]
            )
        }
        .frame(width: 600, height: 600)
    }
}

struct FireLayerView: View {
    let heightMultiplier: Double
    let color: Color
    let shadowColor: Color
    let flameData: [(CGFloat, CGFloat, Double)]
    
    var body: some View {
        ZStack {
            ForEach(0..<flameData.count, id: \.self) { index in
                FlameView(
                    heightMultiplier: heightMultiplier,
                    color: color,
                    shadowColor: shadowColor,
                    xPosition: flameData[index].0,
                    height: flameData[index].1,
                    delay: flameData[index].2
                )
            }
        }
    }
}

struct FlameView: View {
    let heightMultiplier: Double
    let color: Color
    let shadowColor: Color
    let xPosition: CGFloat
    let height: CGFloat
    let delay: Double
    
    
    @State private var animatedHeight: CGFloat = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(color)
            .frame(width: 48, height: animatedHeight)
            .shadow(color: shadowColor, radius: 80, x: 0, y: 0)
            .offset(x: xPosition - 156, y: 0) // Adjusting xPosition relative to center
            .onAppear {
                // Animate only the height to simulate scaleY
                withAnimation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    animatedHeight = min((height * heightMultiplier), 600)
                }
            }
    }
}

// MARK: - Sparks Views
struct SparksView: View {
    var body: some View {
        ZStack {
            ForEach(0..<8) { index in
                SparkView(index: index)
            }
        }
        .frame(width: 100, height: 100)
    }
}

struct SparkView: View {
    let index: Int
    
    @State private var yOffset: CGFloat = 0
    @State private var opacityLevel: Double = 0
    
    var body: some View {
        Rectangle()
            .fill(Color(red: 254/255, green: 241/255, blue: 217/255))
            .frame(width: 6, height: 20)
            .cornerRadius(18)
            .opacity(opacityLevel)
            .offset(x: getOffsetX(index: index), y: yOffset)
            .animation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false)
                    .delay(getDelay(index: index))
            )
            .onAppear {
                // Start the spark animation
                withAnimation {
                    yOffset = -10
                    opacityLevel = 1.0
                }
                // Reset after the animation cycle
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        yOffset = 0
                        opacityLevel = 0.0
                    }
                }
            }
    }
    
    func getOffsetX(index: Int) -> CGFloat {
        switch index {
        case 0: return 160
        case 1: return 180
        case 2: return 208
        case 3: return 310
        case 4: return 360
        case 5: return 390
        case 6: return 400
        case 7: return 430
        default: return 0
        }
    }
    
    func getDelay(index: Int) -> Double {
        switch index {
        case 0: return 0.4
        case 1: return 1.0
        case 2: return 0.8
        case 3: return 2.0
        case 4: return 0.75
        case 5: return 0.65
        case 6: return 1.0
        case 7: return 1.4
        default: return 0.0
        }
    }
}

// MARK: - Logs Composition
struct LogsView: View {
    var body: some View {
        ZStack {
            ForEach(0..<7) { index in
                LogPositionView(index: index)
            }
        }
        .frame(width: 600, height: 600)
    }
}

struct LogPositionView: View {
    let index: Int
    
    var body: some View {
        LogView()
            .rotationEffect(getRotation(index: index))
            .scaleEffect(getScale(index: index))
            .offset(x: getOffsetX(index: index), y: getOffsetY(index: index))
            .zIndex(getZIndex(index: index))
    }
    
    func getRotation(index: Int) -> Angle {
        switch index {
        case 0: return Angle(degrees: 150)
        case 1: return Angle(degrees: 110)
        case 2: return Angle(degrees: -10)
        case 3: return Angle(degrees: -120)
        case 4: return Angle(degrees: -30)
        case 5: return Angle(degrees: 35)
        case 6: return Angle(degrees: -30)
        default: return Angle(degrees: 0)
        }
    }
    
    func getScale(index: Int) -> CGFloat {
        switch index {
        case 5: return 0.85
        default: return 0.75
        }
    }
    
    func getOffsetX(index: Int) -> CGFloat {
        switch index {
        case 0: return 100
        case 1: return 140
        case 2: return 68
        case 3: return 220
        case 4: return 210
        case 5: return 280
        case 6: return 300
        default: return 0
        }
    }
    
    func getOffsetY(index: Int) -> CGFloat {
        switch index {
        case 0: return 100
        case 1: return 120
        case 2: return 98
        case 3: return 80
        case 4: return 75
        case 5: return 92
        case 6: return 70
        default: return 0
        }
    }
    
    func getZIndex(index: Int) -> Double {
        switch index {
        case 0: return 20
        case 1: return 10
        case 2: return 0
        case 3: return 26
        case 4: return 25
        case 5: return 30
        case 6: return 20
        default: return 0
        }
    }
}

// MARK: - Campfire Composition
struct CampfireView: View {
    let heightMultiplier: Double
    
    var body: some View {
        ZStack {
            // Logs
            //LogsView()
            
            // Sticks
            //SticksView()
            
            // Fire
            FireView(heightMultiplier: heightMultiplier)
                
            
            // Sparks
            SparksView()
               
        }
        .frame(width: 100, height: 160)
        .scaleEffect(0.2)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 10)).size(width: 100, height: 80))
    }
}

struct CampfireViewWrapper: View {
    let longestStreak: Int
    
    var body: some View {
        CampfireView(heightMultiplier: 0.2 + Double(longestStreak / 6))
            .id(longestStreak) // This forces a redraw when longestStreak changes
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
