//初期化処理
var refreshTimer;

//メインメニュー表示関数用
var openedMenu = null;
var submenuTimer;

function menuPopup(id){
	if (openedMenu && openedMenu != id){
		closeMenu(id);
	}
	openMenu(id);
}

//レイヤメニューの表示
function openMenu(id){ 
	$(id).style.display = 'block';
	clearTimeout(submenuTimer);
	openedMenu = id;
}

//レイヤメニューを隠す
function closeMenu(){
	$(openedMenu).style.display = 'none';
	openedMenu = null;
}

/***********************************************************
	移動系
************************************************************/
function selfAction(URL){ 
	self.location.href=URL;
}
function parentAction(URL){ 
	parent.location.href=URL;
}

/*********************************************************
	確認ダイアログを出す
*********************************************************/
function checkDialog(URL,str){
	if(confirm(str)){
		parent.location.href=URL;
	}else{
		return 0;
	}
}

/***********************************************************
	削除確認
************************************************************/
function deleteEvent(URL){
	if(confirm("本当に削除してもいいですか？")){
		parent.location.href=URL;
	}else{
		return 0;
	}
}
function deleteSelfEvent(URL){
	if(confirm("本当に削除してもいいですか？")){
		self.location.href=URL;
	}else{
		return 0;
	}
}
function deleteComment(url,message){
	if(message != ""){
		var afterMessage = "";
		messageArray = message.split("<br />");
		for(i = 0;i < messageArray.length;i++){
			if(i != 0){
				afterMessage += "\n";
			}
			afterMessage += messageArray[i];
		}
		if(confirm(afterMessage)){
			parent.location.href=url;
		}else{
			return 0;
		}
	}
}

/*********************************************************
	別ウィンドウを開く
*********************************************************/
function openWindow(URL){
	window.open(URL,"","scrollbars=1,resizable=1");
}

function openFullWindow(URL){
	var examinationWindow;
	myX = screen.width;
	myY = screen.height;
	myAgent = navigator.userAgent;
	if(myAgent.indexOf("Win") != -1){//Windows
		if(myAgent.indexOf("Firefox") != -1){//firefox
			myOption = "top=0,left=0,screenX=0,screenY=0,width="+myX+",height="+myY+",scrollbars=yes,resizable=no";
		}else if(myAgent.indexOf("Netscape") != -1){//Netscape
			myOption = "top=0,left=0,screenX=0,screenY=0,width="+myX+",height="+myY+",scrollbars=yes,resizable=no";
		}else{//それ以外
			myOption = "fullscreen=1,scrollbars=0";
		}
	}else{//Mac
		myOption = "top=0,left=0,screenX=0,screenY=0,width="+myX+",height="+myY+",scrollbars=yes,resizable=no";
	}
	examinationWindow = window.open(URL,"subWin",myOption);
	examinationWindow.focus();
}

/*********************************************************
	ボタンを非表示にする
	Target:	ロックするＩＤ
	Count:	ループ回数
*********************************************************/
function lock(Target,Count){
	if(Count == "0"){
		document.getElementById(Target).disabled=true;
	}else{
		for(i = 0;i < Count;i++){
			document.getElementById(Target+i).disabled=true;
		}
	}
}

/*********************************************************
	Cookie
*********************************************************/
function readCookie(cookie) {
	var data = [];
	var cookies = cookie.split("; ");
	for (var i=0; i<cookies.length; i++) {
		var str = cookies[i].split("=");
		data[str[0]] = str[1];
	}
	return data;
}
