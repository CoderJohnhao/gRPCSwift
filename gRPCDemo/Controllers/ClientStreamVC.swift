//
//  ClientStreamVC.swift
//  gRPCDemo
//
//  Created by Johnhao on 2021/9/28.
//

import UIKit
import GRPC

class ClientStreamVC: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var dataArr: [Routeguide_RouteSummary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func sendBtnClick(_ sender: Any) {
        guard let path = Bundle.main.path(forResource: "route_guide_db", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else { return }
        guard let dataArr = try? Routeguide_Feature.array(fromJSONUTF8Data: data) else { return }
        
        // 事件循环组
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1, networkPreference: .best)
        defer {
            try? group.syncShutdownGracefully()
        }
        
        // 创建一个频道
        let channel = ClientConnection.insecure(group: group).connect(host: "localhost", port: 50051)
        let options = CallOptions(timeLimit: .timeout(.minutes(1)))
        let client = Routeguide_RouteGuideClient(channel: channel)
        
        defer {
            try? client.channel.close().wait()
        }
        
        let call = client.recordRoute(callOptions: options)
        call.response.whenSuccess { [weak self] summary in
            guard let this = self else { return }
            this.dataArr.append(summary)
            DispatchQueue.main.async {
                this.tableView.reloadData()
            }
        }
        
        call.response.whenFailure { error in
          print("RecordRoute Failed: \(error)")
        }

        call.status.whenComplete { _ in
          print("Finished RecordRoute")
        }
        
        for _ in 0..<10 {
            let index = Int.random(in: 0..<dataArr.count)
            let point = dataArr[index].location
            print("Visiting point \(point.latitude), \(point.longitude)")
            call.sendMessage(point, promise: nil)
            Thread.sleep(forTimeInterval: TimeInterval.random(in: 0.5..<1.5))
        }
        
        call.sendEnd(promise: nil)
        
        _ = try! call.status.wait()
    }
    
}

extension ClientStreamVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataArr[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = "\(data.distance)-\(data.featureCount)-\(data.pointCount)-\(data.elapsedTime)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

