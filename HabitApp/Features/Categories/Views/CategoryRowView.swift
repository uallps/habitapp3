import SwiftUI

struct CategoryRowView: View {
    
    let category: CategorySet
    
    var body: some View {
            VStack(alignment: .leading) {
                Text(category.name)
            }
            
            Spacer()
        }
    }
