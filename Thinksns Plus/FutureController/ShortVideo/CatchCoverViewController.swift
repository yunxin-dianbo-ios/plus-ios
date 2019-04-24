//
//  CatchCoverViewController.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/4/19.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import SCRecorder

class CatchCoverViewController: UIViewController {
    weak var superVC: RecorderViewController?
    var exportSession: SCAssetExportSession?
    var recordSession: SCRecordSession!
    var session: [Float64] {
        return recordSession.segments.map({ (segment) -> Float64 in
            return CMTimeGetSeconds(segment.duration)
        })
    }
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var finishBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let segment = recordSession.segments.first, let image = segment.thumbnail {
            coverImageView.image = image
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard coverImageView.image == nil else {
            return
        }
        if let segment = recordSession.segments.first, let image = segment.thumbnail {
            coverImageView.image = image
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        UIApplication.shared.isStatusBarHidden = false
    }

    func catchCoverImage(segmentsIndex: Int, time: CMTime) {
        guard let asset = recordSession.segments[segmentsIndex].asset else {
            return
        }
        let assetImage = AVAssetImageGenerator(asset: asset)
        assetImage.appliesPreferredTrackTransform = true
        assetImage.requestedTimeToleranceAfter = kCMTimeZero
        assetImage.requestedTimeToleranceBefore = kCMTimeZero
        assetImage.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels
        var thumbnailImage: CGImage?
        do {
            try thumbnailImage = assetImage.copyCGImage(at: time, actualTime: nil)
        } catch {
            print(error.localizedDescription)
        }
        guard let cgImage = thumbnailImage else {
            return
        }
        coverImageView.image = UIImage(cgImage: cgImage)
    }

    @IBAction func slidervalueChanged(_ sender: UISlider) {
        let total = session.reduce(0.0) { (result, value) -> Float64 in
            return result + value
        }
        let currentTime = Double(sender.value) * total
        var currentIndex = 0
        for (index, _) in session.enumerated() {
            let groupTotal = session[0...index].reduce(0.0) { (result, value) -> Float64 in
                return result + value
            }
            if currentTime < groupTotal {
                currentIndex = index
                break
            }
        }
        var groupIndeValue = 0.0
        if currentIndex == 0 {
            groupIndeValue = currentTime
        } else {
            let index = currentIndex - 1
            let groupTotal = session[0...index].reduce(0.0) { (result, value) -> Float64 in
                return result + value
            }
            groupIndeValue = currentTime - groupTotal
        }
        let time = CMTimeMakeWithSeconds(groupIndeValue, Int32(1 * USEC_PER_SEC))
        catchCoverImage(segmentsIndex: currentIndex, time: time)
    }

    @IBAction func fininshBtnAction(_ sender: Any) {
        self.finishBtn.isEnabled = false
        self.backBtn.isEnabled = false
        let exportSession = SCAssetExportSession(asset: recordSession.assetRepresentingSegments())
        exportSession.videoConfiguration.maxFrameRate = 35
        exportSession.outputUrl = recordSession.outputUrl
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.contextType = SCContextType.auto

        let videoConfig = exportSession.videoConfiguration
        videoConfig.size = CGSize(width: 720, height: 720)

        self.exportSession = exportSession
        exportSession.exportAsynchronously { [weak self] in
            guard let `self` = self else {
                return
            }
            self.exportSession = nil
            if let error = exportSession.error {
                UIAlertView(title: "存储错误", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "知道了").show()
                self.finishBtn.isEnabled = false
                self.backBtn.isEnabled = false
            } else {
                UIApplication.shared.beginIgnoringInteractionEvents()
                let saveToCameraRoll = SCSaveToCameraRollOperation()
                saveToCameraRoll.saveVideoURL(exportSession.outputUrl!) { [weak self] path, error in
                    guard let `self` = self else {
                        return
                    }
                    UIApplication.shared.endIgnoringInteractionEvents()
                    if let error = error {
                        UIAlertView(title: "存储错误", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "知道了").show()
                        self.finishBtn.isEnabled = false
                        self.backBtn.isEnabled = false
                    } else {
                        if let _ = self.recordSession.segments.first?.thumbnail {
                            if self.superVC?.isDismissOrPop == false {
                                self.superVC?.delegate?.finishRecorder(recordSession: self.recordSession, coverImage: self.coverImageView.image!)
                                self.navigationController?.popToRootViewController(animated: true)
                            } else {
                                self.navigationController?.dismiss(animated: true) {
                                    self.superVC?.delegate?.finishRecorder(recordSession: self.recordSession, coverImage: self.coverImageView.image!)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
