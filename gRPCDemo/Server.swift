//
//  Server.swift
//  gRPCDemo
//
//  Created by Johnhao on 2021/9/9.
//

import GRPC
import NIO
import Logging
import Foundation

let host = "0.0.0.0"
let port = 5000


typealias ErrorBlock = (Error) -> Void
typealias CompleteBlock = () -> ()
typealias SuccessBlock<T> = (T) -> Void


/// 服务
final class Server: NSObject {
    // 信道
    var channel: ClientConnection!
    
    override init() {
        super.init()
        // 事件循环组
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        
        // 设置连接间隔时间/超时时间
        let keepalive = ClientConnectionKeepalive(interval: .seconds(15),
                                                  timeout: .seconds(10))
        // 设置debug
        var logger = Logger(label: "gRPC", factory: StreamLogHandler.standardError(label:))
        logger.logLevel = .debug
        
        // 信道
        self.channel = ClientConnection
            .insecure(group: group) // 事件循环组
            .withKeepalive(keepalive) // 保持长连接
            .withBackgroundActivityLogger(logger)
            .withConnectivityStateDelegate(self, executingOn: .global())
            .withErrorDelegate(self)
            .connect(host: host, port: port)
    }
    
    
    /// 发起请求
    /// - Parameters:
    ///   - test: 参数
    ///   - success: 成功回调
    ///   - failed: 失败回调
    ///   - complte: 完成回调
    func request(_ test: Helloworld_HelloRequest, success: SuccessBlock<String>?=nil, failed: ErrorBlock?=nil, complte: CompleteBlock?=nil) {
        // 创建一个链接
        let client = Helloworld_HelloServerClient(channel: channel)
        // 请求
        let request = Helloworld_HelloRequest.with { $0 = test }
        // 发起请求
        let call = client.hello(request)
        call.response.whenComplete { result in
            do {
                let response = try result.get()
                success?(response.result)
            } catch {
                failed?(error)
            }
            complte?()
        }
        call.response.whenFailure { error in
            failed?(error)
            complte?()
        }

    }
    
    /// 发起请求
    /// - Parameters:
    ///   - data: 参数
    ///   - success: 成功回调
    ///   - failed: 失败回调
    ///   - complte: 完成回调
    func request(_ data: Data, success: @escaping(String) -> (), failed: ErrorBlock?=nil, complte: CompleteBlock?=nil) {
        // 创建一个链接
        let client = Helloworld_HelloServerClient(channel: channel)
        // 请求
        let request = Helloworld_TestRequest.with {
            $0.param = data
        }
        // 发起请求
        let call = client.test(request)
        do {
            let response = try call.response.wait()
            success(response.result)
        } catch {
            failed?(error)
        }
        complte?()
    }
    
    /// 上传
    /// - Parameters:
    ///   - data: 参数
    ///   - success: 成功回调
    ///   - failed: 失败回调
    ///   - complte: 完成回调
    func upLoad(_ name: String, data: Data, type: String, success: @escaping(String) -> (), failed: ErrorBlock?=nil, complte: CompleteBlock?=nil) {
        // 创建一个链接
        let client = Helloworld_HelloServerClient(channel: channel)
        // 请求
        let request = Helloworld_UploadRequest.with {
            $0.data = data
            $0.type = type
            $0.name = name
        }
        // 发起请求
        let call = client.upload(request)
        do {
            let response = try call.response.wait()
            success(response.result)
        } catch {
            failed?(error)
        }
        complte?()
    }
    
    deinit {
        _ = channel.close()
        print("\(self) - closed")
    }
}

extension Server: ConnectivityStateDelegate {
    func connectivityStateDidChange(from oldState: ConnectivityState, to newState: ConnectivityState) {
        debugPrint("oldState:\(oldState) -> newState:\(newState)")
    }
}

extension Server: ClientErrorDelegate {
    func didCatchError(_ error: Error, logger: Logger, file: StaticString, line: Int) {
        debugPrint("error: \(error.localizedDescription)\n logger: \(logger.label)\n file: \(file)\n line: \(line)")
    }
}
