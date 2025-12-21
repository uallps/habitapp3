import SwiftUI

struct CategoryRowView: View {
    
    let category: CategorySet
    
    var body: some View {
        
        HStack() {
            Text(category.name)
            
            Circle()
                .fill(category.color)
                .frame(width: 26, height: 26)
                .overlay(
                    Circle().stroke(Color.black, lineWidth: 1)
                )
            
        }
    }
}
