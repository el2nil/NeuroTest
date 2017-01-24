//
//  extention_CGRect.swift
//  NeuroTest
//
//  Created by Danil Denshin on 09.01.17.
//  Copyright © 2017 el2Nil. All rights reserved.
//

import UIKit

extension CGRect {
	
	var center: CGPoint { return CGPoint(x: midX, y: midY) }
	
	init(center: CGPoint, width: CGFloat, height: CGFloat) {
		self.init(x: center.x - width/2, y: center.y - height/2, width: width, height: height)
	}
}
