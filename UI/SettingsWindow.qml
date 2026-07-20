import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import QtQuick.Window
import QtQuick.Layouts

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
    property string localLlmUrl: ""
    property string localLlmModel: ""
    property string textractorPath: ""
    property QtObject backend

    signal settingsSaved(int height, int width, int size, string color, string font)
    signal promptSaved(string newPrompt)
    signal modelChanged(string newModel)
    signal localLlmSettingsSaved(string url, string model)
    signal textractorPathSaved(string path)
    signal openAPIKeys()

    Theme { id: theme }

    visible: false
    width: 640
    height: 760
    minimumWidth: 480
    minimumHeight: 400
    title: "Settings"
    modality: Qt.NonModal
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowMinimizeButtonHint | Qt.WindowCloseButtonHint
    color: theme.bgBase

    function showNotification(msg, type) {
        settingsNotification.showNotification(msg, type)
    }

    Rectangle {
        anchors.fill: parent
        color: theme.bgBase

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // Sticky header: title + Save/Cancel -- always visible, doesn't
            // scroll away, so you don't have to hunt for it after adding
            // more settings sections below
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Settings"
                    font.pixelSize: 22
                    font.weight: Font.Bold
                    color: theme.textPrimary
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Button {
                        height: 36
                        width: 90
                        text: "Cancel"
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

                    Button {
                        height: 36
                        width: 130
                        text: "Save Settings"
                        font.pixelSize: 13
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

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: theme.border
            }

            ScrollView {
                id: settingsScrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    id: frame
                    width: settingsScrollView.availableWidth
                    spacing: 22

                    // Window Settings Section
                    Column {
                        width: parent.width
                        spacing: 12

                        Text {
                            text: "WINDOW"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1
                            color: theme.textSecondary
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
                                    color: theme.textSecondary
                                }

                                TextField {
                                    id: widthField
                                    width: parent.width
                                    height: 36
                                    text: root.windowWidth
                                    color: theme.textPrimary
                                    font.pixelSize: 14
                                    validator: IntValidator { bottom: 1; top: 3000 }

                                    background: Rectangle {
                                        color: theme.bgSurfaceAlt
                                        border.color: parent.activeFocus ? theme.accent : theme.border
                                        border.width: 1
                                        radius: theme.radiusSm
                                    }
                                }
                            }

                            Column {
                                width: (parent.width - 12) / 2
                                spacing: 6

                                Text {
                                    text: "Height"
                                    font.pixelSize: 12
                                    color: theme.textSecondary
                                }

                                TextField {
                                    id: heightField
                                    width: parent.width
                                    height: 36
                                    text: root.windowHeight
                                    color: theme.textPrimary
                                    font.pixelSize: 14
                                    validator: IntValidator { bottom: 1; top: 3000 }

                                    background: Rectangle {
                                        color: theme.bgSurfaceAlt
                                        border.color: parent.activeFocus ? theme.accent : theme.border
                                        border.width: 1
                                        radius: theme.radiusSm
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
                            text: "TEXT APPEARANCE"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1
                            color: theme.textSecondary
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
                                    color: theme.textSecondary
                                }

                                TextField {
                                    id: sizeField
                                    width: parent.width
                                    height: 36
                                    text: root.fontSize
                                    color: theme.textPrimary
                                    font.pixelSize: 14
                                    validator: IntValidator { bottom: 1; top: 200 }

                                    background: Rectangle {
                                        color: theme.bgSurfaceAlt
                                        border.color: parent.activeFocus ? theme.accent : theme.border
                                        border.width: 1
                                        radius: theme.radiusSm
                                    }
                                }
                            }

                            Column {
                                width: (parent.width - 12) / 2
                                spacing: 6

                                Text {
                                    text: "Color"
                                    font.pixelSize: 12
                                    color: theme.textSecondary
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 36
                                    color: theme.bgSurfaceAlt
                                    border.color: colorMouseArea.containsMouse ? theme.accent : theme.border
                                    border.width: 1
                                    radius: theme.radiusSm

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width - 12
                                        height: parent.height - 12
                                        color: root.fontColor
                                        radius: theme.radiusSm - 1
                                        border.color: theme.border
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
                                color: theme.textSecondary
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
                                    color: theme.textPrimary
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: theme.bgSurfaceAlt
                                    border.color: fontComboBox.down ? theme.accent : theme.border
                                    border.width: 1
                                    radius: theme.radiusSm
                                }
                            }
                        }

                        // Preview
                        Rectangle {
                            width: parent.width
                            height: 60
                            color: theme.bgBase
                            border.color: theme.border
                            border.width: 1
                            radius: theme.radiusSm

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
                        color: theme.border
                    }

                    // Translation Model Section
                    Column {
                        width: parent.width
                        spacing: 12

                        Text {
                            text: "TRANSLATION MODEL"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1
                            color: theme.textSecondary
                        }

                        Text {
                            text: "Current: " + root.currentModel
                            font.pixelSize: 12
                            color: theme.textMuted
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

                                // ComboBox reassigns currentIndex itself whenever its
                                // model changes (to keep it in bounds), which silently
                                // destroys a declarative `currentIndex: find(...)`
                                // binding the first time that happens -- Python
                                // populating availableModels after this component is
                                // already built triggers exactly that, permanently
                                // locking currentIndex to 0 ("Gemini") regardless of
                                // the actually-saved model. Re-sync imperatively
                                // instead, any time either input actually changes.
                                function syncToCurrentModel() {
                                    var idx = find(root.currentModel, Qt.MatchExactly | Qt.MatchCaseInsensitive)
                                    currentIndex = idx !== -1 ? idx : 0
                                }
                                Component.onCompleted: syncToCurrentModel()
                                onModelChanged: syncToCurrentModel()
                                Connections {
                                    target: root
                                    function onCurrentModelChanged() { modelComboBox.syncToCurrentModel() }
                                }

                                contentItem: Text {
                                    leftPadding: 12
                                    text: modelComboBox.displayText
                                    font.pixelSize: 14
                                    color: theme.textPrimary
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: theme.bgSurfaceAlt
                                    border.color: modelComboBox.down ? theme.accent : theme.border
                                    border.width: 1
                                    radius: theme.radiusSm
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

                                onClicked: root.modelChanged(modelComboBox.currentText)
                            }
                        }

                        // Local LLM Settings
                        Column {
                            width: parent.width
                            spacing: 12
                            visible: root.currentModel === "Local LLM"

                            Row {
                                width: parent.width
                                spacing: 12

                                Column {
                                    width: (parent.width - 12) / 2
                                    spacing: 6
                                    Text { text: "Local Base URL"; color: theme.textSecondary; font.pixelSize: 12 }
                                    TextField {
                                        id: localUrlField
                                        width: parent.width
                                        height: 36
                                        text: root.localLlmUrl
                                        color: theme.textPrimary
                                        background: Rectangle { color: theme.bgSurfaceAlt; border.color: theme.border; radius: theme.radiusSm }
                                    }
                                }

                                Column {
                                    width: (parent.width - 12) / 2
                                    spacing: 6
                                    Text { text: "Local Model"; color: theme.textSecondary; font.pixelSize: 12 }
                                    TextField {
                                        id: localModelField
                                        width: parent.width
                                        height: 36
                                        text: root.localLlmModel
                                        color: theme.textPrimary
                                        background: Rectangle { color: theme.bgSurfaceAlt; border.color: theme.border; radius: theme.radiusSm }
                                    }
                                }
                            }

                            Button {
                                height: 36
                                width: 130
                                text: "Save Local LLM"
                                contentItem: Text { text: parent.text; font.pixelSize: 13; color: theme.textOnAccent; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                background: Rectangle {
                                    color: parent.down ? theme.accentPressed : (parent.hovered ? theme.accentHover : theme.accent)
                                    radius: theme.radiusSm
                                    Behavior on color { ColorAnimation { duration: theme.durationFast } }
                                }
                                onClicked: root.localLlmSettingsSaved(localUrlField.text, localModelField.text)
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: theme.border
                    }

                    // Textractor Path Section
                    Column {
                        width: parent.width
                        spacing: 12

                        Text { text: "GAME HOOKING (TEXTRACTOR)"; font.pixelSize: 12; font.weight: Font.DemiBold; font.letterSpacing: 1; color: theme.textSecondary }

                        Column {
                            width: parent.width
                            spacing: 6

                            Text { text: "Textractor Directory (containing x86 and x64 folders)"; font.pixelSize: 12; color: theme.textSecondary }

                            Row {
                                width: parent.width
                                spacing: 12

                                TextField {
                                    id: textractorPathField
                                    width: parent.width - 120
                                    height: 36
                                    text: root.textractorPath
                                    color: theme.textPrimary
                                    background: Rectangle { color: theme.bgSurfaceAlt; border.color: theme.border; radius: theme.radiusSm }
                                }

                                Button {
                                    height: 36
                                    width: 108
                                    text: "Save Path"
                                    contentItem: Text { text: parent.text; font.pixelSize: 13; color: theme.textOnAccent; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    background: Rectangle {
                                        color: parent.down ? theme.accentPressed : (parent.hovered ? theme.accentHover : theme.accent)
                                        radius: theme.radiusSm
                                        Behavior on color { ColorAnimation { duration: theme.durationFast } }
                                    }
                                    onClicked: root.textractorPathSaved(textractorPathField.text)
                                }
                            }
                        }

                        // Process Selection
                        Column {
                            width: parent.width
                            spacing: 6

                            Row {
                                width: parent.width
                                spacing: 12

                                ComboBox {
                                    id: processComboBox
                                    width: parent.width - 240
                                    height: 36
                                    model: []

                                    contentItem: Text { leftPadding: 12; text: processComboBox.displayText; font.pixelSize: 14; color: theme.textPrimary; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                    background: Rectangle { color: theme.bgSurfaceAlt; border.color: theme.border; radius: theme.radiusSm }

                                    Component.onCompleted: updateProcesses()

                                    function updateProcesses() {
                                        if (root.backend) {
                                            model = root.backend.get_running_processes()
                                        }
                                    }
                                }

                                Button {
                                    height: 36
                                    width: 108
                                    text: "Refresh"
                                    contentItem: Text { text: parent.text; font.pixelSize: 13; color: theme.textPrimary; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    background: Rectangle {
                                        color: parent.down ? theme.bgSurfaceAlt : (parent.hovered ? theme.bgSurfaceRaised : theme.bgSurface)
                                        border.color: theme.border
                                        border.width: 1
                                        radius: theme.radiusSm
                                        Behavior on color { ColorAnimation { duration: theme.durationFast } }
                                    }
                                    onClicked: processComboBox.updateProcesses()
                                }

                                Button {
                                    height: 36
                                    width: 108
                                    text: "Attach"
                                    contentItem: Text { text: parent.text; font.pixelSize: 13; color: theme.textOnAccent; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    background: Rectangle {
                                        color: parent.down ? theme.accentPressed : (parent.hovered ? theme.accentHover : theme.accent)
                                        radius: theme.radiusSm
                                        Behavior on color { ColorAnimation { duration: theme.durationFast } }
                                    }
                                    onClicked: {
                                        if (root.backend && processComboBox.currentText) {
                                            var match = processComboBox.currentText.match(/\((\d+)\)$/);
                                            if (match) {
                                                root.backend.attach_process(parseInt(match[1]))
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Thread Selection
                        Column {
                            width: parent.width
                            spacing: 6

                            Text { text: "Active Text Threads"; font.pixelSize: 12; color: theme.textSecondary }

                            Row {
                                width: parent.width
                                spacing: 12

                                ComboBox {
                                    id: threadComboBox
                                    width: parent.width - 120
                                    height: 36
                                    model: []

                                    contentItem: Text { leftPadding: 12; text: threadComboBox.displayText; font.pixelSize: 14; color: theme.textPrimary; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                    background: Rectangle { color: theme.bgSurfaceAlt; border.color: theme.border; radius: theme.radiusSm }

                                    Connections {
                                        target: root.backend
                                        function onThreadsChanged() {
                                            if (root.backend) {
                                                threadComboBox.model = root.backend.get_active_threads()
                                            }
                                        }
                                    }
                                }

                                Button {
                                    height: 36
                                    width: 108
                                    text: "Select Thread"
                                    contentItem: Text { text: parent.text; font.pixelSize: 13; color: theme.textOnAccent; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    background: Rectangle {
                                        color: parent.down ? theme.accentPressed : (parent.hovered ? theme.accentHover : theme.accent)
                                        radius: theme.radiusSm
                                        Behavior on color { ColorAnimation { duration: theme.durationFast } }
                                    }
                                    onClicked: {
                                        if (root.backend && threadComboBox.currentText) {
                                            root.backend.select_thread(threadComboBox.currentText)
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

                    // LLM Prompt Section
                    Column {
                        width: parent.width
                        spacing: 12

                        Text {
                            text: "TRANSLATION PROMPT"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1
                            color: theme.textSecondary
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
                                color: theme.textPrimary

                                background: Rectangle {
                                    color: theme.bgSurfaceAlt
                                    border.color: theme.border
                                    border.width: 1
                                    radius: theme.radiusSm
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

                            onClicked: root.promptSaved(promptTextArea.text)
                        }
                    }

                    Item { height: 8 }
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
        color: theme.bgBase

        Rectangle {
            anchors.fill: parent
            color: theme.bgBase
            border.color: theme.border
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                Text {
                    text: "Choose Color"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: theme.textPrimary
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: theme.border
                }

                // Color preview
                Rectangle {
                    width: parent.width
                    height: 80
                    color: colorDialog.selectedColor
                    border.color: theme.border
                    border.width: 1
                    radius: theme.radiusSm
                }

                Text {
                    text: "Color: " + colorDialog.selectedColor
                    font.pixelSize: 13
                    font.family: "Consolas"
                    color: theme.textSecondary
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
            height: 48
            radius: theme.radiusSm
            visible: false
            opacity: 0
            enabled: true
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.25)

            color: {
                if (settingsNotification.notificationType === "success") return theme.success
                if (settingsNotification.notificationType === "error") return theme.danger
                if (settingsNotification.notificationType === "info") return theme.accent
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
                        if (settingsNotification.notificationType === "success") return "✓"
                        if (settingsNotification.notificationType === "error") return "✗"
                        if (settingsNotification.notificationType === "info") return "ⓘ"
                        return "✓"
                    }
                    font.pixelSize: 18
                    font.bold: true
                    color: theme.textOnAccent
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: settingsNotification.message
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
