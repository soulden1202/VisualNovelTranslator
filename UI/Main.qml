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
    property string localLlmUrl: ""
    property string localLlmModel: ""
    property string textractorPath: ""
    property string translated_text: "Translated text will display here"
    property QtObject backend

    Theme { id: theme }

    // Window settings
    visible: true
    width: w
    height: h
    title: "VN Translator"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: Qt.rgba(0.07, 0.07, 0.08, o)

    // Subtle flat border
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1
        radius: theme.radiusMd
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
        spacing: 6
        z: 100

        // Settings button
        Rectangle {
            width: 30
            height: 30
            radius: theme.radiusSm
            color: settingsMouseArea.containsMouse ? theme.bgSurfaceRaised : Qt.rgba(1, 1, 1, 0.05)
            border.color: theme.border
            border.width: 1

            Behavior on color {
                ColorAnimation { duration: theme.durationFast }
            }

            Text {
                anchors.centerIn: parent
                text: "⚙"
                font.pixelSize: 15
                color: theme.textPrimary
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
            width: 30
            height: 30
            radius: theme.radiusSm
            color: closeMouseArea.containsMouse ? theme.danger : Qt.rgba(1, 1, 1, 0.05)
            border.color: closeMouseArea.containsMouse ? theme.danger : theme.border
            border.width: 1

            Behavior on color {
                ColorAnimation { duration: theme.durationFast }
            }

            Text {
                anchors.centerIn: parent
                text: "×"
                font.pixelSize: 18
                color: theme.textPrimary
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
            height: 38
            radius: theme.radiusSm
            visible: false
            opacity: 0
            border.width: 1

            color: {
                if (mainNotification.notificationType === "success") return theme.success
                if (mainNotification.notificationType === "error") return theme.danger
                if (mainNotification.notificationType === "info") return theme.accent
                return theme.success
            }
            border.color: Qt.rgba(0, 0, 0, 0.25)

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
                    font.pixelSize: 16
                    font.bold: true
                    color: theme.textOnAccent
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: mainNotification.message
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: theme.textOnAccent
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
        localLlmUrl: root.localLlmUrl
        localLlmModel: root.localLlmModel
        textractorPath: root.textractorPath
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

        onLocalLlmSettingsSaved: function(url, model) {
            root.localLlmUrl = url
            root.localLlmModel = model
            backend.save_local_llm_settings(url, model)
        }

        onTextractorPathSaved: function(path) {
            root.textractorPath = path
            backend.save_textractor_path(path)
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
