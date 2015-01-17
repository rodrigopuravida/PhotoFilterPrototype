//
//  ViewController.swift
//  PhotoFilterPrototype
//
//  Created by Rodrigo Carballo on 1/12/15.
//  Copyright (c) 2015 Rodrigo Carballo. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, ImageSelectedProtocol,  UICollectionViewDataSource, UICollectionViewDelegate ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
    
  let alertController = UIAlertController(title: NSLocalizedString("Photo Collection", comment: "Title for AlertController"), message: NSLocalizedString("Please Select", comment: "For selection of picture or photo"), preferredStyle: UIAlertControllerStyle.ActionSheet)
  let mainImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
  var collectionView : UICollectionView!
  var collectionViewYConstraint : NSLayoutConstraint!
  var originalThumbnail : UIImage!
  var filterNames = [String]()
  let imageQueue = NSOperationQueue()
  var gpuContext : CIContext!
  var thumbnails = [Thumbnail]()
  var delegate : ImageSelectedProtocol!
  var originalImage : UIImage?
  var tap = UITapGestureRecognizer()
  var numberOfTapsRequired =  2
  //let rootView : UIView!
  
  //nav bar buttons
  var doneButtonViewController : UIBarButtonItem!
  var shareButtonViewController : UIBarButtonItem!
    
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    mainImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    mainImageView.backgroundColor = UIColor.whiteColor()
    //TODO: INVESTIGATE: WHy setting up an image here hoses everything???
    //mainImageView.image = UIImage(named: "Filter.jpg")
    //mainImageView.backgroundColor = UIColor(patternImage: UIImage(named: "Filter.jpg")!)
    rootView.addSubview(mainImageView)
    mainImageView.contentMode = UIViewContentMode.ScaleAspectFill
    mainImageView.clipsToBounds = true
    let photoButton = UIButton()
    photoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(photoButton)
    photoButton.setTitle(NSLocalizedString("My Pictures", comment: "To select pictures while pressing button"), forState: .Normal)
    photoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
    photoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewFlowLayout)
    collectionViewFlowLayout.itemSize = CGSize(width: 50, height: 50)
    collectionViewFlowLayout.scrollDirection = .Horizontal
    rootView.addSubview(collectionView)
    self.collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "FILTER_CELL")
    //views dictionary
    let views = ["photoButton" : photoButton, "mainImageView" : self.mainImageView, "collectionView" : collectionView]
    //addconstraints
    self.setupConstraintsOnRootView(rootView, forViews: views)
    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //settign up buttons
    self.doneButtonViewController = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done Title for button"), style: UIBarButtonItemStyle.Done, target: self, action: "donePressed")
    self.shareButtonViewController = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "sharePressed")
    self.navigationItem.rightBarButtonItem = self.shareButtonViewController
    //alert controller for Photo Gallery
    let galleryOption = UIAlertAction(title: NSLocalizedString("Photo Gallery", comment: "Photo Gallery"), style: UIAlertActionStyle.Default) { (action) -> Void in
      println("gallery pressed")
      //Create an instance of view controller and assign self as delegate for the didSelectImageFuncitonn
      let galleryVC = GalleryViewController()
      galleryVC.delegate = self
      self.navigationController?.pushViewController(galleryVC, animated: true)
    }
    let galleryOptionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel operation"), style: UIAlertActionStyle.Cancel) { (action) -> Void in
      println("Cancel pressed")
    }    
    let filterOption = UIAlertAction(title: NSLocalizedString("Filter", comment: "Button text to apply filter"), style: UIAlertActionStyle.Default) { (action) -> Void in
      
      //Animation code for filter - tip from John Vogel
      let constraints = self.view.constraints() as [NSLayoutConstraint]
      for code in constraints{
        if code.identifier != nil {
          switch code.identifier!{
          case "filterVerticalConstraint":
            code.constant = 10
          case "imageViewBottomConstraint":
            code.constant = 100
          case "imageViewTopConstraint":
            code.constant = 75
          case "imageViewLeftConstraint":
            code.constant = 25
          case "imageViewRightConstraint":
            code.constant = 25
          default:
            break
          }
        }
      }
      self.collectionViewYConstraint.constant = 20
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.view.layoutIfNeeded()
        
      })
    }
    
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      let cameraOption = UIAlertAction(title: NSLocalizedString("Select camera", comment: "Title for Select Camera option"), style: .Default, handler: { (action) -> Void in
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
      })
      self.alertController.addAction(cameraOption)
    }
    
    let photoOption = UIAlertAction(title: NSLocalizedString("Photos", comment: "Photos for Alert option"), style: .Default) { (action) -> Void in
      let photosVC = PhotoViewController()
      photosVC.destinationImageSize = self.mainImageView.frame.size
      photosVC.delegate = self
      self.navigationController?.pushViewController(photosVC, animated: true)
    }
    self.alertController.addAction(photoOption)
    self.navigationItem.rightBarButtonItem = doneButtonViewController
    self.alertController.addAction(galleryOption)
    self.alertController.addAction(galleryOptionCancel)
    self.alertController.addAction(filterOption)
    let options = [kCIContextWorkingColorSpace : NSNull()] //makes faster
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    self.setupThumbnails()
  }
  
  override func viewDidAppear(animated: Bool) {
    self.originalImage = self.mainImageView.image?
  }
  
  
  func setupThumbnails() {
    self.filterNames = ["CISepiaTone","CIPhotoEffectChrome", "CIPhotoEffectNoir"]
    for name in self.filterNames {
      let thumbnail = Thumbnail(filterName: name, operationQueue: self.imageQueue, context: self.gpuContext)
      //no images attached yet - only array of container thumbnails
      self.thumbnails.append(thumbnail)
    }
    
    //setting up doble tap
    tap.addTarget(self, action: "tappedImage")
    tap.numberOfTapsRequired = self.numberOfTapsRequired
    mainImageView.userInteractionEnabled = true
    mainImageView.addGestureRecognizer(tap)

  }
  
  
  //MARK: ImageSelectedDelegate
  //We are here from Gallery View Controller as View Controller is the delegate for this function
  func controllerDidSelectImage(image: UIImage) {
    println("image selected")
    self.mainImageView.image = image
    self.generateThumbnail(image)
    
    //this fires as soon as I click on an Image
    
    for thumbnail in self.thumbnails {
      thumbnail.originalImage = self.originalThumbnail
      thumbnail.filteredImage = nil
    }
    self.collectionView.reloadData()
  }
  
  //MARK: UIImagePickerController
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    let image = info[UIImagePickerControllerEditedImage] as? UIImage
    self.controllerDidSelectImage(image!)
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  //MARK: Button Selectors
  
  func photoButtonPressed(sender : UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
    println("Pressed button")
  }
  
  func generateThumbnail(originalImage: UIImage) {
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
  
  func donePressed() {
    
    let constraints = self.view.constraints() as [NSLayoutConstraint]
    for code in constraints{
      if code.identifier != nil {
        switch code.identifier!{
        case "filterVerticalConstraint":
          code.constant = -120
        case "imageViewBottomConstraint":
          code.constant = 30
        case "imageViewTopConstraint":
          code.constant = 72
        case "imageViewLeftConstraint":
          code.constant = 0
        case "imageViewRightConstraint":
          code.constant = 0
        default:
          break
        }
      }
    }
    
    //self.collectionViewYConstraint.constant = -120
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutIfNeeded()
      
    })
    self.navigationItem.rightBarButtonItem = self.shareButtonViewController
    self.navigationItem.leftBarButtonItem = nil
  }
  
  func sharePressed() {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
      let compViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      compViewController.addImage(self.mainImageView.image)
      self.presentViewController(compViewController, animated: true, completion: nil)
    } else {
      println("Not able to connect to Twitter")
    }
    
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
    
    return cell
  }
  
  //dont forger self.delegate for this to fire in viewDidLoad
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let thumbnail = self.thumbnails[indexPath.row]
    
    //start filtering of main image view
    
    let startImage = CIImage(image: self.originalImage!)
    let filter = CIFilter(name: self.thumbnails[indexPath.row].filterName)
    filter.setDefaults()
    filter.setValue(startImage, forKey: kCIInputImageKey)
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage
    let extent = result.extent()
    let imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
    self.mainImageView.image = UIImage(CGImage: imageRef)
    
  }
  
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //MARK: Autolayout Constraints - tip courtesy from John Vogel
  
  func setupConstraintsOnRootView(rootView : UIView, forViews views : [String : AnyObject]) {
    
    var constraintsArray = [NSLayoutConstraint]()
    let photoButtonConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[photoButton]-20-|", options: nil, metrics: nil, views: views) as [NSLayoutConstraint]
    rootView.addConstraints(photoButtonConstraintVertical)
    let photoButton = views["photoButton"] as UIView!
    let photoButtonConstraintHorizontal = NSLayoutConstraint(item: photoButton, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
    rootView.addConstraint(photoButtonConstraintHorizontal)
    photoButton.setContentHuggingPriority(750, forAxis: UILayoutConstraintAxis.Vertical)

    
    //adding to constraint array
    for constraint in photoButtonConstraintVertical as [NSLayoutConstraint]{
      constraintsArray.append(constraint)
    }
    constraintsArray.append(photoButtonConstraintHorizontal)
    
    //constraints for the image view
    let mainImageViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[mainImageView]-|", options: nil, metrics: nil, views: views) as [NSLayoutConstraint]
    rootView.addConstraints(mainImageViewConstraintsHorizontal)
    //creating identifiers that will be referenced later on to add or decrease 'constants'
    mainImageViewConstraintsHorizontal[0].identifier = "imageViewLeftConstraint"
    mainImageViewConstraintsHorizontal[1].identifier = "imageViewRightConstraint"
    let mainImageViewConstraintsVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-65-[mainImageView]-10-[photoButton]", options: nil, metrics: nil, views: views) as [NSLayoutConstraint]
    rootView.addConstraints(mainImageViewConstraintsVertical)
    mainImageViewConstraintsVertical[0].identifier = "imageViewTopConstraint"
    mainImageViewConstraintsVertical[1].identifier = "imageViewBottomConstraint"

    for c in mainImageViewConstraintsVertical as [NSLayoutConstraint]{
      constraintsArray.append(c)
    }
    for c in mainImageViewConstraintsHorizontal as [NSLayoutConstraint]{
      constraintsArray.append(c)
    }
    
    let collectionViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: views) as [NSLayoutConstraint]
    rootView.addConstraints(collectionViewConstraintsHorizontal)
    let collectionViewConstraintHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(100)]", options: nil, metrics: nil, views: views) as [NSLayoutConstraint]
    self.collectionView.addConstraints(collectionViewConstraintHeight)
    let collectionViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(-120)-|", options: nil, metrics: nil, views: views) as [NSLayoutConstraint]
    collectionViewConstraintVertical[0].identifier = "filterVerticalConstraint"
    rootView.addConstraints(collectionViewConstraintVertical)
    
    for c in collectionViewConstraintsHorizontal as [NSLayoutConstraint]{
      constraintsArray.append(c)
      
      for c in collectionViewConstraintVertical as [NSLayoutConstraint]{
        constraintsArray.append(c)
      }
      
      //add constraints to main view
      rootView.addConstraints(constraintsArray)
    }
    self.collectionViewYConstraint = collectionViewConstraintVertical.first as NSLayoutConstraint!
  }
  
  //MARK: Double tap function recognizer for main Image View
  func tappedImage() {
 
    println("I have double tapped")
    //controllerDidSelectImage(mainImageView.image!)
    //WE are redoing what we did when needed to resize image for image filter showing
    //TODO: Refactor this conde into Helper Class
    let constraints = self.view.constraints() as [NSLayoutConstraint]
    for code in constraints{
      if code.identifier != nil {
        switch code.identifier!{
        case "filterVerticalConstraint":
          code.constant = 10
        case "imageViewBottomConstraint":
          code.constant = 100
        case "imageViewTopConstraint":
          code.constant = 75
        case "imageViewLeftConstraint":
          code.constant = 25
        case "imageViewRightConstraint":
          code.constant = 25
        default:
          break
        }
      }
    }
    self.collectionViewYConstraint.constant = 20
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })

  }

}

