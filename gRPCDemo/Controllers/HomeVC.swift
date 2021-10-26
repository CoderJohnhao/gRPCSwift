//
//  HomeVC.swift
//  gRPCDemo
//
//  Created by Johnhao on 2021/9/26.
//

import UIKit
import SnapKit


class HomeVC: UIViewController {
    /// 数据
    var dataArr: [String] = ["A Simple Example", "客服端流式", "服务端流式", "双向多次应答" ,"上传图片"]
    
    /// tableView
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return view
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "GRPC Example"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: -  UITableViewDelegate, UITableViewDataSource
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataArr[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let vc = SimpleVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = ClientStreamVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = ServerStreamVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = BidirectionalStreaminVC()
            self.navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = UploadImageVC()
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
}
