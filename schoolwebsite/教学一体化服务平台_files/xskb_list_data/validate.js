vpn_eval((function(){


    //寻找方法并以此方法提交
    //mhd: 传过来要提交的方法
    function findMethod(mhd){
      document.all.method.value=mhd;
      document.forms[0].submit();
    }

	function getIds(colId) {
		var col = document.all(colId);
		var ids = new Array();
		var j = 0;
		if(col!=null){
          if(isNaN(col.length)){
             if(document.all(colId).checked){
                ids[0] = document.all(colId).value;
             }
          }else{
			 for(var i=0; i<col.length; i ++){
              if(col[i].checked){
                ids[j] = col[i].value;
				j ++;
              }
            }
		  }
        }
		return ids;
	}

    //处理删除，colID:被选中的要删除的主键， mhd:删除时要提交处理的方法
    function processDel(colID,mhd){
        var col = document.forms(0).elements(colID);
        var j = 0;
        if(col!=null){
          if(isNaN(col.length)){
             if(document.all(colID).checked){
                j = 1;
              }
          }
        }
        if(col!=null){
            for(var i=0; i<col.length; i ++){
              if(col[i].checked){
                j ++;
              }
            }
        }
        if(j == 0){
           alert("您没有选择要删除的记录！");
           return;
        }
        else{
          if(confirm("您有"+j+"条记录被选中，如果删除，与其相关连的所有信息都将被删除！确定要删除这些记录吗？")){
             document.forms(0).method.value=mhd;
             //return true;
             document.forms[0].submit();
          }
          else{
             return;
          }
        }
    }

    //选中所有的复选框
    function selectAll(call,cid){
        var old = document.all(call).checked
        var col = document.all(cid);
        if(col!=null){
          if(col.length>=2){
            for(var i=0; i<col.length; i ++){
			  if(col[i].disabled == false)
				col[i].checked = old;
            }
          }
          else{
			 if(col.disabled == false)
				 col.checked = old;
          }
        }
    }

	function goPage(object){
		for(var i=0;i<prop_ts.length;i++) {
			if(prop_ts[i].objName==pageId) {
				prop_ts[i].goPage(object);
			}
		}
	}

	function pageOperate2(pageoperate,courrentpage) {
		document.all("pageOperate").value = pageoperate;
        document.all("courrentPage").value = courrentpage;
        document.forms(0).submit();
	}
	function setThePageCount(countPer) {
        var countPage = document.all(countPer).value;
		document.all("countPPage").value = countPage;
        document.forms(0).submit();
    }

	function setPageCount(pageCount){
		for(var i=0;i<prop_ts.length;i++) {
			if(prop_ts[i].objName==pageId) {
				prop_ts[i].setPageCount(pageCount);
			}
		}
	}

    //核查输入的页码
    function checkPage(actionForm){
        if(document.forms(actionForm).page.value == ""){
            alert("页码必须输入!");
            return false;
        }
        if(isNaN(document.forms(actionForm).page.value)){
            alert("必须输入数字!");
            return false;
        }
        else if(document.forms(actionForm).page.value.indexOf(".") >= 0){
            alert("必须输入整数!");
            return false;
        }
        document.forms(actionForm).pageOperate.value = "gotopage";
        document.forms(actionForm).courrentPage.value = document.forms(actionForm).page.value;
        return true;
    }

    //核查输入字符串是否符合要求，只能输入a-z,A-Z,_,0-9
    function checkStr(strObj,errMsg){
       var regObj = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_" ;
       var value = document.all(strObj).value;
	   if(value == ""){
           return true;
        }
       for(var i=0; i<value.length; i++){
         tempChar= value.substring(i,i+1);
         if(regObj.indexOf(tempChar) == -1){
           alert(errMsg);
           document.all(strObj).focus();
           return false;
         }
       }
       return true;
    }

	function checkStr2(value) {
       var regObj = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-" ;
	   if(value == ""){
           return true;
        }
		for(var i=0; i<value.length; i++){
         tempChar= value.substring(i,i+1);
         if(regObj.indexOf(tempChar) == -1){
           return false;
         }
       }
	   return true;
	}

    //核查只能输入数字
    function checkNum(strObj,errMsg){
       var regObj = "0123456789";
       var value = document.all(strObj).value;
       if(value == ""){
           return true;
        }
       for(var i=0; i<value.length; i++){
         tempChar= value.substring(i,i+1);
         if(regObj.indexOf(tempChar) == -1){
           alert(errMsg);
           return false;
         }
       }
       return true;
    }

    //核查是否为email
    function checkEmail(strObj,errMsg){
       var value = document.all(strObj).value;
	   if(value == ""){
           return true;
        }
       if(value.indexOf("@") == -1 || value.indexOf(".") == -1){
          alert(errMsg);
          document.all(strObj).focus();
          return false;
       }
       return true;
    }

    function CheckLength(textarea,length,msg) {
	intLength=(Trim(textarea.value)).length;
     var str = textarea.value;
     if (intLength>length) {
       alert(msg);
       textarea.focus();
       return false;
     }
     return true;
   }

function CheckLength2(textarea,length,msg) {
     intLength=(Trim(textarea.value)).length;
     var str = textarea.value;
     if (intLength>length) {
       alert(msg);
       textarea.focus();
       return false;
     }
     return true;
   }

   // 去除首尾空格
function Trim(str) {

	blnbeginflag=true
	blnendflag=true

	for (i=0;i<str.length;i++) {
			if ((str.indexOf(" ")==0) && blnbeginflag){
			    intlen=str.length
			    str=str.substring(1,intlen)
			    i--
			}else{
			    blnbeginflag=false
			}

			if ((str.lastIndexOf(" ")==(str.length-1)) && blnendflag) {
			    str=str.substring(0,str.length-1)
			}else{
			    blnendflag=false
			}
         }

         return str
   }
   //用户ajax
   var xmlHttp;
   function createXMLHttpRequest() {
         if(window.ActiveXObject){
             xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
         }
         else if(window.XMLHttpRequest){
             xmlHttp = new XMLHttpRequest();
         }
     }

// 验证是否 日期
function isDate( strValue )
{

	// 日期格式必须是 2001-10-1/2001-1-10 或者为空
	if( isEmpty( strValue ) ) return true;

	if( !checkExp( /^\d{4}-[01]?\d-[0-3]?\d$/g, strValue ) ) return false;
	// 或者 /^\d{4}-[1-12]-[1-31]\d$/

	var arr = strValue.split( "-" );
	var year = arr[0];
	var month = arr[1];
	var day = arr[2];

	// 1 <= 月份 <= 12，1 <= 日期 <= 31
	if( !( ( 1<= month ) && ( 12 >= month ) && ( 31 >= day ) && ( 1 <= day ) ) ){
           return false;
        }

	// 润年检查
	if( !( ( year % 4 ) == 0 ) && ( month == 2) && ( day == 29 ) ){
        return false;
        }

	// 7月以前的双月每月不超过30天
	if( ( month <= 7 ) && ( ( month % 2 ) == 0 ) && ( day >= 31 ) ){
        return false;
        }

	// 8月以后的单月每月不超过30天
	if( ( month >= 8) && ( ( month % 2 ) == 1) && ( day >= 31 ) ){
        return false;
        }

	// 2月最多29天
	if( ( month == 2) && ( day >=30 ) ){
        return false;
        }

	return true;
}

// 验证是否 货币
function isMoney( strValue )
{
	// 货币必须是 -12,345,678.9 等格式 或者为空
	if( isEmpty( strValue ) ) return true;

	return checkExp( /^[+-]?\d+(,\d{3})*(\.\d+)?$/g, strValue );
}

function isMoney1( strValue )
{
	// 货币必须是 1111.43等格式 或者为空
	if( isEmpty( strValue ) ) return true;

	return checkExp( /^[+-]?\d{1,6}\.\d{2}$/g, strValue );
}

// 验证是否 Email
function isEmail( strValue )
{
	// Email 必须是 x@a.b.c.d 等格式 或者为空
	if( isEmpty( strValue ) ) return true;

	var pattern = /^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+(\.[a-zA-Z0-9_-])+/;
	return checkExp( pattern, strValue );

}

// 验证是否 为空
function isEmpty( strValue )
{
	if( strValue == "" )
		return true;
	else
		return false;
}
// 使用正则表达式，检测 s 是否满足模式 re
function checkExp( re, s )
{
	return re.test( s );
}

// 验证是否 整数
function isInt( strValue )
{
	// 数字必须是 0123456789 或者为空

	return checkExp( /^\d*$/g, strValue );
}

// 验证是否 数字
function isNumeric( strValue )
{
	// 数字必须是 0123456789 或者为空

	return !isNaN(strValue);
}

// 验证是否 邮政编码
function isPostalCode( strValue )
{
	// 邮政编码必须是6位数字
	return checkExp( /(^$)|(^\d{6}$)/gi, strValue )
}

// 验证是否 电话
function isPhone( strValue )
{
	// 普通电话	(0755)4477377-3301/(86755)6645798-665
	// Call 机	95952-351
	// 手机		130/131/135/136/137/138/13912345678
	// 或者为空
	if( isEmpty( strValue ) ) return true;

	return checkExp( /(^(\(\d{3,5}\)|\d{3,5}|\d{3,5}-)\d{3,12}(-\d{0,8})?$)|(^\d+-\d+$)|(^(130|131|132|133|134|135|136|137|138|139|159|158|157|151|153|152)\d{8}$)/g, strValue );
}

function checkRadioEmpty(prop) {
		var radio_len = document.all(prop).length;
		var result = false;
		if(radio_len >= 2) {
			for(var i=0;i<radio_len;i++) {
				 if(document.all(prop)[i].checked == true){
					  result = true;
				 }
			}
		}else{
			if(document.all(prop).checked == true) {
				result = true;
			}
		}
		return result;
	}


//////////////////////////////////////
var obj_nan = new Array();
var type_nan = new Array();
var msg_nan = new Array();
var i_is = 0;
var check_type_temp = "";
var check_mess_temp = "";

function checkTextType(object,type,mess) {
try  
  { if(isValidate){return true;}
}catch(err)  
{}
   obj_nan[i_is] = object;
   type_nan[i_is] = type;
   msg_nan[i_is] = mess;
   i_is ++;
   check_type_temp = type;
   check_mess_temp = mess;
  return checkBlurType(object);
}

var obj_pa = new Array();
var patt_pa = new Array();
var patt_value = new Array();
var pamess_pa = new Array();
var i_pa = 0;
function checkPattern(object,patternType,pattern_value,mess) {
	
	obj_pa[i_pa] = object;
	patt_pa[i_pa] = patternType;
	patt_value[i_pa] = pattern_value;
	pamess_pa[i_pa] = mess;
	i_pa ++;
}

function checkBlurType(object) {
	var strValue = object.value;
	var result=true;
	switch( check_type_temp.toLowerCase()) {
			//必须为整数
			case "int" :
				result = isInt( strValue );
				if(!result) {
					alert(check_mess_temp+"必须为整数!");
					object.focus();
					return false;
				}
				break;
			//必须为数字，包括小数
			case "num" :
				result = isNumeric( strValue );
				if(!result) {
					alert(check_mess_temp+"必须为数字!");
					object.focus();
					return false;
				}
				break;
			//书写字符串：数字、字符或下划线
			case "str" :
				result = checkStr2( strValue );
				if(!result) {
					alert(check_mess_temp+"必须为数字、字符、下划线或短横线!");
					object.focus();
					return false;
				}
				break;
			//日期格式
			case "date" :
				result = isDate( strValue );
				if(!result) {
					alert(check_mess_temp+"格式书写错误!");
					object.focus();
					return false;
				}
				break;
			//邮件格式
			case "email" :
				result = isEmail( strValue );
				if(!result) {
					alert(check_mess_temp+"格式书写错误!");
					object.focus();
					return false;
				}
				break;
			//钱格式
			case "money" :
				result = isMoney( strValue );
				if(!result) {
					alert(check_mess_temp+"书写错误!");
					object.focus();
					return false;
				}
				break;
			//邮政编码
			case "code" :
				result = isPostalCode( strValue );
				if(!result) {
					alert(check_mess_temp+"书写错误!");
					object.focus();
					return false;
				}
				break;
			//电话格式
			case "isphone" :
				result = isPhone( strValue );
				if(!result) {
					alert(check_mess_temp+"书写错误!");
					object.focus();
					return false;
				}
				break;
		}
		
		if(check_type_temp.indexOf("num$") >= 0) {
			var max = check_type_temp.split("$")[1];
			result = isNumeric( strValue );
			if(!result) {
				alert(check_mess_temp+"必须为数字!");
				object.focus();
				object.value='';
				return false;
			}
			if(Number(strValue) >= Number(max)) {
				alert(check_mess_temp+"必需小于"+max);
				object.focus();
				object.value='';
				return false;
			}
		}
		
		return result;
}

function checkType() {
    for(var j=0;j<obj_nan.length;j++) {
		var strType = type_nan[j];
		if(strType == "radioempty") {
			result = checkRadioEmpty( obj_nan[j] );
				if(!result) {
					alert(msg_nan[j]+"没有选择!");
					return false;
				}
		}
		var strValue = obj_nan[j].value;
		var result=true;

		switch( strType.toLowerCase()) {
			//不能为空
			case "empty" :
				result = isEmpty( Trim(strValue) );
				if(result) {
					alert(msg_nan[j]+"不能为空!");
					obj_nan[j].focus();
					return false;
				}
				break;
			//必须为整数
			case "int" :
				result = isInt( strValue );
				if(!result) {
					alert(msg_nan[j]+"必须为整数!");
					obj_nan[j].focus();
					return false;
				}
				break;
			//必须为数字，包括小数
			case "num" :
				result = isNumeric( strValue );
				if(!result) {
					alert(msg_nan[j]+"必须为数字!");
					obj_nan[j].focus();
					return false;
				}
				break;
			//书写字符串：数字、字符或下划线
			case "str" :
				result = checkStr2( strValue );
				if(!result) {
					alert(msg_nan[j]+"必须为数字、字符、下划线或短横线!");
					obj_nan[j].focus();
					return false;
				}
				break;
			//日期格式
			case "date" :
				result = isDate( strValue );
				if(!result) {
					alert(msg_nan[j]+"格式书写错误!");
					obj_nan[j].focus();
					return false;
				}
				break;
			//邮件格式
			case "email" :
				result = isEmail( strValue );
				if(!result) {
					alert(msg_nan[j]+"格式书写错误!");
					obj_nan[j].focus();
					return false;
				}
				break;
			//钱格式
			case "money" :
				result = isMoney( strValue );
				if(!result) {
					alert(msg_nan[j]+"书写错误!");
					obj_nan[j].focus();
					return false;
				}
				break;
			//邮政编码
			case "code" :
				result = isPostalCode( strValue );
				if(!result) {
					alert(msg_nan[j]+"书写错误!");
					obj_nan[j].focus();
					return false;
				}
				break;
			//电话格式
			case "isphone" :
				result = isPhone( strValue );
				if(!result) {
					alert(msg_nan[j]+"书写错误!");
					obj_nan[j].focus();
					return false;
				}
				break;
		}
		
		if(strType.indexOf("num$") >= 0) {
			var max = strType.split("$")[1];
			result = isNumeric( strValue );
			if(!result) {
				alert(msg_nan[j]+"必须为数字!");
				obj_nan[j].focus();
				return false;
			}
			if(Number(strValue) >= Number(max)) {
				alert(msg_nan[j]+"必需小于"+max);
				obj_nan[j].focus();
				return false;
			}
		}
	}

	for(var k=0;k<obj_pa.length;k++) {
		var paType = patt_pa[k];
		var paValue = patt_value[k];
		var objValue = obj_pa[k].value;

		switch(paType.toLowerCase()) {
			//书写定义长度
			case "length" :
				var paValue_s = paValue.split(",")[0];
				var paValue_e = paValue.split(",")[1];
				if(objValue == "") {
					return true;
				}
				if(objValue.length<paValue_s || objValue.length>paValue_e) {
					if(paValue_s==-1) {
						alert(pamess_pa[k]+"长度不能超过"+paValue_e+"个字！");
					}
					if(paValue_e==-1) {
						alert(pamess_pa[k]+"长度不能少于"+paValue_s+"个字！");
					}
					if(paValue_s>=0&&paValue_e>=0) {
						alert(pamess_pa[k]+"长度必须在"+paValue_s+"到"+paValue_e+"之间！");
					}
					obj_pa[k].focus();
					return false;
				}
				break;
			//正则表达式
			case "pattern" :
				if(!checkExp(paValue,objValue)) {
					alert(pamess_pa[k]);
					obj_pa[k].focus();
					return false;
				}
				break;
		}
	}
	return true;
	}


	//判断表单中的数据是否作了修改,如果未修改不允许提交
	var isTextChanged = false;
	function isFormChanged(form,msg) {
		for (var i = 0; i < form.elements.length; i++) {
		   	var element = form.elements[i];
		   	var type = element.type;
		   	if (type == "text" || type == "hidden" || type == "textarea") {
		    	if (Trim(element.value) != Trim(element.defaultValue)) {
		     		isTextChanged = true;
		     		break;
		    	}
		   	} else if (type == "radio" || type == "checkbox") {
		    	if (element.checked != element.defaultChecked) {
		     		isTextChanged = true;
		     		break;
		    	}
		   	} else if (type == "select-one"||type == "select-multiple") {
		    	for (var j = 0; j < element.options.length; j++) {
		    		if(element.disabled== false) {
			     		if (element.options[j].selected != element.options[j].defaultSelected) {
			      			isTextChanged = true;
			      			break;
			     		}
		     		}
		    	}
		    	
		   	}else { 
		    	// etc...
		   	}
		}
		if(!isTextChanged) {
			//document.forms(0).disabled = true;
			if(msg){ // 您没有作任何的修改,不能提交表单!
				alert(msg);
			}
			//document.forms(0).disabled = false;
			return false;
		}else{
			return true;
		}
	}
	//
var vid="";
var mb="";
var id="";
var b=0;
function frdy_laosha(ids,key,frurl,func){
		vid=ids;
		var keys = "";
		$("#key").val(key);
		if(!document.getElementById("frjumpurl")){
			$('#FormFr').append("<input type='hidden' id='frjumpurl' name='frjumpurl'  value=''  />")
		}
		$('#FormFr').append("<input type='hidden' id='cs' name='cs'  value='"+vid+"'  />");
		//dwrMonitor.getFrMbxx(key,getDataResult_fr);
		 $.ajax({
				type: "post",
				url: $("#PageContext").val()+"/kbxx/getFrmbxx?key="+key,
				data: $('#FormFr').serialize(),
				dataType: "json",
				success: function(data){
				//alert(data);
						if(data.success==false){
							
						}else{
							if(data.data==''){
								setTimeout(func,0);
							}else{
								mb=data.data.mb;
								id=data.data.ywinstanceidname;
								keys=data.key;
								var url="";
								if(mb.indexOf(".frm")>=0){
										url=frurl+"/ReportServer?formlet=/"+mb;
								}else{
										url=frurl+"/ReportServer?reportlet=/"+mb;
								}
								if(id!=null && id.indexOf(",")>0){
									var strs= new Array();
									strs=id.split(",");
									var idl=vid.split(",");
									for(var i=0;i<strs.length;i++){
										url+="&"+strs[i]+"="+idl[i];
										if(strs[i] == "xh" || strs[i] == "jgh"){
											url+="&key="+keys;
										}
									}
								}else{
									if(id!=null)url+="&"+id+"="+vid;
									if(id == "xh" || id == "jgh"){
										url+="&key="+keys;
									}
								}
								//url
								var str_url=window.btoa(url);
								//str_url=window.atob(str_url);
								//alert(str_url);
								$("#frjumpurl").val(str_url);
								JsOpenWin(url,1000,700);
								//JsOpenWin($("#PageContext").val()+"/fr/fr_index.jsp",1000,700);
							}
						}
						
				}
			});
}

	function rqdy_laosha(ids,key,rqurl,func){
		vid=ids;
		$("#key").val(key);
		if(!document.getElementById("frjumpurl")){
			$('#FormFr').append("<input type='hidden' id='frjumpurl' name='frjumpurl'  value=''  />")
		}
		//dwrMonitor.getFrMbxx(key,getDataResult_fr);
		$.ajax({
			type: "post",
			url: $("#PageContext").val()+"/kbxx/getFrmbxx",
			data: $('#FormFr').serialize(),
			dataType: "json",
			success: function(data){
				//alert(data);
				if(data.success==false){

				}else{
					if(data.data==''){
						setTimeout(func,0);
					}else{
						mb=data.data.mb;
						id=data.data.ywinstanceidname;
						var url="";
						if(mb.indexOf(".rpx")>=0){
							url=rqurl+"?rpx=/"+mb;
						}
						if(id!=null && id.indexOf(",")>0){
							var strs= new Array();
							strs=id.split(",");
							var idl=vid.split(",");
							for(var i=0;i<strs.length;i++){
								url+="&"+strs[i]+"="+idl[i];
							}
						}else{
							if(id!=null)url+="&"+id+"="+vid;
						}
						//url
						url+="&rpxHome=WEB-INF/reportFiles";
						var str_url=window.btoa(url);
						//str_url=window.atob(str_url);
						//alert(str_url);
						$("#frjumpurl").val(str_url);
						JsOpenWin($("#PageContext").val()+"/fr/fr_index.jsp",1000,700);
					}
				}

			}
		});
	}

}
).toString().slice(12, -2),"");