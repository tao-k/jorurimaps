MAP
  NAME wms_test
  SIZE 500 500           #画像size
  EXTENT -25000000 -25000000 25000000 25000000   #出力範囲の座標
  STATUS ON              #地図を表示するか
  UNITS DD               #地図の単位(DD は緯度経度)
  IMAGECOLOR 255 255 255 #背景色R G B
  IMAGETYPE PNG
  TRANSPARENT ON
  FONTSET ./fontfile
  DEBUG ON

  WEB
    IMAGEPATH "/html/www/tmp/"
    IMAGEURL "/tmp/"
      METADATA
      "wfs_title"            "GMap WFS Demo Server"  ## REQUIRED
      "wfs_onlineresource"   "http://localhost/cgi-bin/mapserv.exe?"  ## Recommended
      "wfs_srs"               "EPSG:4326"  ## Recommended
      "ows_schemas_location" "http://ogc.dmsolutions.ca"  ## Optional
    END
  END
  PROJECTION
    "init=epsg:4326"
  END
  Symbol
    Name 'circle'
    Type ELLIPSE
    Filled TRUE
    Points
      1 1
    END
  END


  OUTPUTFORMAT
    NAME "json_vector_layer"
    DRIVER "TEMPLATE"
    MIMETYPE "application/json; subtype=geojson"
    FORMATOPTION "FILE=templates/json_point_layer.tmpl"
  END

 # for wfs test



 LAYER
    CONNECTIONTYPE postgis
    NAME "vector_layer"
    CONNECTION "user=joruri dbname=joruri_maps host=127.0.0.1"
    DATA "g from gis_layer_data using srid=4326"
    DUMP TRUE
    METADATA
        "wfs_srs"         "EPSG:4326"
        "gml_featureid"   "rid"
        "wfs_title"       "vector_layer"
        "wfs_typename"   "vector_layer"
        "gml_include_items"       "all"
        "wfs_version"     "1.1.0"
        "wfs_enable_request" "*"
        "wfs_getfeature_formatlist" "json_vector_layer"
        "wfs_formats" "json_vector_layer"
        "gml_types" "auto"
    END
    PROJECTION
        "init=epsg:4326"
    END

    STATUS ON
    TYPE POINT
    CLASS
      STYLE
        COLOR 0 255 255
        SYMBOL 'circle'
        SIZE 13
      END
    END
 END

END
