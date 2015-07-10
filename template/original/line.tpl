MAP
  NAME wms_test
  SIZE 500 500           #画像size
  EXTENT 132 32 136 36   #出力範囲の座標
  STATUS ON              #地図を表示するか
  UNITS DD               #地図の単位(DD は緯度経度)
  IMAGECOLOR 255 255 255 #背景色R G B
  IMAGETYPE PNG
  TRANSPARENT ON
  FONTSET ./fontfile
  WEB
    IMAGEPATH "/html/www/tmp/"
    IMAGEURL "/tmp/"
    METADATA
      "wms_title" "wms_overlays"
      "wms_onlineresource" "http://localhost/cgi-bin/mapserv?map=mapfiles/testmap.map&"
      "wms_srs"  "EPSG:4326 EPSG:900913 EPSG:2446"
      "ows_enable_request" "*"
    END
  END
  PROJECTION
    "init=epsg:2446"
  END

 Symbol
  Name 'circle'
  Type ELLIPSE
  Filled TRUE
  Points
  1 1
  END
 END

  LAYER
    NAME "##layer_name##"
    CONNECTIONTYPE postgis
    CONNECTION "user=joruri dbname=joruri_maps host=127.0.0.1"
    DATA "g from gis_layer_import_data using srid=4326"
    FILTER "layer_id = ##layer_id##"
    TYPE LINE
    ##label_item##
    METADATA
      "DESCRIPTION" "##layer_name##"
      "wms_title" "##layer_name##"
      "wms_srs" "EPSG:4612 EPSG:4326 EPSG:2446"
      "layer_encoding" "SJIS"
    END

   CLASS
      NAME 'areas'
      STYLE
        ##outline_color##
        WIDTH ##width##
      END
      LABEL
        COLOR  ##label_color##
        OUTLINECOLOR 255 255 255
        ANGLE AUTO
        FONT gothic
        TYPE truetype
        SIZE ##label_size##
        POSITION AUTO
        PARTIALS FALSE
        MINFEATURESIZE 40
      END
    END
    PROJECTION
      "init=epsg:4326"
    END
  END






END