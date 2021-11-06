//
//  ViewController.swift
//  Pat-ckageSample
//
//  Created by John Patrick Teruel on 11/3/21.
//

import UIKit
import patckage
import patbase
import Fakery

protocol ViewDisplayLogic: UIViewController, ShowsAlert, HUDAsyncScreen {
    
}

class ViewController: UIViewController, ViewDisplayLogic, ShowsAlert {
    var viewModel: ViewViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel = ViewViewModel()
        viewModel.displayLogic = self
    }

    // MARK: Create
    @IBAction func didTapCreateButton() {
        self.viewModel.create()
    }
    
    // MARK: Read
    @IBAction func didTapGetButton() {
        self.viewModel.get()
    }
    
    // MARK: Update
    @IBAction func didTapUpdateButton() {
        self.viewModel.update()
    }
    
    // MARK: Delete
}

class ViewViewModel: NSObject, ViewModel {
    var displayLogic: ViewDisplayLogic!
    
    var data: [DocumentObject<SampleData>] = []
    
    lazy var faker = Faker()
    lazy var service = UserService()
    
    func create() {
        self.performCoroutine {
            let result = try self.service.createUser().await()
            let message = """
            UserID: \(result.data.userID)
            Name: \(result.data.name)
            Age: \(result.data.age)
            """
            self.displayLogic.showMessageAlert(with: "Created", message: message)
        }
    }
    
    func get() {
        self.performCoroutine {
            let result = try self.service.getCurrentUser().await()
            let message = """
            UserID: \(result.data.userID)
            Name: \(result.data.name)
            Age: \(result.data.age)
            """
            self.displayLogic.showMessageAlert(with: "User", message: message)
        }
    }
    
    func update() {
        self.performCoroutine {
            let name = self.faker.name.name()
            let age = self.faker.number.randomInt(min: 20, max: 50)
            _ = try self.service
                .updateUser(name: name, age: age)
                .await()
            self.displayLogic.showMessageAlert(with: "Success", message: "Updated to \(name); \(age)")
        }
    }
}

protocol ViewModel: NSObject {
    var displayLogic: ViewDisplayLogic! { get set }
}

extension ViewModel {
    func performCoroutine(_ task: @escaping () throws -> Void) {
        DispatchQueue.main.startCoroutine {
            self.displayLogic.startAsyncActivity()
            do {
                try task()
            }catch {
                self.displayLogic.showErrorAlert(error: error)
            }
            self.displayLogic.stopAsyncActivity()
        }
    }
}

struct SampleData: ObjectCodable {
    var name: String
    var age: Int
}

enum SampleCollection: String, CollectionType {
    case person
}
