Moon Patrol Arcade for the Tang Nano 20K FPGA Dev Board. Pinballwiz.org 2025
Code from MIST 

Notes:
Setup for keyboard controls in Upright Mode (5 = Coin)(Start P1 = 1)(Start P2 = 2)(Up Arrow = Jump)(LCtrl = Fire)(Left Arrow = Slow)(Right Arrow = Fast)
Consult the Schematics Folder for Information regarding peripheral connections.
Consult the Schematics Folder for Information on Tang Nano 20K Internal Clock setup.

Build:
* Obtain correct roms file for Moon Patrol (see scripts in tools folder for rom details).
* Unzip rom files to the tools folder.
* Run the make mpatrol proms script in the tools folder.
* Place the generated prom files inside the proms folder.
* Open the TangNano20K-MoonPatrol project file using GoWin.
* Compile the project updating filepaths to source files as necessary.
* Program Tang Nano 20K Board.
* On Game first boot - Press Reset button on TN20K a few times for Graphics to appear correctly.
