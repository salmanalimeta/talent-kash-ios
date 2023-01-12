//
//  Talent Cash
//
//  cloned & modified by Mir karam on 01/12/2022.
//  source origin : https://developer.apple.com/documentation/avfoundation/additional_data_capture/avcamfilter_applying_filters_to_a_capture_stream
//

import UIKit
import AVFoundation
import CoreVideo
import Photos
import MobileCoreServices

protocol CameraDelegate {
    func cameraStarted()
    func cameraStopped()
    func recordingStarted()
    func recordingPaused()
    func recordingResumed()
    func recordingStopped(videoUrl:URL?)
    func cameraStartFailed()
    func recordingCanceled()
    func permissionDenied(video:Bool,audio:Bool)
    func permissionDenied()
}
enum _CaptureState {
        case idle,start,capturing,paused, end,cancel
    }

class CameraControllerView:PreviewMetalView, AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate { //AVCaptureDataOutputSynchronizerDelegate ,AVCaptureDepthDataOutputDelegate
    
    // MARK: - Properties
    var viedoCameraDelegate: CameraDelegate!
    private var videoFilterOn: Bool = false
    
//    private var depthVisualizationOn: Bool = false
    
//    private var depthSmoothingOn: Bool = false
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private var setupResult: SessionSetupResult = .success
    
    private let session = AVCaptureSession()
    
    private var isSessionRunning = false
    
    // Communicate with the session and other session objects on this queue.
    private let sessionQueue = DispatchQueue(label: "SessionQueue", attributes: [], autoreleaseFrequency: .workItem)
    
    private var videoInput: AVCaptureDeviceInput!
    private var audioInput: AVCaptureDeviceInput!
    
    private let videoOutputQueue = DispatchQueue(label: "VideoDataQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
//    private let audioOutputQueue = DispatchQueue(label: "AudioDataQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let audioDataOutput = AVCaptureAudioDataOutput()
    
//    private let depthDataOutput = AVCaptureDepthDataOutput()
    
//    private var outputSynchronizer: AVCaptureDataOutputSynchronizer?
    
    //    private let photoOutput = AVCapturePhotoOutput()
    
    private var filterRenderers: [FilterRenderer] = []
    
    //    private let photoRenderers: [FilterRenderer] = [RosyMetalRenderer(), RosyCIRenderer()]
    
    private let videoDepthMixer = VideoMixer()
    
    //    private let photoDepthMixer = VideoMixer()
    
    private var filterIndex: Int = 0
    
    private var videoFilter: FilterRenderer?
    
    //    private var photoFilter: FilterRenderer?
    
//    private let videoDepthConverter = DepthToGrayscaleConverter()
    
    //    private let photoDepthConverter = DepthToGrayscaleConverter()
    
    private var currentDepthPixelBuffer: CVPixelBuffer?
    
    private var renderingEnabled = true
    
    private var depthVisualizationEnabled = false
    
    private let processingQueue = DispatchQueue(label: "photo processing queue", attributes: [], autoreleaseFrequency: .workItem)
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,
                                                                                             .builtInWideAngleCamera],
                                                                               mediaType: .video,
                                                                               position: .unspecified)
    
    var statusBarOrientation: UIInterfaceOrientation = .portrait
    
    private var _assetWriter: AVAssetWriter?
    private var _assetWriterInput: AVAssetWriterInput?
    private var _assetAudioWriterInput: AVAssetWriterInput?
    private var _adpater: AVAssetWriterInputPixelBufferAdaptor?
    private var _filename = ""
