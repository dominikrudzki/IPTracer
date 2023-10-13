//
//  ViewController.swift
//  IPTracer
//
//  Created by Dominik Rudzki on 06/10/2023.
//

import Cocoa

class ViewController: NSViewController {
    // MARK: - Properties
    
    private let apiService = ApiService.initialize
    private var ipInfo: IPInfo?
    private var lastFetch: Date?
    private var timer: Timer?
    
    // MARK: - UI Elements
    
    private lazy var button: NSButton = {
        let button = NSButton(title: "Fetch IP Info", target: self, action: #selector(fetchButtonClicked(_:)))
        button.frame = NSRect(x: 0, y: 0, width: 200, height: 30)
        return button
    }()
    
    private lazy var ipInfoLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Public IP: ...\nIP Location: ...\nUpdate: ...")
        label.frame = NSRect(x: 10, y: 25, width: 200, height: 60)
        label.alignment = .left
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var progressIndicator: NSProgressIndicator = {
        let indicator = NSProgressIndicator(frame: NSRect(x: 175, y: 75, width: 15, height: 15))
        indicator.style = .spinning
        indicator.isIndeterminate = true
        indicator.isHidden = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startTimer()
    }
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        self.view.addSubview(button)
        self.view.addSubview(ipInfoLabel)
        self.view.addSubview(progressIndicator)
    }
    
    // MARK: - Data Fetching
    
    private func fetchData(completion: @escaping (Result<IPInfo, Error>) -> Void) {
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        
        apiService.getPublicIPAddress() { [weak self] publicIP in
            guard let self = self else { return }
            
            switch publicIP {
            case .success(let ipInfo):
                self.apiService.fetchIPInfo(using: ipInfo) { result in
                    self.handleFetchResult(result, completion: completion)
                }
            case .failure(let error):
                self.handleFetchError(error, completion: completion)
            }
        }
    }
    
    private func handleFetchResult(_ result: Result<IPInfo, Error>, completion: @escaping (Result<IPInfo, Error>) -> Void) {
        DispatchQueue.main.async {
            self.progressIndicator.isHidden = true
            self.progressIndicator.stopAnimation(nil)
            
            switch result {
            case .success(let ipInfo):
                self.lastFetch = Date()
                completion(.success(ipInfo))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func handleFetchError(_ error: Error, completion: @escaping (Result<IPInfo, Error>) -> Void) {
        DispatchQueue.main.async {
            self.progressIndicator.isHidden = true
            self.progressIndicator.stopAnimation(nil)
            completion(.failure(error))
        }
    }
    
    // MARK: - Button Action
    
    @objc private func fetchButtonClicked(_ sender: NSButton) {
        button.isEnabled = false
        
        fetchData { [weak self] result in
            DispatchQueue.main.async {
                self?.button.isEnabled = true
                self?.handleFetchResult(result) { [weak self] result in
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
    }
    
    // MARK: - UI Updates
    
    private func updateTimeLabelText(with timeString: String, isSuccessful: Bool) {
        ipInfoLabel.stringValue = """
                Public IP: \(ipInfo?.ip ?? "...")
                IP Location: \(ipInfo?.countryName.prefix(14) ?? "...")
                Update: \(timeString) ago
                """
        ipInfoLabel.textColor = isSuccessful ? .green : .red
    }
    
    private func updateUIWithIPInfo(_ ipInfo: IPInfo) {
        guard let lastFetch = lastFetch else { return }
        
        let timeElapsed = Date().timeIntervalSince(lastFetch)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.maximumUnitCount = 1
        
        guard let timeString = formatter.string(from: timeElapsed) else {
            return
        }
        
        updateTimeLabelText(with: timeString, isSuccessful: true)
    }
    
    private func updateUIWithErrorMessage(_ errorMessage: String) {
        ipInfoLabel.stringValue = errorMessage
        ipInfoLabel.textColor = .red
    }
    
    // MARK: - Timer Action
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateFetchTime), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Timer Action
    
    @objc private func updateFetchTime() {
        guard let lastFetch = lastFetch else { return }
        
        let timeElapsed = Date().timeIntervalSince(lastFetch)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.maximumUnitCount = 1
        
        guard let timeString = formatter.string(from: timeElapsed) else {
            return
        }
        
        updateTimeLabelText(with: timeString, isSuccessful: true)
    }
}
