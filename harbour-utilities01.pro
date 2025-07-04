# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-utilities01

CONFIG += sailfishapp

SOURCES += src/harbour-utilities01.cpp \
    src/logic.cpp

HEADERS += \
    src/logic.h

DISTFILES += qml/harbour-utilities01.qml \
    qml/components/PageStackProxy.qml \
    qml/components/RoundedImage.qml \
    qml/components/Shared.qml \
    qml/cover/CoverPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/RepoPage.qml \
    qml/pages/ReposPage.qml \
    qml/pages/SecondPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/WelcomePage.qml \
    rpm/harbour-utilities01.changes.in \
    rpm/harbour-utilities01.changes.run.in \
    rpm/harbour-utilities01.spec \
    translations/*.ts \
    harbour-utilities01.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-utilities01-ru.ts \
    translations/harbour-utilities01-it.ts

images.files = images
images.path = /usr/share/$${TARGET}

python.files = python
python.path = /usr/share/$${TARGET}

INSTALLS += images python
