//
//  GalleryViewController.swift
//  PhotoFilterPrototype
//
//  Created by Rodrigo Carballo on 1/12/15.
//  Copyright (c) 2015 Rodrigo Carballo. All rights reserved.
//

import UIKit

protocol ImageSelectedProtocol {
  func controllerDidSelectImage(UIImage) -> Void
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var collectionView : UICollectionView!
  var images = [UIImage]()
  var delegate : ImageSelectedProtocol?
  var photoPic = String()
  var collectionViewFlowLayout : UICollectionViewFlowLayout!
 
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    self.collectionViewFlowLayout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    
    rootView.addSubview(self.collectionView)
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    collectionViewFlowLayout.itemSize = CGSize(width: 200, height: 200)
    
    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.whiteColor()
    self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERY_CELL")
    
    //iterating over range of pictures
    for var i = 1; i <= 10; i++ {
      
      self.photoPic = "photo\(i).jpeg"

      self.images.append(UIImage(named: photoPic)!)
    }
    let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "myCollectionViewPinched:")
    self.collectionView.addGestureRecognizer(pinchRecognizer)
    
  }
  
  //MARK: Gesture recognizers
  func myCollectionViewPinched(sender: UIPinchGestureRecognizer) {
    
    switch sender.state {
    case .Began:
      println("Pimching started")
    case .Changed:
      println("Pinching changed")
    case .Ended:
      println("Pimching ended")
      self.collectionView.performBatchUpdates({ () -> Void in
        println(sender.velocity)
        if sender.velocity > 0 {
          //make it bigger
          let newSize = CGSize(width: self.collectionViewFlowLayout.itemSize.width * 2, height: self.collectionViewFlowLayout.itemSize.height * 2)
          self.collectionViewFlowLayout.itemSize = newSize
        }
        else if sender.velocity < 0 {
          //make it smaller
          let newSize = CGSize(width: self.collectionViewFlowLayout.itemSize.width
            * 0.5, height: self.collectionViewFlowLayout.itemSize.height * 0.5)
          self.collectionViewFlowLayout.itemSize = newSize
          
        }
      }, completion: { (finished) -> Void in
        println("Did I finish")
      })
      
    default:
      println("Default case")
    }
 
    println("Images have been pinched")
    
  }
  
  //MARK: UICollectionViewDataSource
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.images.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
    let image = self.images[indexPath.row]
    cell.imageView.image = image
    return cell
  }
  
  //MARK: UICollectionViewDelegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    self.delegate?.controllerDidSelectImage(self.images[indexPath.row])
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
 
}
