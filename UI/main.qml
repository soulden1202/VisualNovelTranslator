import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Dialogs
ApplicationWindow {

    //initial application window setting width height and opacity
    property int w : 1000
    property int h : 200
    property double o: 0.1
    property string textColor: "#FFFFFF"
    property int textSize : 20

    
    id : root
    visible : true
    width : w
    height : h
    title : "VNtranslator"
    flags : Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color : Qt.rgba(0, 0, 0, o)
    property string translated_text : "Translated text will display here"
    property QtObject backend
    Item {
        id : _dragHandler
        anchors.fill : parent
        DragHandler {
            acceptedDevices : PointerDevice.GenericPointer
            grabPermissions : PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType | PointerHandler.ApprovesTakeOverByAnything
            onActiveChanged : if (active) 
                root.startSystemMove()
            
        }
    }
    Button {
        height : 20
        width : 20
        anchors {
            top : parent.top
            right : parent.right
        }
        text : qsTr("X")
        background : Rectangle {
            color : parent.down
                ? "#bbbbbb"
                : (
                    parent.hovered
                    ? "#d6d6d6"
                    : "#f6f6f6")
        }
        onClicked : { // call the slot to process the text
            backend.close_button()
        }
    }
    Button {
        height : 20
        width : 20
        anchors {
            top : parent.top
            rightMargin : 20
            right : parent.right
        }
        text : qsTr("A")
        background : Rectangle {
            color : parent.down
                ? "#bbbbbb"
                : (
                    parent.hovered
                    ? "#d6d6d6"
                    : "#f6f6f6")
        }
        onClicked : { // call the slot to process the text
            setting.show()
        }
    }
    Text {
        anchors {
            bottom : parent.bottom
            bottomMargin : 12
            left : parent.left
            leftMargin : 12
        }
        clip : false
        text : translated_text
        font.pixelSize : textSize
        color : textColor
    }
    ApplicationWindow {
        visible : false
        width : 200
        height : 200
        id : setting
        title : "Setting"
        Column {
            id : frame
            anchors.fill : parent
            anchors.margins : 5
            spacing : 3
            Row {
                id : heigthInput
                width : frame.width
                spacing : 10
                Rectangle {
                    width : 60
                    height : 30
                    Text {
                        clip : false
                        text : "Heigth"
                        font.pixelSize : 20
                        color : "black"
                    }
                }
                TextField {
                    anchors {
                        rightMargin : 10
                    }
                    id : heightTextField
                    height : 25
                    width : 100
                    validator : IntValidator {
                        bottom : 1
                        top : 3000
                    }
                    text : root.h
                }
            }
            Row {
                id : widthInput
                width : frame.width
                spacing : 10
                Rectangle {
                    width : 60
                    height : 30
                    Text {
                        clip : false
                        text : "Width"
                        font.pixelSize : 20
                        color : "black"
                    }
                }
                TextField {
                    anchors {
                        rightMargin : 10
                    }
                    id : widthTextField
                    height : 25
                    width : 100
                    validator : IntValidator {
                        bottom : 1
                        top : 3000
                    }
                    text : root.w
                }
            }
            Row {
                id : colorInput
                width : frame.width
                spacing : 10
                Rectangle {
                    width : 60
                    height : 30
                    Text {
                        clip : false
                        text : "Color"
                        font.pixelSize : 20
                        color : "black"
                    }
                }
                Rectangle {
                    id: colorPreview
                    width : 60
                    height : 30
                    color: textColor
                    border.width: 1
                    border.color: "black"
                    MouseArea {

                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                          textColorDialog.show()
                          colorDialog.open()
                        }
                        onEntered: {
                            colorPreview.border.width = 3
                        }
                    }
                }
            }
            Row {
                id : sizeInput
                width : frame.width
                spacing : 10
                Rectangle {
                    width : 60
                    height : 30
                    Text {
                        clip : false
                        text : "Size"
                        font.pixelSize : 20
                        color : "black"
                    }
                }
                TextField {
                    anchors {
                        rightMargin : 10
                    }
                    id : textSizeField
                    height : 25
                    width : 100
                    validator : IntValidator {
                        bottom : 1
                        top : 200
                    }
                    text : root.textSize
                }
            }
            Button {
                height : 20
                width : 40
                anchors {
                    right : parent.right
                }
                text : qsTr("Save")
                background : Rectangle {
                    color : parent.down
                        ? "#bbbbbb"
                        : (
                            parent.hovered
                            ? "#d6d6d6"
                            : "#f6f6f6")
                }
                onClicked : { // call the slot to process the text
                    root.h = heightTextField.text
                    root.w = widthTextField.text
                    root.textSize = textSizeField.text
                    setting.close()
                }
            }
        }
        ApplicationWindow {
            visible: false
            width: 375
            height: 275
            id: textColorDialog
            title: "Setting"
            ColorDialog {
                id : colorDialog
                title : "Please choose a color"

                onAccepted : {
                    // textColor = colorDialog.color
                    textColor = colorDialog.selectedColor
                    colorDialog.close()
                    textColorDialog.close()

                }
                onRejected : {
                    colorDialog.close()
                    textColorDialog.close()

                }
            }
        }
        Connections {
            target : backend
            function onTranslatedText(msg) {
                translated_text = msg
            }
        }
    }
}