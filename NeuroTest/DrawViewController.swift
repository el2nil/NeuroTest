//
//  DrawViewController.swift
//  NeuroTest
//
//  Created by Danil Denshin on 07.01.17.
//  Copyright © 2017 el2Nil. All rights reserved.
//

import UIKit

class DrawViewController: UIViewController, UITextFieldDelegate {
	
	let characters = "1234567890"
	// изображение преобразуется к квадрату с заданным разрешением для подачи на вход нейросети
	lazy var neuroWeb: NeuroWeb = {
		let newWeb = NeuroWeb(characters: self.characters, resolution: 60)
		return newWeb
	}()
	
	// флаг, сигнализирующий о том, что линия непрерывная
	var swiped = false
	// вспомогательная переменная для непрерывного рисования
	private var lastPoint = CGPoint.zero
	
	let lineWidth: CGFloat = 30
	
	@IBOutlet weak var mainImageView: UIImageView!
	@IBOutlet weak var tempImageView: UIImageView!
	
	@IBAction func clear(_ sender: UIBarButtonItem) {
		mainImageView.image = nil
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return true
	}
	
	// когда пользователь вводит число для изучения, строка не должна содержать лишних символов 
	// и должна быть не длиннее 1
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if string == "" {
			return true
		}
		if let text = textField.text, text.characters.count == 0 {
			if let char = string.characters.first, characters.characters.contains(char) {
				return true
			}
		}
		return false
	}
	
	// показывает alert чтобы выбрать и изучить цифру
	private func learnSymbol() {
		let alert = UIAlertController(title: nil,
		                              message: "Введите цифру, чтобы выучить",
		                              preferredStyle: .alert)
		alert.addTextField { (textField) in
			textField.delegate = self
		}
		alert.addAction(UIAlertAction(title: "Выучить",
		                              style: .default,
		                              handler: { [weak self] (action) in
										if let symbol = alert.textFields?.first?.text {
											self?.neuroWeb.learnSymbol(symbol)
//											if let neuron = self?.neuroWeb.web.first(where: { $0.name == symbol }) {
//												self?.tempImageView.image = neuron.getImageFromMassive(neuron.weight)
//											}
										}
		}))
		alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	// сохранение и загрузка данных в Core Data
	@IBAction func loadData(_ sender: UIBarButtonItem) {
		neuroWeb.load()
	}
	
	@IBAction func saveData(_ sender: UIBarButtonItem) {
		neuroWeb.save()
	}
	
	@IBAction func recognize(_ sender: UIBarButtonItem) {
		
		if let image = mainImageView.image {
			if let symbol = neuroWeb.recognizeSymbol(image: image) {
				let alert = UIAlertController(title: nil, message: "Я считаю, что это цифра: \(symbol)", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Неправильно", style: .default, handler: { [weak self] action in
					self?.learnSymbol()
				}))
				alert.addAction(UIAlertAction(
					title: "Правильно",
					style: .default,
					handler: nil))
				present(alert, animated: true, completion: nil)
			} else {
				let alert = UIAlertController(title: nil,
				                              message: "Я не могу распознать цифру",
				                              preferredStyle: .alert)
				alert.addTextField(configurationHandler: { [weak self] (textField) in
					textField.delegate = self
				})
				alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
				alert.addAction(UIAlertAction(title: "Выучить",
				                              style: .default,
				                              handler: { [weak self] (action) in
												if let symbol = alert.textFields?.first?.text {
													self?.neuroWeb.learnSymbol(symbol)
//													if let neuron = self?.neuroWeb.web.first(where: { $0.name == symbol }) {
//														self?.tempImageView.image = neuron.getImageFromMassive(neuron.weight)
//													}
													
												}
				}))
				present(alert, animated: true, completion: nil)
			}
			
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		swiped = false
		if let touch = touches.first {
			lastPoint = touch.location(in: mainImageView)
		}
	}
	
	private func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
		
		UIGraphicsBeginImageContext(mainImageView.bounds.size)
		
		let context = UIGraphicsGetCurrentContext()
		mainImageView.image?.draw(in: mainImageView.bounds)
		
		context?.move(to: fromPoint)
		context?.addLine(to: toPoint)
		
		context?.setLineCap(.round)
		context?.setLineWidth(lineWidth)
		context?.setStrokeColor(UIColor.black.cgColor)
		context?.setBlendMode(.normal)
		
		context?.strokePath()
		
		mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		swiped = true
		if let touch = touches.first {
			let currentPoint = touch.location(in: mainImageView)
			drawLine(from: lastPoint, to: currentPoint)
			lastPoint = currentPoint
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if !swiped {
			drawLine(from: lastPoint, to: lastPoint)
		}
	}
	
	
	
	
}
