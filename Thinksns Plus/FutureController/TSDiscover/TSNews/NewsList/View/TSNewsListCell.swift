//
//  TSNewsListCell.swift
//  Thinksns Plus
//
//  Created by LiuYu on 2017/3/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SnapKit

struct TSNewsListCellUX {
    /// cell图片宽度
    static let imageWidth: CGFloat = ScreenSize.ScreenWidth / 75 * 19
    /// cell图片高度
    static let imageHeight: CGFloat = TSNewsListCellUX.imageWidth / 38 * 27
    /// 以下间距请参照文档 《TS+视觉规范2.0》 第26页 f条目的间距说明
    static let spaceOne: CGFloat = 10
    static let spaceTwo: CGFloat = 15
    static let spaceFive: CGFloat = 20
    static let spaceSeven: CGFloat = 3

    /// 内容的最大宽度
    static let titleContentMaxWidth: CGFloat = ScreenSize.ScreenWidth - TSNewsListCellUX.imageWidth - (TSNewsListCellUX.spaceOne * 2) - TSNewsListCellUX.spaceTwo
    /// 未查看时的文字颜色
    static let titleNormanlColor = TSColor.normal.blackTitle
    /// 已查看后的文字颜色
    static let titleSelectedColor = TSColor.normal.minor
    /// 标题的行间距
    static let titleLineSpace: CGFloat = 2
    /// 时间及发布平台label的高度 （与其字号大小相等）
    static let suContentLabelHeight: CGFloat = 12
}

class TSNewsListCell: UITableViewCell {

    static let identifier = "TSNewsListCell"

    /// 是否显示资讯的栏目标签：默认需要展示，但当前需求中在资讯列表中除推荐外在各自栏目下无需再展示栏目标签
    /// 注：配置更新showCategoryFlag应在加载数据之前，即给cellData赋值之前
    var showCategoryFlag: Bool = true {
        didSet {
            self.categoryLabel.isHidden = !showCategoryFlag
        }
    }
    /// 标题
    weak var titleLabel: UILabel!
    /// 信息汇总标签
    ///
    /// 显示 出处+浏览量+时间
    weak var timeAndFromLabel: UILabel!
    /// 底部分割线
    weak var bottomLine: UIView!
    /// 置顶标志
    weak var topLabel: UILabel!
    /// 类型标志
    weak var categoryLabel: UILabel!
    /// cell的数据
    var cellData: NewsModel? {
        didSet {
            updateCellData(WithData: cellData)
        }
    }
    /// cell默认总高度，单图/无图
    var cellHeight: CGFloat = TSNewsListCellUX.imageHeight + 30
    /// 多图的加载背景视图
    var imagesBgView = UIView()
    // MARL: - lifecycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.createdViewItems()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("该cell不支持从xib内初始化")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: - Public
    public func updateCellStyle(isSelected: Bool) {
        self.titleLabel.textColor = isSelected ? TSNewsListCellUX.titleSelectedColor : TSNewsListCellUX.titleNormanlColor
    }

