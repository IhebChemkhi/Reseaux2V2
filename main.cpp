#include "mainwindow.h"

#include <QApplication>
#include <QUrl>
#include <qqmlapplicationengine.h>
#include <qquickwidget.h>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/mapsLock.qml"))); // Replace with your main QML file path
     return a.exec();
}
