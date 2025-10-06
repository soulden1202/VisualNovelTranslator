import QtQuick

Rectangle {
    id: root
    
    property string currentColor: "#FFFFFF"
    signal colorClicked()
    
    width: 60
    height: 30
    color: currentColor
    border.width: 1
    border.color: "black"
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.colorClicked()
        onEntered: root.border.width = 3
        onExited: root.border.width = 1
    }
}