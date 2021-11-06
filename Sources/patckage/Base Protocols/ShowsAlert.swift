//
//  File.swift
//  
//
//  Created by John Patrick Teruel on 11/3/21.
//

import UIKit

public protocol ShowsAlert {
    func showMessageAlert(
        with title: String,
        message: String,
        actions: [UIAlertAction],
        handler: (() -> Void)?)
    func showErrorAlert(
        with message: String,
        title: String,
        actions: [UIAlertAction],
        handler: (() -> Void)?)
    func showErrorAlert(
        error: Error,
        title: String,
        actions: [UIAlertAction],
        handler: (() -> Void)?)
    func showActionSheet(
        with actions: [UIAlertAction],
        title: String?,
        cancelAction: UIAlertAction,
        handler: (() -> Void)?)
}

extension ShowsAlert where Self: UIViewController {
    public func showMessageAlert(
        with title: String,
        message: String,
        actions: [UIAlertAction] = [.okAction()],
        handler: (() -> Void)? = nil) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            actions.forEach({alertController.addAction($0)})
            self.present(alertController, animated: true, completion: handler)
        }
    
    public func showErrorAlert(
        with message: String,
        title: String = "Error",
        actions: [UIAlertAction] = [.okAction()],
        handler: (() -> Void)? = nil) {
            self.showMessageAlert(with: title,
                                  message: message,
                                  actions: actions,
                                  handler: handler)
        }
    
    public func showErrorAlert(
        error: Error,
        title: String = "Error",
        actions: [UIAlertAction] = [.okAction()],
        handler: (() -> Void)? = nil) {
            self.showErrorAlert(with: error.localizedDescription,
                                title: title,
                                actions: actions,
                                handler: handler)
        }
    
    public func showActionSheet(
        with actions: [UIAlertAction],
        title: String? = nil,
        cancelAction: UIAlertAction = .cancelAction(),
        handler: (() -> Void)? = nil) {
            let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            actions.forEach({actionSheet.addAction($0)})
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true, completion: handler)
        }
}
