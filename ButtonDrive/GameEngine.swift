//: Playground - noun: a place where people can play

// class to pass location of sphero and pass' back whether to stop or not
// pass' back if it got into a hole.

import UIKit




struct Hole  {
    var map: [[Int]]
    var start: (x: Int, y: Int)
    var end: (x: Int, y: Int)
    
    
    init(map: [[Int]], start: (x: Int, y: Int), end:(x: Int, y: Int)) {
        self.map = map
        self.start = start
        self.end = end
    }
}


@objc class PuttPuttGameLogic : NSObject {
    var chosenHole: Hole
    
    
    var initialX = 0
    var initialY = 0
	
	@objc init(withHole: Int) {
		chosenHole = PuttPuttGameLogic.predeterminedArray(number: withHole)
	}
    
    @objc init(image: UIImage, startX: Int, startY: Int, endX: Int, endY: Int) {
        
//        super.init()
		
		//commented out second line because it doesn't work with [[Int]], using first to let init work for now
		chosenHole = PuttPuttGameLogic.predeterminedArray(number: 1)
		//chosenHole = Hole(map: PuttPuttGameLogic.pixelValues(fromCGImage: image.cgImage).pixelVals, start: (startX, startY), end: (endX, endY))
		
        
//        for x in 0...999 {
//            for y in 0...999 {
//                chosenHole.map[x][y]=0;
//            }
//        }
        
        dump(chosenHole.map)
    }
    
    
    
    func setInitial(x: Int, y: Int) {
        initialX = x;
        initialY = y;
    }
    
    // [SUCCESS, STOP]
    func puttGolfBallTo(ballX: Int, ballY: Int) -> [Bool] {
		var succeed: Bool
		var stop: Bool = false
        
        let ballXAdjusted = ballX - initialX;
        let ballYAdjusted = ballY - initialY;
		
        if(chosenHole.end.x == ballXAdjusted && chosenHole.end.y == ballYAdjusted) {
            succeed = true
		}
		else {
			succeed = false
		}
	
		let blackPoint = 20
			if(chosenHole.map[ballXAdjusted][ballYAdjusted] <= blackPoint) { //This line is broken because of stupid UInts
			stop = true
		}
		else {
			stop = false
		}
		
		return [succeed, stop]
    }
	
	//Backup plan
	static func predeterminedArray(number: Int) -> Hole {
		var givingHole: Hole = Hole(map: [[0]], start: (0,0), end: (0,0))
		
		for x in 0...1000 {
			for y in 0...1000 {
				givingHole.map[x][y] = 255
			}
		}
		if(number == 1) {
			for y in 0...1000 {
				givingHole.map[0][y] = 0
			}
			
			for y in 0...250 {
				givingHole.map[500][y] = 0
			}
			for x in 500...750 {
				givingHole.map[x][250] = 0
			}
			for y in 250...1000 {
				givingHole.map[750][y] = 0
			}
			
			givingHole.start = (100, 0)
			givingHole.end = (550, 1000)
		}
		else if(number == 2) {
			for y in 0...600 {
				givingHole.map[250][y] = 0
			}
			for y in 400...1000 {
				givingHole.map[750][y] = 0
			}
			for x in 400...600 {
				givingHole.map[x][x] = 0
			}
			
			givingHole.start = (125, 0)
			givingHole.end = (875, 1000)
		}
        
        return givingHole;
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
