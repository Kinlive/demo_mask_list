//
//  MaskProperty.swift
//  DemoMaskList
//
//  Created by Thinkpower on 2020/5/21.
//  Copyright © 2020 com.kinlive. All rights reserved.
//

import Foundation

struct MaskProperty: Codable {
    let id: String
    let name: String
    let phone: String
    let address: String
    let maskAdult: Int
    let maskChild: Int
    let updated: String
    let available: String
    let note: String
    let customNote: String
    let website: String
    let county: String
    let town: String
    let cunli: String
    let servicePeriods: String
    
    private enum CodingKeys: String, CodingKey {
        case id, name, phone, address, updated, available,
                note, website, county, town, cunli
        case maskAdult = "mask_adult"
        case maskChild = "mask_child"
        case customNote = "custom_note"
        case servicePeriods = "service_periods"
        
        
    }
    
    init(from decoder: Decoder) throws {
        do {
            let container  = try decoder.container(keyedBy: CodingKeys.self)
            
            id             = try container.decode(String.self, forKey: .id)
            name           = try container.decode(String.self, forKey: .name)
            phone          = try container.decode(String.self, forKey: .phone)
            address        = try container.decode(String.self, forKey: .address)
            maskAdult      = try container.decode(Int.self, forKey: .maskAdult)
            maskChild      = try container.decode(Int.self, forKey: .maskChild)
            updated        = try container.decode(String.self, forKey: .updated)
            available      = try container.decode(String.self, forKey: .available)
            note           = try container.decode(String.self, forKey: .note)
            customNote     = try container.decode(String.self, forKey: .customNote)
            website        = try container.decode(String.self, forKey: .website)
            county         = try container.decode(String.self, forKey: .county)
            town           = try container.decode(String.self, forKey: .town)
            cunli          = try container.decode(String.self, forKey: .cunli)
            servicePeriods = try container.decode(String.self, forKey: .servicePeriods)
            
            
        } catch let error {
            throw error
        }
    }
}
