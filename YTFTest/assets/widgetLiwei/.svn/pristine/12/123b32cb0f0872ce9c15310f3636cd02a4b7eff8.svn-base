//var filePath = "file:///android_asset/widget/";
var filePath = "./";

	/**
	 * 添加tap事件并执行参数方法
	 */
	function tapMethod(){
    	$(".list").on("tap","li",function(){
	  		var args = $(this).data("args");
	  		eval(args);
	  	});
    }
/**Toast弹窗*/
	function toastMsg(msg){
	    YTF.webUIToast({
	        msg:msg,
	        location:'middle',
	        duration:2000,
	        global:false
	    });
	}
	
/**Alert弹窗*/
	function AlertWinInfoTitleMsg(title,msg){
	    YTF.webUIAlert({
            title:title,
            msg:msg,
            buttons:["确定"]

	    },function(ret,err){
	    });
	}
	
	/**
	 * 打开一个新的功能窗口
	 * @param {Object} url
	 * @param {Object} param
	 */
	function openNewWin(title,winUrl,frameUrl,winType,frameType){
		YTF.winOpen({
            winName:winType,
			htmlUrl:winUrl,
			htmlParam:{
				title:title,
				frameUrl:frameUrl,
				frameType:frameType
			}
        });
	}
	
	/**Alert弹窗*/
	function AlertTitleMsg(title,msg){
	    YTF.webUIAlert({
            title:title,
            msg:msg,
            buttons:["确定"]

	    },function(ret,err){
//	        alert(ret);
	    });
	}
	
	/**
	 * 判断是否支持沉浸式状态栏
	 * @param {Object} el
	 */
	function isStatusBarAppearance(){
        
        var systemType = YTF.systemType;
        if(systemType == 'ios'){
            var iosVersion = YTF.systemVersion;
            var numSV = parseInt(iosVersion,10);
//          var fullScreen = api.fullScreen;
//          var iOS7StatusBarAppearance = api.iOS7StatusBarAppearance;
//          if (numSV >= 7 && !fullScreen && iOS7StatusBarAppearance) {
//              el.style.paddingTop = '20px';
//          }
       }else if(systemType == 'Android'){
            var Version = YTF.systemVersion;
            ver = parseFloat(Version);
            if(ver >= 4.4){
            	return true;
//              el.style.paddingTop = '25px';
            }
        }
    }