import SwiftUI
import _SwiftData_SwiftUI

struct CategoryListView: View {
    @StateObject var categoryListVM: CategoryListViewModel
    @Query var categoriesQuery: [Category]
    
    @State private var selectedPriority: Priority? = nil
    @State private var selectedColor: Color? = nil
    @State private var selectedColorName: String? = ""
    
    init(storageProvider: StorageProvider) {
        _categoryListVM = StateObject(wrappedValue: CategoryListViewModel(storageProvider: storageProvider))
    }
    
    var body: some View {
        
#if os(iOS)
        iOSBody
#else
        macOSBody
#endif
    }
    
#if os(iOS)
@ViewBuilder
var iOSBody: some View {
    NavigationStack {
        VStack(spacing: 12) {
            List(Array(categoriesQuery).filter { category in
                    // Always ignore subcategories
                    guard !category.isSubcategory else { return false }
                    
                    // Filter by selected priority
                    if let selectedPriority = selectedPriority, category.priority != selectedPriority {
                        return false
                    }
                    
                    // Filter by selected color
                    if let selectedColorName = selectedColorName,
                       category.colorAssetName.lowercased() != selectedColorName.lowercased() {
                        return false
                    }
                    
                    return true
            }                ) { category in
                NavigationLink {
                    CategoryDetailWrapperView(
                        storageProvider: categoryListVM.storageProvider,
                        category: category,
                        isSubcategory: category.isSubcategory
                    )
                } label: {
                    CategoryRowView(
                        storageProvider: categoryListVM.storageProvider,
                        category: category,
                        isCategoryParentView: true
                    )
                }
                
                

            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Categorías")
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                NavigationLink {
                    let category = Category(
                        id: UUID(),
                        name: "",
                        icon: UserImageSlot(image: nil),
                        priority: .low,
                        isSubcategory: false
                    )
                    CategoryDetailWrapperView(
                        storageProvider: categoryListVM.storageProvider,
                        category: category,
                        isSubcategory: category.isSubcategory
                    )
                } label: {
                    Label("Añadir", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Menu {
                    Picker("Priority", selection: $selectedPriority) {
                        Text("All").tag(Priority?.none)
                        Text("Alta").tag(Priority.high as Priority?)
                        Text("Media").tag(Priority.medium as Priority?)
                        Text("Baja").tag(Priority.low as Priority?)
                    }

                    Picker("Color", selection: $selectedColorName) {
                        Text("All").tag(String?.none)
                        Text("Red").tag("red" as String?)
                        Text("Blue").tag("blue" as String?)
                        Text("Green").tag("green" as String?)
                        // Add all your colors here
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }        })
    }
}

    
#else
    @ViewBuilder
    var macOSBody: some View {
        VStack(spacing: 12) {
            NavigationStack {
                List(Array(categoriesQuery).filter { category in
                    // Always ignore subcategories
                    guard !category.isSubcategory else { return false }
                    
                    // Filter by selected priority
                    if let selectedPriority = selectedPriority, category.priority != selectedPriority {
                        return false
                    }
                    
                    // Filter by selected color
                    if let selectedColorName = selectedColorName,
                       category.colorAssetName.lowercased() != selectedColorName.lowercased() {
                        return false
                    }
                    
                    return true
                }) { category in
                    NavigationLink {
                        CategoryDetailWrapperView(
                            storageProvider: categoryListVM.storageProvider,
                            category: category,
                            isSubcategory: category.isSubcategory
                        )
                    } label: {
                        CategoryRowView(
                            storageProvider: categoryListVM.storageProvider,
                            category: category,
                            isCategoryParentView: true
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Categorías")
                .toolbar {
                    // Add category button
                    ToolbarItem(placement: .automatic) {
                        NavigationLink {
                            let category = Category(
                                id: UUID(),
                                name: "",
                                icon: UserImageSlot(image: nil),
                                priority: .low,
                                isSubcategory: false
                            )
                            CategoryDetailWrapperView(
                                storageProvider: categoryListVM.storageProvider,
                                category: category,
                                isSubcategory: category.isSubcategory
                            )
                        } label: {
                            Label("Añadir", systemImage: "plus")
                        }
                    }
                    
                    // Filter menu
                    ToolbarItem(placement: .automatic) {
                        Menu {
                            // Priority Picker
                            Picker("Priority", selection: $selectedPriority) {
                                Text("All").tag(Priority?.none)
                                Text("Alta").tag(Priority.high as Priority?)
                                Text("Media").tag(Priority.medium as Priority?)
                                Text("Baja").tag(Priority.low as Priority?)
                            }
                            
                            // Color Picker
                            Picker("Color", selection: $selectedColorName) {
                                Text("All").tag(String?.none)
                                Text("Red").tag("red" as String?)
                                Text("Orange").tag("orange" as String?)
                                Text("Yellow").tag("yellow" as String?)
                                Text("Green").tag("green" as String?)
                                Text("Mint").tag("mint" as String?)
                                Text("Teal").tag("teal" as String?)
                                Text("Cyan").tag("cyan" as String?)
                                Text("Blue").tag("blue" as String?)
                                Text("Indigo").tag("indigo" as String?)
                                Text("Purple").tag("purple" as String?)
                                Text("Pink").tag("pink" as String?)
                                Text("Brown").tag("brown" as String?)
                                Text("Gray").tag("gray" as String?)
                            }
                        } label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
            }
        }
    }

#endif
    
}
