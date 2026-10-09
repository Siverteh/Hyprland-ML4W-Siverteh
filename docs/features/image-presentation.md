# Images and matched presentation

The generic Thumbnailer had no live consumer beyond the optional image helper
and its tests. It is retired. NacreImage/CachingImage now use Qt's native Image:
asynchronous load, native cache, DPI-sized decoding, original-size option and
50ms coalesced path/size requests. Valid replacements retain old pixels while
loading; failed/empty requests clear them and expose a bounded error. Native
file/image/qrc/HTTP URLs retain their schemes. No conversion process, duplicate
thumbnail directory, helper job or download client is introduced.

Maintained wallpaper layouts continue using their existing prepared thumbnail/
preview/poster files and native buffers. This change does not replace, regenerate
or invalidate that cache or alter layouts, search, motion or artwork.

NacrePresentation owns the native presentation.json watch. It validates the
complete role/mode/local-poster record, deep-copies accepted metadata and publishes
one pending/active state. Invalid reads keep the last valid pair. First records
and same-poster palette changes activate as before; a new poster waits until its
actual image reports ready. Only current pending readiness can activate, so an
older decode cannot change the pair. File URLs canonicalize without decoding
literal percent sequences in raw filesystem paths. Saved metadata and private
wallpaper/rotation/mode preferences are unchanged. Read-only presentationState
reports availability/matching/revision/error/mode without private image paths.

ThemePresentation is a small forwarding name; all maintained callers now use
NacrePresentation. Producer/rotation/helper provenance remains separate. See
[the specification](../specs/image-presentation-services.md) and
[the whole-tree tracker](../nacre/PROVENANCE.md). Notices remain until final audit.
