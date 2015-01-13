//
//  ViewController.swift
//  PhotoFilterPrototype
//
//  Created by Rodrigo Carballo on 1/12/15.
//  Copyright (c) 2015 Rodrigo Carballo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ImageSelectedProtocol {
  
  let alertController = UIAlertController(title: "Photo Gallery", message: "Choose a Photo", preferredStyle: UIAlertControllerStyle.ActionSheet)
  let mainImageView = UIImageView()
  let collectionView : UICollectionView!
  let collectionViewyConstraint : NSLayoutConstraint!
  

  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    rootView.addSubview(self.mainImageView)
    self.mainImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.mainImageView.backgroundColor = UIColor.yellowColor()
    let photoButton = UIButton()
    photoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(photoButton)
    photoButton.setTitle("My Photos", forState: .Normal)
    photoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
    photoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    
    //This is new code to look at from Tueesday class
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    //self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewFlowLayout)

    let views = ["photoButton" : photoButton, "mainImageView" : self.mainImageView]
    self.setupConstraintsOnRootView(rootView, forViews: views)
    
    //rootView.backgroundColor = UIColor(patternImage: UIImage(named: "IntroImage.jpeg")!)

    self.view = rootView
  }
  
  
  
  //MARK: ImageSelectedDelegate
  func controllerDidSelectImage(image: UIImage) {
    println("image selected")
    self.mainImageView.image = image
    //self.collectionView.reloadData()
  }
  
  
  //MARK: Button Selectors
  
  func photoButtonPressed(sender : UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let galleryOption = UIAlertAction(title: "Photo Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      println("gallery pressed")
      let galleryVC = GalleryViewController()
      galleryVC.delegate = self
      self.navigationController?.pushViewController(galleryVC, animated: true)
    }
    
    let galleryOptionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
      println("Cancel pressed")
    }
    
        self.alertController.addAction(galleryOption)
        self.alertController.addAction(galleryOptionCancel)
    
  }
  
  //MARK: Image selected delegate
//  func controllerDidSelectImage(image: UIImage) {
//    println("Image selected")
//    self.mainImageView.image = image
//    self.collectionView.reloadData()
//  
//  }
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //MARK: Autolayout Constraints
  func setupConstraintsOnRootView(rootView : UIView, forViews views : [String : AnyObject]) {
    let photoButtonConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[photoButton]-30-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(photoButtonConstraintVertical)
    let photoButton = views["photoButton"] as UIView!
    let photoButtonConstraintHorizontal = NSLayoutConstraint(item: photoButton, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
    rootView.addConstraint(photoButtonConstraintHorizontal)
    let mainImageViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[mainImageView]-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(mainImageViewConstraintHorizontal)
    let mainImageViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[mainImageView]-[photoButton]", options: nil, metrics: nil, views: views)
    rootView.addConstraints(mainImageViewConstraintVertical)
   

  }


}

