//
//  TerraConnect.swift
//  Terra
//
//  Created by Elliott Yu on 23/09/2021.
//

import UIKit

class TerraConnect: UIButton{
    override func awakeFromNib() {
        super.awakeFromNib()
        let color = UIColor.black
        let disabledColor = color.withAlphaComponent(0.3)
         
        let gradientColor1 = UIColor(red: 10.0 / 255.0, green: 10.0 / 255.0, blue: 10.0 / 255.0, alpha: 1).cgColor
        let gradientColor2 = UIColor(red: 5.0 / 255.0, green: 5.0 / 255.0, blue: 5.0 / 255.0, alpha: 1).cgColor
         
        let btnFont = "Helvatica"
        let btnWidth = 200
        let btnHeight = 60
        
        self.frame.size = CGSize(width: btnWidth, height: btnHeight)
        self.frame.origin = CGPoint(x: (((superview?.frame.width)! / 2) - (self.frame.width / 2)), y: self.frame.origin.y)
        
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        self.layer.borderWidth = 3.0
        self.layer.borderColor = color.cgColor
        
        self.setTitleColor(color, for: .normal)
        self.setTitleColor(disabledColor, for: .disabled)
        self.titleLabel?.font = UIFont(name: btnFont, size: 25)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.setTitle(self.titleLabel?.text?.capitalized, for: .normal)
        
        let btnGradient = CAGradientLayer()
        btnGradient.frame = self.bounds
        btnGradient.colors = [gradientColor1, gradientColor2]
        self.layer.insertSublayer(btnGradient, at: 0)
        self.contentEdgeInsets.bottom = 4
        self.addTarget(self, action: #selector(onPress), for: .touchUpInside)

    }
    
    @objc func onPress(){
        print("Pressed")
    }

}
