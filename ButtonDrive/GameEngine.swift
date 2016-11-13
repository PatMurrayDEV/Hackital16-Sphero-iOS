//: Playground - noun: a place where people can play

// class to pass location of sphero and pass' back whether to stop or not
// pass' back if it got into a hole.

import UIKit




struct Hole  {
    var map: [UInt8]
    var start: (x: Int, y: Int)
    var end: (x: Int, y: Int)
    
    
    init(map: [UInt8], start: (x: Int, y: Int), end:(x: Int, y: Int)) {
        self.map = map
        self.start = start
        self.end = end
    }
}


@objc class PuttPuttGameLogic : NSObject {
    var chosenHole: Hole
    
    @objc init(image: UIImage, startX: Int, startY: Int, endX: Int, endY: Int) {
        
//        super.init()
        
        chosenHole = Hole(map: PuttPuttGameLogic.pixelValues(fromCGImage: image.cgImage).pixelVals, start: (startX, startY), end: (endX, endY))
        
//        for x in 0...999 {
//            for y in 0...999 {
//                chosenHole.map[x][y]=0;
//            }
//        }
        
        dump(chosenHole.map)
    }
    
    
    
    // [SUCCESS, STOP]
    @objc func puttGolfBallTo(ballX: Int, ballY: Int) -> [Bool] {
        if(chosenHole.end.x != ballX && chosenHole.end.y != ballY){
            return([false, false])
        }else if(ballX == 0 || ballY == 0){
            return([false, false])
        }else{
            return([true, true])
        }
        
        
    }
    
    
    
    static func pixelValues(fromCGImage imageRef: CGImage?) -> (pixelVals: [UInt8], height: Int, width: Int) {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        if let imageRef = imageRef {
            width = imageRef.width
            height = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = imageRef.bytesPerRow
            let totalBytes = height * bytesPerRow
            
            let colorSpace = CGColorSpaceCreateDeviceGray()
            var intensities = [UInt8](repeating: 0, count: totalBytes)
            
            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
            
            pixelValues = intensities
        }
        
        return (pixelValues!, height, width);
    };
    
    
//    static func convertImageToArray(image : UIImage) -> [[UInt8]] {
//        
//        var pixel_vals = pixelValues(fromCGImage: image.cgImage)
//        var map_array = [[UInt8]]()
//        let array_size = (pixel_vals.height)-1
//        var index = 0
//        for _ in 0...array_size{
//            var row_arr = [UInt8]()
//            for _ in 0...array_size{
//                
//                if pixel_vals.pixelVals[index] == UInt8(0){
//                    row_arr.append(UInt8(0));
//                }else{
//                    row_arr.append(UInt8(255));
//                }
//                index+=1
//            }
//            map_array.append(row_arr);
//        }
//        
//        
//        return map_array;
//        
//        
//        
//    }
//    
    
    
    
    
}
