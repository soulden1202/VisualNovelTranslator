import QtQuick
import QtQuick.Controls.Basic

Row {
    id: root
    spacing: 0
    
    signal closeClicked()
    signal settingsClicked()
    
    // Settings button
    Button {
        height: 20
        width: 20
        text: qsTr("A")
        background: Rectangle {
            color: parent.down ? "#bbbbbb" : (parent.hovered ? "#d6d6d6" : "#f6f6f6")
        }
        onClicked: root.settingsClicked()
    }
    
    // Close button
    Button {
        height: 20
        width: 20
        text: qsTr("X")
        background: Rectangle {
            color: parent.down ? "#bbbbbb" : (parent.hovered ? "#d6d6d6" : "#f6f6f6")
        }
        onClicked: root.closeClicked()
    }
}