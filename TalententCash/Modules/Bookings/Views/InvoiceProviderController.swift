//
//  InvoiceProviderController.swift
//  Talent Cash
//
//  Created by MacBook Pro on 29/09/2022.
//

import UIKit
import Alamofire
import QuickLook

class InvoiceProviderController: StatusBarController {

    @IBOutlet weak var receivedAmoundLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var paidToInvoice: UILabel!
    @IBOutlet weak var paidByInvoice: UILabel!
    @IBOutlet weak var namePaidToLabel: UILabel!
    @IBOutlet weak var usernamePaidToLabel: UILabel!
    @IBOutlet weak var namePaidByLabel: UILabel!
    @IBOutlet weak var usernamepaidBy: UILabel!
    @IBOutlet weak var invoiceData: UILabel!
    @IBOutlet weak var orderNumber: UILabel!
    @IBOutlet weak var invoiceNumber: UILabel!
    @IBOutlet weak var scrollInvoiceView: UIScrollView!
   
    var bookId = ""
    var invoiceDataSource : TalentCompleteBookingInvoice!
    private var invoicePDF:URL? = nil
    private var isInvoiceLoaded = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isInvoiceLoaded{
            loadInvoiceData()
        }
    }
    private func setInvoiceData(invoiceDataSource : TalentCompleteBookingInvoice){
        self.orderNumber.text = invoiceDataSource.invoice_id
        self.paidByInvoice.text = invoiceDataSource.userId.user_id
        self.paidToInvoice.text = invoiceDataSource.talentUserId.user_id
        self.orderNumber.text = invoiceDataSource.invoice_id
        self.usernamepaidBy.text = invoiceDataSource.userId.username
        self.namePaidByLabel.text = invoiceDataSource.userId.name
        self.usernamePaidToLabel.text = invoiceDataSource.talentUserId.name
        self.namePaidToLabel.text = invoiceDataSource.talentUserId.name
        self.serviceNameLabel.text = invoiceDataSource.bookingId.service
        self.receivedAmoundLabel.text = "\(invoiceDataSource.amount) PKR"
        self.invoiceData.text = invoiceDataSource.bookingId.accept_date
       
    }
    private func loadInvoiceData() {
        self.startPulseAnimation()
        NetworkUtil.request(dataType: TalentCompleteBookingInvoiceResponse.self, apiMethod: Constants.URL.talentCompleteBookingInvoice+bookId, parameters:nil) { data in
            self.stopPulseAnimation()
            guard let model = data.talentCompleteBookingInvoice.first else {
                return
            }
            self.isInvoiceLoaded = true
            self.setInvoiceData(invoiceDataSource: model)
        } onFailure: { _,msg in
            self.stopPulseAnimation()
            self.showToast(message: msg, font: .systemFont(ofSize: 16))
        }

        
//        NetworkUtil.request(dataType: TalentCompleteBookingInvoiceResponse.self, apiMethod: Constants.URL.talentCompleteBookingInvoice, parameters: nil) { data in
//            self.stopPulseAnimation()
//            guard let model = data.talentCompleteBookingInvoice.first.first else {
//                return
//            }
//            self.setInvoiceData(invoiceDataSource: model)
//        } onFailure: { msg in
//            self.stopPulseAnimation()
//            self.showToast(message: msg, font: .systemFont(ofSize: 16))
//        }
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func downloadPDF(_ sender: Any) {
//        openPDF()
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
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("receipt_\(bookId).pdf")
        
        pdfData.write(toFile:path.path, atomically: true)
 
        self.invoicePDF = path
        let vc = QLPreviewController()
        vc.dataSource = self
        present(vc, animated: true)
    }
}
extension InvoiceProviderController :QLPreviewControllerDataSource{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        invoicePDF! as QLPreviewItem
    } 
}
