//
//  IPTracerWidget.swift
//  IPTracerWidget
//
//  Created by Dominik Rudzki on 06/10/2023.
//

import WidgetKit
import SwiftUI
import Foundation

struct IPInfo: Codable {
    let ip: String
    let ipNumber: String
    let ipVersion: Int
    let countryName: String
    let countryCode2: String
    let isp: String
    let responseCode: String
    let responseMessage: String
}

struct IPTracerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> IPTracerWidgetEntry {
        IPTracerWidgetEntry(date: Date(), ipInfo: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (IPTracerWidgetEntry) -> ()) {
        let entry = IPTracerWidgetEntry(date: Date(), ipInfo: nil)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [IPTracerWidgetEntry] = []
        
        let publicIP = getPublicIPAddress()
        
        fetchIPInfo(using: publicIP) { result in
            switch result {
            case .success(let ipInfo):
                let entry = IPTracerWidgetEntry(date: Date(), ipInfo: ipInfo)
                entries.append(entry)
            case .failure(let error):
                print("Error fetching IP info: \(error.localizedDescription)")
                
                let entry = IPTracerWidgetEntry(date: Date(), ipInfo: nil)
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct IPTracerWidgetEntry: TimelineEntry {
    let date: Date
    let ipInfo: IPInfo?
}

struct IPTracerWidgetEntryView : View {
    var entry: IPTracerWidgetProvider.Entry
    
    var body: some View {
        VStack {
            if let ipInfo = entry.ipInfo {
                Text("Public IP:")
                Text(ipInfo.ip).font(.title3).foregroundColor(.green)
                Text("IP Location:")
                Text(ipInfo.countryName).font(.title).foregroundColor(.green)
            } else {
                Text("Error fetching IP info").font(.title).foregroundColor(.red)
            }
        }
    }
}

struct IPTracerWidget: Widget {
    let kind: String = "IPTracerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IPTracerWidgetProvider()) { entry in
            if #available(macOS 14.0, *) {
                IPTracerWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                IPTracerWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("IP Tracer Widget")
        .description("Quickly discover your current IP address location.")
    }
}

// Synchronously fetch the public IP address
func getPublicIPAddress() -> String {
    let url = URL(string: "https://ipinfo.io/ip")!
    
    if let data = try? Data(contentsOf: url),
       let ipAddress = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
        return ipAddress
    } else {
        return "ERROR"
    }
}

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
