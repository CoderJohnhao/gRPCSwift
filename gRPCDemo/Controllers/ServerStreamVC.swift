//
//  ServerStreamVC.swift
//  gRPCDemo
//
//  Created by Johnhao on 2021/9/28.
//

import Foundation
import UIKit
import GRPC
import NIO

class ServerStreamVC: UIViewController {
    
    @IBOutlet weak var startXField: UITextField!
    @IBOutlet weak var startYField: UITextField!
    @IBOutlet weak var endXField: UITextField!
    @IBOutlet weak var endYField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataArr: [Routeguide_Feature] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    @IBAction func sendBtnClick(_ sender: Any) {
        
        dataArr = []
        // 事件循环组
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1, networkPreference: .best)
        defer {
            try? group.syncShutdownGracefully()
        }
        
        // 创建一个频道
        let channel = ClientConnection.insecure(group: group).connect(host: "localhost", port: 50051)
        
        // 创建一个服务
        let client = Routeguide_RouteGuideClient(channel: channel)
        
        defer {
            try? client.channel.close().wait()
        }
        
//        let startX = Int(startXField.text ?? "0") ?? 0
//        let startY = Int(startYField.text ?? "0") ?? 0
//        let endX = Int(endXField.text ?? "0") ?? 0
//        let endY = Int(endYField.text ?? "0") ?? 0
        // 参数。为了好测试，这里写的死数据
        let rectangle = Routeguide_Rectangle.with {
            $0.lo = .with {
                $0.latitude = numericCast(400_000_000)
                $0.longitude = numericCast(-750_000_000)
            }
            
            $0.hi = .with {
                $0.latitude = numericCast(420_000_000)
                $0.longitude = numericCast(-730_000_000)
            }
        }
        // 创建一个服务请求
        let call = client.listFeatures(rectangle, callOptions: nil) { [weak self] feature in
            guard let this = self else { return }
            this.dataArr.append(feature)
            DispatchQueue.main.async {
                this.tableView.reloadData()
            }
        }
        // 获取请求状态
        let status = try! call.status.recover { _ in .processingError }.wait()
        if status.code != .ok {
            print("RPC failed: \(status)")
        }
    }
}

extension ServerStreamVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataArr[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = data.name
        cell?.detailTextLabel?.text = "\(data.location.longitude), \(data.location.latitude)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}
