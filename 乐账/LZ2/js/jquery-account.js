  var num = 0; // 定义第一个输入的数据outlayFlag
  var symbolFlag=0;//定义字符的个数
  var incomeFlag=0;
  function jsq(num) {
    //获取当前输入
    
    if($('#screenName').val()==="0.00")
    {
    	$('#screenName').val(null);
    }
    if((num==="-")||(num==="+")||(num==="."))
    {
    	if(symbolFlag==1)
    	{
    	symbolFlag=0;
		document.getElementById('screenName').value += document.getElementById(num).value;	
		$("#eva").val("=");
    	}   	
    }
    else 
    {    

    	symbolFlag=1;
    	document.getElementById('screenName').value += document.getElementById(num).value;
    }
 //   alert(symbolFlag);
    $("#screenName").blur();
  }


  function eva() {
    //计算输入结果
    var tempNum;
    //确认键收回键盘
    if(document.getElementById('eva').value=="确认"){
    	   $("#calculator").hide();
    }
    if(symbolFlag==0){
    	symbolFlag=1;
		tempNum= eval(document.getElementById("screenName").value+"0");
    }
    else{
    	tempNum= eval($("#screenName").val());
    }
    if(typeof(tempNum)!="undefined"){ 
    	$('#screenName').val(tempNum);
    	$('#eva').val("确认");	 	 
    }
 	
    $("#screenName").blur();
  }
  function tuiGe() {
    //退格
    symbolFlag=1;
    var arr = document.getElementById("screenName");
    arr.value = arr.value.substring(0, arr.value.length - 1);
    $("#screenName").blur();
  }

$(document).ready(function(){
    $("#screenName").click(function(){      
            $("#calculator").show();
            document.getElementById("screenName").blur();
            });
    $("#account-income").click(function(){
       incomeFlag=1;
        $("#account-income").addClass("class-on");
        $("#account-outlay").addClass("class-off");
        $("#account-income").removeClass("class-off");
        $("#account-outlay").removeClass("class-on");
        
        $("#account-out-ul").hide(2,function(){
            $("#account-in-ul").show();
        });
      
    });
   $("#account-outlay").click(function(){
         incomeFlag=0;
        $("#account-outlay").addClass("class-on");
        $("#account-income").addClass("class-off");
        $("#account-outlay").removeClass("class-off");
        $("#account-income").removeClass("class-on");  
        $("#account-in-ul").hide(2,function(){
            $("#account-out-ul").show();
        }); 
    });

$("#slide-bar-hide").click(function(){
        
            $("#slide-bar-hide").hide(2,function(){
                $("#slide-bar").animate({width:'hide'},400);
            });

        
    });

//弹出侧边栏
    $(".bar-menu-icon").click(function(){
        $("#slide-bar").animate({width:'show'},400,function(){
            $("#slide-bar-hide").show(1);
            $(".function-list").find("ul").show();
        });
        $("#user-photo").width($("#user-photo").height());
        



    });
   //实现关闭account页面

   $(".close-icon").click(function(){
        $("#account-page").hide(2,function(){
            $("#index-page").show();
        });
    });

   //实现界面弹出效果
    $(".edit-icon").click(function(){
        $("#index-page").hide(2,function(){
            $("#account-page").show();
            $(".num-class-img").css({"background":"url(images/out-photos.png) no-repeat",
                                     "background-size":"194px auto",
                                     "background-position":$(this).find("span").css("background-position")});
            $("#screenName").blur(); 
            $("#screenName").val("0.00"); 
            $("#calculator").show();
            $("#remarkInput").blur(); 
            $("#remarkInput").val("请输入备注信息"); 
            $("#remarkInput").css("color","#97a1a6");  
            $(".function-list").find("ul").hide();      
        });
    });

    //点击备注信息
    $("#remarkInput").click(function(){
        $("#calculator").hide(2,function(){
            $("#remarkInput").focus();
        });
        $("#remarkInput").css("color","black");
        $("#remarkInput").val("");
    });

    //点击话筒弹出语音记账界面
    $(".voice-icon").click(function(){
        $("#voice-page").show();
        
    });






    /*实现支出收入切换*/
    $(".aimgs").click(function(){
        $("#num-class-p").text($(this).find("p").html());
        if(incomeFlag==1){
            $(".num-class-img").css({"background":"url(images/in-photos.png) no-repeat",
                                     "background-repeat":"no-repeat",
                                     "background-size":"146px auto",
                                     "background-position":$(this).find("span").css("background-position")});
            
        }
        else{
            $(".num-class-img").css({"background":"url(images/out-photos.png) no-repeat",
                                     "background-repeat" :"no-repeat",
                                     "background-size":"194px auto",
                                     "background-position":$(this).find("span").css("background-position")});
        }
        /*
        if(incomeFlag==1){
            $(".num-class-img").css({"background":"url(../images/in-photos.png)",
                                     "background-size":"146px auto",
                                     "background-position":$(this).find("span").css("background-position")});
        }   
        else{
            $(".num-class-img").css({"background":"url(../images/out-photos.png)",
                                     "background-size":"194px auto",
                                     "background-position":$(this).find("span").css("background-position")});
        }
        */
       
        
    });




});
  