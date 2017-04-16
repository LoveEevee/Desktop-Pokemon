## Desktop Pokémon
These Pokémon just run around the desktop and wiggle their tails.

## Compiling
1. Install [AutoHotkey](https://autohotkey.com/download/), either v1.1 or v2.0
2. Run `make.ahk` and press `Compile`

## Assets
You can choose a packaged asset by right clicking on the opened window. If you want to set the
asset programmatically, you can use optional executable arguments which can be either a name of
packaged asset (e.g., `fluffyvulpix`) or path to the custom asset. It will also search for PNG files
starting with _eevee.png_, _vulpix.png_, _zorua.png_, _pikachu.png_, _vaporeon.png_, and _noteevee.png_ in the
current directory.

To make initial window bigger or smaller, append `tiny`, `verysmall`, `smaller`, `small`, `normal`,
`big`, `bigger`, or `huge` to the arguments list

Speed can be set with `/speed` followed by `slow`, `normal`, or `fast` after a space.

`/sit` makes the window stay in place.

`/fork` followed by a number 1 through 99 spawns random assets specified number of times. The script
won't allow more than 99 instances even if the command is ran multiple times.

This example uses Command Prompt to load the Pikachu asset with compiled executable:
```
eevee.exe pikachu
```
By default it searches for png files that start with one of the modes, then loads Eevee asset if not
found, second line loads Vulpix asset with a larger window size:
```
eevee.exe
eevee.exe big vulpix
```
Loads Eevee-based, Vulpix-based, and Zorua-based assets from file:
```
eevee.exe "test\eevee_test.png"
eevee.exe "test\vulpix_test.png" /mode vulpix
eevee.exe "test\zorua_test.png" /mode zorua
```
Makes Possessed Eevee very large and slow and FluffyVulpix very small and fast:
```
eevee.exe huge possessedeevee /speed slow
eevee.exe tiny fluffyvulpix /speed fast
```
