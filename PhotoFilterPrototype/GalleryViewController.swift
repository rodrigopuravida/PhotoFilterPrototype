//
//  GalleryViewController.swift
//  PhotoFilterPrototype
//
//  Created by Rodrigo Carballo on 1/12/15.
//  Copyright (c) 2015 Rodrigo Carballo. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource {
  
  var collectionView : UICollectionView!
  var images = [UIImage]()
  var imageArray = [String]()
 
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    rootView.addSubview(self.collectionView)
    self.collectionView.dataSource = self
    collectionViewFlowLayout.itemSize = CGSize(width: 200, height: 200)
    
    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.whiteColor()
    self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERY_CELL")
    
//    for var i = 1; i <= 6; i++ {
//      
//      var test = "photo\(i).jpeg"
//      println(test)
//      
//      
//      //self.images.append(UIImage(named: imageArray[i])!)
//      
//    }
    
    let image1 = UIImage(named: "photo1.jpeg")
    let image2 = UIImage(named: "photo2.jpeg")
    let image3 = UIImage(named: "photo3.jpeg")
    let image4 = UIImage(named: "photo4.jpeg")
    let image5 = UIImage(named: "photo5.jpeg")
    let image6 = UIImage(named: "photo6.jpeg")
    self.images.append(image1!)
    self.images.append(image2!)
    self.images.append(image3!)
    self.images.append(image4!)
    self.images.append(image5!)
    self.images.append(image6!)
    // Do any additional setup after loading the view.
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
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
