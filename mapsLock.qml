import QtQuick 2.12
import QtLocation 5.9
import QtPositioning 5.12
import QtQuick.Controls 2.12
ApplicationWindow {
    visible: true
    width: 800
    height: 600

    Map {
        anchors.fill: parent

        plugin: Plugin {
            name: "osm"  // You can use other map plugins, e.g., "esri"
            PluginParameter {
                    name: "osm.mapping.custom.host"
                    value: "https://tile.openstreetmap.org/{x}/{y}/{z}.png" // Use a different OSM tile server URL
            }
        }

        center: QtPositioning.coordinate(51.5072, -0.1276)  // Initial map center
        zoomLevel: 10  // Initial zoom level
    }
}
