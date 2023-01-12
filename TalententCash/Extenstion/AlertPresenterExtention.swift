//
//  AlertPresenterExtention.swift
//  Talent Cash
//
//  Created by MacBook Pro on 27/09/2022.
//

import UIKit

extension UIViewController{
    
    func getAlert(storyBoardID:String)->UIViewController{
        guard let alertController:UIViewController = self.storyboard?.instantiateViewController(withIdentifier: storyBoardID) else{
            return UIAlertController()
        }
        alertController.providesPresentationContextTransitionStyle = true
        alertController.definesPresentationContext = true
        alertController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        return alertController
    }
    func showAlert(storyBoardID:String){
        present(self.getAlert(storyBoardID: storyBoardID), animated: true)
    }
}

