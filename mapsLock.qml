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

    property int sideLength: 40
    property color hexagonColor: "green"
    function findNodeById(nodeId) {
        for (var i = 0; i < nodeData.length; i++) {
            if (nodeData[i].id === nodeId) {
                return nodeData[i];
            }
        }
        return null; // Retourner null si le nœud n'est pas trouvé
    }
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
        zoomLevel: 13
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

        Component{
            id:carComponent

            MapQuickItem {
                id: carItem
                property int currentNodeIndex: 0
                property var currentWay: waysData && waysData.length > 0 ? waysData[0] : null

                sourceItem: Rectangle {
                    id: carCircle
                    width: 10
                    height: 10
                    color: "blue"
                    radius: width / 2
                }

                Component.onCompleted: {
                    //console.log("waysData:", JSON.stringify(waysData));
                    //console.log("nodeData:", JSON.stringify(nodeData));

                    if (currentWay && currentWay.nodeIds && currentWay.nodeIds.length > 0) {
                        var firstNodeId = currentWay.nodeIds[0];
                        var firstNode = findNodeById(firstNodeId);
                        if (firstNode) {
                            carItem.coordinate = QtPositioning.coordinate(firstNode.lat, firstNode.lon);
                        } else {
                            console.log("First node is undefined for nodeId:", firstNodeId);
                        }
                    } else {
                        console.log("Current way is undefined or empty");
                    }
                }

                Timer {
                    interval: 1000
                    running: currentWay && currentWay.nodeIds && currentWay.nodeIds.length > 0
                    repeat: true

                    onTriggered: {
                        if (currentNodeIndex < currentWay.nodeIds.length) {
                            var nextNodeId = currentWay.nodeIds[currentNodeIndex];
                            var nextNode = findNodeById(nextNodeId);
                            if (nextNode) {
                                carItem.coordinate = QtPositioning.coordinate(nextNode.lat, nextNode.lon);
                                currentNodeIndex = (currentNodeIndex + 1) % currentWay.nodeIds.length;
                            } else {
                                console.log("Next node is undefined for nodeId:", nextNodeId);
                            }
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


