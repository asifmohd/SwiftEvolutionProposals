//
//  File.swift
//  Swift Evolution Proposals
//
//  Created by Asif on 30/10/16.
//  Copyright © 2016 Vibgyor Applications. All rights reserved.
//

import Foundation
import UIKit

protocol ReusableCell {
	static var ReuseIdentifier: String { get }
	static var NibName: String { get }
}

extension ReusableCell {
	static func nib() -> UINib? {
		if NibName.characters.count > 0 {
			return UINib(nibName: NibName, bundle: nil)
		} else {
			return nil
		}
	}
}

extension ReusableCell where Self: UITableViewCell {
	static func registerNibForTable(_ table: UITableView) {
		if let nib = self.nib() {
			table.register(nib, forCellReuseIdentifier: self.ReuseIdentifier)
		}
	}
}

extension ReusableCell where Self: UITableViewHeaderFooterView {
  static func registerNibForTable(_ table: UITableView) {
    if let nib = self.nib() {
      table.register(nib, forHeaderFooterViewReuseIdentifier: self.ReuseIdentifier)
    }
  }
}

extension ReusableCell where Self: UICollectionViewCell {
	static func registerNibForCollection(_ collection: UICollectionView) {
		if let nib = self.nib() {
			collection.register(nib, forCellWithReuseIdentifier: self.ReuseIdentifier)
		}
	}
}

extension ReusableCell where Self: UICollectionReusableView {
    static func registerNibForCollection(_ collection: UICollectionView) {
        if let nib = self.nib() {
            collection.register(nib, forCellWithReuseIdentifier: self.ReuseIdentifier)
        }
    }
}
