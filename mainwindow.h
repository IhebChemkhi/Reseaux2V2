#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "Node.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow {
    Q_OBJECT
    Q_PROPERTY(int numberOfCars READ getNumberOfCars WRITE setNumberOfCars NOTIFY numberOfCarsChanged)

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

    int getNumberOfCars() const { return numberOfCars; }
    Q_INVOKABLE void setNumberOfCars(int count);

signals:
    void numberOfCarsChanged(int numCars);

public slots:
    void updateNumberOfCars();
    void testSlot(int numCars);


private:
    Ui::MainWindow *ui;
    QMap<quint64, Node*> nodes;
    int numberOfCars;
};

#endif // MAINWINDOW_H
