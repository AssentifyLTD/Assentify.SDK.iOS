    private func getIsLocked()->Bool{
        guard let key = field.inputKey else { return false }
        let defaultValue = AssistedFormHelper.getDefaultValueValue(key, page, flowController: self.flowController) ?? ""
        return field.isLocked! && !defaultValue.isEmpty
    }