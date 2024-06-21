# DBZK_Fix

## About:
A mod that aims to remove the game's 60FPS cap during gameplay, adding 21:9/16:10/4:3 support, a toggle to disable motion blur, and TAA tweaks that are useful for upscaling, without the need to modify any extra configuration files.

## Known Issues:
- The game is still running with a Vert- FOV. I still need to find reliable hooks for the LocalPlayer (Required to change the game to Hor+ scaling), and then some hooks for adjusting the FOV during gameplay, as early versions of Unreal Engine 4 don't automatically calculate the correct field of view. The FOV issue doesn't matter as much with 21:9 (I was able to play the game from start to finish), and it's a non-issue with 16:10 or 4:3 (Where the top and bottom expands to a similar viewing space to 16:9).

- Certain UI elements (The Game Over screen), The options menu categories, the level up UI element, and the UI targeting portion are all still using incorrect widget anchors. These need to be fixed to be the center of the screen rather than to the upper left (Which is the default anchoring position in Unreal, this tends to be a problem with games that use hardcoded UI coordinates). Likewise, two montage portions later on in the game with still images are anchored to the left side of the screen.

- Some cutscenes are stretched, for some reason. Unsure if this can be changed, but if they are contained within a UMG widget, it should be possible.

There's probably a few more things that I'm glossing over, but within the source files, it should contain some notes.

## Setup:
Extract the contents of the downloaded .ZIP file in the releases section into the **"\AT\Binaries\Win64\"** directory of where the game is installed.

*Note: If you don't have any other Steam library locations set up, this will likely be **"C:\Program Files (x86)\Steam\SteamApps\Common\DRAGON BALL Z KAKAROT"**.*

For Proton and Steam Deck Users: No further setup is necessary.

## System Requirements:
* A *Legitimate* fully updated copy of the game from Steam *(Due to the difference in memory offsets that can result with cracked/pirated versions, the fact that these versions are likely outdated builds, and the fact that I vehemently discourage piracy when there are convenient and accessible options available to support the developers, **I refuse** to provide technical support for these versions. That includes anyone without a mouse cursor icon next to their name on the Steam Discussion Boards).*<br />
[***The game is available for purchase on Steam.***](https://store.steampowered.com/app/851850)

* Windows 10, Windows 11, or Proton Experimental (On Linux and the Steam Deck). **64-Bit operating system is required.**

## Download (For novices):
[Latest version can be downloaded here.](https://github.com/KingKrouch/DBZK_Fix/releases).

Download includes a Proton friendly version of [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS).

## Special Thanks:
- [Nic](https://github.com/NicNamed) for helping out figure out how to coax UE4SS to work with the game, and for helping to find hooks for functions. This new release wouldn't come out remotely as swiftly (understatement of the century) if not for them. Their assistance also helped me to push towards playing the game to it's finish (Minus the DLC content which I have to get to).

- The kind folks over at the UE4SS Discord, alongside the documentation for UE4SS. Links to those will be in their GitHub repository linked here.

## Support The Project:

☕ If you've enjoyed or gotten usage from my work *(keep in mind, I do a majority of this completely for free on my spare time with no donations or compensation)*, please consider supporting my Ko-Fi below:
<br><br>[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/kingkrouch)
Also, if you can, please spare a bit to support [Nic](https://github.com/NicNamed)'s Ko-Fi below:
<br><br>[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/nic_named)

## Licensing:

- [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) is licensed under the MIT License.
- [inifile](https://github.com/bartbes/inifile/) is licensed under the Simplified BSD License.

**DBZK_Fix (C) 2024 Bryce Q.**

**Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:**

**The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.**

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.**

**[See the MIT License for more details.](https://github.com/KingKrouch/DBZK_Fix/blob/main/LICENSE)**