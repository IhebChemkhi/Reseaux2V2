#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QQuickWidget>
MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    ui->quickWidget_mapView->setSource(QUrl(QStringLiteral("qrc:/mapsLock.qml")));
    ui->quickWidget_mapView->show();
}

MainWindow::~MainWindow()
{
    delete ui;
}

