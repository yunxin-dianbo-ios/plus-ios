//
//  TSURLExtension.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/01/2018.
//  Copyright © 2018 ZhiYiCX. All rights reserved.
//

import Foundation
import Regex

extension URL {

    func ts_serverLinkUrlProcess() -> URL {
        let strUrl = self.absoluteString
        let newStrUrl = strUrl.ts_serverLinkProcess()
        if let newUrl = URL(string: newStrUrl) {
            return newUrl
        }
        return self
    }

}
