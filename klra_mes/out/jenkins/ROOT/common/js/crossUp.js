
/**
* NamoCrossUploader 객체를 생성합니다. 
*/
var embedNamoCrossUploader = function (id, swfUrlStr, replaceElemIdStr, widthStr, heightStr, bgColor, wmode, flashvars) {
	
    // For version detection, set to min. required Flash Player version, or 0 (or 0.0.0), for no version detection. 
    var swfVersionStr = "11.1.0";
    // To use express install, set to playerProductInstall.swf, otherwise the empty string.
    var xiSwfUrlStr = "/crossuploder/NamoCrossUploaderFxSamples/bin/playerProductInstall.swf";
    flashvars.defaultLanguage = ["ko", "false"]; // Default Language 정보를 입력해 주십시오.
    var params = {};
    params.quality = "high";
    params.bgcolor = bgColor;
    params.allowscriptaccess = "sameDomain";
    params.allowfullscreen = "true";
    params.wmode = (wmode != "") ? wmode : "window";
    var attributes = {};
    attributes.id = id;
    attributes.name = id;
    attributes.align = "middle";

    swfobject.embedSWF(
        swfUrlStr,
        replaceElemIdStr,
        widthStr,
        heightStr,
        swfVersionStr,
        xiSwfUrlStr,
        flashvars,
        params,
        attributes);

    // JavaScript enabled so display the flashContent div in case it is not replaced with a swf object.
    swfobject.createCSS("#"+replaceElemIdStr, "display:block;text-align:left;");
}


var getUploadManagerVars = function () {
    var flashvars = {};

	/**
	* NamoCrossUploader 객체에서 Javascript로 전송할 이벤트 함수 이름을 설정합니다.
	* flashvars 객체의 프로퍼티 값을 변경하면 이벤트 함수 이름이 변경되며, 이벤트 함수 이름은 Javascript에 정의되어 있어야 정상적으로 호출됩니다.
	* 사용하지 않는 이벤트는 주석 처리해 주십시오.  
	*/
    flashvars.onCreationComplete	= "onCreationCompleteCu";    // NamoCrossUploader Manager 객체 생성 완료 시
	flashvars.onOpenMonitorWindow   = "onOpenMonitorWindowCu";   // 전송 창 출력 시
	flashvars.onCloseMonitorWindow  = "onCloseMonitorWindowCu";  // 전송 창 종료 시
    flashvars.onStartUpload         = "onStartUploadCu";         // 업로드 시작 시
    flashvars.onEndUpload			= "onEndUploadCu";			 // 업로드 완료 시
    flashvars.onStartUploadItem     = "onStartUploadItemCu";     // 개별 파일의 업로드 시작 시
    flashvars.onEndUploadItem		= "onEndUploadItemCu";       // 개별 파일의 업로드 완료 시
	flashvars.onCancelUploadItem    = "onCancelUploadItemCu";    // 개별 파일의 업로드 취소 시
    flashvars.onException			= "onExceptionCu";           // 예외 발생 시


	/**
	* 언어 정보가 담겨있는 파일의 URL을 입력해 주십시오. 파일명은 변경 가능합니다.
	*/
	flashvars.languageUrl			= "/crossuploder/NamoCrossUploaderFxSamples/bin/FileUploadManagerLang.xml"; 

    return flashvars;
}

var getUploadMonitorVars = function () {
    var flashvars = {};

	/**
	* NamoCrossUploader 객체에서 Javascript로 전송할 이벤트 함수 이름을 설정합니다.
	* flashvars 객체의 프로퍼티 값을 변경하면 이벤트 함수 이름이 변경되며, 이벤트 함수 이름은 Javascript에 정의되어 있어야 정상적으로 호출됩니다.
	* 사용하지 않는 이벤트는 주석 처리해 주십시오. Javascript 내에 이벤트 이름과 동일한 사용자 함수가 존재하지 않을 경우 그대로 두셔도 무방합니다.  
	*/
    flashvars.onCreationComplete	= "onCreationCompleteMntCu";    // NamoCrossUploader Monitor 객체 생성 완료 시

	/**
	* 언어 정보가 담겨있는 파일의 URL을 입력해 주십시오. 파일명은 변경 가능합니다.
	*/
	flashvars.languageUrl			= "/crossuploder/NamoCrossUploaderFxSamples/bin/FileUploadMonitorLang.xml"; 

    return flashvars;
}

