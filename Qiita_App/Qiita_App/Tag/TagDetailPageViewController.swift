//
//  TagDetailViewController.swift
//  Qiita_App
//
//  Created by Sakai Syunya on 2021/07/29.
//  Copyright © 2021 Sakai Syunya. All rights reserved.
//

import UIKit
import Alamofire

class TagDetailPageViewController: UIViewController {
    
    @IBOutlet var tagDetailArticle: UITableView!
    var tagName = ""
    var encodedTagName = ""
    var page = 1
    var articles: [DataItem] = []
    var commonApi = CommonApi()
    var errorView = NetworkErrorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = tagName
        tagDetailArticle.delegate = self
        tagDetailArticle.dataSource = self
        errorView.reloadActionDelegate = self
        commonApi.presentNetworkErrorViewDelegate = self
        checkNetwork()
        
        encodedTagName = self.urlEncode(beforeText: self.tagName)
        
        CommonApi.tagDetailPageRequest(completion: { data in
            print(self.urlEncode(beforeText: self.tagName))
            print(data)
            if data.isEmpty {
                self.presentNetworkErrorView()
            }
            data.forEach {
                self.articles.append($0)
            }
            self.tagDetailArticle.reloadData()
        }, url: CommonApi.structUrl(option: .tagDetailPage(page: page, tagTitle: encodedTagName)))
        configureRefreshControl()
    }
    
    func checkNetwork() {
        if let isConnected = NetworkReachabilityManager()?.isReachable, !isConnected {
            presentNetworkErrorView()
            return
        }
    }
    
    func configureRefreshControl () {
        tagDetailArticle.refreshControl = UIRefreshControl()
        tagDetailArticle.refreshControl?.addTarget(self, action:#selector(handleRefreshControl), for: .valueChanged)
    }
    
    func urlEncode(beforeText: String) -> String {
        let allowedCharacters = NSCharacterSet.alphanumerics.union(.init(charactersIn: "-._~"))
        if let encodedText = beforeText.addingPercentEncoding(withAllowedCharacters: allowedCharacters) {
            return encodedText
        }
        return ""
    }

    @objc func handleRefreshControl() {
        page = 1
        
        CommonApi.tagDetailPageRequest(completion: { data in
            self.articles.removeAll()
            if data.isEmpty {
                self.presentNetworkErrorView()
            }
            data.forEach {
                self.articles.append($0)
            }
            self.tagDetailArticle.reloadData()
        }, url: CommonApi.structUrl(option: .tagDetailPage(page: page, tagTitle: encodedTagName)))
        DispatchQueue.main.async {
            self.tagDetailArticle.refreshControl?.endRefreshing()
        }
    }
}

extension TagDetailPageViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = IdentifierOption.cellType.tagDetailPage.identifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? TagDetailPageCellViewController else {
            return UITableViewCell()
        }
        cell.setTagDetailArticleCell(data: articles[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //-10:基本的にはcountパラメータで20個の記事を取得してくるように指定しているので、20-10=10の10個目のセル、つまり最初に表示された半分までスクロールされたら、追加で記事を読み込む(ページネーション)するようになっています。
        if articles.count >= 20 && indexPath.row == ( articles.count - 10) {
            checkNetwork()
            page += 1
            
            CommonApi.tagDetailPageRequest(completion: { data in
                if data.isEmpty {
                    self.presentNetworkErrorView()
                }
                data.forEach {
                    self.articles.append($0)
                }
                self.tagDetailArticle.reloadData()
            }, url: CommonApi.structUrl(option: .tagDetailPage(page: page, tagTitle: encodedTagName)))
        }
    }
}

extension TagDetailPageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC: QiitaArticlePageViewController = self.storyboard?.instantiateViewController(withIdentifier: "ArticlePage") as? QiitaArticlePageViewController else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        nextVC.articleUrl = articles[indexPath.row].url
        self.present(nextVC, animated: true, completion: nil)
    }
}

extension TagDetailPageViewController: ReloadActionDelegate {
    
    func errorReload() {
        guard let isConnected = NetworkReachabilityManager()?.isReachable else { return }
        if isConnected {
            CommonApi.tagDetailPageRequest(completion: { data in
                self.articles.removeAll()
                if data.isEmpty {
                    self.checkNetwork()
                } else {
                    self.errorView.removeFromSuperview()
                    data.forEach {
                        self.articles.append($0)
                    }
                    self.tagDetailArticle.reloadData()
                }
            }, url: CommonApi.structUrl(option: .tagDetailPage(page: page, tagTitle: encodedTagName)))
        }
    }
}

extension TagDetailPageViewController: PresentNetworkErrorViewDelegate {
    
    func presentNetworkErrorView() {
        errorView.center = self.view.center
        errorView.frame = self.view.frame
        self.view.addSubview(errorView)
    }
}
