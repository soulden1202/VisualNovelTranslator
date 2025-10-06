import QtQuick
import QtQuick.Controls.Basic

Row {
    id: root
    spacing: 10
    
    property string labelText: ""
    property int textValue: 0
    property int maxValue: 3000
    property string inputId: ""
    
    function getValue() {
        return parseInt(textField.text)
    }
    
    Rectangle {
        width: 60
        height: 30
        Text {
            clip: false
            text: root.labelText
            font.pixelSize: 20
            color: "black"
        }
    }
    
    TextField {
        id: textField
        anchors.rightMargin: 10
        height: 25
        width: 100
        validator: IntValidator {
            bottom: 1
            top: root.maxValue
        }
        text: root.textValue
    }
}