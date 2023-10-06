//
//  ViewController.swift
//  IPTracer
//
//  Created by Dominik Rudzki on 06/10/2023.
//

import Cocoa

class ViewController: NSViewController {
    
    let apiService = ApiService.initialize
    
    var textField: NSTextField!
    var ipInfoLabel: NSTextField!
    var lastFetch: Date!
    var button: NSButton!
    
    var ipInfo: IPInfo?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
    }
    
    override var representedObject: Any? {
        didSet {}
    }
    
    func setupUI() {
        button = NSButton(title: "Fetch IP Info", target: self, action: #selector(buttonClicked(_:)))
        button.frame = NSRect(x: 0, y: 0, width: 200, height: 30)
        
        ipInfoLabel = NSTextField(labelWithString: "Public IP: ...\nIP Location: ...\nLast Fetch: ...")
        ipInfoLabel.frame = NSRect(x: 10, y: 25, width: 200, height: 60)
        ipInfoLabel.alignment = .left
        ipInfoLabel.lineBreakMode = .byWordWrapping
        
        self.view.addSubview(button)
        self.view.addSubview(ipInfoLabel)
    }
    
    func fetchData(completion: @escaping (Result<IPInfo, Error>) -> Void) {
        apiService.getPublicIPAddress() { publicIP in
            switch publicIP {
            case .success(let ipInfo):
                self.apiService.fetchIPInfo(using: ipInfo) { result in
                    switch result {
                    case .success(let ipInfo):
                        self.lastFetch = Date()
                        completion(.success(ipInfo))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @objc func buttonClicked(_ sender: NSButton) {
        fetchData { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ipInfo):
                    self?.ipInfo = ipInfo
                    self?.updateUIWithIPInfo(ipInfo)
                case .failure(_):
                    self?.ipInfo = nil
                    self?.updateUIWithErrorMessage("Error fetching IP info")
                }
            }
        }
    }

    func updateUIWithIPInfo(_ ipInfo: IPInfo) {
        ipInfoLabel.stringValue = """
            Public IP: \(ipInfo.ip)
            IP Location: \(ipInfo.countryName.prefix(14))
            Last Fetch: \(Utils.formatDate(date: lastFetch))
            """
        ipInfoLabel.textColor = .green
    }

    func updateUIWithErrorMessage(_ errorMessage: String) {
        ipInfoLabel.stringValue = errorMessage
        ipInfoLabel.textColor = .red
    }
    
}
