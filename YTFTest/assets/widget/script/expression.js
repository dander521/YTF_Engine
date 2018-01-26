(function (window) {
    var u = {};
    /*
     author:xxiaomao
     email:cd@yuantuan.com
     description:表情输入
     created:2016.12.22
     update:0.0.1
     */
    //$.fn.chatExpression = function (options) {
    u.chatExpression = function (options) {
        /*
        options
        @param url expressionFile 表情目录路径
        @param Object chatText 输入框
        @param Object expressionMain 表情显示的盒子
        */
        var _this = this;
        var defaults = {
            expressionFile: null,
            chatText: "#chatText",
            expressionMain: ".expression-wrap"
        };
        var settings = $.extend({}, defaults, options);
        var em_json = [
		    {"name": "Expression_1.png","text": "[微笑]"},
		    {"name": "Expression_2.png","text": "[撇嘴]"},
		    {"name": "Expression_3.png","text": "[色]"},
		    {"name": "Expression_4.png","text": "[发呆]"},
		    {"name": "Expression_5.png","text": "[得意]"},
		    {"name": "Expression_6.png","text": "[流泪]"},
		    {"name": "Expression_7.png","text": "[害羞]"},
		    {"name": "Expression_8.png","text": "[闭嘴]"},
		    {"name": "Expression_9.png","text": "[睡]"},
		    {"name": "Expression_10.png","text": "[大哭]"},
		    {"name": "Expression_11.png","text": "[尴尬]"},
		    {"name": "Expression_12.png","text": "[发怒]"},
		    {"name": "Expression_13.png","text": "[调皮]"},
		    {"name": "Expression_14.png","text": "[呲牙]"},
		    {"name": "Expression_15.png","text": "[惊讶]"},
		    {"name": "Expression_16.png","text": "[难过]"},
		    {"name": "Expression_17.png","text": "[酷]"},
		    {"name": "Expression_18.png","text": "[冷汗]"},
		    {"name": "Expression_19.png","text": "[抓狂]"},
		    {"name": "Expression_20.png","text": "[吐]"},
		    {"name": "Expression_21.png","text": "[偷笑]"},
		    {"name": "Expression_22.png","text": "[愉快]"},
		    {"name": "Expression_23.png","text": "[白眼]"},
		    {"name": "Expression_24.png","text": "[傲慢]"},
		    {"name": "Expression_25.png","text": "[饥饿]"},
		    {"name": "Expression_26.png","text": "[困]"},
		    {"name": "Expression_27.png","text": "[恐惧]"},
		    {"name": "Expression_28.png","text": "[流汗]"},
		    {"name": "Expression_29.png","text": "[憨笑]"},
		    {"name": "Expression_30.png","text": "[悠闲]"},
		    {"name": "Expression_31.png","text": "[奋斗]"},
		    {"name": "Expression_32.png","text": "[咒骂]"},
		    {"name": "Expression_33.png","text": "[疑问]"},
		    {"name": "Expression_34.png","text": "[嘘]"},
		    {"name": "Expression_35.png","text": "[晕]"},
		    {"name": "Expression_36.png","text": "[疯了]"},
		    {"name": "Expression_37.png","text": "[衰]"},
		    {"name": "Expression_38.png","text": "[骷髅]"},
		    {"name": "Expression_39.png","text": "[敲打]"},
		    {"name": "Expression_40.png","text": "[再见]"},
		    {"name": "Expression_41.png","text": "[擦汗]"},
		    {"name": "Expression_42.png","text": "[抠鼻]"},
		    {"name": "Expression_43.png","text": "[鼓掌]"},
		    {"name": "Expression_44.png","text": "[糗大了]"},
		    {"name": "Expression_45.png","text": "[坏笑]"},
		    {"name": "Expression_46.png","text": "[左哼哼]"},
		    {"name": "Expression_47.png","text": "[右哼哼]"},
		    {"name": "Expression_48.png","text": "[哈欠]"},
		    {"name": "Expression_49.png","text": "[鄙视]"},
		    {"name": "Expression_50.png","text": "[委屈]"},
		    {"name": "Expression_51.png","text": "[快哭了]"},
		    {"name": "Expression_52.png","text": "[阴险]"},
		    {"name": "Expression_53.png","text": "[亲亲]"},
		    {"name": "Expression_54.png","text": "[吓]"},
		    {"name": "Expression_55.png","text": "[可怜]"},
		    {"name": "Expression_56.png","text": "[菜刀]"},
		    {"name": "Expression_57.png","text": "[西瓜]"},
		    {"name": "Expression_58.png","text": "[啤酒]"},
		    {"name": "Expression_59.png","text": "[篮球]"},
		    {"name": "Expression_60.png","text": "[乒乓]"},
		    {"name": "Expression_61.png","text": "[咖啡]"},
		    {"name": "Expression_62.png","text": "[饭]"},
		    {"name": "Expression_63.png","text": "[猪头]"},
		    {"name": "Expression_64.png","text": "[玫瑰]"},
		    {"name": "Expression_65.png","text": "[凋谢]"},
		    {"name": "Expression_66.png","text": "[嘴唇]"},
		    {"name": "Expression_67.png","text": "[爱心]"},
		    {"name": "Expression_68.png","text": "[心碎]"},
		    {"name": "Expression_69.png","text": "[蛋糕]"},
		    {"name": "Expression_70.png","text": "[闪电]"},
		    {"name": "Expression_71.png","text": "[炸弹]"},
		    {"name": "Expression_72.png","text": "[刀]"},
		    {"name": "Expression_73.png","text": "[足球]"},
		    {"name": "Expression_74.png","text": "[瓢虫]"},
		    {"name": "Expression_75.png","text": "[便便]"},
		    {"name": "Expression_76.png","text": "[月亮]"},
		    {"name": "Expression_77.png","text": "[太阳]"},
		    {"name": "Expression_78.png","text": "[礼物]"},
		    {"name": "Expression_79.png","text": "[拥抱]"},
		    {"name": "Expression_80.png","text": "[强]"},
		    {"name": "Expression_81.png","text": "[弱]"},
		    {"name": "Expression_82.png","text": "[握手]"},
		    {"name": "Expression_83.png","text": "[胜利]"},
		    {"name": "Expression_84.png","text": "[抱拳]"},
		    {"name": "Expression_85.png","text": "[勾引]"},
		    {"name": "Expression_86.png","text": "[拳头]"},
		    {"name": "Expression_87.png","text": "[差劲]"},
		    {"name": "Expression_88.png","text": "[爱你]"},
		    {"name": "Expression_89.png","text": "[NO]"},
		    {"name": "Expression_90.png","text": "[OK]"},
		    {"name": "Expression_91.png","text": "[爱情]"},
		    {"name": "Expression_92.png","text": "[飞吻]"},
		    {"name": "Expression_93.png","text": "[跳跳]"},
		    {"name": "Expression_94.png","text": "[发抖]"},
		    {"name": "Expression_95.png","text": "[怄火]"},
		    {"name": "Expression_96.png","text": "[转圈]"},
		    {"name": "Expression_97.png","text": "[磕头]"},
		    {"name": "Expression_98.png","text": "[回头]"},
		    {"name": "Expression_99.png","text": "[跳绳]"},
		    {"name": "Expression_100.png","text": "[投降]"},
		    {"name": "Expression_101.png","text": "[激动]"},
		    {"name": "Expression_102.png","text": "[街舞]"},
		    {"name": "Expression_103.png","text": "[献吻]"},
		    {"name": "Expression_104.png","text": "[左太极]"},
		    {"name": "Expression_105.png","text": "[右太极]"}
	];
	
	$(settings.expressionMain).find("i").remove();

	function jsonAttr(strObj) {
		var strAttr = "";
		for (var item in strObj) {
			strAttr = strAttr + item + '="' + strObj[item] + '" ';
		}
		return strAttr;
	}
	for (var i = 0; i < em_json.length; i++) {
		$(settings.expressionMain).append('<i ' + jsonAttr(em_json[i]) + '><img src="' + settings.expressionFile + em_json[i].name + '"></i>')
	}
        
        //点击获取表情内容
        $(settings.expressionMain).on("click", "i", function () {
            if (settings.chatText) {
                InsertImage($(settings.chatText), $(this).children("img").attr("src"), $(this).attr('text'))
            }
        });

        //插入表情图片
        function InsertImage(editer, ImagePath, _em) {
            editer.focus();
            insertHtmlAtCaret('<img src="' + ImagePath + '" data-em="' + _em + '">');
        }

        //获取输入内容
        function textContent() {
            var textConetentHtml = $(settings.chatText).html().replace(/<img[^>]+data-em=['"]([^'"]+)['"]+>/g, "$1");
            return textConetentHtml;
        };
        
        //解析为表情图片内容
        function exportPic(str){
            for (var i = 0; i < em_json.length; i++) {
                em_json[i].text = em_json[i].text.replace('[', '');
                em_json[i].text = em_json[i].text.replace(']', '');
                str = str.replace(new RegExp('\\[(' + em_json[i].text + ')\\]', "g"), '<img src="' + settings.expressionFile + em_json[i].name + '" data-em="[' + em_json[i].text + ']">');
                
            }
            return str;
        }
        
        //光标位置插入内容
        function insertHtmlAtCaret(html) {
            var sel, range;
            if (window.getSelection) {
                // IE9 and non-IE  
                sel = window.getSelection();
                if (sel.getRangeAt && sel.rangeCount) {
                    range = sel.getRangeAt(0);
                    range.deleteContents();
                    // Range.createContextualFragment() would be useful here but is  
                    // non-standard and not supported in all browsers (IE9, for one)  
                    var el = document.createElement("div");
                    el.innerHTML = html;
                    var frag = document.createDocumentFragment(),
                        node, lastNode;
                    while ((node = el.firstChild)) {
                        lastNode = frag.appendChild(node);
                    }
                    range.insertNode(frag);
                    // Preserve the selection  
                    if (lastNode) {
                        range = range.cloneRange();
                        range.setStartAfter(lastNode);
                        range.collapse(true);
                        sel.removeAllRanges();
                        sel.addRange(range);
                    }
                }
            } else if (document.selection && document.selection.type != "Control") {
                // IE < 9  
                document.selection.createRange().pasteHTML(html);
            }
        }


        var has_open = false;
        //打开
        function openDialog() {
            
            $(settings.expressionMain).addClass("expression-open");
            has_open = true
        }
        //关闭
        function closeDialog() {
            $(settings.expressionMain).removeClass("expression-open");
            has_open = false
        };

        var _obj = {
            open: function (callback) {
                if (!has_open) {
                    openDialog();
                    callback && callback(has_open);
                    return has_open
                }
            },
            close: function (callback) {
                if (has_open) {
                    closeDialog();
                    callback && callback(has_open);
                    return has_open;
                }
            },
            toggle: function (callback) {
                if (has_open) {
                    closeDialog();
                } else {
                    openDialog();
                }
                callback && callback(has_open);
                return has_open;
            },
            output: function (callback) {
                callback && callback(textContent());
            },
            expressionExport:function(str,callback){
                callback && callback(exportPic(str));
            }
        };
        return _obj;

    }

    window.$ytf = u;
})(window);