//
//  TWRichTextToolBarButton.swift
//  TSRichTextEditor-Swift
//
//  Created by 小唐 on 04/12/2017.
//  Copyright © 2017 Tightwad. All rights reserved.
//

import UIKit

enum TWRichTextStyle: String {
    case none
    case link
    case hr
    case undo
    case redo
    case image
    case bold
    case italic
    case strikethrough
    case underline
    case blockquote
    case h1
    case h2
    case h3
    case h4
}

class TWRichTextButton: UIButton {

    var textStyle: TWRichTextStyle

    init(textStyle: TWRichTextStyle) {
        self.textStyle = textStyle
        // 注：是混编时有这个问题，还是单纯的Swift有这个问题。
        //super.init(type: .custom)
        super.init(frame: CGRect.zero)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
