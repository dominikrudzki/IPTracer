//
//  ApiService.swift
//  IPTracer
//
//  Created by Dominik Rudzki on 06/10/2023.
//

import Foundation

class ApiService {
    
    static let initialize = ApiService()
    
    func fetchIPInfo(using ipAddress: String, completion: @escaping (Result<IPInfo, Error>) -> Void) {
        let urlString = "https://api.iplocation.net/?ip=\(ipAddress)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "AppErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "AppErrorDomain", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw API Response:\n\(rawResponse)")
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let ipInfo = try decoder.decode(IPInfo.self, from: data)
                completion(.success(ipInfo))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
    func getPublicIPAddress(completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://ipinfo.io/ip")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let ipAddress = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                let error = NSError(domain: "NetworkError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])
                completion(.failure(error))
                return
            }

            completion(.success(ipAddress))
        }

        task.resume()
    }

}
