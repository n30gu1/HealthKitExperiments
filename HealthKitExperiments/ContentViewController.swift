//
//  ContentViewController.swift
//  HealthKitExperiments
//
//  Created by Sung Park on 2022/07/30.
//

import Combine
import HealthKit

class ContentViewController: ObservableObject {
    var healthStore: HKHealthStore?
    
    @Published var hrvValues: [HKQuantity] = [HKQuantity]()
    
    let read = Set([
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
    ])
    
    init() {
        Task {
            if HKHealthStore.isHealthDataAvailable() {
                healthStore = HKHealthStore()
                do {
                    try await healthStore!.requestAuthorization(toShare: [], read: read)
                    getSleepData()
                    try getHRVData()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    func getSleepData() {
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    
                    // something happened
                    return
                    
                }
                
                if let result = tmpResult {
                    
                    // do something with my data
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                        }
                    }
                }
            }
            
            // finally, we execute our query
            healthStore!.execute(query)
        }
    }
    
    func getHRVData() throws {
        // now repeat with hrv data
        guard let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            return
        }
        // Use a sortDescriptor to get the recent data first
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // we create our query with a block completion to execute
        let query = HKSampleQuery(sampleType: hrv, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
            
            if error != nil {
                // something happened
                return
            }
            
            if let result = tmpResult {
                // do something with my data
                for item in result {
                    if let sample = item as? HKQuantitySample {
                        print(sample.endDate)
                        DispatchQueue.main.async { [weak self] in
                            self?.hrvValues.append(sample.quantity)
                        }
                    }
                }
            }
        }
        
        // finally, we execute our query
        healthStore!.execute(query)
    }
}
