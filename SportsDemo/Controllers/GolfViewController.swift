//
//  FootballViewController.swift
//  SportsDemo
//
//  Created by Nacho González Miró on 6/7/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import SVProgressHUD
import Kingfisher
import Speech

class GolfViewController: UIViewController {

    // MARK:  Declare Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var microphoneButton: UIButton!
    
    // MARK:  Declare Object variables
    var golfPlayer = [Player]()
    var filterGolfPlayer = [Player]()
    var detailed = [Detailed]()
    
    var buttonSound : AVAudioPlayer?

    
    // MARK:  Declare Speech variables
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    // MARK: - Display lifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        initGolfJSON()
        initMicrophoneButton()
        initSpeechDelegateMethods()
        setSpeechAuthorization()
        initSearchBarDelegate()
        initTableViewMethods()
        loadXibCells()
        loadFooterView()
        alterLayout()
    }
    
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GolfViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
        navigationItem.titleView = searchBar
        searchBar.showsScopeBar = false
        searchBar.placeholder = "Search Golf Player"
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
    
    // MARK: - Configure Speech methods
    func initMicrophoneButton() {
        microphoneButton.isEnabled = false
    }
    
    func initSpeechDelegateMethods() {
        speechRecognizer.delegate = self
    }
    
    func setSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    // MARK: - Display Button Button Action
    @IBAction func speechSearcherButtonTapped(_ sender: Any) {
        playSound()
        setVibration()
        handleAudioEngine()
    }
    
    // MARK:  Display Button Methods
    func playSound() {
        let path = Bundle.main.path(forResource: "buttonClicked", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            buttonSound = try AVAudioPlayer(contentsOf: url)
            buttonSound?.prepareToPlay()
            buttonSound?.play()
            
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func setVibration() {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
    
    func handleAudioEngine() {
        if audioEngine.isRunning {
            stopRecording(recognitionRequest: recognitionRequest!)
        } else {
            startRecording()
        }
    }
    
    // MARK:  Handle Audio Engine Methods
    func startRecording() {
        microphoneButton.setTitle("Stop Recording", for: .normal)
        checkRecognitionTask()
        prepareAudioRecording()
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        // Report partial results of speech recognition as user speaks
        recognitionRequest.shouldReportPartialResults = true
        starSpeechRecognition(recognitionRequest: recognitionRequest, inputNode: inputNode)
        
        // Note that it is ok to add the audio input after starting the recognitionTask
        addAudioInput(inputNode: inputNode)
        startAudioEngine()
    }
    
    func stopRecording(recognitionRequest: SFSpeechAudioBufferRecognitionRequest) {
        self.audioEngine.stop()
        recognitionRequest.endAudio()
        self.microphoneButton.setTitle("Start Recording", for: .normal)
    }
    
    // MARK:  Start recording methods
    func checkRecognitionTask() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
    }
    
    func prepareAudioRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
    }
    
    func starSpeechRecognition(recognitionRequest: SFSpeechAudioBufferRecognitionRequest, inputNode: AVAudioInputNode) {
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            var isInList = Bool()

            if result != nil {
                if (result?.bestTranscription.formattedString.count)! > 6 {
                    self.searchBar.text = result?.bestTranscription.formattedString
                    isFinal = (result?.isFinal)!
                    
                    let resultString = result?.bestTranscription.formattedString ?? ""
                    
                    guard !resultString.isEmpty else {
                        self.golfPlayer = self.filterGolfPlayer
                        self.filterGolfPlayer.removeAll()
                        self.golfPlayer.removeAll()
                        self.stopRecording(recognitionRequest: recognitionRequest)
                        self.initGolfJSON()
                        return
                    }
                    
                    self.golfPlayer = self.golfPlayer.filter({ (player) -> Bool in
                        isInList = false

                        let dict = player.players
                        let name = dict?.value(forKey: "name") as! String
                        let surname = dict?.value(forKey: "surname") as! String
                        
                        if name + " " + surname == resultString {
                            self.stopRecording(recognitionRequest: recognitionRequest)
                            isInList = true
                        }
                        return isInList
                    })
                    self.tableView.reloadData()
                }
            }
            
            if error != nil || isFinal {
                self.stopAudioEngine(inputNode: inputNode, recognitionRequest: recognitionRequest)
            }
        })
    }
    
    func addAudioInput(inputNode: AVAudioInputNode) {
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
    }
    
    func startAudioEngine() {
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        if self.searchBar.text!.isEmpty {
            searchBar.placeholder = "Search Golf Player"
        } else {
            searchBar.text = "Say something, I'm listening!"
        }
    }
    
    func stopAudioEngine(inputNode: AVAudioInputNode, recognitionRequest: SFSpeechAudioBufferRecognitionRequest) {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        self.recognitionRequest = nil
        self.recognitionTask = nil
        self.stopRecording(recognitionRequest: recognitionRequest)
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
        tableView.deselectRow(at: indexPath, animated: true)
        
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
            golfPlayer.removeAll()
            initGolfJSON()
            searchBar.resignFirstResponder()
            return
        }
        
        if searchText.count > 3 {
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
        }
    }
}

extension GolfViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
}
