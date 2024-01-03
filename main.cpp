#include "mainwindow.h"
#include "node.h"
#include <QApplication>
#include <math.h>
#include <iostream>
#include <QFile>
#include <QQmlContext>
#include <QXmlStreamReader>
#include <QQmlApplicationEngine>
#define DEG_TO_RAD (M_PI / 180.0)
#define RAD_TO_DEG (180.0 / M_PI)
//using namespace libsumo;
/*struct Lambert93 {
    double x;
    double y;
};

Lambert93 convertToLambert93(double latitude, double longitude) {
    Lambert93 result;

    // Constants for Lambert 93 projection (approximate values, not exact)
    double lon0 = 3.0;
    double lat0 = 46.5;
    double n = 0.7256077650532670;
    double c = 11754255.4261;
    double xs = 700000.0;
    double ys = 12655612.0499;

    // Convert latitude and longitude from degrees to radians
    double phi = latitude * M_PI / 180.0;
    double lambda = longitude * M_PI / 180.0;

    // Lambert 93 projection calculations (approximate formula)
    double lon_radians = lambda - lon0 * M_PI / 180.0;
    double R = c * exp(-n * log(tan(M_PI / 4.0 + phi / 2.0)));
    result.x = xs + R * sin(lon_radians);
    result.y = ys - R * cos(lon_radians);

    return result;
}*/



#include <QFile>
#include <QXmlStreamReader>

QList<Node> readOsmFile(const QString &fileName) {
    QFile file(fileName);
    if (!file.open(QFile::ReadOnly | QFile::Text)) {
        qDebug() << "Error: Cannot read file" << qPrintable(fileName)
                 << ": " << qPrintable(file.errorString());
        exit(0);
    }

    QXmlStreamReader xmlReader(&file);
    QList<Node> nodes;
    while (!xmlReader.atEnd() && !xmlReader.hasError()) {
        // Lire le fichier XML
        QXmlStreamReader::TokenType token = xmlReader.readNext();

        // Vérifiez si c'est un élément de démarrage
        if (token == QXmlStreamReader::StartElement) {
            if (xmlReader.name().toString() == "node") {
                Node node;
                node.id = xmlReader.attributes().value("uid").toLong();
                node.lat = xmlReader.attributes().value("lat").toDouble();
                node.lon = xmlReader.attributes().value("lon").toDouble();

                nodes.append(node);
                qDebug() << "Nombre de nœuds chargés :" << nodes.count();

            }
        }
    }


    if (xmlReader.hasError()) {
        qDebug() << "XML error: " << xmlReader.errorString();
    }

    file.close();
    return nodes;
}

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    qRegisterMetaType<Node>("Node");
    qRegisterMetaType<QList<Node>>("QList<Node>");
    MainWindow w;
    QQmlApplicationEngine engine;
    QList<Node> n;
    n= readOsmFile("C:/Users/ihebc/OneDrive/Bureau/Reseaux2V2/DonneMap.osm");
    engine.rootContext()->setContextProperty("nodeData", QVariant::fromValue(n));
    engine.load(QUrl(QStringLiteral("qrc:/mapsLock.qml"))); // Chargez votre fichier QML
    /*double latitude = 48.858331; // Paris latitude
        double longitude = 2.321669; // Paris longitude

        Lambert93 lambert93Coord = convertToLambert93(latitude, longitude);

        // Output Lambert 93 coordinates
        std::cout << "Lambert 93 coordinates: (" << lambert93Coord.x << ", " << lambert93Coord.y << ")" << std::endl;*/
    w.show();

    return a.exec();
}
