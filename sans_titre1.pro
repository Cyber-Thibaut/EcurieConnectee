QT += core gui qml quick mqtt sql charts network

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17

#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    chevalsqlmodel.cpp \
    databasemanager.cpp \
    main.cpp \
    mqttmanager.cpp

HEADERS += \
    chevalsqlmodel.h \
    databasemanager.h \
    mqttmanager.h

FORMS +=

TARGET = EcurieActiveNabou

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /home/pi/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    AccesForm.qml \
    ChevauxForm.qml \
    HomeForm.qml \
    NourritureForm.qml \
    SettingsForm.qml \
    StocksForm.qml \
    main.qml

RESOURCES += \
    qml.qrc
