#include "logic.h"

Logic::Logic(QQmlEngine *engine, QObject *parent) :
    QObject(parent),
    qmlEngine(engine)
{

}

void Logic::addImportPath(const QString &path) {
    this->qmlEngine->addImportPath(path);
}

void Logic::removeImportPath(const QString &path) {
    QStringList paths(this->qmlEngine->importPathList());
    paths.removeAll(path);
    this->qmlEngine->setImportPathList(paths);
}
