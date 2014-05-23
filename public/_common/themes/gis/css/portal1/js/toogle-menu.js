$(function(){
  $('.naviMenu').hide();
  $('#toogle-menu').on("click", function() {
      $('.naviMenu').slideToggle();
      $("#toogle-menu a").toggleClass("open");
	});
	
});

$(function(){
  $(window).bind("load resize", init);
  function init(){
  var _width = $(window).width();
    if(_width <= 799){
      $("#docInfo .next a").text(">>更新情報一覧へ");
    }
  }
});

$(function(){
  $(window).bind("load resize", init);
  function init(){
  var _width = $(window).width();
    if(_width >= 800){
      $("#docInfo .next a").text("更新情報一覧へ");
    }
  }
});

$(function(){
  $('#shisetsuSearch .pieceBody').hide();
  $('#shisetsuSearch .pieceHeader .switch').on("click", function() {
      $('#shisetsuSearch .pieceBody').slideToggle();
      $("#shisetsuSearch .pieceHeader .switch").toggleClass("open");
	});
	
});

$(function(){
  $('#recommend .pieceBody').hide();
  $('#recommend .pieceHeader .switch').on("click", function() {
      $('#recommend .pieceBody').slideToggle();
      $("#recommend .pieceHeader .switch").toggleClass("open");
	});
	
});

$(function(){
  $(".pagination span").toggleClass("heightLine-group5");
  $(".pagination em").toggleClass("heightLine-group5");
  $(".pagination a").toggleClass("heightLine-group5");
});
