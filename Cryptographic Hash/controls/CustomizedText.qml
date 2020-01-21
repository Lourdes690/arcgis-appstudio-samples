import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1


import ArcGIS.AppFramework 1.0

Text {
    property string cusText
    text: cusText
    font.pixelSize: 14 * scaleFactor
    horizontalAlignment: Text.AlignRight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
}

