//
//  DreamsViewDelegate
//  Dreams
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Dreams AB.
//

import Foundation

/**
 The delegate for the `DreamsView`.
 */

public protocol DreamsViewDelegate: class {

    /**
     Delegate callback when the idToken has expired.
     - parameter view: The dreams view invoking the delegate method.
     */
    func dreamsViewDelegateDidReceiveIdTokenExpired(view: DreamsView)

    /**
     Delegate callback when a telemetry event is received.
     - parameter view: The dreams view invoking the delegate method.
     - parameter name: The name of the received telemetry event.
     - parameter payload: The payload containing telemetry event data.
     */
    func dreamsViewDelegateDidReceiveTelemetryEvent(view: DreamsView, name: String, payload: [String: Any])
}
