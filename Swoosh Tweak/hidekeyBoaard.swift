import Foundation
import UIKit

extension  UIViewController{
    func  hidekeyBoaard(){
        let tapgesture  = UITapGestureRecognizer(target: self, action: #selector(dimiskeyoard))
        tapgesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapgesture)
    }
    @objc private func dimiskeyoard (){
        view.endEditing(true)
    }
    func alertMeassge(message:String, title:String = "" ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okaction = UIAlertAction(title: "OK", style: .default, handler: nil)
        okaction.setValue(UIColor.black, forKeyPath: "titleTextColor")
        alert.addAction(okaction)
        self.present(alert, animated: true)
        
    }
    
}

extension UITextField{
    func shdows(cornerRadius:CGFloat = 0){
        self.layer.shadowColor = UIColor.green.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 1.4, height: 2.1)
        self.layer.shadowOpacity = 4
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth  =  0.4
    }
    
}
