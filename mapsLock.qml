import QtQuick 2.15
import QtLocation 5.15
import QtPositioning 5.15
import QtQuick.Controls 2.15
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
                    value: "https://tile.thunderforest.com/spinal-map/{1}/{1}/{1}.png?apikey=a34e26382bec4f6c89b34976553c33d0" // Use a different OSM tile server URL
                }
        }

        center: QtPositioning.coordinate(51.5072, -0.1276)  // Initial map center
        zoomLevel: 10  // Initial zoom level
    }
}
