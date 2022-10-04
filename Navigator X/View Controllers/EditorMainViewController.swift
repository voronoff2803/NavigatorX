//
//  ViewController.swift
//  Navigator X
//
//  Created by Alexey on 16.09.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit
import FloatingPanel

class EditorMainViewController: UIViewController {
    
    @IBOutlet weak var mapScrollView: MapScrollView!
    @IBOutlet weak var mapPointsView: UIView!
    @IBOutlet weak var textFieldsConstraint: NSLayoutConstraint!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var floorChangeConstraint: NSLayoutConstraint!
    @IBOutlet weak var floorView: FloorSelectView!
    
    var mapViews: Set<MapLabel> = []
    
    let dbService = MapPointsService.shared
    
    var mapPoints: [MapPointModel] = []
    
    var fromPoint: MapPointModel?
    var toPoint: MapPointModel?
    
    var selectedLabel: MapLabel?
    
    var fpc: FloatingPanelController!
    
    var informationVC: InformationViewController!
    
    var searchQuery = ""
    
    var currentBuilding = 0
    var currentFloor = 0
    
    var selectedMapPoints: [MapLabel] = []
    
    var currentPath: [MapPointModel] = []
    
    
    func resultPoints() -> [MapPointModel] {
        if searchQuery == "" {
            return mapPoints
        }
        return searchPoints(query: searchQuery)
    }
    
    func changeBuilding(building: Int) {
        fromTextField.text = ""
        toTextField.text = ""
        
        currentPath = []
        fromPoint = nil
        toPoint = nil
        
        currentFloor = 1
        currentBuilding = building
        
        reloadMapPoints()

        mapScrollView.set(imagePath: Bundle.main.path(forResource: Constants.mapImages[currentBuilding]![currentFloor], ofType: "jpg")!, isUp: true)

        
        drawPointsToMapView()
        processMapView()
    }
    
    func changeFloor(floor: Int) {
        currentFloor = floor
        
        print(currentFloor)
        
        mapScrollView.set(imagePath: Bundle.main.path(forResource: Constants.mapImages[currentBuilding]![currentFloor], ofType: "jpg")!, isUp: true)
        
        drawPointsToMapView()
        processMapView()
    }
    
