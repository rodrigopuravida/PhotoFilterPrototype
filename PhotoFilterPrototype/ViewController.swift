//
//  ViewController.swift
//  PhotoFilterPrototype
//
//  Created by Rodrigo Carballo on 1/12/15.
//  Copyright (c) 2015 Rodrigo Carballo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ImageSelectedProtocol,  UICollectionViewDataSource {
  let alertController = UIAlertController(title: "Photo Gallery", message: "Choose a Photo", preferredStyle: UIAlertControllerStyle.ActionSheet)
  let mainImageView = UIImageView()
  var collectionView : UICollectionView!
  var collectionViewYConstraint : NSLayoutConstraint!
  var originalThumbnail : UIImage!
  var filterNames = [String]()
  let imageQueue = NSOperationQueue()
  var gpuContext : CIContext!
  var thumbnails = [Thumbnail]()
  
  //nav bar buttons
  var doneButtonViewController : UIBarButtonItem!
  var shareButtonViewController : UIBarButtonItem!


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
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewFlowLayout)
    collectionViewFlowLayout.itemSize = CGSize(width: 100, height: 100)
    collectionViewFlowLayout.scrollDirection = .Horizontal
    rootView.addSubview(collectionView)
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    collectionView.dataSource = self
    collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "FILTER_CELL")
    
    let views = ["photoButton" : photoButton, "mainImageView" : self.mainImageView, "collectionView" : collectionView]
    
    self.setupConstraintsOnRootView(rootView, forViews: views)
    

    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //settign up buttons
    self.doneButtonViewController = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "donePressed")
    self.shareButtonViewController = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "sharePressed")
    self.navigationItem.rightBarButtonItem = self.shareButtonViewController
    
    let galleryOption = UIAlertAction(title: "Photo Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      println("gallery pressed")
      let galleryVC = GalleryViewController()
      galleryVC.delegate = self
      self.navigationController?.pushViewController(galleryVC, animated: true)
    }
    
    let galleryOptionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
      println("Cancel pressed")
    }
    
    let filterOption = UIAlertAction(title: "Filter", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.collectionViewYConstraint.constant = 20
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.view.layoutIfNeeded()
        
      })
    }
    
    self.navigationItem.rightBarButtonItem = doneButtonViewController

    
    self.alertController.addAction(galleryOption)
    self.alertController.addAction(galleryOptionCancel)
    self.alertController.addAction(filterOption)
    
    let options = [kCIContextWorkingColorSpace : NSNull()] //makes faster
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    
    self.setupThumbnails()
  }
  
  
  func setupThumbnails() {
    self.filterNames = ["CISepiaTone","CIPhotoEffectChrome", "CIPhotoEffectNoir"]
    for name in self.filterNames {
      let thumbnail = Thumbnail(filterName: name, operationQueue: self.imageQueue, context: self.gpuContext)
      //no images attached yet - only array of container thumbnails
      self.thumbnails.append(thumbnail)
    }
  }
  
  
  //MARK: ImageSelectedDelegate
  func controllerDidSelectImage(image: UIImage) {
    println("image selected")
    self.mainImageView.image = image
    self.generateThumbnail(image)
    
    for thumbnail in self.thumbnails {
      thumbnail.originalImage = self.originalThumbnail
      thumbnail.filteredImage = nil
    }
    self.collectionView.reloadData()
  }
  
  //MARK: Button Selectors
  
  func photoButtonPressed(sender : UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }
  
  func generateThumbnail(originalImage: UIImage) {
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
  
  func donePressed() {
    self.collectionViewYConstraint.constant = -120
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutIfNeeded()
      
    })
    self.navigationItem.rightBarButtonItem = self.shareButtonViewController
  }
  
  func sharePressed() {
    println("SharedPressed")
//    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
//      let compViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
//      compViewController.addImage(self.mainImageView.image)
//      self.presentViewController(compViewController, animated: true, completion: nil)
//    } else {
//      //tell user to sign into to twitter to use this feature
//    }
    
  }
  
  //MARK: UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.thumbnails.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as GalleryCell
    let thumbnail = self.thumbnails[indexPath.row]
    //only display if a thumbnaiil image exists
    if thumbnail.originalImage != nil {
      if thumbnail.filteredImage == nil {
        thumbnail.generateFilteredImage()
        cell.imageView.image = thumbnail.filteredImage!
      } }
    //cell.imageView.image = self.originalThumbnail
    return cell
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
    
    let mainImageViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[mainImageView]-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(mainImageViewConstraintsHorizontal)
    let mainImageViewConstraintsVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[mainImageView]-30-[photoButton]", options: nil, metrics: nil, views: views)
    rootView.addConstraints(mainImageViewConstraintsVertical)

    
    let collectionViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintsHorizontal)
    let collectionViewConstraintHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(100)]", options: nil, metrics: nil, views: views)
    self.collectionView.addConstraints(collectionViewConstraintHeight)
    let collectionViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(-120)-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintVertical)
    self.collectionViewYConstraint = collectionViewConstraintVertical.first as NSLayoutConstraint

  }
  
  
  
}

