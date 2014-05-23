//accordion
(function($) {
$(document).ready(function(){
  $('.menuHeader').click(function() {
    $(this).toggleClass("open").next().slideToggle();
  }).next().hide();
  //----------------------------
  $('.accordion2').click(function() {
    $(this).next().slideToggle();
  }).next().hide();
  $('.accordion2:first').next().show();
  //----------------------------
  $('.accordion3').click(function() {
    $('.accordion3').next().slideUp();
    $(this).next().slideToggle();
  }).next().hide();
  //----------------------------
  $('.accordion4').click(function() {
    $(this).toggleClass("selected").next().slideToggle();
  }).next().hide();
  //----------------------------
  $('.accordion5').click(function() {
    $('.accordion5').removeClass("selected").next().slideUp();
    $(this).toggleClass("selected").next().slideToggle();
  }).next().hide();
  //----------------------------
  $('.accordion6').click(function() {
    $(this).toggleClass("selected").next().slideToggle();
  }).next().hide();

  $('.accordion_open').toggle(
    function() {
       $('.accordion6').addClass("selected").next().slideDown();
       $(this).text("CLOSE");
      },
      function() {
        $('.accordion6').removeClass("selected").next().slideUp();
        $(this).text("OPEN");
      }
  );
});
})(jQuery);