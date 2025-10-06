import QtQuick
import QtQuick.Controls.Basic

Rectangle {
    id: notificationRoot
    anchors.fill: parent
    color: "transparent"
    visible: true
    
    // Properties
    property string message: ""
    property string notificationType: "success"
    
    function showNotification(msg, type) {
        console.log("showNotification called:", msg, type)
        message = msg
        notificationType = type || "success"
        notificationBox.visible = true
        notificationBox.opacity = 1
        hideTimer.restart()
    }
    
    Rectangle {
        id: notificationBox
        anchors.centerIn: parent
        width: Math.min(notificationRoot.width * 0.8, 400)
        height: 60
        radius: 8
        visible: false
        opacity: 0
        
        color: {
            if (notificationType === "success") return "#4CAF50"
            if (notificationType === "error") return "#F44336"
            if (notificationType === "info") return "#2196F3"
            return "#4CAF50"
        }
        
        // Drop shadow effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: parent.radius
            color: "transparent"
            border.color: "#00000040"
            border.width: 2
            z: -1
        }
        
        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }
        
        Row {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            // Icon
            Text {
                id: icon
                text: {
                    if (notificationType === "success") return "✓"
                    if (notificationType === "error") return "✗"
                    if (notificationType === "info") return "ⓘ"
                    return "✓"
                }
                font.pixelSize: 24
                font.bold: true
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }
            
            // Message text
            Text {
                width: parent.width - icon.width - 12
                text: notificationRoot.message
                font.pixelSize: 14
                color: "#FFFFFF"
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 2
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    
    Timer {
        id: hideTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            notificationBox.opacity = 0
            visibilityTimer.start()
        }
    }
    
    Timer {
        id: visibilityTimer
        interval: 300
        running: false
        repeat: false
        onTriggered: {
            notificationBox.visible = false
        }
    }
}