var getDownloadManagerVar = function () {
    var flashvars = {};

	/**
	* NamoCrossDownloader 객체에서 Javascript로 전송할 이벤트 함수 이름을 설정합니다.
	* flashvars 객체의 프로퍼티 값을 변경하면 이벤트 함수 이름이 변경되며, 이벤트 함수 이름은 Javascript에 정의되어 있어야 정상적으로 호출됩니다.
	* 사용하지 않는 이벤트는 주석 처리해 주십시오.
	*/
    flashvars.onCreationComplete     = "onCreationCompleteCd";       // NamoCrossDownloader Manager 객체 생성 완료 시
    flashvars.onStartDownloadItem    = "onStartDownloadItemCd";      // 개별 파일의 다운로드 시작 시 (Single Download Only)
    flashvars.onEndDownloadItem		 = "onEndDownloadItemCd";        // 개별 파일의 다운로드 완료 시 (Single Download Only)
    flashvars.onCancelDownloadItem   = "onCancelDownloadItemCd";     // 개별 파일의 다운로드 취소 시 (Single Download Only)
    flashvars.onException            = "onExceptionCd";              // 예외 발생 시

	/**
	* 언어 정보가 담겨있는 파일의 URL을 입력해 주십시오. 파일명은 변경 가능합니다.
	*/
	flashvars.languageUrl			= "/crossuploder/NamoCrossUploaderFxSamples/bin/FileDownloadManagerLang.xml"; 
	flashvars.languageUrlForAIR		= getAbsolutePath("bin") + "FileDownloadMonitorAIRLang.xml"; 
	//flashvars.languageUrlForAIR		= "http://localhost:8080/NamoCrossUploaderFxSamples/bin/FileDownloadMonitorAIRLang.xml"; 

    return flashvars;
}

/**
* NamoCrossUploader 객체가 생성되지 않았을 경우 Flash 다운로드 링크가 활성화 되도록 설정합니다.
*/
var checkNamoCrossUploader = function (id, flashContentId) {
	if(document.getElementById(id) == null) {
		document.getElementById(flashContentId).style.display = "block";
		return false; 
	}
	return true; 
}

/**
* NamoCrossUploader 객체를 생성합니다.
*/
var createNamoCrossUploader = function (managerId, monitorId, flashContentManagerId, flashContentMonitorId) { 
    // Manager 객체 생성 
    embedNamoCrossUploader(
                managerId,                                  // NamoCrossUploader의 Manager 객체 Id
                "/crossuploder/NamoCrossUploaderFxSamples/bin/BasicFileUploadManager.swf",     // NamoCrossUploader의 Manager 객체 파일(swf)의 URL 
                flashContentManagerId,                      // 플래쉬 컨텐트로 변경될 HTML 컨텐츠 Id
                436,                                        // 가로 사이즈    
                280,                                        // 세로 사이즈    
                "#FFFFFF",                                  // NamoCrossUploader 컴포넌트 로딩 전 배경화면색
                "transparent",                              // 플래시 wmode 설정 (배경 투명, z-index의 영향을 받도록 설정)
                getUploadManagerVars()                      // Javascript로 전송할 이벤트 함수 이름과 기타 환경 변수
                );

	if(checkNamoCrossUploader(managerId, flashContentManagerId) == false)
		return; 

    // Monitor 객체 생성 
    embedNamoCrossUploader(
                monitorId,                                  // NamoCrossUploader의 Manager 객체 Id
                "/crossuploder/NamoCrossUploaderFxSamples/bin/BasicFileUploadMonitor.swf",     // NamoCrossUploader의 Manager 객체 파일(swf)의 URL  
                flashContentMonitorId,                      // 플래쉬 컨텐트로 변경될 HTML 컨텐츠 Id
                610,                                        // 가로 사이즈    
                358,                                        // 세로 사이즈    
                "#FFFFFF",                                  // NamoCrossUploader 컴포넌트 로딩 전 배경화면색
                "transparent",                              // 플래시 wmode 설정 (배경 투명, z-index의 영향을 받도록 설정)
				getUploadMonitorVars()						// Javascript로 전송할 이벤트 함수 이름과 기타 환경 변수
                );
}

