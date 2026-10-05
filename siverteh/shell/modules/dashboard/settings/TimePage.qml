import "root:/widgets"
import "root:/services"
import QtQuick
SettingsPage {
 SettingsSection {title:"Local time";description:"The system clock stays synchronized in UTC. Your timezone sets the local time shown by apps."
  StyledText {text:TimezoneSettings.status.localTime??"Checking local time…";font.pointSize:19;color:Colours.palette.m3primary}
  StyledText {text:TimezoneSettings.status.timezone??"";font.pointSize:12}
  Row {spacing:8
   ActionButton {text:"Refresh status";icon:"refresh";onClicked:TimezoneSettings.refresh()}
   ActionButton {text:TimezoneSettings.status.automatic?"Turn off automatic timezone":"Enable automatic timezone";selected:TimezoneSettings.status.automatic??false;enabled:!TimezoneSettings.busy;onClicked:TimezoneSettings.change(TimezoneSettings.status.installed?"automatic":"install",TimezoneSettings.status.installed?(TimezoneSettings.status.automatic?"off":"on"):"")}
  }
  StyledText {width:parent.width;wrapMode:Text.Wrap;text:"Automatic mode follows your public network location on connection changes and checks every 15 minutes. It keeps the current timezone when lookup is unavailable.";font.pointSize:10;color:Colours.palette.m3onSurfaceVariant}
  StyledText {width:parent.width;wrapMode:Text.Wrap;text:TimezoneSettings.status.error||TimezoneSettings.message;visible:text.length>0;font.pointSize:10;color:Colours.palette.m3onSurfaceVariant}
 }
 SettingsSection {title:"Manual timezone";description:"A manual override turns off automatic changes. Use an IANA name such as America/Chicago or Europe/Oslo."
  StyledTextField {id:zone;width:parent.width;height:40;text:TimezoneSettings.status.timezone??"";placeholderText:"Area/City";leftPadding:12;background:StyledRect {radius:12;color:Colours.palette.m3surfaceContainerHigh}}
  ActionButton {text:"Use this timezone";enabled:!TimezoneSettings.busy&&TimezoneSettings.status.installed;onClicked:TimezoneSettings.change("manual",zone.text.trim())}
 }
 Component.onCompleted:TimezoneSettings.refresh()
}
