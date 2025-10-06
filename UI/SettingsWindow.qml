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
    width: 400
    height: 750
    title: "Settings"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog
    
    // Add notification function
    function showNotification(msg, type) {
        settingsNotification.showNotification(msg, type)
    }
    
    Column {
        id: frame
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5
        
        // Height input
        SettingRow {
            id: heightRow
            width: frame.width
            labelText: "Height"
            textValue: root.windowHeight
        }
        
        // Width input
        SettingRow {
            id: widthRow
            width: frame.width
            labelText: "Width"
            textValue: root.windowWidth
        }
        
        // Color input
        Row {
            id: colorInput
            width: frame.width
            spacing: 10
            
            Rectangle {
                width: 60
                height: 30
                Text {
                    clip: false
                    text: "Color"
                    font.pixelSize: 20
                    color:  root.fontColor
                }
            }
            
            ColorPreview {
                id: colorPreview
                currentColor: root.fontColor
                onColorClicked: {
                    colorDialog.selectedColor = root.fontColor
                    textColorDialog.show()
                    colorDialog.open()
                }
            }
        }
        
        // Size input
        SettingRow {
            id: sizeRow
            width: frame.width
            labelText: "Size"
            textValue: root.fontSize
            maxValue: 200
        }
        
        // Font input
        Row {
            id: fontInput
            width: frame.width
            spacing: 10
            
            Rectangle {
                width: 60
                height: 30
                Text {
                    clip: false
                    text: "Font"
                    font.pixelSize: 20
                    color: "black"
                }
            }
            
            ComboBox {
                id: fontComboBox
                width: 170
                height: 30
                model: Qt.fontFamilies()
                currentIndex: find(root.fontFamily, Qt.MatchExactly | Qt.MatchCaseInsensitive)
            }
        }
        
        // Font preview
        Rectangle {
            width: frame.width - 10
            height: 60
            color: "#f0f0f0"
            border.color: "#cccccc"
            border.width: 1
            radius: 3
            
            Text {
                anchors.centerIn: parent
                text: "Preview Text 予覧 123"
                font.family: fontComboBox.currentText
                font.pixelSize: 16
                color: root.fontColor
            }
        }
        
        // Prompt editor section
        Rectangle {
            width: frame.width
            height: 2
            color: "#cccccc"
        }
        
        Text {
            text: "Translation Model"
            font.pixelSize: 18
            font.bold: true
            color: "black"
        }

        Text {
            text: "Current model: " + root.currentModel
            font.pixelSize: 13
            color: "#666666"
        }
        
        Button {
            height: 35
            width: 200
            text: "🔑 Manage API Keys"
            font.pixelSize: 13
            background: Rectangle {
                color: parent.down ? "#ff8844" : (parent.hovered ? "#ffaa66" : "#ffcc88")
                radius: 5
                border.width: 1
                border.color: "#ff6622"
            }
            onClicked: {
                root.openAPIKeys()
            }
        }
        
        Row {
            width: frame.width
            spacing: 10
            
            Rectangle {
                width: 60
                height: 30
                Text {
                    clip: false
                    text: "Model"
                    font.pixelSize: 16
                    color: "black"
                }
            }
            
            ComboBox {
                id: modelComboBox
                width: 150
                height: 30
                model: root.availableModels
                currentIndex: {
                    var idx = find(root.currentModel, Qt.MatchExactly | Qt.MatchCaseInsensitive)
                    return idx !== -1 ? idx : 0 
                }
            }
            
            Button {
                height: 30
                width: 100
                text: qsTr("Change Model")
                background: Rectangle {
                    color: parent.down ? "#8888cc" : (parent.hovered ? "#aaaadd" : "#ccccee")
                    radius: 3
                }
                onClicked: {
                    root.modelChanged(modelComboBox.currentText)
                }
            }
        }
        
        Rectangle {
            width: frame.width
            height: 2
            color: "#cccccc"
        }
        
        Text {
            text: "LLM Prompt"
            font.pixelSize: 18
            font.bold: true
            color: "black"
        }
        
        ScrollView {
            width: frame.width
            height: 150
            clip: true
            
            TextArea {
                id: promptTextArea
                width: parent.width
                wrapMode: TextArea.Wrap
                text: root.prompt
                placeholderText: "Enter your LLM prompt here..."
                font.pixelSize: 12
                background: Rectangle {
                    color: "white"
                    border.color: "#cccccc"
                    border.width: 1
                    radius: 3
                }
            }
        }
        
        Row {
            width: frame.width
            spacing: 10
            
            Button {
                height: 25
                width: 80
                text: qsTr("Save Prompt")
                background: Rectangle {
                    color: parent.down ? "#88cc88" : (parent.hovered ? "#aaddaa" : "#cceecc")
                    radius: 3
                }
                onClicked: {
                    root.promptSaved(promptTextArea.text)
                }
            }
            
        }
        
        Rectangle {
            width: frame.width
            height: 2
            color: "#cccccc"
        }
        
        // Save button
        Button {
            height: 25
            width: 140
            anchors.right: parent.right
            anchors.rightMargin: 5
            text: qsTr("Save Size/Font settings")
            background: Rectangle {
                color: parent.down ? "#bbbbbb" : (parent.hovered ? "#d6d6d6" : "#f6f6f6")
                radius: 3
            }
            onClicked: {
                root.settingsSaved(
                    heightRow.getValue(),
                    widthRow.getValue(),
                    sizeRow.getValue(),
                    root.fontColor,
                    fontComboBox.currentText
                )
                root.close()
            }
        }
    }
    
    // Color dialog
    Window {
        visible: false
        width: 375
        height: 275
        id: textColorDialog
        title: "Color Picker"
        modality: Qt.ApplicationModal
        
        ColorDialog {
            id: colorDialog
            title: "Please choose a color"
            
            onAccepted: {
                root.fontColor = colorDialog.selectedColor
                colorDialog.close()
                textColorDialog.close()
            }
            
            onRejected: {
                colorDialog.close()
                textColorDialog.close()
            }
        }
    }
    
    // Notification component - MUST BE LAST to render on top
    Item {
        id: settingsNotification
        anchors.fill: parent
        z: 10000
        enabled: true
        visible: true
        
        property string message: ""
        property string notificationType: "success"
        
        function showNotification(msg, type) {
            console.log("=== NOTIFICATION FUNCTION CALLED ===")
            console.log("Message:", msg)
            console.log("Type:", type)
            console.log("notificationBox exists:", notificationBox)
            console.log("notificationBox visible before:", notificationBox.visible)
            console.log("notificationBox opacity before:", notificationBox.opacity)
            
            message = msg
            notificationType = type || "success"
            notificationBox.visible = true
            notificationBox.opacity = 1
            
            console.log("notificationBox visible after:", notificationBox.visible)
            console.log("notificationBox opacity after:", notificationBox.opacity)
            console.log("notificationBox color:", notificationBox.color)
            
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
            height: 60
            radius: 8
            visible: false
            opacity: 0
            enabled: true
            
            color: {
                if (settingsNotification.notificationType === "success") return "#4CAF50"
                if (settingsNotification.notificationType === "error") return "#F44336"
                if (settingsNotification.notificationType === "info") return "#2196F3"
                return "#4CAF50"
            }
            
            Component.onCompleted: {
                console.log("notificationBox created, parent:", parent)
                console.log("notificationBox dimensions:", width, "x", height)
            }
            
            // Drop shadow
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
                
                Text {
                    text: {
                        if (settingsNotification.notificationType === "success") return "✓"
                        if (settingsNotification.notificationType === "error") return "✗"
                        if (settingsNotification.notificationType === "info") return "ⓘ"
                        return "✓"
                    }
                    font.pixelSize: 24
                    font.bold: true
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    width: parent.width - 40
                    text: settingsNotification.message
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
                console.log("Hide timer triggered")
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
                console.log("Visibility timer triggered, hiding notification")
                notificationBox.visible = false
            }
        }
    }
}