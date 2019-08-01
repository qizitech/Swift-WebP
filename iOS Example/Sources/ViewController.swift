//
//  ViewController.swift
//  iOS Example
//
//  Created by ainame on Jan 32, 2032.
//  Copyright © 2016 satoshi.namai. All rights reserved.
//

import UIKit
import WebP
import CoreGraphics

class IOSViewController: UIViewController {
    enum State {
        case none
        case processing
    }
    
    @IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var beforeImageView: UIImageView!
    @IBOutlet weak var afterImageView: UIImageView!
    
    var state: State = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.didTapButton(self)
    }

    
    @IBAction func didTapButton(_ sender: Any) {
        print("tapped")
        if state == .processing { return }
        state = .processing
        let encoder = WebPEncoder()
        
        let image = #imageLiteral(resourceName: "testImage")
        
        do {
            print("convert start")
            let data = try! encoder.encode(image, config: .preset(.picture, quality: 85))
            
            let tmpURL = FileManager.default.documentsDirectory.appendingPathComponent("pic.webp")
            print(tmpURL.path)
            try data.write(to: tmpURL)
            
            let shareVC =  UIActivityViewController.init(activityItems: [tmpURL], applicationActivities: nil)
            self.show(shareVC, sender: nil)
            
        } catch let error {
            self.state = .none
            print(error)
        }
    }

}

extension FileManager {
    static var documentsDirectory: URL {
        return `default`.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
    
    var documentsDirectory: URL {
        return urls(for: .documentDirectory, in: .userDomainMask).last!
    }
}
