#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "Node.h"
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QQuickWidget>
#include <QXmlStreamReader>
#include <QFile>
#include <QDebug>

QList<QObject*> readOsmFile(const QString &fileName) {
    QFile file(fileName);
    QList<QObject*> nodes;

    if (!file.open(QFile::ReadOnly | QFile::Text)) {
        qDebug() << "Error: Cannot read file" << qPrintable(fileName)
                 << ": " << qPrintable(file.errorString());
        return nodes;
    }

    QXmlStreamReader xmlReader(&file);
    while (!xmlReader.atEnd() && !xmlReader.hasError()) {
        QXmlStreamReader::TokenType token = xmlReader.readNext();
        if (token == QXmlStreamReader::StartElement) {
            if (xmlReader.name().toString() == "node") {
                Node* node = new Node();
                node->setId(xmlReader.attributes().value("uid").toLong());
                node->setLat(xmlReader.attributes().value("lat").toDouble());
                node->setLon(xmlReader.attributes().value("lon").toDouble());
                nodes.append(node);
            }
        }
    }

    if (xmlReader.hasError()) {
        qDebug() << "XML error: " << xmlReader.errorString();
    }

    file.close();
    return nodes;
}

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent), ui(new Ui::MainWindow) {
    ui->setupUi(this);

    qRegisterMetaType<Node*>("Node*");

    QList<QObject*> nodes = readOsmFile("C:/Users/ihebc/OneDrive/Bureau/Reseaux2V2/DonneMap.osm");
    ui->quickWidget->engine()->rootContext()->setContextProperty("nodeData", QVariant::fromValue(nodes));

    ui->quickWidget->setSource(QUrl(QStringLiteral("qrc:/mapsLock.qml")));
    ui->quickWidget->show();
}

MainWindow::~MainWindow() {
    delete ui;
}
