//
//  DreamsEvent
//  Dreams
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Dreams AB.
//

import Foundation

enum DreamsEvent {
    enum Request: String {
        case updateAccessToken
        case updateLocale
    }

    enum Response: String, CaseIterable {
        case onAccessTokenDidExpired
        case onOnboardingDidComplete
    }
}
