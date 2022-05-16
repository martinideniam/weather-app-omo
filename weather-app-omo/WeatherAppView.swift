//
//  WeatherAppView.swift
//  weather-app-omo
//
//  Created by Vladislav Gorovenko on 16.05.2022.
//

import SwiftUI


struct APICoord: Decodable {
    var lon: Double
    var lat: Double
}

struct APIMain: Decodable {
    var temp: Double
}

struct APICityInfo: Decodable {
    var name: String
    var coord: APICoord
    var main: APIMain
}

struct WeatherAppView: View {
    @State var name: String = ""
    @State var coordinates: (lat: Double, lon: Double) = (0, 0)
    @State var temperature: Double = -100
    @State var nameOfTheCity: String = "Azov"
    var body: some View {
        VStack {
            searchBar
            Spacer()
            Text("\(name)")
                .font(.system(size: 30))
                .bold()
                .padding()
            Text("\(coordinates.lat) \(coordinates.lon)")
                .font(.footnote)
            Text("\(Int(temperature)) °C")
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
                coordinates = (lat: decodedResponse.coord.lat, lon: decodedResponse.coord.lon)
                temperature = decodedResponse.main.temp
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
