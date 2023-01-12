//
//  Talent Cash
//
//  original source origin : https://developer.apple.com/documentation/avfoundation/additional_data_capture/avcamfilter_applying_filters_to_a_capture_stream
//

import CoreMedia
import CoreVideo
import CoreImage

class RosyCIRenderer: FilterRenderer {
    var frameCenter: CGPoint
    
    let filterName: String
    let inputs:KeyValuePairs<String,Any>
    var isPrepared = false
    
    private var ciContext: CIContext?
    
    private var rosyFilter: CIFilter?
    
    private var outputColorSpace: CGColorSpace?
    
    private var outputPixelBufferPool: CVPixelBufferPool?
    
    private(set) var outputFormatDescription: CMFormatDescription?
    
    private(set) var inputFormatDescription: CMFormatDescription?
    
    init(filterName:String,inputs:KeyValuePairs<String,Any>) {
        self.frameCenter = .init(x: 0, y: 0)
        self.filterName = filterName
        self.inputs = inputs
    }
    func prepare(with formatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int) {
        reset()
        
        (outputPixelBufferPool,
         outputColorSpace,
         outputFormatDescription) = allocateOutputBufferPool(with: formatDescription,
                                                             outputRetainedBufferCountHint: outputRetainedBufferCountHint)
        if outputPixelBufferPool == nil {
            return
        }
        
        inputFormatDescription = formatDescription
        ciContext = CIContext()
        guard let rosyFilter = CIFilter(name: self.filterName)else{
            isPrepared = false
            return
        }
        inputs.forEach { (k,v) in
            rosyFilter.setValue(v, forKey: k)
        }
        if filterName.contains("Distortion"){
            rosyFilter.setValue(CIVector(x: frameCenter.x, y: frameCenter.y), forKey: "inputCenter")
            rosyFilter.setValue(frameCenter.x, forKey: "inputRadius")
        }
        if filterName.contains("ZoomBlur"){
            rosyFilter.setValue(CIVector(x: frameCenter.x, y: frameCenter.y), forKey: "inputCenter")
            rosyFilter.setValue(10, forKey: "inputAmount")
        }
        self.rosyFilter = rosyFilter
        isPrepared = true
    }
    
    func reset() {
        ciContext = nil
        rosyFilter = nil
        outputColorSpace = nil
        outputPixelBufferPool = nil
        outputFormatDescription = nil
        inputFormatDescription = nil
        isPrepared = false
    }
    
    func render(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        guard let rosyFilter = rosyFilter,
            let ciContext = ciContext,
            isPrepared else {
                assertionFailure("Invalid state: Not prepared")
                return nil
        }
        
        let sourceImage = CIImage(cvImageBuffer: pixelBuffer)
        rosyFilter.setValue(sourceImage, forKey: kCIInputImageKey)
        
        guard let filteredImage = rosyFilter.value(forKey: kCIOutputImageKey) as? CIImage else {
            print("CIFilter failed to render image")
            return nil
        }
        
        var pbuf: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, outputPixelBufferPool!, &pbuf)
        guard let outputPixelBuffer = pbuf else {
            print("Allocation failure")
            return nil
        }
        
        // Render the filtered image out to a pixel buffer (no locking needed, as CIContext's render method will do that)
        ciContext.render(filteredImage, to: outputPixelBuffer, bounds: filteredImage.extent, colorSpace: outputColorSpace)
        return outputPixelBuffer
    }
}
