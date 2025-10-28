import Foundation
import Capacitor
import HealthKit

@objc(HealthPlugin)
public class HealthPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "HealthPlugin"
    public let jsName = "Health"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "isAvailable", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestAuthorization", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "checkAuthorization", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "readSamples", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "startObservingHRV", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "saveSample", returnType: CAPPluginReturnPromise)
    ]

    private let implementation = Health()
    private let healthStore = HKHealthStore()
    private let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
    private var observerQuery: HKObserverQuery?

    @objc func startObservingHRV(_ call: CAPPluginCall) {
        healthStore.enableBackgroundDelivery(for: hrvType, frequency: .immediate) { [weak self] success, _ in
            guard success else { return }
            self?.observerQuery = HKObserverQuery(sampleType: self!.hrvType, predicate: nil) { [weak self] (_, completionHandler, _) in
                self?.fetchLatestHRV { hrvValue in
                    if let hrvValue = hrvValue {
                        let data: [String: Any] = ["hrv": hrvValue]
                        self?.notifyListeners("hrvChanged", data: data)
                    }
                }
                completionHandler()
            }
            self?.healthStore.execute(self!.observerQuery!)
            call.resolve()
        }
    }

    private func fetchLatestHRV(completion: @escaping (Double?) -> Void) {
        let query = HKSampleQuery(sampleType: hrvType, predicate: nil, limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, samples, _ in
            if let sample = samples?.first as? HKQuantitySample {
                let value = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                completion(value)
            } else {
                completion(nil)
            }
        }
        healthStore.execute(query)
    }

    @objc func isAvailable(_ call: CAPPluginCall) {
        call.resolve(implementation.availabilityPayload())
    }

    @objc func requestAuthorization(_ call: CAPPluginCall) {
        let read = (call.getArray("read") as? [String]) ?? []
        let write = (call.getArray("write") as? [String]) ?? []

        implementation.requestAuthorization(readIdentifiers: read, writeIdentifiers: write) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(payload):
                    call.resolve(payload.toDictionary())
                case let .failure(error):
                    call.reject(error.localizedDescription, nil, error)
                }
            }
        }
    }

    @objc func checkAuthorization(_ call: CAPPluginCall) {
        let read = (call.getArray("read") as? [String]) ?? []
        let write = (call.getArray("write") as? [String]) ?? []

        implementation.checkAuthorization(readIdentifiers: read, writeIdentifiers: write) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(payload):
                    call.resolve(payload.toDictionary())
                case let .failure(error):
                    call.reject(error.localizedDescription, nil, error)
                }
            }
        }
    }

    @objc func readSamples(_ call: CAPPluginCall) {
        guard let dataType = call.getString("dataType") else {
            call.reject("dataType is required")
            return
        }

        let startDate = call.getString("startDate")
        let endDate = call.getString("endDate")
        let limit = call.getInt("limit")
        let ascending = call.getBool("ascending") ?? false

        do {
            try implementation.readSamples(
                dataTypeIdentifier: dataType,
                startDateString: startDate,
                endDateString: endDate,
                limit: limit,
                ascending: ascending
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(samples):
                        call.resolve(["samples": samples])
                    case let .failure(error):
                        call.reject(error.localizedDescription, nil, error)
                    }
                }
            }
        } catch {
            call.reject(error.localizedDescription, nil, error)
        }
    }

    @objc func saveSample(_ call: CAPPluginCall) {
        guard let dataType = call.getString("dataType") else {
            call.reject("dataType is required")
            return
        }

        guard let value = call.getDouble("value") else {
            call.reject("value is required")
            return
        }

        let unit = call.getString("unit")
        let startDate = call.getString("startDate")
        let endDate = call.getString("endDate")
        let metadataAny = call.getObject("metadata") as? [String: Any]
        let metadata = metadataAny?.reduce(into: [String: String]()) { result, entry in
            if let stringValue = entry.value as? String {
                result[entry.key] = stringValue
            }
        }

        do {
            try implementation.saveSample(
                dataTypeIdentifier: dataType,
                value: value,
                unitIdentifier: unit,
                startDateString: startDate,
                endDateString: endDate,
                metadata: metadata
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        call.resolve()
                    case let .failure(error):
                        call.reject(error.localizedDescription, nil, error)
                    }
                }
            }
        } catch {
            call.reject(error.localizedDescription, nil, error)
        }
    }
}
