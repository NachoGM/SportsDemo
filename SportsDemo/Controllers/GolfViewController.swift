//
//  FootballViewController.swift
//  SportsDemo
//
//  Created by Nacho González Miró on 6/7/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import Kingfisher

class GolfViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var golfPlayer = [Player]()
    var filterGolfPlayer = [Player]()
    var detailed = [Detailed]()
    
    // MARK: - Display lifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGolfJSON()
        initTableViewMethods()
        loadXibCells()
        loadFooterView()
        initSearchBarDelegate()
        alterLayout()
    }
    
    // MARK:  Init Search Bar Delegate
    func initSearchBarDelegate() {
        searchBar.delegate = self
    }
    
    // MARK:  Load TableView Configuration
    func initTableViewMethods() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func loadXibCells() {
        tableView.register(UINib(nibName: "SportsCell", bundle: nil), forCellReuseIdentifier: "sportsCell")
    }
    
    func loadFooterView() {
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func alterLayout() {
        // search bar in navigation bar
        //navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        navigationItem.titleView = searchBar
        searchBar.showsScopeBar = false
        searchBar.placeholder = "Search Golf Player"
        searchBar.backgroundColor = .green
    }
    
    // MARK: - Display JSON Methods
    func initGolfJSON() {
        if Connectivity.isConnectedToInternet {
            SVProgressHUD.show(withStatus: "Loading content")
            Alamofire.request(URL_SPORTS, method: .get).responseData { response in
                switch response.response?.statusCode {
                case 200:
                    let jsonData = JSON(response.result.value!)
                    self.parseJSON(jsonData: jsonData)
                default:
                    NSLog(" Error in initGolfJSON")
                }
                SVProgressHUD.dismiss()
            }
        } else {
            displayAlertMessage(userTitle: "Ups...", userMessage: "You don't have internet. \n Please connect to any Wi-fi and try it again. \n Thank you!")
            return
        }
    }
    
    func parseJSON(jsonData: JSON) {
        if let jsonObject = jsonData.arrayObject {
            for i in 0...jsonObject.count-1 {
                let jsonDict = jsonObject[i] as! NSDictionary
                let title = jsonDict.value(forKey: "title") as! String
                if title == "Golf" {
                    let playersArrayOfDicts = jsonDict.value(forKey: "players") as! [NSDictionary]
                    for dict in playersArrayOfDicts.enumerated() {
                        let playersObject = Player(players: dict.element, title: title)
                        self.golfPlayer.append(playersObject)
                    }
                    tableView.reloadData()
                    break
                }
            }
        } else {
            NSLog(" Error in parseJSON")
        }
    }

}

// MARK: - Extension TableView DataSource Methods
extension GolfViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filterGolfPlayer.isEmpty {
            return filterGolfPlayer.count
        } else {
            return golfPlayer.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var name = String()
        var surname = String()
        var date = String()
        var thumbnail = String()
        
        if !filterGolfPlayer.isEmpty {
            name = golfPlayer[indexPath.row].players["name"]! as! String
            surname = golfPlayer[indexPath.row].players["surname"]! as! String
            date = golfPlayer[indexPath.row].players["date"]! as! String
            thumbnail = golfPlayer[indexPath.row].players["image"]! as! String
        } else {
            name = golfPlayer[indexPath.row].players["name"]! as! String
            surname = golfPlayer[indexPath.row].players["surname"]! as! String
            date = golfPlayer[indexPath.row].players["date"]! as! String
            thumbnail = golfPlayer[indexPath.row].players["image"]! as! String
        }

        return configCell(name: name, surname: surname, date: date, thumbnail: thumbnail, indexPath: indexPath)
    }
    
    func configCell(name: String, surname: String, date: String, thumbnail: String, indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "sportsCell") as! SportsCell
        cell.nameLabel.text = name
        cell.surnameLabel.text = surname
        cell.dateLabel.text = date
        let resource = ImageResource(downloadURL: URL(string: thumbnail)!, cacheKey: thumbnail)
        cell.playerImage.kf.setImage(with: resource)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        initCellAnimation(cell: cell)
    }
    
    func initCellAnimation(cell: UITableViewCell) {
        cell.alpha = 0
        
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
        cell.layer.transform = rotationTransform
        
        UIView.animate(withDuration: 1.0) {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }
    }
}

// MARK: - Extension TableView Delegate Methods
extension GolfViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = golfPlayer[indexPath.row].title!
        let name = golfPlayer[indexPath.row].players["name"]! as? String
        let surname = golfPlayer[indexPath.row].players["surname"]! as? String
        let date = golfPlayer[indexPath.row].players["date"]! as? String
        let thumbnail = golfPlayer[indexPath.row].players["image"]! as? String
        let imageResource = ImageResource(downloadURL: URL(string: thumbnail!)!, cacheKey: thumbnail)
        
        let detailedObject = Detailed(section: section, name: name ?? "", surname: surname ?? "", date: date ?? "", imageResource: imageResource)
        sendToDetailedVC(detailedObject: detailedObject)
    }
    
    func sendToDetailedVC(detailedObject: Detailed) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailed") as! DetailedViewController
        vc.detailed = detailedObject
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK:  Configure Sections Heigh
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - Extension SearchBar Delegate Method
extension GolfViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var isInList = Bool()
        guard !searchText.isEmpty else {
            golfPlayer = filterGolfPlayer
            filterGolfPlayer.removeAll()
            initGolfJSON()
            return
        }
        
        if searchText.count > 4 {
            golfPlayer = golfPlayer.filter({ (player) -> Bool in
                let playerSearched = player.players["name"] as! String
                if playerSearched.contains(searchText) {
                    let searchedObject = Player(players: player.players!, title: player.title!)
                    self.filterGolfPlayer.append(searchedObject)
                    isInList = true
                }
                return isInList
            })
            self.tableView.reloadData()
        }
    }
}