//    private var _time: Double = 0
    var _captureState = _CaptureState.idle
  
    // MARK: - View Controller Life Cycle
    func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate( alongsideTransition: { _ in
            let interfaceOrientation = UIApplication.shared.statusBarOrientation
            self.statusBarOrientation = interfaceOrientation
            self.sessionQueue.async {
                
                if let unwrappedVideoDataOutputConnection = self.videoDataOutput.connection(with: .video) {
                    if let rotation = PreviewMetalView.Rotation(with: interfaceOrientation,
                                                                videoOrientation: unwrappedVideoDataOutputConnection.videoOrientation,
                                                                cameraPosition: self.videoInput.device.position) {
                        self.rotation = rotation
                    }
                }
            }
        }, completion: nil)
    }
    
    func loadCamera() {
        videoFilterOn = false
        let vid = AVCaptureDevice.authorizationStatus(for: .video) == .denied || AVCaptureDevice.authorizationStatus(for: .video) == .restricted
        let aud = AVCaptureDevice.authorizationStatus(for: .audio) == .denied || AVCaptureDevice.authorizationStatus(for: .audio) == .restricted
        if vid || aud{
            DispatchQueue.main.async {
                self.viedoCameraDelegate.permissionDenied(video: vid, audio: aud)
            }
        }else{
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted{
                    AVCaptureDevice.requestAccess(for: .audio) { granted in
                        if granted{
                            self.setupResult = .success
                        }else{
                            self.setupResult = .notAuthorized
                            DispatchQueue.main.async {
                                self.viedoCameraDelegate.permissionDenied()
                            }
                        }
                    }
                }else{
                    self.setupResult = .notAuthorized
                    DispatchQueue.main.async {
                        self.viedoCameraDelegate.permissionDenied()
                    }
                }
            }
        }
        
        sessionQueue.async {
            self.configureSession()
        }
        self.filterRenderers = Constants.filterList.compactMap({ f in
            RosyCIRenderer(filterName: f.name,inputs: f.inputs)
        })
    }
    func startCamera() {
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        statusBarOrientation = interfaceOrientation
        
        let initialThermalState = ProcessInfo.processInfo.thermalState
        if initialThermalState == .serious || initialThermalState == .critical {
            showThermalState(state: initialThermalState)
        }
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.addObservers()
                if let unwrappedVideoDataOutputConnection = self.videoDataOutput.connection(with: .video) {
                    let videoDevicePosition = self.videoInput.device.position
                    let rotation = PreviewMetalView.Rotation(with: self.statusBarOrientation,videoOrientation: unwrappedVideoDataOutputConnection.videoOrientation,cameraPosition: videoDevicePosition)
                    self.mirroring = (videoDevicePosition == .front)
                    if let rotation = rotation {
                        self.rotation = rotation
                    }
                }
                self.videoOutputQueue.async {
                    self.renderingEnabled = true
                }
                
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                DispatchQueue.main.async {
                    self.viedoCameraDelegate.cameraStarted()
                }
            case .notAuthorized:
                break;
            case .configurationFailed:
                DispatchQueue.main.async {
                    self.viedoCameraDelegate.cameraStartFailed()
                }
            }
        }
    }
    
    func stopCamera() {
        videoOutputQueue.async {
            self.renderingEnabled = false
        }
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        self.viedoCameraDelegate.cameraStopped()
    }
    
    @objc func didEnterBackground(notification: NSNotification) {
        // Free up resources.
        videoOutputQueue.async {
            self.renderingEnabled = false
            if let videoFilter = self.videoFilter {
                videoFilter.reset()
            }
            self.videoDepthMixer.reset()
            self.currentDepthPixelBuffer = nil
//            self.videoDepthConverter.reset()
            self.pixelBuffer = nil
            self.flushTextureCache()
        }
    }
    
    @objc
    func willEnterForground(notification: NSNotification) {
        videoOutputQueue.async {
            self.renderingEnabled = true
        }
    }
    
    // Use this opportunity to take corrective action to help cool the system down.
    @objc
    func thermalStateChanged(notification: NSNotification) {
        if let processInfo = notification.object as? ProcessInfo {
            showThermalState(state: processInfo.thermalState)
        }
    }
    
    func showThermalState(state: ProcessInfo.ThermalState) {
        DispatchQueue.main.async {
            if state == .critical{
                self.viedoCameraDelegate.permissionDenied()
            }
        }
    }
    
    // MARK: - KVO and Notifications
    
    private var sessionRunningContext = 0
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(thermalStateChanged),
                                               name: ProcessInfo.thermalStateDidChangeNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: NSNotification.Name.AVCaptureSessionRuntimeError,
                                               object: session)
        
        session.addObserver(self, forKeyPath: "running", options: NSKeyValueObservingOptions.new, context: &sessionRunningContext)
        
        // A session can run only when the app is full screen. It will be interrupted in a multi-app layout.
        // Add observers to handle these session interruptions and inform the user.
        // See AVCaptureSessionWasInterruptedNotification for other interruption reasons.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: NSNotification.Name.AVCaptureSessionWasInterrupted,
                                               object: session)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: NSNotification.Name.AVCaptureSessionInterruptionEnded,
                                               object: session)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                               object: videoInput.device)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        session.removeObserver(self, forKeyPath: "running", context: &sessionRunningContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if context == &sessionRunningContext {
            let newValue = change?[.newKey] as AnyObject?
            guard (newValue?.boolValue) != nil else { return }
            DispatchQueue.main.async {
                //                self.cameraButton.isEnabled = (isSessionRunning && self.videoDeviceDiscoverySession.devices.count > 1)
                //                self.photoButton.isEnabled = isSessionRunning
                //                self.videoFilterButton.isEnabled = isSessionRunning
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Session Management
    
    // Call this on the SessionQueue
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        let defaultVideoDevice: AVCaptureDevice? = videoDeviceDiscoverySession.devices.first
        
        guard let videoDevice = defaultVideoDevice,let audioDevice = AVCaptureDevice.default(for: .audio) else {
            setupResult = .configurationFailed
            return
        }
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
            audioInput = try AVCaptureDeviceInput(device: audioDevice)
        } catch {
            print("Could not create video or audio device input: \(error)")
            setupResult = .configurationFailed
            return
        }
        
        session.beginConfiguration()

        
        session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        
        // Add a video input.
        guard session.canAddInput(videoInput) else {
            print("Could not add video device input to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.addInput(videoInput)
        
        guard session.canAddInput(audioInput) else {
            print("Could not add video device input to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.addInput(audioInput)
        
        // Add a video data output
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
        } else {
            print("Could not add audio data output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        // Add a Audio data output
        if session.canAddOutput(audioDataOutput) {
            session.addOutput(audioDataOutput)
            audioDataOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
        } else {
            print("Could not add video data output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.commitConfiguration()
    }
    
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        // In iOS 9 and later, the userInfo dictionary contains information on why the session was interrupted.
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let reasonIntegerValue = userInfoValue.integerValue,
           let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
            
            if reason == .videoDeviceInUseByAnotherClient {
                // Simply fade-in a button to enable the user to try to resume the session running.
                //                resumeButton.isHidden = false
                //                resumeButton.alpha = 0.0
                //                UIView.animate(withDuration: 0.25) {
                //                    self.resumeButton.alpha = 1.0
                //                }
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                // Simply fade-in a label to inform the user that the camera is unavailable.
                //                cameraUnavailableLabel.isHidden = false
                //                cameraUnavailableLabel.alpha = 0.0
                //                UIView.animate(withDuration: 0.25) {
                //                    self.cameraUnavailableLabel.alpha = 1.0
                //                }
            }
        }
    }
    
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        //        if !resumeButton.isHidden {
        //            UIView.animate(withDuration: 0.25,
        //                           animations: {
        //                            self.resumeButton.alpha = 0
        //            }, completion: { _ in
        //                self.resumeButton.isHidden = true
        //            }
        //            )
        //        }
        //        if !cameraUnavailableLabel.isHidden {
        //            UIView.animate(withDuration: 0.25,
        //                           animations: {
        //                            self.cameraUnavailableLabel.alpha = 0
        //            }, completion: { _ in
        //                self.cameraUnavailableLabel.isHidden = true
        //            }
        //            )
        //        }
    }
    
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }
        
        let error = AVError(_nsError: errorValue)
        print("Capture session runtime error: \(error)")
        
        /*
         Automatically try to restart the session running if media services were
         reset and the last start running succeeded. Otherwise, enable the user
         to try to resume the session running.
         */
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                } else {
                    DispatchQueue.main.async {
                        //                        self.resumeButton.isHidden = false
                    }
                }
            }
        } else {
            //            resumeButton.isHidden = false
        }
    }
    
    @IBAction private func focusAndExposeTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        guard let texturePoint = texturePointForView(point: location) else {
            return
        }
        
        let textureRect = CGRect(origin: texturePoint, size: .zero)
        let deviceRect = videoDataOutput.metadataOutputRectConverted(fromOutputRect: textureRect)
        focus(with: .autoFocus, exposureMode: .autoExpose, at: deviceRect.origin, monitorSubjectAreaChange: true)
    }
    
    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    @IBAction private func toogleeFlashLight(_ sender: UIButton) {
        let isOn = sender.isSelected
        sessionQueue.async {
            let device = self.videoInput.device
            if device.hasTorch{
                do{
                    try device.lockForConfiguration()
                    if isOn{
                        device.torchMode = .off
                    }else{
                        device.torchMode = .on
                    }
                    device.unlockForConfiguration()
                    DispatchQueue.main.async {
                        sender.isSelected.toggle()
                    }
                }catch {}
            }
        }
    }
    @IBAction private func changeCamera(_ sender: UIButton) {
        UIView.animate(withDuration:0.8, animations: {
                    sender.transform = CGAffineTransform(rotationAngle: -0.999*CGFloat.pi)
        }) { _ in
            sender.transform = .identity
        }
        videoOutputQueue.sync {
            renderingEnabled = false
            if let filter = videoFilter {
                filter.reset()
            }
            videoDepthMixer.reset()
            currentDepthPixelBuffer = nil
//            videoDepthConverter.reset()
            self.pixelBuffer = nil
        }
        
        let interfaceOrientation = statusBarOrientation
    
        
        sessionQueue.async {
            let currentVideoDevice = self.videoInput.device
            var preferredPosition = AVCaptureDevice.Position.unspecified
            switch currentVideoDevice.position {
            case .unspecified, .front:
                preferredPosition = .back
                
            case .back:
                preferredPosition = .front
            @unknown default:
                fatalError("Unknown video device position.")
            }
            
            let devices = self.videoDeviceDiscoverySession.devices
            if let videoDevice = devices.first(where: { $0.position == preferredPosition }) {
                var videoInput: AVCaptureDeviceInput
                do {
                    videoInput = try AVCaptureDeviceInput(device: videoDevice)
                } catch {
                    print("Could not create video device input: \(error)")
                    self.videoOutputQueue.async {
                        self.renderingEnabled = true
                    }
                    return
                }
                self.session.beginConfiguration()
                
                // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
                self.session.removeInput(self.videoInput)
                
                if self.session.canAddInput(videoInput) {
                    NotificationCenter.default.removeObserver(self,
                                                              name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                                              object: currentVideoDevice)
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(self.subjectAreaDidChange),
                                                           name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                                           object: videoDevice)
                    
                    self.session.addInput(videoInput)
                    self.videoInput = videoInput
                } else {
                    print("Could not add video device input to the session")
                    self.session.addInput(self.videoInput)
                }
                self.session.commitConfiguration()
            }
            
            let videoPosition = self.videoInput.device.position
            
            if let unwrappedVideoDataOutputConnection = self.videoDataOutput.connection(with: .video) {
                let rotation = PreviewMetalView.Rotation(with: interfaceOrientation,
                                                         videoOrientation: unwrappedVideoDataOutputConnection.videoOrientation,
                                                         cameraPosition: videoPosition)
                
                self.mirroring = (videoPosition == .front)
                if let rotation = rotation {
                    self.rotation = rotation
                }
            }
            
            self.videoOutputQueue.async {
                self.renderingEnabled = true
            }
        }
    }
    
