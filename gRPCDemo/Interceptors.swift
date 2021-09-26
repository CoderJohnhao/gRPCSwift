//
//  Interceptors.swift
//  gRPCDemo
//
//  Created by Johnhao on 2021/9/26.
//

import Foundation
import GRPC
import NIO
import Logging

/// 拦截器

class HelloClientInterceptor: ClientInterceptor<Helloworld_HelloRequest, Helloworld_HelloResponse> {
    
    override func send(_ part: GRPCClientRequestPart<Helloworld_HelloRequest>,
                       promise: EventLoopPromise<Void>?,
                       context: ClientInterceptorContext<Helloworld_HelloRequest, Helloworld_HelloResponse>) {
        switch part {
        case let .metadata(headers):
            print("> Starting '\(context.path)' RPC, headers:\(headers)")
        case let .message(request, _):
            print("> Sending request with text '\(request.name)'")
        case .end:
            print("> Closing request stream")
        }
        context.send(part, promise: promise)
    }
    
    override func receive(_ part: GRPCClientResponsePart<Helloworld_HelloResponse>,
                          context: ClientInterceptorContext<Helloworld_HelloRequest, Helloworld_HelloResponse>) {
        switch part {
        case let .metadata(headers):
          print("< Received headers:\(headers)")
        case let .message(response):
          print("< Received response with text '\(response.result)'")
        case let .end(status, trailers):
          print("< Response stream closed with status: '\(status)' and trailers:\(trailers)")
        }
        context.receive(part)
    }
}

class TestClientInterceptor: ClientInterceptor<Helloworld_TestRequest, Helloworld_HelloResponse> {
    
    override func send(_ part: GRPCClientRequestPart<Helloworld_TestRequest>,
                       promise: EventLoopPromise<Void>?,
                       context: ClientInterceptorContext<Helloworld_TestRequest, Helloworld_HelloResponse>) {
        switch part {
        case let .metadata(headers):
            print("> Starting '\(context.path)' RPC, headers:\(headers)")
        case let .message(request, _):
            print("> Sending request with text '\(request.param)'")
        case .end:
            print("> Closing request stream")
        }
        context.send(part, promise: promise)
    }
    
    override func receive(_ part: GRPCClientResponsePart<Helloworld_HelloResponse>,
                          context: ClientInterceptorContext<Helloworld_TestRequest, Helloworld_HelloResponse>) {
        switch part {
        case let .metadata(headers):
          print("< Received headers:\(headers)")
        case let .message(response):
          print("< Received response with text '\(response.result)'")
        case let .end(status, trailers):
          print("< Response stream closed with status: '\(status)' and trailers:\(trailers)")
        }
        context.receive(part)
    }
}

class UploadClientInterceptor: ClientInterceptor<Helloworld_UploadRequest, Helloworld_HelloResponse> {
    
    override func send(_ part: GRPCClientRequestPart<Helloworld_UploadRequest>,
                       promise: EventLoopPromise<Void>?,
                       context: ClientInterceptorContext<Helloworld_UploadRequest, Helloworld_HelloResponse>) {
        switch part {
        case let .metadata(headers):
            print("> Starting '\(context.path)' RPC, headers:\(headers)")
        case let .message(request, _):
            print("> Sending request with text '\(request.name)'")
        case .end:
            print("> Closing request stream")
        }
        context.send(part, promise: promise)
    }
    
    override func receive(_ part: GRPCClientResponsePart<Helloworld_HelloResponse>,
                          context: ClientInterceptorContext<Helloworld_UploadRequest, Helloworld_HelloResponse>) {
        switch part {
        case let .metadata(headers):
          print("< Received headers:\(headers)")
        case let .message(response):
          print("< Received response with text '\(response.result)'")
        case let .end(status, trailers):
          print("< Response stream closed with status: '\(status)' and trailers:\(trailers)")
        }
        context.receive(part)
    }
}

public class ExampleClientInterceptorFactory: Helloworld_HelloServerClientInterceptorFactoryProtocol {
    
    
    public init() {}
    
    func makeHelloInterceptors() -> [ClientInterceptor<Helloworld_HelloRequest, Helloworld_HelloResponse>] {
        [HelloClientInterceptor()]
    }
    
    func makeTestInterceptors() -> [ClientInterceptor<Helloworld_TestRequest, Helloworld_HelloResponse>] {
        [TestClientInterceptor()]
    }
    
    
    func makeUploadInterceptors() -> [ClientInterceptor<Helloworld_UploadRequest, Helloworld_HelloResponse>] {
        [UploadClientInterceptor()]
    }
    
    
}
