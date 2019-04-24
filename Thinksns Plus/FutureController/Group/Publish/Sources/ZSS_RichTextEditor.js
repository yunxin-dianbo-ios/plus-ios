/*!
 *
 * ZSSRichTextEditor v0.5.2
 * http://www.zedsaid.com
 *
 * Copyright 2014 Zed Said Studio LLC
 *
 */

var titleMaxLimit = 20;

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

var zss_editor = {};

// If we are using iOS or desktop
zss_editor.isUsingiOS = true;

// If the user is draging
zss_editor.isDragging = false;

// The current selection
zss_editor.currentSelection;

// The current editing image
zss_editor.currentEditingImage;

// The current editing link
zss_editor.currentEditingLink;

// The objects that are enabled
zss_editor.enabledItems = {};

// Height of content window, will be set by viewController
zss_editor.contentHeight = 244;

// Sets to true when extra footer gap shows and requires to hide
zss_editor.updateScrollOffset = false;

/**
 * The initializer function that must be called onLoad
 */
zss_editor.init = function() {

    // 自定义
    zss_editor.titleEditor = document.getElementById("zss_editor_title");
    zss_editor.titleCurrentLen = document.getElementById("title_currentlen");
    zss_editor.titleLenCounter = document.getElementById("title_counter");
    zss_editor.editor = document.getElementById("zss_editor_content");
    
    var title = document.getElementById("zss_editor_title");
    var editor = document.getElementById("zss_editor_content");
//    editor.style.minHeight = window.innerHeight - 69 + 'px';

    // js回调iOS，建议使用JSContext，因使用URL可能会覆盖或冲突导致结果异常
    title.addEventListener("click", function(){
        zss_editor.titleClick();
        }, false);
    title.addEventListener("focus", function(){
        zss_editor.titleFocus();                 
        }, false);
    title.addEventListener("input", function(e){
        zss_editor.titleInput();
        // 字数限制，也使用input监听处理，而不是使用keyup，否则会在最大字数输入时发生闪烁。
        }, false);
   title.addEventListener("keydown", function(event){
                              // 要阻止换行，监听keydown
                              zss_editor.titleKeyDown(event);
                          }, false);


    // click、focus、blur、touch、
    editor.addEventListener("click", function(){
        zss_editor.contentClick();
        }, false);
    editor.addEventListener("focus", function(e){
        zss_editor.contentFocus();
        //e.target.selection
        }, false);
    editor.addEventListener("blur", function(){
        zss_editor.contentBlur();
        }, false);
    editor.addEventListener("touchend", function(e){
        zss_editor.contentTouchEnd();
        //e.target.selection
    }, false);

    // change无效，暂时使用DOMSubtreeModified 或 input，
    // 但DOMSubtreeModified内不能使用calculateEditorHeightWithCaretPosition
//    editor.addEventListener("DOMSubtreeModified", function(){
//        window.location = 'contentchange://';
//       }, false);
    editor.addEventListener("input", function(){
        zss_editor.contentInput();
        }, false);
    
    editor.addEventListener("keyup", function(event){
        zss_editor.contentKeyUp(event);
        }, false);


    // 监听光标改变，editor添加selectionchange事件无效，只能使用document添加
   document.addEventListener("selectionchange", function(e){
          zss_editor.debug("selectionchange");
          // 注1：高度计算应在这里，而不是在contentInput里，否则初始聚焦时会发生移动异常。
          // 注2：暂不知道为啥计算正确
          zss_editor.calculateEditorHeightWithCaretPosition();
          //zss_editor.setScrollPosition();
          // 获取当前开启的样式状态，用于光标移动或获取焦点时
          zss_editor.enabledEditingItems(e);
         }, false);

    // $(window).on('scroll', function(e) {
    //              zss_editor.updateOffset();
    //              });

    // Make sure that when we tap anywhere in the document we focus on the editor
//    $(window).on('touchmove', function(e) {
//                 zss_editor.isDragging = true;
//                 zss_editor.updateScrollOffset = true;
//                 zss_editor.setScrollPosition();
//                 zss_editor.enabledEditingItems(e);
//                 });
//    $(window).on('touchstart', function(e) {
//                 zss_editor.isDragging = false;
//                 });
//    $(window).on('touchend', function(e) {
//                 if (!zss_editor.isDragging && (e.target.id == "zss_editor_footer"||e.target.nodeName.toLowerCase() == "html")) {
//                 zss_editor.focusEditor();
//                 }
//                 });

}//end


