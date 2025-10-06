import QtQuick

Text {
    id: root
    
    property string displayText: ""
    property int fontSize: 20
    property string fontColor: "#FFFFFF"
    property string fontFamily: "Arial"
    
    text: displayText
    font.pixelSize: fontSize
    font.family: fontFamily
    color: fontColor
    wrapMode: Text.Wrap
    elide: Text.ElideNone
    clip: false
}