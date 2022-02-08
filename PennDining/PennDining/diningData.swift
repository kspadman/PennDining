//
//  diningData.swift
//  PennDining
//
//  Created by Karthik Padmanabhan on 2/4/22.
//

import Foundation

// This class is used to place all of the data parsed from the JSON into a succint object
// Each struct here represents a different layer of the JSON. Ex: document, venue, etc.
struct DocumentData: Decodable {
    
    var document: VenueData
    
    enum CodingKeys: String, CodingKey {
        case document = "document"
    }
}

struct VenueData: Decodable {
    
    var venue: [DiningHallData]
    
    enum CodingKeys: String, CodingKey {
        case venue = "venue"
    }
    
}

struct DiningHallData: Decodable {
    
    var name: String
    var dailyMenuURL: String
    var imageURL: String?
    var dateHours: [DateHoursData]
    var facilityURL: String
    var venueType: String
    
    enum CodingKeys: String, CodingKey {
        case dailyMenuURL = "dailyMenuURL"
        case name = "name"
        case imageURL = "imageURL"
        case dateHours = "dateHours"
        case facilityURL = "facilityURL"
        case venueType = "venueType"
    }
}

struct DateHoursData: Decodable {
    var date: String
    var meal: [MealTimesData]
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case meal = "meal"
    }
}

struct MealTimesData: Decodable {
    
    var close: String
    var open: String

    enum CodingKeys: String, CodingKey {
        case close = "close"
        case open = "open"
    }
}
