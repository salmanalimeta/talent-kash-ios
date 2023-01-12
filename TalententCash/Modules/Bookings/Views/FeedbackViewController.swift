//
//  FeedbackViewController.swift
//  Talent Cash
//
//  Created by Zohaib Baig on 29/09/2022.
//

import UIKit
import Cosmos
import Alamofire

class FeedbackViewController: StatusBarController, UITextViewDelegate {
    
    @IBOutlet weak var textFieldView: UITextView!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var bookingId: String!
    var blurView: UIView!
    var feedback = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.isEnabled = false
        textFieldView.delegate = self
        if feedback {
            textFieldView.isUserInteractionEnabled = false
            rating.isUserInteractionEnabled = false
            submitBtn.isHidden = true
        }
        rating.didFinishTouchingCosmos = {stars in
            self.submitBtn.isEnabled = true
            switch stars{
            case 1,2 :
                self.ratingLabel.text = "Poor"
            case 3,4 :
                self.ratingLabel.text = "Fair"
            case 5 :
                self.ratingLabel.text = "Excellent"
            default:
                break
            }
            if stars < 1{
                self.submitBtn.setImage(UIImage(named: "SubmitUnselect"), for: .normal)
            } else {
                self.submitBtn.setImage(UIImage (named: "SubmitSelect"), for: .normal)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if feedback {
            viewFeedback()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func submitAct(_ sender: Any) {
        submitFeedback()
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor(named: "foreground")!
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
               textView.text = "Provide feedback here"
               textView.textColor = UIColor.lightGray
           }
    }
    func submitFeedback() {
        self.startPulseAnimation()
        NetworkUtil.request(dataType: SubmitFeedback.self, apiMethod: Constants.URL.submitFeedback, parameters: ["bookingId": bookingId ?? "", "rating": rating.rating], requestType: .post) { Feedback in
            self.stopPulseAnimation()
            if Feedback.status{
                NotificationCenter.default.post(name:NSNotification.Name("BOOKING_FEEDBACK_ADDED"),object: nil)
                let vc = self.getAlert(storyBoardID: "EmojiViewController") as! EmojiViewController
                vc.rating = Feedback.insertRec.rating
                vc.onBackToHome = {
                    self.dismiss(animated: false)
                }
                self.present(vc, animated: true)
            }else{
                self.showToast(message: Feedback.message, font: .boldSystemFont(ofSize: 16))
                
            }
        } onFailure: { _,error in
            self.stopPulseAnimation()
            self.showToast(message: error, font: .boldSystemFont(ofSize: 16))
            
        }
    }
    
    func viewFeedback() {
        self.startPulseAnimation()
        NetworkUtil.request(dataType: ViewFeedback.self, apiMethod: Constants.URL.viewFeedback, parameters: ["booking_id": bookingId ?? ""], requestType: .post) { viewFeedback in
            self.stopPulseAnimation()
            self.rating.rating = Double(viewFeedback.checkFeedback.rating)
            self.textFieldView.text = viewFeedback.checkFeedback.checkFeedbackDescription
        } onFailure: { _,error in
            self.showToast(message: error, font: .boldSystemFont(ofSize: 16))
        }
    }
}

