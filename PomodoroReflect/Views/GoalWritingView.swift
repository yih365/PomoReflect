import SwiftUI
import _SwiftData_SwiftUI
import Combine

final class GoalViewModel: ObservableObject {
    private var disposeBag = Set<AnyCancellable>()

    @Published var text: String = ""

    init() {
        text = UserDefaults.standard.string(forKey: "goal") ?? ""
        self.debounceTextChanges()
    }

    private func debounceTextChanges() {
        $text
            // 1 second debounce
            .debounce(for: 1, scheduler: RunLoop.main)

            // Called when text stops updating (stoped typing)
            .sink {
                print("new goal text value: \($0)")
                // Save goal to UserDefaults
                UserDefaults.standard.set($0, forKey: "goal")
            }
            .store(in: &disposeBag)
    }
}


struct GoalWritingView: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject var goalViewModel = GoalViewModel()
    @State private var currNote: String = ""
    
    private var textBoxBottomPadding = CGFloat(30)
    private var TFTextColor = Color.black
    
    @Query private var notes: [Note]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Goal Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Image(systemName: "target") 
                    //     .foregroundColor(.blue)
                    Text("Session Goal")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }

                TextField("", text: $goalViewModel.text,
                          prompt: Text("What do you want to achieve?").foregroundColor(.gray))
                    .foregroundColor(TFTextColor)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
                    .font(.system(size: 15, weight: .regular))
                
                HStack {
                    Text("💡 Make it specific and achievable")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: { showGoalExamples() }) {
                        Text("See examples")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.bottom, 10)

            // Thoughts Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Image(systemName: "brain")
                    //     .foregroundColor(.purple)
                    Text("Capture Thoughts")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                
                TextField("", text: $currNote,
                          prompt: Text("Write down any distracting thoughts...").foregroundColor(.gray))
                    .foregroundColor(TFTextColor)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
                    .font(.system(size: 15, weight: .regular))
                    .onSubmit { if (!currNote.isEmpty) { saveNote() } }
                
                Text("🎯 Focus now, address these thoughts later")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            if (!notes.isEmpty) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Captured Thoughts")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    List {
                        ForEach(notes) { note in
                            HStack {
                                Text("•")
                                    .foregroundColor(.purple)
                                Text(note.text)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 8)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteNote)
                    }
                    .frame(height: 200)
                    .scrollContentBackground(.hidden)
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.pagePigment)
    }
    
    private func deleteNote(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                print("deleting at index \(index)")
                modelContext.delete(notes[index])
            }
        }
    }
    
    private func showGoalExamples() {
        let examples = [
            "• Complete section 3.2 of my research paper",
            "• Write test cases for the new feature",
            "• Read and summarize chapter 4",
            "• Solve 5 practice problems",
            "• Draft outline for presentation"
        ]
        
        // Show examples in an alert
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let alert = UIAlertController(
            title: "Example Goals",
            message: examples.joined(separator: "\n"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        window.rootViewController?.present(alert, animated: true)
    }
    
    private func saveNote() {
        guard !currNote.isEmpty else { return }
        withAnimation {
            let newNote = Note(text: currNote)
            modelContext.insert(newNote)
            currNote = ""
        }
    }
}

#Preview {
    GoalWritingView()
        .modelContainer(for: Note.self, inMemory:true)
}
