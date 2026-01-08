import SwiftUI

struct NoteRowView: View {
    let note: DailyNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title)
                .font(.headline)
                .lineLimit(1)
            
            Text(note.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text(note.createdAt, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}