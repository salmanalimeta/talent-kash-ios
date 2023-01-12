//
//  InvoiceViewController.swift
//  Talent Cash
//
//  Created by Iqra Fahad on 27/09/2022.
//

import UIKit
import Foundation
import Alamofire
import QuickLook

class InvoiceViewController: StatusBarController {

    @IBOutlet weak var invDetail: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var invoiceDate: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var paidByInvoice: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var paidToInvoice: UILabel!
    @IBOutlet weak var paidToUser: UILabel!
    @IBOutlet weak var PaidToName: UILabel!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var paidAmount: UILabel!
    
    @IBOutlet weak var scrollInvoiceView: UIScrollView!
    var bookingId:String!
    private var invoicePDF:URL? = nil
    private var isInvoiceLoaded = false
//    var invoiceDataSource : InvoiceModel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isInvoiceLoaded{
            invoiceDetails()
        }
    }
    
    func invoiceDetails() {
        self.startPulseAnimation()
        NetworkUtil.request(dataType: InvoiceModel.self, apiMethod: Constants.URL.invoice+bookingId, parameters: nil, requestType: .get) { invoiceData in
            self.stopPulseAnimation()
            if invoiceData.status{
                guard let data = invoiceData.userCompleteBookingInvoice.first else {
                    return
                }
                self.isInvoiceLoaded = true
                self.invDetail.text = data.invoice_id
                self.orderIdLabel.text = data.invoice_id
                self.invoiceDate.text = data.pay_datetime
                self.paidByInvoice.text = data.userId.user_id
                self.userName.text = data.userId.name
                self.name.text = data.userId.name
                self.paidToInvoice.text = data.talentUserId.user_id
                self.paidToUser.text = data.talentUserId.name
                self.PaidToName.text = data.talentUserId.username
                self.serviceName.text = data.bookingId.service
                self.paidAmount.text = "\(data.amount) PKR"
            }else{
                self.showToast(message: invoiceData.message, font: .systemFont(ofSize: 16))
            }
        } onFailure: { _,msg in
            self.stopPulseAnimation()
            self.showToast(message: msg, font: .systemFont(ofSize: 16))
        }

    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func downloadPDF(_ sender: Any) {
     createPdfFromView()
    }
    func createPdfFromView()
    {
        // Set frame as per content of view
        guard let v = self.scrollInvoiceView.subviews.first else {
            return
        }
        v.backgroundColor = UIColor(named: "background") ?? .black
        let pdfPageBounds: CGRect = .init(origin:.zero , size:.init(width:  v.frame.width, height:  v.frame.height))
        let pdfData: NSMutableData = NSMutableData()

        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
        v.layer.render(in: UIGraphicsGetCurrentContext()!)
        UIGraphicsEndPDFContext()
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("receipt_\(bookingId ?? "").pdf")
        
        pdfData.write(toFile:path.path, atomically: true)
 
        self.invoicePDF = path
        let vc = QLPreviewController()
        vc.dataSource = self
        present(vc, animated: true)
    }
}
extension InvoiceViewController :QLPreviewControllerDataSource{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        invoicePDF! as QLPreviewItem
    }
}
