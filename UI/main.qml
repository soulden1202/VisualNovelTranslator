import QtQuick
import QtQuick.Controls.Basic

ApplicationWindow {
    id: root
    
    // Properties
    property int w: 1000
    property int h: 200
    property double o: 0.95
    property string textColor: "#E8E8E8"
    property int textSize: 20
    property string textFont: "Arial"
    property string llmPrompt: ""
    property string selectedModel: "Gemini"
    property var availableModels: []
    property string translated_text: "Translated text will display here"
    property QtObject backend
    
    // Window settings
    visible: true
    width: w
    height: h
    title: "VN Translator"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: Qt.rgba(0.1, 0.1, 0.12, o)
    
    // Subtle border
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Qt.rgba(0.3, 0.3, 0.35, 0.3)
        border.width: 1
        radius: 8
    }
    
    // Drag handler for moving window
    DragHandler {
        target: null
        acceptedDevices: PointerDevice.GenericPointer
        grabPermissions: PointerHandler.CanTakeOverFromItems | 
                        PointerHandler.CanTakeOverFromHandlersOfDifferentType | 
                        PointerHandler.ApprovesTakeOverByAnything
        onActiveChanged: if (active) root.startSystemMove()
    }
    
    // Control buttons
    Row {
        anchors {
            top: parent.top
            right: parent.right
            margins: 8
        }
        spacing: 4
        z: 100
        
        // Settings button
        Rectangle {
            width: 32
            height: 32
            radius: 6
            color: settingsMouseArea.containsMouse ? Qt.rgba(0.3, 0.3, 0.35, 0.8) : Qt.rgba(0.2, 0.2, 0.25, 0.6)
            border.color: Qt.rgba(0.4, 0.4, 0.45, 0.4)
            border.width: 1
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            Text {
                anchors.centerIn: parent
                text: "⚙"
                font.pixelSize: 16
                color: "#E8E8E8"
            }
            
            MouseArea {
                id: settingsMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: settingsWindow.show()
                cursorShape: Qt.PointingHandCursor
            }
        }
        
        // Close button
        Rectangle {
            width: 32
            height: 32
            radius: 6
            color: closeMouseArea.containsMouse ? Qt.rgba(0.8, 0.2, 0.2, 0.8) : Qt.rgba(0.2, 0.2, 0.25, 0.6)
            border.color: Qt.rgba(0.4, 0.4, 0.45, 0.4)
            border.width: 1
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            Text {
                anchors.centerIn: parent
                text: "×"
                font.pixelSize: 20
                color: "#E8E8E8"
            }
            
            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: backend.close_button()
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
    
    // Display text
    Text {
        anchors {
            fill: parent
            margins: 16
            topMargin: 48
        }
        text: translated_text
        font.pixelSize: textSize
        font.family: textFont
        color: textColor
        wrapMode: Text.Wrap
        elide: Text.ElideNone
        clip: false
    }
    
    // Compact notification
    Item {
        id: mainNotification
        anchors.fill: parent
        z: 10000
        
        property string message: ""
        property string notificationType: "success"
        
        function showNotification(msg, type) {
            message = msg
            notificationType = type || "success"
            
            notificationBox.opacity = 0
            notificationBox.visible = true
            
            Qt.callLater(function() {
                notificationBox.opacity = 1
            })
            
            hideTimer.restart()
        }
        
        Rectangle {
            id: notificationBox
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 12
            }
            width: Math.min(parent.width - 120, 400)
            height: 40
            radius: 8
            visible: false
            opacity: 0
            
            color: {
                if (mainNotification.notificationType === "success") return Qt.rgba(0.2, 0.8, 0.4, 0.95)
                if (mainNotification.notificationType === "error") return Qt.rgba(0.9, 0.3, 0.3, 0.95)
                if (mainNotification.notificationType === "info") return Qt.rgba(0.3, 0.6, 0.9, 0.95)
                return Qt.rgba(0.2, 0.8, 0.4, 0.95)
            }
            
            border.color: Qt.rgba(1, 1, 1, 0.2)
            border.width: 1
            
            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            
            Row {
                anchors.centerIn: parent
                spacing: 10
                
                Text {
                    text: {
                        if (mainNotification.notificationType === "success") return "✓"
                        if (mainNotification.notificationType === "error") return "✗"
                        if (mainNotification.notificationType === "info") return "ⓘ"
                        return "✓"
                    }
                    font.pixelSize: 18
                    font.bold: true
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: mainNotification.message
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
        
        Timer {
            id: hideTimer
            interval: 2500
            running: false
            repeat: false
            onTriggered: {
                notificationBox.opacity = 0
                visibilityTimer.start()
            }
        }
        
        Timer {
            id: visibilityTimer
            interval: 200
            running: false
            repeat: false
            onTriggered: {
                notificationBox.visible = false
            }
        }
    }
    
    // Settings window
    SettingsWindow {
        id: settingsWindow
        windowHeight: root.h
        windowWidth: root.w
        fontSize: root.textSize
        fontColor: root.textColor
        fontFamily: root.textFont
        prompt: root.llmPrompt
        currentModel: root.selectedModel
        availableModels: root.availableModels
        backend: root.backend
        
        onSettingsSaved: function(height, width, size, color, font) {
            root.h = height
            root.w = width
            root.textSize = size
            root.textColor = color
            root.textFont = font
            backend.save_settings(width, height, size, color, font)
        }
        
        onPromptSaved: function(newPrompt) {
            root.llmPrompt = newPrompt
            backend.save_prompt(newPrompt)
        }
        
        onModelChanged: function(newModel) {
            root.selectedModel = newModel
            backend.save_model(newModel)
        }
        
        onOpenAPIKeys: {
            apiKeyWindow.show()
        }
    }
    
    // API Key Management Window
    APIKeyWindow {
        id: apiKeyWindow
        backend: root.backend
    }
    
    // Backend connection
    Connections {
        target: backend
        
        function onTranslatedText(msg) {
            translated_text = msg
        }
        
        function onNotificationRequested(message, notificationType) {
            if (settingsWindow.visible) {
                settingsWindow.showNotification(message, notificationType)
            } else if (apiKeyWindow.visible) {
                apiKeyWindow.showNotification(message, notificationType)
            } else {
                mainNotification.showNotification(message, notificationType)
            }
        }
    }
}