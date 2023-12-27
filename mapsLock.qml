import QtQuick 2.0
import QtLocation 5.6
import QtPositioning 5.6

Rectangle {
    id: window
    property double oldLat: 47.750839
    property double oldLng: 7.335888
    property Component comMarker: mapMarker

    property double minX: 47.0
    property double minY: 9.0
    property double maxX: 70.0
    property double maxY: .0
    property int sideLength: 40

    property color hexagonColor: "green"

    Plugin {
        id: mapPlugin
        name: "osm"
    }


    // Create a button to generate the hexagonal grid

    Map {
        id: mapView
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(oldLat, oldLng);
        zoomLevel: 12
        property var dynamicPolyline: null

        property var poly : []


        Component.onCompleted: {
            var coordinates = [
                // Set starting coordinates of the line
                 QtPositioning.coordinate(47.761542, 7.335888), // Set ending coordinates of the line
                 QtPositioning.coordinate(47.756691, 7.348272),
                 QtPositioning.coordinate(47.745987, 7.348272),
                 QtPositioning.coordinate(47.740135, 7.335888),
                 QtPositioning.coordinate(47.745987, 7.323505),
                 QtPositioning.coordinate(47.756691, 7.323505),
                 QtPositioning.coordinate(47.761542, 7.335888)
             ];

            //  recuperer dynamiquement les points et tracer par une boucle les polygones

            var dynamicPolylineComponent = Qt.createQmlObject(
                'import QtLocation 5.6; MapPolyline { line.color: "red"; line.width: 3; path: ' + JSON.stringify(coordinates) + '; }',
                mapView,
                'dynamicPolyline'
            );
            var polygonn = generatePolygons();


            console.log(polygonn.length)
            for(var i = 0;i<polygonn.length;i++){
                mapView.addMapItem(polygonn[i])
                console.log(i)
            }

            mapView.addMapItem(dynamicPolylineComponent);



        }


        function generatePolygonsCoordinates(){

        }

        function generatePolygons() {
                // Create a list to store the polygons
                var polygons = []

                // Calculate the starting coordinates for the polygons
                var startX = oldLat + sideLength / 2
                var startY = oldLng + sideLength * 0.75 / 2

                // Iterate over the area boundaries, generating polygons within the range
                for (var y = startY; y < 90; y += sideLength * 0.75) {
                    for (var x = startX; x < 90; x += sideLength) {
                        // Create a polygon with hexagonal vertices
                        var polygonPoints = [
                            QtPositioning.coordinate(x, y),
                            QtPositioning.coordinate(x + sideLength * 0.75, y - sideLength * 0.25),
                            QtPositioning.coordinate(x + sideLength, y - sideLength * 0.5),
                            QtPositioning.coordinate(x + sideLength * 0.75, y - sideLength * 0.75),
                            QtPositioning.coordinate(x + sideLength / 2, y - sideLength),
                            QtPositioning.coordinate(x - sideLength * 0.25, y - sideLength * 0.75),
                            QtPositioning.coordinate(x, y)
                        ]

                        var polygon = Qt.createQmlObject(
                                    'import QtLocation 5.6; MapPolyline { line.color: "black"; line.width: 3; path: ' + JSON.stringify(polygonPoints) + '; }',
                                    mapView,
                                    'dynamicPolyline'+x+y
                                );
                        polygons.push(polygon)


                    }

                    // Adjust the starting x-coordinate for the next row of polygons
                    startX -= sideLength / 2
                }

                console.log(polygons)

                // Return the list of polygons
                return polygons
            }


//        MapPolyline {
//                    line.color: "blue" // Set the line color
//                    line.width: 3 // Set the line width

//                    path: [
//                       // Set starting coordinates of the line
//                        QtPositioning.coordinate(47.761542, 7.335888), // Set ending coordinates of the line
//                        QtPositioning.coordinate(47.756691, 7.348272),
//                        QtPositioning.coordinate(47.745987, 7.348272),
//                        QtPositioning.coordinate(47.740135, 7.335888),
//                        QtPositioning.coordinate(47.745987, 7.323505),
//                        QtPositioning.coordinate(47.756691, 7.323505),
//                        QtPositioning.coordinate(47.761542, 7.335888)
//                    ]
//                }

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
