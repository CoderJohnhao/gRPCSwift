//
//  ViewController.swift
//  gRPCDemo
//
//  Created by Johnhao on 2021/9/9.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var reponseLabel: UILabel!
    
    
    
    let server = Server()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func sendBtn(_ sender: Any) {
        guard let name = textField.text else {
            return
        }
        
        var test = Helloworld_HelloRequest()
        test.name = name
        server.request(test) { [weak self] result in
            self?.reponseLabel.text = result
        } failed: { [weak self] error in
            self?.reponseLabel.text = error.localizedDescription
        }
    }
    
    @IBAction func sendBytesBtn(_ sender: Any) {
        guard let name = textField.text else {
            return
        }
        guard let data = name.data(using: .utf8) else { return }
        server.request(data) { [weak self] result in
            self?.reponseLabel.text = result
        } failed: { [weak self] error in
            self?.reponseLabel.text = error.localizedDescription
        }
    }
    
    @IBAction func uploadBtn(_ sender: Any) {
        guard let image = UIImage(named: "1.png") else { return }
        guard let data = image.jpegData(compressionQuality: 1.0) else { return }
        server.upLoad("1.png", data: data, type: "PNG") { [weak self] result in
            self?.reponseLabel.text = result
        } failed: { [weak self] error in
            self?.reponseLabel.text = error.localizedDescription
        }
    }
}

