function execDaumPostcode(areaIdList, zipName, addr1Name, addr2Name) {
    new daum.Postcode({
        oncomplete: function(data) {
            var addr = ''; // 주소 변수
            var extraAddr = ''; // 참고항목 변수

            if (data.userSelectedType === 'R') { // 사용자가 도로명 주소를 선택했을 경우
                addr = data.roadAddress;
            } else { // 사용자가 지번 주소를 선택했을 경우(J)
                addr = data.jibunAddress;
            }
            if(data.userSelectedType === 'R'){
                if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
                    extraAddr += data.bname;
                }
                if(data.buildingName !== '' && data.apartment === 'Y'){
                    extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                }
                if(extraAddr !== ''){
                    extraAddr = ' (' + extraAddr + ')';
                }
                for(var i in areaIdList){
                    $("#"+areaIdList[i]).find("[name='"+addr2Name+"']").val(extraAddr);
                }
                //document.getElementById("MEMAD2").value = extraAddr;
            
            } else {
                //document.getElementById("MEMAD2").value = '';
            	 for(var i in areaIdList){
                 	$("#"+areaIdList[i]).find("[name='"+addr2Name+"']").val("");

            	 }
            }
            for(var i in areaIdList){
            	
            	console.log(areaIdList[i])
            	$("#"+areaIdList[i]).find("[name='"+zipName+"']").val(data.zonecode);
            	$("#"+areaIdList[i]).find("[name='"+addr1Name+"']").val(addr);
            	$("#"+areaIdList[i]).find("[name='"+addr2Name+"']").focus();
                 //document.getElementById('MEMPCD').value = data.zonecode;
                 //document.getElementById("MEMAD1").value = addr;
                 //document.getElementById("MEMAD2").focus(); 
            	
            	//event fn
				if(commonUtil.checkFn("execDaumPostcodeEnd")){
					execDaumPostcodeEnd(areaIdList[i], data.zonecode, addr, extraAddr, data);
				}
            }           
        }
    }).open({
    	popupName: 'Address'
    });
}