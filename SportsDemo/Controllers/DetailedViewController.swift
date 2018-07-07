//
//  DetailedViewController.swift
//  SportsDemo
//
//  Created by Nacho González Miró on 6/7/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import UIKit
import Kingfisher
import SVProgressHUD

class DetailedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var detailed: Detailed!
    
    // MARK: - Load TableView Methods in LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initTableViewMethods()
        loadXibCells()
    }
    
    func initTableViewMethods() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    func loadXibCells() {
        tableView.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "image")
        tableView.register(UINib(nibName: "InfoCell", bundle: nil), forCellReuseIdentifier: "info")
    }
}

// MARK: - Extension TableView DataSource Methods
extension DetailedViewController: UITableViewDataSource {
    enum Position {
        case Thumbnail
        case Info
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == Position.Thumbnail.hashValue {
            return configImageCell(resource: detailed.imageResource)
        } else if indexPath.row == Position.Info.hashValue {
            return configInfoCell(title: detailed.section, name: detailed.name, surname: detailed.surname, date: detailed.date)
        } else {
            NSLog(" Error in cellForRowAt")
            return configInfoCell(title: "", name: "", surname: "", date: "")
        }
    }

    // MARK:  Configure Custom Cells
    func configImageCell(resource: ImageResource) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "image") as! ImageCell
        cell.playerImage.kf.setImage(with: resource)
        SVProgressHUD.dismiss()
        return cell
    }
    
    func configInfoCell(title: String, name: String, surname: String, date: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "info") as! InfoCell
        cell.titleSectionLabel.text = title
        cell.nameAndSurnameLabel.text = name + " " + surname
        cell.dateLabel.text = date
        return cell
    }
}

// MARK: - Extension TableView Delegate Methods
extension DetailedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == Position.Thumbnail.hashValue {
            return configHeightForThumbnailCell()
        } else if indexPath.row == Position.Info.hashValue {
            return configHeightForInfoCell()
        } else {
            NSLog(" Error in heightForRowAt")
            return configHeightForInfoCell()
        }
    }
    
    // MARK:  Handle Custom Cells Height
    func configHeightForThumbnailCell() -> CGFloat {
        let screenHeight = self.view.frame.size.height
        let quarterView = self.view.frame.size.height / 4
        return screenHeight - quarterView
    }
    
    func configHeightForInfoCell() -> CGFloat {
        let quarterPartOfView = self.view.frame.size.height / 4
        let navigationBarSize = self.navigationController?.navigationBar.frame.height
        return quarterPartOfView - navigationBarSize!
    }
}
