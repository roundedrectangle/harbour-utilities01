#ifndef LOGIC_H
#define LOGIC_H

#include <QObject>
#include <QQmlEngine>

class Logic : public QObject {
    Q_OBJECT
public:
    explicit Logic(QQmlEngine *engine, QObject *parent = nullptr);

    Q_INVOKABLE void addImportPath(const QString &path);
    Q_INVOKABLE void removeImportPath(const QString &path);

private:
    QQmlEngine *qmlEngine;

signals:

};

#endif // LOGIC_H
