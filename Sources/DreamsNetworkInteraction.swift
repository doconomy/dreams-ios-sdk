//
//  DreamsNetworkInteraction
//  Dreams
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2021 Dreams AB.
//

import Foundation

// MARK: DreamsNetworkInteracting

public protocol DreamsNetworkInteracting {
    func didLoad()
    func use(webView: WebViewProtocol)
    func use(delegate: DreamsDelegate)
    func launch(with credentials: DreamsCredentials, locale: Locale)
    func update(locale: Locale)
}

// MARK: DreamsNetworkInteraction

public final class DreamsNetworkInteraction: DreamsNetworkInteracting {

    private let webService: WebServiceType
    private let configuration: DreamsConfiguration
    
    private weak var webView: WebViewProtocol!
    private weak var delegate: DreamsDelegate?
    
    init(configuration: DreamsConfiguration, webService: WebServiceType) {
        self.configuration = configuration
        self.webService = webService
    }
    
    // MARK: Public
    
    public func didLoad() {
        webService.delegate = self
    }
    
    public func use(webView: WebViewProtocol) {
        self.webView = webView
        setUpUserContentController()
    }
    
    public func use(delegate: DreamsDelegate) {
        self.delegate = delegate
    }
    
    public func launch(with credentials: DreamsCredentials, locale: Locale) {
        loadBaseURL(credentials: credentials, locale: locale)
    }
    
    public func update(locale: Locale) {
        let jsonObject: JSONObject = ["locale": locale.identifier]
        send(event: .updateLocale, with: jsonObject)
    }
    
    // MARK: Private

    private func handle(event: ResponseEvent, with jsonObject: JSONObject?) {
        switch event {
        case .onIdTokenDidExpire:
            guard let requestId = jsonObject?["requestId"] as? String else { return }
            delegate?.handleDreamsCredentialsExpired { [weak self] credentials in
                self?.update(idToken: credentials.idToken, requestId: requestId)
            }
        case .onTelemetryEvent:
            guard let name = jsonObject?["name"] as? String,
                  let payload = jsonObject?["payload"] as? JSONObject else { return }
            delegate?.handleDreamsTelemetryEvent(name: name, payload: payload)
        case .onAccountProvisionRequested:
            guard let requestId = jsonObject?["requestId"] as? String else { return }
            delegate?.handleDreamsAccountProvisionInitiated { [weak self] in
                self?.accountProvisionInitiated(requestId: requestId)
            }
        case .onExitRequested:
            delegate?.handleExitRequest()
        }
    }
    
    private func update(idToken: String, requestId: String) {
        let jsonObject: JSONObject = ["idToken": idToken, "requestId":  requestId]
        send(event: .updateIdToken, with: jsonObject)
    }

    private func accountProvisionInitiated(requestId: String) {
        let jsonObject: JSONObject = ["requestId": requestId]
        send(event: .accountProvisionInitiated, with: jsonObject)
    }
    
    private func setUpUserContentController() {
        ResponseEvent.allCases.forEach {
           webView.add(webService, name: $0.rawValue)
        }
    }
    
    private func loadBaseURL(credentials: DreamsCredentials, locale: Locale) {
    
        let body = [
            "idToken": credentials.idToken,
            "locale": locale.identifier,
            "clientId": configuration.clientId
        ]

        webService.load(url: configuration.baseURL, method: "POST", body: body)
    }
}

// MARK: WebServiceDelegate

extension DreamsNetworkInteraction: WebServiceDelegate {
    func webServiceDidPrepareRequest(service: WebServiceType, urlRequest: URLRequest) {
        _ = webView.load(urlRequest)
    }

    func webServiceDidPrepareMessage(service: WebServiceType, jsString: String) {
        webView.evaluateJavaScript(jsString, completionHandler: nil)
    }

    func webServiceDidReceiveMessage(service: WebServiceType, event: ResponseEvent, jsonObject: JSONObject?) {
        handle(event: event, with: jsonObject)
    }
    
    func send(event: Request, with jsonObject: JSONObject?) {
        webService.prepareRequestMessage(event: event, with: jsonObject)
    }
}