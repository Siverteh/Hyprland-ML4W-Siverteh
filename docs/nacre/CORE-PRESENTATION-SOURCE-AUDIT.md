# Core presentation current-source audit

2026-10-10. Current bodies individually read against completed independent
replacement specs/boundaries and later file histories. Properly licensed native
APIs/fonts remain dependencies; helpers/assets/other fixtures separately reviewed.

| Current source | Replacement/authoring basis | Later current-file changes | Current SHA-256 |
|---|---|---|---|
| `nacre/shell/modules/NacreShellIpc.qml` | `5da1132` | unchanged | `8ae178b4660f3ba211c4d569b67c3306b39c051c86711162ba182698b1d9917b` |
| `nacre/shell/modules/NacreShellShortcuts.qml` | `5da1132` | unchanged | `712d6c4b107134e65063375baddb2a0bb1ca34156a88f7a3588f7f95f71fbda7` |
| `nacre/shell/modules/Shortcuts.qml` | `5da1132` | unchanged | `eae64d7c69ab58bb0bbb8a57ece7937bce04fb6d6759162f3e6333b47cfe3d81` |
| `nacre/shell/modules/background/Background.qml` | `216f23a` | unchanged | `92bf4602f6fcedc18ed94990c4969b0160025e72d06d76311679235d1edcf046` |
| `nacre/shell/modules/background/DynamicWallpaper.qml` | `216f23a` | unchanged | `b7ad0b5b7885f6f18eb627833b8ea15e8b0f9b7160abda86763e699b53b8e032` |
| `nacre/shell/modules/background/NacreBackground.qml` | `216f23a` | 5da1132 | `5ef1d6ac4e004aff4734a5745a43a631a8bef3dfa52d9fd824a01f4735bfdf61` |
| `nacre/shell/modules/background/NacreDesktopVideo.qml` | `216f23a` | unchanged | `d5e1b55240e7ad0fcd210088e222c44427bf765aa3856a8434f03678c7d86168` |
| `nacre/shell/modules/background/NacreWallpaperScene.qml` | `216f23a` | 5da1132, d1d9a1e | `244365d7b015fab4b929925941395933c3aacf4a6ca82ab057452000e98ff404` |
| `nacre/shell/modules/background/Wallpaper.qml` | `216f23a` | unchanged | `8319c36eea91572eb82b9ebc6f6d9fb34bd80a92734d76994790006ca9b12e91` |
| `nacre/shell/modules/bar/components/ActiveWindow.qml` | `ce69bc0` | unchanged | `9c6e718083aaa43e0fea88bfda581c937e5feec9658fe90f93a0557ec7ba9347` |
| `nacre/shell/modules/bar/components/NacreActiveTitle.qml` | `ce69bc0` | unchanged | `abf5dcb381d4084b6f54efe4860b00fdd9e6eb22bc0a0ceb288b809dfb7e4c01` |
| `nacre/shell/modules/bar/components/NacrePowerButton.qml` | `ce69bc0` | 5da1132 | `ae48e901f1f4d2fb6b44d06ed211d43e7dda060f016571a7fbdcab04c8245d3e` |
| `nacre/shell/modules/bar/components/NacreStatusIcons.qml` | `ce69bc0` | 5da1132, dc01bf9, 96c83f4 | `9365fcb0a033bad2abbe1824a5df060df81e42509af1df2d06cb374b86bb8f9f` |
| `nacre/shell/modules/bar/components/Power.qml` | `ce69bc0` | unchanged | `36df82c1e2a031380261d7205cd55f23b78eecf3618f0d594f9e997f75afcb52` |
| `nacre/shell/modules/bar/components/StatusIcons.qml` | `ce69bc0` | unchanged | `24fb0163a0f73ef6145a4af860d8f8f04a21083ddc33e6fbab33763c2a925ddd` |
| `nacre/shell/modules/bar/popouts/Audio.qml` | `28db63f` | unchanged | `9f4685cac77c9395b7c0cca8ac7548dfe2f0e63a185343859ecd9e0c9e1897af` |
| `nacre/shell/modules/bar/popouts/Battery.qml` | `ce69bc0` | unchanged | `4fe7e5fd1e17fecde29124baa12509ca4b2e5f414a531b4eb9f259446b10abfa` |
| `nacre/shell/modules/bar/popouts/Bluetooth.qml` | `28db63f` | unchanged | `3498d08b3e225faac2fab771dc317a698e302ba9f0ff36a8c147c19304e5361b` |
| `nacre/shell/modules/bar/popouts/Calendar.qml` | `ce69bc0` | unchanged | `028582f9ac2ba5731e1ae77918d7974847a864339a51b31eb51b04d9a646feaa` |
| `nacre/shell/modules/bar/popouts/Content.qml` | `28db63f` | unchanged | `79cd5753185018f3252c918571d77ad1be10f59eef7450be2f88dc3f65cfc2d2` |
| `nacre/shell/modules/bar/popouts/NacreBatteryPopup.qml` | `ce69bc0` | unchanged | `7a5466c6e025f5b1da124fdb77c318d84627395702dedfcab331892e970703f3` |
| `nacre/shell/modules/bar/popouts/NacreBluetoothPopup.qml` | `28db63f` | unchanged | `b6eb3fdd41130a2d76ef1771d4ff7eac0e962b994d7230535121048f611b9c9e` |
| `nacre/shell/modules/bar/popouts/NacreCalendarPopup.qml` | `ce69bc0` | unchanged | `655d8fd12b561aae6e012a559e556819922add6a4b5eeb80435f5097a0c60955` |
| `nacre/shell/modules/bar/popouts/NacreHistoryPopup.qml` | `28db63f` | unchanged | `ffcf9ecf0815c69f2d145a6a127bedba3ea5595befd4a222f4dccb91c8253229` |
| `nacre/shell/modules/bar/popouts/NacreNetworkPopup.qml` | `28db63f` | unchanged | `87df4880ecba42708ff8e1736ee8d9dbf1a60e6d99434bdca97d93b386982c7f` |
| `nacre/shell/modules/bar/popouts/NacrePopupContent.qml` | `28db63f` | unchanged | `47b600a127fc26c8ff32cd14987361e3136c2877b772614dda80ada436a7af9c` |
| `nacre/shell/modules/bar/popouts/NacrePopupPanel.qml` | `28db63f` | 490d457, 6e09600 | `28a7ac8efb79d5d0bffc2670b8832e940a32cdbdca0c6ada220956a8d041a5b4` |
| `nacre/shell/modules/bar/popouts/NacreQuickList.qml` | `28db63f` | unchanged | `767e1426779ca1af4409cbd8adc66b61f05082fd86152c16d4dd0b5d0db825ef` |
| `nacre/shell/modules/bar/popouts/NacreQuickSlider.qml` | `28db63f` | unchanged | `a00f6873f3633ccdac70ad3f070bd8d25a6cc3aeaffa81cac322c15257459c15` |
| `nacre/shell/modules/bar/popouts/NacreSoundPopup.qml` | `28db63f` | ada8f42 | `b3ce0cefba0cc060ec4ee6065653a22c21b63182b4348c9b77d33f0ee96ed1ba` |
| `nacre/shell/modules/bar/popouts/Network.qml` | `28db63f` | unchanged | `a0ffd9451cc0f74f5b60072e0462b15e204aaeea1a0dc2eb9a6a869e40aaa02e` |
| `nacre/shell/modules/bar/popouts/Notifications.qml` | `28db63f` | unchanged | `d7cf5e438373d737368778cffb13defc817c9e2f587947578b45670200db0a54` |
| `nacre/shell/modules/bar/popouts/QuickList.qml` | `28db63f` | unchanged | `36490eb6319a4acca44f7e3fedded7dd5db1e9fbe402a637596de997b099e618` |
| `nacre/shell/modules/bar/popouts/QuickSlider.qml` | `28db63f` | unchanged | `6466a304d7a82f5e3c438108befc2dd1755e24d7d23d1fd731eb7a51f737ce78` |
| `nacre/shell/modules/bar/popouts/Wrapper.qml` | `28db63f` | unchanged | `f7308416fa81f3e744daae9fd693cd66da460d0d529da8253b57637f37b2905c` |
| `nacre/shell/modules/drawers/NacreChrome.qml` | `609a1e4` | unchanged | `63e1fd15f9397058527527782b1dc7c4c720c8027b8c7c1524e8ecc4d5ad616f` |
| `nacre/shell/modules/drawers/NacreDesktop.qml` | `609a1e4` | 5da1132, 966ae9e, ea5653e | `b08c84e2ff356d1bfff0abcf71f4d6f95dafffc0deef39a962236212a6aad4b5` |
| `nacre/shell/modules/drawers/NacrePanelHost.qml` | `609a1e4` | 216f23a, 28db63f, 1cd6ab7, e869927, 7b53c65, 239af3a | `7e062ae0a6c8721ab41aa1f54fa08e1be30a11c014f1cf1a8de6dca7ef70ac69` |
| `nacre/shell/modules/drawers/NacrePanelInput.qml` | `609a1e4` | 5da1132, 966ae9e | `3ff1d6d165545769ad08469d353883b9ade121f9d252795d355f0a2e1920a559` |
| `nacre/shell/modules/drawers/NacrePanelMask.qml` | `609a1e4` | unchanged | `0555541a289ac48db8274d7734e820df73e2dd53236b556936d51d992abf361e` |
| `nacre/shell/modules/drawers/NacreReservedEdges.qml` | `609a1e4` | unchanged | `25d6e248614f874111ae091e0675017b20c2efc4fa64f62175e7eff03b7a7e82` |
| `nacre/shell/modules/drawers/NacreScreen.qml` | `609a1e4` | 5da1132, 216f23a, 8d96a29, 239af3a | `208c31bab243e5fb20cf8a599478f901548b2442e7211d812492c326ea461477` |
| `nacre/shell/modules/drawers/layout.js` | `239af3a` | unchanged | `612da7d5655dfb6cd9aa814e0433ffa7187519bc754675a53e8efcac61d4e5da` |
| `nacre/shell/modules/drawers/registry.js` | `609a1e4` | unchanged | `640445c5b66cfbb3472abeafe0a30faa19e42adbcc500501c6edb1fa40ccf10e` |
| `nacre/shell/modules/osd/Content.qml` | `216f23a` | unchanged | `23e8024d2e8a3bb94564aa37a10c8ab0e90cde527a100bc68563496fad4d09f6` |
| `nacre/shell/modules/osd/Interactions.qml` | `216f23a` | unchanged | `28a43e8053ffb60b05d36fe6986c5451cdd4723d722d3c32c45b9d6d648739f0` |
| `nacre/shell/modules/osd/NacreOsdControls.qml` | `216f23a` | unchanged | `9a32efdca63736baef5c251e6c4d137b015fa48f53e0465e069c2cc326527637` |
| `nacre/shell/modules/osd/NacreOsdEvents.qml` | `216f23a` | unchanged | `a915eee18bfc7c4332a4ff5cf5b41d9829892f66e8a94afb55427430b03605ea` |
| `nacre/shell/modules/osd/NacreOsdPanel.qml` | `216f23a` | unchanged | `96992b605188b699592086160dc3a3431cf8407852ac7bddb020ab4f8806b2df` |
| `nacre/shell/modules/osd/Wrapper.qml` | `216f23a` | unchanged | `e268d215aaf703a6b421e4ecf44e4c055ac537625df174e4b43784dc351f5d6f` |
| `nacre/shell/modules/session/Content.qml` | `216f23a` | unchanged | `0e6e111f09106fc1d7caee7e385d21c56e1787150e815974e7137cb94e37cae4` |
| `nacre/shell/modules/session/NacreSessionControls.qml` | `216f23a` | unchanged | `facf3caa7369eb974cf300b58f385fb647edd3d13c7001e2f624f35f26a6616e` |
| `nacre/shell/modules/session/NacreSessionPanel.qml` | `216f23a` | d1d9a1e | `3042ff147de53dce4269d1a9feff4e9c239339f83bd06a917c0d33fad59c41c8` |
| `nacre/shell/modules/session/Wrapper.qml` | `216f23a` | unchanged | `4ac89fd90e7d88acc6697d5012476e1b804c6e8e626ac35213c53eb2ffb7037d` |
| `nacre/shell/modules/topbar/NacreHeader.qml` | `966ae9e` | 5da1132, 7c8f3a6 | `f34ccb48b1377a507ebb6e4de940353311ded7c7851e8f7bffe0e87a54a2ecdc` |
| `nacre/shell/modules/topbar/NacreHeaderForwarder.qml` | `966ae9e` | 5da1132 | `7528e10fbe234162252f93867c1071dba8e89a32ece5f5261ea52d29d5b8ceb6` |
| `nacre/shell/modules/topbar/NacreHeaderTrigger.qml` | `966ae9e` | 5da1132 | `da16a40627257699f48ffd32209ebe9b12cade457e618d10246814d3c4975f0c` |
| `nacre/shell/modules/topbar/NacreTopBar.qml` | `966ae9e` | 5da1132 | `384bc53e3a86aaa3eadb60293285f1ca7757920498503e1deaf66ad8844f4713` |
| `nacre/shell/modules/topbar/NacreWorkspaceRow.qml` | `966ae9e` | unchanged | `861ad3050d2ce7be1eb951e9b58049c6ba7fbe8e4c8bc47994a9bffe1dbb88fc` |
| `nacre/shell/modules/topbar/TopBar.qml` | `966ae9e` | unchanged | `b71c105b0b0118cc7319d88021edbdd749901b5c661ddeeefde7890336ebd954` |
| `nacre/shell/modules/topbar/WorkspaceStrip.qml` | `966ae9e` | unchanged | `72fce00f6a128339d1afb71ced8103d49d2ba67623e1bff5ffb98ad716893efd` |
| `nacre/shell/shell.qml` | `5da1132` | 36c35e0 | `d3e40ea09882259a0f0480c0790c20b3b705d804cf9366ffff84373ff295ac3c` |
