//
//  GameScene.swift
//  Nearly Nuked
//
//  Created by Joel Goncalves on 6/9/15.
//  Copyright (c) 2015 EyeGame. All rights reserved.
//

import SpriteKit
import Foundation

var hero : JGHero!
var nukeGenerator: JGNukeGenerator!
var ground : SKSpriteNode!


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ground : SKSpriteNode!
    var ninjaRun : SKAction!
    
    var isStarted : Bool = false
    var isGameOver : Bool = false
    
    override func didMoveToView(view: SKView)
    {
        addBackground()
        addGround()
        addHero()
        addNukeGenerator()
        addTapToStartLabel()
        addPointsLabel()
        addPhysicsWorld()
        loadScore()
        
    }
    
    func addHero()
    {
        //add hero & movement
        hero = JGHero()
        hero.position = CGPointMake(80,ground.position.y + ground.frame.size.height/2 + hero.frame.size.height/2)
        addChild(hero)
    }
    
    func addBackground()
    {
        //self.backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 1.0)
        
        //add background
        let background = SKSpriteNode(imageNamed: "Full-background.png")
        addChild(background)
        
    }
    
    func addNukeGenerator()
    {
        //add nuke generator
        nukeGenerator = JGNukeGenerator(color: UIColor.clearColor(), size: view!.frame.size)
        nukeGenerator.position = view!.center
        addChild(nukeGenerator)
    }
    
    func addGround()
    {
        //add ground
        ground = SKSpriteNode(imageNamed: "ground.png")
        //ground = SKSpriteNode(texture: nil, color: UIColor.blueColor(), size: CGSizeMake(self.frame.size.width, 50))
        var wSpacing = ground.size.width / 2
        var hSpacing = ground.size.height / 2
        ground.position = CGPointMake(0, -self.frame.size.height/2 + ground.frame.size.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.dynamic = false;
        addChild(ground)
    }
    
    func addTapToStartLabel()
    {
        // add start label
        let tapToStartLabel = SKLabelNode(text: "Tap to start!")
        tapToStartLabel.name = "tapToStartLabel"
        //tapToStartLabel.position = view.center
        tapToStartLabel.fontName = "Helvetica"
        tapToStartLabel.fontColor = UIColor.blackColor()
        addChild(tapToStartLabel)
        tapToStartLabel.runAction(blinkAnimation())
    }
    
    func addPointsLabel()
    {
        let pointsLabel = JGPointsLabel(num: 0)
        pointsLabel.position = CGPointMake(-(view!.frame.size.width/2 - 20), view!.frame.size.height/2 - 35)
        pointsLabel.name = "pointsLabel";
        addChild(pointsLabel)
        
        let highscoreLabel = JGPointsLabel(num: 0);
        highscoreLabel.name = "highscoreLabel"
        highscoreLabel.position = CGPointMake(view!.frame.size.width/2 - 20,
            view!.frame.size.height/2 - 35)
        addChild(highscoreLabel)
        
        let highscoreTextLabel = SKLabelNode(text: "High")
        highscoreTextLabel.fontColor = UIColor.blackColor()
        highscoreTextLabel.fontSize = 18.0
        highscoreTextLabel.fontName = "Helvetica"
        highscoreTextLabel.position = CGPointMake(0, -20)
        highscoreLabel.addChild(highscoreTextLabel)
    }
    
    func addPhysicsWorld()
    {
        self.anchorPoint = CGPointMake(0.5, 0.5)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = sceneCategory
        // add physics world
        physicsWorld.contactDelegate = self
    }
    
    func loadScore()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let highscoreLabel = childNodeWithName("highscoreLabel") as! JGPointsLabel
        highscoreLabel.setScore(defaults.integerForKey("highscore")) //grab high saved scared
    }
    
    func start()
    {
        let tapToStartLabel = childNodeWithName("tapToStartLabel")
        tapToStartLabel?.removeFromParent()
        self.isStarted = true
        hero.start()
        nukeGenerator.startGeneratingNukeEvery(1)
    }
    
    func gameOver()
    {
        isGameOver = true
        
        //stop everything
        //hero.fall()
        nukeGenerator.stopNukes()
        hero.ninjaMoveEnded()
        hero.dead()
        
        // create game over label
        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontColor = UIColor.blackColor()
        gameOverLabel.fontName = "Helvetica"
        addChild(gameOverLabel)
        gameOverLabel.runAction(blinkAnimation())
        
        // Save highscore
        let pointsLabel = childNodeWithName("pointsLabel") as! JGPointsLabel
        let highscoreLabel = childNodeWithName("highscoreLabel") as! JGPointsLabel
        
        if highscoreLabel.number < pointsLabel.number
        {
            highscoreLabel.setScore(pointsLabel.number)
            
            // Save info
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(highscoreLabel.number, forKey: "highscore")
        }
    }
    
    func restart() {
        let newScene = GameScene(size: view!.bounds.size)
        newScene.scaleMode = .AspectFill
        
        view!.presentScene(newScene)
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        if isGameOver{
            restart()
        }
        
        if (!isStarted){
            self.start()
        }else{
            hero.start()
        }
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        //Choose one of the touches to work with
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if nukeGenerator.nukeTracker.count > 0{
            let nuke = nukeGenerator.nukeTracker[0] as JGNuke
            
            let nukeLocation = nukeGenerator.convertPoint(nuke.position, toNode: self)
            
            if nukeLocation.y < hero.position.y
            {
                nukeGenerator.nukeTracker.removeAtIndex(0)
                let pointsLabel = childNodeWithName("pointsLabel") as! JGPointsLabel
                pointsLabel.increment()
            }
        }
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBeginContact(contact: SKPhysicsContact) {
        let dead = SKTexture(imageNamed: "dead.png")
        if !isGameOver{
            gameOver()
            println("Did begin contact")
        }
    }
    
    //MARK: - Animations
    func blinkAnimation() -> SKAction
    {
        let duration = 0.4
        let fadeOut = SKAction.fadeAlphaTo(0.0, duration: duration)
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: duration)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        return SKAction.repeatActionForever(blink)
    }
}
