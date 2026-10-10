# Login and Files current-source audit

2026-10-10 UTC. Nine complete maintained login/config/helper/Thunar bodies and six
specific test sources individually reviewed against local authoring and current
native contracts. The separately reviewed Logo remains an asset dependency.

Login presentation/config/helpers first cb36d47 use public QtQuick and SDDM
models/proxy APIs; later sizing, own logo and palette cache changes traced.
Thunar's four bodies first 338417c use local app-scoped native integration;
current thunar-files.py explicitly follows the earlier thunar-trial.py rename.
Initial installer comparison shared trial extraction/setup only with own local
Yazi/Dolphin installers 30a52ae/86bebe6; 47b06d4 retired private native extraction.
Current compiler/desktop/MIME setup reviewed as local standard native interface
assembly. Other first-source five-normalized-line peer comparisons found no
copies. These metrics supplement history/current body review, not sole origin
proof or the final whole-upstream comparison. Earlier exposure acknowledged;
no legal clean-room/final-license claim.

Unused issue originated in ML4W import 989022d, with only later branding history.
It had no active caller; login installer FILES lists only Main/Logo/theme.conf/
metadata.desktop, all matching the installed root theme. Actual /etc/issue differs.
Retire the uncertain repository artifact without viewing/copying its body to
reproduce it, add retired-path guard, and leave the system banner and auth intact.
No new banner owner or root theme mutation is needed.

Own new actual greeter fixture uses fake public models/proxy, verifying selected
user/session, submission prerequisites/busy guard, explicit retry and clearing on
failure/success, invalid color fallback. Existing appearance fixture now scopes
its cache to temporary HOME. Existing native GTK fixture compiles the actual
module and verifies an atomic CSS replacement recolors the same widget. Test
source origins individually traced; unrelated fixtures not certified by consumers.
Native APIs and stock licensed fonts/icons remain dependencies; no real auth,
account, device, power or AI action is used for verification.

[SDDM model/proxy contracts](https://github.com/sddm/sddm/wiki/Theming).

| Current source | Authoring basis | Later path changes | Current SHA-256 |
|---|---|---|---|
| `nacre/login/Main.qml` | `cb36d47` | 548f0b4, 83b3531, b0632b9, b57c06a | `1af709dc68f280500c305c5f35d0cd3c05830d8200f9045353123f227b45f389` |
| `nacre/login/metadata.desktop` | `cb36d47` | 548f0b4 | `506f87f9d65cc23aeede9608736bdf8eadc7d29f6a824935123f17020ec75d31` |
| `nacre/login/theme.conf` | `cb36d47` | 548f0b4 | `a6bf8bfcb7386705ba5a3ea530780627ce25cfc020b52226d3a28bbf4458bea9` |
| `nacre/shell-tools/login-appearance.py` | `cb36d47` | 548f0b4, bb46dd6, 83b3531, 09f9ceb | `c68339fe4dac3d78932047745d588a442d1f9cbbc5fcbc84215747162b1754e6` |
| `nacre/shell-tools/login-install.py` | `cb36d47` | 548f0b4, bb46dd6, 83b3531, b0632b9 | `156fd1a5f4539bb858340d86f11db4dc33469b82954ca29a44be614062b011fc` |
| `nacre/shell-tools/thunar-files.py` | `338417c` | 548f0b4, 47b06d4, a046f7b | `ed0bcc93f426790d1ab54726d2a2e03cb404999651cd388e7b05de8f473a0e84` |
| `nacre/shell-tools/thunar-theme.c` | `338417c` | 548f0b4 | `f127c692a396c869edfb853d64e98f8612da27a9e4c36da7ca1e496eb90c7d36` |
| `nacre/shell-tools/thunar.css` | `338417c` | 548f0b4 | `94c73b33ecf5538ebc61a13a1686f1946682338b5d1bbf43d35981098809bca1` |
| `nacre/shell-tools/install-thunar.py` | `338417c` | 548f0b4, 47b06d4, a046f7b | `684412ce41f5b4f6e1af5e6213acb64dd1a38a1d4ed212dd31a87c29695671b4` |
| `nacre/shell-tools/tests/test_login_theme.py` | `cb36d47` | 7a524e7, 548f0b4, 83b3531, 09f9ceb | `801c40fd06619629da003ce9e767d2b115076b8d367f931815b6518cb506fb22` |
| `nacre/shell-tools/tests/test_thunar_style.py` | `338417c` | 548f0b4 | `c4cfe2c7fb4f98970f8f001098ab053323708f39c8df81d26467f32dfbd46396` |
| `nacre/shell-tools/tests/native/thunar-style.c` | `338417c` | 548f0b4 | `e679805dde5e84cee5f7628cd98d7baa991a36c0aba74de424c12e6bd60491f4` |
| `nacre/shell-tools/tests/test_runtime_environment.py` | `47b06d4` | 548f0b4 | `396b0a59b8c1dcb330ce479205f5f0815544432a58bb3f9c316ad6d7294c5520` |
| `nacre/shell-tools/tests/test_login_ui.py` | `7a524e7` | unchanged | `39ba8dacb88bb236979001516f8a9d6de9dfe1ebc268a5176edcaa79db641388` |
| `nacre/shell-tools/tests/login-qml/tst_login.qml` | `7a524e7` | unchanged | `0e9a14f22ad9c9fe1db8a1e9dd7118eb7855795b803c0921b3ebfdcd872ebd16` |
