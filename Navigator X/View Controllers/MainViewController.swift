//
//  ViewController.swift
//  Navigator X
//
//  Created by Alexey on 16.09.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit
import FloatingPanel
import NotificationBannerSwift
import CleanyModal


class MainViewController: UIViewController {
    
    @IBOutlet weak var mapScrollView: MapScrollView!
    @IBOutlet weak var mapPointsView: UIView!
    @IBOutlet weak var textFieldsConstraint: NSLayoutConstraint!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var floorChangeConstraint: NSLayoutConstraint!
    @IBOutlet weak var floorView: FloorSelectView!
    @IBOutlet weak var buildingLabel: UILabel!
    @IBOutlet weak var cancelResultViewButton: UIView?
    
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
    var currentFloor = 10
    
    var currentPath: [MapPointModel] = []
    
    func updateBuildingLabel() {
        buildingLabel.text = Constants.buildingNames[self.currentBuilding]
    }
    
    func resultPoints() -> [MapPointModel] {
        if searchQuery == "" {
            return mapPoints.filter({$0.isSearchable()})
        }
        return searchPoints(query: searchQuery)
    }
    
    func changeFloor(floor: Int) {
        let isUp = floor + 1 == currentFloor ? false : true
        
        currentFloor = floor

        mapScrollView.set(imagePath: Bundle.main.path(forResource: Constants.mapImages[currentBuilding]![currentFloor], ofType: "jpg")!, isUp: isUp)

        
        drawPointsOnMapView()

        
        processMapView()

        
        drawPath()
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

        
        drawPointsOnMapView()

        
        processMapView()

        
        drawPath()
        updateBuildingLabel()
        
        updateFloorView()
        
        setShowPannel(show: false)
    }
    
