#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "Node.h"
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QQuickWidget>
#include <QXmlStreamReader>
#include <QFile>
#include <QDebug>

struct Way {
    quint64 id;
    QVector<quint64> nodeIds;  // IDs des nœuds
};
bool isNodeIdPresent(const QMap<quint64, Node*>& nodes, quint64 nodeId) {

    if (nodes.contains(nodeId)){
        return true;
    }

    return false;
}


bool isNodeIdPresent(const QVariantList &nodeList, quint64 nodeId) {
    for (const QVariant &nodeVariant : nodeList) {
        QVariantMap nodeMap = nodeVariant.toMap();
        if (nodeMap.value("id").toULongLong() == nodeId) {
            return true;
        }
    }
    return false;
}
QMap<quint64, Node*> readAllOsmNodes(const QString &fileName) {
    QMap<quint64, Node*> nodes;
    QFile file(fileName);

    if (!file.open(QFile::ReadOnly | QFile::Text)) {
        qDebug() << "Error: Cannot read file" << qPrintable(fileName)
                 << ": " << qPrintable(file.errorString());
        return nodes;
    }

    QXmlStreamReader xmlReader(&file);

    while (!xmlReader.atEnd() && !xmlReader.hasError()) {
        xmlReader.readNext();
        if (xmlReader.isStartElement() && xmlReader.name().toString() == "node") {
            bool ok;
            quint64 nodeId = xmlReader.attributes().value("id").toULongLong(&ok);
            double lat = xmlReader.attributes().value("lat").toDouble();
            double lon = xmlReader.attributes().value("lon").toDouble();

            if (ok) {
                Node* node = new Node();
                node->setId(nodeId);
                node->setLat(lat);
                node->setLon(lon);
                nodes.insert(nodeId, node);
            } else {
                qDebug() << "Failed to read node ID";
            }
        }
    }

    if (xmlReader.hasError()) {
        qDebug() << "XML error: " << xmlReader.errorString();
    }

    file.close();
    return nodes;
}

QVector<Way> readOsmWays(const QString &fileName) {
    QFile file(fileName);
    QVector<Way> ways;
    QXmlStreamReader xmlReader(&file);

    if (!file.open(QFile::ReadOnly | QFile::Text)) {
        qDebug() << "Error: Cannot read file" << qPrintable(fileName)
                 << ": " << qPrintable(file.errorString());
        return ways;
    }

    while (!xmlReader.atEnd() && !xmlReader.hasError()) {
        xmlReader.readNext();
        if (xmlReader.isStartElement() && xmlReader.name().toString() == "way") {
            Way way;
            way.id = xmlReader.attributes().value("id").toLong();
            while (!(xmlReader.tokenType() == QXmlStreamReader::EndElement && xmlReader.name().toString() == "way")) {
                xmlReader.readNext();
                if (xmlReader.tokenType() == QXmlStreamReader::StartElement && xmlReader.name().toString() == "nd") {
                    bool ok;
                    quint64 nodeId = xmlReader.attributes().value("ref").toULongLong(&ok);
                    if (ok) {
                        way.nodeIds.push_back(nodeId);
                        //qDebug()<< "nodes for "<< way.id << "/*/ id "<<way.nodeIds;
                    } else {
                        qDebug() << "Failed to convert node ID for Way" << way.id;
                    }
                }
            }

            ways.push_back(way);

        }
    }


    file.close();
    return ways;
}

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent), ui(new Ui::MainWindow) {
    ui->setupUi(this);

    qRegisterMetaType<Node*>("Node*");
    QString osmFilePath = "C:/Users/ihebc/OneDrive/Bureau/Reseaux2V2/DonneMap.osm";

    // Lire les nœuds
    QMap<quint64, Node*> nodes = readAllOsmNodes(osmFilePath);

    // Convertir les nœuds pour QML
    QVariantList nodeListForQml;
    for (auto *node : nodes) {
        QVariantMap nodeMap;
        nodeMap.insert("id", QVariant::fromValue(node->id()));
        nodeMap.insert("lat", QVariant::fromValue(node->lat()));
        nodeMap.insert("lon", QVariant::fromValue(node->lon()));
        nodeListForQml.append(nodeMap);
    }

    // Lire les chemins
    QVector<Way> ways = readOsmWays(osmFilePath);

    // Convertir les chemins pour QML
    QVariantList wayListForQml;
    for (const Way &way : ways) {
        QVariantMap wayMap;
        wayMap.insert("id", QVariant::fromValue(way.id));

        QVariantList nodeIdList;
        for (quint64 nodeId : way.nodeIds) {
            nodeIdList.append(QVariant::fromValue(nodeId));
        }
        wayMap.insert("nodeIds", nodeIdList);

        wayListForQml.append(wayMap);
    }

    // Passer les données à QML
    ui->quickWidget->engine()->rootContext()->setContextProperty("nodeData", nodeListForQml);
    ui->quickWidget->engine()->rootContext()->setContextProperty("waysData", wayListForQml);

    ui->quickWidget->setSource(QUrl(QStringLiteral("qrc:/mapsLock.qml")));
    ui->quickWidget->show();
}

MainWindow::~MainWindow() {
    for (auto &node : nodes) {
        delete node;
    }
    delete ui;
}
