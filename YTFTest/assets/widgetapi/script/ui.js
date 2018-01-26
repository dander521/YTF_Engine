/**Alert弹窗*/
function Alert() {
	YTF.webUIAlert({
		title : "提示框",
		msg : "测试内容",
		buttons : ["确定"]
	}, function(ret, err) {
		alert(JSON.stringify(ret));
	});
}

/**Alert弹窗*/
function AlertMsg(msg) {
	YTF.webUIAlert({
		title : "提示框",
		msg : msg,
		buttons : ["确定"]
	}, function(ret, err) {
		alert(JSON.stringify(ret));
	});
}

/**Alert弹窗*/
function Alert1() {
	YTF.webUIConfirm({
		title : "提示框",
		msg : "测试内容",
		buttons : ["确定", "忽略", "取消"]
	}, function(ret, err) {
		alert(JSON.stringify(ret));
	});
}

/**Alert弹窗*/
function Alert2() {
	YTF.webUIPrompt({
		title : "提示框",
		msg : "测试内容",
		text : "请输入......",
		buttons : ["确定", "忽略", "取消"],
		type : "number"

	}, function(ret, err) {
		alert(JSON.stringify(ret));
	});
}

/**进度弹窗*/
function Progress() {
	YTF.showProgress({
		　　imgUrl:"widget://images/loading.gif",
		bottomText : "加载中23···",
		topText : "加载中333···",
		// bgColor : "#20f0",
		bgColor : "rgba(255,0,0,0.2)",
		topTextColor : "#cccccc",
		// xywh : {
		// w : 80,
		// h : 80
		// },
		// gifSize : {
		// w : 40,
		// h : 40
		// },
	});

	setTimeout("closeProgress()", 3000);
}

/**关闭弹窗*/
function closeProgress() {
	YTF.hideProgress();
}

/**下拉刷新设置*/
function setPull1() {
	YTF.webUISetPullDownRefresh({
		isShow : true,
		imgUrl : "widget://images/default_ptr_rotate.png",
		textColor : "#FF0191",
		textDown : "下拉可以刷新",
		textUp : "松开可以刷新",
		textLoading : "加载中",
		// textUpdateTime:"5年前",       isShowUpdateTime:true
	}, function(ret, err) {
	});
}

/**关闭刷新*/
function closePull1() {
	YTF.webUIPullDownCloseRefresh();
}

/**设置为下拉刷新状态*/
function openPull() {
	YTF.webUIPullDownOpenRefresh();
}

/**下拉刷新设置*/
function setPull() {
	YTF.setPullDownRefresh({
		isShow : true,
		imgUrl : "widget://images/default_ptr_rotate.png",
		textColor : "#FF0191",
		textDown : "下拉可以刷新",
		textUp : "松开可以刷新",
		textLoading : "加载中",
		// textUpdateTime:"5年前",       isShowUpdateTime:true
	}, function(ret, err) {
	});
}

/**关闭刷新*/
function closePull() {
	YTF.pullDownCloseRefresh();
}

/**设置为下拉刷新状态*/
function openPull1() {
	YTF.pullDownOpenRefresh();
}

/**Toast弹窗*/
function toast() {
	YTF.toast({
		msg : "测试弹窗",
		location : 'middle',
		duration : 2000,
		global : false
	});
}

/**进度弹窗*/
function webProgress() {
	YTF.webUIShowProgress({
		　　imgUrl:"widget://images/loading.gif",
		bottomText : "加载中23···",
		topText : "加载中333···",
		bgColor : "#333333",
		xywh : {
			w : 80,
			h : 80
		},
		gifSize : {
			w : 40,
			h : 40
		},
	});
	setTimeout("webCloseProgress()", 3000);
}

/**关闭弹窗*/
function webCloseProgress() {
	YTF.webUIHideProgress();
}

function setPullUpLoading() {
	alert(222);
	YTF.setPullUpLoading({
		isShow : true,
		imgUrl:"widget://image/aa.png",
		bgColor : "rgba(255,255,255,0.2)",
		textColor : "rgba(109, 128, 153, 0.2)",
		textDown : "上拉可以刷新...",
		textUp : "松开可以刷新...",
		textLoading : "加载中...",
		// textUpdateTime:"2016.10.12",
		isShowUpdateTime : true
	}, function(ret, err) {
		// alert(ret.status);
	});
}

function pullUpOpenLoading() {
	YTF.pullUpOpenLoading();
}

function pullUpCloseLoading() {
	YTF.pullUpCloseLoading();
}

function set3DTouchListener(){
    YTF.config3DTouchListener({},function(ret,err){
                               alert(123);
                               if(ret){
                               alert(ret);
                               }
                               
                               });}

function set3DTouchMenu(){
    YTF.config3DTouchMenu({
                               items:[{
                                      type: 'com.yuantuan.YTF.add',
                                      title: 'Add',
                                      icon: {
                                      file: 'widget://images/home.png'
                                      },
                                      userInfo:{
                                      'key1': 'value1'
                                      }
                                      },{
                                      type: 'com.yuantuan.YTF.done',
                                      title: 'Done',
                                      icon: {
                                      type: 0
                                      },
                                      userInfo:{
                                      'key2': 'value2'
                                      }
                                      }]
                               },function(ret,err){
                               if(ret){
                               alert(ret);
                               }
                               });
}



