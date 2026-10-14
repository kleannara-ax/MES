var clsto = 0;
var clProjtlist = [];
site.gridSearchHelpEnter=false;
$(document).ready(function(){

    if($('#S_PROJT_CD.nodate').length){
        cl.searchInit();
        var json = netUtil.sendData({
            module : 'CLCOM',
            command : 'CLCOM_PROJT_NODATE',
        });
        clProjtlist = json.data;
        //commonUtil.addItemList($('#S_PROJT_NM'),clProjtlist,'PROJT_CD','PROJT_NM');
        cl.addItemList($('#S_PROJT_CD.nodate'),clProjtlist,'PROJT_CD','SPS_PROJT_NM');
    } else {
        cl.searchInit();
        var json = netUtil.sendData({
            module : 'CLCOM',
            command : 'CLCOM_PROJT',
        });
        clProjtlist = json.data;
        //commonUtil.addItemList($('#S_PROJT_NM'),clProjtlist,'PROJT_CD','PROJT_NM');
        cl.addItemList($('#S_PROJT_CD'),clProjtlist,'PROJT_CD','SPS_PROJT_NM');
    }


});
var cl = {
    searchInit:function(){
        //프로젝트유형변경


        $('#S_REQUEST_KND_GB').change(function(){
            //프로벡트코드 리셋
            $('#S_PROJT_CD').val('');
            $('#S_PROJT_NM').val('');
            $('#H_PROJT_NM').val('');
            $('#H_SPS_NM').val('');
            var searchAreaParam = inputList.setRangeParam("searchArea");
            $.each(Object.keys(searchAreaParam.get('RANGE_DATA_PARAM').map),function(k,v){

                if(v!='PRGR_ST_Single'){
                    searchAreaParam.get('RANGE_DATA_PARAM').remove(v);
                }
            });
            if($('#S_PROJT_CD.nodate').length){
                cl.getClCode($('#S_PROJT_CD'),'CLCOM_PROJT_NODATE',searchAreaParam,'PROJT_CD','SPS_PROJT_NM');
            } else {
                cl.getClCode($('#S_PROJT_CD'),'CLCOM_PROJT',searchAreaParam,'PROJT_CD','SPS_PROJT_NM');
            }

        });
        $('#S_PROJT_NM,#searchArea input[type=text]').not('.searchInput').keypress(function(e){
            if(!$(this).is('.searchInput')){
                if(e.keyCode==13){
                    $('#S_PROJT_NM').keyup();
                    commonBtnClick('Search');
                    return false;
                }
            }
        });
        $('#S_PRGR_ST').change(function(){
            $('#S_REQUEST_KND_GB').change();
        })
        //프로젝트코드
        $('#S_PROJT_NM').keyup(function() {
            var protjNm = $('#S_PROJT_NM').val();

            $('#H_PROJT_NM').val('');
            $('#H_SPS_NM').val('');

            var postJson = inputList.setRangeParam("searchArea");

            if(protjNm.indexOf('/')>-1){
                var protjNmSplit = protjNm.split('/');
                postJson.put('SPS_NM', protjNmSplit[0]);
                postJson.put('PROJT_NM', protjNmSplit[1]);
                $('#H_SPS_NM').val(protjNmSplit[0]);
                $('#H_PROJT_NM').val(protjNmSplit[1]);

            } else {
                postJson.put('PROJT_NM',protjNm);
                $('#H_PROJT_NM').val(protjNm);
            }
            clearTimeout(clsto);

            postJson.put('REQUEST_KND_GB',$('#S_REQUEST_KND_GB').val());

            $.each(Object.keys(postJson.get('RANGE_DATA_PARAM').map),function(k,v){
                if(v!='PRGR_ST_Single'){
                    postJson.get('RANGE_DATA_PARAM').remove(v);
                }
            });

            clsto = setTimeout(function(){
                if($('#S_PROJT_CD.nodate').length){
                    cl.getClCode($('#S_PROJT_CD'),'CLCOM_PROJT_NODATE',postJson,'PROJT_CD','SPS_PROJT_NM');
                } else {
                    cl.getClCode($('#S_PROJT_CD'),'CLCOM_PROJT',postJson,'PROJT_CD','SPS_PROJT_NM');
                }
            },200);

        });
        $('#S_PROJT_CD').change(function(){
            $('#S_PROJT_NM').val('');
            $('#H_PROJT_NM').val('');
            $('#H_SPS_NM').val('');
            if($.trim($('#S_PROJT_CD').val())==''){
                $('#S_PROJT_NM').keyup();
            }
        })
        //프로젝트명
        // cl.getClCode($('#S_PROJT_CD'),'CLCOM_PROJT',{REQUEST_KND_GB:$('#S_REQUEST_KND_GB').val()},'PROJT_CD','PROJT_NM').unbind('change').change(function(){
        //     $('#S_PROJT_NM').val('');
        //     //$('#S_PROJT_CD').val(commonUtil.getCode('CLCOM_CLCOM_PROJT',$('#S_PROJT_NM').val(),'PROJT_CD'));
        //     $('#S_REQUEST_KND_GB').val(commonUtil.getCode('CLCOM_CLCOM_PROJT',$('#S_PROJT_CD').val(),'REQUEST_KND_GB'));
        // });
    },
    txtdownload:function(filename, text) {

        if($.trim(filename).indexOf('.csv')>-1){
            var pom = document.createElement('a');
            var blob = new Blob(["\ufeff"+text], {type: 'text/csv;charset=utf-8;'});
            var url = URL.createObjectURL(blob);
             pom.href = url;
             pom.setAttribute('download',filename);
             pom.click();
        }else {
            var element = document.createElement('a');
              element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
              element.setAttribute('download', filename);

              element.style.display = 'none';
              document.body.appendChild(element);

              element.click();

              document.body.removeChild(element);
        }

    },
    bytesToSize:function(bytes) {
       var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
       if (bytes == 0) return '0 Byte';
       var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
       return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
    },
    getByte:function(s){
        var stringByteLength = (function(s,b,i,c){
            for(b=i=0;c=s.charCodeAt(i++);b+=c>>11?3:c>>7?2:1);
            return b
        })(s);
        return stringByteLength;
    },
	cutByteLength : function(s, len) {

		if (s == null || s.length == 0) {
			return 0;
		}
		var size = 0;
		var rIndex = s.length;

		for ( var i = 0; i < s.length; i++) {
			size += this.charByteSize(s.charAt(i));
			if( size == len ) {
				rIndex = i + 1;
				break;
			} else if( size > len ) {
				rIndex = i;
				break;
			}
		}
		return s.substring(0, rIndex);
	},
	charByteSize : function(ch) {

		if (ch == null || ch.length == 0) {
			return 0;
		}

		var charCode = ch.charCodeAt(0);

		if (charCode <= 0x00007F) {
			return 1;
		} else if (charCode <= 0x0007FF) {
			return 2;
		} else if (charCode <= 0x00FFFF) {
			return 3;
		} else {
			return 4;
		}
	},
    getClCode:function(thisObj,command,jsonParam,VALUE_COL,TEXT_COL){
        var exModule = command.split('_');
        var module = exModule[0];
        if(!VALUE_COL) {
            VALUE_COL = configData.INPUT_COMBO_VALUE_COL;
        }
        if(!TEXT_COL) {
            TEXT_COL = configData.INPUT_COMBO_TEXT_COL;
        }
        if(!jsonParam) jsonParam = {};
        var param = new DataMap();

        if(jsonParam instanceof DataMap){
            param = jsonParam;
        } else {
            if(Object.keys(jsonParam).length>0){
                $.each(jsonParam,function(k,v){
                    param.put(k,v);
                })
            }
        }
        var expCommend = command.split('_');
        var sendType = expCommend[expCommend.length-1];

        if(sendType!='LIST' && sendType!='COMBO' ){
            sendType = 'list';
        }

        var json = netUtil.sendData({
            module : module,
            command : command,
            param:param,
            sendType: sendType.toLowerCase()
        });
        var comboDataMap = {};
        var exCode = [module,command].join('_');

        try {
            inputList.comboDataMap.put(exCode,json['data']);
            cl.addItemList(thisObj,json['data'],VALUE_COL,TEXT_COL,exCode);
        } catch(ex) {

        }

        return $(thisObj);
    },
    /**  CL
     * 엘리먼트생성
     * @param nodeName
     * @param val
     * @param attr
     * @returns {jQuery.fn.init|jQuery|HTMLElement|*}
     */
    makeElement:function(nodeName,val,attr){
		var el = null;
		if(nodeName=='input' || nodeName=='img' || nodeName=='col'){
			el = $('<'+nodeName+' />');
		} else {
			el = $('<'+nodeName+'></'+nodeName+'>');
		}
		if(val){
			if(nodeName=='input'||nodeName=='textarea') el.val(val);
			else el.html(val);
		}
		if(attr){
			this.makeAttr(el,attr);
		}
		return el;
	},
    addItemList:function(thisObj,jArray,key,val,combomapid,empty,showcode){
		if(empty==undefined)empty=true;
		if(showcode==undefined)showcode=true;
		var target =$(thisObj).prop('nodeName')=='SELECT'?$(thisObj):$(thisObj).find('select');
		target.empty();
		var viewText = '';
		if($.trim($(thisObj).attr('viewtext'))){
		   viewText= $.trim($(thisObj).attr('viewtext')); 
        }
		if($(thisObj).attr('allView')=='false'||$(thisObj).attr('allview')=='false'){
            empty=false;
        }

		if(empty){
		    if(document.URL.substr(document.URL.indexOf('.page')-6,2)=='CL'){
		        target.append(cl.makeElement('option','선택',{value:''}));
            } else {
		        target.append(cl.makeElement('option',viewText||'전체',{value:''}));
            }

		}
		var addCodeView = true;
		if($(thisObj).attr('ComboCodeView')=='false'||$(thisObj).attr('combocodeview')=='false'){
		    addCodeView=false;
        }

		if(jArray.length)
		{
		    var inJson = {}
			$.each(jArray,function(i,v){
			    inJson[v[key]]=v;


				target.append(cl.makeElement('option',(addCodeView?('['+v[key]+']'):(''))+v[val],{value:v[key]}));
			});
			inputList.comboMap.map[combomapid+'_MAP'] = inJson;
			inputList.comboMap.map[combomapid] = target.html();
		}
		else {
		}
		return $(target);
	},
    addList:function(pDataMap,command,sendType,listObj,origListObj) {
        if(!origListObj) origListObj = [];
        //cl.ajax.rebind();
        var bindKey = [command,sendType.toUpperCase(),'LIST'].join('.');
        //cl.ajax.paramSort.push(bindKey);
        if(pDataMap.get('listModule')){
            pDataMap.put('listModule',[pDataMap.get('listModule'),bindKey].join(','))
        } else {
            pDataMap.put('listModule',[bindKey].join(','))
        }

        pDataMap.put((command+'_'+sendType).toUpperCase(),listObj);
        //pDataMap.put((command+'_'+sendType).toUpperCase(),origListObj);
    },
    addMap:function(pDataMap,command,sendType,mapObj,origMapObj){
        if(!origMapObj) origMapObj = new DataMap();
        //cl.ajax.rebind();
        var bindKey = [command,sendType.toUpperCase(),'MAP'].join('.');

        if(pDataMap.get('listModule')){
            pDataMap.put('listModule',[pDataMap.get('listModule'),bindKey].join(','))
        } else {
            pDataMap.put('listModule',[bindKey].join(','))
        }
        pDataMap.put((command+'_'+sendType).toUpperCase(),mapObj);


        //pDataMap.put((command+'_'+sendType).toUpperCase(),mapObj);//
    },
    cllog:function(text){
        console.log('전송데이터 ',text)
    },
    dataSendSet:function(pDataMap,id,gridsplit,param){
        if(!gridsplit) gridsplit='';
        if(!id) id ='AJAX';
        pDataMap.put('ID',id);
        pDataMap.put('GRIDSPLIT',gridsplit);
        if(param)
        pDataMap.put('param',param);



    },
    fileDownload : function(uuid) {
		if(!uuid){
			return;
		}
		jQuery("#fileDownloadForm").remove();

		// 비동기 전달을 위해 전달에 필요한 파라메터에 각 값들은 jsonString형태로 전송한다.
		var formHtml = "<form action='/GCCL/CL/fileDown/file.data' method='post' id='fileDownloadForm'>"
					 + "<input type='text' name='UUID' value='"+uuid+"' />"
					 + "</form>";
		jQuery(formHtml).hide().appendTo('body');
		jQuery("#fileDownloadForm").submit();
	},
    // format:function(objValue,formatter){
    //     if (!objValue.valueOf()) return "";
    //     try {
    //         if(typeof(objValue)=='string') {
    //
    //             var theString = objValue;
    //
    //             // start with the second argument (i = 1)
    //             for (var i = 1; i < arguments.length; i++) {
    //                 // "gm" = RegEx options for Global search (more than one instance)
    //                 // and for Multiline search
    //                 var regEx = new RegExp("\\{" + (i - 1) + "\\}", "gm");
    //                 theString = theString.replace(regEx, arguments[i]);
    //             }
    //
    //             return theString;
    //         } else  if(typeof(objValue)=='object') {
    //              if ((objValue.valueOf()+"").length==13){
    //                  var weekName = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
    //                  var weekSName = ["일", "월", "화", "수", "목", "금", "토"];
    //                  var d = objValue;
    //
    //                  return formatter.replace(/(yyyy|yy|MM|dd|E|K|hh|mm|ss|a\/p)/gi, function($1) {
    //                      switch ($1) {
    //                          case "yyyy": return d.getFullYear();
    //                          case "yy": return (d.getFullYear() % 1000).zf(2);
    //                          case "MM": return (d.getMonth() + 1).zf(2);
    //                          case "dd": return d.getDate().zf(2);
    //                          case "E": return weekName[d.getDay()];
    //                          case "K": return weekSName[d.getDay()];
    //                          case "HH": return d.getHours().zf(2);
    //                          case "hh": return ((h = d.getHours() % 12) ? h : 12).zf(2);
    //                          case "mm": return d.getMinutes().zf(2);
    //                          case "ss": return d.getSeconds().zf(2);
    //                          case "a/p": return d.getHours() < 12 ? "오전" : "오후";
    //                          default: return $1;
    //                      }
    //                  });
    //              }
    //         }
    //     } catch(ex){
    //
    //     }
    //     return objValue;
    //
    // },
    // /**
    //  * 한글초성 분석
    //  * placeholder 생성할때 사용
    //  * ex) 메뉴경로 마지막글자 로에 받침이 있는지 찾는용도
    //  * @returns {Array}
    //  */
    // toKorChars : function(str) {
    //     var cCho = ['ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']
    //         ,
    //         cJung = ['ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ', 'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ']
    //         ,
    //         cJong = ['', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ']
    //         , cho, jung, jong;
    //     var cnt = str.length, chars = [], cCode;
    //     for (var i = 0; i < cnt; i++) {
    //         cCode = str.charCodeAt(i);
    //         if (cCode == 32) {
    //             continue;
    //         }
    //         // 한글이 아닌 경우
    //         if (cCode < 0xAC00 || cCode > 0xD7A3) {
    //             chars.push(str.charAt(i));
    //             continue;
    //         }
    //         cCode = str.charCodeAt(i) - 0xAC00;
    //         jong = cCode % 28; // 종성
    //         jung = ((cCode - jong) / 28) % 21 // 중성
    //         cho = (((cCode - jong) / 28) - jung) / 21 // 초성
    //         chars.push(cCho[cho], cJung[jung]);
    //         if (cJong[jong] !== '') {
    //             chars.push(cJong[jong]);
    //         }
    //     }
    //     return chars;
    // },
    fnChkByte:function(obj, maxByte){
        var str = obj.value;
        var str_len = str.length;

        var rbyte = 0;
        var rlen = 0;
        var one_char = "";
        var str2 = "";

        for(var i=0; i<str_len; i++){
            one_char = str.charAt(i);
            if(escape(one_char).length > 4){
                rbyte += 2;                                         //한글2Byte
            }else{
                rbyte++;                                            //영문 등 나머지 1Byte
            }

            if(rbyte <= maxByte){
                rlen = i+1;                                          //return할 문자열 갯수
            }
        }

        if(rbyte > maxByte){
            commonUtil.msgBox('CL_MAX_CNTS_LENGTH' ,[(maxByte/2) ,maxByte]);
            str2 = str.substr(0,rlen);                                  //문자열 자르기
            obj.value = str2;
            fnChkByte(obj, maxByte);
        }else{
            document.getElementById('byteInfo').innerText = rbyte;
        }
    },
    getCurrPk:function(PKCOL,ADDCOL,LEN){
        if(!PKCOL) {
            alert('PKCOL required')
            return false;
        }
        if(!LEN) {
            LEN = 12;
        }
        var dataPostMap = new DataMap();
        var pkMap = new DataMap();
        pkMap.put('PKCOL',PKCOL);
        pkMap.put('ADDCOL',ADDCOL);
        pkMap.put('LEN',LEN);
        cl.addMap(dataPostMap,'CLCOM_CURR_PK','MAP',pkMap);
        var json = netUtil.sendData({
            url:'/GCCL/CL/json/listUpdate.data',
            param:dataPostMap,
        });
        var pkString = json.data['CLCOM_PK']['CLCOM_PK']
        return pkString

    },
    getPk:function(PKCOL,ADDCOL,LEN){
        if(!PKCOL) {
            alert('PKCOL required')
            return false;
        }
        if(!LEN) {
            LEN = 12;
        }
        var dataPostMap = new DataMap();
        var pkMap = new DataMap();
        pkMap.put('PKCOL',PKCOL);
        pkMap.put('ADDCOL',ADDCOL);
        pkMap.put('LEN',LEN);
        cl.addMap(dataPostMap,'CLCOM_PK','MAP',pkMap);
        var json = netUtil.sendData({
            url:'/GCCL/CL/json/listUpdate.data',
            param:dataPostMap,
        });
        var pkString = json.data['CLCOM_PK']['CLCOM_PK']
        return pkString

    },
    ajax:  {
        fileMap:{},
        // getFileList:function(MENUID,GUUID){
        //     cl.ajax.reset();
        //     var postMap = new DataMap();
        //     postMap.put('MENUID',MENUID);
        //     postMap.put('GUUID',GUUID);
        //     cl.ajax.addMap('CLCOM_CLFILE','LIST',postMap);
        //     var json = cl.ajax.sendData();
        //     return json;
        // },
        upImageCheck:function(file){
            if(!file){
                alert('file notExists');
                return false;
            }
            if(file.type.indexOf("image")==-1)
            {
                alert('image notExists');
                return false;
            } else {
                return true;
            }
        },
        upImage:function(file,menuID,guuID){
            if(cl.ajax.upImageCheck(file)){
                return cl.ajax.upLoad(file, menuID, guuID,'/common/image/fileUp/image.data');
            } else {
                return '';
            }

        },
        delFile:function(listOrMap,menuID,param,callback) {
            if(!callback) callback=null;
            if(!listOrMap) listOrMap = 'MAP';
            var paramData = new DataMap(param);
            paramData.put("GETTYPE",listOrMap);
            paramData.put("MENUID",menuID);


             var json = netUtil.sendData({
                url:'/GCCL/CL/json/fileDelete.data',
                param:paramData,
            });
            if(typeof(callback)=="function"){
                callback(json);
                return ;
            }
            return json;

        },
        upFile:function(file,menuID,guuID) {
            return cl.ajax.upLoad(file, menuID, guuID,'/common/fileUp/file.data');
        },

        upLoad:function(file,menuID,guuID,url){

            if(!file){
                alert('file notExists');
                return false;
            }
            if(!menuID){
                alert('menuID notExists');
                return false;
            }
            if(!guuID){
                guuID = '';
            }
            var formData = new FormData();
            formData.append('fileUp', file);

            $.ajax( {
                url:url ,
                enctype: 'multipart/form-data',
                type: 'POST',
                async:false,
                contentType: false,
                processData: false,
                data: formData,
                error: function() {
                    file='';
                },
                success: function(r){
                    file  = r.substring(r.indexOf('[')+1,r.lastIndexOf(']'))
                    if(menuID){
                        var postMap = new DataMap();
                        postMap.put('UUID',file);
                        postMap.put('MENUID',menuID);
                        postMap.put('GUUID',guuID);

                        var json = netUtil.sendData({
                            url:'/GCCL/CL/json/fileUpdate.data',
                            param:postMap
                        });
                        if(json.hasOwnProperty("data")){
                            cl.ajax.fileMap[file] = json["data"];
                        }

                    }

                }
            });
            return file;
        },
        // postParam:null,
        // param:null,
        // paramSort:[],
        // rebind:function() {
        //     if(!cl.ajax.param){
        //         cl.ajax.paramSort = [];
        //         cl.ajax.afterSort = new DataMap();
        //         cl.ajax.param = new DataMap();
        //     }
        //     return cl.ajax;
        // },
        // reset:function(){
        //     cl.ajax.postParam = null;
        //     cl.ajax.paramSort = [];
        //     cl.ajax.afterSort = new DataMap();
        //     cl.ajax.param = new DataMap();
        //     return cl.ajax;
        // },
        // addAfter:function(command,afterCommand,sendType,fromKey) {
        //     cl.ajax.afterSort.put(command,[afterCommand,sendType,fromKey].join('.'));
        // },
        // addList:function(command,sendType,listObj) {
        //     cl.ajax.rebind();
        //     var bindKey = [command,sendType.toUpperCase(),'LIST'].join('.');
        //     cl.ajax.paramSort.push(bindKey);
        //     cl.ajax.param.put((command+'_'+sendType).toUpperCase(),listObj);
        //     return cl.ajax;
        // },
        // addParam:function(mapObj){
        //     cl.ajax.postParam = mapObj;
        // },
        // addMap:function(command,sendType,mapObj){
        //     cl.ajax.rebind();
        //     var bindKey = [command,sendType.toUpperCase(),'MAP'].join('.');
        //     cl.ajax.paramSort.push(bindKey);
        //     cl.ajax.param.put((command+'_'+sendType).toUpperCase(),mapObj);
        //
        //     return cl.ajax;
        // },
        // /**
        //  * 비동기방식
        //  * @param id
        //  * @param addId
        //  */
        // send:function(id,addId){
        //     return cl.ajax.post(id,addId);
        // },
        // /**
        //  * 비동기방식
        //  * @param id
        //  * @param addId
        //  */
        // post:function(id,addId){
        //     if(!addId) addId='';
        //     if(!id) id ='AJAX';
        //     cl.ajax.param.put('listModule',cl.ajax.paramSort.join(','));
        //     cl.ajax.param.put('addAfter',cl.ajax.afterSort);
        //     if(cl.ajax.postParam) cl.ajax.param.put('param',cl.ajax.postParam);
        //     cl.ajax.param.put('ID',id);
        //     cl.ajax.param.put('GRIDSPLIT',addId);
        //     var json = netUtil.send({
        //         url:'/GCCL/CL/json/listUpdate.data',
        //         param:cl.ajax.param,
        //         successFunction : "saveDataCallBack",
        //         failFunction : "failDataCallBack"
        //     });
        //
        //     return cl.ajax;
        // },
        // /**
        //  * 동기방식
        //  * @param callback
        //  * @returns {*}
        //  */
        // sendData:function(callback){
        //     cl.ajax.param.put('listModule',cl.ajax.paramSort.join(','));
        //     cl.ajax.param.put('addAfter',cl.ajax.afterSort);
        //     if(cl.ajax.postParam) cl.ajax.param.put('param',cl.ajax.postParam);
        //     cl.ajax.param.put('ID','');
        //     cl.ajax.param.put('GRIDSPLIT','');
        //     var json = netUtil.sendData({
        //         url:'/GCCL/CL/json/listUpdate.data',
        //         param:cl.ajax.param,
        //     });
        //     if(typeof(callback)=="function"){
        //         callback(json,arguments);
        //         return ;
        //     }
        //
        //     return json;
        // }
    },
    // UI : {
    //     INIT:function(){
    //         //$('.content_wrap').css('max-width','960px');
    //         $( ".content_wrap .tabs" ).on( "tabsactivate", function( event, ui ) {
    //             //alert($(this).tabIndex());
    //             var tabBtn = $(this).find('.tab_btn .fl_r.cl');
    //             if(tabBtn.length){
    //                 tabBtn.hide();
    //                 tabBtn.eq($(this).tabs( "option", "active" )).show()
    //             }
    //         });
    //
    //     },
    //     BTN:function(){
    //
    //     },
    //     PRJINFO:function() {
    //         //프로젝트유형변경
    //
	// 	    $('#S_REQUEST_KND_GB').change(function(){
	// 	    //프로벡트코드 리셋
    //             $('#S_PROJT_CD').val('');
    //             cl.getClCode($('#S_PROJT_NM'),'CLCOM_PROJT',{REQUEST_KND_GB:$('#S_REQUEST_KND_GB').val()},'PROJT_CD','PROJT_NM');
    //         });
    //         //프로젝트코드
    //         $('#S_PROJT_CD').keypress(function() {
    //             cl.getClCode($('#S_PROJT_NM'),'CLCOM_PROJT',{REQUEST_KND_GB:$('#S_REQUEST_KND_GB').val(),PROJT_CD:$('#S_PROJT_CD').val()},'PROJT_CD','PROJT_NM');
    //         });
    //         //프로젝트명
    //         cl.getClCode($('#S_PROJT_NM'),'CLCOM_PROJT',{REQUEST_KND_GB:$('#S_REQUEST_KND_GB').val()},'PROJT_CD','PROJT_NM').unbind('change').change(function(){
    //             $('#S_PROJT_CD').val('');
    //             $('#S_PROJT_CD').val(cl.getCode('CLCOM_CLCOM_PROJT',$('#S_PROJT_NM').val(),'PROJT_CD'));
    //
    //         });
    //     },
    //     PRJBRDINFO:function() {
    //         //프로젝트유형변경
    //
	// 	    $('#S_REQUEST_KND_GB').change(function(){
	// 	    //프로벡트코드 리셋
    //             $('#S_PROJT_CD').val('');
    //             cl.getClCode($('#S_PROJT_NM'),'CLCOM_PROJT_BRD',{REQUEST_KND_GB:$('#S_REQUEST_KND_GB').val()},'PROJT_CD','PROJT_NM');
    //         });
    //         //프로젝트코드
    //         $('#S_PROJT_CD').keypress(function() {
    //             cl.getClCode($('#S_PROJT_NM'),'CLCOM_PROJT_BRD',{REQUEST_KND_GB:$('#S_REQUEST_KND_GB').val(),PROJT_CD:$('#S_PROJT_CD').val()},'PROJT_CD','PROJT_NM');
    //         });
    //         //프로젝트명
    //         cl.getClCode($('#S_PROJT_NM'),'CLCOM_PROJT_BRD',{REQUEST_KND_GB:$('#S_REQUEST_KND_GB').val()},'PROJT_CD','PROJT_NM').unbind('change').change(function(){
    //             $('#S_PROJT_CD').val('');
    //             $('#S_PROJT_CD').val(cl.getCode('CLCOM_CLCOM_PROJT_BRD',$('#S_PROJT_NM').val(),'PROJT_CD'));
    //         });
    //     }
    // },

    // popup:{
    //     popupID:null,
    //     open:function($id,w,h,callback,param) {
    //         cl.popup.popupID = $id;
    //         if(!param) param ={};
    //         $layerBack.show();
    //         $LayerPop = $($id);
    //         if($LayerPop == undefined){
    //
    //         }
    //
    //         if(!w){
    //             w = $LayerPop.css('width');
    //         }
    //         if(!h){
    //             h = $LayerPop.css('height');
    //         }
    //         if(!w) w = 500;
    //         if(!h) h = 500;
    //         if(w<400){
    //             w = 4000;
    //         }
    //         if(h<300){
    //             h = 3000;
    //         }
    //
    //
    //         $LayerPop.width(w).css({'margin-left':-(w/1.8)+'px','margin-top':-(h/2)+'px','left':'50%','top':'top%'});
    //         $LayerPop.find('.content_layout').height(h);
    //         $LayerPop.show();
    //         $layerBack.show();
    //         if(typeof(callback)=='function'){
    //             callback($LayerPop,param);
    //         }
    //     },
    //     close:function($id){
    //         if(!$id &&cl.popup.popupID){
    //             $id= cl.popup.popupID;
    //         }
    //         $LayerPop = $($id);
	// 	    $LayerPop.hide();
	// 	    $layerBack.hide();
    //     }
    // },
    // getClCode:function(thisObj,command,jsonParam,VALUE_COL,TEXT_COL){
    //     var exModule = command.split('_');
    //     var module = exModule[0];
    //     if(!VALUE_COL) {
    //             VALUE_COL = 'VALUE_COL';
    //
    //     }
    //     if(!TEXT_COL) {
    //             TEXT_COL = 'TEXT_COL';
    //     }
    //     if(!jsonParam) jsonParam = {};
    //     var param = new DataMap();
    //
    //     if(jsonParam instanceof DataMap){
    //         param = jsonParam;
    //     } else {
    //         if(Object.keys(jsonParam).length>0){
    //             $.each(jsonParam,function(k,v){
    //                 param.put(k,v);
    //             })
    //         }
    //     }
    //
    //
    //
    //     var expCommend = command.split('_');
    //     var sendType = expCommend[expCommend.length-1];
    //
    //     if(sendType!='LIST' && sendType!='COMBO' ){
    //         sendType = 'list';
    //     }
    //
    //     var json = netUtil.sendData({
    //       module : module,
    //       command : command,
    //       param:param,
    //       sendType: sendType.toLowerCase()
    //     });
    //     var comboDataMap = {};
    //     var exCode = [module,command].join('_');
    //     comboDataMap[exCode] = json['data'];
    //     try {
    //         $.extend(inputList.comboDataMap.map,comboDataMap);
    //         cl.addItemList(thisObj,json['data'],VALUE_COL,TEXT_COL,exCode);
    //     } catch(ex) {
    //
    //     }
    //
    //
    //    return $(thisObj);
    // },
    // getMap:function(thisObj,appendJson,delKey){
    //     var param = new DataMap();
    //     if(validate.check(thisObj)) {
    //
    //
    //         var el = $(thisObj).find('input,textarea,select');
    //         var obj = {};
    //         $.each(el, function (i) {
    //             if ($(this).attr('type') == 'checkbox' && !$(this).is(':checked')) return false;
    //             if ($(this).attr('type') == 'radio' && !$(this).is(':checked')) return false;
    //             var objName = $(this).attr('name');
    //             if (objName) {
    //                 if ($(this).get(0).nodeName == 'SELECT' && (obj[objName] == '' || obj[objName] == null)) {
    //                     obj[objName] = $(this).find(':selected').attr('value');
    //                     param.put(objName, $(this).find(':selected').attr('value'));
    //                 } else {
    //                     param.put(objName, $(this).val());
    //                 }
    //             }
    //
    //         });
    //     }
    //     if(appendJson){
    //         if(Object.keys(appendJson).length!=0){
    //             $.each(appendJson,function(k,v){
    //                 param.put(k,v);
    //             })
    //         }
    //     }
    //     if(delKey){
    //         if(delKey.length!=0){
    //             $.each(delKey,function(i,k){
    //                 delete param[k];
    //             })
    //         }
    //     }
    //     return param;
    //
    // },
	// setData:function(thisObj,jsonData){
	// 	if(!jsonData) jsonData ={};
	// 	var resElement = $(thisObj);
	// 	if(Object.keys(jsonData).length>0){
	// 		$.each(jsonData,function(k,v){
	// 		    v = $.trim(v);
	// 		    if(resElement.find(':checkbox[name='+k+']').length>0){
	// 		        resElement.find(':checkbox[name='+k+']').val([v]);
    //             }
    //             else if(resElement.find(':radio[name='+k+']').length>0){
	// 		       resElement.find(':radio[name='+k+']').val([v]);
    //             }
    //
	// 			else {
	// 				if(resElement.find('#'+k).length){
	// 					resElement.find('#'+k).val(v);
	// 				} else {
	// 					resElement.find('[name='+k+']').val(v);
	// 				}
    //
    //             }
	// 		});
	// 	}
	// 	return resElement;
    //
	// },
    // addCodeView:true,


    // getCode:function(item,key,itemkey){
    //     if(itemkey){
    //
    //         return inputList.comboMap.map[item+'_MAP'][key][itemkey];
    //
    //     } else {
    //         return inputList.comboMap.map[item+'_MAP'][key];
    //     }
    // },
    /**  CL
     * ATTR 을 소문자로 변환하지않도록 변경
     * @param element
     * @param attrs
     * @returns {*}
     */
	makeAttr:function(element,attrs){
		if(attrs){
			$.each(attrs,function(k,v){
				element.get(0).setAttributeNS('',k,v);
			});
		}
		return element;
	},
    /**  CL
     * 엘리먼트생성
     * @param nodeName
     * @param val
     * @param attr
     * @returns {jQuery.fn.init|jQuery|HTMLElement|*}
     */
    makeElement:function(nodeName,val,attr){
		var el = null;
		if(nodeName=='input' || nodeName=='img' || nodeName=='col'){
			el = $('<'+nodeName+' />');
		} else {
			el = $('<'+nodeName+'></'+nodeName+'>');
		}
		if(val){
			if(nodeName=='input'||nodeName=='textarea') el.val(val);
			else el.html(val);
		}
		if(attr){
			cl.makeAttr(el,attr);
		}
		return el;
	}
}