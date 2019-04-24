platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

# 通过pod 使用三方库时,必须指定明确的版本号!方便同期开发的用户使用相同的三方,方便后续更新!
# 编辑该文件时,必须使用专业的编辑器.不允许使用记事本编辑,避免导致的乱码错误引发的问题.
# 开发中的无版本号的 pod 管理的库,需要使用`pod update`命令更新

target 'ThinkSNSPlus' do
  pod 'YYKit', '1.0.9'                      # iOS 组件
  pod 'SwiftyJSON', '3.1.3'                 # json 解析
  pod 'STRegex', '1.1.0'                    # regex 处理
  pod 'MonkeyKing', '1.3.0'                 # 三方分享
  pod 'XCGLogger', '4.0.0'                  # 日志输出
  pod 'KeychainAccess', '3.0.1'             # 钥匙串管理
  pod 'SwiftDate', '4.0.11'                 # 日期处理
  pod 'KMPlaceholderTextView', '1.3.0'      # 带占位符的TextView
  pod 'SnapKit', '3.1.2'                    # UI布局组件
  pod 'ReachabilitySwift', '3'              # 网络连接性检查
  pod 'Kingfisher', '4.7.0'                 # 图片下载缓存转码等
  pod 'RealmSwift', '3.0.1'                 # 本地数据库
  pod 'MJRefresh', '3.1.12'                 # 上下拉刷新
  pod 'PKHUD', '4.2.3'                      # 指示器
  pod 'CryptoSwift', '0.7.0'                # 加密
  pod 'TYAttributedLabel', :git => 'https://github.com/customized-repos/TYAttributedLabel.git'# 富文本Label（其实是个View）
  pod 'Hyphenate', '3.5.2'		            # 环信
  pod 'Masonry', '1.1.0'                 # 视图布局
  pod 'JPush', '3.0.3'                      # 极光推送
  pod 'Bugly', '2.4.8'                      # 崩溃收集
  pod 'GCDWebServer/WebUploader', '3.4.2'   # web上传功能
  pod 'Vivid'             # 图片处理
  pod 'SCRecorder', :git => 'https://github.com/customized-repos/SCRecorder' # 视频录制
  pod 'ZFPlayer', :git => 'https://github.com/customized-repos/ZFPlayer.git' #播放器
  pod 'TZImagePickerController', :git => 'https://github.com/customized-repos/TZImagePickerController.git' # 视频.图片选择框架
  pod 'MarkdownView', :git => 'https://github.com/customized-repos/MarkdownView.git'# markdown 渲染器基于 webview
  pod 'Alamofire', '4.7.3'
  pod 'ObjectMapper', '3.3.0'
  ### fork 的 activelabel 库，用于付费文字和超链接文字的显示
  pod 'ActiveLabel', :git => 'https://github.com/customized-repos/ActiveLabel.swift.git'
  ### '即时聊天相关
  pod 'Starscream', '2.0.2'                 # websocket 协议实现
  pod 'JSQMessagesViewController', :git => 'https://github.com/customized-repos/JSQMessagesViewController.git', :branch => '7.3.4'  # 消息UI
  pod 'IQKeyboardManagerSwift', '4.0.7'     # 自动调整视图 避免键盘遮挡
  pod 'AMap3DMap-NO-IDFA', '6.4.0'	 # 高德地图
  pod 'AMapLocation-NO-IDFA', '2.6.1'	# 高德定位
  pod 'AMapSearch-NO-IDFA', '6.1.1'	# 高德搜索
  pod 'objc-geohash', '0.0.1'               # GeoHash
  pod 'WechatOpenSDK', '1.8.2'
  pod 'mob_linksdk','2.2.6'

  target 'ThinkSNS +Tests' do            # 测试相关三方库
    inherit! :search_paths
    pod 'Nimble', '5.1.1'                   # 断言
    pod 'Mockingjay', '2.0.0'               # 网络请求模拟
    
  end

end

# Realm Need: If using Xcode 8, paste the following at the bottom of your Podfile, updating the Swift version if necessary:
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
