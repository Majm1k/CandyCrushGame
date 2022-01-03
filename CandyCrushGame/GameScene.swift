//
//  GameScene.swift
//  CandyCrushGame
//
//  Created by Дмитрий Рузайкин on 02.01.2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var candyTapped: SKSpriteNode!
    var touched: Bool!
    var matchedRow: [SKSpriteNode] = []
    var matchedCol: [SKSpriteNode] = []
    var matchedRow1: [SKSpriteNode] = []
    var matchedCol1: [SKSpriteNode] = []
    
    override func didMove(to view: SKView) {
     
        create_arrayCandy()
    }
    
    func create_arrayCandy(){
        let nameCandy: [String] = ["Blue","Green","Orange","Purple","Red","Yellow"]
        for i in stride(from: -self.size.width/2 + self.size.width/10/2, to: self.size.width/2, by: self.size.width/10){
            for j in stride(from: -400, to: self.size.width/2, by: self.size.width/10){
                let name = nameCandy.randomElement()!
                let candy = SKSpriteNode(texture: SKTexture(imageNamed: name))
                candy.name = name
                candy.position = CGPoint(x: i, y: j)
                addChild(candy)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        if let candy = nodes(at: location).first as? SKSpriteNode{
            candyTapped = candy
            touched = true
        }
    }
    
    func create_Candy(Matched: inout [SKSpriteNode]){
        if Matched.count >= 3{
            var points: [CGPoint] = []
            for candy in Matched{
                points.append(candy.position)
            }
            for candy in Matched{
                candy.removeFromParent()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {[self] in
                let nameCandy: [String] = ["Blue","Green","Orange","Purple","Red","Yellow"]
                for i in 0...points.count - 1{
                    let name = nameCandy.randomElement()!
                    if (nodes(at: points[i]).first as? SKSpriteNode) == nil{
                        let candy = SKSpriteNode(texture: SKTexture(imageNamed: name))
                        candy.name = name
                        candy.position = points[i]
                        addChild(candy)
                    }
                }
            }
        }
    }
    
    func create_Move(FromNode: SKSpriteNode, ToNode: SKSpriteNode){
        let pos1 = FromNode.position
        let pos2 = ToNode.position
        let move1 = SKAction.move(to: pos2, duration: 0.15)
        let move2 = SKAction.move(to: pos1, duration: 0.15)
        let check1 = SKAction.run { [self] in
            matchedRow.removeAll()
            matchedCol.removeAll()
            check(candy: FromNode, x: self.size.width/10, y: 0, candyMatched: &matchedRow)
            check(candy: FromNode, x: 0, y: self.size.width/10, candyMatched: &matchedCol)
            create_Candy(Matched: &matchedRow)
            create_Candy(Matched: &matchedCol)
        }
        
        let check2 = SKAction.run { [self] in
            matchedRow1.removeAll()
            matchedCol1.removeAll()
            check(candy: FromNode, x: self.size.width/10, y: 0, candyMatched: &matchedRow1)
            check(candy: FromNode, x: 0, y: self.size.width/10, candyMatched: &matchedCol1)
            create_Candy(Matched: &matchedRow1)
            create_Candy(Matched: &matchedCol1)
        }
        let sequence1 = SKAction.sequence([move1, check1])
        let sequence2 = SKAction.sequence([move2, check2])
        
        FromNode.run(sequence1)
        ToNode.run(sequence2)
    }
    
    func check(candy: SKSpriteNode, x:CGFloat, y:CGFloat, candyMatched: inout [SKSpriteNode]){
        if let candyTam = nodes(at: CGPoint(x: candy.position.x + x, y: candy.position.y + y)).first as? SKSpriteNode{
            if !candyMatched.contains(candyTam){
                if candyTam.name == candy.name{
                    candyMatched.append(candyTam)
                    check(candy: candyTam, x: x, y: y, candyMatched: &candyMatched)
                }
            }
        }
        
        if let candyTam = nodes(at: CGPoint(x: candy.position.x - x, y: candy.position.y - y)).first as? SKSpriteNode{
            if !candyMatched.contains(candyTam){
                if candyTam.name == candy.name{
                    candyMatched.append(candyTam)
                    check(candy: candyTam, x: x, y: y, candyMatched: &candyMatched)
                }
            }
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        if let candyMove = nodes(at: location).first as? SKSpriteNode{
            if candyTapped != candyMove && touched && (candyTapped.position.x == candyMove.position.x || candyTapped.position.y == candyMove.position.y){
                touched = false
                create_Move(FromNode: candyTapped, ToNode: candyMove)
            }
        }
    }
}
