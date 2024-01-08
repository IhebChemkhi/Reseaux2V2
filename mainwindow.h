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
    Q_PROPERTY(int temps READ getTemps WRITE setTemps NOTIFY tempsChanged)

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

    int getNumberOfCars() const { return numberOfCars; }
    int getTemps() const {return temps;}
    Q_INVOKABLE void setNumberOfCars(int count);
    Q_INVOKABLE void setTemps(int count);

signals:
    void numberOfCarsChanged(int numCars);
    void tempsChanged(int temps);

public slots:
    void updateNumberOfCars();
    void updateTemps();
    void testSlot(int numCars);


private:
    Ui::MainWindow *ui;
    QMap<quint64, Node*> nodes;
    int numberOfCars;
    int temps;
};

#endif // MAINWINDOW_H
