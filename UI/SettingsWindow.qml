import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import QtQuick.Window

Window {
    id: root
    
    property int windowHeight: 0
    property int windowWidth: 0
    property int fontSize: 0
    property string fontColor: ""
    property string fontFamily: ""
    property string prompt: ""
    property string currentModel: ""
    property var availableModels: ""
    property QtObject backend
    
    signal settingsSaved(int height, int width, int size, string color, string font)
    signal promptSaved(string newPrompt)
    signal modelChanged(string newModel)
    signal openAPIKeys()
    
    visible: false
    width: 500
    height: 1000
    title: "Settings"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog
    color: "#1A1A1E"
    
    function showNotification(msg, type) {
        settingsNotification.showNotification(msg, type)
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#1A1A1E"
        border.color: "#2D2D32"
        border.width: 1
        
        Column {
            id: frame
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20
            
            // Header
            Text {
                text: "Settings"
                font.pixelSize: 28
                font.weight: Font.Bold
                color: "#E8E8E8"
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: "#2D2D32"
            }
            
            // Window Settings Section
            Column {
                width: parent.width
                spacing: 12
                
                Text {
                    text: "Window"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: "#B8B8B8"
                }
                
                Row {
                    width: parent.width
                    spacing: 12
                    
                    Column {
                        width: (parent.width - 12) / 2
                        spacing: 6
                        
                        Text {
                            text: "Width"
                            font.pixelSize: 12
                            color: "#808080"
                        }
                        
                        TextField {
                            id: widthField
                            width: parent.width
                            height: 36
                            text: root.windowWidth
                            color: "#E8E8E8"
                            font.pixelSize: 14
                            validator: IntValidator { bottom: 1; top: 3000 }
                            
                            background: Rectangle {
                                color: "#252529"
                                border.color: parent.activeFocus ? "#4A9EFF" : "#2D2D32"
                                border.width: 1
                                radius: 6
                            }
                        }
                    }
                    
                    Column {
                        width: (parent.width - 12) / 2
                        spacing: 6
                        
                        Text {
                            text: "Height"
                            font.pixelSize: 12
                            color: "#808080"
                        }
                        
                        TextField {
                            id: heightField
                            width: parent.width
                            height: 36
                            text: root.windowHeight
                            color: "#E8E8E8"
                            font.pixelSize: 14
                            validator: IntValidator { bottom: 1; top: 3000 }
                            
                            background: Rectangle {
                                color: "#252529"
                                border.color: parent.activeFocus ? "#4A9EFF" : "#2D2D32"
                                border.width: 1
                                radius: 6
                            }
                        }
                    }
                }
            }
            
            // Text Settings Section
            Column {
                width: parent.width
                spacing: 12
                
                Text {
                    text: "Text Appearance"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: "#B8B8B8"
                }
                
                Row {
                    width: parent.width
                    spacing: 12
                    
                    Column {
                        width: (parent.width - 12) / 2
                        spacing: 6
                        
                        Text {
                            text: "Size"
                            font.pixelSize: 12
                            color: "#808080"
                        }
                        
                        TextField {
                            id: sizeField
                            width: parent.width
                            height: 36
                            text: root.fontSize
                            color: "#E8E8E8"
                            font.pixelSize: 14
                            validator: IntValidator { bottom: 1; top: 200 }
                            
                            background: Rectangle {
                                color: "#252529"
                                border.color: parent.activeFocus ? "#4A9EFF" : "#2D2D32"
                                border.width: 1
                                radius: 6
                            }
                        }
                    }
                    
                    Column {
                        width: (parent.width - 12) / 2
                        spacing: 6
                        
                        Text {
                            text: "Color"
                            font.pixelSize: 12
                            color: "#808080"
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 36
                            color: "#252529"
                            border.color: colorMouseArea.containsMouse ? "#4A9EFF" : "#2D2D32"
                            border.width: 1
                            radius: 6
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width - 12
                                height: parent.height - 12
                                color: root.fontColor
                                radius: 4
                                border.color: "#000000"
                                border.width: 1
                            }
                            
                            MouseArea {
                                id: colorMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    colorDialog.selectedColor = root.fontColor
                                    textColorDialog.show()
                                    colorDialog.open()
                                }
                            }
                        }
                    }
                }
                
                Column {
                    width: parent.width
                    spacing: 6
                    
                    Text {
                        text: "Font Family"
                        font.pixelSize: 12
                        color: "#808080"
                    }
                    
                    ComboBox {
                        id: fontComboBox
                        width: parent.width
                        height: 36
                        model: Qt.fontFamilies()
                        currentIndex: find(root.fontFamily, Qt.MatchExactly | Qt.MatchCaseInsensitive)
                        
                        contentItem: Text {
                            leftPadding: 12
                            text: fontComboBox.displayText
                            font.pixelSize: 14
                            color: "#E8E8E8"
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            color: "#252529"
                            border.color: fontComboBox.down ? "#4A9EFF" : "#2D2D32"
                            border.width: 1
                            radius: 6
                        }
                    }
                }
                
                // Preview
                Rectangle {
                    width: parent.width
                    height: 60
                    color: "#0D0D10"
                    border.color: "#2D2D32"
                    border.width: 1
                    radius: 6
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Preview Text 予覧 123"
                        font.family: fontComboBox.currentText
                        font.pixelSize: 16
                        color: root.fontColor
                    }
                }
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: "#2D2D32"
            }
            
            // Translation Model Section
            Column {
                width: parent.width
                spacing: 12
                
                Text {
                    text: "Translation Model"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: "#B8B8B8"
                }
                
                Text {
                    text: "Current: " + root.currentModel
                    font.pixelSize: 12
                    color: "#808080"
                }
                
                Button {
                    height: 40
                    width: parent.width
                    text: "🔑  Manage API Keys"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "#E8E8E8"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.down ? "#4A7FC7" : (parent.hovered ? "#5A8FD7" : "#4A9EFF")
                        radius: 6
                        border.color: parent.hovered ? "#6A9FE7" : "transparent"
                        border.width: 1
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                    
                    onClicked: root.openAPIKeys()
                }
                
                Row {
                    width: parent.width
                    spacing: 12
                    
                    ComboBox {
                        id: modelComboBox
                        width: parent.width - 120
                        height: 36
                        model: root.availableModels
                        currentIndex: {
                            var idx = find(root.currentModel, Qt.MatchExactly | Qt.MatchCaseInsensitive)
                            return idx !== -1 ? idx : 0
                        }
                        
                        contentItem: Text {
                            leftPadding: 12
                            text: modelComboBox.displayText
                            font.pixelSize: 14
                            color: "#E8E8E8"
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            color: "#252529"
                            border.color: modelComboBox.down ? "#4A9EFF" : "#2D2D32"
                            border.width: 1
                            radius: 6
                        }
                    }
                    
                    Button {
                        height: 36
                        width: 108
                        text: "Switch"
                        font.pixelSize: 13
                        
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
                        
                        onClicked: root.modelChanged(modelComboBox.currentText)
                    }
                }
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: "#2D2D32"
            }
            
            // LLM Prompt Section
            Column {
                width: parent.width
                spacing: 12
                
                Text {
                    text: "Translation Prompt"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: "#B8B8B8"
                }
                
                ScrollView {
                    width: parent.width
                    height: 140
                    clip: true
                    
                    TextArea {
                        id: promptTextArea
                        width: parent.width
                        wrapMode: TextArea.Wrap
                        text: root.prompt
                        placeholderText: "Enter translation instructions..."
                        font.pixelSize: 12
                        color: "#E8E8E8"
                        
                        background: Rectangle {
                            color: "#252529"
                            border.color: "#2D2D32"
                            border.width: 1
                            radius: 6
                        }
                    }
                }
                
                Button {
                    height: 36
                    width: 120
                    text: "Save Prompt"
                    font.pixelSize: 13
                    
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
                    
                    onClicked: root.promptSaved(promptTextArea.text)
                }
            }
            
            Item { height: 1 }
            
            // Save Button
            Button {
                height: 44
                width: parent.width
                text: "Save Settings"
                font.pixelSize: 15
                font.weight: Font.Medium
                
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "#E8E8E8"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                background: Rectangle {
                    color: parent.down ? "#4A7FC7" : (parent.hovered ? "#5A8FD7" : "#4A9EFF")
                    radius: 6
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                onClicked: {
                    root.settingsSaved(
                        parseInt(heightField.text),
                        parseInt(widthField.text),
                        parseInt(sizeField.text),
                        root.fontColor,
                        fontComboBox.currentText
                    )
                    root.close()
                }
            }
        }
    }
    
    // Color dialog
     Window {
        visible: false
        width: 400
        height: 300
        id: textColorDialog
        title: "Color Picker"
        modality: Qt.ApplicationModal
        color: "#1A1A1E"
        
        Rectangle {
            anchors.fill: parent
            color: "#1A1A1E"
            border.color: "#2D2D32"
            border.width: 1
            
            Column {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16
                
                Text {
                    text: "Choose Color"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    color: "#E8E8E8"
                }
                
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#2D2D32"
                }
                
                // Color preview
                Rectangle {
                    width: parent.width
                    height: 80
                    color: colorDialog.selectedColor
                    border.color: "#2D2D32"
                    border.width: 1
                    radius: 6
                }
                
                Text {
                    text: "Color: " + colorDialog.selectedColor
                    font.pixelSize: 13
                    font.family: "Consolas"
                    color: "#B8B8B8"
                }
                
                Item { height: 10 }
                
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12
                    
                    Button {
                        width: 100
                        height: 36
                        text: "Cancel"
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
                        
                        onClicked: textColorDialog.close()
                    }
                    
                    Button {
                        width: 100
                        height: 36
                        text: "Pick Color"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: "#E8E8E8"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            color: parent.down ? "#4A7FC7" : (parent.hovered ? "#5A8FD7" : "#4A9EFF")
                            radius: 6
                            
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }
                        
                        onClicked: colorDialog.open()
                    }
                    
                    Button {
                        width: 100
                        height: 36
                        text: "Apply"
                        font.pixelSize: 13
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
                            root.fontColor = colorDialog.selectedColor
                            textColorDialog.close()
                        }
                    }
                }
            }
        }
        
        ColorDialog {
            id: colorDialog
            title: "Choose a color"
            parentWindow: textColorDialog
            
            onAccepted: {
                root.fontColor = colorDialog.selectedColor
            }
        }
    }
    
    // Notification component
    Item {
        id: settingsNotification
        anchors.fill: parent
        z: 10000
        enabled: true
        visible: true
        
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
            enabled: true
            
            color: {
                if (settingsNotification.notificationType === "success") return Qt.rgba(0.2, 0.8, 0.4, 0.95)
                if (settingsNotification.notificationType === "error") return Qt.rgba(0.9, 0.3, 0.3, 0.95)
                if (settingsNotification.notificationType === "info") return Qt.rgba(0.3, 0.6, 0.9, 0.95)
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
                        if (settingsNotification.notificationType === "success") return "✓"
                        if (settingsNotification.notificationType === "error") return "✗"
                        if (settingsNotification.notificationType === "info") return "ⓘ"
                        return "✓"
                    }
                    font.pixelSize: 22
                    font.bold: true
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: settingsNotification.message
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