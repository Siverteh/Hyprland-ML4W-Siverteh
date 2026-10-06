import qs.widgets
import qs.services
import QtQuick
SettingsPage {
 SettingsSection {title:"Your lock screen";description:"Wallpaper colors, a large clock and live information around the password field."
  Row {spacing:8
   ActionButton {text:"Preview layout";icon:"preview";onClicked:AppLaunch.run(["siverteh-os-shell","lock-preview"])}
   ActionButton {text:"Lock now";icon:"lock";onClicked:AppLaunch.run(["hyprlock"])}
  }
  SettingToggle {label:"Media information and playback controls";setting:"lockMedia"}
  SettingToggle {label:"Weather conditions";setting:"lockWeather"}
  SettingToggle {label:"Notification summaries";setting:"lockNotifications"}
  SettingToggle {label:"Show notification titles and message previews";setting:"lockNotificationContents"}
  StyledText {width:parent.width;wrapMode:Text.Wrap;text:"With message previews off, the lock screen shows app names and notification counts. Unlocking always requires your normal password.";font.pointSize:10;color:Colours.palette.m3onSurfaceVariant}
 }
 SettingsSection {title:"Weather";description:"Leave the location empty for an approximate city based on your public IP. Cached conditions remain available offline."
  StyledTextField {id:city;width:parent.width;height:40;text:DesktopSettings.data.weatherLocation??"";placeholderText:"City, for example Oslo";leftPadding:12;background:StyledRect {radius:12;color:Colours.palette.m3surfaceContainerHigh}}
  Row {spacing:8
   ActionButton {text:"Save location";onClicked:DesktopSettings.set("weatherLocation",city.text.trim())}
   ActionButton {text:"Refresh weather";onClicked:Weather.reload()}
  }
  SettingToggle {label:"Use Fahrenheit";setting:"weatherFahrenheit"}
  StyledText {width:parent.width;wrapMode:Text.Wrap;text:Weather.description?(Weather.location?Weather.location+" · ":"")+Weather.description+" · "+Weather.displayTemperature:Weather.error||"Weather is not available yet";font.pointSize:11;color:Colours.palette.m3onSurfaceVariant}
 }
}
