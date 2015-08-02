//
//  ViewController.swift
//  CardScanner
//
//  Created by 游义男 on 15/8/3.
//  Copyright (c) 2015年 游义男. All rights reserved.
//

import UIKit

class ViewController: UIViewController,CardIOPaymentViewControllerDelegate{

    @IBOutlet weak var labelResult: UILabel!
    @IBAction func startScan(sender: UIButton) {
        var Cardvc = CardIOPaymentViewController(paymentDelegate: self)
        Cardvc.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        
        presentViewController(Cardvc, animated: true, completion: nil)
    }
    
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        labelResult.text = "您取消了扫描。"
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        if let card = cardInfo {
            labelResult.text = "卡号:\(card.cardNumber)" + "\n" + "过期年月:\(card.expiryYear)年\(card.expiryMonth)月" + "\n" + "CVV:\(card.cvv)"
        }
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

