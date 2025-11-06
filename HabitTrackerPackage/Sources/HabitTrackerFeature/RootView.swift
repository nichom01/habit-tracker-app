import SwiftUI

public struct RootView: View {
    @State private var showSplash = true
    
    public init() {}
    
    public var body: some View {
        if showSplash {
            SplashScreenView()
                .onAppear {
                    // Show splash screen for 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
                }
        } else {
            ContentView()
        }
    }
}