/**
* SimpleNamoCrossUploader 객체를 생성합니다.
*/
var createSimpleNamoCrossUploader = function (managerId, flashContentManagerId) { 
    // SimpleNamoCrossUploader 객체 생성 
    embedNamoCrossUploader(
                managerId,                                  // NamoCrossUploader의 Manager 객체 Id
                "/crossuploder/NamoCrossUploaderFxSamples/bin/SimpleFileUploadManager.swf",    // NamoCrossUploader의 Manager 객체 파일(swf)의 URL
                flashContentManagerId,						// 플래쉬 컨텐트로 변경될 HTML 컨텐츠 Id
                436,                                        // 가로 사이즈    
                280,                                        // 세로 사이즈    
                "#FFFFFF",                                  // NamoCrossUploader 컴포넌트 로딩 전 배경화면색
                "transparent",                              // 플래시 wmode 설정 (배경 투명, z-index의 영향을 받도록 설정)
                getUploadManagerVars()                      // Javascript로 전송할 이벤트 함수 이름과 기타 환경 변수
                );

	checkNamoCrossUploader(managerId, flashContentManagerId); 
}


/**
* NamoCrossDownloader 객체를 생성합니다.
*/
var createNamoCrossDownloader = function (managerId, flashContentManagerId, isSingle) {
    var swfUrl = "/crossuploder/NamoCrossUploaderFxSamples/bin/SingleFileDownloadManager.swf";
    if (isSingle == false)
        swfUrl = "/crossuploder/NamoCrossUploaderFxSamples/bin/MultipleFileDownloadManager.swf";

    // Manager 객체 생성 
    embedNamoCrossUploader(
                managerId,                          // NamoCrossDownloader의 Manager 객체 Id
                swfUrl,                             // NamoCrossDownloader의 Manager 객체 파일(swf)의 URL 
                flashContentManagerId,              // 플래쉬 컨텐트로 변경될 HTML 컨텐츠 Id
                436,                                // 가로 사이즈    
                280,                                // 세로 사이즈    
                "#FFFFFF",                          // NamoCrossDownloader 컴포넌트 로딩 전 배경화면색
                "transparent",                      // 플래시 wmode 설정 (배경 투명, z-index의 영향을 받도록 설정)
                getDownloadManagerVar()             // Javascript로 전송할 이벤트 함수 이름과 기타 환경 변수
                );
	
	checkNamoCrossUploader(managerId, flashContentManagerId);
}


/**
* 현재 HTTP 경로를 알아오기 위한 함수입니다. (샘플을 위한 것으로 필요 없을 경우 삭제)
*/ 
var getCurrentPath = function () {
	var url = window.location.protocol + "//" + window.location.host;		
	var pos = window.location.pathname.lastIndexOf("/"); 
	if(pos == -1)
		url += "/";
	else 
		url += (window.location.pathname.substring(0, pos+1)); 

	return url; 
}

/**
* 샘플의 디렉토리 경로를 알아오기 위한 함수입니다. (샘플을 위한 것으로 필요 없을 경우 삭제)
* 샘플의 NamoCrossUploaderFxSamples 디렉토리 구성을 임의로 변경할 경우, 아래 함수는 수정이 필요합니다. 
*/ 
var getAbsolutePath = function (dirName) {
	var url = location.href; 				
	var pos = url.lastIndexOf("/NamoCrossUploaderFxSamples/"); 
	if(pos != -1) 
		url = url.substring(0, pos+("/NamoCrossUploaderFxSamples/").length); 
	else
		return ""; 

	url = url + dirName + "/"
	return url; 
}

