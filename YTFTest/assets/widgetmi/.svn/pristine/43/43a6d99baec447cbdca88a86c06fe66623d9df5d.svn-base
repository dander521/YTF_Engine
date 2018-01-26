/**调用本地相册*/
	function media_album(){
	    YTF.mediaGetPicture({
	        sourceType:"album"
	    });
	}
	/**调用本地相册 多选 */
	function media_albums(){
	    YTF.mediaGetPicture({
	        sourceType:"album",
	        isCheckbox:true
	    }, function(ret, err){
            if(ret){
                 alert(ret);
            }else{
                 alert(err);
            }
        });
	}