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

    Theme { id: theme }

    visible: false
    width: 650
    height: 600
    title: "API Key Management"
    modality: Qt.ApplicationModal
    flags: Qt.Dialog
    color: theme.bgBase

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
        color: theme.bgBase

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            // Header
            Text {
                text: "API Key Management"
                font.pixelSize: 22
                font.weight: Font.Bold
                color: theme.textPrimary
            }

            Text {
                width: parent.width
                text: "Add multiple API keys per model. Keys automatically switch when reaching daily quotas."
                font.pixelSize: 13
                color: theme.textSecondary
                wrapMode: Text.WordWrap
            }

            Rectangle {
                width: parent.width
                height: 1
                color: theme.border
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
                            color: theme.bgSurface
                            border.color: theme.border
                            border.width: 1
                            radius: theme.radiusMd

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
                                        font.pixelSize: 17
                                        font.weight: Font.Bold
                                        color: theme.textPrimary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Rectangle {
                                        width: 60
                                        height: 22
                                        radius: 11
                                        color: theme.bgBase
                                        border.color: theme.border
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
                                            color: theme.textSecondary
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
                                        color: theme.textPrimary

                                        background: Rectangle {
                                            color: theme.bgBase
                                            border.color: parent.activeFocus ? theme.accent : theme.border
                                            border.width: 1
                                            radius: theme.radiusSm
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
                                            color: theme.textPrimary
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        background: Rectangle {
                                            color: parent.down ? theme.bgSurfaceAlt : (parent.hovered ? theme.bgSurfaceRaised : theme.bgSurface)
                                            border.color: theme.border
                                            border.width: 1
                                            radius: theme.radiusSm

                                            Behavior on color {
                                                ColorAnimation { duration: theme.durationFast }
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
                                            color: theme.textOnAccent
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        background: Rectangle {
                                            color: parent.down ? theme.accentPressed : (parent.hovered ? theme.accentHover : theme.accent)
                                            radius: theme.radiusSm

                                            Behavior on color {
                                                ColorAnimation { duration: theme.durationFast }
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
                                                return index === activeIndex ? theme.accentMuted : theme.bgBase;
                                            }
                                            border.color: {
                                                root.refreshCounter;
                                                var activeIndex = backend ? backend.get_active_key_index(keyModelName) : -1;
                                                return index === activeIndex ? theme.accent : theme.border;
                                            }
                                            border.width: 1
                                            radius: theme.radiusSm

                                            Behavior on color {
                                                ColorAnimation { duration: theme.durationFast }
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
                                                        return index === activeIndex ? theme.accent : theme.textMuted;
                                                    }

                                                    Behavior on color {
                                                        ColorAnimation { duration: theme.durationFast }
                                                    }
                                                }

                                                Text {
                                                    text: backend ? backend.get_api_key_masked(keyModelName, index) : ""
                                                    font.pixelSize: 13
                                                    font.family: "Consolas"
                                                    color: theme.textSecondary
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
                                                        color: theme.textOnAccent
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                    }

                                                    background: Rectangle {
                                                        color: parent.down ? theme.accentPressed : (parent.hovered ? theme.accentHover : theme.accent)
                                                        radius: theme.radiusSm

                                                        Behavior on color {
                                                            ColorAnimation { duration: theme.durationFast }
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
                                                    color: theme.accentMuted
                                                    border.color: theme.accent
                                                    border.width: 1
                                                    radius: theme.radiusSm
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
                                                        color: theme.accent
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
                                                        color: theme.textOnAccent
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                    }

                                                    background: Rectangle {
                                                        color: parent.down ? theme.dangerPressed : (parent.hovered ? theme.dangerHover : theme.danger)
                                                        radius: theme.radiusSm

                                                        Behavior on color {
                                                            ColorAnimation { duration: theme.durationFast }
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
                color: theme.border
            }

            Text {
                width: parent.width
                text: "💡 Tip: Add multiple keys to automatically switch when quota limits are reached"
                font.pixelSize: 12
                color: theme.textMuted
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
                    color: theme.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.down ? theme.bgSurfaceAlt : (parent.hovered ? theme.bgSurfaceRaised : theme.bgSurface)
                    border.color: theme.border
                    border.width: 1
                    radius: theme.radiusSm

                    Behavior on color {
                        ColorAnimation { duration: theme.durationFast }
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
            height: 48
            radius: theme.radiusSm
            visible: false
            opacity: 0
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.25)

            color: {
                if (apiNotification.notificationType === "success") return theme.success
                if (apiNotification.notificationType === "error") return theme.danger
                if (apiNotification.notificationType === "info") return theme.accent
                return theme.success
            }

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
                    font.pixelSize: 18
                    font.bold: true
                    color: theme.textOnAccent
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: apiNotification.message
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: theme.textOnAccent
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
