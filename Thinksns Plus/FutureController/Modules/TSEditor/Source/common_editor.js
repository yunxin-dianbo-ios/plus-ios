// 说明：
// 由于web输入中文的时候连字会导致设置字体样式之后不能取消，现在的方案是取消样式的时候在文本后边追加一个不可见的空格
// 该方案利弊如下：
// 是否自动删除断字的空格可以通过配置isAutoDeleteStyleSpace来设置，默认是方案二
// 方案一：
// 1、自动删除：
// 1.1 解决的bug：删除已经设置字体样式后的一个默认字体样式时，需要点击两次删除按钮（用户手动删除一次空格）
// 1.2 待处理的bug：
// 1.2.1 由于代码删除了输入的内容，会破坏编辑栈的内容，导致撤销操作会异常。
// 1.2.2 整个markdown的内容长度计算会把空格计算在内
// 方案二：
// 2、不自动删除：
// 2.1 解决的bug：因为自动移除断字的空格导致的撤销操作异常
// 2.2 待处理的bug：
// 2.2.1 删除已经设置字体样式后的一个默认字体样式时，需要点击两次删除按钮（用户手动删除一次空格
// 2.2.2 整个markdown的内容长度计算会把空格计算在内

function focusEditor(editor) {
    // 设置光标位于尾部
    editor.focus();
    var range = document.createRange();
    range.selectNodeContents(editor);
    range.collapse(false);
    var sel = window.getSelection();
    //判断光标位置，如不需要可删除
    if(sel.anchorOffset!=0){
        return;
    };
    sel.removeAllRanges();
    sel.addRange(range);
}

var webeditor = {};

// If we are using iOS or desktop
webeditor.isUsingiOS = true;

// If the user is draging
webeditor.isDragging = false;

// The current selection
webeditor.currentSelection;

// The current editing image
webeditor.currentEditingImage;

// The current editing link
webeditor.currentEditingLink;

// The objects that are enabled
webeditor.enabledItems = {};

// Height of content window, will be set by viewController
webeditor.contentHeight = 244;

// Sets to true when extra footer gap shows and requires to hide
webeditor.updateScrollOffset = false;

/**
 * The initializer function that must be called onLoad
 */
webeditor.init = function() {
    
    // 自定义
    webeditor.editor = document.getElementById("webeditor_content");
    webeditor.footer = document.getElementById("webeditor_footer");
    
    var editor = document.getElementById("webeditor_content");
    var isInsertStyleSpace = false;
    // 默认不删除
    var isAutoDeleteStyleSpace = false;

    // js回调iOS，建议使用JSContext，因使用URL可能会覆盖或冲突导致结果异常
    // click、focus、blur、touch、
    editor.addEventListener("click", function(){
        webeditor.contentClick();
    }, false);
    editor.addEventListener("focus", function(e){
        webeditor.contentFocus();
        //e.target.selection
    }, false);
    editor.addEventListener("blur", function(){
        webeditor.contentBlur();
    }, false);

    // change无效，暂时使用DOMSubtreeModified 或 input，
    // 但DOMSubtreeModified内不能使用calculateEditorHeightWithCaretPosition
//    editor.addEventListener("DOMSubtreeModified", function(){
//        window.location = 'contentchange://';
//       }, false);
    editor.addEventListener("input", function(){
        webeditor.contentInput();
        }, false);
    
    editor.addEventListener("keyup", function(event){
        webeditor.contentKeyUp(event);
        }, false);


    // 监听光标改变，editor添加selectionchange事件无效，只能使用document添加
   document.addEventListener("selectionchange", function(e){
          webeditor.debug("selectionchange1");
          // 注1：高度计算应在这里，而不是在contentInput里，否则初始聚焦时会发生移动异常。
          // 注2：暂不知道为啥计算正确
          webeditor.calculateEditorHeightWithCaretPosition();
         if (webeditor.editor.isAutoDeleteStyleSpace) {
             if (webeditor.editor.isInsertStyleSpace) {
                webeditor.editor.isInsertStyleSpace = false;
             } else {
                webeditor.deleteInputPositionZWNJ();
             }
        }

//          //webeditor.setScrollPosition();
          // 获取当前开启的样式状态，用于光标移动或获取焦点时
          webeditor.enabledEditingItems(e);
         }, false);

    // $(window).on('scroll', function(e) {
    //              webeditor.updateOffset();
    //              });

    // Make sure that when we tap anywhere in the document we focus on the editor
//    $(window).on('touchmove', function(e) {
//                 webeditor.isDragging = true;
//                 webeditor.updateScrollOffset = true;
//                 webeditor.setScrollPosition();
//                 webeditor.enabledEditingItems(e);
//                 });
//    $(window).on('touchstart', function(e) {
//                 webeditor.isDragging = false;
//                 });
//    $(window).on('touchend', function(e) {
//                 if (!webeditor.isDragging && (e.target.id == "webeditor_footer"||e.target.nodeName.toLowerCase() == "html")) {
//                 webeditor.focusEditor();
//                 }
//                 });
    
    

}//end


