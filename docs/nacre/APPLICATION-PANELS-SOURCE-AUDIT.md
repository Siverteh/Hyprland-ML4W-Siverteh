# Application panels current-source audit

2026-10-10 UTC. All 58 current source bodies read individually: dashboard 39
(including 18 Settings, 8 overview and 5 media helpers), launcher 8,
notifications 2, extras 8 and lock preview 1. Current body review, completed
behavior specs, explicit replacement boundaries and later file history support
these records; filenames, green tests and change pointers alone do not.

Dashboard/Settings/media/overview/workspace/launcher/wallpaper/notification bodies
follow their independent replacements. Own extras were added in 007d020,
ChatPane in e3d0298, edge handles in 6fb4d5a, and lock preview in a0090ce.
Mechanical five-normalized-line comparison of those first sources against
then-existing non-extra shell peers/predecessors found only the native
Variants/model/Scope/id/required-screen scaffold in EdgeHandles. That is public
Quickshell per-screen API assembly, not an inherited panel algorithm. The
55fbe20 lock-preview redesign had no such five-line match; its Caelestia-style
visual reference is acknowledged. The preview uses own generated panel geometry
and native clock/provider/media contracts; it does not authenticate the session.
No upstream body was displayed or used to write a replacement in this audit.
Earlier source exposure remains acknowledged, without a legal clean-room claim.

Retain the reviewed independent bodies and current visual/layout/scroll/focus
behavior; this batch changes source records only. Detailed page controls keep
existing command owners/capability checks, private preference writes only upon
explicit actions, and guarded media seek/volume ownership. Notification hover/
suppression/history and wallpaper cached image/lazy preview behavior remain.
Referenced backend helpers, tests/fixtures and assets are not certified by these
consumer reviews. Native Qt/Quickshell and licensed fonts/icons stay dependencies.
Full-tree comparison and applicable notices remain open.

