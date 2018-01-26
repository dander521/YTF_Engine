var JPush = {
eventName:"send",//回调时间的类型，字符串类型，取值范围如下
//send:点击发送按钮
//clickExpand:点击扩展面板的狂战项事件，该事件还会返回index字段，标明点击的扩展面板的下标
//openSuccess:模块视图成功打开
	index:0,//点击扩展面板扩展项的回调的下标。用来标识点击了哪个扩展项。仅在clickExpand事件下有效。
msg:"发送的内容"//当事件为send时，返回输入框的内容。
};
