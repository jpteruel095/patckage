//
//  File.swift
//  
//
//  Created by John Patrick Teruel on 11/3/21.
//

import Foundation
import UIKit


extension UIAlertAction {
    public static func cancelAction(
        with title: String = "Cancel",
        style: UIAlertAction.Style = .cancel,
        handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
            return UIAlertAction(title: title,
                                 style: style,
                                 handler: handler)
        }
    
    public static func okAction(
        title: String = "OK",
        style: UIAlertAction.Style = .cancel,
        handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
            return cancelAction(with: "OK",
                                style: style,
                                handler: handler)
        }
}
