# PennDining

#### Karthik Sai Padmanabhan - Penn Labs Technical Challenge! 
This app is a replica of the Penn Mobile Dining tab, as seen [here](https://www.figma.com/file/bFEGKMbQhgBQGYZJ0cJQHH/Penn-Mobile---iOS-Challenge?node-id=0%3A1)

---

The main features of the app are:
- Display all venues, sorted by residential dining hall or retail dining
- Display venue name, hours, and current status (open or closed)
- Display image of the venue, shown to the left of the above information
- Allow the user to click on each venue, leading to a new WebView which displays the menu for the venue 

## Project Design
1. I began by designing the UI from the Figma. This included high-level code organization, including using a List inside of a Navigation view to cleanly display the dining cells. I used a diningCell struct for efficiency so that a new diningCell could be created for each DiningHall.
2. Once the UI was complete, I moved on to parse the JSON from the [API](http://api.pennlabs.org/dining/venues). This included creating a diningData object, which holds all of the relevant fields of data needed for functionaliy (name, hours, date, imageURL, facilityURL, meal). I then sorted this data into an array of DiningHall objects, so that the data could be accessed and used easily.
3. I then worked on displaying the correct image for each corresponding dining hall, for which I used an [AsyncImage()](https://developer.apple.com/documentation/swiftui/asyncimage)
4. Then, I worked to format the time strings to display the hours as seen on the Figma.
5. In order to check whether or not each dining hall was open at the current time, I converted the time strings to Date() objects, and the compared them to the current time.
6. Finally, I used a Navigation Link to implement the functionality of having a WebView open when the user clicks on the venue.
7. I played around with the font sizes to make the app as close as possible to the real app.

If I had more time, I would have used the [Kingfisher](https://github.com/onevcat/Kingfisher) library to cache the dining images so that they would have to load from the imageURL every time. 

---
## Classes
- _DiningHall_: This Identifiable object stores all relevant information for any venue. This includes its name, hours, open status, imageURL, facilityURL, retail or residential, and a unique ID
- _diningData_: This class contains several structs which adhere to the Decodable protocol. Each struct is a new layer of the JSON, so that it is easy to parse the data and place the raw data into an object. Each struct has codingKeys, which are helpful if the variable name is different from the field in the JSON.
- _WebView_: This class is used for the WebView that web view page that appears when a user clicks on a venue. It is a UIViewRepresentable and makes it simple to return a web view given a URL. This class is called from the NavigationLink in the main ContentView class.
- _ContentView_: This class contains the main organization and code for the logic of the app. It has structs for diningCell, diningWebView, and functions for getting the data, sorting the data into an array, and ultimately displaying everything seen by the user.

