	var uploadUrl = 'http://139.129.52.244/index.php/Api/Upload/index';
	function cancleAjax(){
		YTF.cancelAjax(
        {   signName: 'testAjaxGet'},
        function(ret,err){
            alert(JSON.stringify(ret));
        });
	}

	function nimingAjax(url){
         YTF.ajax({
         		url:url,
               signName: 'testAjaxGet',
               methodType: 'get',
			   },function(ret,err){
			        if(ret){
						alert(JSON.stringify(ret));
			        }else{
			        }

       		   })
	}
	function nimingAjaxPost(url,txt){
         YTF.ajax({
         	   url:url,
               signName: 'testAjaxPost',
               methodType: 'post',
               data: {
                    values: {
						txt: txt
                    }
                }
			   },function(ret,err){
			   		if(ret){
			   			alert("客户端返回数据为："+JSON.stringify(ret));
			   		}else if(err){
			   			alert(JSON.stringify(err));
			   		}
       		   });
	}



	function nimingAjaxUpload(url,files){

         YTF.ajax({
			   url: url,
               signName: 'testAjaxPost1',
               methodType: 'post',
               data: {
                    files: {
                        flieupload:files
                    }
                }
			   },function(ret,err){
			        if(ret){
			            if(ret.data.flie_url){
			            	var publicUrl ='http://139.129.52.244/'+ret.data.flie_url ;
			            	$("#imgUpload").attr('src',publicUrl); 
			            }
			        }else{
			        }
       		   });
	}

	function downLoadAjax(url) {

	YTF.ajaxDownload({
			url: url,
			methodType: 'get',
			signName: 'testAjaxDownLoad',
			saveFileName: 'master.zip'
		},
		function(ret, err) {
			if(ret) {
				if(ret && ret.progress) {
					$(".progress .spanWidth").css("width", ret.progress+ "%" );
				}
				if(ret.progress == 100 && ret.filePath ) {
					alert("下载完成！地址为：" + ret.filePath);
				}
			} else if(err) {
			}
		});
}
	function cancleDownLoadAjax(){
        YTF.cancelAjax(
        {   signName: 'testAjaxDownLoad'},
        function(ret,err){
        alert(JSON.stringify(ret));
        });
	}


	/**调用本地相册 多选 */
	function media_album(){
	    YTF.mediaGetPicture({
	        sourceType:"album",
	        isCheckbox:false
	    }, function(ret, err){
            if(ret){
                 var imgArr=[];
                 imgArr = ret.imagePath;
                nimingAjaxUpload(uploadUrl,imgArr)
            }else{
                 alert(JSON.stringify(ret));
            }
        });
	}