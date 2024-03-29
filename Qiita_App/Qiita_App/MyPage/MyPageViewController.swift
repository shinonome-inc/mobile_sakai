//
//  MyPageViewController.swift
//  Qiita_App
//
//  Created by Sakai Syunya on 2021/07/26.
//  Copyright © 2021 Sakai Syunya. All rights reserved.
//

import UIKit
import Alamofire

class MyPageViewController: UIViewController {
    
    @IBOutlet var myArticlesList: UITableView!
    @IBOutlet var myIcon: UIImageView!
    @IBOutlet var myName: UILabel!
    @IBOutlet var myId: UILabel!
    @IBOutlet var myIntroduction: UILabel!
    @IBOutlet var followCount: UIButton!
    @IBOutlet var followerCount: UIButton!
    var myArticles: [UserArticleItem] = []
    var myInfo: UserHeader?
    var page = 1
    var id = ""
    var commonApi = CommonApi()
    var errorView = NetworkErrorView()
    var reLogin = NotLoginPageViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorView.reloadActionDelegate = self
        commonApi.presentNetworkErrorViewDelegate = self
        reLogin.loginActionDelegate = self
        myArticlesList.dataSource = self
        myArticlesList.delegate = self
        settingHeader(myArticlesList)
        checkNetwork()
        if AccessTokenDerivery.shared.getAccessToken().isEmpty {
            reLogin.center = self.view.center
            reLogin.frame = self.view.frame
            self.view.addSubview(reLogin)
        }
        
        CommonApi().myPageRequest(completion: { data in
            if data.isEmpty {
                self.checkNetwork()
            }
            data.forEach {
                self.myArticles.append($0)
            }
            self.myArticlesList.reloadData()
        }, url: CommonApi.structUrl(option: .myPage(page: page)))
        
        CommonApi.myPageHeaderRequest(completion: { data in
            self.myInfo = data
            guard let myData = self.myInfo else { return }
            guard let imageUrl = URL(string: myData.profileImageUrl) else { return }
            do {
                let imageData = try Data(contentsOf: imageUrl)
                self.myIcon.image = UIImage(data: imageData)
            } catch {
                self.myIcon.image = UIImage(named: "errorUserIcon")
                print("error: Can't get image")
            }
            self.myName.text = myData.name
            self.myId.text = "@\(myData.id)"
            self.id = myData.id
            self.myIntroduction.text = myData.description
            self.followCount.setTitle("\(myData.followeesCount) フォロー中", for: .normal)
            self.followerCount.setTitle("\(myData.followersCount) フォロワー", for: .normal)
        }, url: CommonApi.structUrl(option: .myPageHeader))
        configureRefreshControl()
    }
    
    @IBAction func pushFollowCount(_ sender: Any) {
        guard let nextVC: FollowPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowPage") as? FollowPageViewController else { return }
        nextVC.tableViewInfo = .followees
        nextVC.userId = id
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func pushFollowerCount(_ sender: Any) {
        guard let nextVC: FollowPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowPage") as? FollowPageViewController else { return }
        nextVC.tableViewInfo = .followers
        nextVC.userId = id
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func checkNetwork() {
        if let isConnected = NetworkReachabilityManager()?.isReachable, !isConnected {
            presentNetworkErrorView()
            return
        }
    }
    
    func settingHeader(_ tableView: UITableView) {
        let label = UILabel(frame: CGRect(x:0, y:0, width: tableView.bounds.width, height: 28))
        label.text = "　　投稿記事"
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.backgroundColor = UIColor {_ in return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)}
        label.textColor = UIColor {_ in return #colorLiteral(red: 0.5098039216, green: 0.5098039216, blue: 0.5098039216, alpha: 1)}
        tableView.tableHeaderView = label
    }
    
    func configureRefreshControl () {
        myArticlesList.refreshControl = UIRefreshControl()
        myArticlesList.refreshControl?.addTarget(self, action:#selector(handleRefreshControl), for: .valueChanged)
    }

    @objc func handleRefreshControl() {
        page = 1
        
        CommonApi().myPageRequest(completion: { data in
            self.myArticles.removeAll()
            if data.isEmpty {
                self.checkNetwork()
            }
            data.forEach {
                self.myArticles.append($0)
            }
            self.myArticlesList.reloadData()
        }, url: CommonApi.structUrl(option: .myPage(page: page)))
        
        CommonApi.myPageHeaderRequest(completion: { data in
            self.myInfo = data
            guard let myData = self.myInfo else { return }
            guard let imageUrl = URL(string: myData.profileImageUrl) else { return }
            do {
                let imageData = try Data(contentsOf: imageUrl)
                self.myIcon.image = UIImage(data: imageData)
            } catch {
                self.myIcon.image = UIImage(named: "errorUserIcon")
                print("error: Can't get image")
            }
            self.myName.text = myData.name
            self.myId.text = "@\(myData.id)"
            self.id = myData.id
            self.myIntroduction.text = myData.description
            self.followCount.setTitle("\(myData.followeesCount) フォロー中", for: .normal)
            self.followerCount.setTitle("\(myData.followersCount) フォロワー", for: .normal)
        }, url: CommonApi.structUrl(option: .myPageHeader))
        DispatchQueue.main.async {
            self.myArticlesList.refreshControl?.endRefreshing()
        }
    }
}

extension MyPageViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = IdentifierOption.cellType.myPage.identifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MyPageCellViewController else {
            return UITableViewCell()
        }
        cell.setMyArticleCell(data: myArticles[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //-10:基本的にはcountパラメータで20個の記事を取得してくるように指定しているので、20-10=10の10個目のセル、つまり最初に表示された半分までスクロールされたら、追加で記事を読み込む(ページネーション)するようになっています。
        if myArticles.count >= 20 && indexPath.row == ( myArticles.count - 10) {
            checkNetwork()
            page += 1
            
            CommonApi().myPageRequest(completion: { data in
                if data.isEmpty {
                    self.checkNetwork()
                }
                data.forEach {
                    self.myArticles.append($0)
                }
                self.myArticlesList.reloadData()
            }, url: CommonApi.structUrl(option: .myPage(page: page)))
        }
    }
}

extension MyPageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC: QiitaArticlePageViewController = self.storyboard?.instantiateViewController(withIdentifier: "ArticlePage") as? QiitaArticlePageViewController else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        nextVC.articleUrl = myArticles[indexPath.row].url
        self.present(nextVC, animated: true, completion: nil)
    }
}