/***  JS回调iOS  ***/

// JSContext方式回调
// 注：enabledEditingItems内部调用了enableEditingTextStyleItems进行回调

// This will show up in the XCode console as we are able to push this into an NSLog.
webeditor.debug = function(msg) {
    //window.location = 'debug://'+msg;
    appDebug(msg);
}

// contentFocus
webeditor.contentFocus = function() {
    //window.location = 'contentfocus://';
    webeditor.debug('contentfocus');
    appContentFocus();
}

// contentBlur
webeditor.contentBlur = function() {
    //window.location = 'contentblur://';
    webeditor.debug('contentblur');
    appContentBlur();
}

// contentChange
webeditor.contentInput = function() {
    //window.location = 'contentchange://';
    webeditor.debug('contentchange1');
    appContentChange();
}

// imageClick
webeditor.imageClick = function(imageIndex) {
    //window.location = 'imageclick://' +  encodeURI(imageIndex);
    webeditor.debug('imageclick');
    appImageClick(imageIndex);
}

// imageDelete
webeditor.imageDelete = function(imageIndex) {
    webeditor.debug('imageDelete');
    appImageDelete(imageIndex);
}

//
webeditor.setScrollPosition = function() {
    var position = window.pageYOffset;
    // window.location = 'scroll://'+position;
    webeditor.debug('scroll: '+position);
    appScrollPosition(index);
}

// 当前可用的编辑样式选项
webeditor.enableEditingTextStyleItems = function(items) {
    if (items.length > 0) {
        webeditor.debug('enableEditingStyleItems: '+items.join(','));
        appEnableEditingStyleItems(items.join(','));
    } else {
        webeditor.debug('enableEditingStyleItems: null');
        appEnableEditingStyleItems("");
    }
}

/*** 按键处理 ***/

// 编辑器按键处理
webeditor.contentKeyUp = function(event) {
    // 8-Backspace键     13-Enter键
    if (event.which == 13) {
        // _self.getEditItem(evt);

        // 换行的默认处理：换行默认是添加<br />，但如果输入内容，则变成了<div></div>。
        // 因此，最后的markdown获取时，对标签的处理时需保留这种标签
        
    } else if (event.which == 8) {
        // _self.getEditItem(evt);

        // 删除图片的处理：图片整块的div设置为不可编辑的，使用删除键的时一次删除完毕。

    }
    if (event.which == 8 && webeditor.editor.isAutoDeleteStyleSpace) {
        webeditor.deleteInputPositionZWNJ();
        webeditor.enabledEditingItems();
    }
}

// 删除手动插入的断字符号
webeditor.deleteInputPositionZWNJ = function() {
    // 应该判断当前的光标的前一个字符是否为手动添加的断字符号，如果是就删除掉
    var caretOffset = webeditor.getCursortPosition(webeditor.editor);
    let markdownContent = webeditor.getContentNoMarkdown()
    var targetCharCode;
    if (caretOffset > 1) {
        targetCharCode = markdownContent.charCodeAt(caretOffset - 1);
    }
    if (targetCharCode == 8204) {
        webeditor.debug('找到了断字符号，已经删除');
        webeditor.debug(document.execCommand('delete', false, null));
    } else {
//        webeditor.debug('并没有');
    }
}
// 获取当前光标位置
webeditor.getCursortPosition = function(element){
    var caretOffset = 0;
    var doc = element.ownerDocument || element.document;
    var win = doc.defaultView || doc.parentWindow;
    var sel;
    if (typeof win.getSelection != "undefined") {//谷歌、火狐
        sel = win.getSelection();
        if (sel.rangeCount > 0) {//选中的区域
            var range = win.getSelection().getRangeAt(0);
            var preCaretRange = range.cloneRange();//克隆一个选中区域
            preCaretRange.selectNodeContents(element);//设置选中区域的节点内容为当前节点
            preCaretRange.setEnd(range.endContainer, range.endOffset);  //重置选中区域的结束位置
            caretOffset = preCaretRange.toString().length;
        }
    } else if ((sel = doc.selection) && sel.type != "Control") {//IE
        var textRange = sel.createRange();
        var preCaretTextRange = doc.body.createTextRange();
        preCaretTextRange.moveToElementText(element);
        preCaretTextRange.setEndPoint("EndToEnd", textRange);
        caretOffset = preCaretTextRange.text.length;
    }
    return caretOffset;
}
//webeditor.moveEnd = function(obj){
//    obj.focus();
//    var len = obj.value.length;
//    if (document.selection) {
//        var sel = obj.createTextRange();
//        sel.moveStart('character',len);
//        sel.collapse();
//        sel.select();
//    } else if (typeof obj.selectionStart == 'number' && typeof obj.selectionEnd == 'number') {
//        obj.selectionStart = obj.selectionEnd = len;
//    }
//}
/***  ***/

