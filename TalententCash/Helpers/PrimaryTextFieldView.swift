//
//  JobSummaryView.swift
//  Loadxuser
//
//  Created by Zohaib Baig on 05/12/2021.
//

import UIKit
import Reusable

class PrimaryTextFieldView: UIView, NibOwnerLoadable {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var fieldButton: UIButton!
    
    public var setTitle : String = "" {
        didSet {
            title.text = setTitle
        }
    }
    
    public var setTextInput : String = "" {
        didSet {
            textInput.placeholder = setTextInput
            textInput.textColor = .white
        }
    }
    
    var buttonCallBack: (() -> Void)?
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
        customizeUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
        customizeUI()
    }
    
    private func customizeUI() {
        self.backgroundColor = .clear
        self.textInput.textColor = .white
    }
    
}
