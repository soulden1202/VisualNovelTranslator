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
            // Save to config file
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
    }
}
