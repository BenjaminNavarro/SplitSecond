#!/bin/bash

(cd Export/HTML5 && zip HTML5.zip index.html index.js index.pck index.png index.wasm)
(cd Export/Windows && zip Windows.zip SplitSecond.pck SplitSecond.exe)
(cd Export/Linux && zip Linux.zip SplitSecond.pck SplitSecond.x86_64)

butler push Export/HTML5/HTML5.zip benjaminnavarro/splitsecond:HTML5
butler push Export/Windows/Windows.zip benjaminnavarro/splitsecond:Windows
butler push Export/macOS/macOS.zip benjaminnavarro/splitsecond:macOS
butler push Export/Linux/Linux.zip benjaminnavarro/splitsecond:Linux
