//
//  ViedeoDownloader.swift
//  Talent Cash
//
//  Created by Aamir on 14/12/2022.
//

import Foundation
import Photos
import UIKit
import MediaWatermark
import DPVideoMerger_Swift

protocol VideoDownloaderDelegagte {
    func videoDownloadStarted()
    func videoDownloadProgress(progress:Int)
    func videoDownloadCompleted()
    func videoDownloadBusy()
    func videoDownloadFailed(msg:String)
}
class VideoDownloader:NSObject,URLSessionDownloadDelegate{
    var isBusy = false
    var isCanceled = false
    private var delegate:VideoDownloaderDelegagte? = nil
    private var task:URLSessionDownloadTask? = nil
    
    init(_ delegate:VideoDownloaderDelegagte) {
        self.delegate = delegate
    }
    func download(url: URL){
        if isBusy{
            delegate?.videoDownloadBusy()
            return
        }
        isBusy = true
        isCanceled = false
        let operationQueue = OperationQueue()
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: operationQueue)
        task = session.downloadTask(with:url)
        task?.resume()
        delegate?.videoDownloadStarted()
        self.isBusy = true
    }
    func pasue() {
        task?.suspend()
    }
    func resume() {
        task?.resume()
    }
    func cancel() {
        self.isBusy = false
        isCanceled = true
        task?.cancel()
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            self.delegate?.videoDownloadProgress(progress: Int((Double(totalBytesWritten)/Double(totalBytesExpectedToWrite))*100.0))
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do{
            var outputURL =  URL(fileURLWithPath: NSTemporaryDirectory())
            outputURL.appendPathComponent("video.mp4")
            if FileManager.default.fileExists(atPath: outputURL.path){
                try FileManager.default.removeItem(at: outputURL)
            }
            try FileManager.default.moveItem(at: location, to: outputURL)
            addWaterMark(outputURL, onComplete: {url in
                self.isBusy = false
                if let url = url{
                    self.saveToPhotos(url)
                }else{
                    self.saveToPhotos(outputURL)
                }
            })
        }catch {
            delegate?.videoDownloadFailed(msg: "Video Save Failed!")
        }
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.isBusy = false
        if isCanceled {
            return
        }
        DispatchQueue.main.async {
            self.delegate?.videoDownloadFailed(msg: "video download failed")
        }
    }
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        self.isBusy = false
        if isCanceled {
            return
        }
        DispatchQueue.main.async {
            self.delegate?.videoDownloadFailed(msg: "video download failed")
        }
    }
    private func addWaterMark(_ inUrl:URL,onComplete: @escaping ((URL?) -> Void)){
        let videoUrlAsset = AVAsset(url: inUrl)
        guard let videoTrack = videoUrlAsset.tracks(withMediaType: .video).first else { return }
        let s = videoTrack.naturalSize.height > videoTrack.naturalSize.width ? videoTrack.naturalSize.width/4 : videoTrack.naturalSize.height/4
        
        if let item = MediaItem(url: inUrl) {
            let logoImage = UIImage(named: "watermark")
                    
            let firstElement = MediaElement(image: logoImage!)
            firstElement.frame = CGRect(x:10, y:250, width: 120, height: 120)
                    
            let testStr = ""
            let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
            let attrStr = NSAttributedString(string: testStr, attributes: attributes)
                    
            let secondElement = MediaElement(text: attrStr)
            secondElement.frame = CGRect(x:10, y:firstElement.frame.origin.y+firstElement.frame.height+20, width: logoImage!.size.width, height: logoImage!.size.height)
                    
            item.add(elements: [firstElement])
                    
            let mediaProcessor = MediaProcessor()
            mediaProcessor.processElements(item: item) { [weak self] (result, error) in
                
                let fileURL = Bundle.main.url(forResource: "LastClip", withExtension: "mp4")
                let fileURLs = [result.processedUrl,fileURL]
                DPVideoMerger().mergeVideos(withFileURLs: fileURLs as! [URL], completion: {(_ mergedVideoFile: URL?, _ error: Error?) -> Void in
                    if error != nil {
//                        let errorMessage = "Could not merge videos: \(error?.localizedDescription ?? "error")"
//                        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (a) in
//                        }))
//                        self.present(alert, animated: true) {() -> Void in }
                        return
                    }
                    onComplete(mergedVideoFile)
                    })
      
//                self?.mergeVideos(FirstUrl:result.processedUrl!, SecondUrl:fileURL! , onComplete: {url in
//                    onComplete(url)
//                })
                
                
           
            }
        }

    }
    
    func mergeVideos(FirstUrl : URL , SecondUrl : URL ,onComplete: @escaping ((URL?) -> Void)){

        let firstAssets = AVAsset(url: FirstUrl)
        let secondAssets = AVAsset(url: SecondUrl)

                
        KVVideoManager.shared.merge(arrayVideos: [firstAssets, secondAssets]) { (outputURL, error) in
              if let error = error {
                   print("Error:\(error.localizedDescription)")
              }
              else {
                   if let url = outputURL {
                       print("Output video file:\(url)")
                       onComplete(url)
                   }
             }
        }

    }
    private func textToImage(drawText: NSString, inImage: UIImage) -> UIImage{
        let size:CGFloat  = 180
        // Setup the image context using the passed image
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, 1)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSAttributedString.Key.font:  UIFont(name: "Helvetica Bold", size:18)!,
            NSAttributedString.Key.foregroundColor:  UIColor.white,
        ]
        let textFontLargeAttributes = [
            NSAttributedString.Key.font:  UIFont(name: "Helvetica Bold", size:28)!,
            NSAttributedString.Key.foregroundColor:  UIColor.white,
        ]
        // Put the image into a rectan gle as large as the original image
        inImage.draw(in: CGRectMake(0,0 , size-70, size-70))
 
        // Create a point within the space that is as bit as the image
        let rect = CGRectMake(0,size-64, size, size)
        let rect1 = CGRectMake(4,size-34, size, size)
 
        // Draw the text into an image
        "TalentCash".draw(in: rect, withAttributes: textFontLargeAttributes)
        drawText.draw(in: rect1, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage
        
    }
    private func saveToPhotos(_ outputURL:URL){
//        var outputURL =  URL(fileURLWithPath: NSTemporaryDirectory())
//        outputURL.appendPathComponent("video.mp4")
//        if FileManager.default.fileExists(atPath: outputURL.path){
//           try FileManager.default.removeItem(at: outputURL)
//        }
//        try FileManager.default.moveItem(at: inUrl, to: outputURL)
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
        }) { (success, error) -> Void in
            if let eer = error{
                print(eer)
            }
            DispatchQueue.main.async {
                if success {
                    self.delegate?.videoDownloadCompleted()
                }
                else {
                    self.delegate?.videoDownloadFailed(msg: "unable to save video")
                }
            }
        }
    }
}
