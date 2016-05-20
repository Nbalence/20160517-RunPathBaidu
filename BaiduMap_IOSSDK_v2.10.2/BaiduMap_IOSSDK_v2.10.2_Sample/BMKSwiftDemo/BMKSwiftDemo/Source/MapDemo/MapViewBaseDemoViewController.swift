//
//  MapViewBaseDemoViewController.swift
//  BMKSwiftDemo
//
//  Created by wzy on 15/11/2.
//  Copyright © 2015年 baidu. All rights reserved.
//

import UIKit

class MapViewBaseDemoViewController: UIViewController, BMKMapViewDelegate {
    var _mapView: BMKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let topHeight = (self.navigationController?.navigationBar.frame.height)! + UIApplication.sharedApplication().statusBarFrame.height

        _mapView = BMKMapView(frame: CGRect(x: 0, y: topHeight, width: self.view.frame.width, height: self.view.frame.height - topHeight))
        self.view.addSubview(_mapView!)
        
        addCustomGesture()//添加自定义手势
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        _mapView?.viewWillAppear()
        _mapView?.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        _mapView?.viewWillDisappear()
        _mapView?.delegate = nil
    }
    
    // MARK: - BMKMapViewDelegate
    
    /**
    *地图初始化完毕时会调用此接口
    *@param mapview 地图View
    */
    func mapViewDidFinishLoading(mapView: BMKMapView!) {
        let alertVC = UIAlertController(title: "", message: "BMKMapView控件初始化完成", preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "知道了", style: .Cancel, handler: nil)
        alertVC.addAction(alertAction)
        self .presentViewController(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - 添加自定义手势 （若不自定义手势，不需要下面的代码）
    func addCustomGesture() {
        /*
        *注意：
        *添加自定义手势时，必须设置UIGestureRecognizer的cancelsTouchesInView 和 delaysTouchesEnded 属性设置为false，否则影响地图内部的手势处理
        */
        let tapGesturee = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        tapGesturee.cancelsTouchesInView = false
        tapGesturee.delaysTouchesEnded = false
        self.view.addGestureRecognizer(tapGesturee)
    }
    
    func handleSingleTap(tap: UITapGestureRecognizer) {
        NSLog("custom single tap handle")
    }
}
