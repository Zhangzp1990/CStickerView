//
//  ViewController.swift
//  CStickerViewDemo
//
//  Created by zhangzp on 2023/7/15.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let imageView1 = UIImageView(image: UIImage(named: "testImage1"))
        imageView1.contentMode = .scaleAspectFit
        let sticker1 = CStickerView(frame: CGRect(x: 100, y: 100, width: imageView1.frame.width, height: imageView1.frame.height), view: imageView1)
        self.view.addSubview(sticker1)
        
        let label1 = UILabel()
        label1.text = "Hello, World!!!"
        label1.font = UIFont.systemFont(ofSize: 20)
        label1.textAlignment = .center
        let sticker2 = CStickerView(frame: CGRect(x: 100, y: 600, width: 160, height: 60), view: label1)
        self.view.addSubview(sticker2)
    }
}
