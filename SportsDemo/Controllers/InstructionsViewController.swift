//
//  InstructionsViewController.swift
//  SportsDemo
//
//  Created by Nacho González Miró on 6/7/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import UIKit
import SwiftyOnboard

class InstructionsViewController: UIViewController {
    
    // MARK: Declare var SwiftyOnboard
    var swiftyOnboard: SwiftyOnboard!
    let colors:[UIColor] = [#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1),#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1),#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)]
    var titleArray: [String] = ["Welcome to SportsDemo App!", "Check the best sports players in the world", "Check only Golf Players", "Say something positive"]
    var subTitleArray: [String] = ["This app is an assesstment developed by Nacho González Miro", "This TOP Sport Players are organized in 4 sections: \n\n  Football, \n  Tennis, \n  Golf \n  Formula1", "In this section you can search a particular Golf Player", "I spend all the weekend doing this, give me a good feedback!"]
    
    var gradiant: CAGradientLayer = {
        //Gradiant for the background view
        let blue = UIColor(red: 69/255, green: 127/255, blue: 202/255, alpha: 1.0).cgColor
        let purple = UIColor(red: 166/255, green: 172/255, blue: 236/255, alpha: 1.0).cgColor
        let gradiant = CAGradientLayer()
        gradiant.colors = [purple, blue]
        gradiant.startPoint = CGPoint(x: 0.5, y: 0.18)
        return gradiant
    }()
    
    // MARK: - Display LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradient()
        configSwiftyOnboard()
    }
    
    func configSwiftyOnboard() {
        swiftyOnboard = SwiftyOnboard(frame: view.frame, style: .light)
        view.addSubview(swiftyOnboard)
        swiftyOnboard.dataSource = self
        swiftyOnboard.delegate = self
    }
    
    func gradient() {
        //Add the gradiant to the view:
        self.gradiant.frame = view.bounds
        view.layer.addSublayer(gradiant)
    }
    
    @objc func handleSkip() {
        swiftyOnboard?.goToPage(index: 3, animated: true)
    }
    
    @objc func handleContinue(sender: UIButton) {
        let index = sender.tag
        swiftyOnboard?.goToPage(index: index + 1, animated: true)
    }
}

// MARK: - Extension SwiftyOnboard
extension InstructionsViewController: SwiftyOnboardDelegate, SwiftyOnboardDataSource {
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return 4
    }
    
    func swiftyOnboardBackgroundColorFor(_ swiftyOnboard: SwiftyOnboard, atIndex index: Int) -> UIColor? {
        return colors[index]
    }
    
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        let view = SwiftyOnboardPage()
        view.imageView.image = UIImage(named: "space\(index)")
        view.title.font = UIFont(name: "Lato-Heavy", size: 22)
        view.subTitle.font = UIFont(name: "Lato-Regular", size: 16)
        view.title.text = titleArray[index]
        view.subTitle.text = subTitleArray[index]
        return view
    }
    
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        let overlay = SwiftyOnboardOverlay()
        //Setup targets for the buttons on the overlay view:
        overlay.skipButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        overlay.continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        //Setup for the overlay buttons:
        overlay.continueButton.titleLabel?.font = UIFont(name: "Lato-Bold", size: 16)
        overlay.continueButton.setTitleColor(UIColor.white, for: .normal)
        overlay.skipButton.setTitleColor(UIColor.white, for: .normal)
        overlay.skipButton.titleLabel?.font = UIFont(name: "Lato-Heavy", size: 16)
        return overlay
    }
    
    @objc func vc () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "main")
        present(vc, animated: true, completion: nil)
    }
    
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
        let currentPage = round(position)
        overlay.continueButton.tag = Int(position)
        
        if currentPage == 0.0 || currentPage == 1.0 || currentPage == 2.0 {
            overlay.continueButton.setTitle("Continue", for: .normal)
            overlay.skipButton.setTitle("Skip", for: .normal)
            overlay.skipButton.isHidden = false
        } else {
            overlay.continueButton.setTitle("Get Started!", for: .normal)
            overlay.skipButton.isHidden = true
            overlay.continueButton.addTarget(self, action: #selector(vc), for: .touchUpInside)
        }
    }
}
