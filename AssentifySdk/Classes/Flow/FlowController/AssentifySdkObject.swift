//
//  AssentifySdkObject.swift
//  Pods
//
//  Created by TariQ on 11/02/2026.
//




public final class AssentifySdkObject {

    public static let shared = AssentifySdkObject()
    private init() {}

    private var sssentifySdk: AssentifySdk?

    public func set(_ key: AssentifySdk) {
        self.sssentifySdk = key
    }

    public func get() -> AssentifySdk? {
        return sssentifySdk
    }

    public func clear() {
        sssentifySdk = nil
    }
}

public final class ApiKeyObject {

    public static let shared = ApiKeyObject()
    private init() {}

    private var apiKey: String?

    public func set(_ key: String) {
        self.apiKey = key
    }

    public func get() -> String? {
        return apiKey
    }

    public func clear() {
        apiKey = nil
    }
}


public final class FlowEnvironmentalConditionsObject {

    public static let shared = FlowEnvironmentalConditionsObject()
    private init() {}

    private var value: FlowEnvironmentalConditions?

    public func set(_ conditions: FlowEnvironmentalConditions) {
        self.value = conditions
    }

    public func get() -> FlowEnvironmentalConditions? {
        return value
    }

    public func clear() {
        value = nil
    }
}

public final class ConfigModelObject {

    public static let shared = ConfigModelObject()
    private init() {}

    private var config: ConfigModel?

    public func set(_ model: ConfigModel) {
        self.config = model
    }

    public func get() -> ConfigModel? {
        return config
    }

    public func clear() {
        config = nil
    }
}

public final class LocalStepsObject {

    public static let shared = LocalStepsObject()
    private init() {}

    private var steps: [LocalStepModel]? = []

    public func set(_ model: [LocalStepModel]) {
        self.steps = model
    }

    public func get() -> [LocalStepModel]? {
        return steps
    }

    public func clear() {
        steps = nil
    }
}







public final class SelectedTemplatesObject {

    public static let shared = SelectedTemplatesObject()
    private init() {}

    private var templates: Templates?

    public func set(_ model: Templates) {
        self.templates = model
    }

    public func get() -> Templates? {
        return templates
    }

    public func clear() {
        templates = nil
    }
}

