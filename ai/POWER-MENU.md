# Power menu repair

The power menu uses 24% of the focused monitor's logical height as its top and
bottom margin. A 1800-pixel screen at scale 1.5 therefore uses 288-pixel margins.
Run `python3 -m unittest discover -s ai/tests -p test_wlogout.py -v`. Desktop
verification opens the existing Super-X menu and dismisses it with Escape;
verification must not invoke any logout or power action.

Restore the previous menu script from the dated deployment backup to roll back
this repair, preserving all other dotfile changes.
