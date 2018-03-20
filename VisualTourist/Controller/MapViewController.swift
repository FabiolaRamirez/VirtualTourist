//
//  ViewController.swift
//  VisualTourist
//
//  Created by Fabiola Ramirez on 3/11/18.
//  Copyright © 2018 FabiolaRamirez. All rights reserved.
//

import UIKit
import  MapKit
import CoreData


class MapViewController: UIViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var messageView: UIView!
    
    var gestureBegin: Bool = false
    var editMode: Bool = false
    var currentPins:[Pin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRightBarButtonItem()
        let savedPins = preloadSavedPin()
        
        if savedPins != nil {
            currentPins = savedPins!
            //Add Annotation To Map
            for pin in currentPins {
                let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                addAnnotationToMap(fromCoord: coordinate)
            }
        }
    
    }
    
    
    func setRightBarButtonItem() {
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        messageView.isHidden = true
    }
    
    
     //Core Data
    func getCoreDataStack() -> CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    //Fetch Results
    func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let stack = getCoreDataStack()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = []
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    
    //Load Saved Pin
    func preloadSavedPin() -> [Pin]? {
        do {
            var pinList:[Pin] = []
            let fetchedResultsController = getFetchedResultsController()
            try fetchedResultsController.performFetch()
            let pinCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            for index in 0..<pinCount {
                pinList.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Pin)
            }
            return pinList
        } catch {
            return nil
        }
    }
    
    //Gesture Recognizer
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureBegin = true
        return true
    }
    
    //MARK: - Action method
    
    @IBAction func TapGestureRecognized(_ sender: UILongPressGestureRecognizer) {
        if gestureBegin {
            let gestureRecognizer = sender
            let gestureTouchLocation = gestureRecognizer.location(in: mapView)
            addAnnotationToMap(fromPoint: gestureTouchLocation)
            gestureBegin = false
        }
    }
    
    //Add Pin
    func addAnnotationToMap(fromPoint: CGPoint) {
        let coordToAdd = mapView.convert(fromPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordToAdd
        addCoreData(of: annotation)
        mapView.addAnnotation(annotation)
    }
    
    func addAnnotationToMap(fromCoord: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = fromCoord
        mapView.addAnnotation(annotation)
    }
    
    //Add Core Data
    func addCoreData(of: MKAnnotation) {
        do {
            let coord = of.coordinate
            let pin = Pin(latitude: coord.latitude, longitude: coord.longitude, context: getCoreDataStack().context)
            try getCoreDataStack().saveContext()
            currentPins.append(pin)
        } catch {
            print("Add Core Data failed")
        }
    }
    
    //Delete Core Data
    func removeCoreData(of: MKAnnotation) {
        
        let coord = of.coordinate
        for pin in currentPins {
            if pin.latitude == coord.latitude && pin.longitude == coord.longitude {
                do {
                    getCoreDataStack().context.delete(pin)
                    try getCoreDataStack().saveContext()
                } catch {
                    print("Remove failed")
                }
                break
            }
        }
    }
    
   //MARK: - prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetailVC" {
            
            let destination = segue.destination as! DetailViewController
            let coord = sender as! CLLocationCoordinate2D
            destination.coordinateSelected = coord
            
            for pin in currentPins {
                
                if pin.latitude == coord.latitude && pin.longitude == coord.longitude {
                    
                    destination.coreDataPin = pin
                    break
                }
            }
            
        }
    }
    
    //Edit
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        messageView.isHidden = !editing
        editMode = editing
    }
    
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !editMode {
            performSegue(withIdentifier: "showDetailVC", sender: view.annotation?.coordinate)
            mapView.deselectAnnotation(view.annotation, animated: false)
        } else {
            removeCoreData(of: view.annotation!)
            mapView.removeAnnotation(view.annotation!)
        }
    }
}



