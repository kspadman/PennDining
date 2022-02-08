//
//  ContentView.swift
//  PennDining
//
//  Created by Karthik Padmanabhan on 2/4/22.
//

import SwiftUI
struct ContentView: View {
    
    // this String is the current date formatted to the dates parsed from the API, used to retrieve correct hours
    var dateCheck: String {
        let x = DateFormatter()
        x.dateFormat = "yyyy-MM-dd"
        return x.string(from: Date())
    }
    
    // this is a list of all dining halls, which is populated with DiningHall's when data is retrieved
    @State var diningList = [DiningHall(name: "test", hours: ["hours"], open: "closed", imageURL: "https://president.upenn.edu/themes/custom/penn_global/assets/img/penn-graphic.jpg", facilityURL: "https://president.upenn.edu/themes/custom/penn_global/assets/img/penn-graphic.jpg", retail: false)]
    
    // data object used to hold all of the data parsed from the json, in the form of DocumentData type
    @State var data = DocumentData(document: VenueData(venue: [DiningHallData(name: "test hall", dailyMenuURL: "test url", imageURL: "test image", dateHours: [DateHoursData(date: "test date", meal: [MealTimesData(close: "test close", open: "test open")])], facilityURL: "https://s3.us-east-2.amazonaws.com/labs.api/dining/starbucks.jpg", venueType: "retail")]))
    
    // this funciton parses the JSON, and retrieves all data
    func getData() {
        
        let urlString = "https://api.pennlabs.org/dining/venues"
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!) { data, _, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let decodedData = try decoder.decode(DocumentData.self, from: data)
                        self.data = decodedData
                        createDiningList()
                    } catch {
                        print("Error: something went wrong! \(error)")
                    }
                    
                }
            }
        }.resume()
    }
    
    // creates the list of DiningHall from the retrieved data
    func createDiningList() -> Void {
        
        var diningL: [DiningHall] = []
        let venues = data.document.venue
        var time = [""]
        var closedToday = true;
        
        for i in 0...venues.count-1 {
            var name = venues[i].name
            for j in 0...venues[i].dateHours.count-1{
                let mealTimes = venues[i].dateHours[j].meal
                if (venues[i].dateHours[j].date == dateCheck) {
                    closedToday = false;
                    for k in 0...mealTimes.count-1 {
                        time.append((mealTimes[k].open) + " | " + (mealTimes[k].close))
                    }
                    diningL.append(DiningHall(name: name, hours: time, open: "open", imageURL: venues[i].imageURL ?? "https://president.upenn.edu/themes/custom/penn_global/assets/img/penn-graphic.jpg", facilityURL: venues[i].facilityURL, retail: checkRetail(type: venues[i].venueType)))
                }
                if (closedToday) {
                    
                    diningL.append(DiningHall(name: name, hours: time, open: "CLOSED TODAY", imageURL: venues[i].imageURL ?? "https://president.upenn.edu/themes/custom/penn_global/assets/img/penn-graphic.jpg", facilityURL: venues[i].facilityURL, retail: checkRetail(type: venues[i].venueType)))
                }
                time = [""]
                name = ""
            }
            diningList = diningL
        }
        
        // removes the "fake" DiningHall object that was a placeholder before data was retrieved
        if (!diningList.isEmpty) {
            for index in 0...diningList.count-1 {
                diningList[index].hours.remove(at: 0)
            }
        }
        
        diningList = diningList
    }
    
    // checks if the dining hall is retail or not
    func checkRetail(type: String) -> Bool {
        if (type == "retail") {
            return true
        }
        return false
    }
    
    var body: some View {
        return VStack {
            Text("Dining")
                .font(.system(size: 20, weight: .semibold, design: .default))
            NavigationView {
                List {
                    header()
                    ForEach(diningList) { hall in
                        if (!hall.retail) {
                            NavigationLink(destination: diningWebView(hall: hall)){
                                diningCell(hall: hall)
                            }
                        }
                    }
                    Text("Retail Dining")
                        .bold()
                        .font(.system(size: 24))
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    ForEach(diningList) { hall in
                        if (hall.retail) {
                            NavigationLink(destination: diningWebView(hall: hall)){
                                diningCell(hall: hall)
                            }
                        }
                    }
                }
                .navigationTitle("Dining")
                .navigationBarHidden(true)
                .onAppear(perform: self.createDiningList)
            }
        }.onAppear(perform: self.getData)
    }
}

// struct for clickable view that leads to webpage
struct diningWebView: View {
    let hall: DiningHall
    
