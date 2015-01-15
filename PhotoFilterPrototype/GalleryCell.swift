//
//  GalleryCell.swift
//  PhotoFilterPrototype
//
//  Created by Rodrigo Carballo on 1/12/15.
//  Copyright (c) 2015 Rodrigo Carballo. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
  let imageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(self.imageView)
    //self.backgroundColor = UIColor.whiteColor()
    imageView.frame = self.bounds
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    imageView.layer.masksToBounds = true
    let views = ["imageView" : imageView]
    //adding constraints for the image pincher
    let imageViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: nil, metrics: nil, views: views)
    self.addConstraints(imageViewConstraintsHorizontal)
    
    let imageViewConstraintsVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: nil, metrics: nil, views: views)
    self.addConstraints(imageViewConstraintsVertical)

  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
