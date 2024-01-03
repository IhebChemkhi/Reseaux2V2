import QtQuick 2.0
import QtLocation 5.6
import QtPositioning 5.6

Rectangle {
    id: window
    property double oldLat: 47.750839
    property double oldLng: 7.335888
    property double minX: 47.0
    property double minY: 9.0
    property double maxX: 70.0
    property double maxY: .0
    property var node: nodeData

    property var ways: waysData
    property int sideLength: 40
    property color hexagonColor: "green"
    Plugin {
        id: mapPlugin
        name: "osm"

    }


    // Create a button to generate the hexagonal grid

    Map {
        id: map
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(oldLat, oldLng);
        zoomLevel: 15
    }
    Plugin {
        id: itemsOverlayPlugin
        name: "itemsoverlay"
    }
    Map {
        id: overlayMap
        anchors.fill: parent
        plugin: itemsOverlayPlugin
        center: map.center
        zoomLevel: map.zoomLevel
        color: "transparent"

        Component.onCompleted: {
            console.log("overlayMap is loaded");

        }

        Component {
            id: hexagonComponent
            MapPolygon {
                border.color: 'red'
                border.width: 1
                opacity: 0.7

                property color originalColor: "transparent"


                property int hexagonId: modelData
                property real r: 0.001155 * 2 // The radius of the hexagon, adjust this to change the size
                property real w: Math.sqrt(3) * r // Width of the hexagon
                property real d: 1.5 * r // Adjusted vertical separation between hexagons
                property real row: Math.floor(hexagonId / 13)
                property real col: hexagonId % 13
                property real xOffset: (row % 2) * (w / 2)
                property real centerX: 47.7445 - 0.019 + col * w + xOffset
                property real centerY: 7.3400 - 0.043 + row * d

                function hexVertex(angle) {
                    return QtPositioning.coordinate(centerX + r * Math.sin(angle), centerY + r * Math.cos(angle));
                }

                path: [
                    hexVertex(Math.PI / 3 * 0),
                    hexVertex(Math.PI / 3 * 1),
                    hexVertex(Math.PI / 3 * 2),
                    hexVertex(Math.PI / 3 * 3),
                    hexVertex(Math.PI / 3 * 4),
                    hexVertex(Math.PI / 3 * 5)
                ]
            }
        }

        Repeater {
            id: hexagonRepeater
            model: 312 // Number of hexagons to create
            delegate: hexagonComponent
            Component.onCompleted: {
                console.log("hexagonRepeater is loaded, count:", count);
            }
        }

        Component {
            id: carComponent

            MapQuickItem {
                id: carItem
                property int currentNodeIndex: 0
                property var currentWay: ways[94]
                property int currentWayIndex: 0
                Component.onCompleted: {

                    if (ways.length > 0 && ways[0].nodeIds.length > 0) {
                        var firstNodeId = ways[0].nodeIds[0];
                        for (var i = 0; i < node.length; i++) {
                            if (node[i].id === firstNodeId) {
                                carItem.coordinate = QtPositioning.coordinate(node[i].lat, node[i].lon);
                                break;
                            }
                        }
                    }
                }
                sourceItem: Rectangle {
                    id: carCircle
                    width: 10
                    height: 10
                    color: "blue"
                    radius: width / 2
                }

                Timer {

                    interval: 2000
                    running: ways.length > 0
                    repeat: true

                    onTriggered: {
                        var currentWay = ways[currentWayIndex];
                        console.log("Current way", currentWay.id);
                        if (currentNodeIndex < currentWay.nodeIds.length) {
                            var nodeId = currentWay.nodeIds[currentNodeIndex];
                            for (var i = 0; i < node.length; i++) {
                                if (node[i].id === nodeId) {
                                    carItem.coordinate = QtPositioning.coordinate(node[i].lat, node[i].lon);
                                    currentNodeIndex++;
                                    break;
                                }
                            }
                        } else {
                            // Move to the next way
                            currentNodeIndex = 0;
                            currentWayIndex = (currentWayIndex + 1) % ways.length;
                        }
                    }
                }
            }
        }


        // Créer la voiture
        Repeater {
            model: 1 // Nombre de voitures
            delegate: carComponent
        }
    }
}



