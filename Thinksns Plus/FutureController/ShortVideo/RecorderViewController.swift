//
// Created by lip on 2018/3/20.
// Copyright (c) 2018 zhiyicx. All rights reserved.
//

import UIKit
import SCRecorder
import AVFoundation
import Vivid

protocol RecorderVCDelegate: NSObjectProtocol {
    func finishRecorder(recordSession: SCRecordSession, coverImage: UIImage)
}

class RecorderProgressView: UIView {
    private let backgroundView: UIView = UIView()
    // 录制持续时间视图
    private let totalDurationView: UIView = UIView()
    // 录制最短时间标注
    private let minDurationView: UIView = UIView()
    // 录制碎片标注数组
    private var tagViews: [UIView] = []
    // 最小时长 在RecorderViewController中配置
    fileprivate var minDuration: CGFloat
    // 最大时长 在RecorderViewController中配置
    fileprivate var maxDuration: CGFloat

    // 更新播放片段
    func update(sessionDurations durations: [Float]) {
        while durations.count != tagViews.count {
            if tagViews.count < durations.count {
                let tag = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width * (1 / 100), height: self.frame.height))
                tag.backgroundColor = UIColor.white
                tagViews.append(tag)
                self.insertSubview(tag, aboveSubview: totalDurationView)
            } else if tagViews.count > durations.count {
                tagViews.last?.removeFromSuperview()
                tagViews.removeLast()
            }
        }

        for (index, duration) in durations.enumerated() {
            var cgDuration = CGFloat(duration)
            if cgDuration > maxDuration {
                cgDuration = maxDuration
            }
            guard index < tagViews.count else {
                assert(false, "不应该出现越界的情况,之前的计算应保证两个数组一样大")
                return
            }
            let tag = tagViews[index]
            tag.frame = CGRect(x: self.frame.width * (cgDuration / maxDuration) - 4, y: 0, width: 4, height: self.frame.height)
        }
    }

    func update(duration: Float) {
        var currentDuration = CGFloat(duration)
        if currentDuration > maxDuration {
            currentDuration = maxDuration
        }
        totalDurationView.frame = CGRect(x: 0, y: 0, width: self.frame.width * (currentDuration / maxDuration), height: self.frame.height)
    }

    init(frame: CGRect, minDuration: CGFloat, maxDuration: CGFloat) {
        self.minDuration = minDuration
        self.maxDuration = maxDuration
        super.init(frame: frame)
        backgroundView.frame = self.bounds
        backgroundView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.7)
        self.addSubview(backgroundView)
        minDurationView.frame = CGRect(x: self.frame.width * (minDuration / maxDuration), y: 0, width: 4, height: self.frame.height)
        minDurationView.backgroundColor = UIColor.white
        self.addSubview(minDurationView)
        totalDurationView.frame = CGRect.zero
        totalDurationView.backgroundColor = TSColor.main.theme
        self.addSubview(totalDurationView)
    }

    required init?(coder aDecoder: NSCoder) {
        self.minDuration = 0
        self.maxDuration = 0
        super.init(coder: aDecoder)
    }
}

class RecorderConsole: UIView {
    enum RecorderBtnType: Int {
        /// 等待录制的状态
        case normal = 10_000
        /// 自动录制状态
        case autoRecording = 10_010
        /// 手动录制状态 (长按)
        case manuRecording = 10_086
    }
    /// 录制器进度条
    private var recorderProgressView: RecorderProgressView!    /// 录制按钮
    /// - Note: 点击和长按2种手势,2种动画,点击后超过最低时间还会出现暂停按钮.
    let recorderBtn: UIButton = UIButton(type: .custom)
    /// 撤销录制按钮
    let undoRecorderBtn: UIButton = UIButton(type: .custom)
    /// 录制完成按钮
    let finishRecorderBtn: UIButton = UIButton(type: .custom)
    /// 美颜开关按钮
    let whiteningBtn: UIButton = UIButton(type: .custom)
    /// 切换摄像头按钮
    let reverseCameraBtn: UIButton = UIButton(type: .custom)
    // 最小时长
    var minDuration: CGFloat = 0
    // 最大时长
    var maxDuration: CGFloat = 0

