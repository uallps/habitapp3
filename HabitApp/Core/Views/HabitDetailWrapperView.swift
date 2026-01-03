import SwiftUI
import SwiftData

struct HabitDetailWrapper: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    // IF CATEGORY IS TRUE
    @StateObject var categoryListVM: CategoryListViewModel
    @StateObject var userImageVM: UserImagesViewModel
    // END IF
    
    @EnvironmentObject private var appConfig: AppConfig
    
    @ObservedObject var habitListVM: HabitListViewModel
    @State var habit: Habit
    private let isNew: Bool
    
    init(habitListVM: HabitListViewModel, modelContext: ModelContext? = nil, isNew: Bool, habit: Habit) {
        _categoryListVM = StateObject(wrappedValue: CategoryListViewModel(storageProvider: appConfig.storageProvider))
        _userImageVM = StateObject(wrappedValue: UserImagesViewModel())
        self.habitListVM = habitListVM
        self.isNew = isNew
        self._habit = State(initialValue: habit)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 🔹 Título
            TextField("Título del hábito", text: $habit.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // 🔹 Días de la semana
            Text("Selecciona los días de la semana")
                .font(.headline)
            
            WeekdaySelector(selectedDays: $habit.scheduledDays)
                .padding(.horizontal)
            
            // 🔹 Prioridad
            Text("Prioridad")
                .font(.headline)
                .padding(.top)
            
            Picker("Prioridad", selection: Binding(
                get: { habit.priority ?? .medium },
                set: { habit.priority = $0 }
            )) {
                ForEach(Priority.allCases, id: \.self) { priority in
                    Text(priority.localized.togglingFirstLetterCase).tag(priority)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Spacer()
            
            categorySection
        }
        
        Spacer()
        
        // 🔹 Botón Guardar
        Button(action: saveHabit) {
            Text("Guardar hábito")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding(.horizontal)
        }
        .background(Color.blue)
        .cornerRadius(10)
        
        // 🔹 Botón Eliminar (solo si no es nuevo)
        
    }

        .navigationTitle(isNew ? "Nuevo hábito" : "Editar hábito")
        .padding()
    }
    
    var categorySection: some View {
        Section(header: Text("Añadir hábito a categoría")) {
            if Array(categoryListVM.categories.values).isEmpty {
                Text("No hay categorías disponibles. Crea al menos una categoría.")
                    .foregroundColor(.gray)

            }else {
                List {
                    ForEach(Array(categoryListVM.categories.values).sorted(by: { $0.name < $1.name })) { category in
                       NavigationLink {
                            CategoryDetailWrapperView(
                                viewModel: categoryListVM,
                                category: category,
                                userImageVM: userImageVM,
                                isSubcategory: category.isSubcategory
                            )
                       } label: {
                             CategoryRowView(category: category)

                       }
                       .buttonStyle(.plain)

                    }
                }
                .frame(minHeight: 120, maxHeight: 300)
            }
        }    }
    
    // MARK: - Funciones
    private func saveHabit() {
        if isNew {
            modelContext.insert(habit)
        }
        try? modelContext.save()
        dismiss()
    }
    
    private func deleteHabit() {
        modelContext.delete(habit)
        try? modelContext.save()
        dismiss()
    }
}
