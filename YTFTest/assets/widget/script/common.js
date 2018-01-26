serverUrl = "http://biyu.iyuantuan.org.cn/";
photoUrl = "http://biyu.iyuantuan.org.cn";
userToken = (localStorage.getItem("logtoken")) ? localStorage.getItem("logtoken") : "";
/**打开一个新的Win*/
function openNewWin(winName, winUrl) {
	YTF.winOpen({
		winName : winName,
		htmlUrl : winUrl,
	});
}

/**
 * 打开frame
 */
function openFrame(frameName, frameUrl, x, y, w, h) {

	YTF.frameOpen({
		frameName : frameName,
		htmlUrl : frameUrl,
		isBounces : true,
		background : '#000000',
		isVScrollBar : true,
		isHScrollBar : true,
		isScale : true,
		htmlParam : YTF.getHtmlParam(),
		xywh : {
			x : x,
			y : y,
			w : w,
			h : h,
			marginLeft : 0, //相对父 window 左外边距的距离
			marginTop : 0, //相对父 window 上外边距的距离
			marginBottom : 0, //相对父 window 下外边距的距离
			marginRight : 0 //相对父 window 右外边距的距离
		},
		isReload : false,
		isEdit : true
	});
}

function isElement(obj) {
	return !!(obj && obj.nodeType == 1);
}

function statusBarFix(obj) {
	var deviceSystem = YTF.systemType;
	var systemVer = parseFloat(YTF.systemVersion);
	if (!isElement(obj)) {
		console.log('obj is not a DOM Element');
		return;
	}
	if (deviceSystem == "iOS") {
		if (systemVer >= 7) {
			obj.style.paddingTop = '20px';
		}
	} else if (deviceSystem == "Android") {
		if (systemVer >= 5.0) {
			obj.style.paddingTop = '25px';
		}
	}
}

//手机格式验证
function checkPhone(phone) {
	var res = phone.match(/^1[3|4|5|7|8][0-9]\d{8}$/);
	return res;
};

//短信验证码格式验证
function checkSmsCode(code) {
	var res = code.match(/^[0-9]*$/);
	return res;
};

//检测是否为空
function checkIsEmpty(str) {
	if (str == "" || str == null || str == undefined) {
		return true;
	}
	return false;
}

//根据年月日计算年龄
function ages(str) {
	var r = str.match(/^(\d{1,4})(-|\/)(\d{1,2})\2(\d{1,2})$/);
	if (r == null)
		return false;
	var d = new Date(r[1], r[3] - 1, r[4]);
	if (d.getFullYear() == r[1] && (d.getMonth() + 1) == r[3] && d.getDate() == r[4]) {
		var Y = new Date().getFullYear();
		return Y - r[1];
	}
	return false;
}

/**登录界面*/
function openLoginWin(winName, winUrl) {
	localStorage.clear();
	YTF.winOpen({
		winName : winName,
		htmlUrl : winUrl,
	});
	window.setTimeout(function() {
		YTF.winClose();
		YTF.winClose({
			winName:"index_main"
		});
		}, 2000);
};

//性别
var sexArr = [];
sexArr[0] = "保密";
sexArr[1] = "男";
sexArr[2] = "女";

/**
 *获取距离查询条件标题 
 */
function getDistanceTitle(distance){
	var val = "不限";
	switch(distance){
		case'city':
			val = "同城";
			break;
		case'province':
			val = "同省";
			break;
		case'nprovince':
			val = "省外";
			break;
	};
	return val;
};

/**
 *获取年龄标题
 */
function getAgeTitle(age) {
	var val = "不限";
	switch(age) {
	case'0-12':
		val = '12岁以下';
		break;
	case'12-18':
		val = '12岁-18岁';
		break;
	case'18-24':
		val = "18岁-24岁";
		break;
	case'24-30':
		val = "24岁-30岁";
		break;
	case'30-40':
		val = "30岁-40岁";
		break;
	case'40-50':
		val = "40岁-50岁";
		break;
	case'50-60':
		val = "50岁-60岁";
		break;
	case'60-200':
		val = "60岁以上";
		break;
	}

	return val;
};
//****************侯文才**********************//

