//
//  extention_UIImage.swift
//  NeuroTest
//
//  Created by Danil Denshin on 09.01.17.
//  Copyright © 2017 el2Nil. All rights reserved.
//
import UIKit

extension UIImage {
	
	func trim(keepRatio: Bool = false) -> UIImage {
		let newRect = self.cropRect(keepRatio: keepRatio)
		if let newImage = self.cgImage?.cropping(to: newRect) {
			return UIImage(cgImage: newImage)
		}
		return self
	}
	
	func cropRect(keepRatio: Bool) -> CGRect {
		let cgImage = self.cgImage!
		guard let context = UIImage.createARGBBitmapContextFromImage(forSize: self.size) else { return CGRect.zero }
		
		let height = CGFloat(cgImage.height)
		let width = CGFloat(cgImage.width)
		
		let rect = CGRect(x: 0, y: 0, width: width, height: height)
		context.draw(cgImage, in: rect)
		
		guard let data = context.data?.assumingMemoryBound(to: UInt8.self) else { return CGRect.zero }
		
		var lowX = width
		var lowY = height
		var highX: CGFloat = 0
		var highY: CGFloat = 0
		
		for yInt in 0..<Int(height) {
			let y = CGFloat(yInt)
			for xInt in 0..<Int(width) {
				let x = CGFloat(xInt)
				let pixelIndex = (width * y + x) * 4
				
				if data[Int(pixelIndex)] == 0 { continue }
				
				if data[Int(pixelIndex+1)] > 0xE0 && data[Int(pixelIndex+2)] > 0xE0 && data[Int(pixelIndex+3)] > 0xE0 { continue }
				
				if x < lowX {
					lowX = x
				}
				if x > highX {
					highX = x
				}
				if y < lowY {
					lowY = y
				}
				if y > highY {
					highY = y
				}
			}
		}
		
		var newHeight = highY - lowY + 1
		var newWidth = highX - lowX + 1
		
		
		// если нам нужно обрезанное изображение с изначальным соотношением сторон
		if keepRatio {
			let ratio = height / width
			
			let newRatio = newHeight / newWidth
			if newRatio < ratio {
				let heightInset = (newHeight / newRatio * ratio) - newHeight
				if lowY - (heightInset / 2) < 0 {
					highY = highY + (heightInset - lowY)
					lowY = 0
				} else if highY + (heightInset / 2) > height {
					lowY = lowY - (heightInset - (height - highY))
					highY = height
				} else {
					lowY = lowY - heightInset / 2
					highY = highY + heightInset / 2
				}
				newHeight = highY - lowY
			}
			if newRatio > ratio {
				let widthInset = (newWidth / ratio * newRatio) - newWidth
				if lowX - (widthInset / 2) < 0 {
					highX = highX + (widthInset - lowX)
					lowX = 0
				} else if highX + (widthInset / 2) > width {
					lowX = lowX - (widthInset - (width - highX))
					highX = width
				} else {
					lowX = lowX - widthInset / 2
					highX = highX + widthInset / 2
				}
				newWidth = highX - lowX
			}
			
			//		let inset: CGFloat = 10
			
			//		if lowX - inset >= 0 { lowX = lowX - inset }
			//		if lowY - inset >= 0 { lowY = lowY - inset }
			//		if highX + inset <= width { highX = highX + inset }
			//		if highY + inset <= height { highY = highY + inset }
		}
		
		if let dataRef = context.data {
			free(dataRef)
		}
		
		return CGRect(x: lowX, y: lowY, width: newWidth, height: newHeight)
	}
	
	class func createARGBBitmapContextFromImage(forSize size: CGSize) -> CGContext? {
		let width = Int(size.width)
		let height = Int(size.height)
		
		let bitmapBytesPerRow = width * 4
		let bitmapByteCount = bitmapBytesPerRow * height
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		
		guard let bitmapData = malloc(bitmapByteCount) else { return nil }
		let data = bitmapData.assumingMemoryBound(to: UInt8.self)
		for i in 0..<Int(bitmapByteCount) {
			data[i] = 0
		}
		
		let context = CGContext.init(data: bitmapData,
		                             width: width,
		                             height: height,
		                             bitsPerComponent: 8,
		                             bytesPerRow: bitmapBytesPerRow,
		                             space: colorSpace,
		                             bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
		return context
	}
}
