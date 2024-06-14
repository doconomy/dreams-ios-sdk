//
//  DreamsViewController
//  Dreams
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Dreams AB.
//

import UIKit
import WebKit

public protocol DreamsLaunching: AnyObject {
    /**
     This method MUST be called just after the DreamsViewController is presented, the Dreams interface will be launched for given credentials.

     - parameter with: credentials - DreamsCredentials
     - parameter locale: Selected Locale
     - parameter headers: Set optional HTTP headers
     - parameter completion: Called when Dreams did launch successfuly or failed

     - Attention: This method MUST be called on main thread, when called from background threads it will crash to avoid undefined behaviour.

     */
    func launch(with credentials: DreamsCredentials, locale: Locale, headers: [String: String]?, completion: ((Result<Void, DreamsLaunchingError>) -> Void)?)

    /**
     This method MUST be called just after the DreamsViewController is presented, the Dreams interface will be launched for given credentials.

     - parameter with: credentials - DreamsCredentials
     - parameter locale: Selected Locale
     - parameter headers: Set optional HTTP headers
     - parameter completion: Called when Dreams did launch successfuly or failed
     - parameter location: the host app can ask DreamsSDK to start Dreams with certain location

     - Attention: This method MUST be called on main thread, when called from background threads it will crash to avoid undefined behaviour.

     */
    func launch(with credentials: DreamsCredentials, locale: Locale, headers: [String: String]?, location: String, completion: ((Result<Void, DreamsLaunchingError>) -> Void)?)
}

public extension DreamsLaunching {
    /**
     This method MUST be called just after the DreamsViewController is presented, the Dreams interface will be launched for given credentials.

     - parameter idToken: User idToken
     - parameter locale: Selected Locale
     
     - Attention: This method MUST be called on main thread, when called from background threads it will crash to avoid undefined behaviour.
     */
    func launch(with credentials: DreamsCredentials, locale: Locale) {
        launch(with: credentials, locale: locale, headers: nil, completion: nil)
    }

    /**
     This method MUST be called just after the DreamsViewController is presented, the Dreams interface will be launched for given credentials.

     - parameter with: credentials - DreamsCredentials
     - parameter locale: Selected Locale
     - parameter location: the host app can ask DreamsSDK to start Dreams with certain location

     - Attention: This method MUST be called on main thread, when called from background threads it will crash to avoid undefined behaviour.

     */
    func launch(with credentials: DreamsCredentials, locale: Locale, location: String) {
        launch(with: credentials, locale: locale, headers: nil, location: location, completion: nil)
    }
    
    /**
     This method MUST be called just after the DreamsViewController is presented, the Dreams interface will be launched for given credentials.

     - parameter with: credentials - DreamsCredentials
     - parameter locale: Selected Locale
     - parameter headers: Set optional HTTP headers

     - Attention: This method MUST be called on main thread, when called from background threads it will crash to avoid undefined behaviour.

     */
    func launch(with credentials: DreamsCredentials, locale: Locale, headers: [String: String]? = nil) {
        launch(with: credentials, locale: locale, headers: headers, completion: nil)
    }
    
    /**
     This method MUST be called just after the DreamsViewController is presented, the Dreams interface will be launched for given credentials.

     - parameter with: credentials - DreamsCredentials
     - parameter locale: Selected Locale
     - parameter headers: Set optional HTTP headers
     - parameter location: the host app can ask DreamsSDK to start Dreams with certain location

     - Attention: This method MUST be called on main thread, when called from background threads it will crash to avoid undefined behaviour.

     */
    func launch(with credentials: DreamsCredentials, locale: Locale, headers: [String: String]? = nil, location: String) {
        launch(with: credentials, locale: locale, headers: headers, location: location, completion: nil)
    }
}

public protocol NavigatingToLocation: AnyObject {
    /**
     This method can be only called when Dreams is already presented, calls before `launch` method completion will be ignored.

     - parameter location: - String describing location inside Dreams
     */
    func navigateTo(location: String)
}

public protocol LocaleUpdating: AnyObject {
    /**
     This method can be called at all times after the DreamsViewController is presented, the Dreams interface will update to selected Locale.
     - parameter locale: Selected Locale
     */
    func update(locale: Locale)
}

public protocol HeaderUpdating: AnyObject {
    /**
     This method can be called at all times after the DreamsViewController is presented, the Dreams interface will send the headers with every request.
     - parameter headers: Set optional HTTP headers
     */
    func update(headers: [String: String]?)
}

