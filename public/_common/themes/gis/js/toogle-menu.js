$(function(){
  $('.naviMenu').hide();
  $('#toogle-menu').on("click", function() {
      $('#toogle-menu a').toggleClass('on');
      $('.naviMenu').slideToggle();
	});
	
});

$(function(){
  $('#ichiran').on("click", function() {
      $("#ichiran").addClass("current");
      $("#samunail").removeClass("current");
      $(".wrapper").addClass("ichi");
      $(".wrapper").removeClass("samu");
	});
	
  $('#samunail').on("click", function() {
      $("#samunail").addClass("current");
      $("#ichiran").removeClass("current");
      $(".wrapper").addClass("samu");
      $(".wrapper").removeClass("ichi");
	});

});

$(function(){
  $(window).bind("load resize", init);
  function init(){
  var _width = $(window).width();
    if(_width <= 800){
      $(".content").removeClass("ichi");
      $("ul.shinchaku").css("display", "block");
    }
  }
});

$(function(){
  $("ul.shinchaku li > div:last-child").toggleClass("last");
  $("ul.recome li > div:last-child").toggleClass("last");
  $("ul.rank li > div:last-child").toggleClass("last");
  $("ul.chuui li > div:last-child").toggleClass("last");
  $("ul.tokei li > div:last-child").toggleClass("last");
  $("ul.hodou li > div:last-child").toggleClass("last");
  $("ul.sonota li > div:last-child").toggleClass("last");
});

$(function(){
  $(".pagination span").toggleClass("heightLine-group5");
  $(".pagination em").toggleClass("heightLine-group5");
  $(".pagination a").toggleClass("heightLine-group5");
});

$(function(){
  $(window).bind("load resize", init);
  function init(){
  var _width = $(window).width();
    if(_width <= 319){
      $(".logo img").css("width", "100%");
    }
  }
});

$(function(){
  $(window).bind("load resize", init);
  function init(){
  var _width = $(window).width();
    if(_width >= 320){
      $(".logo img").css("width", "216px");
    }
  }
});
