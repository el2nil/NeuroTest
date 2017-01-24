//
//  Neuron.swift
//  NeuroTest
//
//  Created by Danil Denshin on 09.01.17.
//  Copyright © 2017 el2Nil. All rights reserved.
//

import Foundation
import UIKit

class Neuron {
	
	private let imageSide: CGFloat
	// порог чувствительности к значению alpha.
	private var alphaSensivity: Int = 100
	
	// предел суммы, которая считается положительным ответом. Выбрано эксперементально.
	private let recognizeLimit: Int
	
	let name: String
	var input: [[Int]]
	var sum: Int {
		var sum: Int = 0
		for y in 0..<Int(imageSide) {
			for x in 0..<Int(imageSide) {
				sum += input[y][x] * weight[y][x]
			}
		}
		return sum
	}
	var weight: [[Int]]
	
	init(name: String, resolution: CGFloat) {
		self.name = name
		self.imageSide = resolution
		self.recognizeLimit = Int(imageSide * imageSide) / 10 * 5
		self.input = {
			let row = Array<Int>(repeating: 0, count: Int(resolution))
			let talbe = Array<Array<Int>>(repeating: row, count: Int(resolution))
			return talbe
		}()
		self.weight = {
			let row = Array<Int>(repeating: 0, count: Int(resolution))
			let talbe = Array<Array<Int>>(repeating: row, count: Int(resolution))
			return talbe
		}()
	}
	
	func result() -> Bool {
		return sum >= recognizeLimit
	}
	
	func incrementWeight() {
		for y in 0..<Int(imageSide) {
			for x in 0..<Int(imageSide) {
				weight[y][x] += input[y][x]
			}
		}
	}
	
	func decrementWeight() {
		for y in 0..<Int(imageSide) {
			for x in 0..<Int(imageSide) {
				weight[y][x] -= input[y][x]
			}
		}
	}
	
	func printInput() {
		for y in 0..<Int(imageSide) {
			var str = ""
			for x in 0..<Int(imageSide) {
				let alpha = input[y][x]
				str += String(alpha)
			}
			print(str)
		}
		print("")
	}
	
	func printWeight() {
		for y in 0..<Int(imageSide) {
			var str = ""
			for x in 0..<Int(imageSide) {
				let alpha = weight[y][x]
				str += String(alpha)
			}
			print(str)
		}
		print("")
	}
	
	func getImageFromMassive(_ massive: [[Int]]) -> UIImage? {
		
		let contextSize = CGSize(width: imageSide, height: imageSide)
		guard let context = UIImage.createARGBBitmapContextFromImage(forSize: contextSize) else { return nil }
		
		guard let data = context.data?.assumingMemoryBound(to: UInt8.self) else { return nil }
		
		for y in 0..<Int(imageSide) {
			for x in 0..<Int(imageSide) {
				let pixelIndex = (y * Int(imageSide) + x) * 4
				let alpha = massive[y][x] * 25
				data[pixelIndex] = (alpha < 0 ? 0 : UInt8(alpha))
			}
		}
		let image = UIImage(cgImage: context.makeImage()!)
//		free(context.data!)
		return image
		
	}
	
	
	// метод преобразует входное изображение к квадрату со стороной imageSide и подает на вход нейрона
	func loadInputImage(image: UIImage) {
		
		// обрезаем лишние белые поля изображения
		let trimImage = image.trim()
		
		let trimImageMaxSide = trimImage.size.width > trimImage.size.height ? trimImage.size.width : trimImage.size.height
		
		// создаем контекст и область памяти для изображения нужного разрешения
		let contextSize = CGSize(width: imageSide, height: imageSide)
		guard let context = UIImage.createARGBBitmapContextFromImage(forSize: contextSize) else { return }
		
		// создаем прямоуголник, чтобы он влез в нужное нам разрешение, с соотношением
		// сторон как у обрезанного входного изображения.
		// иначе изображение растянется и деформируется
		let scale = trimImageMaxSide / imageSide
		let newImageSize = CGSize(width: trimImage.size.width / scale, height: trimImage.size.height / scale)
		let newImageRect = CGRect(center: CGPoint(x: imageSide/2, y: imageSide/2), width: newImageSize.width, height: newImageSize.height)
		
		context.draw(trimImage.cgImage!, in: newImageRect)
		
		// заполняем вхоные данные значением alpha, т.к. цвет у нас черный и все остальные байты равны 0
		guard let data = context.data?.assumingMemoryBound(to: UInt8.self) else { return }
		for y in 0..<Int(imageSide) {
			for x in 0..<Int(imageSide) {
				input[y][x] = 0
				let pixelIndex = (y * Int(imageSide) + x) * 4
				if Int(data[pixelIndex]) > alphaSensivity {
					input[y][x] = 1
				}
			}
		}
		
		free(context.data)
	}
	
	func getWeightData() -> Data {
		return NSKeyedArchiver.archivedData(withRootObject: weight)
	}
	
	func loadWeightData(_ data: Data) {
		weight = NSKeyedUnarchiver.unarchiveObject(with: data) as! [[Int]]
	}
	
}
