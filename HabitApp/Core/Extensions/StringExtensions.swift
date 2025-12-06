extension String {
    var togglingFirstLetterCase: String {
        guard let first = first else { return self }
        let firstToggled: String
        firstToggled = first.isUppercase ? first.lowercased() : first.uppercased()
        return firstToggled + dropFirst()
    }
}
