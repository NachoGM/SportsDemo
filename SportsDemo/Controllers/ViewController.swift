//
//  ViewController.swift
//  SportsDemo
//
//  Created by Nacho González Miró on 5/7/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import Kingfisher


class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var sections = [Section]()
    var detailed = [Detailed]()

    // MARK: - Display LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initJSON()
        initTableViewMethods()
        loadXibCells()
        loadFooterView()
    }
    
    //  Configure TableView Methods
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

    // MARK: - Display JSON Methods
    func initJSON() {
        if Connectivity.isConnectedToInternet {
            SVProgressHUD.show(withStatus: "Loading content")
            Alamofire.request(URL_SPORTS, method: .get).responseData { response in
                switch response.response?.statusCode {
                case 200:
                    let jsonData = JSON(response.result.value!)
                    self.parseJSON(jsonData: jsonData)
                default:
                    NSLog(" Error in getCreatorsJSON")
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
                let type = jsonDict.value(forKey: "type") as! String
                let players = jsonDict.value(forKey: "players") as! NSArray
                let namePlayersArray = players.value(forKey: "name") as! NSArray
                let surnamePlayersArray = players.value(forKey: "surname") as! NSArray
                let imagePlayersArray = players.value(forKey: "image") as! NSArray
                let datePlayersArray = players.value(forKey: "date") as! NSArray

                let sectionObject = Section(titleSection: title, type: type, players: players, name: namePlayersArray, surname: surnamePlayersArray, image: imagePlayersArray, date: datePlayersArray)
                self.sections.append(sectionObject)
            }
        } else {
            NSLog(" Error in parseJSON")
        }
        tableView.reloadData()
    }
}

// MARK: - Extension TableView DataSource Methods
extension ViewController: UITableViewDataSource {
    enum Sections: Int {
        case Golf = 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let surname = sections[indexPath.section].surname[indexPath.row] as! String
        let name = sections[indexPath.section].name[indexPath.row] as! String
        let thumbnailStringArray: [String] = sections[indexPath.section].image as! [String]
        return configCell(name: name, surname: surname, thumbnail: thumbnailStringArray, indexPath: indexPath)
    }
    
    // MARK:  Configure Cells
    func configCell(name: String, surname: String, thumbnail: [String], indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "sportsCell") as! SportsCell
        cell.nameLabel.text = name
        cell.surnameLabel.text = surname
        cell.dateLabel.text = handleDateTextInCells(indexPath: indexPath)
        let resource = ImageResource(downloadURL: URL(string: thumbnail[indexPath.row])!, cacheKey: thumbnail[indexPath.row])
        cell.playerImage.kf.setImage(with: resource)
        return cell
    }
    
    func handleDateTextInCells(indexPath: IndexPath) -> String {
        var dateString = String()
        let date = sections[2].date[indexPath.row] as! String
        if indexPath.section == 2 {
            dateString = date
        } else {
            dateString = ""
        }
        return dateString
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
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sendInfoToDetailedVC(indexPath: indexPath)
    }
    
    // MARK:  Handle Info sended to Detailed VC
    func sendInfoToDetailedVC(indexPath: IndexPath) {
        let section = sections[indexPath.section].title
        let surname = sections[indexPath.section].surname[indexPath.row] as! String
        let name = sections[indexPath.section].name[indexPath.row] as! String
        let thumbnailStringArray: [String] = sections[indexPath.section].image as! [String]
        let resource = ImageResource(downloadURL: URL(string: thumbnailStringArray[indexPath.row])!, cacheKey: thumbnailStringArray[indexPath.row])
        let date = handleDateTextInCells(indexPath: indexPath)
        let detailedObject = Detailed(section: section ?? "", name: name, surname: surname, date: date, imageResource: resource)

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailed") as! DetailedViewController
        vc.detailed = detailedObject
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return setSectionsCellHeight()
    }
    
    // MARK:  Configure Sections Height
    func setSectionsCellHeight() -> CGFloat {
        let quarterView = self.view.frame.size.height / 4
        return quarterView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CustomHeaderView()
        header.customInit(title: sections[section].title, section: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        let headerImage = UIImage(named: imageHeaderArray[section])
        let headerImageView = UIImageView(image: headerImage)
        header.backgroundView = headerImageView
    }
}
