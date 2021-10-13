//
//  BidirectionalStreaminVC.swift
//  gRPCDemo
//
//  Created by Johnhao on 2021/9/28.
//
import UIKit
import GRPC

class BidirectionalStreaminVC: UIViewController {
    @IBOutlet weak var inputTextFiled: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var dataArr: [Routeguide_RouteNote] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func send(_ sender: Any) {
        guard let text = inputTextFiled.text, text.count > 0 else { return }
        
        var data: [Routeguide_RouteNote] = []
        
        for _ in 0...10 {
            let note = Routeguide_RouteNote.with {
                $0.message = text
                $0.location = .with {
                    $0.latitude = Int32.random(in: 0...100)
                    $0.longitude = Int32.random(in: 0...100)
                }
            }
            data.append(note)
        }
        
        // 事件循环组
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1, networkPreference: .best)
        defer {
            try? group.syncShutdownGracefully()
        }
        
        // 创建一个频道
        let channel = ClientConnection.insecure(group: group).connect(host: "localhost", port: 50051)
        let options = CallOptions(timeLimit: .timeout(.minutes(1)))
        let client = Routeguide_RouteGuideClient(channel: channel)
        let call = client.routeChat(callOptions: options) { [weak self] note in
            guard let this = self else { return }
            this.dataArr.append(note)
            DispatchQueue.main.async {
                this.tableView.reloadData()
            }
        }
        call.status.whenSuccess { status in
            if status.code == .ok {
              print("发送消息成功")
            } else {
              print("发送消息失败: \(status)")
            }
        }
        for note in data {
            call.sendMessage(note, promise: nil)
        }
        call.sendEnd(promise: nil)
        _ = try! call.status.wait()
    }
}

extension BidirectionalStreaminVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataArr[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = data.message
        cell?.detailTextLabel?.text = "\(data.location.longitude)-\(data.location.latitude)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}