    init(frame: CGRect, minDuration: CGFloat, maxDuration: CGFloat) {
        self.minDuration = minDuration
        self.maxDuration = maxDuration
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        recorderProgressView = RecorderProgressView(frame: CGRect(x: 0, y: TSLiuhaiHeight, width: UIScreen.main.bounds.width, height: 4), minDuration: minDuration, maxDuration: maxDuration)
        self.addSubview(recorderProgressView)
        recorderBtn.frame = CGRect(x: self.bounds.width / 2 - 40, y: self.bounds.maxY - 40 - 80, width: 80, height: 80)
        recorderBtn.tag = RecorderBtnType.normal.rawValue
        recorderBtn.setImage(UIImage(named: "ico_video_record"), for: .normal)
        self.addSubview(recorderBtn)

        finishRecorderBtn.frame = CGRect(x: self.bounds.width - 15 - 50, y: TSStatusBarHeight + 12, width: 50, height: 16)
        finishRecorderBtn.setTitle("下一步", for: .normal)
        finishRecorderBtn.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.navigation.rawValue)
        finishRecorderBtn.setTitleColor(UIColor.white, for: .normal)
        finishRecorderBtn.isHidden = true
        finishRecorderBtn.setEnlargeResponseAreaEdge(size: 20)
        self.addSubview(finishRecorderBtn)

        undoRecorderBtn.frame = CGRect(x: 43, y: self.bounds.maxY - 60 - 40, width: 40, height: 40)
        undoRecorderBtn.setImage(UIImage(named: "ico_video_delete"), for: .normal)
        undoRecorderBtn.isHidden = true
        self.addSubview(undoRecorderBtn)

        whiteningBtn.setImage(UIImage(named: "ico_video_beauty_close"), for: .normal)
        whiteningBtn.setImage(UIImage(named: "ico_video_beauty_on"), for: .selected)
        whiteningBtn.frame = undoRecorderBtn.frame
        whiteningBtn.isHidden = false
        self.addSubview(whiteningBtn)

        reverseCameraBtn.setImage(UIImage(named: "ico_video_camera"), for: .normal)
        reverseCameraBtn.frame = CGRect(x: self.bounds.width - 43 - 40, y: self.bounds.maxY - 60 - 40, width: 40, height: 40)
        reverseCameraBtn.isHidden = false
        self.addSubview(reverseCameraBtn)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func update(duration: Float) {
        finishRecorderBtn.isHidden = duration < Float(minDuration)
        whiteningBtn.isHidden = duration > 0
        recorderProgressView.update(duration: duration)
    }

    func update(sessionDurations durations: [Float]) {
        if durations.count <= 0 {
            undoRecorderBtn.isHidden = true
        }
        recorderProgressView.update(sessionDurations: durations)
    }
}

class RecorderViewController: UIViewController {
    // MARK: - property
    /// 最小录制时长
    fileprivate var minDuration: CGFloat = 10
    /// 最大录制时长
    fileprivate var maxDuration: CGFloat = 60
    let previewView: UIView = UIView()
    let loadingView: UIView = UIView()
    let scImageView: SCFilterImageView = SCFilterImageView(frame: CGRect.zero)
    /// 返回按钮
    let backBtn: UIButton = UIButton(type: .custom)
    /// 控制台
    var recorderConsole: RecorderConsole!
    var focusView: SCRecorderToolsView = SCRecorderToolsView()
    var recorder: SCRecorder!
    weak var delegate: RecorderVCDelegate?
    /// 录制结束时,是撤销整个导航栏还是回到nav的根控制器 true 标识撤销整个
    var isDismissOrPop: Bool = true
    /// 屏幕居中 宽高等于屏幕宽度的
    let centerFrame = CGRect(x: 0, y: (UIScreen.main.bounds.height - UIScreen.main.bounds.width) / 2, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)

