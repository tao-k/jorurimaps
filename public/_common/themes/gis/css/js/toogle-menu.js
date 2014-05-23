$(function(){
  $('.naviMenu').hide();
  $('#toogle-menu').on("click", function() {
      $('.naviMenu').slideToggle();
	});
	
});

$(function(){
  $('.lowerMenu form').hide();
  $('#toogle-search').on("click", function() {
      $('.lowerMenu form').slideToggle();
	});
	
});

$(function(){
  $('#ichiran').on("click", function() {
      $("#ichiran").toggleClass("current");
      $("#samunail").removeClass("current");
      $(".content").toggleClass("ichi");
      $(".content").removeClass("samu");
	});
	
  $('#samunail').on("click", function() {
      $("#samunail").toggleClass("current");
      $("#ichiran").removeClass("current");
      $(".content").toggleClass("samu");
      $(".content").removeClass("ichi");
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
