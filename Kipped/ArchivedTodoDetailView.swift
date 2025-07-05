import SwiftUI

struct ArchivedTodoDetailView: View {
    let todo: Todo
    @ObservedObject var todoViewModel: TodoViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 32) {
            Text(todo.title)
                .font(.title)
                .padding()
            Button(action: {
                todoViewModel.unarchiveTodo(todo)
                dismiss()
            }) {
                Label("Unarchive", systemImage: "arrow.uturn.left")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(16)
            }
            Spacer()
        }
        .padding()
    }
} 