import QtQuick
import QtQuick.Controls.Basic

ApplicationWindow {
    id: root
    
    // Properties
    property int w: 1000
    property int h: 200
    property double o: 0.1
    property string textColor: "#FFFFFF"
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
    title: "VNtranslator"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: Qt.rgba(0, 0, 0, o)
    
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
    ControlButtons {
        anchors {
            top: parent.top
            right: parent.right
        }
        onCloseClicked: backend.close_button()
        onSettingsClicked: settingsWindow.show()
    }
    
    // Display text
    TranslatedTextDisplay {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            leftMargin: 12
            rightMargin: 12
            bottomMargin: 12
        }
        displayText: translated_text
        fontSize: textSize
        fontColor: textColor
        fontFamily: textFont
    }
    
    // Compact notification for main window
    Item {
        id: mainNotification
        anchors.fill: parent
        z: 10000
        
        property string message: ""
        property string notificationType: "success"
        
        function showNotification(msg, type) {
            console.log("Main window notification:", msg, type)
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
                topMargin: 10
            }
            width: Math.min(parent.width - 120, 400)
            height: 35
            radius: 17
            visible: false
            opacity: 0
            
            color: {
                if (mainNotification.notificationType === "success") return "#4CAF50"
                if (mainNotification.notificationType === "error") return "#F44336"
                if (mainNotification.notificationType === "info") return "#2196F3"
                return "#4CAF50"
            }
            
            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                radius: parent.radius
                color: "transparent"
                border.color: "#00000050"
                border.width: 2
                z: -1
                opacity: 0.5
            }
            
            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            
            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 12
                spacing: 8
                
                Text {
                    text: {
                        if (mainNotification.notificationType === "success") return "✓"
                        if (mainNotification.notificationType === "error") return "✗"
                        if (mainNotification.notificationType === "info") return "ⓘ"
                        return "✓"
                    }
                    font.pixelSize: 16
                    font.bold: true
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    width: parent.width - 24
                    text: mainNotification.message
                    font.pixelSize: 11
                    font.bold: true
                    color: "#FFFFFF"
                    elide: Text.ElideRight
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
    
    // Backend connection - forward notifications to appropriate windows
    Connections {
        target: backend
        
        function onTranslatedText(msg) {
            translated_text = msg
        }
        
        function onNotificationRequested(message, notificationType) {
            console.log("Notification signal received:", message, notificationType)
            
            // Show in appropriate window based on what's visible
            if (settingsWindow.visible) {
                settingsWindow.showNotification(message, notificationType)
            } else if (apiKeyWindow.visible) {
                apiKeyWindow.showNotification(message, notificationType)
            } else {
                // Show in main window if no other window is open
                mainNotification.showNotification(message, notificationType)
            }
        }
    }
}