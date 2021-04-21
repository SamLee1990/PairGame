//
//  PlayViewController.swift
//  PairGame
//
//  Created by 李世文 on 2021/4/9.
//

import UIKit

class PlayViewController: UIViewController {
    
    @IBOutlet weak var flipsLabel: UILabel!
    @IBOutlet weak var timesLabel: UILabel!
    @IBOutlet var cardButtonCollection: [UIButton]!
    
    var cards = [Card]()//所有卡片
    var flippedCards = [Int]()//翻開的卡片
    var pairNumber = 0
    //翻牌次數
    var flips = 0{
        didSet{
            flipsLabel.text = flips.description
        }
    }
    //遊戲時間
    var gameTime = 50{
        didSet{
            timesLabel.text = gameTime.description
        }
    }
    
    var timer = Timer()//計時器
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //設定圖案維持比例以及backgroundColor設定
        for i in cardButtonCollection {
            i.imageView?.contentMode = .scaleAspectFit
            i.backgroundColor = UIColor.systemTeal
        }
        //設定卡片圖案
        cards = [
            Card(id: 0, imageStr: "cat"),
            Card(id: 1, imageStr: "dog"),
            Card(id: 2, imageStr: "fox"),
            Card(id: 3, imageStr: "lion"),
            Card(id: 4, imageStr: "owl"),
            Card(id: 5, imageStr: "pig"),
        ]
        cards += cards
        cards.shuffle()
        
        setTimer()
    }
    
    //遊戲初始化
    func gameInit() {
        cards.shuffle()
        flippedCards.removeAll()
        pairNumber = 0
        flips = 0
        gameTime = 50
        
        for (index,_) in cards.enumerated() {
            cards[index].flipped = false
            cardButtonCollection[index].backgroundColor = UIColor.systemTeal
            cardButtonCollection[index].setImage(UIImage(named: "pet"), for: .normal)
            cardButtonCollection[index].layer.opacity = 1
            UIView.transition(with: cardButtonCollection[index], duration: 0.3, options: .transitionFlipFromTop, animations: nil, completion: nil)
        }
        
        setTimer()
    }
    
    //開始計時
    func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
    }
    
    //遊戲時間倒數
    @objc func countDown(){
        gameTime -= 1
        if gameTime == 0 {
            timer.invalidate()//停止timer
            messageAlert()
        }
    }
    
    //彈出訊息
    func messageAlert() {
        var controller = UIAlertController()
        let playAgainAction = UIAlertAction(title: "再次挑戰", style: .default) { (_) in
            self.gameInit()
        }
        let backHomeAction = UIAlertAction(title: "重新選擇難度", style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        if gameTime != 0 {
            controller = UIAlertController(title: "挑戰成功！", message: "請繼續挑戰更高的難度～", preferredStyle: .alert)
        }else{
            controller = UIAlertController(title: "失敗！", message: "超過時間囉～", preferredStyle: .alert)
        }
        controller.addAction(playAgainAction)
        controller.addAction(backHomeAction)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func flipCard(_ sender: UIButton) {
        guard flippedCards.count != 2 else {
            return
        }
        //取得當前button的index
        let buttonNumber = cardButtonCollection.firstIndex(of: sender)!
        //翻牌
        if cards[buttonNumber].flipped == false {
            cards[buttonNumber].flipped = true
            sender.setImage(UIImage(named: cards[buttonNumber].imageStr), for: .normal)
            sender.backgroundColor = UIColor.systemIndigo
            UIView.transition(with: sender, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            //加入比對陣列
            flippedCards.append(buttonNumber)
            flips += 1
            flipsLabel.text = flips.description
        }
        //翻開兩張卡片時，開始做比對
        if flippedCards.count == 2 {
            let cardNumber1 = flippedCards[0]
            let cardNumber2 = flippedCards[1]
            if cards[cardNumber1].id != cards[cardNumber2].id {//若不同
                //0.5秒後翻回去
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { [self] in
                    for i in flippedCards{
                        cardButtonCollection[i].setImage(UIImage(named: "pet"), for: .normal)
                        cardButtonCollection[i].backgroundColor = UIColor.systemTeal
                        UIView.transition(with: cardButtonCollection[i], duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
                        cards[i].flipped = false
                    }
                    flippedCards.removeAll()
                }
            }else{//若相同
                //0.4後消失
                DispatchQueue.main.asyncAfter(deadline: .now()+0.4) { [self] in
                    for i in flippedCards{
                        cardButtonCollection[i].layer.opacity = 0
                        UIView.transition(with: cardButtonCollection[i], duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
                    }
                    flippedCards.removeAll()
                    pairNumber += 1
                    if pairNumber == cards.count / 2{
                        timer.invalidate()
                        messageAlert()
                    }
                }
            }
        }
    }
    
    @IBAction func doReStart(_ sender: UIButton) {
        timer.invalidate()
        let controller = UIAlertController(title: "重新開始", message: "結束本局遊戲", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.gameInit()
        }
        let continueAction = UIAlertAction(title: "繼續遊戲", style: .default) { (_) in
            self.setTimer()
            
        }
        controller.addAction(okAction)
        controller.addAction(continueAction)
        present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func doClose(_ sender: UIButton) {
        timer.invalidate()
        let controller = UIAlertController(title: "即將結束遊戲", message: "返回主畫面", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        let continueAction = UIAlertAction(title: "繼續遊戲", style: .cancel) { (_) in
            self.setTimer()
        }
        controller.addAction(okAction)
        controller.addAction(continueAction)
        present(controller, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
