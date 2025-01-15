import SwiftUI

struct GoalWritingView: View {
    @State private var goal: String = ""

    var body: some View {
        VStack {
            Text("Goal for this session:")
                .font(.headline)
                .padding(.bottom, 10)

            TextField("Enter your goal", text: $goal)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disableAutocorrection(true)
        }
        .padding()
    }
}

#Preview {
    GoalWritingView()
}