webeditor.updateOffset = function() {
    webeditor.debug('webeditor.updateOffset');
    
    if (!webeditor.updateScrollOffset)
        return;
    
    var offsetY = window.document.body.scrollTop;
    
    var footer = $('#webeditor_footer');
    
    var maxOffsetY = footer.offset().top - webeditor.contentHeight;
    
    if (maxOffsetY < 0)
        maxOffsetY = 0;
    
    if (offsetY > maxOffsetY)
    {
        window.scrollTo(0, maxOffsetY);
    }
    
    webeditor.setScrollPosition();
}

webeditor.getCaretYPosition = function() {
    var sel = window.getSelection();
    var range = sel.getRangeAt(0);
    var span = document.createElement('span');
    range.collapse(false);
    range.insertNode(span);
    // 处理输入普通文字然后首次设置字体无效的bug
    var topPosition = span.offsetTop;
    var spanParent = span.parentNode;
    span.parentNode.removeChild(span);
    spanParent.normalize();
    return topPosition;
}

webeditor.calculateEditorHeightWithCaretPosition = function() {

    var padding = 50;
    var c = webeditor.getCaretYPosition();

    var editor = $('#webeditor_content');

    var offsetY = window.document.body.scrollTop;
    var height = webeditor.contentHeight;

    var newPos = window.pageYOffset;

    if (c < offsetY) {
        newPos = c;
    } else if (c > (offsetY + height - padding)) {
        newPos = c - height + padding - 18;
    }

    window.scrollTo(0, newPos);
}

/***  ***/

webeditor.prepareInsert = function() {
    webeditor.backuprange();
}

webeditor.backuprange = function(){
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    webeditor.currentSelection = {"startContainer": range.startContainer, "startOffset":range.startOffset,"endContainer":range.endContainer, "endOffset":range.endOffset};
}

webeditor.restorerange = function(){
    var selection = window.getSelection();
    selection.removeAllRanges();
    var range = document.createRange();
    range.setStart(webeditor.currentSelection.startContainer, webeditor.currentSelection.startOffset);
    range.setEnd(webeditor.currentSelection.endContainer, webeditor.currentSelection.endOffset);
    selection.addRange(range);
}

webeditor.getSelectedNode = function() {
    var node,selection;
    if (window.getSelection) {
        selection = getSelection();
        node = selection.anchorNode;
    }
    if (!node && document.selection) {
        selection = document.selection
        var range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
        node = range.commonAncestorContainer ? range.commonAncestorContainer :
        range.parentElement ? range.parentElement() : range.item(0);
    }
    if (node) {
        return (node.nodeName == "#text" ? node.parentNode : node);
    }
};

/*** Editor ***/
webeditor.setBold = function() {
    webeditor.deleteInputPositionZWNJ();
    if (document.queryCommandState('bold') == true) {
        document.execCommand('bold', false, null);
        var strikeThrough = false
        // 记录一下是否设置了其他属性
        if (document.queryCommandState('strikeThrough') == true) {
           strikeThrough = true
        }
        var italic = false
        if (document.queryCommandState('italic') == true) {
            italic = true
        }
        webeditor.editor.isInsertStyleSpace = true;
        document.execCommand('insertHTML', false, '&zwnj;');
        if (strikeThrough == true) {
            document.execCommand('strikeThrough', false, null);
        }
        if (italic == true) {
            document.execCommand('italic', false, null);
        }
    } else {
        document.execCommand('bold', false, null);
    }
    webeditor.enabledEditingItems();
}

webeditor.setItalic = function() {
    webeditor.deleteInputPositionZWNJ();
    if (document.queryCommandState('italic')) {
        webeditor.debug(document.execCommand('italic', false, null));
        var bold = false
        // 记录一下是否设置了其他属性
        if (document.queryCommandState('bold') == true) {
            bold = true
        }
        var strikeThrough = false
        if (document.queryCommandState('strikeThrough') == true) {
            strikeThrough = true
        }
        webeditor.editor.isInsertStyleSpace = true;
        document.execCommand('insertHTML', false, '&zwnj;');
        if (bold == true) {
            document.execCommand('bold', false, null);
        }
        if (strikeThrough == true) {
            document.execCommand('strikeThrough', false, null);
        }
    } else {
        document.execCommand('italic', false, null);
    }
}

