//
//  File.swift
//  
//
//  Created by John Patrick Teruel on 11/3/21.
//

import Foundation
import MBProgressHUD

public protocol HUDAsyncScreen {
    var hudOverlaidViews: [UIView] { get set }
}

extension HUDAsyncScreen {
    @discardableResult
    public func startAsyncActivity(animated: Bool = true,
                                   configure: ((MBProgressHUD, UIView) -> Void)? = nil) -> [MBProgressHUD] {
        hudOverlaidViews.compactMap {
            let hud = MBProgressHUD.showAdded(to: $0, animated: animated)
            configure?(hud, $0)
            return hud
        }
    }

    public func stopAsyncActivity(animated: Bool = true) {
        hudOverlaidViews.forEach {
            MBProgressHUD.hide(for: $0, animated: animated)
        }
    }
}

public extension HUDAsyncScreen where Self: UIViewController {
    var hudOverlaidViews: [UIView] {
        get {
            return [self.view]
        }
        set {
            _ = newValue
        }
    }
}