//    @IBAction private func toggleDepthVisualization() {
//        depthVisualizationOn.toggle()
//        let depthEnabled = depthVisualizationOn
//        
//        sessionQueue.async {
//            self.session.beginConfiguration()
//            
//            if let unwrappedDepthConnection = self.depthDataOutput.connection(with: .depthData) {
//                unwrappedDepthConnection.isEnabled = depthEnabled
//            }
//            
//            if depthEnabled {
//                // Use an AVCaptureDataOutputSynchronizer to synchronize the video data and depth data outputs.
//                // The first output in the dataOutputs array, in this case the AVCaptureVideoDataOutput, is the main output.
//                self.outputSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [self.videoDataOutput, self.depthDataOutput])
//                
//                if let unwrappedOutputSynchronizer = self.outputSynchronizer {
//                    unwrappedOutputSynchronizer.setDelegate(self, queue: self.videoOutputQueue)
//                }
//            } else {
//                self.outputSynchronizer = nil
//            }
//            self.session.commitConfiguration()
//            
//            self.videoOutputQueue.async {
//                if !depthEnabled {
////                    self.videoDepthConverter.reset()
//                    self.videoDepthMixer.reset()
//                    self.currentDepthPixelBuffer = nil
//                }
//                self.depthVisualizationEnabled = depthEnabled
//            }
//        }
//    }
    

    func toggleFiltering(index:Int) {
        videoOutputQueue.async {
            if index > 0 {
                self.videoFilter?.reset()
                self.videoFilter = self.filterRenderers[index]
            } else {
                if let filter = self.videoFilter {
                    filter.reset()
                }
                self.videoFilter = nil
            }
        }
    }
    
    @IBAction private func captureVideo(_ photoButton: UIButton) {
        switch _captureState {
        case .idle:
            _captureState = .start
        case .capturing:
            _captureState = .paused
            self.viedoCameraDelegate.recordingPaused()
        case .paused:
            _captureState = .capturing
            self.viedoCameraDelegate.recordingStarted()
        case .end:
            _captureState = .idle
        default:
            break
            
        }
        //        let depthEnabled = depthVisualizationOn
        //
//                sessionQueue.async {
//                    let photoSettings = AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)])
//                    if depthEnabled && self.photoOutput.isDepthDataDeliverySupported {
//                        photoSettings.isDepthDataDeliveryEnabled = true
//                        photoSettings.embedsDepthDataInPhoto = false
//                    } else {
//                        photoSettings.isDepthDataDeliveryEnabled = depthEnabled
//                    }
//
//                    self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
//                }
    }
    
    // MARK: - Video Data Output Delegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !renderingEnabled {
            return
        }
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        switch _captureState {
        case .start:
            // Set up recorder
            _filename = UUID().uuidString
            let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mov")
            let writer = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
            let inputAudio = AVAssetWriterInput(mediaType: .audio, outputSettings: audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mov))
            inputAudio.expectsMediaDataInRealTime = true
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mov))
            input.mediaTimeScale = timestamp.timescale
            input.expectsMediaDataInRealTime = true
            input.transform = CGAffineTransform(rotationAngle: .pi/2)
            let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
            if writer.canAdd(input) {
                writer.add(input)
            }
            if writer.canAdd(inputAudio){
                writer.add(inputAudio)
            }
            writer.startWriting()
            writer.startSession(atSourceTime:timestamp)
            _assetWriter = writer
            _assetAudioWriterInput = inputAudio
            _assetWriterInput = input
            _adpater = adapter
            _captureState = .capturing
            DispatchQueue.main.async {
                self.viedoCameraDelegate.recordingStarted()
            }
        case .capturing:
            if output == videoDataOutput {
                guard
                    let videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
                    let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
                    return
                }
                var finalVideoPixelBuffer = videoPixelBuffer
                if let filter = videoFilter {
                    if !filter.isPrepared {
                        /*
                         outputRetainedBufferCountHint is the number of pixel buffers the renderer retains. This value informs the renderer
                         how to size its buffer pool and how many pixel buffers to preallocate. Allow 3 frames of latency to cover the dispatch_async call.
                         */
                        let size = CMVideoFormatDescriptionGetDimensions(formatDescription)
                        filter.frameCenter = .init(x: CGFloat(size.width)*0.4, y: CGFloat(size.height)*0.4)
                        filter.prepare(with: formatDescription, outputRetainedBufferCountHint: 3)
                    }
                    
                    // Send the pixel buffer through the filter
                    guard let filteredBuffer = filter.render(pixelBuffer: finalVideoPixelBuffer) else {
                        print("Unable to filter video buffer")
                        return
                    }
                    
                    finalVideoPixelBuffer = filteredBuffer
                }
                self.pixelBuffer = finalVideoPixelBuffer
                if _assetWriterInput?.isReadyForMoreMediaData == true {
                    _adpater?.append( finalVideoPixelBuffer, withPresentationTime: timestamp)
                }
            }else if output == audioDataOutput{
                if _assetAudioWriterInput?.isReadyForMoreMediaData == true {
                    _assetAudioWriterInput?.append(sampleBuffer)
                }
            }
            break
        case .end:
            guard _assetWriterInput?.isReadyForMoreMediaData == true,_assetAudioWriterInput?.isReadyForMoreMediaData == true, _assetWriter!.status != .failed else { break }
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mov")
            _assetAudioWriterInput!.markAsFinished()
            _assetWriterInput?.markAsFinished()
            _assetWriter?.finishWriting { [weak self] in
                self?._captureState = .idle
                self?._assetWriter = nil
                self?._assetWriterInput = nil
                self?._assetAudioWriterInput = nil
                DispatchQueue.main.async {
                    self?.viedoCameraDelegate.recordingStopped(videoUrl: url)
                }
            }
        case .cancel:
            self._captureState = .idle
            self._assetWriter?.cancelWriting()
            self._assetWriter = nil
            self._assetWriterInput = nil
            self._assetAudioWriterInput = nil
            DispatchQueue.main.async {
                self.viedoCameraDelegate.recordingCanceled()
            }
            
        default:
            guard
                let videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
                let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
                return
            }
            var finalVideoPixelBuffer = videoPixelBuffer
            if let filter = videoFilter {
                if !filter.isPrepared {
                    let size = CMVideoFormatDescriptionGetDimensions(formatDescription)
                    filter.frameCenter = .init(x: CGFloat(size.width)*0.3, y: CGFloat(size.height)*0.5)
                    filter.prepare(with: formatDescription, outputRetainedBufferCountHint: 3)
                }
                // Send the pixel buffer through the filter
                guard let filteredBuffer = filter.render(pixelBuffer: finalVideoPixelBuffer) else {
                    print("Unable to filter video buffer")
                    return
                }
                finalVideoPixelBuffer = filteredBuffer
            }
            self.pixelBuffer = finalVideoPixelBuffer
        }
    }
    
    // MARK: - Depth Data Output Delegate
    
    /// - Tag: StreamDepthData
