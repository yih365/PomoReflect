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
                .padding(.bottom, textBoxBottomPadding)
                .font(.system(size: 15, weight: .regular, design: .default))

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
                .onSubmit {
                    // Add note unless empty
                    if (!currNote.isEmpty) {
                        saveNote()
                    }
                }
            
            if (!notes.isEmpty) {
                List {
                    ForEach(notes) {
                        note in
                        Text(note.text)
                            .listRowBackground(Color.white)
                    }
                    .onDelete(perform: deleteNote)
                }
                .frame(height: 200)
                .scrollContentBackground(.hidden)
            }

            Spacer()
        }
        .padding()
    }
    
    private func deleteNote(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                print("deleting at index \(index)")
                modelContext.delete(notes[index])
            }
        }
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
