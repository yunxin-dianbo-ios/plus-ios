//
//  TSSwitchServiceVC.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/5/21.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class TSSwitchServiceVC: UIViewController {

    @IBOutlet weak var serviceTypeControl: UISegmentedControl!
    @IBOutlet weak var customURLTF: UITextField!

    @IBOutlet weak var jpName: UITextField!
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var jpKey: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "切换服务器"
    }

    @IBAction func sureBtnClick(_ sender: Any) {
        self.view.endEditing(true)
        let serviceType = self.serviceTypeControl.selectedSegmentIndex
        if serviceType == 2 {
            // 自定义服务器 必须手动填写
            if self.customURLTF.text?.isEmpty == true || self.jpName.text?.isEmpty == true || self.jpKey.text?.isEmpty == true {
                self.showHint("请输入自定义内容")
                return
            }
        }
        UserDefaults.standard.set(self.serviceTypeControl.selectedSegmentIndex, forKey: "TSPlusServerTypeKey")
        UserDefaults.standard.set(self.customURLTF.text, forKey: "TSPlusServerURLKey")
        UserDefaults.standard.set(self.jpName.text, forKey: "TSPlusServerJPNameKey")
        UserDefaults.standard.set(self.jpKey.text, forKey: "TSPlusServerJPKeyKey")
        UserDefaults.standard.synchronize()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            // 重启app
            exit(0)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
