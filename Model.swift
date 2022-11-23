//
//  Model.swift
//  SwiftUIMultiplatform
//
//  Created by IPS-161 on 17/11/22.
//

import Foundation
struct Welcome: Codable,Identifiable {
    let id = UUID()
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Codable, Identifiable {
    let id = UUID()
    let magazineID: Int
    let magazineName, magazineDescription: String
    let magazineThumbnail: String
    let magazineURL: String

    enum CodingKeys: String, CodingKey {
        case magazineID = "magazine_id"
        case magazineName = "magazine_name"
        case magazineDescription = "magazine_description"
        case magazineThumbnail = "magazine_thumbnail"
        case magazineURL = "magazine_url"
    }
}
class Api : ObservableObject{
    @Published var books = Welcome.init(data: [Datum]())
    
    func loadData(completion:@escaping (Welcome) -> ()) {
        guard let url = URL(string: "https://magazine.herokuapp.com/magazine")
        else {
            print("Invalid url...")
            return
        }
   
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
        
            let jsondata = try! JSONSerialization.jsonObject(with: data ?? Data(), options: JSONSerialization.ReadingOptions.fragmentsAllowed)
            print(jsondata)
            let books = try! JSONDecoder().decode(Welcome.self, from: data!)
            DispatchQueue.main.async {
                completion(books)
            }
        }.resume()
        
    }
}