    func setShowPannel(show: Bool) {
        if show {
            fpc.move(to: .tip, animated: true)
            floorChangeConstraint.constant = 154
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        } else {
            fpc.move(to: .hidden, animated: true)
            floorChangeConstraint.constant = 14
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapScrollView.set(imagePath: Bundle.main.path(forResource: "kronv_1", ofType: "jpg")!, isUp: true)
        mapScrollView.scrollDelegate = self
        
        fromTextField.delegate = self
        toTextField.delegate = self
        
        hideKeyboardWhenTappedAround()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapScrollViewTapAction))
        mapScrollView.addGestureRecognizer(tapGestureRecognizer)
        
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapScrollViewLongTapAction))
        mapScrollView.addGestureRecognizer(longTapGestureRecognizer)
        
        fpc = FloatingPanelController()
        
        fpc.isRemovalInteractionEnabled = false
        fpc.layout = InformationLayout()
        fpc.invalidateLayout()

        // Assign self as the delegate of the controller.
        fpc.delegate = self // Optional

        // Set a content view controller.
        self.informationVC = storyboard?.instantiateViewController(withIdentifier: "InformationViewController") as? InformationViewController
        self.informationVC.delegate = self
        
        fpc.set(contentViewController: informationVC)

        // Track a scroll view(or the siblings) in the content view controller.
        //fpc.track(scrollView: contentVC.tableView)

        // Add and show the views managed by the `FloatingPanelController` object to self.view.
        fpc.addPanel(toParent: self)
        
        //self.present(fpc, animated: true, completion: nil)
        
        floorView.delegate = self
    }
    
    @objc func mapScrollViewTapAction(tap: UITapGestureRecognizer) {
        let position = tap.location(in: self.view)
        
        if let selectedLabal = mapViews.first(where: {position.getDistance(to: $0.center) < 20}) {
            selectedLabal.setSelected(true)
            
            selectedMapPoints.append(selectedLabal)
            
            if selectedMapPoints.count > 1 {
                selectedMapPoints.forEach({$0.setSelected(false)})
                //mapScrollView.drawPath(points: selectedMapPoints.map({$0.mapPoint}))
                
                MapPointsService.shared.addConnection(from: selectedMapPoints[0].mapPoint, to: selectedMapPoints[1].mapPoint)
                
                selectedMapPoints = []
            }
            
        } else {
            let addPointForm = AddPointFormViewController(point: self.mapScrollView.canvasView.convert(position, from: self.view), building: currentBuilding, floor: currentFloor)
            self.present(addPointForm, animated: true, completion: nil)
        }
    }
    
    @objc func mapScrollViewLongTapAction(tap: UITapGestureRecognizer) {
        let position = tap.location(in: self.view)
        
        if let selectedLabal = mapViews.first(where: {position.getDistance(to: $0.center) < 20}) {
            MapPointsService.shared.removeFromDatabase(point: selectedLabal.mapPoint)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapScrollView.scrollToCenter()
        
        reloadMapPoints()
        
        MapPointsService.shared.changeCallBack = {
            self.reloadMapPoints()
        }
    }
    
    func processMapView() {
        mapViews.forEach({self.processMapView(mapView: $0)})
    }
    
    func searchPoints(query: String) -> [MapPointModel] {
        var result: [MapPointModel] = []
        
        result.append(contentsOf: self.mapPoints.filter({$0.text.lowercased().contains(query.lowercased()) || $0.info.lowercased().contains(query.lowercased())}))
        
        return result
    }
    
    func selectLabel(label: MapLabel) {
        self.selectedLabel?.setSelected(false)
        label.setSelected(true)
        self.selectedLabel = label
        
        if fpc.state == .tip {
    //                fpc.move(to: .hidden, animated: true) {
    //                    self.informationVC.setup(mapPoint: selectedLabel.mapPoint)
    //                    self.fpc.move(to: .tip, animated: true)
    //                }
            self.informationVC.setup(mapPoint: label.mapPoint)
        } else {
            self.informationVC.setup(mapPoint: label.mapPoint)
            self.setShowPannel(show: true)
        }
    }
    
    func reloadMapPoints() {
        mapPoints = MapPointsService.shared.getMapPoints(false, building: currentBuilding)
        print("reloadMapPoints")
        print(currentBuilding)
        print(mapPoints)
        drawPointsToMapView()
        processMapView()
    }
    
    func drawPointsToMapView() {
        mapViews.forEach({$0.removeFromSuperview()})
        mapViews = []
        for i in mapPoints.filter({$0.floor == currentFloor}) {
            let dynamicView = MapLabel(frame: CGRect(origin: .zero, size: CGSize(width: 103, height: 33)), mapPoint: i)
            self.mapViews.insert(dynamicView)
        }
        mapScrollView.drawConnections(points: self.mapPoints.filter({$0.floor == currentFloor}))
    }
    
    func selectPoint(point: MapPointModel, isToField: Bool) {
        if isToField {
            toPoint = point
            toTextField.text = toPoint?.text
        } else {
            fromPoint = point
            fromTextField.text = fromPoint?.text
        }
        
        if fromPoint != nil && toPoint != nil {
            self.findPath()
        } else {
            self.mapScrollView.zoomToPoint(point: point)
        }
    }
    
    var buildingSelectView: SelectBuildingView?
    
    func findPath() {
        
        guard let fromPoint = self.fromPoint else { return }
        guard let toPoint = self.toPoint else { return }
        
        currentPath = MapPointsService.shared.findPath(from: fromPoint, to: toPoint, building: currentBuilding)
        
        var pathToDraw: [MapPointModel] = []
        
        for i in currentPath {
            if pathToDraw.last?.floor != i.floor {
                self.mapScrollView.drawPath(points: pathToDraw)
                pathToDraw = []
            }
            pathToDraw.append(i)
        }
    }
    
    @IBAction func showBuildingSelectView() {
        if buildingSelectView == nil {
            buildingSelectView = SelectBuildingView(frame: view.bounds)
            buildingSelectView?.isUserInteractionEnabled = true
            buildingSelectView?.delegate = self
            self.view.addSubview(buildingSelectView!)
        } else {
            buildingSelectView?.removeAnimated()
            buildingSelectView = nil
        }
    }
    
    func processMapView(mapView: MapCoordinatable) {
        let newPoint = self.view.convert(mapView.mapCoordinate, from: self.mapScrollView.canvasView)
        
        mapView.center = CGPoint(x: newPoint.x, y: newPoint.y - mapView.frame.height / 2)
        
        if (mapView.center.x > -50) && (mapView.center.x <= mapPointsView.bounds.width + 50) && (mapView.center.y > -50) && (mapView.center.y <= mapPointsView.bounds.height + 50) {
            if mapView.superview == nil {
                self.mapPointsView.addSubview(mapView)
            }
        } else {
            if mapView.superview != nil {
                mapView.removeFromSuperview()
            }
        }
    }
}

extension EditorMainViewController: MapScrollViewDelegate {
    func didScroll() {
        mapViews.forEach({self.processMapView(mapView: $0)})
    }
}

extension EditorMainViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        self.searchQuery = ""
        if textField == self.fromTextField { expandFromTextField() }
        if textField == self.toTextField { expandToTextField() }

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setEqualWidthTextFields()

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            self.searchQuery = updatedText

        }
        return true
    }
    
    func expandFromTextField() {
        self.textFieldsConstraint.constant = -self.view.bounds.width / 2.8
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func expandToTextField() {
        self.textFieldsConstraint.constant = self.view.bounds.width / 2.8
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setEqualWidthTextFields() {
        self.textFieldsConstraint.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

extension EditorMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultPoints().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ResultTableViewCell
        cell.setup(point: self.resultPoints()[indexPath.row])
        return cell
    }
    
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let labelView = mapViews.first(where: {$0.mapPoint == resultPoints()[indexPath.row]}) {
            selectLabel(label: labelView)
        }
        
        if fromTextField.isEditing {
            selectPoint(point: resultPoints()[indexPath.row], isToField: false)
        }
        
        if toTextField.isEditing {
            selectPoint(point: resultPoints()[indexPath.row], isToField: true)
        }
    }
}

extension EditorMainViewController: SelectBuildingViewDelegate {
    func buildingDidSelected(building: Int) {
        changeBuilding(building: building)
        print(building)
    }
    
    func hideAction() {
        showBuildingSelectView()
    }
}

extension EditorMainViewController: FloatingPanelControllerDelegate {
    
}

extension EditorMainViewController: InformationViewControllerDelegate {
    func didSelectFromPoint(point: MapPointModel) {
        selectPoint(point: point, isToField: false)
    }
    
    func didSelectToPoint(point: MapPointModel) {
        selectPoint(point: point, isToField: true)
    }
}

extension EditorMainViewController: FloorSelectViewDelegate {
    func floorDidChange(floor: Int) {
        changeFloor(floor: floor)
    }
}
