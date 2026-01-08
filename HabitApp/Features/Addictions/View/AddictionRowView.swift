import SwiftUI

struct AddictionRowView: View {
    let addiction: Addiction

    var body: some View {
        HStack {
            Text(addiction.name)
                .font(.headline)
            Spacer()
            Text("\(addiction.severity.rawValue) \(addiction.severity.emoji)")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text("Recaídas: \(addiction.relapseCount)")
                .font(.subheadline)
                .foregroundColor(.red)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}