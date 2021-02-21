/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtLocation 5.6
import QtPositioning 5.5
import "map"
import "menus"
import "helper.js" as Helper

ApplicationWindow {
    id: appWindow
    property variant map
    property variant parameters

    // Init Makrers. TODO: refact.
    property variant presetMarkers: [
    QtPositioning.coordinate(43.651555254812834, -79.3885123406998 ),
    QtPositioning.coordinate(43.64633368060591, -79.41922375329023 ),
    QtPositioning.coordinate(43.656717852524146, -79.35855996145148 ),
    QtPositioning.coordinate(43.66962464582783, -79.39966545239155 ),
    QtPositioning.coordinate(43.6414313886651, -79.38287232604284 ),
    QtPositioning.coordinate(43.665292087979886, -79.37631350189375 ),
    QtPositioning.coordinate(43.64200867750141, -79.40064036298946 ),
    QtPositioning.coordinate(43.65962915296164, -79.4112779594699 ),
    QtPositioning.coordinate(43.648829269451944, -79.36547611106273 ),
    ];

    function createMap(provider)
    {
        var plugin

        if (parameters && parameters.length>0)
            plugin = Qt.createQmlObject ('import QtLocation 5.6; Plugin{ name:"' + provider + '"; parameters: appWindow.parameters}', appWindow)
        else
            plugin = Qt.createQmlObject ('import QtLocation 5.6; Plugin{ name:"' + provider + '"}', appWindow)

        if (map) {
            map.destroy()
        }

        map = mapComponent.createObject(page);
        map.plugin = plugin;

        for (var i = 0; i<presetMarkers.length; i++) {
              map.addMarkerWithCoordinate(presetMarkers[i])
        }
        map.zoomLevel = map.maximumZoomLevel
        map.fitViewportToMapItems()

        map.forceActiveFocus()
    }

    function getPlugins()
    {
        var plugin = Qt.createQmlObject ('import QtLocation 5.6; Plugin {}', appWindow)
        var myArray = new Array()
        for (var i = 0; i<plugin.availableServiceProviders.length; i++) {
            var tempPlugin = Qt.createQmlObject ('import QtLocation 5.6; Plugin {name: "' + plugin.availableServiceProviders[i]+ '"}', appWindow)
            if (tempPlugin.supportsMapping())
                myArray.push(tempPlugin.name)
        }
        myArray.sort()
        return myArray
    }

    function initializeProviders(pluginParameters)
    {
        var parameters = new Array()
        for (var prop in pluginParameters){
            var parameter = Qt.createQmlObject('import QtLocation 5.6; PluginParameter{ name: "'+ prop + '"; value: "' + pluginParameters[prop]+'"}',appWindow)
            parameters.push(parameter)
        }
        appWindow.parameters = parameters
        var plugins = getPlugins()
        mainMenu.providerMenu.createMenu(plugins)
        for (var i = 0; i<plugins.length; i++) {
            if (plugins[i] === "osm")
                mainMenu.selectProvider(plugins[i])
        }
    }

    title: qsTr("Scopic Delivery")
    height: 600
    width: 800
    visible: true
    menuBar: mainMenu

    MainMenu {
        id: mainMenu

        function setLanguage(lang)
        {
            map.plugin.locales = lang;
            stackView.pop(page)
        }

        onSelectProvider: {
            stackView.pop()
            for (var i = 0; i < providerMenu.items.length; i++) {
                providerMenu.items[i].checked = providerMenu.items[i].text === providerName
            }

            createMap(providerName)
            if (map.error === Map.NoError) {
                selectMapType(map.activeMapType)
                toolsMenu.createMenu(map);

            } else {
                mapTypeMenu.clear();
                toolsMenu.clear();
            }
        }

        onSelectMapType: {
            stackView.pop(page)
            for (var i = 0; i < mapTypeMenu.items.length; i++) {
                mapTypeMenu.items[i].checked = mapTypeMenu.items[i].text === mapType.name
            }
            map.activeMapType = mapType
        }


        onSelectTool: {
            switch (tool) {
            case "routeAroundAll":
                map.calculateVoyagerMarkerRoute()
                break
            case "fitViewport":
                map.fitViewportToMapItems()
                break
            case "Language":
                stackView.pop({item:page, immediate: true})
                stackView.push({ item: Qt.resolvedUrl("forms/Locale.qml") ,
                                   properties: { "locale":  map.plugin.locales[0]}})
                stackView.currentItem.selectLanguage.connect(setLanguage)
                stackView.currentItem.closeForm.connect(stackView.closeForm)
                break
            case "Clear":
                map.clearData()
                break
            case "Prefetch":
                map.prefetchData()
                break
            default:
                console.log("Unsupported operation")
            }
        }

        onToggleMapState: {
            stackView.pop(page)
            switch (state) {
            default:
                console.log("Unsupported operation")
            }
        }
    }

    MapPopupMenu {
        id: mapPopupMenu

        function show(coordinate)
        {
            stackView.pop(page)
            mapPopupMenu.coordinate = coordinate
            mapPopupMenu.markersCount = map.markers.length
            mapPopupMenu.mapItemsCount = map.mapItems.length
            mapPopupMenu.update()
            mapPopupMenu.popup()
        }

        onItemClicked: {
            stackView.pop(page)
            switch (item) {
            case "fitViewport":
                map.fitViewportToMapItems()
                break
            default:
                console.log("Unsupported operation")
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        focus: true
        initialItem: Item {
            id: page

            Text {
                visible: !supportsSsl && map && map.activeMapType && activeMapType.metadata.isHTTPS
                text: "The active map type\n
requires (missing) SSL\n
support"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: appWindow.width / 12
                font.bold: true
                color: "grey"
                anchors.centerIn: parent
                z: 12
            }
        }

        function showMessage(title,message,backPage)
        {
            push({ item: Qt.resolvedUrl("forms/Message.qml") ,
                               properties: {
                                   "title" : title,
                                   "message" : message,
                                   "backPage" : backPage
                               }})
            currentItem.closeForm.connect(closeMessage)
        }

        function closeMessage(backPage)
        {
            pop(backPage)
        }

        function closeForm()
        {
            pop(page)
        }

        function showRouteListPage()
        {
            push({ item: Qt.resolvedUrl("forms/RouteList.qml") ,
                               properties: {
                                   "routeModel" : map.routeModel
                               }})
            currentItem.closeForm.connect(closeForm)
        }
    }

    Component {
        id: mapComponent

        MapComponent{
            width: page.width
            height: page.height
            onSupportedMapTypesChanged: mainMenu.mapTypeMenu.createMenu(map)
            onCoordinatesCaptured: {
                var text = "<b>" + qsTr("Latitude:") + "</b> " + Helper.roundNumber(latitude,4) + "<br/><b>" + qsTr("Longitude:") + "</b> " + Helper.roundNumber(longitude,4)
                stackView.showMessage(qsTr("Coordinates"),text);
            }
            onGeocodeFinished:{
                if (map.geocodeModel.status == GeocodeModel.Ready) {
                    if (map.geocodeModel.count == 0) {
                        stackView.showMessage(qsTr("Geocode Error"),qsTr("Unsuccessful geocode"))
                    } else if (map.geocodeModel.count > 1) {
                        stackView.showMessage(qsTr("Ambiguous geocode"), map.geocodeModel.count + " " +
                                              qsTr("results found for the given address, please specify location"))
                    } else {
                        stackView.showMessage(qsTr("Location"), geocodeMessage(),page)
                    }
                } else if (map.geocodeModel.status == GeocodeModel.Error) {
                    stackView.showMessage(qsTr("Geocode Error"),qsTr("Unsuccessful geocode"))
                }
            }
            onRouteError: stackView.showMessage(qsTr("Route Error"),qsTr("Unable to find a route for the given points"),page)

            onShowGeocodeInfo: stackView.showMessage(qsTr("Location"),geocodeMessage(),page)

            onErrorChanged: {
                if (map.error != Map.NoError) {
                    var title = qsTr("ProviderError")
                    var message =  map.errorString + "<br/><br/><b>" + qsTr("Try to select other provider") + "</b>"
                    if (map.error == Map.MissingRequiredParameterError)
                        message += "<br/>" + qsTr("or see") + " \'scopicdelivery --help\' "
                                + qsTr("how to pass plugin parameters.")
                    stackView.showMessage(title,message);
                }
            }
            onShowMainMenu: mapPopupMenu.show(coordinate)
            onShowMarkerMenu: markerPopupMenu.show(coordinate)
            onShowRouteList: stackView.showRouteListPage()
        }
    }
}
