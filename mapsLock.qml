import QtQuick 2.15
import QtPositioning 5.11
import QtLocation 5.11
Rectangle {
    id:window
    property double latitude: 50.5072
    property double longitude: 0.1276
    property Component localmarker: marker
    Plugin{
        id:googlemapview
        name:"osm"


    }
    Map{
        id:mapview
        anchors.fill: parent
        plugin: googlemapview
        center: QtPositioning.coordinate(latitude,longitude)
        zoomLevel: 8
    }
}
