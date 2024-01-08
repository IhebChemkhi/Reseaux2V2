import QtQuick 2.12

import QtLocation 6.6
import QtPositioning 6.6
import QtQuick.Controls 2.5


Rectangle {
    id: window
    width: 640
    height: 480
    property double oldLat: 47.750839
    property double oldLng: 7.335888
    property double minX: 47.0
    property double minY: 9.0
    property double maxX: 70.0
    property double maxY: .0
    property bool timerRunning: true
    property var node: nodeData
    property var ways: waysData
    property int numberOfCars: 15
    property int sideLength: 40
    property color hexagonColor: "green"
    property real coverageRadius: 50
    property var voitures: []

    Plugin {
        id: mapPlugin
        name: "osm"
        PluginParameter {
            name: "osm.mapping.providersrepository.disabled"
            value: "true"
        }
        PluginParameter {
            name: "osm.mapping.providersrepository.address"
            value: "http://maps-redirect.qt.io/osm/5.6/"
        }


    }
    function initVoitures() {
        window.voitures = [];
        for (var i = 0; i < mainWindow.numberOfCars; i++) {
            window.voitures.push({lat: 0, lon: 0}); // Initialisez avec des valeurs par défaut
            console.log("Voiture " + i + " initialisée : ", JSON.stringify(window.voitures[i]));

        }
        console.log("Total des voitures initialisées : ", window.voitures.length);
    }
    function calculateDistance(lat1, lon1, lat2, lon2) {
        var R = 6371e3; // Rayon de la Terre en mètres
        var radianLat1 = lat1 * Math.PI / 180; // Convertir en radians
        var radianLat2 = lat2 * Math.PI / 180;
        var deltaLat = (lat2-lat1) * Math.PI / 180;
        var deltaLon = (lon2-lon1) * Math.PI / 180;

        var a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) +
                Math.cos(radianLat1) * Math.cos(radianLat2) *
                Math.sin(deltaLon/2) * Math.sin(deltaLon/2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

        var distance = R * c; // Distance en mètres
        return distance;
    }
    function updateCarRepeater() {
        carRepeater.model = 0;
        carRepeater.model = mainWindow.numberOfCars;
    }
    property var circles: [] // Array to hold MapCircle instances




    // Create a button to generate the hexagonal grid

    Map {
        id: map
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(oldLat, oldLng);
        zoomLevel: 15
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            property point lastMousePos

            onPressed: function(mouse) {
                lastMousePos = Qt.point(mouse.x, mouse.y);
            }

            onPositionChanged: function(mouse) {
                if (mouseArea.pressedButtons & Qt.LeftButton) {
                    var dx = mouse.x - lastMousePos.x;
                    var dy = mouse.y - lastMousePos.y;

                    // Conversion des déplacements en pixels en changements de coordonnées géographiques
                    // Cette conversion est basique et peut nécessiter des ajustements en fonction du niveau de zoom et de la projection de la carte
                    var newCenterLat = map.center.latitude + dy * 0.00010; // Facteur d'ajustement pour la latitude
                    var newCenterLng = map.center.longitude - dx * 0.00010; // Facteur d'ajustement pour la longitude

                    map.center = QtPositioning.coordinate(newCenterLat, newCenterLng);
                    lastMousePos = Qt.point(mouse.x, mouse.y);
                }
            }

            onWheel: function(wheel) {
                var factor = wheel.angleDelta.y > 0 ? 1.1 : 0.9;
                map.zoomLevel *= factor;
            }
        }
    }


    Plugin {
        id: itemsOverlayPlugin
        name: "itemsoverlay"
    }
    Canvas {
        id:lineCanvas
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = "red";
            ctx.lineWidth = 2;

            for (var i = 0; i < mainWindow.numberOfCars; i++) {
                for (var j = i + 1; j < mainWindow.numberOfCars; j++) {
                    var car1 = window.voitures[i];
                    var car2 = window.voitures[j];

                    var distance = calculateDistance(car1.lat, car1.lon, car2.lat, car2.lon);

                    if (distance < window.coverageRadius * 2) {
                        console.log("Dessin d'une ligne entre les voitures " + i + " et " + j);
                        var car1Pos = map.fromCoordinate(QtPositioning.coordinate(car1.lat, car1.lon));
                        var car2Pos = map.fromCoordinate(QtPositioning.coordinate(car2.lat, car2.lon));

                        ctx.beginPath();
                        ctx.moveTo(car1Pos.x, car1Pos.y);
                        ctx.lineTo(car2Pos.x, car2Pos.y);
                        ctx.stroke();
                    }
                }
            }
        }
    }


    Map {
        id: overlayMap
        anchors.fill: parent
        plugin: itemsOverlayPlugin
        center: map.center
        zoomLevel: map.zoomLevel
        color: "transparent"

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
            id: circleComponent
            MapCircle {
                radius: 50
                color: "transparent"
                border.color: "green"
                border.width: 1
            }
        }

        MapItemView {
            model: mainWindow.numberOfCars // Utilisez le nombre de voitures comme modèle

            delegate: MapQuickItem {
                property int currentNodeIndex: 0
                property var currentWay: assignNewWay()

                function assignNewWay() {
                    return waysData[Math.floor(Math.random() * waysData.length)]
                }

                sourceItem: Item {
                    width: 10
                    height: 10

                    Rectangle {
                        width: 10
                        height: 10
                        color: "blue"
                        radius: 5 // Half of width to create a circle
                        anchors.centerIn: parent
                        Component.onCompleted: {
                            initVoitures();
                            console.log(JSON.stringify(voitures));
                        }
                    }

                    // Additional rectangle to represent the coverage radius
                    Rectangle {
                        width: coverageRadius * 2 // Adjust size accordingly
                        height: coverageRadius * 2
                        color: "green"
                        opacity: 0.3
                        radius: coverageRadius // Half of width/height to create a circle
                        anchors.centerIn: parent
                    }

                }

                Timer {
                    id:myTimer
                    interval: mainWindow.temps
                    running: window.timerRunning && currentWay.nodeIds.length > 0
                    repeat: true
                    onTriggered: {
                        if (currentNodeIndex < currentWay.nodeIds.length) {
                            var nodeId = currentWay.nodeIds[currentNodeIndex]
                            var node = nodeData.find(function(n) { return n.id === nodeId })
                            if (node) {

                                if (window.voitures && currentNodeIndex < window.voitures.length) {
                                    window.voitures[currentNodeIndex].lat = node.lat;
                                    window.voitures[currentNodeIndex].lon = node.lon;
                                    lineCanvas.requestPaint();
                                }

                                coordinate = QtPositioning.coordinate(node.lat, node.lon)
                                currentNodeIndex++

                            }
                        } else {
                            currentWay = assignNewWay()
                            currentNodeIndex = 0
                        }

                    }
                }

            }
        }
    }


    Connections {
        target: mainWindow
        function onNumberOfCarsChanged() {

            console.log("Nombre de voitures mis à jour :", mainWindow.numberOfCars);
            // La mise à jour du nombre de voitures sera gérée automatiquement par le modèle
        }
    }

    Button {
        id: zoomInButton
        text: "Zoom In"
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.bottomMargin: 10

        onClicked: {
            map.zoomLevel += 1
        }
    }
    Button {
        id: zoomOutButton
        text: "Zoom out"
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: zoomInButton.bottom // Place le bouton "Zoom Out" en dessous de "Zoom In"
        anchors.topMargin: 10 // Marge supérieure pour espacer les boutons

        onClicked: {
            map.zoomLevel -= 1
        }
    }
    Button {
        id:arreterTimer
        text: "arreter Timer"
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: zoomOutButton.bottom // Place le bouton "Zoom Out" en dessous de "Zoom In"
        anchors.topMargin: 10 // Marge supérieure pour espacer les boutons

        onClicked: {

            window.timerRunning = false;
        }
    }
    Button {
        text: "demarrer Timer"
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: arreterTimer.bottom // Place le bouton "Zoom Out" en dessous de "Zoom In"
        anchors.topMargin: 10 // Marge supérieure pour espacer les boutons

        onClicked: {

            window.timerRunning = true;
        }
    }


}






