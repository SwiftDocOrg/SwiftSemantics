extension StringProtocol {
    var nonEmpty: String? {
        return isEmpty ? nil : String(self)
    }

    var trimmed: String {
        let startIndex = firstIndex(where: { !$0.isWhitespace }) ?? self.startIndex
        let endIndex = lastIndex(where: { !$0.isWhitespace }) ?? self.endIndex
        return String(self[startIndex...endIndex])
    }
}
