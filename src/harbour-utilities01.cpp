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

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/harbour-utilities01.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //   - SailfishApp::pathToMainQml() to get a QUrl to the main QML file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    QQmlContext *context = view.data()->rootContext();
    const char *uri = "harbour.utilities01";

    view->engine()->addImportPath(SailfishApp::pathTo("qml/modules").toString()); // Opal

    Logic *logic = new Logic(view->engine(), view.data());
    context->setContextProperty("logic", logic);
    qmlRegisterUncreatableType<Logic>(uri, 1, 0, "Logic", QString());

    view->setSource(SailfishApp::pathToMainQml());
    view->show();
    return app->exec();
}
