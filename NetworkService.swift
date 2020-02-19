//
//  Network.swift
//  searchImage
//
//  Created by Dmytro on 2/18/20.
//  Copyright © 2020 Dmytro Doroshchuk. All rights reserved.
//

import UIKit

typealias ImagesList = Result<ResponseData?, Error?>
typealias ImageData = Result<UIImage?, Error?>

enum Result<Value, Error> {
    case success(Value)
    case failure(Error)
}

protocol NetworkServiceProtocol: class {
    func getImagesUrlList(searchString: String, completion: @escaping (ImagesList) -> Void)
    func downloadImage(from string: String, completion: @escaping (ImageData) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    func getImagesUrlList(searchString: String, completion: @escaping (ImagesList) -> Void) {
        
        let parameters: [String: String] = [
            "api_key": Constants.Api.apiKey,
            "q": searchString,
            "limit": "20"]
        
        guard var components = URLComponents(string:
            Constants.Api.host + Constants.Api.path) else {
                completion(.failure(nil))
                return }
        
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = components.url else {
            completion(.failure(nil))
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil
                else {
                    completion(.failure(error))
                    return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseData = try decoder.decode(ResponseData.self, from: data)
                completion(.success(responseData))
            } catch let error {
                completion(.failure(error))
            }
            
            }.resume()
    }
    
    func downloadImage(from string: String, completion: @escaping (ImageData) -> Void) {
        
        guard let url = URL(string: string) else {
            completion(.failure(nil))
            return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil,
                let image = UIImage(data: data)
                else {
                    completion(.failure(nil))
                    return
            }
            completion(.success(image))
            }.resume()
    }
    
}