/****网络错误显示模版****/
function netErr(doc,fun){
	var temp = '<div class="h943-hmc yt yt-ac yt-pc yt-ver">'+
			'	<div class="img-wrap user-photo bg-img-network-busy02" style="background-image: url(../images/bg-img-network-busy02.png);">'+
			'	</div>'+
			'	<div class="fz32 c66 lh1 mt40 mb30">网络不给力哦...</div>'+
			'	<div class="btn-network-busy yt yt-ac yt-pc" onClick="'+fun+'">重试</div>'+
			'</div>';
		$(doc).html(temp);
}

/****暂无数据显示模版****/
function noData(doc,fun,msg){
	if(!msg){
		msg = "暂无数据";
		}
	var temp = '<div class="h943-hmc yt yt-ac yt-pc yt-ver">'+
			'	<div class="img-wrap user-photo bg-img-blank_my" style="background-image: url(../images/bg-img-blank.png);">'+
			'	</div>'+
			'	<div class="fz32 c66 lh1 mt40 mb30">'+msg+'</div>'+
			'	<div class="btn-network-busy yt yt-ac yt-pc" onClick="'+fun+'">重试</div>'+
			'</div>';
		$(doc).html(temp);
}

//时间戳格式化
function formatDate(date, format) {
			if (!date) return;   
			if (!format) format = "yyyy-MM-dd"; 
			date = parseInt(date);   
			switch(typeof date) {   
				case "string":
					if(date.indexOf(".") > 0){
						date = new Date(date.split(".")[0].replace(/-/ig, "/")); 
						}else{
						date = new Date(date.replace(/-/ig, "/")); 	
							}
					break;   
				case "number":   
					date = new Date(date * 1000);   
					break;   
			}    
			if (!date instanceof Date) return;   
			var dict = {   
				"yyyy": date.getFullYear(),   
				"M": date.getMonth() + 1,   
				"d": date.getDate(),   
				"H": date.getHours(),   
				"m": date.getMinutes(),   
				"s": date.getSeconds(),   
				"MM": ("" + (date.getMonth() + 101)).substr(1),   
				"dd": ("" + (date.getDate() + 100)).substr(1),   
				"HH": ("" + (date.getHours() + 100)).substr(1),   
				"mm": ("" + (date.getMinutes() + 100)).substr(1),   
				"ss": ("" + (date.getSeconds() + 100)).substr(1)
			};       
			return format.replace(/(yyyy|MM?|dd?|HH?|ss?|mm?)/g, function() {   
				return dict[arguments[0]];   
			});                   
		}
		
/***个性化日期***/
//JavaScript函数：
var minute = 1000 * 60;
var hour = minute * 60;
var day = hour * 24;
var halfamonth = day * 15;
var month = day * 30;
function getDateDiff(dateTimeStamp) {
        var now = new Date().getTime();
        var diffValue = now - getDateTimeStamp(dateTimeStamp);
        if (diffValue < 0) {
                //若日期不符则弹出窗口告之
                //alert("结束日期不能小于开始日期！");
        }
        var monthC = diffValue / month;
        var weekC = diffValue / (7 * day);
        var dayC = diffValue / day;
        var hourC = diffValue / hour;
        var minC = diffValue / minute;
        if (monthC >= 1) {
                result = parseInt(monthC) + "个月前";
        } else if (weekC >= 1) {
                result = parseInt(weekC) + "周前";
        } else if (dayC >= 1) {
                result = parseInt(dayC) + "天前";
        } else if (hourC >= 1) {
                result = parseInt(hourC) + "小时前";
        } else if (minC >= 1) {
                result = parseInt(minC) + "分钟前";
        } else result = "刚刚";
        return result;
}
//js函数代码：字符串转换为时间戳
function getDateTimeStamp(dateStr){
	return Date.parse(dateStr.replace(/-/gi,"/"));
}

/*定位方法，此方法非同步回调，
**可现在index页面调用此方法获取结果
*/
function getLocation(){
	var location=YTF.require("YTFAmap");
		location.getLocation({
		　　mode:0,
		　　cache:false
		},function(ret,err){
			if(ret){
				localStorage.setItem("location",JSON.stringify(ret));
				}
		});
}

function showProgress(str){
	YTF.showProgress({
		bottomText:str,
		gifSize:{
				w:60,
				h:60
			},
		xywh:{
				w:130,
				h:130
			},
		bgColor:"rgba(51,51,51,0.8)"
	});
}
//****************侯文才**********************//

