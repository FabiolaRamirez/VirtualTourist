//
//  DetailViewController.swift
//  VisualTourist
//
//  Created by Fabiola Ramirez on 3/18/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class DetailViewController: UIViewController {

    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var coordinateSelected:CLLocationCoordinate2D!
    let spacingBetweenItems:CGFloat = 5
    let totalCellCount:Int = 25
    
    var stack:CoreDataStack!
    var coreDataPin:Pin!
    var savedImages:[Photo] = []
    var selectedToDelete:[Int] = [] {
        
        didSet {
            if selectedToDelete.count > 0 {
                newCollectionButton.setTitle("Remove selected pictures", for: .normal)
            } else {
                newCollectionButton.setTitle("New collection", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Flow Layout
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = spacingBetweenItems
        flowLayout.minimumLineSpacing = spacingBetweenItems
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        //Collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        newCollectionButton.isHidden = false
        
        
        collectionView.allowsMultipleSelection = true
        addAnnotationToMap()
        
        //Fetch Photos
        let savedPhoto = preloadSavedPhoto()
        if savedPhoto != nil && savedPhoto?.count != 0 {
            savedImages = savedPhoto!
            showSavedResult()
        } else {
            showNewResult()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //Core Data Stack
    func getCoreDataStack() -> CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    //Fetch Results
    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let stack = getCoreDataStack()
        let fetchedRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchedRequest.sortDescriptors = []
        fetchedRequest.predicate = NSPredicate(format: "pin = %@", argumentArray: [coreDataPin!])
        
        return NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    
    }
    
    //Saved Photo
    func preloadSavedPhoto() -> [Photo]? {
        
        do {
            var photoArray:[Photo] = []
            let fetchedResultsController = getFetchedResultsController()
            try fetchedResultsController.performFetch()
            let photoCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            
            for index in 0..<photoCount {
                
                photoArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Photo)
            }
            
            return photoArray.sorted(by: {$0.index < $1.index})
            
        } catch {
            
            return nil
        }
    }
    
    
    @IBAction func getNewCollection(_ sender: UIButton) {
        
        if selectedToDelete.count > 0 {
            removeSelectedPicturesAtCoreData()
            unselectAllSelectedCollectionViewCell()
            savedImages = preloadSavedPhoto()!
            showSavedResult()
            
        } else {
            showNewResult()
        }
    }
    
    func unselectAllSelectedCollectionViewCell() {
        
        for indexPath in collectionView.indexPathsForSelectedItems! {
            collectionView.deselectItem(at: indexPath, animated: false)
            collectionView.cellForItem(at: indexPath)?.contentView.alpha = 1
        }
    }
    
    //Remove Photos
    func removeSelectedPicturesAtCoreData() {
        
        for index in 0..<savedImages.count {
            
            if selectedToDelete.contains(index) {
                getCoreDataStack().context.delete(savedImages[index])
            }
        }
        
        do {
            try getCoreDataStack().saveContext()
        } catch {
            print("Remove photo from Core Data failed")
        }
        selectedToDelete.removeAll()
    }
    

    func showSavedResult() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func showNewResult() {
        newCollectionButton.isEnabled = false
        deleteExistingCoreDataPhoto()
        savedImages.removeAll()
        collectionView.reloadData()
        
        getImagesRandomResult { (pictures) in
            
            if pictures != nil {
                
                DispatchQueue.main.async {
                    
                    self.addCoreData(pictures: pictures!, coreDataPin: self.coreDataPin)
                    
                    self.savedImages = self.preloadSavedPhoto()!
                    self.showSavedResult()
                    self.newCollectionButton.isEnabled = true
                }
            }
        }
    }
    
    
    func addCoreData(pictures:[Picture], coreDataPin:Pin) {
        
        for image in pictures {
            do {
                let delegate = UIApplication.shared.delegate as! AppDelegate
                let stack = delegate.stack
                let photo = Photo(index: pictures.index{$0 === image}!, url: image.imageURLString(), data: nil, context: stack.context)
                photo.pin = coreDataPin
                try stack.saveContext()
            } catch {
                print("Add Core Data failed")
            }
        }
    }
    
    
    func deleteExistingCoreDataPhoto() {
        
        for image in savedImages {
            getCoreDataStack().context.delete(image)
        }
    }
    
    //Get Random Photos
    func getImagesRandomResult(completion: @escaping (_ result:[Picture]?) -> Void) {
        
        var result:[Picture] = []
        
        Service.getImages(lat: coordinateSelected.latitude, long: coordinateSelected.longitude, success: {(pictures) in
            if pictures.count > self.totalCellCount {
                var randomArray:[Int] = []
                
                while randomArray.count < self.totalCellCount {
                    
                    let random = arc4random_uniform(UInt32(pictures.count))
                    if !randomArray.contains(Int(random)) { randomArray.append(Int(random)) }
                }
                
                for random in randomArray {
                    
                    result.append(pictures[random])
                }
                
                completion(result)
                
            } else {
                
                completion(pictures)
            }
            
        }, failure: {(error) in
           completion(nil)
            DispatchQueue.main.async {
                self.alertError(self, error: error.message)
            }
        })
        
        
        
    }
    
    func addAnnotationToMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinateSelected
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    

}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return savedImages.count
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.activityIndicator.startAnimating()
        cell.initWithPhoto(savedImages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width / 3 - spacingBetweenItems
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return spacingBetweenItems
    }
    
    func selectedToDeleteFromIndexPath(_ indexPathArray: [IndexPath]) -> [Int] {
        var selected:[Int] = []
        
        for indexPath in indexPathArray {
            
            selected.append(indexPath.row)
        }
        return selected
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedToDelete = selectedToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            cell?.contentView.alpha = 0.5
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        selectedToDelete = selectedToDeleteFromIndexPath(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            cell?.contentView.alpha = 1
        }
    }
    
    
}

extension DetailViewController {
    
    func alertError(_ controller: UIViewController, error: String) {
        let AlertController = UIAlertController(title: "", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel) {
            action in AlertController.dismiss(animated: true, completion: nil)
        }
        AlertController.addAction(cancelAction)
        controller.present(AlertController, animated: true, completion: nil)
    }
    
}
