import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Window

Window {
    id: root
    
    property var requiredKeys: []
    property QtObject backend
    property int refreshCounter: 0
    
    signal apiKeyAdded(string keyName)
    signal apiKeyDeleted(string keyName)
    signal apiKeyActivated(string keyName)
    
    visible: false
    width: 650
    height: 600
    title: "API Key Management"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog
    color: "#1A1A1E"
    
    function showNotification(msg, type) {
        if (apiNotification) {
            apiNotification.showNotification(msg, type)
        }
    }
    
    Component.onCompleted: {
        loadKeys()
    }
    
    onVisibleChanged: {
        if (visible) {
            loadKeys()
        }
    }
    
    function loadKeys() {
        if (backend) {
            requiredKeys = backend.get_required_api_keys()
            refreshCounter++
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#1A1A1E"
        border.color: "#2D2D32"
        border.width: 1
        
        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20
            
            // Header
            Text {
                text: "API Key Management"
                font.pixelSize: 28
                font.weight: Font.Bold
                color: "#E8E8E8"
            }
            
            Text {
                width: parent.width
                text: "Add multiple API keys per model. Keys automatically switch when reaching daily quotas."
                font.pixelSize: 13
                color: "#808080"
                wrapMode: Text.WordWrap
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: "#2D2D32"
            }
            
            ScrollView {
                width: parent.width
                height: 420
                clip: true
                
                Column {
                    width: parent.width
                    spacing: 16
                    
                    Repeater {
                        model: root.requiredKeys
                        delegate: Rectangle {
                            id: categoryContainer 
                            width: parent.width
                            height: Math.max(220, keyColumn.implicitHeight + 24)
                            color: "#252529"
                            border.color: "#2D2D32"
                            border.width: 1
                            radius: 8
                            
                            Column {
                                id: keyColumn
                                width: parent.width - 24
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.margins: 12
                                spacing: 12
                                
                                // Header
                                Row {
                                    width: parent.width
                                    spacing: 10
                                    
                                    Text {
                                        text: modelData
                                        font.pixelSize: 18
                                        font.weight: Font.Bold
                                        color: "#E8E8E8"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    Rectangle {
                                        width: 60
                                        height: 22
                                        radius: 11
                                        color: "#0D0D10"
                                        border.color: "#2D2D32"
                                        border.width: 1
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: {
                                                if (!backend) return "0";
                                                var keys = backend.get_all_keys_for(modelData);
                                                return keys.length + " key" + (keys.length !== 1 ? "s" : "");
                                            }
                                            font.pixelSize: 11
                                            font.weight: Font.Medium
                                            color: "#808080"
                                        }
                                    }
                                }
                                
                                // Add new key section
                                Row {
                                    width: parent.width
                                    spacing: 8
                                    height: 36
                                    
                                    TextField {
                                        id: newKeyInput
                                        width: parent.width - 116
                                        height: 36
                                        placeholderText: "Enter new API key..."
                                        echoMode: TextInput.Password
                                        font.pixelSize: 13
                                        color: "#E8E8E8"
                                        
                                        background: Rectangle {
                                            color: "#0D0D10"
                                            border.color: parent.activeFocus ? "#4A9EFF" : "#2D2D32"
                                            border.width: 1
                                            radius: 6
                                        }
                                    }
                                    
                                    Button {
                                        height: 36
                                        width: 54
                                        
                                        property bool isShowing: false
                                        text: isShowing ? "Hide" : "Show"
                                        font.pixelSize: 11
                                        
                                        contentItem: Text {
                                            text: parent.text
                                            font: parent.font
                                            color: "#E8E8E8"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        
                                        background: Rectangle {
                                            color: parent.down ? "#2D2D32" : (parent.hovered ? "#3D3D42" : "#252529")
                                            border.color: "#2D2D32"
                                            border.width: 1
                                            radius: 6
                                            
                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }
                                        
                                        onClicked: {
                                            isShowing = !isShowing
                                            newKeyInput.echoMode = isShowing ? TextInput.Normal : TextInput.Password
                                        }
                                    }
                                    
                                    Button {
                                        height: 36
                                        width: 54
                                        text: "Add"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        
                                        contentItem: Text {
                                            text: parent.text
                                            font: parent.font
                                            color: "#E8E8E8"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        
                                        background: Rectangle {
                                            color: parent.down ? "#2D5A2D" : (parent.hovered ? "#3D6A3D" : "#4D7A4D")
                                            radius: 6
                                            
                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }
                                        
                                        onClicked: {
                                            if (newKeyInput.text.trim() !== "" && backend) {
                                                backend.add_api_key(modelData, newKeyInput.text.trim())
                                                newKeyInput.text = ""
                                                root.refreshCounter++
                                            }
                                        }
                                    }
                                }
                                
                                // List of existing keys
                                Column {
                                    id: keysColumn
                                    width: parent.width
                                    spacing: 6
                                    
                                    property string currentModel: modelData
                                    
                                    Repeater {
                                        id: keysRepeater
                                        model: (root.refreshCounter >= 0 && backend) ? backend.get_all_keys_for(keysColumn.currentModel) : []
                                        
                                        delegate: Rectangle {
                                            required property int index
                                            required property string modelData
                                            property string keyModelName: keysColumn.currentModel
                                            property string currentKey: modelData
                                            
                                            width: parent.width
                                            height: 42
                                            color: {
                                                root.refreshCounter;
                                                var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                                return index === activeIndex ? "#1E3A5F" : "#0D0D10";
                                            }
                                            border.color: {
                                                root.refreshCounter;
                                                var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                                return index === activeIndex ? "#4A9EFF" : "#2D2D32";
                                            }
                                            border.width: 1
                                            radius: 6
                                            
                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                            
                                            Row {
                                                anchors.fill: parent
                                                anchors.margins: 8
                                                spacing: 8
                                                
                                                Rectangle {
                                                    width: 8
                                                    height: 8
                                                    radius: 4
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    color: {
                                                        root.refreshCounter;
                                                        var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                                        return index === activeIndex ? "#4A9EFF" : "#404040";
                                                    }
                                                    
                                                    Behavior on color {
                                                        ColorAnimation { duration: 150 }
                                                    }
                                                }

                                                Text {
                                                    text: backend ? backend.get_api_key_masked(keyModelName, index) : ""
                                                    font.pixelSize: 13
                                                    font.family: "Consolas"
                                                    color: "#B8B8B8"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    elide: Text.ElideMiddle
                                                    width: 160
                                                }
                                                
                                                Item { width: 10; height: 1 }
                                                
                                                Button {
                                                    height: 28
                                                    width: 78
                                                    text: "Set Active"
                                                    font.pixelSize: 11
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    visible: {
                                                        root.refreshCounter;
                                                        var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                                        return index !== activeIndex;
                                                    }
                                                    
                                                    contentItem: Text {
                                                        text: parent.text
                                                        font: parent.font
                                                        color: "#E8E8E8"
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                    }
                                                    
                                                    background: Rectangle {
                                                        color: parent.down ? "#3A6FC7" : (parent.hovered ? "#4A7FD7" : "#4A9EFF")
                                                        radius: 4
                                                        
                                                        Behavior on color {
                                                            ColorAnimation { duration: 150 }
                                                        }
                                                    }
                                                    
                                                    onClicked: {
                                                        if (backend) {
                                                            backend.set_active_key(keyModelName, index)
                                                            root.refreshCounter++
                                                        }
                                                    }
                                                }
                                                
                                                Rectangle {
                                                    width: 78
                                                    height: 28
                                                    color: "#1E3A5F"
                                                    border.color: "#4A9EFF"
                                                    border.width: 1
                                                    radius: 4
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    visible: {
                                                        root.refreshCounter;
                                                        var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                                        return index === activeIndex;
                                                    }
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "ACTIVE"
                                                        font.pixelSize: 10
                                                        font.weight: Font.Bold
                                                        color: "#4A9EFF"
                                                    }
                                                }
                                                
                                                Button {
                                                    height: 28
                                                    width: 60
                                                    text: "Delete"
                                                    font.pixelSize: 11
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    
                                                    contentItem: Text {
                                                        text: parent.text
                                                        font: parent.font
                                                        color: "#E8E8E8"
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                    }
                                                    
                                                    background: Rectangle {
                                                        color: parent.down ? "#A33030" : (parent.hovered ? "#B34040" : "#C35050")
                                                        radius: 4
                                                        
                                                        Behavior on color {
                                                            ColorAnimation { duration: 150 }
                                                        }
                                                    }
                                                    
                                                    onClicked: {
                                                        if (backend) {
                                                            backend.delete_api_key(keyModelName, index)
                                                            root.refreshCounter++
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: "#2D2D32"
            }
            
            Text {
                width: parent.width
                text: "💡 Tip: Add multiple keys to automatically switch when quota limits are reached"
                font.pixelSize: 12
                color: "#808080"
                wrapMode: Text.WordWrap
            }
            
            Button {
                height: 40
                width: 100
                anchors.right: parent.right
                text: "Close"
                font.pixelSize: 13
                
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "#E8E8E8"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                background: Rectangle {
                    color: parent.down ? "#2D2D32" : (parent.hovered ? "#3D3D42" : "#252529")
                    border.color: "#2D2D32"
                    border.width: 1
                    radius: 6
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                onClicked: root.close()
            }
        }
    }
    
    // Notification component
    Item {
        id: apiNotification
        anchors.fill: parent
        z: 10000
        
        property string message: ""
        property string notificationType: "success"
        
        function showNotification(msg, type) {
            message = msg
            notificationType = type || "success"
            notificationBox.visible = true
            notificationBox.opacity = 1
            hideTimer.restart()
        }
        
        Rectangle {
            id: notificationBox
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 20
            }
            width: Math.min(parent.width - 40, 350)
            height: 56
            radius: 8
            visible: false
            opacity: 0
            
            color: {
                if (apiNotification.notificationType === "success") return Qt.rgba(0.2, 0.8, 0.4, 0.95)
                if (apiNotification.notificationType === "error") return Qt.rgba(0.9, 0.3, 0.3, 0.95)
                if (apiNotification.notificationType === "info") return Qt.rgba(0.3, 0.6, 0.9, 0.95)
                return Qt.rgba(0.2, 0.8, 0.4, 0.95)
            }
            
            border.color: Qt.rgba(1, 1, 1, 0.2)
            border.width: 1
            
            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
            }
            
            Row {
                anchors.centerIn: parent
                spacing: 12
                
                Text {
                    text: {
                        if (apiNotification.notificationType === "success") return "✓"
                        if (apiNotification.notificationType === "error") return "✗"
                        if (apiNotification.notificationType === "info") return "ⓘ"
                        return "✓"
                    }
                    font.pixelSize: 22
                    font.bold: true
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: apiNotification.message
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#FFFFFF"
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
}