webeditor.setSubscript = function() {
    document.execCommand('subscript', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setSuperscript = function() {
    document.execCommand('superscript', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setStrikeThrough = function() {
    webeditor.deleteInputPositionZWNJ();
    if (document.queryCommandState('strikeThrough')) {
        webeditor.debug(document.execCommand('strikeThrough', false, null));
        var bold = false
        // 记录一下是否设置了其他属性
        if (document.queryCommandState('bold') == true) {
            bold = true
        }
        var italic = false
        if (document.queryCommandState('italic') == true) {
            italic = true
        }
        webeditor.editor.isInsertStyleSpace = true;
        document.execCommand('insertHTML', false, '&zwnj;');
        if (bold == true) {
            document.execCommand('bold', false, null);
        }
        if (italic == true) {
            document.execCommand('italic', false, null);
        }
    } else {
        document.execCommand('strikeThrough', false, null);
    }
    webeditor.enabledEditingItems();
}

webeditor.setUnderline = function() {
    document.execCommand('underline', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setBlockquote = function() {
    document.execCommand('formatBlock', false, '<blockquote>');
    webeditor.enabledEditingItems();
}

webeditor.removeFormating = function() {
    document.execCommand('removeFormat', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setHorizontalRule = function() {
    document.execCommand('insertHorizontalRule', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setHeading = function(heading) {
    var current_selection = $(webeditor.getSelectedNode());
    var t = current_selection.prop("tagName").toLowerCase();
    var is_heading = (t == 'h1' || t == 'h2' || t == 'h3' || t == 'h4' || t == 'h5' || t == 'h6');
    if (is_heading && heading == t) {
        var c = current_selection.html();
        current_selection.replaceWith(c);
    } else {
        document.execCommand('formatBlock', false, '<'+heading+'>');
    }

    webeditor.enabledEditingItems();
}

webeditor.setParagraph = function() {
    var current_selection = $(webeditor.getSelectedNode());
    var t = current_selection.prop("tagName").toLowerCase();
    var is_paragraph = (t == 'p');
    if (is_paragraph) {
        var c = current_selection.html();
        current_selection.replaceWith(c);
    } else {
        document.execCommand('formatBlock', false, '<p>');
    }

    webeditor.enabledEditingItems();
}

webeditor.undo = function() {
    document.execCommand('undo', false, null);
    webeditor.enabledEditingItems();
}

webeditor.redo = function() {
    document.execCommand('redo', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setOrderedList = function() {
    document.execCommand('insertOrderedList', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setUnorderedList = function() {
    document.execCommand('insertUnorderedList', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setJustifyCenter = function() {
    document.execCommand('justifyCenter', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setJustifyFull = function() {
    document.execCommand('justifyFull', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setJustifyLeft = function() {
    document.execCommand('justifyLeft', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setJustifyRight = function() {
    document.execCommand('justifyRight', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setIndent = function() {
    document.execCommand('indent', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setOutdent = function() {
    document.execCommand('outdent', false, null);
    webeditor.enabledEditingItems();
}

webeditor.setFontFamily = function(fontFamily) {

    webeditor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand("fontName", false, fontFamily);
    document.execCommand("styleWithCSS", null, false);
    webeditor.enabledEditingItems();

}

webeditor.setTextColor = function(color) {

    webeditor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('foreColor', false, color);
    document.execCommand("styleWithCSS", null, false);
    webeditor.enabledEditingItems();
    // document.execCommand("removeFormat", false, "foreColor"); // Removes just foreColor

}

webeditor.setBackgroundColor = function(color) {
    webeditor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('hiliteColor', false, color);
    document.execCommand("styleWithCSS", null, false);
    webeditor.enabledEditingItems();
}

// 引用样式的移除，使用p标签或div标签
webeditor.removeBlockquote = function() {
    //    let Range = document.getSelection().getRangeAt(0),
    //    formatName = Range.commonAncestorContainer.parentElement.nodeName === 'BLOCKQUOTE' ? 'P' : 'BLOCKQUOTE';
    //    document.execCommand('formatBlock', false, formatName)
    //    webeditor.enabledEditingItems();
    
    // 上面的方式在某些情况下会出现异常，特别是有删除线时
    // 引用样式移除，注setBlockquote不可使用setIndent，否则会不断的缩进下去
    webeditor.setOutdent();
}

/*** Link ***/

// Needs addClass method

webeditor.insertLink = function(url, title) {
    webeditor.debug("webeditor.insertLink");
    webeditor.restorerange();
    var sel = document.getSelection();
    console.log(sel);
    if (sel.toString().length != 0) {
        if (sel.rangeCount) {

            var el = document.createElement("a");
            el.setAttribute("href", url);
            el.setAttribute("title", title);

            var range = sel.getRangeAt(0).cloneRange();
            range.surroundContents(el);
            sel.removeAllRanges();
            sel.addRange(range);
        }
    }
    else
    {
        // url校验，scheme + 服务器，不符合该格式则添加"zhiyi"格式的scheme
        if (!url.match("^http://[\\s\\S]+")) {
            url = "zhiyi:" + url
        }
        document.execCommand("insertHTML",false,"<a href='"+url+"'>"+title+"</a>");
    }
    
//    webeditor.enabledEditingItems();
    
}

webeditor.updateLink = function(url, title) {

    webeditor.restorerange();

    if (webeditor.currentEditingLink) {
        var c = webeditor.currentEditingLink;
        c.attr('href', url);
        c.attr('title', title);
    }
    webeditor.enabledEditingItems();

}//end

webeditor.unlink = function() {
    
    if (webeditor.currentEditingLink) {
        var c = webeditor.currentEditingLink;
        c.contents().unwrap();
    }
    webeditor.enabledEditingItems();
}

webeditor.quickLink = function() {
    
    var sel = document.getSelection();
    var link_url = "";
    var test = new String(sel);
    var mailregexp = new RegExp("^(.+)(\@)(.+)$", "gi");
    if (test.search(mailregexp) == -1) {
        checkhttplink = new RegExp("^http\:\/\/", "gi");
        if (test.search(checkhttplink) == -1) {
            checkanchorlink = new RegExp("^\#", "gi");
            if (test.search(checkanchorlink) == -1) {
                link_url = "http://" + sel;
            } else {
                link_url = sel;
            }
        } else {
            link_url = sel;
        }
    } else {
        checkmaillink = new RegExp("^mailto\:", "gi");
        if (test.search(checkmaillink) == -1) {
            link_url = "mailto:" + sel;
        } else {
            link_url = sel;
        }
    }
    
    var html_code = '<a href="' + link_url + '">' + sel + '</a>';
    webeditor.insertHTML(html_code);
    
}

/*** Image ***/

webeditor.insertImage = function(url, alt) {
    webeditor.restorerange();
    var html = '<img src="'+url+'" alt="'+alt+'" />';
    webeditor.insertHTML(html);
    webeditor.enabledEditingItems();
}

webeditor.updateImage = function(url, alt) {

    webeditor.restorerange();

    if (webeditor.currentEditingImage) {
        var c = webeditor.currentEditingImage;
        c.attr('src', url);
        c.attr('alt', alt);
    }
    webeditor.enabledEditingItems();

}//end

webeditor.insertImageUrl = function(url, imageIndex, alt, width, height) {
    webeditor.restorerange();

    var html = '<br /><div><div class="image" id="image' + imageIndex + '">';
    html += '<img class="myimg" src="' + url + '" alt="' + alt + '" width="' + width + '" height="' + height + '" />';
    // 图片后追加换行
//    html += '<br />';
    // 图片后输入框，用于输入图片名字描述
//    html += '<input type="text" name="picname" placeholder="请输入图片名字" />';
    // cover + markdown + progress + failure
    //html += '<div class="failure"><div class="tips">图片上传失败，请重新上传</div></div>';
    html += '<div class="failure"></div>';
    html += '<div class="markdown"></div>';
    html += '</div></div><br />';
    webeditor.insertHTML(html);
    webeditor.enabledEditingItems();
    
    // 添加点击事件
    var imagenode = document.getElementById('image' + imageIndex);
    // imagenode必须在外面再套一层，否则删除时直接崩溃
    imagenode.contentEditable = false;
    imagenode.addEventListener('click', function (e) {
        e.stopPropagation();
        // imageIndex 建议从e.currentTarget中获取比较合适
        webeditor.imageClick(imageIndex);
    }, false);
    
    // 添加节点事件，用于处理图片通过delete删除时的响应回调
    imagenode.addEventListener('DOMNodeRemovedFromDocument', function(e){
        e.stopPropagation();
        // 图片被删除的回调
        webeditor.imageDelete(imageIndex);
        // imageIndex 建议从e.currentTarget中获取比较合适
        // var target = e.currentTarget;
        // var imgDiv = target.querySelector('.image');
        // var id = imgDiv.getAttribute('id'); // "imagexxx" 格式
        // id = id.replace(/image/g, '');
        //webeditor.imageDelete(id);
    }, false);
    
}

//webeditor.insertImageBase64String = function(imageBase64String, alt) {
//    webeditor.restorerange();
//    var html = '<img src="data:image/jpeg;base64,'+imageBase64String+'" alt="'+alt+'" />';
//    webeditor.insertHTML(html);
//    webeditor.enabledEditingItems();
//}

// 判断该图片是否存在
webeditor.isExistImage = function(imageIndex) {
    var divImg = document.getElementById('image'+imageIndex)
    return divImg != null ? "1" : "0";
}

webeditor.insertImageBase64String = function(imageBase64String, imageIndex, alt, width, height) {
    webeditor.restorerange();

    var html = '<br /><div><div class="image" id="image' + imageIndex + '">';
    html += '<img class="myimg" src="data:image/jpeg;base64,' + imageBase64String + '" alt="' + alt + '" width="' + width + '" height="' + height + '" />';
    // 图片后追加换行
//    html += '<br />';
    // 图片后输入框，用于输入图片名字描述
//    html += '<input type="text" name="picname" placeholder="请输入图片名字" />';
    // cover + markdown + progress + failure
    //html += '<div class="failure"><div class="tips">图片上传失败，请重新上传</div></div>';
    html += '<div class="failure"></div>';
    html += '<div class="markdown"></div>';
    html += '</div></div><br />';
    webeditor.insertHTML(html);
    webeditor.enabledEditingItems();
    
    // 添加点击事件
    var imagenode = document.getElementById('image' + imageIndex);
    // imagenode必须在外面再套一层，否则删除时直接崩溃
    imagenode.contentEditable = false;
    imagenode.addEventListener('click', function (e) {
        e.stopPropagation();
        webeditor.imageClick(imageIndex);
    }, false);

    // 添加节点事件，用于处理图片通过delete删除时的响应回调
    imagenode.parentNode.addEventListener('DOMNodeRemovedFromDocument', function(e){
        e.stopPropagation();
        // 图片被删除的回调
        var target = e.currentTarget;
        // imageIndex 建议从e.currentTarget中获取比较合适
        webeditor.imageDelete(imageIndex);
    }, false);
    

    //    func htmlForJPGImage(_ image: UIImage) -> String {
    //        guard let imgData = UIImageJPEGRepresentation(image, 1.0) else {
    //            return ""
    //        }
    //        let imageSource = String(format: "data:image/jpg;base64,%@", imgData.base64EncodedString())
    //        let imageHtml = String(format: "<br /><img src = \"%@\" /><br/>", imageSource)
    //        return imageHtml
    //    }


    /**
     var image = '
     <div>
     <br>
     </div>
     <div class="block">
     \n\t\t\t\t
     <div class="img-block">
     <div style="width: ' + newWidth + 'px" class="process">
     \n\t\t\t\t\t
     <div class="fill">
     \n\t\t\t\t\t
     </div>
     \n\t\t\t\t
     </div>
     \n\t\t\t\t
     <img class="images" data-id="' + id + '" style="width: ' + newWidth + 'px; height: ' + newHeight + 'px;" src="' + url + '"/>
     \n\t\t\t\t
     <div class="cover" style="width: ' + newWidth + 'px; height: ' + newHeight + 'px">
     </div>
     \n\t\t\t\t
     <div class="delete">
     \n\t\t\t\t\t
     <img class="error" src="./reload.png">
     \n\t\t\t\t\t
     <div class="tips">
     \u56FE\u7247\u4E0A\u4F20\u5931\u8D25\uFF0C\u8BF7\u70B9\u51FB\u91CD\u8BD5
     </div>
     \n\t\t\t\t\t
     <div class="markdown">
     </div>
     \n\t\t\t\t
     </div>
     </div>
     \n\t\t\t\t
     <input class="dec" type="text" placeholder="\u8BF7\u8F93\u5165\u56FE\u7247\u540D\u5B57">
     \n\t\t\t
     </div>
     <div>
     <br>
     </div>';
     //    _self.insertHtml(image);
     **/

}

webeditor.updateImageBase64String = function(imageBase64String, alt) {

    webeditor.restorerange();

    if (webeditor.currentEditingImage) {
        var c = webeditor.currentEditingImage;
        var src = 'data:image/jpeg;base64,' + imageBase64String;
        c.attr('src', src);
        c.attr('alt', alt);
    }
    webeditor.enabledEditingItems();

}//end

webeditor.removeImage = function(id) {
    var divImg = document.getElementById('image'+id);
    divImg.parentNode.removeChild(divImg);
}

webeditor.reloadImage = function(id) {
    
}

webeditor.uploadImageSuccess = function(id, fileId) {
    var divImg = document.getElementById('image'+id);
    var markdown = divImg.querySelector('.markdown');
    markdown.innerHTML = "@![image]("+fileId+")<br />"; // 图片后增加换行。插入图片后的换行容易被文字代替
    webeditor.debug(markdown.innerHTML);
}

webeditor.uploadImageFailure = function(id) {
    var divImg = document.getElementById('image'+id);
    var failure = divImg.querySelector('.failure');
    failure.style.display = 'block';
    // 上传失败，则移除该图片
    //webeditor.removeImage(id)
}

// 加载完成后的图片处理
// 处理图片：1. 图片的markdown的div内容补充；2. 图片的响应事件添加
webeditor.loadedImageProcess = function(id, fileId) {
    var imageIndex = "image"+id;
    var imagenode = document.getElementById('image'+id);
    if (imagenode == null) {
        return;
    }
    // 添加点击事件
    // imagenode必须在外面再套一层，否则删除时直接崩溃
    imagenode.contentEditable = false;
    imagenode.addEventListener('click', function (e) {
        e.stopPropagation();
        // imageIndex 建议从e.currentTarget中获取比较合适
        webeditor.imageClick(imageIndex);
    }, false);

    // 添加节点事件，用于处理图片通过delete删除时的响应回调
    imagenode.addEventListener('DOMNodeRemovedFromDocument', function(e){
        e.stopPropagation();
        // 图片被删除的回调
        webeditor.imageDelete(imageIndex);
        // imageIndex 建议从e.currentTarget中获取比较合适
        // var target = e.currentTarget;
        // var imgDiv = target.querySelector('.image');
        // var id = imgDiv.getAttribute('id'); // "imagexxx" 格式
        // id = id.replace(/image/g, '');
        //webeditor.imageDelete(id);
    }, false);

    // markdownDiv 添加内容
    var markdownDiv = imagenode.querySelector('.markdown');
    markdownDiv.innerHTML = "@![image]("+fileId+")<br />";
}

/*** ItemEnabled ***/
// 注：当前光标位置处开启的编辑元素需使用jquery，否则查询不到

webeditor.isCommandEnabled = function(commandName) {
    return document.queryCommandState(commandName);
}

webeditor.enabledEditingItems = function(e) {
    
    console.log('enabledEditingItems');
    var items = [];
    if (webeditor.isCommandEnabled('bold')) {
        items.push('bold');
    }
    if (webeditor.isCommandEnabled('italic')) {
        items.push('italic');
    }
    if (webeditor.isCommandEnabled('subscript')) {
        items.push('subscript');
    }
    if (webeditor.isCommandEnabled('superscript')) {
        items.push('superscript');
    }
    if (webeditor.isCommandEnabled('strikeThrough')) {
        items.push('strikeThrough');
    }
    if (webeditor.isCommandEnabled('underline')) {
        items.push('underline');
    }
    if (webeditor.isCommandEnabled('insertOrderedList')) {
        items.push('orderedList');
    }
    if (webeditor.isCommandEnabled('insertUnorderedList')) {
        items.push('unorderedList');
    }
    if (webeditor.isCommandEnabled('justifyCenter')) {
        items.push('justifyCenter');
    }
    if (webeditor.isCommandEnabled('justifyFull')) {
        items.push('justifyFull');
    }
    if (webeditor.isCommandEnabled('justifyLeft')) {
        items.push('justifyLeft');
    }
    if (webeditor.isCommandEnabled('justifyRight')) {
        items.push('justifyRight');
    }
    if (webeditor.isCommandEnabled('insertHorizontalRule')) {
        items.push('horizontalRule');
    }
    var formatBlock = document.queryCommandValue('formatBlock');
    if (formatBlock.length > 0) {
        items.push(formatBlock);
    }
    // Images
    $('img').bind('touchstart', function(e) {
                  $('img').removeClass('zs_active');
                  $(this).addClass('zs_active');
                  });
    
    // Use jQuery to figure out those that are not supported
    if (typeof(e) != "undefined") {
        
        // The target element
        var s = webeditor.getSelectedNode();
        var t = $(s);
        var nodeName = e.target.nodeName.toLowerCase();
        
        // Background Color
        var bgColor = t.css('backgroundColor');
        if (bgColor.length != 0 && bgColor != 'rgba(0, 0, 0, 0)' && bgColor != 'rgb(0, 0, 0)' && bgColor != 'transparent') {
            items.push('backgroundColor');
        }
        // Text Color
        var textColor = t.css('color');
        if (textColor.length != 0 && textColor != 'rgba(0, 0, 0, 0)' && textColor != 'rgb(0, 0, 0)' && textColor != 'transparent') {
            items.push('textColor');
        }
        
        //Fonts
        var font = t.css('font-family');
        if (font.length != 0 && font != 'Arial, Helvetica, sans-serif') {
            items.push('fonts');
        }
        
        // Link
        if (nodeName == 'a') {
            webeditor.currentEditingLink = t;
            var title = t.attr('title');
            items.push('link:'+t.attr('href'));
            if (t.attr('title') !== undefined) {
                items.push('link-title:'+t.attr('title'));
            }
            
        } else {
            webeditor.currentEditingLink = null;
        }
        // Blockquote
        if (nodeName == 'blockquote') {
            items.push('indent');
        }
        // Image
        if (nodeName == 'img') {
            webeditor.currentEditingImage = t;
            items.push('image:'+t.attr('src'));
            if (t.attr('alt') !== undefined) {
                items.push('image-alt:'+t.attr('alt'));
            }
            
        } else {
            webeditor.currentEditingImage = null;
        }
        
    }
    
    // if (items.length > 0) {
    //     if (webeditor.isUsingiOS) {
    //         //window.location = "zss-callback/"+items.join(',');
    //         window.location = "callback://0/"+items.join(',');
    //     } else {
    //         console.log("callback://"+items.join(','));
    //     }
    // } else {
    //     if (webeditor.isUsingiOS) {
    //         window.location = "zss-callback/";
    //     } else {
    //         console.log("callback://");
    //     }
    // }
    // 回调修正
    webeditor.enableEditingTextStyleItems(items);
    
}

/*** HTML ***/

webeditor.setHTML = function(html) {
    var editor = $('#webeditor_content');
    editor.html(html);
}

webeditor.insertHTML = function(html) {
    document.execCommand('insertHTML', false, html);
    webeditor.enabledEditingItems();
}

webeditor.getHTML = function() {
    
    var html = webeditor.editor.innerHTML;
    return html;

    // // Images
    // var img = $('img');
    // if (img.length != 0) {
    //     $('img').removeClass('zs_active');
    //     $('img').each(function(index, e) {
    //                   var image = $(this);
    //                   var zs_class = image.attr('class');
    //                   if (typeof(zs_class) != "undefined") {
    //                   if (zs_class == '') {
    //                   image.removeAttr('class');
    //                   }
    //                   }
    //                   });
    // }
    
    // // Blockquote
    // var bq = $('blockquote');
    // if (bq.length != 0) {
    //     bq.each(function() {
    //             var b = $(this);
    //             if (b.css('border').indexOf('none') != -1) {
    //             b.css({'border': ''});
    //             }
    //             if (b.css('padding').indexOf('0px') != -1) {
    //             b.css({'padding': ''});
    //             }
    //             });
    // }
    
    // // Get the contents
    // var h = document.getElementById("webeditor_content").innerHTML;
    
    // return h;
}

/*** CSS ***/

webeditor.setCustomCSS = function(customCSS) {
    
    document.getElementsByTagName('style')[0].innerHTML=customCSS;
    
    //set focus
    /*editor.focusout(function(){
     var element = $(this);
     if (!element.text().trim().length) {
     element.empty();
     }
     });*/
    
    
    
}

/*** Footer ***/

// footerHeight
webeditor.setFooterHeight = function(footerHeight) {
    var footer = $('#webeditor_footer');
    footer.height(footerHeight + 'px');
}

/*** FOCUS & BLUR ***/

webeditor.focusEditor = function() {
    
    // the following was taken from http://stackoverflow.com/questions/1125292/how-to-move-cursor-to-end-of-contenteditable-entity/3866442#3866442
    // and ensures we move the cursor to the end of the editor
    var editor = $('#webeditor_content');
    var range = document.createRange();
    range.selectNodeContents(editor.get(0));
    range.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    editor.focus();
}

webeditor.blurEditor = function() {
    $('#webeditor_content').blur();
}

// 插入链接后的聚焦
webeditor.focusAfterInsertLink = function() {
    
}
// 插入图片后的聚焦
webeditor.focusAfterInsertImage = function() {
    
}
// 取消插入后的聚焦
webeditor.focusAfterCancelInsert = function() {
    
}

/*** Content ***/

// ContentPlaceholder
webeditor.setPlaceholder = function(placeholder) {
    
    var editor = $('#webeditor_content');
    
    //set placeHolder
    editor.attr("placeholder",placeholder);
    
    //set focus
    editor.focusout(function(){
                    var element = $(this);
                    if (!element.text().trim().length) {
                    element.empty();
                    }
                    });

}

// 正文输入框最小高度，主要用于界面点击响应键盘区域，注意若设置main的最小高度，暂时无效，可能需要进行别的设置
webeditor.setContentMinHeight = function(minHeight) {
    //var titleH = webeditor.titleEditor.offsetHeight + 30 + 1; // padding + lineH
    //webeditor.debug('titleH: ' + titleH);
    webeditor.editor.style.minHeight = minHeight + 'px';
}

// 获取内容的文字，不含标签
webeditor.getContentText = function() {
    return $('#webeditor_content').text();
}

// 获取内容的markdown格式
webeditor.getContentMarkdown = function() {
    // 注意懒惰匹配
    //var markdown = webeditor.getHTML().replace(/<div>|<\/div>|<[divimginput]+ class=".*">/g, '').replace(/\n|\t/g,'').trim();
//    var markdown = webeditor.getHTML().replace(/<div>|<\/div>|<[divimg]+ class=".*?">/g, '').replace(/\n|\t/g,'').trim();
    // .replace(/<\/div>|<div>[u4e00-u9fa5]+<\/div>/g,"").trim();
    // 保留无class的div，以保证换行
    //var markdown = webeditor.getHTML().replace(/<div\\s+\\S+>\\s+\\S+<\/div>|<[divimginput]+ class=".*?">/g, '').replace(/\n|\t/g,'').trim();
    // 替换div为p标签，问答模块中后台会修改markdown数据的div标签导致展示异常
    // .replace(/<div\\s+\\S+>\\s+\\S+<\/div>|<[divimginput]+ class=".*">|\u56FE\u7247\u4E0A\u4F20\u5931\u8D25\uFF0C\u8BF7\u70B9\u51FB\u91CD\u8BD5/g, '').replace(/\n|\t/g,'').replace(/<div>[u4e00-u9fa5]+<\/div>/g,"").replace(/div|span/g,'p').trim();
    var markdown = webeditor.getHTML().replace(/<div\\s+\\S+>\\s+\\S+<\/div>|<[divimginput]+ class=".*?">/g, '').replace(/\n|\t/g,'').replace(/div|span/g, 'p').trim();
    
    // <br> -> <br />, <hr> -> <hr />
    markdown = markdown.replace(/<br>/g, '<br />').replace(/<hr>/g, '<hr />');
    
    return markdown;
}

// 获取内容的无markdown格式，取消所有标签
webeditor.getContentNoMarkdown = function(content) {
    var content = webeditor.getHTML().replace(/<div class=".*">.*<\/div>|<\/?[^>]*>/g, '').replace(/\s+/, '').trim();
    return content;
}

// 设置内容
webeditor.setContentWithMarkdown = function(markdown) {
    if (null != markdown) {
        webeditor.debug('set markdown content start: \n' + markdown + '\n');
        
        webeditor.editor.innerHTML = markdown;

        // 似乎没有range
        //webeditor.insertHTML(html);
        
//        var editor = document.getElementById("webeditor_content");
//        editor.innerHTML = markdown;
    }
}

