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
        VStack {
            Text("Goal for this session:")
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundColor(.black)
                .padding(.bottom, 2)

            TextField("", text: $goalViewModel.text,
                      prompt: Text("Enter your goal").foregroundColor(.gray))
                .foregroundColor(TFTextColor)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.black, style: StrokeStyle(lineWidth: 1.0)))
                .padding(.bottom, 5)
                .font(.system(size: 15, weight: .regular, design: .default))
            
            Text("Make it specific and achievable within this session")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 4)
            
            Button(action: {
                showGoalExamples()
            }) {
                Text("See example goals")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, textBoxBottomPadding)

            Text("Extraneous thoughts during session:")
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundColor(.black)
                .padding(.bottom, 2)
            
            TextField("", text: $currNote,
                      prompt: Text("Note your extraneous thoughts").foregroundColor(.gray))
                .foregroundColor(TFTextColor)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.black, style: StrokeStyle(lineWidth: 1.0)))
                .font(.system(size: 15, weight: .regular, design: .default))
                .padding(.bottom, 5)
                .onSubmit {
                    if (!currNote.isEmpty) {
                        saveNote()
                    }
                }
            
            Text("Write down your distracting thoughts and come back to them later.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 8)
            
            if (!notes.isEmpty) {
                List {
                    ForEach(notes) {
                        note in
                        Text(note.text)
                            .listRowBackground(Color.white)
                            .foregroundColor(.black)
                    }
                    .onDelete(perform: deleteNote)
                }
                .frame(height: 200)
                .scrollContentBackground(.hidden)
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