/***  JS回调iOS  ***/

// JSContext方式回调
// 注：enabledEditingItems内部调用了enableEditingTextStyleItems进行回调

// This will show up in the XCode console as we are able to push this into an NSLog.
zss_editor.debug = function(msg) {
    //window.location = 'debug://'+msg;
    appDebug(msg);
}

// titleClick
zss_editor.titleClick = function() {
    //window.location = 'titleclick://';
    zss_editor.debug('titleclick');
    
    // 回调focus即可
    //appTitleClick();
}

// contentClick
zss_editor.contentClick = function() {
    //window.location = 'contentclick://';
    zss_editor.debug('contentclick');

    // 回调focus即可
    //appContentClick();
}

// titleFocus
zss_editor.titleFocus = function() {
    //window.location = 'titlefocus://';
    zss_editor.debug('titlefocus');
    appTitleFocus();
}

// contentFocus
zss_editor.contentFocus = function() {
    //window.location = 'contentfocus://';
    zss_editor.debug('contentfocus');
    appContentFocus();
}

// contentBlur
zss_editor.contentBlur = function() {
    //window.location = 'contentblur://';
    zss_editor.debug('contentblur');
    appContentBlur();
}

// contentTouchEnd
zss_editor.contentTouchEnd = function() {
    //window.location = 'contenttouchend://';
    zss_editor.debug('contenttouchend');

    // 使用focus回调即可
    // appContentTouchEnd();
}

// titleChange
zss_editor.titleInput = function() {
    //window.location = 'titlechange://';
    zss_editor.debug('titlechange');
    appTitleChange();

    // 计数器处理
    var text = zss_editor.titleEditor.innerText;
    var html = zss_editor.titleEditor.innerHTML
    
    if (text.length == 1 && (html == '<br>' || html == '<br/>' || html == '<br />')) {
        // 删除掉最后一个文字时，会产生一个<br>标签，此时text.length==1，但text打印为空，且导致标题占位文字异常
        zss_editor.debug('text.length == 1 && text == <br>');
        zss_editor.titleEditor.innerHTML = '';
        rturn
    }    
    if (text.length < 10) {
        zss_editor.titleLenCounter.style.display = "none";
        return
    }
    if (text.length >= 10) {
        zss_editor.titleLenCounter.style.display = "block";
        zss_editor.titleLenCounter.style.color = "green";
    }
    if (text.length > 15) {
        zss_editor.titleLenCounter.style.color = "red";
    }
    // 字数限制：使用keyup监听处理会有闪烁
    if (text.length > titleMaxLimit) {
        zss_editor.titleEditor.innerHTML = text.substring(0, titleMaxLimit);
        // 重新尾部聚焦，否则聚焦到头部
        focusEditor(zss_editor.titleEditor);
    }
    // 计数器更新
    zss_editor.titleCurrentLen.innerText = zss_editor.titleEditor.innerText.length;
}

// contentChange
zss_editor.contentInput = function() {
    //window.location = 'contentchange://';
    zss_editor.debug('contentchange');
    appContentChange();
}

// imageClick
zss_editor.imageClick = function(imageIndex) {
    //window.location = 'imageclick://' +  encodeURI(imageIndex);
    zss_editor.debug('imageclick');
    appImageClick(index);
}


