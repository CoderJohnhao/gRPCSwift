//
//  SimpleVC.swift
//  gRPCDemo
//
//  Created by Johnhao on 2021/9/26.
//

import Foundation
import UIKit
import GRPC
import NIO
import Logging

class SimpleVC: UIViewController {
    
    lazy var textField: UITextField = {
        let view = UITextField()
        view.placeholder = "请输入你的名字"
        view.borderStyle = .roundedRect
        return view
    }()
    
    lazy var sendBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("发送", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(sendBtnClick), for: .touchUpInside)
        return btn
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .red
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "简单事例"
        
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.top.equalTo(view.snp.topMargin).offset(30)
            make.height.equalTo(40)
        }
        
        view.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 60, height: 30))
            make.centerX.equalToSuperview()
            make.top.equalTo(textField.snp.bottom).offset(30)
        }
        
        view.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.top.equalTo(sendBtn.snp.bottom).offset(50)
            make.bottom.lessThanOrEqualToSuperview().offset(-30)
        }
    }
    
    
    @objc
    private func sendBtnClick() {
        guard let text = textField.text, !text.isEmpty else { return }
        
        
        // 事件循环组
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        
        // 设置连接间隔时间/超时时间
        let keepalive = ClientConnectionKeepalive(interval: .seconds(15),
                                                  timeout: .seconds(10))
        // 设置debug
        var logger = Logger(label: "gRPC", factory: StreamLogHandler.standardError(label:))
        logger.logLevel = .debug
        
        // 信道
        let channel = ClientConnection
            .insecure(group: group) // 事件循环组
            .withKeepalive(keepalive) // 保持长连接
            .withBackgroundActivityLogger(logger)
            .connect(host: "localhost", port: 50051)
        
        // 创建一个链接
        let client = Routeguide_RouteGuideClient(channel: channel)
        // 请求
        let request = Routeguide_Point.with {
            $0.latitude = 408122808
            $0.longitude = -743999179
        }
        // 发起请求
        let call = client.getFeature(request)
        call.response.whenCompleteBlocking(onto: .main) { [weak self] result in
            do {
                let response = try result.get()
                self?.textLabel.text = response.name
            } catch {
                self?.textLabel.text = error.localizedDescription
            }
            let _ = channel.close()
        }
    }
}