    /// 最小录制时长, 最大录制时长
    init(minDuration: CGFloat, maxDuration: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        if minDuration > 0, maxDuration > 0 {
            if maxDuration > minDuration {
                self.minDuration = minDuration
                self.maxDuration = maxDuration
            } else {
                self.maxDuration = maxDuration
                self.minDuration = maxDuration
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setup
    func setupUI() {
        /** setup roo view */
        view.backgroundColor = UIColor.darkText
        previewView.frame = view.bounds
        previewView.backgroundColor = UIColor.clear
        view.addSubview(previewView)
        // 在预览页面顶部和底部增加黑色view 只显示屏幕中间部门，编辑页面也如此，最后在导出视频时，只导出正方形的视频即可。
        let topBlackMaskView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: (UIScreen.main.bounds.height - UIScreen.main.bounds.width) / 2))
        topBlackMaskView.backgroundColor = UIColor.black
        view.addSubview(topBlackMaskView)
        let bottomBlackMaskView = UIView(frame: CGRect(x: 0, y: centerFrame.maxY, width: view.bounds.width, height: (UIScreen.main.bounds.height - UIScreen.main.bounds.width) / 2))
        bottomBlackMaskView.backgroundColor = UIColor.black
        view.addSubview(bottomBlackMaskView)
        /// 加载试图，没有被使用
//        loadingView.frame = previewView.bounds
//        loadingView.backgroundColor = UIColor.black
//        loadingView.alpha = 0.4
//        previewView.addSubview(loadingView)
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicatorView.center = loadingView.center
        loadingView.addSubview(activityIndicatorView)
        loadingView.isHidden = true
        recorderConsole = RecorderConsole(frame: UIScreen.main.bounds, minDuration: minDuration, maxDuration: maxDuration)
        view.addSubview(recorderConsole)
        /** setup btn */
        backBtn.frame = CGRect(x: 16, y: TSStatusBarHeight + 12, width: 18, height: 18)
        backBtn.setImage(UIImage(named: "ico_video_close"), for: .normal)
        backBtn.addTarget(self, action: #selector(popViewController(_:)), for: .touchUpInside)
        view.addSubview(backBtn)
        backBtn.setEnlargeResponseAreaEdge(size: 20)
        recorderConsole.recorderBtn.addTarget(self, action: #selector(action(recorderbtn:)), for: .touchUpInside)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        recorderConsole.recorderBtn.addGestureRecognizer(longPress)
        recorderConsole.undoRecorderBtn.addTarget(self, action: #selector(action(undoRecorderBtn:)), for: .touchUpInside)
        recorderConsole.finishRecorderBtn.addTarget(self, action: #selector(action(finishRecorderBtn:)), for: .touchUpInside)
        recorderConsole.whiteningBtn.addTarget(self, action: #selector(action(whiteBtn:)), for: .touchUpInside)
        recorderConsole.reverseCameraBtn.addTarget(self, action: #selector(action(reverseCamera:)), for: .touchUpInside)
    }

    func setupRecorder() {
        recorder = SCRecorder()
        recorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
        recorder.maxRecordDuration = CMTimeMakeWithSeconds(10, 600)
        /// maxTime, maxTime * fps
        recorder.maxRecordDuration = CMTimeMakeWithSeconds(60, 60 * 30)
        // recorder.fastRecordMethodEnabled = true 启动快速录制
        recorder.delegate = self
        recorder.autoSetVideoOrientation = false
        recorder.previewView = previewView
        recorder.initializeSessionLazily = false
        recorder.mirrorOnFrontCamera = true
        recorder.device = .back
        /// videoConfig
        recorder.videoConfiguration.enabled = true
        recorder.videoConfiguration.timeScale = 1
        recorder.videoConfiguration.filter = SCFilter(ciFilterName: "CIPhotoEffectFade")
        recorder.videoConfiguration.sizeAsSquare = true
        recorder.videoConfiguration.bitrate = 2_000_000

        scImageView.frame = previewView.bounds
        scImageView.filter = SCFilter(ciFilterName: "CIPhotoEffectFade")
        recorder.scImageView = scImageView
        previewView.addSubview(scImageView)

//        let audioConfig = recorder.audioConfiguration
//        audioConfig.bitrate = 128_000
//        audioConfig.channelsCount = 1
//        audioConfig.sampleRate = 0
//        audioConfig.format = Int32(kAudioFormatMPEG4AAC)

        /** setup focusView */
        focusView = SCRecorderToolsView(frame: centerFrame)
        focusView.autoresizingMask = [UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleWidth]
        focusView.outsideFocusTargetImage = UIImage(named: "ico_video_focusing")
        focusView.recorder = recorder
        recorderConsole.insertSubview(focusView, at: 0)

        do {
            try recorder.prepare()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    // MARK: set btn action
    func action(reverseCamera btn: UIButton) {
        recorder.switchCaptureDevices()
    }

    func action(whiteBtn btn: UIButton) {
        let mono = SCFilter(ciFilterName: "CIPhotoEffectFade")
        let empty = SCFilter.empty()
        let videoConfig = recorder.videoConfiguration
        if btn.isSelected { // 关闭美颜
            videoConfig.filter = mono
            scImageView.filter = mono
        } else {
            videoConfig.filter = empty
            scImageView.filter = empty
        }
        btn.isSelected = !btn.isSelected
    }

    func action(finishRecorderBtn btn: UIButton) {
        recorder.pause {
            if let session = self.recorder.session {
                if session.segments.isEmpty {
                    TSLogCenter.log.debug("\n\nsession.segments.isEmpty\n\n")
                    return
                }
                SCRecordSessionManager.sharedInstance().save(session)
                let vc = CatchCoverViewController(nibName: "CatchCoverViewController", bundle: nil)
                vc.recordSession = session
                vc.superVC = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        prepareDuration(withSession: recorder.session)
    }

    func action(undoRecorderBtn btn: UIButton) {
        let actionsheetView = TSCustomActionsheetView(titles: ["确定要删除上一段已录制视频吗", "是的"])
        actionsheetView.delegate = self
        actionsheetView.notClickIndexs = [0]
        actionsheetView.tag = 2
        actionsheetView.show()
    }

    func popViewController(_ sender: UIButton) {
        guard let session = recorder.session else {
            navigationController?.dismiss(animated: true)
            return
        }
        if session.segments.isEmpty {
            navigationController?.dismiss(animated: true)
            return
        }
        let actionsheetView = TSCustomActionsheetView(titles: ["视频录制尚未完成，是否取消录制？", "是的"])
        actionsheetView.delegate = self
        actionsheetView.notClickIndexs = [0]
        actionsheetView.tag = 1
        actionsheetView.show()
    }

    func action(recorderbtn recorderBtn: UIButton) {
        guard let type = RecorderConsole.RecorderBtnType(rawValue: recorderBtn.tag) else {
            assert(false, "错误的设置了这个录制按钮的tag值")
            return
        }
        switch type {
        case .normal: // 按钮正常的情况下,被点击了一下,进入自动录制
            recorderBtn.setImage(UIImage(named: "ico_video_recording"), for: .normal)
            recorderBtn.tag = RecorderConsole.RecorderBtnType.autoRecording.rawValue
            recorderConsole.reverseCameraBtn.isHidden = true
            recorderConsole.undoRecorderBtn.isHidden = true
            recorder.record()
        case .autoRecording: // 按钮自动录制的情况下,被点击了一下,进入正常模式
            recorderBtn.setImage(UIImage(named: "ico_video_record"), for: .normal)
            recorderBtn.tag = RecorderConsole.RecorderBtnType.normal.rawValue
            recorderConsole.reverseCameraBtn.isHidden = false
            recorderConsole.undoRecorderBtn.isHidden = false
            recorder.pause()
        case .manuRecording:
            assert(false, "手动录制的情况下按钮是怎么又一次响应点击的")
            break
        }
    }

    func longPress(_ longPress: UILongPressGestureRecognizer) {
        let btn = recorderConsole.recorderBtn
        guard let type = RecorderConsole.RecorderBtnType(rawValue: btn.tag) else {
            assert(false, "错误的设置了这个录制按钮的tag值")
            return
        }
        if longPress.state == UIGestureRecognizerState.began && type == .normal {
            btn.setImage(UIImage(named: "ico_video_recording"), for: .normal)
            btn.tag = RecorderConsole.RecorderBtnType.manuRecording.rawValue
            recorderConsole.reverseCameraBtn.isHidden = true
            recorderConsole.undoRecorderBtn.isHidden = true
            recorder.record()
        }
        if (longPress.state == .cancelled || longPress.state == .ended) && type == .manuRecording {
            btn.setImage(UIImage(named: "ico_video_record"), for: .normal)
            btn.tag = RecorderConsole.RecorderBtnType.normal.rawValue
            recorderConsole.reverseCameraBtn.isHidden = false
            recorderConsole.undoRecorderBtn.isHidden = false
            recorder.pause()
        }
    }

    // MARK: - lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareSession()
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRecorder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recorder.startRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recorder.previewViewFrameChanged()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recorder.stopRunning()
        UIApplication.shared.isStatusBarHidden = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    deinit {
        recorder = nil
    }
}

extension RecorderViewController: TSCustomAcionSheetDelegate {
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if view.tag == 1 {
            navigationController?.dismiss(animated: true)
        } else if view.tag == 2 {
            guard let session = recorder.session else {
                return
            }
            if session.segments.isEmpty {
                return
            }
            session.removeLastSegment()
            prepareDuration(withSession: recorder.session)
        }
    }
}

// MARK: - delegate
// MARK: SCRecorderDelegate
extension RecorderViewController: SCRecorderDelegate {
    // session 中开始一个片段的录制
    func recorder(_ recorder: SCRecorder, didBeginSegmentIn session: SCRecordSession, error: Error?) {
        print("session 中开始一个片段的录制")
    }

    // session 中完成一个片段的录制
    func recorder(_ recorder: SCRecorder, didComplete segment: SCRecordSessionSegment?, in session: SCRecordSession, error: Error?) {
        if let error = error {
            print("session中完成一个片段的录制出错: \(error.localizedDescription)")
            return
        }
        prepareDuration(withSession: recorder.session)
    }

    // session 达到了最大时长
    func recorder(_ recorder: SCRecorder, didComplete session: SCRecordSession) {
        print("session 达到了最大时长")
    }

    // session 中的录制器初始化音频完毕
    func recorder(_ recorder: SCRecorder, didInitializeAudioIn session: SCRecordSession, error: Error?) {
        print("session 中的录制器初始化音频完毕")
    }

    // session 中的录制器初始化视频完毕
    func recorder(_ recorder: SCRecorder, didInitializeVideoIn session: SCRecordSession, error: Error?) {
        print("session 中的录制器初始化视频完毕")
    }

    // session 中的录制器在添加视频缓冲
    func recorder(_ recorder: SCRecorder, didAppendVideoSampleBufferIn session: SCRecordSession) {
        guard let currentTime = recorder.session?.duration else {
            return
        }
        if CMTimeGetSeconds(currentTime) >= Double(maxDuration) { // 视频达到了最大时长
            self.action(finishRecorderBtn: UIButton())
            return
        }
        self.recorderConsole.update(duration: Float(CMTimeGetSeconds(currentTime)))
    }

    // session 中的录制器在添加音频缓冲
    func recorder(_ recorder: SCRecorder, didAppendAudioSampleBufferIn session: SCRecordSession) {
    }

    // session 中的录制器跳过视频缓冲区
    func recorder(_ recorder: SCRecorder, didSkipVideoSampleBufferIn session: SCRecordSession) {
        print("session 中的录制器跳过视频缓冲区")
    }

    // recorder重新配置audioInput
    func recorder(_ recorder: SCRecorder, didReconfigureAudioInput audioInputError: Error?) {
        print("Reconfigured audio --- input: \(audioInputError?.localizedDescription ?? "" )")
    }

    // recorder重新配置 videoInput
    func recorder(_ recorder: SCRecorder, didReconfigureVideoInput videoInputError: Error?) {
        print("Reconfigured video --- input: \(videoInputError?.localizedDescription ?? "" )")
    }
}

// MARK: - handle
// MARK: handle session
extension RecorderViewController {
    fileprivate func prepareSession() {
        if recorder.session == nil {
            let session = SCRecordSession()
            session.fileType = AVFileTypeMPEG4
            recorder.session = session
        }
    }

    func prepareDuration(withSession session: SCRecordSession?) {
        guard let segments = session?.segments else {
            recorderConsole.update(sessionDurations: [])
            recorderConsole.update(duration: 0)
            return
        }
        var durations = [Float]()
        for (index, _) in segments.enumerated() {
            var totalTime: CMTime = kCMTimeZero
            for time in segments[0...index] {
                let segment: SCRecordSessionSegment = time
                let duration: CMTime = segment.duration
                // 计算总时长 加上再写入
                totalTime = CMTimeAdd(totalTime, duration)
            }
            durations.append(Float(CMTimeGetSeconds(totalTime)))
        }
        recorderConsole.update(sessionDurations: durations)
        guard let currentTime = recorder.session?.duration else {
            return
        }
        recorderConsole.update(duration: Float(CMTimeGetSeconds(currentTime)))
    }
}