zss_editor.setScrollPosition = function() {
    var position = window.pageYOffset;
    
    // window.location = 'scroll://'+position;
    zss_editor.debug('scroll: '+position);
    appScrollPosition(index);
}

/// 当前可用的编辑样式选项
zss_editor.enableEditingTextStyleItems = function(items) {
//    if (items.length > 0) {
//        if (zss_editor.isUsingiOS) {
//            //window.location = "zss-callback/"+items.join(',');
//            window.location = "callback://0/"+items.join(',');
//        } else {
//            console.log("callback://"+items.join(','));
//        }
//    } else {
//        if (zss_editor.isUsingiOS) {
//            window.location = "zss-callback/";
//        } else {
//            console.log("callback://");
//        }
//    }
    if (items.length > 0) {
        zss_editor.debug('enableEditingStyleItems: '+items.join(','));
        appEnableEditingStyleItems(items.join(','));
    } else {
        zss_editor.debug('enableEditingStyleItems: null');
        appEnableEditingStyleItems("");
    }
    
}



/*** 按键处理 ***/

zss_editor.titleKeyDown = function(event) {
    // 8-Backspace键     13-Enter键
    if (event.which == 13) {
        // 禁止换行
        event.cancelBubble = true;
        event.preventDefault();
        event.stopPropagation();
    }
}

zss_editor.contentKeyUp = function(event) {
    // 8-Backspace键     13-Enter键
    if (event.which == 13) {
        // _self.getEditItem(evt);
        
        // 插入p标签
        // 注：按下Enter变成了插入div，导致最后获取的markdown正常换行出现问题
//        zss_editor.insertHTML
        
    } else if (event.which == 8) {
        // _self.getEditItem(evt);
        
        // TODO: - 判断当前是否是图片，如果是图片，则删除
        
//        zss_editor.debug("content Backspace KeyUp")
        
//        var node = zss_editor.getSelectedNode()
//        zss_editor.debug(node)
        
//        var node = zss_editor.getSelectedNode()
//        if node.type == "image" {
//            node.parentNode.removeChild(node)
//        }

//        zss_editor.removeImage("image0")
    }
}

zss_editor.updateOffset = function() {
    zss_editor.debug('zss_editor.updateOffset');
    
    if (!zss_editor.updateScrollOffset)
        return;

    var offsetY = window.document.body.scrollTop;

    var footer = $('#zss_editor_footer');

    var maxOffsetY = footer.offset().top - zss_editor.contentHeight;

    if (maxOffsetY < 0)
        maxOffsetY = 0;

    if (offsetY > maxOffsetY)
    {
        window.scrollTo(0, maxOffsetY);
    }

    zss_editor.setScrollPosition();
}