//    func depthDataOutput(_ depthDataOutput: AVCaptureDepthDataOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection) {
//        processDepth(depthData: depthData)
//        print("data out.....")
//
//    }
    
//    func processDepth(depthData: AVDepthData) {
//        if !renderingEnabled {
//            return
//        }
//
//        if !depthVisualizationEnabled {
//            return
//        }
//
//        if !videoDepthConverter.isPrepared {
//            var depthFormatDescription: CMFormatDescription?
//            CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
//                                                         imageBuffer: depthData.depthDataMap,
//                                                         formatDescriptionOut: &depthFormatDescription)
//            if let unwrappedDepthFormatDescription = depthFormatDescription {
//                videoDepthConverter.prepare(with: unwrappedDepthFormatDescription, outputRetainedBufferCountHint: 2)
//            }
//        }
//
//        guard let depthPixelBuffer = videoDepthConverter.render(pixelBuffer: depthData.depthDataMap) else {
//            print("Unable to process depth")
//            return
//        }
//
//        currentDepthPixelBuffer = depthPixelBuffer
//    }
    
    // MARK: - Video + Depth Output Synchronizer Delegate
    
//    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
//        print("asdm,najksdnasndm,nasmdnmasnm,dasnmdnmasnm,")
//        if let syncedDepthData: AVCaptureSynchronizedDepthData = synchronizedDataCollection.synchronizedData(for: depthDataOutput) as? AVCaptureSynchronizedDepthData {
//            if !syncedDepthData.depthDataWasDropped {
//                let depthData = syncedDepthData.depthData
////                processDepth(depthData: depthData)
//            }
//        }
//
//        if let syncedVideoData: AVCaptureSynchronizedSampleBufferData = synchronizedDataCollection.synchronizedData(for: videoDataOutput) as? AVCaptureSynchronizedSampleBufferData {
//            if !syncedVideoData.sampleBufferWasDropped {
//                let videoSampleBuffer = syncedVideoData.sampleBuffer
////                processVideo(sampleBuffer: videoSampleBuffer)
//            }
//        }
//    }
    
    
    // MARK: - Utilities
    //    private func capFrameRate(videoDevice: AVCaptureDevice) {
    //        if self.photoOutput.isDepthDataDeliverySupported {
    //            // Cap the video framerate at the max depth framerate.
    //            if let frameDuration = videoDevice.activeDepthDataFormat?.videoSupportedFrameRateRanges.first?.minFrameDuration {
    //                do {
    //                    try videoDevice.lockForConfiguration()
    //                    videoDevice.activeVideoMinFrameDuration = frameDuration
    //                    videoDevice.unlockForConfiguration()
    //                } catch {
    //                    print("Could not lock device for configuration: \(error)")
    //                }
    //            }
    //        }
    //    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        
        sessionQueue.async {
            let videoDevice = self.videoInput.device
            
            do {
                try videoDevice.lockForConfiguration()
                if videoDevice.isFocusPointOfInterestSupported && videoDevice.isFocusModeSupported(focusMode) {
                    videoDevice.focusPointOfInterest = devicePoint
                    videoDevice.focusMode = focusMode
                }
                
                if videoDevice.isExposurePointOfInterestSupported && videoDevice.isExposureModeSupported(exposureMode) {
                    videoDevice.exposurePointOfInterest = devicePoint
                    videoDevice.exposureMode = exposureMode
                }
                
                videoDevice.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                videoDevice.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
}

extension AVCaptureVideoOrientation {
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

extension PreviewMetalView.Rotation {
    init?(with interfaceOrientation: UIInterfaceOrientation, videoOrientation: AVCaptureVideoOrientation, cameraPosition: AVCaptureDevice.Position) {
        /*
         Calculate the rotation between the videoOrientation and the interfaceOrientation.
         The direction of the rotation depends upon the camera position.
         */
        switch videoOrientation {
        case .portrait:
            switch interfaceOrientation {
            case .landscapeRight:
                if cameraPosition == .front {
                    self = .rotate90Degrees
                } else {
                    self = .rotate270Degrees
                }
                
            case .landscapeLeft:
                if cameraPosition == .front {
                    self = .rotate270Degrees
                } else {
                    self = .rotate90Degrees
                }
                
            case .portrait:
                self = .rotate0Degrees
                
            case .portraitUpsideDown:
                self = .rotate180Degrees
                
            default: return nil
            }
        case .portraitUpsideDown:
            switch interfaceOrientation {
            case .landscapeRight:
                if cameraPosition == .front {
                    self = .rotate270Degrees
                } else {
                    self = .rotate90Degrees
                }
                
            case .landscapeLeft:
                if cameraPosition == .front {
                    self = .rotate90Degrees
                } else {
                    self = .rotate270Degrees
                }
                
            case .portrait:
                self = .rotate180Degrees
                
            case .portraitUpsideDown:
                self = .rotate0Degrees
                
            default: return nil
            }
            
        case .landscapeRight:
            switch interfaceOrientation {
            case .landscapeRight:
                self = .rotate0Degrees
                
            case .landscapeLeft:
                self = .rotate180Degrees
                
            case .portrait:
                if cameraPosition == .front {
                    self = .rotate270Degrees
                } else {
                    self = .rotate90Degrees
                }
                
            case .portraitUpsideDown:
                if cameraPosition == .front {
                    self = .rotate90Degrees
                } else {
                    self = .rotate270Degrees
                }
                
            default: return nil
            }
            
        case .landscapeLeft:
            switch interfaceOrientation {
            case .landscapeLeft:
                self = .rotate0Degrees
                
            case .landscapeRight:
                self = .rotate180Degrees
                
            case .portrait:
                if cameraPosition == .front {
                    self = .rotate90Degrees
                } else {
                    self = .rotate270Degrees
                }
                
            case .portraitUpsideDown:
                if cameraPosition == .front {
                    self = .rotate270Degrees
                } else {
                    self = .rotate90Degrees
                }
                
            default: return nil
            }
        @unknown default:
            fatalError("Unknown orientation.")
        }
    }
}
