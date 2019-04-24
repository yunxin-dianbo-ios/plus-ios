//
//  TSQuestionDetailContentView.swift
//  ThinkSNS +
//
//  Created by 小唐 on 25/10/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  问题详情中的内容视图
//
//  注1：由于MarkdownView自身的左右Margin导致样式变更，所以本控件不应该被约束有左右间距。
//  注2：增加一个当前高度的参数

import Foundation
import UIKit
import YYKit
import MarkdownView

protocol TSQuestionDetailContentViewProtocol: class {
    // 展示全部 点击回调
    func didClickShowMoreWithNewHeight(_ newHeight: CGFloat) -> Void
}
extension TSQuestionDetailContentViewProtocol {
    // 展示全部 点击回调
    func didClickShowMoreWithNewHeight(_ newHeight: CGFloat) -> Void {
    }
}

class TSQuestionDetailContentView: UIView {

    // MARK: - Internal Property
    // 回调
    weak var delegate: TSQuestionDetailContentViewProtocol?
    var showMoreClickAction: ((_ newHeight: CGFloat) -> Void)?

    /// 简短展示时 正文的左右间距
    let contentLrMargin: CGFloat
    /// 控件宽度
    let viewWidth: CGFloat

    /// 数据模型
    private(set) var model: TSQuestionDetailModel?
    // 图片数组
    fileprivate var imageArray: [String] = []
    // 当前查看的图片链接
    var currentImgStr: String?

    // MARK: - Internal Function

    // 加载模型，并返回当前加载后的高度
    func loadModel(_ model: TSQuestionDetailModel, complete:((_ height: CGFloat) -> Void)? = nil) -> Void {
        self.model = model
        self.setupWithModel(model, complete: complete)
    }

    // MARK: - Private Property

    /// 简短内容相关
    private weak var shortContentView: UIView!
    private weak var shortImageView: UIImageView!
    private weak var shortContentLabel: YYLabel!
    /// 内容的markdown界面
    private weak var contentMarkdownView: MarkdownView!
    /// 简短展示时 若展示图片则图片控件的高度
    fileprivate let normalImageH: CGFloat = 150
    /// 简短展示时 若展示图片则正文和图片控件的间距
    fileprivate let verCenterMargin: CGFloat = 10
    /// 原生展示content时的最大高度
    fileprivate let maxContentH: CGFloat = 3 * (15 + 5) + 1.0  // 加1.0是为了避免计算上可能多一点点的部分

    /// 简短展示时正文的字体
    fileprivate let contentFont: UIFont = UIFont.systemFont(ofSize: 14)
    /// 简短展示时正文的颜色
    fileprivate let contentColor: UIColor = TSColor.main.content

    // MARK: - Initialize Function
    init(contentLrMargin: CGFloat, viewWidth: CGFloat) {
        self.contentLrMargin = contentLrMargin
        self.viewWidth = viewWidth
        super.init(frame: CGRect.zero)
        self.initialUI()
        self.shortContentView.isHidden = true   // 默认隐藏
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCircle Function

    // MARK: - Private  UI

    // 界面布局
    private func initialUI() -> Void {
        // 1. markdownView
        let markdownView = MarkdownView()
        self.addSubview(markdownView)
        markdownView.isScrollEnabled = false
        markdownView.snp.makeConstraints { (make) in
            // 注：由于MarkdownView自身的左右Margin导致样式变更，所以这里约束左右为self。且本控件不应该被约束有左右间距。
            make.edges.equalTo(self)
            make.height.equalTo(100)    // 随便写的初始高度
        }
        markdownView.onTouchLink = { [weak self] (request) in
            guard let url = request.url else {
                return false
            }
            if let parentVC = self?.parentViewController {
                TSUtil.pushURLDetail(url: url, currentVC: parentVC)
            }
            return false
        }
        markdownView.onTouchClick = {[weak self] (url) in
            let string: NSString = NSString(string: url)
            self?.currentImgStr = string.substring(from: 8)
            self?.previewPicture()
        }
        self.contentMarkdownView = markdownView
        // 2. shortContentView
        let shortContentView = UIView()
        self.addSubview(shortContentView)
        shortContentView.snp.makeConstraints { (make) in
            make.edges.equalTo(markdownView)
        }
        self.shortContentView = shortContentView
        // 2.1 imageView
        let imageView = UIImageView(cornerRadius: 0)
        shortContentView.addSubview(imageView)
        imageView.image = UIImage.colorImage(color: TSColor.inconspicuous.background)
        imageView.snp.makeConstraints { (make) in
            make.leading.equalTo(shortContentView).offset(contentLrMargin)
            make.trailing.equalTo(shortContentView).offset(-contentLrMargin)
            make.top.equalTo(shortContentView)
            make.height.equalTo(0)
        }
        self.shortImageView = imageView
        // 2.2 shortContentLabel - YYLabel
        let contentLabel = YYLabel()
        shortContentView.addSubview(contentLabel)
        contentLabel.numberOfLines = 3
        contentLabel.font = UIFont.systemFont(ofSize: 15)
        contentLabel.textColor = UIColor(hex: 0x666666)
        contentLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(imageView)
            make.top.equalTo(imageView.snp.bottom).offset(0)
            make.bottom.equalTo(shortContentView)
        }
        self.shortContentLabel = contentLabel
    }

