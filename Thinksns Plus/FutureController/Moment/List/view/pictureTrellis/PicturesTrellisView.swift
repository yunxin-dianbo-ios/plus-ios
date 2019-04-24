//
//  PicturesTrellisView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/10/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  九宫格预览视图

import UIKit
import Kingfisher

protocol PicturesTrellisViewDelegate: class {

    /// 点解了九宫格预览视图上的某张视图
    ///
    /// - Parameters:
    ///   - view: 九宫格预览视图
    ///   - index: 被点击的图片的下标
    func picturesTrellisView(_ view: PicturesTrellisView, didSelectPictureAt index: Int)

    /// 点击了数量蒙层按钮
    func picturesTrellisViewDidSelectedCountMaskButton(_ view: PicturesTrellisView)
}

class PicturesTrellisView: UIView {
    weak var delegate: PicturesTrellisViewDelegate?
    /// 是否按照视频占位图的规则计算图片尺寸
    var isUseVideoFrameRule: Bool = false

    /// 图片数据
    var models: [PaidPictureModel] = [] {
        didSet {
            loadModels()
        }
    }
    /// 所有图片
    var pictures: [UIImage?] {
        return pictureViews.map { $0.picture }
    }
    /// 所有图片在屏幕上的 frames
    var frames: [CGRect] {
        return pictureViews.map { $0.frameOnScreen }
    }

    /// 图片数组
    internal var pictureViews: [PictureViewer] = []

    /// 图片之间的间隙
    internal let spacing: CGFloat = 3.3
    /// 长图的宽度
    internal let widthLong: CGFloat = 259 / 375 * UIScreen.main.bounds.width
    /// 一张图宽度
    internal let width1: CGFloat = UIScreen.main.bounds.width - 116
    /// 二分之一图的宽度
    internal let width2: CGFloat = (UIScreen.main.bounds.width - 116.0 - 1.0 * 3.5) / 2.0
    /// 三分之一图的宽度
    internal let width3: CGFloat = (UIScreen.main.bounds.width - 116.0 - 2.0 * 3.5) / 3.0
    /// 四分之一图的宽度
    internal let width4: CGFloat = (UIScreen.main.bounds.width - 116.0 - 3.0 * 3.5) / 4.0

    let timerInterval: TimeInterval = 5
    var timer: Timer? = nil
    var currentIndex = 0

