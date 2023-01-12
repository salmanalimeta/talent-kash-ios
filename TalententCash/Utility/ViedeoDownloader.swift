//
//  ViedeoDownloader.swift
//  Talent Cash
//
//  Created by Aamir on 14/12/2022.
//

import Foundation
import Photos

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
        self.isBusy = false
        print(location)
        do{
            var outputURL =  URL(fileURLWithPath: NSTemporaryDirectory())
            outputURL.appendPathComponent("video.mp4")
            if FileManager.default.fileExists(atPath: outputURL.path){
               try FileManager.default.removeItem(at: outputURL)
            }
            try FileManager.default.moveItem(at: location, to: outputURL)
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
        }catch{
            DispatchQueue.main.async {
                self.delegate?.videoDownloadFailed(msg: "unable to save video")
            }
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
}
