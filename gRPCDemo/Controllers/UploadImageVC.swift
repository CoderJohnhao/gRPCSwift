//
//  File.swift
//  gRPCDemo
//
//  Created by Johnhao on 2021/9/26.
//

import Foundation
import UIKit
import GRPC
import NIO
import Logging
import NIOHPACK

class UploadImageVC: UIViewController {
    
    lazy var sendBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("上传图片", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(uploadBtnClick), for: .touchUpInside)
        return btn
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
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
        title = "上传图片"
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
        }
        
        view.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 30))
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(30)
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
    private func uploadBtnClick() {
        guard let data = UIImage(named: "1")?.jpegData(compressionQuality: 1) else { return }
        
        // 事件循环组
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        
        // 设置连接间隔时间/超时时间
        let keepalive = ClientConnectionKeepalive(interval: .seconds(15),
                                                  timeout: .seconds(10))
        // 设置debug
        var logger = Logger(label: "jh", factory: StreamLogHandler.standardError(label:))
        logger.logLevel = .debug
        
        // 信道
        let channel = ClientConnection
            .insecure(group: group) // 事件循环组
            .withKeepalive(keepalive) // 保持连接
            .withBackgroundActivityLogger(logger)
            .connect(host: host, port: port)
        
        // 创建一个链接
        let client = Helloworld_HelloServerClient(channel: channel, interceptors: ExampleClientInterceptorFactory())
        // 请求
        let request = Helloworld_UploadRequest.with {
            $0.data = data
            $0.type = "PNG"
            $0.name = "1.png"
        }
        
        // 设置header
        var options = CallOptions()
        options.customMetadata = HPACKHeaders([("test", "哈哈哈"), ("test2", "哈哈哈2")])
        
        // 发起请求
        let call = client.upload(request, callOptions: options)
        call.response.whenCompleteBlocking(onto: .main) { [weak self] result in
            logger.info("response: \(result)")
            do {
                let response = try result.get()
                self?.textLabel.text = response.result
                guard let image = UIImage(contentsOfFile: response.result) else {
                    return
                }
                self?.imageView.image = image
            } catch {
                self?.textLabel.text = error.localizedDescription
            }
            let _ = channel.close()
        }
        call.response.whenFailure { (error) in
            print("error: \(error.localizedDescription)")
        }
    }
    
}



