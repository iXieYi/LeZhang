/*slid-bar*/
$(document).ready(function(){
	$("#slide-bar-hide").click(function(){
		
			$("#slide-bar-hide").hide(2,function(){
				$("#slide-bar").animate({width:'hide'},400);
			});
		
	});
	$(".bar-menu-icon").click(function(){
		$("#slide-bar").animate({width:'show'},400,function(){
			$("#slide-bar-hide").show(1);
		});
	});
});
/*
$(document).ready(function(){
	$("#slide-bar-hide").click(function(){
		$("#slide-bar").animate({width:'hide'},500);
	});
	$(".bar-menu-icon").click(function(){
		$("#slide-bar").animate({width:'show'},500);
	});
});

*/