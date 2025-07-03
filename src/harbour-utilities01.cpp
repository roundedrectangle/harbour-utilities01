#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QScopedPointer>
#include <QQuickView>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QQmlContext>

#include <sailfishapp.h>

#include "logic.h"

int main(int argc, char *argv[]) {
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    QQmlContext *context = view.data()->rootContext();
    const char *uri = "harbour.utilities01";
    const char *internalUri = "harbour.utilities01.internal";

    view->engine()->addImportPath(SailfishApp::pathTo("qml/modules").toString()); // Opal

    Logic *logic = new Logic(view->engine(), view.data());
    context->setContextProperty("logic", logic);
    qmlRegisterUncreatableType<Logic>(internalUri, 1, 0, "Logic", QString());

    view->setSource(SailfishApp::pathToMainQml());
    view->show();
    return app->exec();
}
