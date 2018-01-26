	
	
	function eventListenerAdd(eventName){
		YTF.eventListenerAdd(
	      {eventName: eventName},
	      function(ret, err){
	        if( ret ){
	              toastMsg("add"+JSON.stringify(ret));
	            }else{
	              console.log(JSON.stringify(err));
	        }
        });
	}
	function cancleEvent(eventName){
		YTF.eventListenerRm(
	      {eventName: eventName},
	      function(ret, err){
	        if( ret ){
	              toastMsg("cancleEvent"+"取消监听成功！");
	            }else{
	              console.log(JSON.stringify(err));
	            }
        	});
	}
	
//	function sendEvent(eventName){
//		YTF.eventSend({
//		    eventName: eventName,
//		});
//	}
	function sendEvent(eventName){
		YTF.eventSend({
		    eventName: eventName,
		    attr: {
	        key1: '发送自定义消息：',
	        key2: eventName
	    }
		});
	}

