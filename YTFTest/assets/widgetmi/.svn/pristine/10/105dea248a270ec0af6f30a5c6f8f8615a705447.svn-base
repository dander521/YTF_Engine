/**Alert弹窗*/
	function Alert(){
	    YTF.webUIAlert({
            title:"提示框",
            msg:"测试内容",
            buttons:["确定"]
	    },function(ret,err){
	        alert(JSON.stringify(ret));
	    });
	}
	/**Alert弹窗*/
	function AlertMsg(msg){
	    YTF.webUIAlert({
            title:"提示框",
            msg:msg,
            buttons:["确定"]
	    },function(ret,err){
	        alert(JSON.stringify(ret));
	    });
	}
	/**Alert弹窗*/
	function Alert1(){
	    YTF.webUIConfirm({
            title:"提示框",
            msg:"测试内容",
            buttons:["确定","忽略","取消"]
	    },function(ret,err){
	        alert(JSON.stringify(ret));
	    });
	}
		/**Alert弹窗*/
	function Alert2(){
	    YTF.webUIPrompt({
            title:"提示框",
            msg:"测试内容",
            text:"请输入......",
            buttons:["确定","忽略","取消"],
            type:"number"

	    },function(ret,err){
	        alert(JSON.stringify(ret));
	    });
	}
	 /**进度弹窗*/
	function Progress(){
        YTF.showProgress({
        　　imgUrl:"widget:///images/loading.gif",
        });
        
        setTimeout("closeProgress()",10000);
	}

	/**关闭弹窗*/
	function closeProgress(){
	    YTF.hideProgress();
	}
	
	/**下拉刷新设置*/
	function setPull(){
	    YTF.webUISetPullDownRefresh({
	        isShow:true,
	        imgUrl:"widget:///images/default_ptr_rotate.png",
	        textColor:"#FF0191F7",
	        textDown:"下拉可以刷新",
	        textUp:"松开可以刷新",
	        textLoading:"加载中",
	        textUpdateTime:"5年前",
	        isShowUpdateTime:true
	    },function(ret,err){
	    });
	}
	
	/**关闭刷新*/
	function closePull(){
	    YTF.webUIPullDownCloseRefresh();
	}
	/**设置为下拉刷新状态*/
	function openPull(){
	    YTF.webUIPullDownOpenRefresh();
	}
	
	
/**Toast弹窗*/
	function toast(){
	    YTF.webUIToast({
	        msg:"测试弹窗",
	        location:'middle',
	        duration:2000,
	        global:false
	    });
	}
	

 /**进度弹窗*/
	function webProgress(){
        YTF.webUIShowProgress({
        　　imgUrl:"widget://images/loading.gif",
        });
        setTimeout("webCloseProgress()",10000);
	}

	/**关闭弹窗*/
	function webCloseProgress(){
	    YTF.webUIHideProgress();
	}