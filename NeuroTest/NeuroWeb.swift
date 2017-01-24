//
//  NeuroWeb.swift
//  NeuroTest
//
//  Created by Danil Denshin on 09.01.17.
//  Copyright © 2017 el2Nil. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class NeuroWeb {
	
	let characters: String
	let resolution: CGFloat
	var web: [Neuron] = []
	
	init(characters: String, resolution: CGFloat) {
		self.resolution = resolution
		self.characters = characters
		for character in characters.characters {
			let neuron = Neuron(name: String(character), resolution: resolution)
			web.append(neuron)
		}
	}
	
	func recognizeSymbol(image: UIImage) -> String? {
		for neuron in web {
			neuron.loadInputImage(image: image)
		}
		return web.first(where: { $0.result() })?.name
	}
	
	func learnSymbol(_ symbol: String) {
		for neuron in web {
			if (neuron.name == symbol && neuron.result())
				|| (neuron.name != symbol && !neuron.result()) {
				// правильный ответ, ничего не делаем
			} else if neuron.name == symbol && !neuron.result() {
				neuron.incrementWeight()
			} else if neuron.name != symbol && neuron.result() {
				neuron.decrementWeight()
			}
		}
	}
	
	func load() {
		let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
		let context: NSManagedObjectContext! = container?.newBackgroundContext()
		
		let request: NSFetchRequest<NeuronCD> = NeuronCD.fetchRequest()
		request.predicate = NSPredicate(format: "TRUEPREDICATE")
		
		if let result = try? context.fetch(request) {
			for neuronCD in result {
				if let neuron = web.first(where: { $0.name == neuronCD.name }) {
					neuron.loadWeightData(neuronCD.weight as! Data)
				} else {
					let neuron = Neuron(name: neuronCD.name!, resolution: resolution)
					neuron.loadWeightData(neuronCD.weight as! Data)
					web.append(neuron)
				}
			}
		}
		
		if let storeURL = container?.persistentStoreDescriptions.first?.url {
			print("Data loaded from: \(storeURL.description)")
		}
	}
	
	func save() {
		
		let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
		let context: NSManagedObjectContext! = container?.newBackgroundContext()
		
		let request: NSFetchRequest<NeuronCD> = NeuronCD.fetchRequest()
		request.predicate = NSPredicate(format: "TRUEPREDICATE")
		
		if let result = try? context.fetch(request) {
			for neuron in web {
				if let storedNeuron = result.first(where: { $0.name == neuron.name }) {
					storedNeuron.weight = neuron.getWeightData() as NSData
				} else {
					let neuronCD = NeuronCD(context: context)
					neuronCD.name = neuron.name
					neuronCD.weight = neuron.getWeightData() as NSData
				}
			}
		}
		
		try? context?.save()
		
		if let storeURL = container?.persistentStoreDescriptions.first?.url {
			print("Data saved to: \(storeURL.description)")
		}
	}
}
