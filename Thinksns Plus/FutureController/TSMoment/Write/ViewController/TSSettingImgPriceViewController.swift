 //
//  TSReturnPicturePriceViewController.swift
//  ThinkSNS +
//
//  Created by Fiction on 2017/6/30.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import KMPlaceholderTextView
import SnapKit

protocol TSSettingImgPriceVCDelegate: class {
    func setsPrice(price: TSImgPrice, index: Int)
}

class TSSettimgPriceViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    var allBackgroundview: UIView = UIView()
    var thePriceChargesBackgroundview: UIView = UIView()
    var thePriceBackgroundview: UIView = UIView()
    var theUserPriceBackgroundview: UIView = UIView()
    //
    var toSee: UIButton = UIButton(type: .custom)
    var toDownload: UIButton = UIButton(type: .custom)
    // MARK: - 页面必需参数，TSImgPrice
    var imagePrice: TSImgPrice!
    //
    var itemFirst: UIButton = UIButton(type: .custom)
    var itemSecond: UIButton = UIButton(type: .custom)
    var itemThird: UIButton = UIButton(type: .custom)
    var userPriceNumber: UITextField = UITextField()
    var prices: [Int] = [100, 500, 1_500]

    let submitButtion: UIButton = UIButton(type: .custom)
    var resetButton: TSTextButton = TSTextButton.initWith(putAreaType: .top)
    weak var delegate: TSSettingImgPriceVCDelegate?
    var enterIndex: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置图片收费"
        self.view.backgroundColor = TSColor.inconspicuous.background
        setUI()
        if imagePrice.paymentType == .not || imagePrice.paymentType == .read {
            setgetdo(toSee)
        } else {
            setgetdo(toDownload)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         IQKeyboardManager.sharedManager().enable = true
        /// 如果有值的话
        ifSubmited()
    }
    init(imagePrice: TSImgPrice) {
        super.init(nibName: nil, bundle: nil)
        self.imagePrice = imagePrice
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    func setUI() {
        allBackgroundview.frame = self.view.frame
        allBackgroundview.backgroundColor = UIColor.clear
        self.view.addSubview(allBackgroundview)
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(tapResignFirstResponder))
        allBackgroundview.addGestureRecognizer(tap)
        // 选择图片收费方式
        setPriceCharges()
        // 设置图片收费金额按钮
        setPrice()
        // user自定义金额
        setUserPrice()
        setButtons()
    }
    func ifSubmited() {
        let paymentType = imagePrice.paymentType.rawValue
        let sellingPrice = imagePrice.sellingPrice
        if paymentType == ImagePaymentType.read.rawValue {
            toSee.setTitleColor(TSColor.main.theme, for: .normal)
            toSee.layer.borderColor = TSColor.main.theme.cgColor
        } else if paymentType == ImagePaymentType.download.rawValue {
            toDownload.setTitleColor(TSColor.main.theme, for: .normal)
            toDownload.layer.borderColor = TSColor.main.theme.cgColor
        } else {
            let arry: Array<UIButton> = [toSee, toDownload]
            for index in arry {
                index.setTitleColor(TSColor.normal.blackTitle, for: .normal)
                index.layer.borderColor = TSColor.inconspicuous.highlight.cgColor
            }
        }
        let arry: Array<UIButton> = [itemFirst, itemSecond, itemThird]
        var isLocationPrice = false
        // 相同的价格则选中按钮
        for item in arry {
            let price = prices[item.tag - 600]
            if price == sellingPrice {
                item.setTitleColor(TSColor.main.theme, for: .normal)
                item.layer.borderColor = TSColor.main.theme.cgColor
                isLocationPrice = true
                break
            }
        }
        // 如果没有匹配到本地推荐价格，就显示自定义金额
        if isLocationPrice == false && sellingPrice > 0 {
            userPriceNumber.text = "\(sellingPrice)"
        }
        let _ = setSubmitIsEnabled(imagePrice: imagePrice)
    }
    func setPriceCharges() {
        allBackgroundview.addSubview(thePriceChargesBackgroundview)
        thePriceChargesBackgroundview.backgroundColor = TSColor.main.white
        thePriceChargesBackgroundview.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.right.equalTo(self.view)
            make.height.equalTo(101.5)
        }
        let tiplabel = UILabel()
        setTip(theTip: tiplabel, theSuperview: thePriceChargesBackgroundview, theWidth: 105, theTipSting: "选择图片收费方式")
        toSee.addTarget(self, action: #selector(setgetdo(_:)), for: .touchUpInside)
        toDownload.addTarget(self, action: #selector(setgetdo(_:)), for: .touchUpInside)
        setButton(giveButton: toSee, givePricetag: 501, givePricetxt: "查看收费")
        setButton(giveButton: toDownload, givePricetag: 502, givePricetxt: "下载收费")
        thePriceChargesBackgroundview.addSubview(toSee)
        thePriceChargesBackgroundview.addSubview(toDownload)
        toSee.snp.makeConstraints { (make) in
            make.left.equalTo(thePriceChargesBackgroundview).offset(15)
            make.top.equalTo(thePriceChargesBackgroundview).offset(46.5)
            make.bottom.equalTo(thePriceChargesBackgroundview).offset(-20)
            make.right.equalTo(toDownload.snp.left).offset(-15)
        }
        toDownload.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(toSee)
            make.right.equalTo(thePriceChargesBackgroundview).offset(-15)
        }
    }
    func setPrice() {
        thePriceBackgroundview.backgroundColor = TSColor.main.white
        allBackgroundview.addSubview(thePriceBackgroundview)
        thePriceBackgroundview.snp.makeConstraints { (make) in
            make.top.equalTo(thePriceChargesBackgroundview.snp.bottom).offset(5)
            make.left.right.equalTo(self.view)
            make.height.equalTo(101.5)
        }
        let tiplabel = UILabel()
        setTip(theTip: tiplabel, theSuperview: thePriceBackgroundview, theWidth: 105, theTipSting: "选择图片收费金额")
        itemFirst.addTarget(self, action: #selector(setgetprice(_:)), for: .touchUpInside)
        itemSecond.addTarget(self, action: #selector(setgetprice(_:)), for: .touchUpInside)
        itemThird.addTarget(self, action: #selector(setgetprice(_:)), for: .touchUpInside)
        var priceArrays = [String]()
        if TSAppConfig.share.localInfo.feedItems.count > 2 {
            prices = TSAppConfig.share.localInfo.feedItems
        }
        for price in prices {
            priceArrays.append("\(price)")
        }
        setButton(giveButton: itemFirst, givePricetag: 600, givePricetxt: "\(priceArrays[0])")
        setButton(giveButton: itemSecond, givePricetag: 601, givePricetxt: "\(priceArrays[1])")
        setButton(giveButton: itemThird, givePricetag: 602, givePricetxt: "\(priceArrays[2])")
        thePriceBackgroundview.addSubview(itemFirst)
        thePriceBackgroundview.addSubview(itemSecond)
        thePriceBackgroundview.addSubview(itemThird)
        itemFirst.snp.makeConstraints { (make) in
            make.left.equalTo(thePriceBackgroundview).offset(15)
            make.top.equalTo(thePriceBackgroundview).offset(46.5)
            make.bottom.equalTo(thePriceBackgroundview).offset(-20)
            make.right.equalTo(itemSecond.snp.left).offset(-15)
        }
        itemSecond.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(itemFirst)
            make.right.equalTo(itemThird.snp.left).offset(-15)
        }
        itemThird.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(itemFirst)
            make.right.equalTo(thePriceBackgroundview).offset(-15)
        }
        let lineview = UIView(frame: CGRect(x: 15, y: 100, width: self.view.bounds.width - 30, height: 0.5))
        lineview.backgroundColor = TSColor.inconspicuous.highlight
        thePriceBackgroundview.addSubview(lineview)
    }
    private func setButtons() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "IMG_topbar_back"), style: .plain, target: self, action: #selector(tapCancelButton))
        resetButton.setTitle("重置", for: .normal)
        resetButton.addTarget(self, action: #selector(resetAll), for: .touchUpInside)
        resetButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: resetButton)
    }
    func setUserPrice() {
        theUserPriceBackgroundview.backgroundColor = TSColor.main.white
        allBackgroundview.addSubview(theUserPriceBackgroundview)
        theUserPriceBackgroundview.snp.makeConstraints { (make) in
            make.top.equalTo(thePriceBackgroundview.snp.bottom)
            make.left.right.equalTo(self.view)
            make.height.equalTo(50)
        }
        let userPricelable = UILabel()
        userPricelable.text = "自定义金额"
        userPricelable.adjustsFontSizeToFitWidth = true
        userPricelable.textColor = TSColor.normal.blackTitle
        theUserPriceBackgroundview.addSubview(userPricelable)
        userPricelable.snp.makeConstraints { (make) in
            make.top.equalTo(theUserPriceBackgroundview).offset(17.5)
            make.left.equalTo(theUserPriceBackgroundview).offset(14)
            make.width.equalTo(73.5)
            make.height.equalTo(14)
        }
        let yuan = UILabel(frame: CGRect.zero)
        yuan.text = TSAppConfig.share.localInfo.goldName
        yuan.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        let size = TSAppConfig.share.localInfo.goldName.size(maxSize: CGSize.maxSize, font: yuan.font!)
        yuan.textColor = TSColor.normal.blackTitle
        theUserPriceBackgroundview.addSubview(yuan)
        yuan.snp.makeConstraints { (make) in
            make.centerY.equalTo(userPricelable)
            make.width.equalTo(size.width + 5) // width + 5，右侧间距-5
            make.height.equalTo(14)
            make.right.equalToSuperview().offset(-10)
        }
        userPriceNumber = UITextField()
        userPriceNumber.placeholder = "请输入金额"
        userPriceNumber.keyboardType = .numberPad
        userPriceNumber.textAlignment = .right
        userPriceNumber.textColor = TSColor.normal.blackTitle
        userPriceNumber.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        userPriceNumber.delegate = self
        userPriceNumber.addTarget(self, action: #selector(priceChange(_:)), for: .allEditingEvents)
        theUserPriceBackgroundview.addSubview(userPriceNumber)
        userPriceNumber.snp.makeConstraints { (make) in
            make.top.height.equalTo(userPricelable)
            make.right.equalTo(yuan.snp.left).offset(-9)
            make.left.equalTo(userPricelable.snp.right).offset(9)
        }
        submitButtion.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        submitButtion.setTitle("确定", for: .normal)
        submitButtion.setTitleColor(TSColor.main.white, for: .normal)
        submitButtion.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.navigation.rawValue)
        submitButtion.backgroundColor = TSColor.button.disabled
        submitButtion.clipsToBounds = true
        submitButtion.layer.cornerRadius = 6
        submitButtion.addTarget(self, action: #selector(submitVoid), for: .touchUpInside)
        allBackgroundview.addSubview(submitButtion)
        submitButtion.snp.makeConstraints { (make) in
            make.top.equalTo(theUserPriceBackgroundview.snp.bottom).offset(44.5)
            make.left.equalTo(self.view).offset(15)
            make.height.equalTo(45)
            make.right.equalTo(self.view.snp.right).offset(-15)
        }
        submitButtion.isEnabled = false

    }
    // customize void
    func setButton(giveButton: UIButton, givePricetag: Int, givePricetxt: String) {
        giveButton.tag = givePricetag
        giveButton.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        giveButton.setTitle(givePricetxt, for: .normal)
        giveButton.setTitleColor(TSColor.normal.blackTitle, for: .normal)
        giveButton.backgroundColor = TSColor.main.white
        giveButton.clipsToBounds = true
        giveButton.layer.cornerRadius = 6
        giveButton.layer.borderColor = TSColor.inconspicuous.highlight.cgColor
        giveButton.layer.borderWidth = 1
    }
    func setTip(theTip: UILabel, theSuperview: UIView, theWidth: Float, theTipSting: String) {
        theTip.text = theTipSting
        theTip.textColor = UIColor.gray
        theTip.font = UIFont.systemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue)
        theSuperview.addSubview(theTip)
        theTip.snp.makeConstraints { (make) in
            make.left.equalTo(theSuperview).offset(14)
            make.top.equalTo(theSuperview).offset(19.5)
            make.width.greaterThanOrEqualTo(theWidth)
            make.height.equalTo(12.5)
        }
    }
    func tapResignFirstResponder() {
        userPriceNumber.resignFirstResponder()
    }
    func setgetdo(_ tag: UIButton) {
        let arry: Array<UIButton> = [toSee, toDownload]
        for index in arry {
            if index.tag == tag.tag {
                index.setTitleColor(TSColor.main.theme, for: .normal)
                index.layer.borderColor = TSColor.main.theme.cgColor
            } else {
                index.setTitleColor(TSColor.normal.blackTitle, for: .normal)
                index.layer.borderColor = TSColor.inconspicuous.highlight.cgColor
            }
        }
        if tag.tag == toSee.tag {
            imagePrice.paymentType = .read
        } else {
            imagePrice.paymentType = .download
        }
        userPriceNumber.resignFirstResponder()
        let _ = setSubmitIsEnabled(imagePrice: imagePrice)
    }
    func setgetprice(_ tag: UIButton) {
        let arry: Array<UIButton> = [itemFirst, itemSecond, itemThird]
        for index in arry {
            if index.tag == tag.tag {
                index.setTitleColor(TSColor.main.theme, for: .normal)
                index.layer.borderColor = TSColor.main.theme.cgColor
            } else {
                index.setTitleColor(TSColor.normal.blackTitle, for: .normal)
                index.layer.borderColor = TSColor.inconspicuous.highlight.cgColor
            }
        }
        let price = prices[tag.tag - 600]
        imagePrice.sellingPrice = price
        userPriceNumber.text = nil
        userPriceNumber.resignFirstResponder()
        let _ = setSubmitIsEnabled(imagePrice: imagePrice)
    }
    // MARK: - text delegate
    func priceChange(_ pricetexrfiled: UITextField) {
        let str: String = pricetexrfiled.text ?? "0"
        if str.first == "0" || !TSAccountRegex.isPayMoneyFormat(str) || str == "" {
            pricetexrfiled.text = nil
            imagePrice.sellingPrice = 0
        } else if !str.isEmpty {
            TSAccountRegex.checkAndUplodTextFieldText(textField: pricetexrfiled, stringCountLimit: 8)
            let arry: Array<UIButton> = [itemFirst, itemSecond, itemThird]
            for index in arry {
                index.setTitleColor(TSColor.main.content, for: .normal)
                index.layer.borderColor = TSColor.normal.imagePlaceholder.cgColor
            }
            imagePrice.sellingPrice = Int(str)!
        }
        let _ = setSubmitIsEnabled(imagePrice: imagePrice)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" || string == "\n\r"{
            userPriceNumber.resignFirstResponder()
            return false
        }
        return true
    }
    // MARK: - 提交方法
    func submitVoid() {
        userPriceNumber.resignFirstResponder()
        // 必须要满足二个条件，type、amount 才能保存
        if setSubmitIsEnabled(imagePrice: imagePrice) {
            if enterIndex != nil {
                delegate?.setsPrice(price: imagePrice, index: enterIndex!)
            } else {
                delegate?.setsPrice(price: imagePrice, index: 0)
            }
            let _ = navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - Cancel bar
    @objc private func tapCancelButton() {
        userPriceNumber.resignFirstResponder()
        let _ = self.navigationController?.popViewController(animated: true)
    }
    // MARK: - reset bar
    @objc private func resetAll() {
        userPriceNumber.resignFirstResponder()
        imagePrice = TSImgPrice(paymentType: .not, sellingPrice: 0)
        let arry: Array<UIButton> = [toSee, toDownload, itemFirst, itemSecond, itemThird]
        for index in arry {
            index.setTitleColor(TSColor.main.content, for: .normal)
            index.layer.borderColor = TSColor.normal.imagePlaceholder.cgColor
        }
        userPriceNumber.text = nil
        delegate?.setsPrice(price: imagePrice, index: enterIndex!)
        let _ = setSubmitIsEnabled(imagePrice: imagePrice)

    }

    func setSubmitIsEnabled(imagePrice: TSImgPrice) -> Bool {
        if imagePrice.paymentType != .not && imagePrice.sellingPrice > 0 {
            submitButtion.isEnabled = true
            submitButtion.backgroundColor = TSColor.button.normal
            return true
        } else {
            submitButtion.isEnabled = false
            submitButtion.backgroundColor = TSColor.button.disabled
            return false
        }
    }
}
