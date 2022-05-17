//
//  WeatherAppView.swift
//  weather-app-omo
//
//  Created by Vladislav Gorovenko on 16.05.2022.
//

import SwiftUI

struct APIMain: Decodable {
    var temp: Double
}

struct APICityInfo: Decodable {
    var name: String
    var main: APIMain
    var weather: [APIWeather]
}

struct APIWeather: Decodable {
    let description: String
}

struct WeatherAppView: View {
    @State var name: String = ""
    @State var temperature: Double = 1000
    @State var description: String = ""
    @State var weatherLabel: String = ""
    @State var nameOfTheCity: String = "Azov"
    var body: some View {
        VStack {
            searchBar
            Spacer()
            Text("\(name)")
                .font(.system(size: 30))
                .bold()
                .padding()
            Text(weatherLabel)
                .font(.system(size: 40))
            Text("\(description)")
            Text(treatTemperature(temperature))
                .font(.headline)
            Spacer()
        }
    }
    
    var searchBar: some View {
        VStack {
            HStack {
                TextField("Enter city name", text: $nameOfTheCity)
                    .padding()
                Button {
                    Task {
                        await loadData()
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .padding()
                }

            }
            .overlay(RoundedRectangle(cornerRadius: 10).stroke())
            .padding()
        }
    }
    
    // to make sure that numbers are not displayed till they received
    func treatTemperature(_ number: Double) -> String {
        if number == 1000 {
            return "-- °C"
        }
        return "\(Int(number)) °C"
    }
    
    func treatWeatherDescriptions(description: String) -> String {
        if description.contains("clear") { return "☀️" }
        if description.contains("few") { return "🌤" }
        if description.contains("scattered") { return "☁️" }
        if description.contains("clouds") { return "☁️" }
        if description.contains("overcast") { return "☁️" }
        if description.contains("shower") { return "🌦" }
        if description.contains("rain") { return "🌧" }
        if description.contains("thunderstorm") { return "⛈" }
        if description.contains("snow") { return "❄️"}
        return "❓"
    }
    
    func loadData() async {
        let key = ""
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(nameOfTheCity.lowercased())&appid=\(key)&units=metric") else {
            print("can't make up URL from STRING")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(APICityInfo.self, from: data) {
                name = decodedResponse.name
                temperature = decodedResponse.main.temp
                description = decodedResponse.weather.first!.description
                weatherLabel = treatWeatherDescriptions(description: description)
            }
        } catch {
            print("invalid URL")
        }
    }
}

struct WeatherApp_Previews: PreviewProvider {
    static var previews: some View {
        WeatherAppView()
    }
}
