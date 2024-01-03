#ifndef NODE_H
#define NODE_H

#include <QObject>

class Node : public QObject {
    Q_OBJECT
    Q_PROPERTY(quint64 id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(double lat READ lat WRITE setLat NOTIFY latChanged)
    Q_PROPERTY(double lon READ lon WRITE setLon NOTIFY lonChanged)

public:
    explicit Node(QObject *parent = nullptr) : QObject(parent), m_id(0), m_lat(0.0), m_lon(0.0) {}

    quint64 id() const { return m_id; }
    double lat() const { return m_lat; }
    double lon() const { return m_lon; }

public slots:
    void setId(quint64 id) {
        if (m_id == id)
            return;
        m_id = id;
        emit idChanged();
    }

    void setLat(double lat) {
        if (qFuzzyCompare(m_lat, lat))
            return;
        m_lat = lat;
        emit latChanged();
    }

    void setLon(double lon) {
        if (qFuzzyCompare(m_lon, lon))
            return;
        m_lon = lon;
        emit lonChanged();
    }

signals:
    void idChanged();
    void latChanged();
    void lonChanged();

private:
    quint64 m_id;  // Changed from long to quint64
    double m_lat;
    double m_lon;
};

#endif // NODE_H
