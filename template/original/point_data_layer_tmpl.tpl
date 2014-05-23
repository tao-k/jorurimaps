// mapserver template
[callback](
[resultset layer=vector_layer]
{
  "type": "FeatureCollection",
  "features":[
    [feature trimlast=","]
    {
      "type":"Feature",
      "id":"[rid]",
      "geometry":{
        "type": "Point",
        "coordinates":["[lng]","[lat]"]
      },
      "geometry_name":"g",
      "properties":{
        "gis_layer":"vector_layer",
        "rid":"[rid]",
        "icon_id":"[icon_id]",
        "layer_id": "[layer_id]"
      }
    },
    [/feature]
  ]
}
[/resultset]
)