    // MARK: - 生命周期
    init() {
        super.init(frame: .zero)
        setUI()
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - UI

    /// 设置视图
    internal func setUI() {
        for _ in 0...8 {
            let pictureView = PictureViewer()
            pictureView.addTarget(self, action: #selector(pictureTaped(_:)), for: .touchUpInside)
            pictureView.countMaskButton.addTarget(self, action: #selector(countMaskButtonTaped), for: .touchUpInside)
            pictureViews.append(pictureView)
        }
    }

    /// 加载视图数据
    internal func loadModels() {
        removeAllPictures()
        // 1.调整需要显示的图片的数量
        let imageCount = min(models.count, 9)

        // 2.获取图片的 frames
        var pictureFrames: [CGRect] = []
        if models.count == 1 {
            let model = models[0]
            pictureFrames = [getOneFrame(pictureOriginalSize: model.originalSize)]
        } else {
            pictureFrames = getMultiFrames(count: imageCount)
        }

        // 3.刷新每张图片并更新其 frame
        for index in 0..<imageCount {
            let model = models[index]
            let pictureView = pictureViews[index]
            let pictureFrame = pictureFrames[index]
            pictureView.frame = pictureFrame
            // 如果是第九张图片，且图片的总数大于 9，那么最后一张图片要显示数量蒙层
            if index == 8 {
                model.unshowCount = models.count - 9
            }
            pictureView.model = model
            addSubview(pictureView)
        }

        // 4.更新九宫格图片视图的 frame
        updateFrame(imageCount)
    }

    /// 移除所有图片
    internal func removeAllPictures() {
        // TODO: 试一下，修改动态每次加载的逻辑，修改成重设数据和尺寸，而不是全部删除和载入
        for pictureView in pictureViews {
            guard pictureView.superview != nil else {
                continue
            }
            pictureView.removeFromSuperview()
        }
    }

    /// 设置总大小
    func updateFrame(_ pictureCount: Int) {
        // 图片 count 为 5、8 时，图片组合的高度
        let heightTotal58 = 2 * (width3 + spacing) + width2
        // 图片 count 为 4、6、7、9 时，图片组合的高度
        let heightTotal4679 = width1
        // 设置总 frame
        switch pictureCount {
        case 1:
            let newSize = getOneFrame(pictureOriginalSize: models[0].originalSize).size
            frame = CGRect(origin: frame.origin, size: newSize)
        case 2:
            frame = CGRect(x: frame.minX, y: frame.minY, width: width1, height: width2)
        case 3:
            frame = CGRect(x: frame.minX, y: frame.minY, width: width1, height: width3)
        case 4, 9:
            frame = CGRect(x: frame.minX, y: frame.minY, width: width1, height: heightTotal4679)
        case 6, 7, 5, 8:
            frame = CGRect(x: frame.minX, y: frame.minY, width: width1, height: width1)
        default:
            frame = CGRect(x: frame.minX, y: frame.minY, width: width1, height: 0)
        }
    }

    // MARK: - 用户交互

    /// 点击了单张图片
    func pictureTaped(_ sender: PictureViewer) {
        guard let index = pictureViews.index(of: sender) else {
            return
        }
        delegate?.picturesTrellisView(self, didSelectPictureAt: index)
    }

    /// 点击了数量蒙层
    func countMaskButtonTaped() {
        delegate?.picturesTrellisViewDidSelectedCountMaskButton(self)
    }
}

// MARK: - 子视图 frame 计算
extension PicturesTrellisView {

    open func getMultiFrames(count: Int) -> [CGRect] {
        switch count {
        case 2, 3, 4, 9:
            return get2349Frames(count:count)
        case 5:
            return get5Frames()
        case 6:
            return get6Frames()
        case 7:
            return get7Frames()
        case 8:
            return get8Frames()
        default:
            return []
        }
    }

    // 一张图设置
    ///
    /// - Parameters:
    ///   - pictureOriginalSize: 图片原大小
    ///   - isLong: 是否为长图
    /// - Returns: 一张图时显示的大小
    open func getOneFrame(pictureOriginalSize: CGSize) -> CGRect {
        guard isUseVideoFrameRule == false else {
            // 视屏的占位图是另外的计算规则
//            如果 宽等于高 播放器大小显示为width1*width1 播放时内容等比缩放，完整填充播放
//            如果 宽小于高（竖着的长方形） 播放器大小显示width1*width1 播放时内容等比缩放，左右无内容处两边显示黑边
//            如果 宽大于高（横着的长方形） 播放器大小显示宽度width1*高度为原视频高度等比缩放后的高度 播放时内容等比缩放，完成填充内容播放
            if pictureOriginalSize.width == pictureOriginalSize.height {
                let buttonFrame = CGRect(x: 0, y: 0, width: width1, height: width1)
                return buttonFrame
            } else if pictureOriginalSize.width < pictureOriginalSize.height {
                let buttonFrame = CGRect(x: 0, y: 0, width: width1, height: width1)
                return buttonFrame
            } else if pictureOriginalSize.width > pictureOriginalSize.height {
                var heigth = width1 / pictureOriginalSize.width * pictureOriginalSize.height
                if heigth > width1 {
                    heigth = width1
                }
                let buttonFrame = CGRect(x: 0, y: 0, width: width1, height: heigth)
                return buttonFrame
            }
            return CGRect.zero
        }
        if pictureOriginalSize.isLongPictureSize() {
            // 如果是长图
            let heigth = widthLong * 1.333
            let buttonFrame = CGRect(x: 0, y: 0, width: widthLong, height: heigth)
            return buttonFrame
        } else {
            // 如果不是长图
            var heigth = width1 / pictureOriginalSize.width * pictureOriginalSize.height
            // 高度最大尺寸为最大宽度的 4/3
            if heigth > width1 * 4 / 3 {
                heigth = width1 * 4 / 3
            }
            let buttonFrame = CGRect(x: 0, y: 0, width: width1, height: heigth)
            return buttonFrame
        }
    }

    // MARK: 内部调用方法
    /// 2/3/4/9 张图设置
    internal func get2349Frames(count: Int) -> [CGRect] {
        var frames: [CGRect] = []
        for index in 0...count - 1 {
            var buttonFrame = CGRect.zero
            let number = (count == 2 || count == 4) ? 2 : 3
            let buttonWidth = (width1 - CGFloat(number - 1) * spacing) / CGFloat(number)
            buttonFrame = CGRect(x: CGFloat(index % number) * (buttonWidth + spacing), y: CGFloat(index / number) * (buttonWidth + spacing), width: buttonWidth, height: buttonWidth)
            frames.append(buttonFrame)
        }
        return frames
    }

    /// 五张图设置
    internal func get5Frames() -> [CGRect] {
        var frames: [CGRect] = []
        for index in 0...4 {
            var buttonFrame = CGRect.zero
            if index == 0 {
                buttonFrame = CGRect(x: 0, y: 0, width: width3 * 2 + spacing, height: width3 * 2 + spacing)
            }
            if index == 1 || index == 2 {
                buttonFrame = CGRect(x: (width3 + spacing) * 2, y: CGFloat(index - 1) * (width3 + spacing), width: width3, height: width3)
            }
            if index == 3 || index == 4 {
                buttonFrame = CGRect(x: CGFloat(index - 3) * (width2 + spacing), y: (width3 + spacing) * 2, width: width2, height: width3)
            }
            frames.append(buttonFrame)
        }
        return frames
    }

    /// 六张图设置
    internal func get6Frames() -> [CGRect] {
        var frames: [CGRect] = []
        for index in 0...5 {
            var buttonFrame = CGRect.zero
            if index == 0 {
                buttonFrame = CGRect(x: 0, y: 0, width: width3 * 2 + spacing, height: width3 * 2 + spacing)
            }
            if index == 1 || index == 2 {
                buttonFrame = CGRect(x: (width3 + spacing) * 2, y: CGFloat(index - 1) * (width3 + spacing), width: width3, height: width3)
            }
            if index > 2 {
                buttonFrame = CGRect(x: CGFloat(index - 3) * (width3 + spacing), y: (width3 + spacing) * 2, width: width3, height: width3)
            }
            frames.append(buttonFrame)
        }
        return frames
    }

    /// 七张图设置
    internal func get7Frames() -> [CGRect] {
        var frames: [CGRect] = []
        for index in 0...6 {
            var buttonFrame = CGRect.zero
            if index == 0 {
                buttonFrame = CGRect(x: 0, y: 0, width: width2, height: width2)
            }
            if index == 1 || index == 2 {
                buttonFrame = CGRect(x: width2 + spacing + CGFloat(index - 1) * (width4 + spacing), y: 0, width: width4, height: width4)
            }
            if index == 3 {
                buttonFrame = CGRect(x: width2 + spacing, y: width4 + spacing, width: width2, height: width2)
            }
            if index == 4 {
                buttonFrame = CGRect(x: 0, y: width2 + spacing, width: width2, height: width2)
            }
            if index > 4 {
                buttonFrame = CGRect(x: width2 + spacing + CGFloat(index - 5) * (width4 + spacing), y: width2 + spacing * 2 + width4, width: width4, height: width4)
            }
            frames.append(buttonFrame)
        }
        return frames
    }

    /// 八张图设置
    internal func get8Frames() -> [CGRect] {
        var frames: [CGRect] = []
        for index in 0...7 {
            var buttonFrame = CGRect.zero
            if index < 3 {
                buttonFrame = CGRect(x: CGFloat(index) * (width3 + spacing), y: 0, width: width3, height: width3)
            }
            if index == 3 || index == 4 {
                buttonFrame = CGRect(x: CGFloat(index - 3) * (spacing + width2), y: width3 + spacing, width: width2, height: width3)
            }
            if index > 4 {
                buttonFrame = CGRect(x: CGFloat(index - 5) * (width3 + spacing), y: (width3 + spacing) * 2, width: width3, height: width3)
            }
            frames.append(buttonFrame)
        }
        return frames
    }
}