    func setShowPannel(show: Bool) {
        if show {
            fpc.move(to: .tip, animated: true)
//            floorChangeConstraint.constant = 154
//            UIView.animate(withDuration: 0.2) {
//                self.view.layoutIfNeeded()
//            }
        } else {
            fpc.move(to: .hidden, animated: true)
//            floorChangeConstraint.constant = 14
//            UIView.animate(withDuration: 0.2) {
//                self.view.layoutIfNeeded()
//            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            cancelResultViewButton?.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        mapScrollView.set(imagePath: Bundle.main.path(forResource: "kronv_1", ofType: "jpg")!, isUp: true)
        mapScrollView.scrollDelegate = self
        
        fromTextField.delegate = self
        toTextField.delegate = self
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
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
        
        self.updateBuildingLabel()
        
        cancelResultViewButton?.applyShadow(apply: true)
        
        self.cancelResultViewButton?.isHidden = true
    }
    
    @objc func mapScrollViewLongTapAction(tap: UITapGestureRecognizer) {
        let position = tap.location(in: self.view)
        var mTextField: UITextField?
        
        let alert = CleanyAlertViewController(
            title: "Добавить сообщение на карту",
            message: "Это сообщение будет видно всем пользователем в течении 24 часов",
            imageName: "messageIconCornerRadius")

        alert.addAction(title: "Отправить", style: .cancel) { _ in
            if mTextField?.text != "" {
                let point = MapPointModel()
                
                point.scaleVisible = 0.3
                point.type = .message
                point.labelText = mTextField?.text ?? ""
                point.text = mTextField?.text ?? ""
                point.info = Date().dateAndTimetoString()
                point.building = self.currentBuilding
                point.floor = self.currentFloor
                point.position = self.mapScrollView.canvasView.convert(position, from: self.view)
                
                MapPointsService.shared.addToDatabase(point: point)
            }
        }
        alert.addTextField() { (textField) in
            textField.font = UIFont.boldSystemFont(ofSize: 16)
            mTextField = textField
        }
        alert.addAction(title: "Отмена", style: .cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func mapScrollViewTapAction(tap: UITapGestureRecognizer) {
        let position = tap.location(in: self.view)
        
        if let selectedLabel = mapViews.first(where: {position.getDistance(to: $0.center) < 20 && $0.superview != nil}) {
            if selectedLabel.isSelectable {
                selectLabel(label: selectedLabel)
            }
        } else {
            self.selectedLabel?.setSelected(false)
            self.selectedLabel = nil
            
            self.setShowPannel(show: false)
        }
        
        processMapView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapScrollView.scrollToCenter()
        
        reloadMapPoints()
        
        MapPointsService.shared.changeCallBack = {
            self.reloadMapPoints()
        }
        
        updateFloorView()
        
        self.updateBuildingLabel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            if self.mapPoints.count == 0 {
                let banner = FloatingNotificationBanner(title: "Ошибка", subtitle: "Для загрузки данных необходим интернет", style: .danger)
                banner.show()
            }
        }
    }
    
    func updateFloorView() {
        let minFloor = Constants.mapImages[currentBuilding]?.keys.sorted(by: <).first
        let maxFloor = Constants.mapImages[currentBuilding]?.keys.sorted(by: >).first
        
        floorView.minFloor = minFloor ?? 1
        floorView.maxFloor = maxFloor ?? 1
        
        floorView.setFloor(floor: minFloor ?? 1)
    }
    
    func processMapView() {
        mapViews.forEach({self.processMapView(mapView: $0)})
    }
    
    func searchPoints(query: String) -> [MapPointModel] {
        var result: [MapPointModel] = []
        
        result.append(contentsOf: self.mapPoints.filter({$0.text.lowercased().contains(query.lowercased())}))
        result.sort { (p1, p2) -> Bool in
            p1.floor == currentFloor
        }
        return result.filter({$0.isSearchable()})
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
        mapPoints = MapPointsService.shared.getMapPoints(true, building: currentBuilding)
        //mapScrollView.drawConnection(points: self.mapPoints)
        drawPointsOnMapView()
        processMapView()
        resultTableView.reloadData()
        
        scrollToMainEnterance()
    }
    
    func drawPointsOnMapView() {
        mapViews.forEach({$0.removeFromSuperview()})
        mapViews = []
        for i in mapPoints.filter({$0.floor == currentFloor}) {
            let dynamicView = MapLabel(frame: CGRect(origin: .zero, size: CGSize(width: 103, height: 33)), mapPoint: i)
            self.mapViews.insert(dynamicView)
        }
    }
    
    func selectPoint(point: MapPointModel, isToField: Bool) {
        
        if isToField {
            toPoint = point
            toTextField.text = toPoint?.text
        } else {
            fromPoint = point
            fromTextField.text = fromPoint?.text
            
            if currentFloor != fromPoint!.floor {
                floorView.selectFloor(floor: fromPoint!.floor)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [self] in
                    scrollToPoint(point: point)
                    if let labelView = mapViews.first(where: {$0.mapPoint == point}) {
                        selectLabel(label: labelView)
                        return
                    }
                }
            }
        }
    
        if let labelView = mapViews.first(where: {$0.mapPoint == point}) {
            selectLabel(label: labelView)
        }
        
        if fromPoint != nil && toPoint != nil {
            self.findPath()
        } else {
            scrollToPoint(point: point)
        }
    }
    
    var buildingSelectView: SelectBuildingView?
    
    func findPath() {
        guard let fromPoint = self.fromPoint else { return }
        guard let toPoint = self.toPoint else { return }
        
        currentPath = MapPointsService.shared.findPath(from: fromPoint, to: toPoint, building: currentBuilding)
        
        drawPath()
        
        processMapView()
    }
    
    var stairsTextedMapLabels: [MapLabel] = []
    
    func scrollToMainEnterance() {
        if let mainEnterance = mapViews.first(where: {$0.mapPoint.type == .mainEntrance}) {
            let rect = CGRect(x: mainEnterance.mapPoint.position.x - 1000, y: mainEnterance.mapPoint.position.y - 2000, width: 2000, height: 2000)
            
            mapScrollView.zoom(to: rect, animated: true)
        }
    }
    
    func scrollToPoint(point: MapPointModel) {
        if let mapView = mapViews.first(where: {$0.mapPoint == point}) {
           // if mapView.superview == nil {
                let rect = CGRect(x: mapView.mapPoint.position.x - 400, y: mapView.mapPoint.position.y - 400, width: 800, height: 800)
                
                mapScrollView.zoom(to: rect, animated: true)
           // }
        }
    }
    
    func drawPath() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        
        
            if self.fromTextField.text == "" {self.fromPoint = nil}
            if self.toTextField.text == "" {self.toPoint = nil}
        
            if self.fromPoint == nil || self.toPoint == nil { self.currentPath = [] }
        
            self.stairsTextedMapLabels.forEach({$0.setText(text: "")})
        
            self.mapScrollView.clearPath()
        
        var pathToDraw: [MapPointModel] = []
        
        var delay: Double = 0.0
        
            for i in self.currentPath {
            if pathToDraw.last?.floor != i.floor {
                if pathToDraw.last?.floor == self.currentFloor {
                    self.mapScrollView.drawPath(points: pathToDraw, delay: delay)
                }
                delay += 0.5
                pathToDraw = []
            }
                if self.currentPath.last == i {
                pathToDraw.append(i)
                    if pathToDraw.last?.floor == self.currentFloor {
                    self.mapScrollView.drawPath(points: pathToDraw, delay: delay)
                }
            }
            pathToDraw.append(i)
        }
        if pathToDraw.count > 1 {
            self.mapScrollView.zoomToPath(points: self.currentPath.filter({$0.floor == self.currentFloor}))
        } else {
            self.scrollToMainEnterance()
        }
        
        var firstPoint: MapPointModel?
        var lastPoint: MapPointModel?
            for i in self.currentPath {
            if (i.type == .stairsUp || i.type == .stairsDown) {
                if firstPoint == nil {
                    firstPoint = i
                }
            } else {
                if (lastPoint?.type == .stairsUp || lastPoint?.type == .stairsDown) {
                    if let stairsTextedMapLabel = self.mapViews.first(where: {$0.mapPoint == firstPoint}) {
                        stairsTextedMapLabel.setText(text: "На \(lastPoint?.floor ?? 0) этаж")
                        self.stairsTextedMapLabels.append(stairsTextedMapLabel)
                    }
                    firstPoint = nil
                    lastPoint = nil
                }
            }
            lastPoint = i
        }
        }
        
//        for i in currentPath.reversed() {
//            if (i.type == .stairsUp || i.type == .stairsDown) {
//                if firstPoint == nil {
//                    firstPoint = i
//                }
//            } else {
//                if (lastPoint?.type == .stairsUp || lastPoint?.type == .stairsDown) {
//                    if let stairsTextedMapLabel = mapViews.first(where: {$0.mapPoint == firstPoint}) {
//                        stairsTextedMapLabel.setText(text: "C \(lastPoint?.floor ?? 0) этажа")
//                        stairsTextedMapLabels.append(stairsTextedMapLabel)
//                    }
//                    firstPoint = nil
//                    lastPoint = nil
//                }
//            }
//            lastPoint = i
//        }
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
        