/**
* 샘플의 디렉토리 경로를 알아오기 위한 함수입니다. (샘플을 위한 것으로 필요 없을 경우 삭제)
* 샘플의 NamoCrossUploaderFxSamples 디렉토리 구성을 임의로 변경할 경우, 아래 함수는 수정이 필요합니다. 
*/ 
var getAbsolutePathNoProtocol = function (dirName) {
	var url = location.href; 				
	var pos = url.lastIndexOf("/NamoCrossUploaderFxSamples/"); 
	if(pos != -1) 
		url = url.substring(0, pos+("/NamoCrossUploaderFxSamples/").length); 
	else
		return ""; 

	url = url + dirName + "/"
	
	var protocol = window.location.protocol + "//" + window.location.host;
	url = url.substring(protocol.length);
	
	return url; 
}

/**
 * 입력받은 URL 을 , 절대경로(full url)로 변경하여 반환합니다. 
 *  - setUploadUrl 과 함께 사용되며, 본 function 을 사용하지 않으면 Chrome 에서 target URL 설정시, swf 파일 대비 상대경로로 입력해야만 정상동작합니다.
 *  - full url 이 입력된 경우는 별도 처리 없이 입력된 값 자체를 반환합니다.
 */
var getAbsoluteUrl = function(path){
	if(path){
		if(!/^http[s]*\:\/\//.test(path)) {
			var basepath = location.pathname.substr(0,location.pathname.lastIndexOf('/')+1);
			if(path.indexOf('./')==0) {
				path = path.replace('./','');
			} else if(path.indexOf('/')==0) {
				basepath = '';
			}
			path = basepath + path;
		}
	}
	return path;
}


/**
* NamoCrossUploader의 Manager, Monitor 객체
*/
var cuManager = null;
var cuMonitor = null;  

/**
* NamoCrossUploader의 Manager 객체 생성 완료 시 호출됩니다.
*/
var onCreationCompleteCu = function () {
    cuManager = document.getElementById("crossUploadManager");
    // upload url 설정
    cuManager.setUploadURL("/crossuploder/UploadProcess.jsp");
    //cuManager.setUploadURL(getCurrentPath() + "UploadProcess.jsp"); 
	//cuManager.setUploadURL("http://localhost:8080/NamoCrossUploaderFxSamples/SettingUI/SettingUploadUI/UploadProcess.jsp"); 
}

/**
* NamoCrossUploader의 Monitor 객체 생성 완료 시 호출됩니다.
*/
var onCreationCompleteMntCu = function () {
    cuManager.setMonitorResources(document.getElementById("crossUploadMonitor").getMonitorResources()); 
}

/** 
* 전송창이 열릴 때 호출됩니다.
*/ 
var onOpenMonitorWindowCu = function () {
	window.focus(); 
    document.getElementById("monitorBgLayer").style.display = "block";
    document.getElementById("monitorLayer").style.display = "block";
}

/** 
* 전송창이 닫힐 때 호출됩니다.
*/ 
var onCloseMonitorWindowCu = function () { 
	window.focus(); 
    document.getElementById("monitorBgLayer").style.display = "none";
    document.getElementById("monitorLayer").style.display = "none";    

	// 데이터 처리 페이지로 업로드 결과를 전송합니다. 
	// onEndUploadCu 나 onCloseMonitorWindowCu 이벤트 시점에 처리하시면 되며, onCloseMonitorWindowCu 시에는 getUploadStatus()를 사용하여 업로드 상태를 체크해 주십시오.
	if(cuManager.getUploadStatus() == "COMPLETE") {
		/**
		* 업로드된 전체 파일의 정보를 가져옵니다. 
		* 서버측에서 JSON 타입으로 반환했을 경우는 JSON 타입으로 가져오는 것을 권장하며, 그 외의 경우는 개별 파일 정보를 조합할 delimiter 문자(또는 문자열)를 입력해 주십시오.
		*/
		var uploadedFilesInfo = cuManager.getUploadedFilesInfo("JSON"); 
		//var uploadedFilesInfo = cuManager.getUploadedFilesInfo("|"); 
		
		alert(JSON.stringify(uploadedFilesInfo));

		/**
        * 필요 시, 아래처럼 사용해 주십시오. (JSON으로 넘오올 경우)
		var obj = jQuery.parseJSON(uploadedFilesInfo); 
		alertTimeout(obj.length); 
		alertTimeout(obj[0].Name); 
		*/
		
		// 데이터 처리 페이지로 업로드 결과를 전송합니다.
		//document.dataForm.uploadedFilesInfo.value = uploadedFilesInfo; 
		//document.dataForm.submit(); 
	}
}

