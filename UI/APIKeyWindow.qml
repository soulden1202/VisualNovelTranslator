import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Window

Window {
    id: root
    
    property var requiredKeys: []
    property QtObject backend
    property int refreshCounter: 0
    
    // Signals for notifications
    signal apiKeyAdded(string keyName)
    signal apiKeyDeleted(string keyName)
    signal apiKeyActivated(string keyName)
    
    visible: false
    width: 600
    height: 500
    title: "API Key Management"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog
    
    // Add notification function
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
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        Text {
            text: "API Key Management"
            font.pixelSize: 24
            font.bold: true
            color: "black"
        }
        
        Text {
            width: parent.width
            text: "Add multiple API keys per model. Switch between keys when one reaches its daily quota."
            font.pixelSize: 12
            color: "#666666"
            wrapMode: Text.WordWrap
        }
        
        Rectangle {
            width: parent.width
            height: 2
            color: "#cccccc"
        }
        
        ScrollView {
            width: parent.width
            height: 350
            clip: true
            
            Column {
                width: parent.width
                spacing: 15
                
                Repeater {
                    model: root.requiredKeys
                    delegate: Rectangle {
                        id: categoryContainer 
                        width: parent.width
                        height: Math.max(200, keyColumn.implicitHeight + 20)
                        color: "#f9f9f9"
                        border.color: "#dddddd"
                        border.width: 1
                        radius: 5
                        
                        Column {
                            id: keyColumn
                            width: parent.width - 20
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 10
                            spacing: 8
                            
                            // Header
                            Row {
                                width: parent.width
                                spacing: 10
                                
                                Text {
                                    text: modelData
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "black"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                Text {
                                    text: {
                                        if (!backend) return "";
                                        var keys = backend.get_all_keys_for(modelData);
                                        return "(" + keys.length + " key" + (keys.length !== 1 ? "s" : "") + ")";
                                    }
                                    font.pixelSize: 12
                                    color: "#666666"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            // Add new key section
                            Row {
                                width: parent.width
                                spacing: 10
                                height: 35
                                
                                TextField {
                                    id: newKeyInput
                                    width: parent.width - 120
                                    height: 30
                                    placeholderText: "Enter new API key..."
                                    echoMode: TextInput.Password
                                    font.pixelSize: 12
                                }
                                
                                Button {
                                    height: 30
                                    width: 50
                                    
                                    property bool isShowing: false
                                    text: isShowing ? "Hide" : "Show"
                                    
                                    background: Rectangle {
                                        color: parent.down ? "#aaaaaa" : (parent.hovered ? "#cccccc" : "#dddddd")
                                        radius: 3
                                    }
                                    
                                    onClicked: {
                                        isShowing = !isShowing
                                        newKeyInput.echoMode = isShowing ? TextInput.Normal : TextInput.Password
                                    }
                                }
                                
                                Button {
                                    height: 30
                                    width: 50
                                    text: "Add"
                                    background: Rectangle {
                                        color: parent.down ? "#44aa44" : (parent.hovered ? "#66cc66" : "#88ee88")
                                        radius: 3
                                    }
                                    onClicked: {
                                        if (newKeyInput.text.trim() !== "" && backend) {
                                            backend.add_api_key(modelData, newKeyInput.text.trim())
                                            newKeyInput.text = ""
                                            root.refreshCounter++
                                            // Emit signal for notification - handled by backend now
                                        }
                                    }
                                }
                            }
                            
                            // List of existing keys
                            Column {
                                id: keysColumn
                                width: parent.width
                                spacing: 5
                                
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
                                        height: 40
                                        color: {
                                            root.refreshCounter; // Force refresh
                                            var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                            return index === activeIndex ? "#e6f3ff" : "#ffffff";
                                        }
                                        border.color: {
                                            root.refreshCounter; // Force refresh
                                            var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                            return index === activeIndex ? "#4a90e2" : "#cccccc";
                                        }
                                        border.width: {
                                            root.refreshCounter; // Force refresh
                                            var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                            return index === activeIndex ? 2 : 1;
                                        }
                                        radius: 3
                                        
                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 5
                                            spacing: 5
                                            
                                            Text {
                                                text: {
                                                    root.refreshCounter; // Force refresh
                                                    var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                                    return index === activeIndex ? "● " : "○ ";
                                                }
                                                font.pixelSize: 14
                                                color: {
                                                    root.refreshCounter; // Force refresh
                                                    var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                                    return index === activeIndex ? "#4a90e2" : "#999999";
                                                }
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 20
                                            }

                                            Text {
                                                text: backend ? backend.get_api_key_masked(keyModelName, index) : ""
                                                font.pixelSize: 12
                                                color: "black"
                                                anchors.verticalCenter: parent.verticalCenter
                                                elide: Text.ElideMiddle
                                                width: 150
                                            }

                                            
                                            
                                            Item { width: 10; height: 1 } // Spacer
                                            
                                            Button {
                                                height: 25
                                                width: 70
                                                text: "Set Active"
                                                anchors.verticalCenter: parent.verticalCenter
                                                visible: {
                                                    root.refreshCounter; // Force refresh
                                                    var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                                    return index !== activeIndex;
                                                }
                                                background: Rectangle {
                                                    color: parent.down ? "#5588ff" : (parent.hovered ? "#77aaff" : "#99ccff")
                                                    radius: 3
                                                }
                                                onClicked: {
                                                    if (backend) {
                                                        backend.set_active_key(keyModelName, index)
                                                        root.refreshCounter++
                                                        // Notification handled by backend now
                                                    }
                                                }
                                            }
                                            
                                            Text {
                                                width: 70
                                                text: "ACTIVE"
                                                font.pixelSize: 10
                                                font.bold: true
                                                color: "#4a90e2"
                                                anchors.verticalCenter: parent.verticalCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                visible: {
                                                    root.refreshCounter; // Force refresh
                                                    var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                                    return index === activeIndex;
                                                }
                                            }
                                            
                                            Button {
                                                height: 25
                                                width: 55
                                                text: "Delete"
                                                anchors.verticalCenter: parent.verticalCenter
                                                background: Rectangle {
                                                    color: parent.down ? "#cc4444" : (parent.hovered ? "#ee6666" : "#ff8888")
                                                    radius: 3
                                                }
                                                onClicked: {
                                                    if (backend) {
                                                        backend.delete_api_key(keyModelName, index)
                                                        root.refreshCounter++
                                                        // Notification handled by backend now
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
            height: 2
            color: "#cccccc"
        }
        
        Text {
            width: parent.width
            text: "💡 Tip: Add multiple keys to automatically switch when quota limits are reached"
            font.pixelSize: 11
            color: "#ff6600"
            wrapMode: Text.WordWrap
        }
        
        Button {
            height: 30
            width: 100
            anchors.right: parent.right
            text: "Close"
            background: Rectangle {
                color: parent.down ? "#bbbbbb" : (parent.hovered ? "#d6d6d6" : "#f6f6f6")
                radius: 3
            }
            onClicked: root.close()
        }
    }
}