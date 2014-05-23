jQuery( function() {
    jQuery( '#tabs > ul > li' ) . click( function () {
        var str = jQuery( 'input', this ) . val();
        jQuery( '#tabs > div' ) . not( str ) . css( 'display', 'none' );
        jQuery( str ) . css( 'display', 'block' );
        jQuery( this ) . css( { 'background': '#FFBEFC', 'color': '#000' } );
        jQuery( '#tabs > ul > li' ) . not( this ) . css( { 'background': '-webkit-gradient(linear, left top, left bottom, from(#446BDA), to(#1647D0))', 'background-color': '#446BDA', 'color': '#FFF' } );
    } ) . first() . click();
} );