/**
* 예외 발생 시 호출됩니다.
*/ 
var onExceptionCu = function (params) {
    // 300~ : 일반적 예외
    // 400~ : 시스템 예외
    // 500~ : 서측에서 발생한 예외
    // 필요한 예외정보만 고객에서 보여주십시오.
	var obj = jQuery.parseJSON(params); 
	alertTimeout("[예외 정보]\n" + "code : " + obj.code + "\n" + "message : " + obj.message + "\n" + "detailMessage : " + obj.detailMessage); 
	
} 

/**
* 개별 파일에 대한 업로드 완료 시 호출됩니다. 
* 인자로 넘어온 데이터는 서버측(UploadProcess.jsp)에서 조합한 형태의 문자열입니다.
* 샘플에서는 JSON 타입으로 넘겨주고 있습니다. 
* 필요할 경우, 주석을 풀고 사용해 주십시오. 
*/ 
var onEndUploadItemCu = function (params) { 
	/*
	var obj = jQuery.parseJSON(params); 
	alertTimeout("[개별 파일에 대한 업로드 결과 정보]\n" + 
		"Name : "					+ obj.name + "\n" +
		"FileName : "				+ obj.fileName + "\n" +
		"LastSavedDirectoryPath : " + obj.lastSavedDirectoryPath + "\n" +
		"LastSavedFilePath : "		+ obj.lastSavedFilePath + "\n" +
		"LastSavedFileName : "		+ obj.lastSavedFileName + "\n" +
		"FileSize : "				+ obj.fileSize + "\n" +
		"FileNameWithoutFileExt : " + obj.fileNameWithoutFileExt + "\n" +
		"FileExtension : "			+ obj.fileExtension + "\n" +
		"ContentType : "			+ obj.contentType + "\n" +
		"IsSaved : "				+ obj.isSaved + "\n" +
		"IsEmptyFile : "			+ obj.isEmptyFile
	); 
	*/
}

/**
* 업로드 완료 시 호출됩니다. 
*/
var onEndUploadCu = function () { 
	// alertTimeout("업로드가 완료됐습니다."); 
} 

/* UI Properties 변경 */
var resetUIProperties = function () { 
	var width = document.getElementById("cuManagerW").value; 
	var height = document.getElementById("cuManagerH").value; 
	var borderColor = document.getElementById("borderColor").value; 
	var visibleUploadButton = (document.getElementsByName("visibleUploadButton")[0].checked == true) ? true : false;
	var enableUploadButton = (document.getElementsByName("enableUploadButton")[0].checked == true) ? true : false; 
	var closeMonitorAfterTransferCompleted = (document.getElementsByName("closeMonitorAfterTransferCompleted")[0].checked == true) ? true : false; 		

	// UI 프로퍼티를 설정합니다.
	var uiProperties = {
	    "width": width,
		"height": height,
		"borderColor": borderColor,
		"visibleUploadButton": visibleUploadButton,
		"enableUploadButton": enableUploadButton,
		"closeMonitorAfterTransferCompleted": closeMonitorAfterTransferCompleted
	};
    cuManager.setUIProperties(uiProperties);

	// HTML 내의 Flash 영역을 변경합니다.
	cuManager.width = Number(width); 
	cuManager.height = Number(height); 

	// flash 내의 업로드 버튼의 visible, enabled 상태에 따라 html 버튼의 visibility 설정
	if(visibleUploadButton == false || enableUploadButton == false) 
		document.getElementById("startUpload").style.visibility="visible";
	else
		document.getElementById("startUpload").style.visibility="hidden";			
}

/* NamoCrossUploader의 업로드 버턴이 invisible 또는 disable 됐을 때 HTML 내에서 직접 업로드를 시작 */
var onStartUpload = function () { 
	cuManager.startUpload(); 
}

/**
* Flash로부터 호출되는 Javascript 콜백함수 내에서 alert 창을 띄우기 위한 처리로 Chrome, Firefox, Safari 브라우저의 일부 버전에 해당됩니다. 
*/
var alertTimeout = function (params) {
    window.focus();
    setTimeout(function () { alert(params) }, 100);
}