## 1、gRPC（[官网]([gRPC](https://grpc.io/))）

##### 1、gRPC简介

gRPC 是 谷歌开源的一种高性能远程过程调用 (RPC)框架，所谓的RPC(Remote Procedure Call 远程过程调用)框架实际是提供了一套机制，使得应用程序之间可以通信，而且也遵从**server/client**模型，使用的时候客户端调用server端接口就像是调用本地函数一样，如图下是RPC结构图：

![https://grpc.io/img/landing-2.svg](https://grpc.io/img/landing-2.svg)

##### 2、Protocol Buffers

默认情况下，gRPC 使用[Protocol Buffers]([Language Guide  | Protocol Buffers  | Google Developers](https://developers.google.com/protocol-buffers/docs/overview))，Protocol Buffers是一个灵活的、高效的、自动化的用于对结构化数据进行序列化的协议，与XML相比，Protocol Buffers序列化后的码流更小、速度更快、操作更简单。在一些高性能且对响应速度有要求的数据传输场景非常适用。

```protobuf
syntax="proto3";

message HelloRequest {
  string greeting = 1;
}

message HelloResponse {
  string reply = 1;
}

service HelloService {
  rpc SayHello (HelloRequest) returns (HelloResponse);
}

```

Protoco Buffers在gRPC的框架中主要有三个作用：

- 定义数据结构
- 定义服务接口
- 通过序列化和反序列化，提升传输效率

使用XML、JSON进行数据编译时，数据文本格式更容易阅读，但进行数据交换时，设备就需要耗费大量的CPU在I/O动作上，自然会影响整个传输速率。Protocol Buffers不像前者，它会将字符串进行序列化后再二进制的形式进行传输。

在编码方面Protocol Buffers对比JSON、XML的优点：

- 简单，体积小，数据描述文件大小只有1/10至1/3；
- 传输和解析的速率快，相比XML等，解析速度提升20倍甚至更高；
- 可编译性强。

##### 3、基于HTTP/2

由于gRPC基于HTTP 2.0标准设计，带来了更多强大功能，如多路复用、二进制帧、头部压缩、推送机制。这些功能给设备带来重大益处，如节省带宽、降低TCP连接次数、节省CPU使用等。gRPC既能够在客户端应用，也能够在服务器端应用，从而以透明的方式实现两端的通信和简化通信系统的构建。

HTTP 2.0的新特性：

- 双向流、多路复用

  在HTTP 1.X协议中，客户端在同一时间访问同一域名的请求数量是有限制的，当超过阈值时请求会被阻断，但是这种情况在HTTP 2.0中将被忽略。由于HTTP 1.X传输的是纯文本数据，传输体积较大，而HTTP 2.0传输的基本单元为帧，每个帧都包含消息，并且由于HTTP 2.0允许同时通过一条连接发起多个“请求-响应”消息，无需建立多个TCP链接的同时实现多条流并行，提高吞吐性能，并且在一个连接内对多个消息进行优先级的管理和流控。

- 二进制帧

  相对于HTTP 1.X的纯文本传输来，HTTP 2.0传输的是二进制数据，与Protocol Buffers相辅相成。使得传输数据体积小、负载低，保持更加紧凑和高效。

- 头部压缩

  因为HTTP是无状态协议，对于业务的处理没有记忆能力，每一次请求都需要携带设备的所有细节，特别是在头部都会包含大量的重复数据，对于设备来说就是在不断地做无意义的重复性工作。HTTP 2.0中使用“头表”来跟踪之前发送的数据，对于相同的数据将不再使用重复请求和发送，进而减少数据的体积。

  ![](https://pics3.baidu.com/feed/d439b6003af33a87a23f99fd505dc03c5243b589.jpeg?token=3c7fc45b9bcac3492c61ffc443814a5d&s=C26BB7529C78748A54476C54030080FE)

##### 4、gRPC通信方式

像许多RPC系统一样，gRPC也是围绕着定义服务的理念，指定可以远程调用的方法及其参数和返回类型。默认情况下，gRPC使用Protocol Buffers作为接口定义语言（IDL）来描述服务接口和有效载荷消息的结构。如果需要的话，也可以使用其他的替代品。

gRPC 允许您定义四种服务方法:

1、Unary RPC

单一的RPC，客户端向服务器发送单个请求并返回单个响应，就像普通的函数调用一样。	

```protobuf
rpc SayHello(HelloRequest) returns (HelloResponse);
```

2、Server streaming RPC

服务器流式 RPC，其中客户端向服务器发送请求并获取流以读取一系列消息。客户端从返回的流中读取，直到没有更多消息。 gRPC 保证单个 RPC 调用中的消息排序。

```protobuf
rpc LotsOfReplies(HelloRequest) returns (stream HelloResponse);
```

3、Client streaming RPC

客户端流式 RPC，其中客户端写入一系列消息并将它们发送到服务器，再次使用提供的流。一旦客户端完成写入消息，它等待服务器读取它们并返回其响应。 gRPC 再次保证单个 RPC 调用中的消息排序。

```protobuf
rpc LotsOfGreetings(stream HelloRequest) returns (HelloResponse);
```

4、Bidirectional streaming RPC

双向流式 RPC，其中双方使用读写流发送一系列消息。这两个流独立运行，因此客户端和服务器可以按照他们喜欢的任何顺序进行读写：例如，服务器可以在写入响应之前等待接收所有客户端消息，或者它可以交替读取消息然后写入消息，或其他一些读取和写入的组合。保留每个流中消息的顺序。

```protobuf
rpc BidiHello(stream HelloRequest) returns (stream HelloResponse);
```

## 2、安装proto/grpc插件

##### 1、使用pod安装Swift-proto/gprc插件

```swift
pod 'gRPC-Swift'
pod 'gRPC-Swift-Plugins'
// 执行pod install
$pod install

//pod install完成后，将Pods/gRPC-Swift-Plugins里面的protoc-gen-swift/protoc-gen-grpc-swift 拷贝到/usr/local/bin
$cp protoc-gen-swift protoc-gen-grpc-swift /usr/local/bin
```

##### 2、安装OC-proto/grpc插件

- 新建一个.podspec文件

```ruby
Pod::Spec.new do |s|
  s.name     = '<Podspec file name>'
  s.version  = '0.0.1'
  s.license  = '...'
  s.authors  = { '<your name>' => '<your email>' }
  s.homepage = '...'
  s.summary = '...'
  s.source = { :git => 'https://github.com/...' }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'

  # Base directory where the .proto files are.
  src = '.'

  # We'll use protoc with the gRPC plugin.
  s.dependency '!ProtoCompiler-gRPCPlugin', '~> 1.0'

  # Pods directory corresponding to this app's Podfile, relative to the location of this podspec.
  pods_root = '<path to your Podfile>/Pods'

  # Path where Cocoapods downloads protoc and the gRPC plugin.
  protoc_dir = "#{pods_root}/!ProtoCompiler"
  protoc = "#{protoc_dir}/protoc"
  plugin = "#{pods_root}/!ProtoCompiler-gRPCPlugin/grpc_objective_c_plugin"

  # Directory where you want the generated files to be placed. This is an example.
  dir = "#{pods_root}/#{s.name}"

  # Run protoc with the Objective-C and gRPC plugins to generate protocol messages and gRPC clients.
  # You can run this command manually if you later change your protos and need to regenerate.
  # Alternatively, you can advance the version of this podspec and run `pod update`.
  s.prepare_command = <<-CMD
    mkdir -p #{dir}
    #{protoc} \
        --plugin=protoc-gen-grpc=#{plugin} \
        --objc_out=#{dir} \
        --grpc_out=#{dir} \
        -I #{src} \
        -I #{protoc_dir} \
        #{src}/*.proto
  CMD

  # The --objc_out plugin generates a pair of .pbobjc.h/.pbobjc.m files for each .proto file.
  s.subspec 'Messages' do |ms|
    ms.source_files = "#{dir}/*.pbobjc.{h,m}"
    ms.header_mappings_dir = dir
    ms.requires_arc = false
    # The generated files depend on the protobuf runtime.
    ms.dependency 'Protobuf'
  end

  # The --objcgrpc_out plugin generates a pair of .pbrpc.h/.pbrpc.m files for each .proto file with
  # a service defined.
  s.subspec 'Services' do |ss|
    ss.source_files = "#{dir}/*.pbrpc.{h,m}"
    ss.header_mappings_dir = dir
    ss.requires_arc = true
    # The generated files depend on the gRPC runtime, and on the files generated by `--objc_out`.
    ss.dependency 'gRPC-ProtoRPC'
    ss.dependency "#{s.name}/Messages"
  end

  s.pod_target_xcconfig = {
    # This is needed by all pods that depend on Protobuf:
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1',
    # This is needed by all pods that depend on gRPC-RxLibrary:
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  }
end

// 新建Podfile文件
pod '<Podspec file name>', :path => 'podspec文件路径'

// 再执行 pod install
```

```ruby
// 终端生成pbrpc和pbobjc代码文件
protoc --plugin=protoc-gen-grpc=编译器插件路径/grpc_objective_c_plugin --objc_out=生成pbobjc文件夹路径 --grpc_out=生成pbrpc文件夹路径 -I 存放.proto文件夹路径 -I .proto文件路径
```



##### 3、服务端使用python语言，python安装protoc/grpc插件

```
$python -m pip install grpcio
$python -m pip install grpcio-tools googleapis-common-protos
```

## 3、proto语法

使用的proto语法的文本文件, 用来定义数据格式。

##### 1、自定义消息类型

###### 1.0、下面是一个简单的例子：

```protobuf
syntax="proto3"; // proto版本

// 请求
message HelloRequest {
	// 类型 名称 = 编号;
	string name = 1;
}
```

- 第一行的含义是定该文件使用的是proto3的语法。

- HelloRequest定义有一个承载消息的属性，每一个被定义在HelloRequest消息体中的字段，都是由数据类型和属性名称组成。

###### 1.1、指定字段类型

​	在上面的示例中，字段是标量类型：字符串类型(name)，但是您也可以为字段指定复合类型，包括枚举和其他消息类型。

###### 1.2、分配数字编号

​	消息定义中的每个字段都有一个**唯一的编号**。这些字段编号用于在[消息二进制格式中](https://developers.google.com/protocol-buffers/docs/encoding)标识您的字段，一旦您的消息类型被使用，就不应更改。请注意，1 到 15 范围内的字段编号占用一个字节进行编码，包括字段编号和字段类型（您可以在[协议缓冲区编码中](https://developers.google.com/protocol-buffers/docs/encoding#structure)找到更多相关信息）。16 到 2047 范围内的字段编号占用两个字节。因此，您应该为非常频繁出现的消息元素保留数字 1 到 15。请记住为将来可能添加的频繁出现的元素留出一些空间。

###### 1.3、指定字段规则

​	消息字段可以是以下之一：

- singular：格式正确的消息可以有零个或一个此字段，这是 proto3 语法的默认字段规则。
- repeated：该字段可以在消息中重复任意次数，重复值的顺序将被保留。类似数组

###### 1.4、添加更多的消息类型

​	可以在单个`.proto`文件中定义多种消息类型。如果您要定义多个相关消息，这很有用 - 例如，如果您想定义与您的`HelloResponse`消息类型相对应的回复消息格式，您可以将其添加到相同的`.proto`

```protobuf
syntax="proto3"; // proto版本

// 请求
message HelloRequest {
	// 类型 名称 = 编号;
	string name = 1;
}

// 响应
message HelloResponse {
	string result = 1;
}
```

###### 1.5、添加评论

​	要向`.proto`文件添加注释，请使用 C/C++ 样式`//`和`/* ... */`语法。

```protobuf
syntax="proto3";

/* 这是注释 */
message HelloRequest {
	string name = 1; // 姓名
}
```

###### 1.6、保留字段

​	如果您通过完全删除某个字段或将其注释掉来[更新](https://developers.google.com/protocol-buffers/docs/proto3#updating)消息类型，则未来的用户可以在对类型进行自己的更新时重复使用该字段编号。如果他们以后加载相同的旧版本，这可能会导致严重的问题`.proto`，包括数据损坏、隐私错误等。确保不会发生这种情况的一种方法是指定已删除字段的字段编号是`reserved`. 如果任何未来的用户尝试使用这些字段标识符，协议缓冲区编译器会报错。请注意，您不能在同一`reserved`语句中混合使用字段名称和字段编号。

```protobuf
message Foo {
  reserved 2, 15, 9 to 11;
  reserved "foo", "bar";
  // reserved 2, "foo"; ❌
}
```

##### 2、数据类型

| proto    | Swift  | OC       |
| :------- | ------ | -------- |
| double   | Double | double   |
| float    | Float  | float    |
| int32    | Int32  | int32_t  |
| int64    | Int64  | int64_t  |
| uint32   | UInt32 | uint32_t |
| uint64   | UInt64 | uint64_t |
| sint32   | Int32  | int32_t  |
| sint64   | Int64  | int64_t  |
| fixed32  | UInt32 | uint32_t |
| fixed64  | UInt64 | uint64_t |
| sfixed32 | Int32  | int32_t  |
| sfixed64 | Int64  | int64_t  |
| bool     | Bool   | BOOL     |
| string   | String | NSString |
| bytes    | Data   | NSData   |

##### 3、默认值

​	解析消息时，如果编码的消息不包含特定的单数元素，则解析对象中的相应字段将设置为该字段的默认值。这些默认值是特定于类型的：

- 对于string，默认值为空字符串。
- 对于bytes，默认值为空字节。
- 对于 bool，默认值为 false。
- 对于数字类型，默认值为零。
- 对于[enums](https://developers.google.com/protocol-buffers/docs/proto3#enum)，默认值是第**一个定义的 enum value**，它必须是 0。
- 对于消息字段，未设置该字段。它的确切值取决于语言。有关详细信息，请参阅[生成的代码指南](https://developers.google.com/protocol-buffers/docs/reference/overview)。

##### 4、枚举

​	当您定义消息类型时，您可能希望它的一个字段只有一个预定义的值列表。例如，假设你想添加一个`corpus`字段每个`SearchRequest`，其中语料库可以`UNIVERSAL`，`WEB`，`IMAGES`，`LOCAL`，`NEWS`，`PRODUCTS`或`VIDEO`。您可以通过`enum`为每个可能的值添加一个常量到您的消息定义中来非常简单地做到这一点。在下面的示例中，我们添加了一个具有所有可能值的`enum`调用`Corpus`和一个类型为的字段`Corpus`：

```protobuf
message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 result_per_page = 3;
  enum Corpus {
    UNIVERSAL = 0;
    WEB = 1;
    IMAGES = 2;
    LOCAL = 3;
    NEWS = 4;
    PRODUCTS = 5;
    VIDEO = 6;
  }
  Corpus corpus = 4;
}
```

##### 5、使用其他类型

您可以使用其他消息类型作为字段类型。例如，假设您想`Result`在每条`SearchResponse`消息中包含消息,为此您可以在其中定义一个`Result`消息类型`.proto`，然后指定一个类型为`Result`in的字段`SearchResponse`：

```protobuf
import "其他类型文件相对路径.proto"; // Test
import "google/protobuf/any.proto";

message SearchResponse {
	// 引用当前文件内类型
  repeated Result results = 1;
  // 引用其他文件类型
  Test test = 2;
  // 使用包名，防止重名冲突
  test.bar.Result result = 3;
  // Map
  map<stirng, int> ages = 4;
  // Any
  google.protobuf.Any any1 = 5;
}

message Result {
  string url = 1;
  string title = 2;
  repeated string snippets = 3;
  
  message DataMsg {
  	string msg = 1;
  	string desc = 2;
  }
  // 内嵌
  DataMsg msg = 4;
}
```

```protobuf
package test.bar;
message Result {
	...
}
```

##### 6、定义服务Server

​	如果您想在 RPC（远程过程调用）系统中使用您的消息类型，您可以在`.proto`文件中定义一个 RPC 服务接口，协议缓冲区编译器将以您选择的语言生成服务接口代码和存根。因此，例如，如果您想使用接受您`HelloRequest`并返回 a的方法定义 RPC 服务`HelloResponse`，您可以在您的`.proto`文件中按如下方式定义它：

```protobuf
syntax = "proto3";

message HelloRequest {
	string name = 1; // 姓名
}

message HelloResponse {
	string result = 1;
}

service HelloServer {
	rpc Hello(HelloRequest) returns (HelloResponse);
}
```

## 4、Client-Swift实现

swift需要使用cocoapods导入两个框架

```ruby
pod 'gRPC-Swift'
pod 'gRPC-Swift-Plugins' // 主要是获取protoc-gen-swift/protoc-gen-grpc-swift编译器插件，后期添加/usr/local/bin后可以不用
```

用.proto 文件来创建GRPC服务， 用Protocol Buffer消息类型定义方法参数和返回类型，格式如下。

```protobuf
syntax = "proto3";

package helloworld;

message HelloRequest {
    string name = 1;
}

message HelloResponse {
    string result = 1;
}

service HelloServer {
    rpc Hello (HelloRequest) returns (HelloResponse) {}
}
```

终端cd 到.proto文件目录下，生成.pb.swfit和.grpc.swift两个文件

```
protoc .proto文件路径 \
    --proto_path=proto文件目录 \
    --plugin=protoc-gen-swift执行文件路径 \
    --swift_opt=Visibility=Public \
    --swift_out=生成.pb.swift存放目录 \
    --plugin=protoc-gen-grpc-swift执行文件路径 \
    --grpc-swift_opt=Visibility=Public \
    --grpc-swift_out=生成.grpc.swift存放目录
```

代码实现,demo链接[Github](https://github.com/CoderJohnhao/gRPCSwift.git)

```swift
import GRPC
import NIO
import Logging

/// 服务器地址
let host = "0.0.0.0"
/// 端口
let port = 5000

/// 创建一个事件循环组
/// - loopCount: 循环个数
let eventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)

// 设置连接间隔时间/超时时间
let keepalive = ClientConnectionKeepalive(interval: .seconds(15),
                                          timeout: .seconds(10))
// 设置logger
var logger = Logger(label: "gRPC", factory: StreamLogHandler.standardError(label:))
logger.logLevel = .debug

// 信道
let channel = ClientConnection
    .insecure(group: group) // 事件循环组
    .withKeepalive(keepalive) // 设置保持长连接时间
    .withBackgroundActivityLogger(logger)
    .connect(host: host, port: port)

// 创建一个链接
let client = Helloworld_HelloServerClient(channel: channel)
// 请求
let request = Helloworld_HelloRequest.with { $0.name = text }
// 发起请求
let call = client.hello(request)
call.response.whenCompleteBlocking(onto: .main) { [weak self] result in
    do {
        let response = try result.get()
        print(response.result)
    } catch {
        print(error.localizedDescription)
    }
    // 关闭                                            
    let _ = channel.close()
}
```



## 5、Client-OC实现

demo链接[Github](https://github.com/CoderJohnhao/gRPC-OC.git)

```objective-c
[GRPCProtoCall useInsecureConnectionsForHost:host_port];
HelloServer *server = [[HelloServer alloc] initWithHost: host_port];
HelloRequest *reqeust = [HelloRequest message];
reqeust.name = @"EASI";
[server helloWithRequest:reqeust handler:^(HelloResponse * _Nullable response, NSError * _Nullable error) {
    if (response) {
        NSLog(@"response: %@", response.result);
    } else {
        NSLog(@"error: %@", error.localizedDescription);
    }
}];
```



## 6、Server-Python实现

demo链接[Github](https://github.com/CoderJohnhao/grpcdemo.git)



资料参照：[gRPC官网]([Core concepts, architecture and lifecycle | gRPC](https://grpc.io/docs/what-is-grpc/core-concepts/))、[Protocol Buffers](https://developers.google.com/protocol-buffers/docs/overview)、[grpc地址Github](https://github.com/grpc/grpc.git)、[gRPC-OC]([grpc/src/objective-c at master · grpc/grpc (github.com)](https://github.com/grpc/grpc/tree/master/src/objective-c))、[gRPC-Swift](https://github.com/grpc/grpc-swift.git)