| Current source | Replacement/authoring basis | Later current-file changes | Current SHA-256 |
|---|---|---|---|
| `nacre/shell/lock-preview.qml` | `a0090ce` | 28707f7, 02b2bda, a492dc6, 9a3b9a7, 548f0b4, 807f257, 55fbe20, 83b3531, 06ffaf4, 4e411a5, e2d00b9, 524c97d | `08f8b5016ebe6e3db0e97d270dfcfe97f1651f882fa2fe512266ae9e913eb612` |
| `nacre/shell/modules/dashboard/NacreDashboardNavigation.qml` | `1cd6ab7` | 02b2bda | `6400fc0cfe92ee1b64c7cc807d483b02e63336b253f62da0c5bce4f6e237e383` |
| `nacre/shell/modules/dashboard/NacreDashboardPanel.qml` | `1cd6ab7` | 96c83f4, 19083bd, ed8f1e1, e82a4e6, 0a2b8a2 | `5e700d5575660bc03a4c4fa92162abff94b8848fec251aaee8e42db9fe33916c` |
| `nacre/shell/modules/dashboard/NacreMediaPage.qml` | `e82a4e6` | 02b2bda, 13701fc, 3a8f60a | `2745068c1f7a879b5e70a88d9140c7b9bbc44c8333f93603d4edc88dc439f81b` |
| `nacre/shell/modules/dashboard/NacreOverview.qml` | `0a2b8a2` | unchanged | `dc8596bd83c135bc8e1e58fdd1cd75581af5f9e60e66923bfdc6a4df64d87f90` |
| `nacre/shell/modules/dashboard/NacrePerformancePage.qml` | `e82a4e6` | 18d8aab, 3a8f60a | `3fa5ff3136c13bd009d341dced5544e174370f59181ba7b18ae8a81689779143` |
| `nacre/shell/modules/dashboard/NacreSettings.qml` | `19083bd` | 5da1132, 02b2bda, b770506, cbef0e4, c230d36 | `b2e64510749a2cd1e68ca5f9a76aafc860e5958a57298c2f6a9d7a100dbc771a` |
| `nacre/shell/modules/dashboard/NacreWorkspacePage.qml` | `ed8f1e1` | 02b2bda, ea5653e | `37e27a16b286a461c6baed0fd97700d3f3577562399f648d9fa4afe14f523704` |
| `nacre/shell/modules/dashboard/media/NacreAlbum.qml` | `e82a4e6` | unchanged | `9bba1804b18ddab5cb64c62838864da730d831e4e9b91c5399409a2da166a1e2` |
| `nacre/shell/modules/dashboard/media/NacreMediaButton.qml` | `e82a4e6` | unchanged | `35ee2f8ef3ac2d8ab41bda99927cc332c7a07a14c49842116d8a25908154c9f0` |
| `nacre/shell/modules/dashboard/media/NacreMediaSlider.qml` | `e82a4e6` | unchanged | `b3da92e675a0fa231a37693ca4ae0a7873e1457886f7504f1de5828d7f537633` |
| `nacre/shell/modules/dashboard/media/NacreMetricRing.qml` | `e82a4e6` | 02b2bda | `3cb9f2e9b817d83e3860228d6c9f77754686005068b4d62d5d214cd7446a57a4` |
| `nacre/shell/modules/dashboard/media/media.js` | `e82a4e6` | unchanged | `d6d8c6b99850cdd8c6122187cff5f85b60d41d5a29c3cdd32ed1551f9f25772f` |
| `nacre/shell/modules/dashboard/overview/NacreCalendarCard.qml` | `0a2b8a2` | 02b2bda, a492dc6 | `208d639be5b50cff2ff2ad891c563a3c2c111c2b6ac0b87ba000417a897da8d4` |
| `nacre/shell/modules/dashboard/overview/NacreClockCard.qml` | `0a2b8a2` | 02b2bda, a492dc6 | `bad20c9d87b806c81822f830a38694f528b2d61fd8e199063534f6133daba8ae` |
| `nacre/shell/modules/dashboard/overview/NacreHostCard.qml` | `0a2b8a2` | unchanged | `2f7ad9dbf163bb6a0b81441d559cbd13a4a5e809fb6d4f98b43be14aa3fdb70b` |
| `nacre/shell/modules/dashboard/overview/NacreMediaCard.qml` | `0a2b8a2` | 02b2bda, 13701fc | `3e1270e646dd3d48c38339f9d00020ab0ef76c9e56bd76af30b89c2d3d7cc6ee` |
| `nacre/shell/modules/dashboard/overview/NacreOverviewCard.qml` | `0a2b8a2` | 02b2bda | `6804370e4676c092957d89db238c76b5201257fdb168a90acff651d243609b93` |
| `nacre/shell/modules/dashboard/overview/NacreResourceCard.qml` | `0a2b8a2` | 02b2bda, 18d8aab | `bc49de4740bd7ac35806916458c9d745e066c47386b29095b7f2ab0a65f1b5ac` |
| `nacre/shell/modules/dashboard/overview/NacreWeatherCard.qml` | `0a2b8a2` | 28707f7, 02b2bda | `d3fa507877f35b55da7975b88401616daf673f91d7e3971b1fb5dafda7de36e1` |
| `nacre/shell/modules/dashboard/overview/overview.js` | `0a2b8a2` | unchanged | `5fe9aaa801a4c3541988b3ba16f935c2ce87b3783849d65b1f8d1460fb29c699` |
| `nacre/shell/modules/dashboard/settings-catalog.js` | `19083bd` | unchanged | `c3c25441dbec86c097cd483e9d6137c3c3eb88505ef7a389fd39028036b51b48` |
| `nacre/shell/modules/dashboard/settings/NacreAiPage.qml` | `b770506` | unchanged | `982c5e5e6888af9ad4b09fea3f4573a6e047510fecdb88fc13a606ba0d0b5396` |
| `nacre/shell/modules/dashboard/settings/NacreAppearancePage.qml` | `c230d36` | 28707f7 | `9588bc49e0bfc4abef41c5977d6e4c5cdbedb1de68fd9a012892f8a95edc8940` |
| `nacre/shell/modules/dashboard/settings/NacreAudioNode.qml` | `b770506` | unchanged | `1f7ad8a9f2c7868cd1555600226b866712e48e7a1795866d789c4ad504b3a4bb` |
| `nacre/shell/modules/dashboard/settings/NacreBluetoothPage.qml` | `b770506` | d4a82bb | `10f373bad239b4c87a27742d7627fa3d3675b68e8180501ef74e55dc4bad31df` |
| `nacre/shell/modules/dashboard/settings/NacreDesktopPage.qml` | `cbef0e4` | unchanged | `b330de5e96612b0c78fdacbc0525298154962a802914db33ba718ccaa0ba91cf` |
| `nacre/shell/modules/dashboard/settings/NacreDisplaysPage.qml` | `cbef0e4` | unchanged | `f5071befc98e10669b80ce51175c92cbcab272c07bdd8004b8a24b73ca44aace` |
| `nacre/shell/modules/dashboard/settings/NacreLockPage.qml` | `b770506` | 28707f7 | `ae3b96cd4f2cbf54d2960352c5dbf46ac559d4f8f434049779bc8e4353a40ca5` |
| `nacre/shell/modules/dashboard/settings/NacreMaintenancePage.qml` | `cbef0e4` | unchanged | `3b598feac6e4fe887b7f08800a71204692ce1fb0c5ef05d5e83bd1542b05c1ed` |
| `nacre/shell/modules/dashboard/settings/NacreNetworkPage.qml` | `b770506` | f1ef99a, 977f628 | `3de47daa83f9650db58e3203d7eae67c98d330defdf300c4ceecf36bc43bae41` |
| `nacre/shell/modules/dashboard/settings/NacreNotificationPage.qml` | `b770506` | e4d2474 | `61959d60df742786d3efab978b0bf413dcd412cf02a3ef09ae19f1af2bbaaf40` |
| `nacre/shell/modules/dashboard/settings/NacreNumberField.qml` | `c230d36` | unchanged | `3093d13e9dec540fd44fe83ea9be5d4f22b0556156d1c39deed128e713ad6f1d` |
| `nacre/shell/modules/dashboard/settings/NacrePaletteTile.qml` | `c230d36` | unchanged | `c7614c0f9c9a0d1e218beb5dfd17a2a3656faabe79e2fd0f9ef818cae8f40918` |
| `nacre/shell/modules/dashboard/settings/NacreSettingToggle.qml` | `19083bd` | 02b2bda | `89c889302c905871da3f955e4511b89a05e757a9ef41de2f215568f33ad0caca` |
| `nacre/shell/modules/dashboard/settings/NacreSettingsPage.qml` | `19083bd` | unchanged | `a9edc6c728e179cbee4feff9c13c49aa501f595c4248763a1fa315818041b86f` |
| `nacre/shell/modules/dashboard/settings/NacreSettingsSection.qml` | `19083bd` | 02b2bda | `6731423a090a75253f5fe7487972431c6e4450ebdae13806f5550ad6981e6b43` |
| `nacre/shell/modules/dashboard/settings/NacreSoundPage.qml` | `b770506` | unchanged | `d8732e870cc7dc15a9240dd8353d748690657ea51a9c9a935367438a9f855756` |
| `nacre/shell/modules/dashboard/settings/NacreTimePage.qml` | `b770506` | unchanged | `57458fce88c775a3ca4a04dde70754698af0c5b638c86f00ef8d3a0c97e4c35d` |
| `nacre/shell/modules/dashboard/settings/NacreWorkflowsPage.qml` | `cbef0e4` | unchanged | `4e4a57b7b4195ac6c9e1c25ee42af7ce8350d03a2359cc2ede5366996487f616` |
| `nacre/shell/modules/extras/ChatPane.qml` | `e3d0298` | 02b2bda, 9a3b9a7, 548f0b4, 67065bf, b12961b, 83b3531, 5d0028f, 36dc0ba, 8bd5e65, e83d56f, 973e0a4, 5c3cd84, a7495cb, ddb0066, d10c724 | `ee649fb1423e883c1b74abaf4f93d3b654423a2b2ceb0cb80f42f525170b4926` |
| `nacre/shell/modules/extras/Clipboard.qml` | `007d020` | 02b2bda, 9a3b9a7, 548f0b4, 2c1d2ca, 83b3531, 5d0028f, e3d0298 | `3978592538c0aa3a32d2ea600970a1c9bfc33d288415d3fc1e14577bb4324ae0` |
| `nacre/shell/modules/extras/EdgeHandles.qml` | `6fb4d5a` | 5da1132, 9a3b9a7, 548f0b4, b12961b, 2c1d2ca, 9deeee7 | `d78ebfceddf2173fa83f98fa5159a2ab0ecd2a96ca0d22f35ceb39b82834e6b5` |
| `nacre/shell/modules/extras/Keybindings.qml` | `007d020` | 02b2bda, 9a3b9a7, 548f0b4, 2c1d2ca, 83b3531, 5d0028f, e3d0298 | `6ca6019e38081fdce4033b3f97e56f7b7fd13e386e4fe182d4908bb711bfe41b` |
| `nacre/shell/modules/extras/LeftDrawer.qml` | `007d020` | 02b2bda, ea5653e, 9a3b9a7, 548f0b4, 22e240b, 83b3531, 5d0028f, e83d56f, d10c724, e3d0298, 3121dad | `c16f300b5ee4e41bcac52dd5398a85ec3a83dd6640a289a56ba0c6d704be7491` |
| `nacre/shell/modules/extras/Overview.qml` | `007d020` | 02b2bda, ea5653e, 9a3b9a7, 548f0b4, 83b3531, 5d0028f, e3d0298 | `cffc581c63f7c47ca4614e92050d3bd875ab06f19c446f8ae4faf72958b4d636` |
| `nacre/shell/modules/extras/Palette.qml` | `007d020` | 02b2bda, ea5653e, 3d93b32, 9a3b9a7, 548f0b4, 83b3531, 5d0028f, e3d0298 | `0b1c6d05742b812c9658d36899c27bd0fa5bf30c09afbd737523bfd18016d696` |
| `nacre/shell/modules/extras/SearchSurface.qml` | `007d020` | 02b2bda, 9a3b9a7, 548f0b4, 83b3531, 5d0028f | `32b25d196e485f067d63862db2a6f664b866357274db81d72afaf574e2c0b5b3` |
| `nacre/shell/modules/launcher/NacreAppBrowser.qml` | `bc7c7e2` | 02b2bda, 3d93b32 | `c688dfd41714aeaf5c67c62aa59f9b2e63ce8430ab02fd35befe3fb01e737fb8` |
| `nacre/shell/modules/launcher/NacreLauncherPanel.qml` | `7b53c65` | 28707f7, bc7c7e2 | `02d83b1d65247d481aa4dae0e6891f8ac17b66a3cf5bf93510d6d4996e2b29a5` |
| `nacre/shell/modules/launcher/NacreSearchPanel.qml` | `7b53c65` | 02b2bda, 3d93b32 | `d8dec7fd7e03b83d4a7201b5dac55bb364a495e606839ddaaf6b68ed726081dd` |
| `nacre/shell/modules/launcher/NacreWallpaperBackdrop.qml` | `bc7c7e2` | unchanged | `3d310c9372f28163a8f9029df4fe2d2db9c02aad02335c208b00df4f8e356868` |
| `nacre/shell/modules/launcher/NacreWallpaperHex.qml` | `bc7c7e2` | 02b2bda | `74ddf62742ee789ed2e7582b0690c9921a32ffa5434e3224be4587f3a08371f6` |
| `nacre/shell/modules/launcher/NacreWallpaperMotion.qml` | `bc7c7e2` | unchanged | `c7af560c0584ede098e9479225cf9cc86d77a4525a26186f27379b084350827e` |
| `nacre/shell/modules/launcher/NacreWallpaperPicker.qml` | `bc7c7e2` | 28707f7, 02b2bda | `86e9d6978d7ab3edc8553d385e3af8cadb2eb68131bf6ab69fccb914463abe64` |
| `nacre/shell/modules/launcher/app-browser.js` | `bc7c7e2` | unchanged | `4b27f799d384df32e762a740870f975ad9b7277c290f0af87b87200f95cbbc4d` |
| `nacre/shell/modules/notifications/NacreNotice.qml` | `e869927` | 02b2bda, e4d2474 | `1b09b5abdea2989d50903b1abed5d234b6b43f964bc2c65d0925e605d13185e8` |
| `nacre/shell/modules/notifications/NacreNotificationStack.qml` | `e869927` | e4d2474 | `00a4825a6fa9d2d4201488083a48a34da3e0e9961cb0989b0ff15f96ac6ac1bf` |
