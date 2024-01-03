#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QQuickItem>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    ui->quickWidget->setSource(QUrl(QStringLiteral("qrc:/mapsLock.qml")));
    ui->quickWidget->show();
    // emit addMarker(25.000, 50.000);
}

MainWindow::~MainWindow()
{
    delete ui;
}

