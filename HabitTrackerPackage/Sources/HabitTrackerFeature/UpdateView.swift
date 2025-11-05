import SwiftUI

public struct UpdateView: View {
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack {
                Text("Update")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Log your habit updates")
                    .foregroundStyle(.secondary)
                    .padding()
            }
            .navigationTitle("Update")
        }
    }
}