    // MARK: - Private  数据加载

    /// 加载内容
    fileprivate func setupWithModel(_ model: TSQuestionDetailModel?, complete:((_ height: CGFloat) -> Void)? = nil) -> Void {
        guard let question = model else {
            return
        }
        // 2018.08.08
        // 需求修订为：默认显示全部内容，不再判断是否显示“展开更多”
        self.showMarkdown(with: question, showMoreAction: false, complete: complete)
//        // 判断是否展示更多
//        if self.isNeedShowMore(with: question.body) {
//            // 1. 展示更多 - 缩略展示
//            self.setupShortContent(with: question, complete: complete)
//        } else {
//            // 2. 不用展示更多 - markdown加载
//            self.showMarkdown(with: question, showMoreAction: false, complete: complete)
//        }
    }

    /// 判断是否需要展示更多
    fileprivate func isNeedShowMore(with content: String) -> Bool {
        var showFlag: Bool = false
        let maxW: CGFloat = self.viewWidth - self.contentLrMargin * 2.0
        let maxH: CGFloat = self.maxContentH
        // 判断 纯文字 或 替换图片后的文字内容 是否超过指定高度
        // 注：关于图片前的多个连续换行换行问题，原生处理和markdown渲染是不一致的，可能会导致一些展示差异。
        var showH: CGFloat = 0
        if content.ts_customMarkdownIsContainImageCode() {
            let showContent = content.ts_customMarkdownToNormal()
            showH = showContent.size(maxSize: CGSize(width: maxW, height: CGFloat(MAXFLOAT)), font: self.contentFont, lineMargin: 5).height
        } else {
            showH = content.size(maxSize: CGSize(width: maxW, height: CGFloat(MAXFLOAT)), font: self.contentFont, lineMargin: 5).height
        }
        if showH > maxH {
            showFlag = true
        }
        return showFlag
    }