    var body: some View {
        var menu = hall.facilityURL
        menu.insert("s", at: menu.firstIndex(of: ":")!) // changes url from http to https
        return WebView(menuURL: URL(string: menu)!)
            .edgesIgnoringSafeArea(.all)
    }
}

// struct for all dining hall cells in main view
struct diningCell: View {
    
    let hall: DiningHall
    
    // sets time from 24-hour to 12-hour time, with am/pm
    func changeTimeFormat(hour: String) -> String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        
        let date = df.date(from: String(hour))
        df.dateFormat = "h:mma"
        
        let time12 = df.string(from: date!)
        return time12
    }
    
    // sets hours to be displayed correctly, removing trailing 0's and am/pm tags when necessary
    func transformTimes() -> String {
        
        var arrayStrings = [""]
        if (hall.open == "CLOSED TODAY") {
            return hall.open
        }
        
        for i in 0...hall.hours.count-1 {
            let splicedHours = hall.hours[i].split(separator: "|")
            let open = splicedHours[0]
            let closed = splicedHours[1]
            
            arrayStrings.append(changeTimeFormat(hour: String(open)) + " - " + changeTimeFormat(hour: String(closed)))
        }
        arrayStrings.remove(at: 0)
        if (hall.name == "Houston Market" && hall.hours.count > 1) {
            arrayStrings.remove(at: 0)
        }
        
        
        for i in 0...arrayStrings.count-1 {
            let badChars: Set<Character> = ["A", "M", "P"]
            arrayStrings[i].removeAll(where: { badChars.contains($0) })
            arrayStrings[i] = arrayStrings[i].replacingOccurrences(of: ":00", with: "")
        }
        
        
        if (arrayStrings.count == 1) {
            if (arrayStrings[0].contains("11:59")) {
                arrayStrings[0] = arrayStrings[0].replacingOccurrences(of: "11:59", with: "12am")
            } else {
                arrayStrings[0] = arrayStrings[0] + "pm"
            }
        }
        
        var singleString = ""
        for time in arrayStrings {
            if (singleString == "") {
                singleString = time
            } else {
                singleString = singleString + " | " + time
            }
        }
        
        return String(singleString)
    }
    
    // checks if the dining hall is open or closed by comparing current time with the operating hours of the dining hall
    func isOpen() -> String {
        
        if (hall.open == "CLOSED TODAY") {
            return "CLOSED"
        }
        
        let calender = Calendar.current
        let now = Date()
        
        for timeSlot in hall.hours {
            
            let splicedHours = timeSlot.split(separator: "|")
            let open = splicedHours[0].replacingOccurrences(of: " ", with: "")
            let closed = splicedHours[1].replacingOccurrences(of: " ", with: "")
            
            let openComponents = open.split(separator: ":")
            let closedComponents = closed.split(separator: ":")
            
            let open_time_today = calender.date(
                bySettingHour: Int(openComponents[0]) ?? 0,
                minute: Int(openComponents[1]) ?? 0,
                second: Int(openComponents[2]) ?? 0,
                of: now)!
            
            let closed_time_today = calender.date(
                bySettingHour: Int(closedComponents[0]) ?? 0,
                minute: Int(closedComponents[1]) ?? 0,
                second: Int(closedComponents[2]) ?? 0,
                of: now)!
            
            if (now >= open_time_today && now <= closed_time_today) {
                return "Open"
            }
        }
        
        return "Closed"
    }
    
    var body: some View {
        
        HStack {
            AsyncImage(url: URL(string: hall.imageURL)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 120, height: 80)
            VStack(alignment: .leading, spacing: 2) {
                if (isOpen() == "Open") {
                    Text(isOpen())
                        .foregroundColor(.yellow)
                        .font(.system(size: 12, weight: .semibold, design: .default))
                } else {
                    Text(isOpen())
                        .font(.system(size: 12, weight: .light, design: .default))
                        .foregroundColor(.gray)
                }
                
                Text(hall.name)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .font(.body)
                Text(transformTimes())
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
    }
}

// header for formatted date and "Dining Halls" label
struct header: View {
    
    var dateLabel: String {
        let s = DateFormatter()
        s.dateFormat = "MMMM d, y"
        return s.string(from: Date())
    }
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(dateLabel.uppercased())
                .font(.caption)
                .foregroundColor(Color.gray)
                .bold()
            Text("Dining Halls")
                .bold()
                .font(.system(size: 24))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portrait)
    }
}
