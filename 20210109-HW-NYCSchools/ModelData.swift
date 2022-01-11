//
//  ModelData.swift
//
//  Created by bayareahank on 1/9/22.
//

// Kind of follow SwiftUI style
// I choose CSV data format cause it is supported by both data source, while JSON isn't.

import Foundation
import SwiftCSV
import os.log

class ModelData {
    
    static let schoolUrl = "https://data.cityofnewyork.us/api/views/s3k6-pzi2/rows.csv?accessType=DOWNLOAD"
    static let satUrl = "https://data.cityofnewyork.us/api/views/f9bf-2cp4/rows.csv?accessType=DOWNLOAD"
    
    var schools = [String:School]()
    private static var sharedInstance: ModelData = {
        let instance = ModelData()
        return instance
    }()

    // Singleton
    class func shared() -> ModelData {
        return .sharedInstance
    }
    
    // Read school data first, build dictionary
    // Then read sat data, update existing school dictionary.
    func fetchData(completion: @escaping (Error?) -> Void) {
        let dispatchGroup = DispatchGroup()
        var satCSV: CSV?
        
        dispatchGroup.enter()
        buildSchoolData() { error in
            
            defer {
                dispatchGroup.leave()
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            // print ("fetchData.buildSchooData finished ...")
        }
        
        dispatchGroup.enter()
        buildSatData { csv, error in
            
            defer {
                dispatchGroup.leave()
            }
            
            guard let csv = csv else {
                os_log("ModelData.fetchData buildSatData failed %@", type: .error, error?.localizedDescription ?? "")
                completion(error)
                
                return
            }
            
            satCSV = csv
            print ("ModelData.buildSatData found \(satCSV!.namedRows.count) rows")
        }
        
        // dispatchGroup.notify(queue: DispatchQueue.global()) {
        dispatchGroup.notify(queue: .main) {
            [weak self] in
            
            // print ("ModelData.fetchData got notify ... ")
            
            guard let sself = self else {
                os_log("ModelData.fetchData notify found nil self", type: .info)
                completion(nil)
                return
            }
            
            sself.updateData(satCSV!)
            completion(nil)
        }
    }
    
    // Build the initial school data, without sat scores.
    func buildSchoolData(completion: @escaping (Error?) -> Void) {
        ModelData.loadCSVOverNet(dataUrl: ModelData.schoolUrl) { [weak self] csv, error in
            guard let csv = csv else {
                completion(error)
                return
            }
            
            guard let sself = self else {
                return
            }
            
            for row in csv.namedRows {
               
                guard let dbn = row["dbn"] else {
                    os_log("ModelData.buildSchoolData found row without dbn %@", type: .error, row)
                    continue
                }
                    
                guard let schoolName = row["school_name"] else {
                    os_log("ModelData.buildSchoolData found row without schoolName %@", type: .error, row)
                    continue
                }
                    
                // So description is allowed to be nil
                let description = row["overview_paragraph"] ?? ""
                    
                let school = School(name: schoolName, description: description)
                    
                sself.schools[dbn] = school
                
                // print ("Appending schools \(school)")
            }
            
            print ("buildSchoolData total schools \(sself.schools.count)")
            completion(nil)
        }
    }
    
    func buildSatData(completion: @escaping (CSV?, Error?) -> Void) {
        ModelData.loadCSVOverNet(dataUrl: ModelData.satUrl, completion: completion)
    }
    
    func updateData(_ csv: CSV) {
        // iterate over sat data, update existing school data with SAT scores.
        
        // print ("Modeldata.updateData rows \(csv.namedRows.count)")
        
        for row in csv.namedRows {
            guard let dbn = row["DBN"] else {
                os_log("ModelData.updateData found row without DBN %@", type: .error, row)
                continue
            }
            
            // We do have SAT data and School data mismatch, we only show schools in the latest 2017 data.
            guard let school = schools[dbn] else {
                os_log("ModelData.updateData found extra school %@", type: .info, row)
                continue
            }
                
            let readingScore = row["SAT Critical Reading Avg. Score"] ?? "s"
            let mathScore = row["SAT Math Avg. Score"] ?? "s"
            let writeScore = row["SAT Writing Avg. Score"] ?? "s"
                
            // We can do this cause school is a struct, not a class.
            var theSchool = school
            theSchool.scores[.math] = TestScore(test: .math, value: mathScore)
            theSchool.scores[.reading] = TestScore(test: .reading, value: readingScore)
            theSchool.scores[.writing] = TestScore(test: .writing, value: writeScore)
                
            schools[dbn] = theSchool
            
            // print ("updateData: appending SAT \(theSchool)")
        }
        
    }
    
    // Utility, to load csv data from url
    class func loadCSVOverNet(dataUrl: String, completion: @escaping (CSV?, Error?)->Void) {
    
        let task = URLSession.shared.dataTask(with: URL(string: dataUrl)!) {
            (data, response, error) -> Void in
            // Check if data was received successfully
            
            guard let data = data else {
                os_log("ModelData.loadCSVOverNet fetch data from %@ failed %@", type: .debug, dataUrl, error?.localizedDescription ?? "")
                completion(nil, error)
                return
            }
            
            guard let content = String(data: data, encoding: .utf8) else {
                os_log("ModelData.loadCSVOverNet data format incorrect", type: .debug)
                completion(nil, nil)
                return
            }
            
            do {
                let csv = try CSV(string: content)
                completion(csv, nil)
                
            } catch {
                print ("ModelData.loadCSVOverNet parsing CSV failed \(error.localizedDescription)")
                completion(nil, error)
            }
            
        }
            
        task.resume()
    }
    
}
