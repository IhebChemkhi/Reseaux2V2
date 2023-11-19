import QtQuick 2.0
import QtLocation 5.6
import QtPositioning 5.6

Rectangle {
    id: window
    property double oldLat: 47.750839
    property double oldLng: 7.335888
    property Component comMarker: mapMarker

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    Map {
        id: mapView
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(oldLat, oldLng);
        zoomLevel: 12
        MapPolyline {
                    line.color: "blue" // Set the line color
                    line.width: 3 // Set the line width
                    path: [
                       // Set starting coordinates of the line
                        QtPositioning.coordinate(47.761542, 7.335888), // Set ending coordinates of the line
                        QtPositioning.coordinate(47.756691, 7.348272),
                        QtPositioning.coordinate(47.745987, 7.348272),
                        QtPositioning.coordinate(47.740135, 7.335888),
                        QtPositioning.coordinate(47.745987, 7.323505),
                        QtPositioning.coordinate(47.756691, 7.323505),
                        QtPositioning.coordinate(47.761542, 7.335888)

                        // Add more coordinates to create a more complex line if needed
                    ]
                }
    }

    function setCenter(lat, lng) {
        mapView.pan(oldLat - lat, oldLng - lng)
        oldLat = lat
        oldLng = lng
    }

    function addMarker(lat, lng) {
        var item = comMarker.createObject(window, {
                                           coordinate: QtPositioning.coordinate(lat, lng)
                                          })
        mapView.addMapItem(item)
    }

    Component {
        id: mapMarker
        MapQuickItem {
            id: markerImg
            anchorPoint.x: image.width/4
            anchorPoint.y: image.height
            coordinate: position

            sourceItem: Image {
                id: image
                source: "http://maps.gstatic.com/mapfiles/ridefinder-images/mm_20_red.png"
            }
        }
    }
}