    /// 缩略展示/简短展示
    fileprivate func setupShortContent(with model: TSQuestionDetailModel, complete:((_ height: CGFloat) -> Void)? = nil) -> Void {
        // 判断是否有图片
        let content = model.body
        let isContainImageFlag: Bool = content.ts_customMarkdownIsContainImageCode()
        // 间距设置
        let contentTopMargin: CGFloat = isContainImageFlag ? self.verCenterMargin : 0
        let imageH: CGFloat = isContainImageFlag ? self.normalImageH : 0
        self.shortImageView.isHidden = !isContainImageFlag
        self.shortContentView.isHidden = false
        self.contentMarkdownView.isHidden = true
        self.shortImageView.snp.updateConstraints { (make) in
            make.height.equalTo(imageH)
        }
        self.shortContentLabel.snp.updateConstraints { (make) in
            make.top.equalTo(self.shortImageView.snp.bottom).offset(contentTopMargin)
        }
        // 内容加载
        if isContainImageFlag, let strUrl = content.ts_customMarkdownToStandard().ts_getMarkdownImageUrl().first {
            let url = URL(string: strUrl)
            let placeholderImage = UIImage.colorImage(color: TSColor.inconspicuous.background)
            self.shortImageView.kf.setImage(with: url, placeholder: placeholderImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
        self.setupShortContentLabel(with: content, model: model)
        // 高度返回处理
        let contentH: CGFloat = content.ts_customMarkdownToNormal().size(maxSize: CGSize(width: self.viewWidth - self.contentLrMargin * 2.0, height: CGFloat(MAXFLOAT)), font: self.contentFont, lineMargin: 5.0).height
        let showContentH: CGFloat = min(self.maxContentH, contentH)
        let height: CGFloat = imageH + contentTopMargin + showContentH
        self.contentMarkdownView.snp.updateConstraints({ (make) in
            make.height.equalTo(height)
        })
        self.layoutIfNeeded()
        complete?(height)
    }

    /// markdown加载
    /// showMoreAction 是否是显示更多的响应，显示更多会使用回调
    private func showMarkdown(with model: TSQuestionDetailModel, showMoreAction: Bool, complete: ((_ height: CGFloat) -> Void)? = nil) -> Void {
        self.contentMarkdownView.isHidden = false
        self.shortContentView.isHidden = true
        // 注入查看图片相关的js
        let getImagesJSString =
        """
            function getImages(){
            var objs = document.getElementsByTagName(\"img\");
            var imgScr = '';
            for(var i=0;i<objs.length;i++) {
            if (i == 0){
              imgScr = objs[i].src;
            } else {
               imgScr = imgScr +'***'+ objs[i].src;
            }
            }
             return imgScr;
            }
            """
        let imageClickJSString =
        """
         function registerImageClickAction(){
        var imgs = document.getElementsByTagName('img')
           for(var i=0;i<imgs.length;i++){
            imgs[i].customIndex = i;
             imgs[i].onclick=function() {
            window.location.href='TSimage:'+this.src;
         }
        }
        }
       """
        self.contentMarkdownView.load(markdown: model.body.ts_customMarkdownToStandard(), enableImage: true)
        contentMarkdownView.onRendered = { [unowned self] (height) in
            self.contentMarkdownView.snp.updateConstraints({ (make) in
                make.height.equalTo(height)
            })
            // 回调
            complete?(height)
            if showMoreAction {
                self.delegate?.didClickShowMoreWithNewHeight(height)
                self.showMoreClickAction?(height)
            }
            self.contentMarkdownView.webView?.evaluateJavaScript(imageClickJSString, completionHandler: nil)
            self.contentMarkdownView.webView?.evaluateJavaScript(getImagesJSString, completionHandler: nil)
            self.contentMarkdownView.webView?.evaluateJavaScript("registerImageClickAction();", completionHandler: nil)
            self.contentMarkdownView.webView?.evaluateJavaScript("getImages()", completionHandler: { (image, error) in
                if error == nil {
                    if let  image = image as? NSString {
                        let array: [String] =   image.components(separatedBy: "***")
                        self.imageArray = array
                    }
                }
            })
        }
    }

    /// yyLabel加载内容
    private func setupShortContentLabel(with content: String, model: TSQuestionDetailModel) -> Void {
        // 1. 对content进行处理，去掉图片展示
        let showContent = content.ts_customMarkdownToNormal()
        // 2. 构建富文本
        let attContent = NSMutableAttributedString(string: showContent)
        attContent.font = self.contentFont
        attContent.color = self.contentColor
        // 段落
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0        // 行间距
        attContent.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: attContent.length))

        // 3. addSeeMoreButton
        let strDot: String = "..."      // 这个有些情况下可能没有，待完善
        let strSpace: String = "  "
        let strSeeMore: String = "展示全部"
        let attMore = NSMutableAttributedString(string: strDot + strSpace + strSeeMore)
        attMore.font = self.contentFont
        attMore.setColor(UIColor(hex: 0x2495bd), range: (attMore.string as NSString).range(of: strSeeMore))

        let highlight = YYTextHighlight()
        highlight.setColor(UIColor.red)     // UIColor(hex: 0x2495bd)
        highlight.tapAction = { [weak self](containerView, text, range, rect) in
            // 展开
            self?.showMarkdown(with: model, showMoreAction: true)
        }
        attMore.setTextHighlight(highlight, range: (attMore.string as NSString).range(of: strSeeMore))
        let seeMoreLabel = YYLabel()
        seeMoreLabel.attributedText = attMore
        seeMoreLabel.sizeToFit()

        let truncationToken = NSAttributedString.attachmentString(withContent: seeMoreLabel, contentMode: UIViewContentMode.center, attachmentSize: seeMoreLabel.size, alignTo: seeMoreLabel.font!, alignment: YYTextVerticalAlignment.center)
        self.shortContentLabel.truncationToken = truncationToken
        self.shortContentLabel.attributedText = attContent
        self.shortContentLabel.numberOfLines = 3
    }

    // MARK: - Private  事件响应
    fileprivate func previewPicture() -> Void {
        var currentIndex: Int = 0
        var objectArray: [TSImageObject] = []
        for section in 0..<imageArray.count {
            let path = String(describing: imageArray[section])
            if path == self.currentImgStr {
                currentIndex = section
            }
            let object = TSImageObject()
            let subIndex = (TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue as NSString).length
            if let fileId = Int((path as NSString).substring(from: subIndex + 1)) {
                object.storageIdentity = fileId
            }
            object.cacheKey = ""
            object.mimeType = "image/jpeg"
            objectArray.append(object)
        }
        let picturePreview = TSPicturePreviewVC(objects: objectArray, imageFrames: [], images: [], At: currentIndex)
        picturePreview.show()
    }
}
