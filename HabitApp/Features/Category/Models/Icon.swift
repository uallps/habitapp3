import Foundation

class Icon {
    let id: String

    init(id: String) {
        self.id = id
    }

    // Required for Hashable
    static func == (lhs: Icon, rhs: Icon) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

