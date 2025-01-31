/* Copyright 2021 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15

import ArcGIS.AppFramework 1.0

import "../"

Rectangle {
    id: page

    property Item contentItem

    property alias title: titleText.text

    property BluetoothManager bluetoothManager
    property AppDialog gnssDialog
    property StackView stackView

    // Header bar styling
    property real headerBarHeight: 50 * AppFramework.displayScaleFactor
    property real headerBarTextSize: 20 * AppFramework.displayScaleFactor
    property bool headerBarTextBold: true

    property color headerBarTextColor: "#ffffff"
    property color headerBarBackgroundColor: "#8f499c"

    property color backIconColor: headerBarTextColor
    property real backIconSize: 30 * AppFramework.displayScaleFactor
    property url backIcon: "../images/back.png"

    property color settingsIconColor: headerBarTextColor
    property real settingsIconSize: 30 * AppFramework.displayScaleFactor
    property url settingsIcon: "../images/round_settings_white_24dp.png"

    // Page styling
    property real contentMargins: 0
    property color textColor: "#303030"
    property color backgroundColor: "#f8f8f8"
    property color listBackgroundColor: "#ffffff"

    // Font styling
    property string fontFamily: Qt.application.font.family
    property real letterSpacing: 0
    property real helpTextLetterSpacing: 0
    property var locale: Qt.locale()
    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    // set these to provide access to location settings
    property bool allowSettingsAccess
    property var settingsUI

    //--------------------------------------------------------------------------

    readonly property var settingsTabContainer: settingsUI ? settingsUI.settingsTabContainer : null
    readonly property var settingsTabLocation: settingsUI ? settingsUI.settingsTabLocation : null

    readonly property real notchHeight: isNotchAvailable() ? 40 * AppFramework.displayScaleFactor : 20 * AppFramework.displayScaleFactor

    //--------------------------------------------------------------------------

    signal titlePressAndHold()
    signal backButtonPressed()
    signal settingsCogPressed()
    signal activated()
    signal deactivated()
    signal removed()

    //--------------------------------------------------------------------------

    color: backgroundColor

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        if (contentItem) {
            contentItem.parent = page;
            contentItem.anchors.left = page.left;
            contentItem.anchors.right = page.right;
            contentItem.anchors.top = headerBar.bottom;
            contentItem.anchors.bottom = page.bottom;
            contentItem.anchors.margins = contentMargins;
        }
    }

    //-----------------------------------------------------------------------------------
    // backbutton handling

    onActivated: {
        forceActiveFocus();
    }

    Keys.onReleased: {
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
            event.accepted = true
            backButtonPressed();
        }
    }

    //--------------------------------------------------------------------------

    // prevent mouse events from filtering through to the underlying components
    MouseArea {
        anchors.fill: parent
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: topSpacing

        visible: Qt.platform.os === "ios"

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: Qt.platform.os === "ios" ? notchHeight : 0
        color: headerBarBackgroundColor
    }

    Rectangle {
        id: headerBar

        anchors {
            left: parent.left
            right: parent.right
            top: topSpacing.bottom
        }

        height: headerBarHeight
        color: headerBarBackgroundColor

        RowLayout {
            anchors.fill: parent

            spacing: 0

            Item {
                Layout.preferredWidth: 15 * AppFramework.displayScaleFactor
                Layout.fillHeight: true
            }

            StyledImageButton {
                id: backButton

                Layout.fillHeight: true
                Layout.preferredWidth: backIconSize
                Layout.preferredHeight: backIconSize
                Layout.alignment: Qt.AlignVCenter

                source: backIcon
                color: backIconColor
                rotation: isRightToLeft ? 180 : 0

                onClicked: {
                    backButtonPressed();
                }
            }

            AppText {
                id: titleText

                Layout.fillWidth: true
                Layout.fillHeight: true

                color: headerBarTextColor

                fontFamily: page.fontFamily
                pixelSize: page.headerBarTextSize
                letterSpacing: page.letterSpacing
                bold: page.headerBarTextBold

                fontSizeMode: Text.HorizontalFit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight

                MouseArea {
                    anchors.fill: parent

                    onPressAndHold: {
                        titlePressAndHold();
                    }
                }
            }

            Item {
                visible: !configButton.visible

                Layout.fillHeight: true
                Layout.preferredWidth: backIconSize
                Layout.preferredHeight: backIconSize
            }

            StyledImageButton {
                id: configButton

                visible: allowSettingsAccess && settingsUI
                enabled: visible

                Layout.fillHeight: true
                Layout.preferredHeight: settingsIconSize
                Layout.preferredWidth: settingsIconSize
                Layout.alignment: Qt.AlignVCenter

                source: settingsIcon
                color: settingsIconColor

                onClicked: {
                    settingsCogPressed();
                }
            }

            Item {
                Layout.preferredWidth: 15 * AppFramework.displayScaleFactor
                Layout.fillHeight: true
            }
        }
    }

    //--------------------------------------------------------------------------

    onBackButtonPressed: {
        if (stackView) {
            if (stackView.depth > 1) {
                stackView.pop()
            } else {
                stackView.clear()
            }
        } else {
            console.log("Error: stackView has not been set")
        }
    }

    //--------------------------------------------------------------------------

    onSettingsCogPressed: {
        if (stackView && settingsUI) {
            settingsUI.showLocationSettings(stackView, true)
        } else {
            console.log("Error: stackView and/or settingsUI have not been set")
        }
    }

    //--------------------------------------------------------------------------

    StackView.onActivated: {
        activated();
    }

    //--------------------------------------------------------------------------

    StackView.onDeactivated: {
        deactivated();
    }

    //--------------------------------------------------------------------------

    StackView.onRemoved: {
        removed();
    }

    //--------------------------------------------------------------------------

    function isNotchAvailable() {
        var unixName = AppFramework.systemInformation.unixMachine
        if (typeof unixName !== "undefined" && unixName.match(/iPhone(10|\d\d)/)) {
            switch(unixName) {
            case "iPhone10,1":
            case "iPhone10,4":
            case "iPhone10,2":
            case "iPhone10,5":
                return false;
            default:
                return true;
            }
        }
        return false;
    }

    //--------------------------------------------------------------------------
}
