TARGET = qml_scopic_delivery
TEMPLATE = app

QT += qml network quick positioning location
SOURCES += main.cpp

# Workaround for QTBUG-38735
QT_FOR_CONFIG += location-private
qtConfig(geoservices_mapboxgl): QT += sql
qtConfig(geoservices_osm): QT += concurrent

RESOURCES += \
    scopicdelivery.qrc

OTHER_FILES +=scopicdelivery.qml \
    helper.js \
    map/MapComponent.qml \
    map/MapSliders.qml \
    map/Marker.qml \
    menus/MainMenu.qml \
    menus/MapPopupMenu.qml \
    menus/MarkerPopupMenu \
    forms/Message.qml \
    forms/MessageForm.ui.qml \
    forms/Locale.qml \
    forms/LocaleForm.ui.qml \
    forms/RouteList.qml \
    forms/RouteListDelegate.qml \
    forms/RouteListHeader.qml

#target.path = $$[QT_INSTALL_EXAMPLES]/location/mapviewer
INSTALLS += target