        if (mapView.center.x > -50) &&
            (mapView.center.x <= mapPointsView.bounds.width + 50) &&
            (mapView.center.y > -50) &&
            (mapView.center.y <= mapPointsView.bounds.height + 50) &&
            (Double(mapScrollView.zoomScale) > mapView.scaleVisible || !mapView.isHidable){
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

extension MainViewController: MapScrollViewDelegate {
    func didScroll() {
        mapViews.forEach({self.processMapView(mapView: $0)})
    }
}

extension MainViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        self.searchQuery = ""
        self.resultTableView.reloadData()
        if textField == self.fromTextField { expandFromTextField() }
        if textField == self.toTextField { expandToTextField() }
        self.resultTableView.isHidden = false
        self.fpc.move(to: .hidden, animated: true)
        self.cancelResultViewButton?.isHidden = false
        if self.resultTableView.numberOfRows(inSection: 0) > 0 {
            self.resultTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .none, animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setEqualWidthTextFields()
        self.resultTableView.isHidden = true
        self.cancelResultViewButton?.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            self.searchQuery = updatedText
            self.resultTableView.reloadData()
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

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultPoints().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ResultTableViewCell
        cell.setup(point: self.resultPoints()[indexPath.row])
        return cell
    }
    
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let labelView = mapViews.first(where: {$0.mapPoint == resultPoints()[indexPath.row]}) {
//            selectLabel(label: labelView)
//        }
        
        if fromTextField.isEditing {
            selectPoint(point: resultPoints()[indexPath.row], isToField: false)
        }
        
        if toTextField.isEditing {
            selectPoint(point: resultPoints()[indexPath.row], isToField: true)
        }
    }
}

extension MainViewController: SelectBuildingViewDelegate {
    func buildingDidSelected(building: Int) {
        changeBuilding(building: building)
        print(building)
    }
    
    func hideAction() {
        showBuildingSelectView()
    }
}

extension MainViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        if fpc.state == .hidden {
            floorChangeConstraint.constant = 14
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
        if fpc.state == .tip {
            floorChangeConstraint.constant = 154
                        UIView.animate(withDuration: 0.2) {
                            self.view.layoutIfNeeded()
                        }
        }
    }
}

extension MainViewController: InformationViewControllerDelegate {
    func didSelectFromPoint(point: MapPointModel) {
        selectPoint(point: point, isToField: false)
        setShowPannel(show: false)
    }
    
    func didSelectToPoint(point: MapPointModel) {
        selectPoint(point: point, isToField: true)
        setShowPannel(show: false)
    }
}

extension MainViewController: FloorSelectViewDelegate {
    func floorDidChange(floor: Int) {
        changeFloor(floor: floor)
    }
}

