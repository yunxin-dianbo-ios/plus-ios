//
// Created by lip on 2018/3/20.
// Copyright (c) 2018 zhiyicx. All rights reserved.
//
// 视频预览页面，暂时废弃

import UIKit
import SCRecorder
import MobileCoreServices

class ProcessMediaViewController: UIViewController {
    @IBOutlet weak var filterView: SCSwipeableFilterView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var cancleBtn: UIButton!
    weak var superVC: RecorderViewController?
    var exportSession: SCAssetExportSession?
    var recordSession: SCRecordSession!
    var player: SCPlayer!

    // MARK: - life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
        player.setItemBy(recordSession.assetRepresentingSegments())
        player.play()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSC()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
        player.pause()
    }

    deinit {
        player.pause()
        player = nil
        filterView = nil
        exportSession?.cancelExport()
    }

    // MARK: setup
    func setupUI() {
        maskView.isHidden = true
        finishBtn.setEnlargeResponseAreaEdge(size: 20)
        cancleBtn.setEnlargeResponseAreaEdge(size: 20)
    }

    func setupSC() {
        player = SCPlayer()
        if ProcessInfo.processInfo.activeProcessorCount > 1 {
            self.filterView.contentMode = UIViewContentMode.scaleAspectFit
            let emptyFilter = SCFilter.empty()
            emptyFilter.name = "无"
            let chrome = SCFilter(ciFilterName: "CIPhotoEffectChrome")
            chrome.name = "老照片"
            let fade = SCFilter(ciFilterName: "CIPhotoEffectFade")
            fade.name = "胶片"
            let instant = SCFilter(ciFilterName: "CIPhotoEffectInstant")
            instant.name = "老电影"
            let mono = SCFilter(ciFilterName: "CIPhotoEffectMono")
            mono.name = "黑白"
            let transfer = SCFilter(ciFilterName: "CIPhotoEffectTransfer")
            transfer.name = "温暖"

            filterView.filters = [emptyFilter, chrome, fade, instant, mono, transfer]
            player.scImageView = filterView
        } else {
            let playerView = SCVideoPlayerView(player: player)
            playerView.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            playerView.frame = filterView.frame
            playerView.autoresizingMask = filterView.autoresizingMask
            filterView.superview?.insertSubview(playerView, aboveSubview: filterView)
            filterView.removeFromSuperview()
        }
        player.loopEnabled = true
    }

    // MARK: btn action
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func finishBtnAction(_ sender: Any) {
        guard let currentFilter = filterView.selectedFilter?.copy() as? SCFilter else {
            return
        }
        player.pause()

        let exportSession = SCAssetExportSession(asset: recordSession.assetRepresentingSegments())
        exportSession.videoConfiguration.filter = currentFilter
        exportSession.videoConfiguration.maxFrameRate = 35
        exportSession.outputUrl = recordSession.outputUrl
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.delegate = self
        exportSession.contextType = SCContextType.auto

        let videoConfig = exportSession.videoConfiguration
        videoConfig.bitrate = 2_000_000
        videoConfig.size = CGSize(width: 640, height: 640)
        videoConfig.scalingMode = AVVideoScalingModeResize
        videoConfig.timeScale = 1
        videoConfig.sizeAsSquare = true

        let audioConfig = exportSession.audioConfiguration
        audioConfig.bitrate = 128_000
        audioConfig.channelsCount = 1
        audioConfig.sampleRate = 0
        audioConfig.format = Int32(kAudioFormatMPEG4AAC)

        self.exportSession = exportSession

        maskView.isHidden = false
        maskView.alpha = 0
        UIView.animate(withDuration: 0.3) { () -> Void in
            self.maskView.alpha = 1
        }

        exportSession.exportAsynchronously { [weak self] in
            guard let `self` = self else {
                return
            }
            self.player.play()
            self.exportSession = nil
            UIView.animate(withDuration: 0.3) { () -> Void in
                self.maskView.alpha = 0
                self.maskView.isHidden = true
            }
            if let error = exportSession.error {
                UIAlertView(title: "存储错误", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "知道了").show()
            } else {
                UIApplication.shared.beginIgnoringInteractionEvents()
                let saveToCameraRoll = SCSaveToCameraRollOperation()
                saveToCameraRoll.saveVideoURL(exportSession.outputUrl!) { [weak self] path, error in
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if let error = error {
                        UIAlertView(title: "存储错误", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "知道了").show()
                    } else {
//                        if let _ = self?.recordSession.segments.first?.thumbnail {
//                            if self?.superVC?.isDismissOrPop == false {
//                                self?.superVC?.delegate?.finishRecorder(recordSession: self!.recordSession)
//                                self?.navigationController?.popToRootViewController(animated: true)
//                            } else {
//                                self?.navigationController?.dismiss(animated: true) {
//                                    self?.superVC?.delegate?.finishRecorder(recordSession: self!.recordSession)
//                                }
//                            }
//                        }
                    }
                }
            }
        }
    }
}

extension ProcessMediaViewController: SCPlayerDelegate {

}

extension ProcessMediaViewController: SCAssetExportSessionDelegate {

}
