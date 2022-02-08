//
//  DiningHall.swift
//  PennDining
//
//  Created by Karthik Padmanabhan on 2/6/22.
//

import Foundation
import SwiftUI

// This object contains all information for a dining hall.
// Using an object make it very easy to get relevant information for each dining hall.
struct DiningHall: Identifiable {
    
    let name: String
    var hours: [String]
    let open: String
    let imageURL: String
    let facilityURL: String
    let retail: Bool
    let id = UUID()
    
}
