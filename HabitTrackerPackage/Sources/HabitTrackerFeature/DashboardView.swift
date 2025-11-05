import SwiftUI

public struct DashboardView: View {
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack {
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your habits overview")
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}

