//
//  ViewController.swift
//  IdentifyBarcode
//
//  Created by 游义男 on 15/8/2.
//  Copyright (c) 2015年 游义男. All rights reserved.
//

import UIKit
//视频音频
import AVFoundation

class ViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    //重新扫描
    @IBAction func Rescan(sender: UIButton) {
        session?.startRunning()
        //隐藏按钮
        sender.hidden = true
    }
    @IBOutlet weak var buttonRescan: UIButton!
    @IBOutlet weak var ScanLabel: UILabel!
    //视频捕捉会话
    var session:AVCaptureSession?
    //视频画面预览
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    //自动锁定小方框
    var autolockView:UIView?
    
    //停止扫描
    func stopScan(){
        session?.stopRunning()
        buttonRescan.hidden = false
        
        view.bringSubviewToFront(buttonRescan)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        buttonRescan.hidden = true
        
        session = AVCaptureSession()
        //指定设备时摄像头
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        //输入
        if let input = AVCaptureDeviceInput(device: device, error: nil){
            session?.addInput(input)
    }else{
            println("无法使用摄像头")
            return
        }
        //输出
        let output = AVCaptureMetadataOutput()
        session?.addOutput(output)
        
        // 添加元数据对象输出代理
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        // 输出视频
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeFace]
        //视频预览层 与视频捕捉会话关联
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        // 布局调整
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        //启动会话
        session?.startRunning()
        
        //显示结果标签
        view.bringSubviewToFront(ScanLabel)
        
        //自动锁定框初始化
        autolockView = UIView()
        autolockView?.layer.borderColor = UIColor.greenColor().CGColor
        autolockView?.layer.borderWidth = 2
        view.addSubview(autolockView!)
        view.bringSubviewToFront(autolockView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //打开一个URL对应的程序
    func launchApp(decodedStr:String){
        let alert = UIAlertController(title: "二维码", message: "将要打开\(decodedStr)", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let okAction = UIAlertAction(title: "打开", style:UIAlertActionStyle.Destructive) { (_) -> Void in
            if let url = NSURL(string: decodedStr){
                if UIApplication.sharedApplication().canOpenURL(url){
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
        alert.addAction(okAction)
      
        // iPad上打开如下方法
//        alert.popoverPresentationController?.sourceView = view
//        alert.popoverPresentationController?.sourceRect = ScanLabel.frame
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //获取商品名
    func showGoodsName(decodedStr:String){
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let baseURL = "http://api.juheapi.com/jhbar/bar?appkey=5dde6d0cf313b93ba47798b6ad4b910f&pkg=cn.edu.hhuc&cityid=1&barcode="
        let request = NSURLRequest(URL: NSURL(string: baseURL + decodedStr)!)
        // session在后台执行 异步
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, _, e) -> Void in
            if e == nil {
                if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary{
                    if let summary = json["result"]?["summary"] as? NSDictionary{
                        let name = summary.valueForKey("name") as? String
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.ScanLabel.text = self.ScanLabel.text! + "" + name!
                        })
                    }
                }
            }
        })
        task.resume()
    }
    
    
    //一旦发现视频捕捉就输出
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        //判断元数据是否有输出
        if metadataObjects == nil || metadataObjects.count == 0{
            autolockView?.frame = CGRectZero
            ScanLabel.text = "正在扫描中"
            return
        }
        if let obj =  metadataObjects.first as? AVMetadataFaceObject {
            if obj.type == AVMetadataObjectTypeFace{
                let faceObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(obj) as! AVMetadataFaceObject
                autolockView!.frame = faceObject.bounds
                ScanLabel.text = "发现人脸"
            }
        }
        //如果是条形码
        if let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject{
            let barcodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(obj) as! AVMetadataMachineReadableCodeObject
            autolockView?.frame = barcodeObject.bounds
            
            switch obj.type{
            case AVMetadataObjectTypeQRCode:
                if let decodedStr = obj.stringValue {
                    stopScan()
                    ScanLabel.text = "二维码:" + decodedStr
                    
                    launchApp(decodedStr)
                }
            case AVMetadataObjectTypeEAN13Code:
                if let decodedStr = obj.stringValue{
                    stopScan()
                    ScanLabel.text = "商品码:" + decodedStr
                    
                    showGoodsName(decodedStr)
                }
            default:
                return
            }
        }
        

    }


}