zss_editor.setPlaceholder = function(placeholder) {

    var editor = $('#zss_editor_content');

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
zss_editor.setContentMinHeight = function(minHeight) {
    var titleH = zss_editor.titleEditor.offsetHeight + 30 + 1; // padding + lineH
    zss_editor.debug('titleH: ' + titleH);
    zss_editor.editor.style.minHeight = minHeight - titleH + 'px';
}

zss_editor.setFooterHeight = function(footerHeight) {
    var footer = $('#zss_editor_footer');
    footer.height(footerHeight + 'px');
}

zss_editor.getCaretYPosition = function() {
    var sel = window.getSelection();
    // Next line is comented to prevent deselecting selection. It looks like work but if there are any issues will appear then uconmment it as well as code above.
    //sel.collapseToStart();
    var range = sel.getRangeAt(0);
    var span = document.createElement('span');// something happening here preventing selection of elements
    range.collapse(false);
    range.insertNode(span);
    var topPosition = span.offsetTop;
    span.parentNode.removeChild(span);
    return topPosition;
}

zss_editor.calculateEditorHeightWithCaretPosition = function() {

    var padding = 50;
    var c = zss_editor.getCaretYPosition();

    var editor = $('#zss_editor_content');

    var offsetY = window.document.body.scrollTop;
    var height = zss_editor.contentHeight;

    var newPos = window.pageYOffset;

    if (c < offsetY) {
        newPos = c;
    } else if (c > (offsetY + height - padding)) {
        newPos = c - height + padding - 18;
    }

    window.scrollTo(0, newPos);
}

zss_editor.backuprange = function(){
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    zss_editor.currentSelection = {"startContainer": range.startContainer, "startOffset":range.startOffset,"endContainer":range.endContainer, "endOffset":range.endOffset};
}

zss_editor.restorerange = function(){
    var selection = window.getSelection();
    selection.removeAllRanges();
    var range = document.createRange();
    range.setStart(zss_editor.currentSelection.startContainer, zss_editor.currentSelection.startOffset);
    range.setEnd(zss_editor.currentSelection.endContainer, zss_editor.currentSelection.endOffset);
    selection.addRange(range);
}

zss_editor.getSelectedNode = function() {
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

zss_editor.setBold = function() {
    document.execCommand('bold', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setItalic = function() {
    document.execCommand('italic', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setSubscript = function() {
    document.execCommand('subscript', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setSuperscript = function() {
    document.execCommand('superscript', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setStrikeThrough = function() {
    document.execCommand('strikeThrough', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setUnderline = function() {
    document.execCommand('underline', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setBlockquote = function() {
    document.execCommand('formatBlock', false, '<blockquote>');
    zss_editor.enabledEditingItems();
}

zss_editor.removeFormating = function() {
    document.execCommand('removeFormat', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setHorizontalRule = function() {
    document.execCommand('insertHorizontalRule', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setHeading = function(heading) {
    var current_selection = $(zss_editor.getSelectedNode());
    var t = current_selection.prop("tagName").toLowerCase();
    var is_heading = (t == 'h1' || t == 'h2' || t == 'h3' || t == 'h4' || t == 'h5' || t == 'h6');
    if (is_heading && heading == t) {
        var c = current_selection.html();
        current_selection.replaceWith(c);
    } else {
        document.execCommand('formatBlock', false, '<'+heading+'>');
    }

    zss_editor.enabledEditingItems();
}

zss_editor.setParagraph = function() {
    var current_selection = $(zss_editor.getSelectedNode());
    var t = current_selection.prop("tagName").toLowerCase();
    var is_paragraph = (t == 'p');
    if (is_paragraph) {
        var c = current_selection.html();
        current_selection.replaceWith(c);
    } else {
        document.execCommand('formatBlock', false, '<p>');
    }

    zss_editor.enabledEditingItems();
}

// Need way to remove formatBlock
console.log('WARNING: We need a way to remove formatBlock items');

zss_editor.undo = function() {
    document.execCommand('undo', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.redo = function() {
    document.execCommand('redo', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setOrderedList = function() {
    document.execCommand('insertOrderedList', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setUnorderedList = function() {
    document.execCommand('insertUnorderedList', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setJustifyCenter = function() {
    document.execCommand('justifyCenter', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setJustifyFull = function() {
    document.execCommand('justifyFull', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setJustifyLeft = function() {
    document.execCommand('justifyLeft', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setJustifyRight = function() {
    document.execCommand('justifyRight', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setIndent = function() {
    document.execCommand('indent', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setOutdent = function() {
    document.execCommand('outdent', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setFontFamily = function(fontFamily) {

    zss_editor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand("fontName", false, fontFamily);
    document.execCommand("styleWithCSS", null, false);
    zss_editor.enabledEditingItems();

}

zss_editor.setTextColor = function(color) {

    zss_editor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('foreColor', false, color);
    document.execCommand("styleWithCSS", null, false);
    zss_editor.enabledEditingItems();
    // document.execCommand("removeFormat", false, "foreColor"); // Removes just foreColor

}

zss_editor.setBackgroundColor = function(color) {
    zss_editor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('hiliteColor', false, color);
    document.execCommand("styleWithCSS", null, false);
    zss_editor.enabledEditingItems();
}

// Needs addClass method

zss_editor.insertLink = function(url, title) {
    zss_editor.debug("zss_editor.insertLink");
    zss_editor.restorerange();
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
        if (!url.match("[\\s\\S]+:[\\s\\S]+")) {
            url = "zhiyi:" + url
        }
        document.execCommand("insertHTML",false,"<a href='"+url+"'>"+title+"</a>");
    }
    
//    zss_editor.enabledEditingItems();
    
}

zss_editor.updateLink = function(url, title) {

    zss_editor.restorerange();

    if (zss_editor.currentEditingLink) {
        var c = zss_editor.currentEditingLink;
        c.attr('href', url);
        c.attr('title', title);
    }
    zss_editor.enabledEditingItems();

}//end

zss_editor.updateImage = function(url, alt) {

    zss_editor.restorerange();

    if (zss_editor.currentEditingImage) {
        var c = zss_editor.currentEditingImage;
        c.attr('src', url);
        c.attr('alt', alt);
    }
    zss_editor.enabledEditingItems();

}//end

zss_editor.updateImageBase64String = function(imageBase64String, alt) {

    zss_editor.restorerange();

    if (zss_editor.currentEditingImage) {
        var c = zss_editor.currentEditingImage;
        var src = 'data:image/jpeg;base64,' + imageBase64String;
        c.attr('src', src);
        c.attr('alt', alt);
    }
    zss_editor.enabledEditingItems();

}//end


zss_editor.unlink = function() {

    if (zss_editor.currentEditingLink) {
        var c = zss_editor.currentEditingLink;
        c.contents().unwrap();
    }
    zss_editor.enabledEditingItems();
}

zss_editor.quickLink = function() {

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
    zss_editor.insertHTML(html_code);

}

zss_editor.prepareInsert = function() {
    zss_editor.backuprange();
}

zss_editor.insertImage = function(url, alt) {
    zss_editor.restorerange();
    var html = '<img src="'+url+'" alt="'+alt+'" />';
    zss_editor.insertHTML(html);
    zss_editor.enabledEditingItems();
}

//zss_editor.insertImageBase64String = function(imageBase64String, alt) {
//    zss_editor.restorerange();
//    var html = '<img src="data:image/jpeg;base64,'+imageBase64String+'" alt="'+alt+'" />';
//    zss_editor.insertHTML(html);
//    zss_editor.enabledEditingItems();
//}

zss_editor.setHTML = function(html) {
    var editor = $('#zss_editor_content');
    editor.html(html);
}

zss_editor.insertHTML = function(html) {
    document.execCommand('insertHTML', false, html);
    zss_editor.enabledEditingItems();
}

zss_editor.getHTML = function() {

    // Images
    var img = $('img');
    if (img.length != 0) {
        $('img').removeClass('zs_active');
        $('img').each(function(index, e) {
                      var image = $(this);
                      var zs_class = image.attr('class');
                      if (typeof(zs_class) != "undefined") {
                      if (zs_class == '') {
                      image.removeAttr('class');
                      }
                      }
                      });
    }

    // Blockquote
    var bq = $('blockquote');
    if (bq.length != 0) {
        bq.each(function() {
                var b = $(this);
                if (b.css('border').indexOf('none') != -1) {
                b.css({'border': ''});
                }
                if (b.css('padding').indexOf('0px') != -1) {
                b.css({'padding': ''});
                }
                });
    }

    // Get the contents
    var h = document.getElementById("zss_editor_content").innerHTML;

    return h;
}

zss_editor.getText = function() {
    return $('#zss_editor_content').text();
}

zss_editor.isCommandEnabled = function(commandName) {
    return document.queryCommandState(commandName);
}

zss_editor.enabledEditingItems = function(e) {

    console.log('enabledEditingItems');
    var items = [];
    if (zss_editor.isCommandEnabled('bold')) {
        items.push('bold');
    }
    if (zss_editor.isCommandEnabled('italic')) {
        items.push('italic');
    }
    if (zss_editor.isCommandEnabled('subscript')) {
        items.push('subscript');
    }
    if (zss_editor.isCommandEnabled('superscript')) {
        items.push('superscript');
    }
    if (zss_editor.isCommandEnabled('strikeThrough')) {
        items.push('strikeThrough');
    }
    if (zss_editor.isCommandEnabled('underline')) {
        items.push('underline');
    }
    if (zss_editor.isCommandEnabled('insertOrderedList')) {
        items.push('orderedList');
    }
    if (zss_editor.isCommandEnabled('insertUnorderedList')) {
        items.push('unorderedList');
    }
    if (zss_editor.isCommandEnabled('justifyCenter')) {
        items.push('justifyCenter');
    }
    if (zss_editor.isCommandEnabled('justifyFull')) {
        items.push('justifyFull');
    }
    if (zss_editor.isCommandEnabled('justifyLeft')) {
        items.push('justifyLeft');
    }
    if (zss_editor.isCommandEnabled('justifyRight')) {
        items.push('justifyRight');
    }
    if (zss_editor.isCommandEnabled('insertHorizontalRule')) {
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
        var s = zss_editor.getSelectedNode();
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
            zss_editor.currentEditingLink = t;
            var title = t.attr('title');
            items.push('link:'+t.attr('href'));
            if (t.attr('title') !== undefined) {
                items.push('link-title:'+t.attr('title'));
            }

        } else {
            zss_editor.currentEditingLink = null;
        }
        // Blockquote
        if (nodeName == 'blockquote') {
            items.push('indent');
        }
        // Image
        if (nodeName == 'img') {
            zss_editor.currentEditingImage = t;
            items.push('image:'+t.attr('src'));
            if (t.attr('alt') !== undefined) {
                items.push('image-alt:'+t.attr('alt'));
            }

        } else {
            zss_editor.currentEditingImage = null;
        }

    }

    // if (items.length > 0) {
    //     if (zss_editor.isUsingiOS) {
    //         //window.location = "zss-callback/"+items.join(',');
    //         window.location = "callback://0/"+items.join(',');
    //     } else {
    //         console.log("callback://"+items.join(','));
    //     }
    // } else {
    //     if (zss_editor.isUsingiOS) {
    //         window.location = "zss-callback/";
    //     } else {
    //         console.log("callback://");
    //     }
    // }
    // 回调修正
    zss_editor.enableEditingTextStyleItems(items);

}

zss_editor.focusEditor = function() {

    // the following was taken from http://stackoverflow.com/questions/1125292/how-to-move-cursor-to-end-of-contenteditable-entity/3866442#3866442
    // and ensures we move the cursor to the end of the editor
    var editor = $('#zss_editor_content');
    var range = document.createRange();
    range.selectNodeContents(editor.get(0));
    range.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    editor.focus();
}

// 插入链接后的聚焦
zss_editor.focusAfterInsertLink = function() {
    
}
// 插入图片后的聚焦
zss_editor.focusAfterInsertImage = function() {
    
}
// 取消插入后的聚焦
zss_editor.focusAfterCancelInsert = function() {
    
}

zss_editor.blurEditor = function() {
    $('#zss_editor_content').blur();
}

zss_editor.setCustomCSS = function(customCSS) {

    document.getElementsByTagName('style')[0].innerHTML=customCSS;

    //set focus
    /*editor.focusout(function(){
                    var element = $(this);
                    if (!element.text().trim().length) {
                    element.empty();
                    }
                    });*/



}

//end


zss_editor.getTitleText = function() {
    return $('#zss_editor_title').text();
}

// 引用样式的移除，使用p标签或div标签
zss_editor.removeBlockquote = function() {
//    let Range = document.getSelection().getRangeAt(0),
//    formatName = Range.commonAncestorContainer.parentElement.nodeName === 'BLOCKQUOTE' ? 'P' : 'BLOCKQUOTE';
//    document.execCommand('formatBlock', false, formatName)
//    zss_editor.enabledEditingItems();
    
    // 引用样式移除，注setBlockquote不可使用setIndent，否则会不断的缩进下去
    // 上面的方式在某些情况下会出现异常，特别是有删除线时
    zss_editor.setOutdent();
}

// 判断该图片是否存在
zss_editor.isExistImage = function(imageIndex) {
    var divImg = document.getElementById('image'+imageIndex)
    return divImg != null ? "1" : "0";
}

zss_editor.insertImageBase64String = function(imageBase64String, imageIndex, alt, width, height) {
    zss_editor.restorerange();

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
    zss_editor.insertHTML(html);
    zss_editor.enabledEditingItems();
    
    // 添加点击事件
    var imagenode = document.getElementById('image' + imageIndex);
    // imagenode必须在外面再套一层，否则删除时直接崩溃
    imagenode.contentEditable = false;
    imagenode.addEventListener('click', function (e) {
       e.stopPropagation();
//       zss_editor.debug("imageclick");
       window.location = 'imageclick://' + encodeURI(imageIndex);
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

// 需要进一步验证

zss_editor.removeImage = function(id) {
    var divImg = document.getElementById('image'+id);
    divImg.parentNode.removeChild(divImg);
}

zss_editor.reloadImage = function(id) {
    
}

zss_editor.uploadImageSuccess = function(id, fileId) {
    var divImg = document.getElementById('image'+id);
    var markdown = divImg.querySelector('.markdown');
    markdown.innerHTML = "@![image]("+fileId+")<br />"; // 图片后增加换行。插入图片后的换行容易被文字代替
    zss_editor.debug(markdown.innerHTML);
}

zss_editor.uploadImageFailure = function(id) {
    var divImg = document.getElementById('image'+id);
    var failure = divImg.querySelector('.failure');
    failure.style.display = 'block';
    // 上传失败，则移除该图片
    //zss_editor.removeImage(id)
}

// 获取内容的markdown格式
zss_editor.getContentMarkdown = function() {
    // 注意懒惰匹配
    //var markdown = zss_editor.getHTML().replace(/<div>|<\/div>|<[divimginput]+ class=".*">/g, '').replace(/\n|\t/g,'').trim();
//    var markdown = zss_editor.getHTML().replace(/<div>|<\/div>|<[divimg]+ class=".*?">/g, '').replace(/\n|\t/g,'').trim();
    // .replace(/<\/div>|<div>[u4e00-u9fa5]+<\/div>/g,"").trim();
    // 保留无class的div，以保证换行
    var markdown = zss_editor.getHTML().replace(/<div\\s+\\S+>\\s+\\S+<\/div>|<[divimginput]+ class=".*?">/g, '').replace(/\n|\t/g,'').trim();
    return markdown;
}

// 获取内容的无markdown格式，取消所有标签
zss_editor.getContentNoMarkdown = function(content) {
    var content = zss_editor.getHTML().replace(/<div class=".*">.*<\/div>|<\/?[^>]*>/g, '').replace(/\s+/, '').trim();
    return content;
}

// 设置标题
zss_editor.setTitle = function(title) {
    if (null != title) {
        zss_editor.titleEditor.innerText = title;
    }
}

// 设置内容
zss_editor.setContentWithMarkdown = function(markdown) {
    if (null != markdown) {
        zss_editor.debug('set markdown content start: \n' + markdown + '\n');
        
        zss_editor.editor.innerHTML = markdown;

        
        // 似乎没有range
        //zss_editor.insertHTML(html);
        
//        var editor = document.getElementById("zss_editor_content");
//        editor.innerHTML = markdown;
    }
}