    // MARK: - Private
    private func updateCellData(WithData cellData: NewsModel?) {
        guard let data = cellData else {
            return
        }
        var imgCount: Int = 0
        if let imgInfos = data.coverInfos, imgInfos.isEmpty == false {
            if imgInfos.count >= 3 {
                let maxImageCount: CGFloat = 3
                imgCount = CGFloat(imgInfos.count) > maxImageCount ? Int(CGFloat(maxImageCount)) : imgInfos.count
                // 两边是 10 ，中间 5
                let imageSpX: Int = 5
                let imageWith = (ScreenSize.ScreenWidth - 20 -  CGFloat((imgCount - 1) * imageSpX)) / CGFloat(imgCount)
                let imageHeight = imageWith * 3 / 4
                imagesBgView.snp.remakeConstraints { (make) in
                    make.top.equalTo(titleLabel.snp.bottom).offset(10)
                    make.leading.trailing.equalToSuperview()
                    make.height.equalTo(imageHeight)
                }
                imagesBgView.removeAllSubviews()
                for (index, imgInfo) in imgInfos.enumerated() {
                    let imageItem = UIImageView(frame: CGRect.zero)
                    imageItem.contentMode = .scaleAspectFill
                    imageItem.clipsToBounds = true
                    imagesBgView.addSubview(imageItem)
                    let imgUrl = TSURLPath.imageV2URLPath(storageIdentity: imgInfo.id, compressionRatio: 20, cgSize: imgInfo.size)
                    imageItem.kf.setImage(with: imgUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                    let imageOffsetX = CGFloat(index + 1) * CGFloat(imageSpX) + CGFloat(index) * imageWith + CGFloat(imageSpX)
                    imageItem.snp.makeConstraints { (mark) in
                        mark.top.equalToSuperview()
                        mark.leading.equalToSuperview().offset(imageOffsetX)
                        mark.width.equalTo(imageWith)
                        mark.height.equalTo(imageHeight)
                    }
                    if index == imgCount - 1 {
                        break
                    }
                }
            } else {
                imagesBgView.snp.remakeConstraints { (mark) in
                    mark.size.equalTo(CGSize(width: TSNewsListCellUX.imageWidth, height: TSNewsListCellUX.imageHeight))
                    mark.top.equalToSuperview().offset(15)
                    mark.right.equalToSuperview().offset(-10)
                    mark.bottom.equalToSuperview().offset(-15)
                }
                imagesBgView.removeAllSubViews()
                let imageItem = UIImageView(frame: CGRect.zero)
                imageItem.contentMode = .scaleAspectFill
                imageItem.clipsToBounds = true
                imagesBgView.addSubview(imageItem)
                let imgUrl = TSURLPath.imageV2URLPath(storageIdentity: imgInfos[0].id, compressionRatio: 20, cgSize: imgInfos[0].size)
                imageItem.kf.setImage(with: imgUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                imageItem.snp.makeConstraints { (mark) in
                    mark.top.leading.trailing.bottom.equalToSuperview()
                }
            }
        } else {
            imagesBgView.snp.remakeConstraints({ (mark) in
                mark.size.equalTo(CGSize.zero)
                mark.top.equalToSuperview().offset(15)
                mark.right.equalToSuperview().offset(-10)
            })
        }
        let attributeSring = NSMutableAttributedString(string: data.title)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = TSNewsListCellUX.titleLineSpace
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        attributeSring .addAttributes([NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: self.titleLabel.font], range: NSRange(location: 0, length: CFStringGetLength(data.title as CFString!)))
        titleLabel.attributedText = attributeSring
        /// 自适应文本高度
        titleLabel.sizeToFit()
        titleLabel.snp.remakeConstraints { (mark) in
            mark.left.equalToSuperview().offset(10)
            if imgCount < 3 {
                if let text = titleLabel.attributedText {
                    if  text.size().width > TSNewsListCellUX.titleContentMaxWidth {
                        mark.top.equalToSuperview().offset(10)
                    } else {
                        mark.top.equalToSuperview().offset(30)
                    }
                }
                mark.right.equalTo(imagesBgView.snp.left).offset(-22)
            } else {
                mark.top.equalToSuperview().offset(10)
                mark.right.equalToSuperview().offset(-15)
            }
        }
        if data.categoryInfo.id == -99 { // 客户端自定义的广告类别
            let date = data.createdDate as NSDate
            let timeString = TSDate().dateString( .normal, nsDate: date)
            self.timeAndFromLabel.text = data.from + " · " + timeString

            categoryLabel.textColor = TSColor.normal.disabled
            categoryLabel.layer.borderColor = TSColor.normal.disabled.cgColor
        } else {
            let reviewCount = TSAppConfig.share.pageViewsString(number: data.hits) + "浏览"
            let date = data.createdDate as NSDate
            let timeString = TSDate().dateString( .normal, nsDate: date)
            var from = ""
            if data.from == "原创" { // 垃圾后台要求这样判断的
                from = data.author
            } else {
                from = data.from
            }
            self.timeAndFromLabel.text = from + " · " + reviewCount + " · " + timeString

            categoryLabel.textColor = TSColor.main.theme
            categoryLabel.layer.borderColor = TSColor.main.theme.cgColor
        }

        self.categoryLabel.text = data.categoryInfo.name

        topLabel.sizeToFit()
        let topLabelWidth = topLabel.frame.width
        categoryLabel.sizeToFit()
        //let categoryLabelWidth = categoryLabel.frame.width
        let categoryLabelWidth = self.showCategoryFlag ? categoryLabel.frame.width + 5 : 0

        if data is TopNewsModel {
            self.topLabel.snp.remakeConstraints { (mark) in
                mark.height.equalTo(15)
                mark.width.equalTo(topLabelWidth + 5)
                mark.left.equalToSuperview().offset(10)
                mark.bottom.equalTo(timeAndFromLabel.snp.bottom)
            }
            self.categoryLabel.snp.remakeConstraints { (mark) in
                mark.left.equalTo(self.topLabel.snp.right).offset(5)
                mark.width.equalTo(categoryLabelWidth)
                mark.height.equalTo(15)
                mark.centerY.equalTo(timeAndFromLabel.snp.centerY)
            }
        } else {
            self.topLabel.snp.remakeConstraints { (mark) in
                mark.size.equalTo(CGSize.zero)
                mark.left.equalToSuperview().offset(15)
                mark.top.equalTo(titleLabel.snp.bottom).offset(18)
            }
            self.categoryLabel.snp.remakeConstraints { (mark) in
                mark.left.equalToSuperview().offset(10)
                mark.width.equalTo(categoryLabelWidth)
                mark.height.equalTo(15)
                mark.centerY.equalTo(timeAndFromLabel.snp.centerY)
            }
        }
        let timeAndFromLabelOffset = self.showCategoryFlag ? 5 : 0
        self.timeAndFromLabel.snp.remakeConstraints { (mark) in
            mark.left.equalTo(self.categoryLabel.snp.right).offset(timeAndFromLabelOffset)
            mark.height.equalTo(15)
            if imgCount == 0 {
                mark.top.equalTo(titleLabel.snp.bottom).offset(18)
                mark.right.equalTo(self.imagesBgView.snp.left).offset(-5)
                mark.bottom.equalToSuperview().offset(-10)
            } else if imgCount < 3 {
                mark.bottom.equalTo(imagesBgView.snp.bottom)
                mark.right.equalTo(self.imagesBgView.snp.left).offset(-5)
            } else {
                mark.right.equalToSuperview()
                mark.top.equalTo(imagesBgView.snp.bottom).offset(15)
                mark.bottom.equalToSuperview().offset(-10)
            }
        }

        self.bottomLine.snp.remakeConstraints { (mark) in
            mark.height.equalTo(0.5)
            mark.width.equalToSuperview()
            mark.bottom.equalToSuperview()
        }
    }

    // MARK: - other
    func createdViewItems() {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: TSFont.Title.pulse.rawValue)
        titleLabel.textColor = TSNewsListCellUX.titleNormanlColor
        titleLabel.textAlignment = NSTextAlignment.left
        titleLabel.numberOfLines = 2
        self.titleLabel = titleLabel

        let timeAndFromLabel = UILabel()
        timeAndFromLabel.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
        timeAndFromLabel.textColor = TSColor.normal.disabled
        self.timeAndFromLabel = timeAndFromLabel

        let bottomLine = UIView()
        bottomLine.backgroundColor = TSColor.inconspicuous.disabled
        self.bottomLine = bottomLine

        let topLabel = UILabel()
        topLabel.textColor = TSColor.small.topLogo
        topLabel.font = UIFont.systemFont(ofSize: TSFont.SubInfo.special.rawValue)
        topLabel.textAlignment = .center
        topLabel.layer.borderColor = TSColor.small.topLogo.cgColor
        topLabel.layer.borderWidth = 0.5
        topLabel.text = "顶"
        self.topLabel = topLabel

        let categoryLabel = UILabel()
        categoryLabel.textColor = TSColor.main.theme
        categoryLabel.font = UIFont.systemFont(ofSize: TSFont.SubInfo.special.rawValue)
        categoryLabel.textAlignment = .center
        categoryLabel.layer.borderColor = TSColor.main.theme.cgColor
        categoryLabel.layer.borderWidth = 0.5
        self.categoryLabel = categoryLabel
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.timeAndFromLabel)
        self.contentView.addSubview(self.bottomLine)
        self.contentView.addSubview(self.topLabel)
        self.contentView.addSubview(self.categoryLabel)
        self.contentView.addSubview(self.imagesBgView)
    }
}

extension UILabel {
    func lineCount() -> Int {
        let labelSize = CGSize(width: self.frame.size.width, height: CGFloat(Float.infinity))
        let rHeight = lroundf(Float(self.sizeThatFits(labelSize).height))
        let charSize = lroundf(Float(self.font.lineHeight))
        return rHeight / charSize
    }
}