public protocol DreamsDelegateUsing: AnyObject {
    /**
     This method MUST be called before the ViewController is presented, otherwise delegate won't be able to mediate.
     - parameter delegate : DreamsDelegate handling events
     */
    func use(delegate: DreamsDelegate)
}

public protocol ViewControllerPresenting: AnyObject {
    /**
     This method is used internally.
     */
    func present(viewController: UIViewController)
}

public class DreamsViewController: UIViewController {

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private let interaction: DreamsNetworkInteracting
    
    public init(interaction: DreamsNetworkInteracting) {
        self.interaction = interaction
        super.init(nibName: nil, bundle: nil)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        guard let configuration = Dreams.shared.configuration else {
            fatalError("Call Dreams.configure() in your AppDelegate")
        }
        self.interaction = DreamsNetworkInteractionBuilder.build(configuration: configuration)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder: NSCoder) {
        guard let configuration = Dreams.shared.configuration else {
            fatalError("Call Dreams.configure() in your AppDelegate")
        }
        self.interaction = DreamsNetworkInteractionBuilder.build(configuration: configuration)
        super.init(coder: coder)
    }

    public override func loadView() {
        view = webView
        interaction.use(webView: webView)
    }
    
    public override func viewDidLoad() {
        interaction.didLoad()
        interaction.use(navigation: self)
    }
    
}

// MARK: DreamsLaunching
extension DreamsViewController: DreamsLaunching {
    /**
     This method MUST be called just after the DreamsViewController is presented, the Dreams interface will be launched for given credentials.
     
     - parameter idToken: User idToken
     - parameter locale: Selected Locale
     - parameter headers: Set optional HTTP headers
     - parameter completion: Called when Dreams did launch successfuly or failed
    
     - Attention: This method MUST be called on main thread, when called from background threads it will crash to avoid undefined behaviour.
        
     */
    public func launch(with credentials: DreamsCredentials, locale: Locale, headers: [String: String]? = nil, completion: ((Result<Void, DreamsLaunchingError>) -> Void)?) {
        guard Thread.isMainThread else {
            fatalError("Launch can be only called on main thread!")
        }
        interaction.launch(credentials: credentials, locale: locale, headers: headers, location: nil, completion: completion)
    }

    /**
     This method MUST be called just after the DreamsViewController is presented, the Dreams interface will be launched for given credentials.

     - parameter location: the host app can ask DreamsSDK to start Dreams with certain location
     - parameter with: credentials - DreamsCredentials
     - parameter locale: Selected Locale
     - parameter headers: Set optional HTTP headers
     - parameter completion: Called when Dreams did launch successfuly or failed

     - Attention: This method MUST be called on main thread, when called from background threads it will crash to avoid undefined behaviour.

     */
    public func launch(with credentials: DreamsCredentials, locale: Locale, headers: [String: String]? = nil, location: String, completion: ((Result<Void, DreamsLaunchingError>) -> Void)?) {
        interaction.launch(credentials: credentials, locale: locale, headers: headers, location: location, completion: completion)
    }
}

// MARK: NavigatingToLocation
extension DreamsViewController: NavigatingToLocation {

    /**
     This method can be only called when Dreams is already presented, calls before `launch` method completion will be ignored and the function
     will return false.

     - parameter location: - String describing location inside Dreams

     */
    public func navigateTo(location: String) {
        interaction.navigateTo(location: location)
    }
}

// MARK: HeaderUpdating
extension DreamsViewController: HeaderUpdating {
    
    /**
     This method can be called at all times after the DreamsViewController is presented, the Dreams interface will send the headers with every request.
     - parameter headers: Set optional HTTP headers
     */
    
    public func update(headers: [String : String]?) {
        interaction.update(headers: headers)
    }
}

// MARK: DreamsDelegateUsing
extension DreamsViewController: DreamsDelegateUsing {

    /**
     This method MUST be called before the ViewController is presented, otherwise delegate won't be able to mediate.
     - parameter delegate : DreamsDelegate handling events
     */
    public func use(delegate: DreamsDelegate) {
        interaction.use(delegate: delegate)
    }
}

// MARK: LocaleUpdating
extension DreamsViewController: LocaleUpdating {

    /**
     This method can be called at all times after the DreamsViewController is presented, the Dreams interface will update to selected Locale.
     - parameter locale: Selected Locale
     */
    public func update(locale: Locale) {
        interaction.update(locale: locale)
    }
}

// MARK: ViewControllerPresenting (used internally)
extension DreamsViewController: ViewControllerPresenting {
    public func present(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}