extension MyPageViewController: ReloadActionDelegate {
    
    func errorReload() {
        guard let isConnected = NetworkReachabilityManager()?.isReachable else { return }
        if isConnected {
            CommonApi().myPageRequest(completion: { data in
                self.myArticles.removeAll()
                if data.isEmpty {
                    self.checkNetwork()
                } else {
                    self.errorView.removeFromSuperview()
                    data.forEach {
                        self.myArticles.append($0)
                    }
                    self.myArticlesList.reloadData()
                }
            }, url: CommonApi.structUrl(option: .myPage(page: page)))
            
            CommonApi.myPageHeaderRequest(completion: { data in
                self.myInfo = data
                guard let myData = self.myInfo else { return }
                guard let imageUrl = URL(string: myData.profileImageUrl) else { return }
                do {
                    let imageData = try Data(contentsOf: imageUrl)
                    self.myIcon.image = UIImage(data: imageData)
                } catch {
                    self.myIcon.image = UIImage(named: "errorUserIcon")
                    print("error: Can't get image")
                }
                self.myName.text = myData.name
                self.myId.text = "@\(myData.id)"
                self.id = myData.id
                self.myIntroduction.text = myData.description
                self.followCount.setTitle("\(myData.followeesCount) フォロー中", for: .normal)
                self.followerCount.setTitle("\(myData.followersCount) フォロワー", for: .normal)
            }, url: CommonApi.structUrl(option: .myPageHeader))
        }
    }
}

extension MyPageViewController: PresentNetworkErrorViewDelegate {
    
    func presentNetworkErrorView() {
        errorView.center = self.view.center
        errorView.frame = self.view.frame
        self.view.addSubview(errorView)
    }
}

extension MyPageViewController: LoginActionDelegate {
    
    func loginAction() {
        guard let nextVC = storyboard?.instantiateViewController(withIdentifier: "TopPage") else { return }
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true, completion: nil)
        reLogin.removeFromSuperview()
    }
}
