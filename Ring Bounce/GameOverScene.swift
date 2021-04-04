//
//  GameOverScene.swift
//  Ring Bounce
//
//  Created by Eric Pu Jing on 1/7/17.
//  Copyright © 2017 CPUcontrol. All rights reserved.
//

import Foundation
import SpriteKit
import GoogleMobileAds

class GameOverScene: SKScene {
    
    let button = SKShapeNode(rectOf: CGSize(width: 150, height: 40), cornerRadius: 3.0)
    
    var viewController: GameViewController!
    var bannerView: GADBannerView!
    init(size: CGSize, score: Int) {
        
        super.init(size: size)
        
        let defaults = UserDefaults.standard
        let storedScore: Int = defaults.object(forKey: "High Score")! as! Int
        
        backgroundColor = SKColor.white
        let message = "Game Over"

        let label = SKLabelNode(fontNamed: "Helvetica")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        if storedScore < score{
            defaults.set(score, forKey: "High Score")
            defaults.synchronize()
            
            let record = SKLabelNode(fontNamed: "Helvetica")
            record.text = "New High Score: " + score.description
            record.fontSize = 30
            record.fontColor = SKColor.black
            record.position = CGPoint(x: size.width/2, y: size.height/2 - 60)
            addChild(record)
        }
        else{
            let record = SKLabelNode(fontNamed: "Helvetica")
            record.text = "Score: " + score.description
            record.fontSize = 30
            record.fontColor = SKColor.black
            record.position = CGPoint(x: size.width/2, y: size.height/2 - 60)
            addChild(record)
        }

        let tryAgain = SKLabelNode(fontNamed: "Helvetica")
        tryAgain.text = "Play again"
        tryAgain.fontSize = 20
        tryAgain.fontColor = SKColor.black
        tryAgain.position = CGPoint(x: 0, y: -8)
        button.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        button.fillColor = UIColor(white: 0.8, alpha: 1.0)
        addChild(button)
        button.addChild(tryAgain)
    }
    
    override func didMove(to view: SKView) {
        if bannerView == nil {
            initializeBanner()
        }
        bannerView.isHidden = false
        loadRequest()
    }
    
    func initializeBanner() {
        // Create a banner ad and add it to the view hierarchy.
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = "ca-app-pub-4165247909639733/1869326200"
        bannerView.rootViewController = viewController
        view!.addSubview(bannerView)
    }
    
    func loadRequest() {
        let request = GADRequest()
        //request.testDevices = [kGADSimulatorID, "8161690b7f46f772a979613151fc76ce"]
        bannerView.load(request)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        if button.contains(touch.location(in: self)){
        
            let scene = GameScene(size: size)
            scene.scaleMode = .resizeFill
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            scene.viewController = self.viewController

            bannerView.isHidden = true
            
            self.view?.presentScene(scene)
        }
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
