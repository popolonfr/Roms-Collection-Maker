## Description

This tool for Windows is used to facilitate the creation of ROM compilations for the [Flash ROM SCC cartridge](https://www.msx.org/wiki/Popolon-fr_Flash-ROM_SCC_Cartridge) with a simple menu to run them. It consists of a set of BATCH scripts and external executables.

## Download the files

Download the [Zasm](https://k1.spdns.de/Develop/Projects/zasm/Distributions/) archive for Windows, unzip it into a directory then add the path to this directory in the Windows [PATH](https://www.wikihow.com/Change-the-PATH-Environment-Variable-on-Windows) variable.

Download the [Roms Collection Maker](https://github.com/popolonfr/Roms-Collection-Maker/archive/refs/heads/main.zip) directory from Github and copy to the chosen location on your hard drive.

## Copy files

Copy the ROMs (".ROM") to the ".\Roms-Collection-Maker\Roms\" directory. The total must not exceed 2032KB. Roms and MegaRoms that are not compatible will need to be converted with the corresponding [IPS patch](https://www.msx.org/wiki/How_to_use_IPS_files)  found (if it exists) in the **".\Patches\"** directory.


## Create and edit ROMs list

Run **".\1- Build the List.bat"**. This action will create the list of ROMs and save it in the **".\Build\EditThisList.asm"** file. Edit the list and change the filenames that are in quotes in the third column to how you want them to appear in the menu without changing the number of characters which should remain at 40 for each name. 

In the second column specify the generation of MSX from which the ROM is compatible. 0 for MSX1, 1 for MSX2, 2 for MSX2+, 3 for Turbo-R. By indicating 1 (ROM MSX2), the name of the ROM will not be displayed in the list on the MSX1 computers. For a correct display, it is necessary to indicate the last ROM of each generation by adding 128 to its value. Add 64 to indicate that the ROM is using reflections of its memory.

## Create the final ROM

Run "2- Build the Rom.bat" to create the final ROM **".\Build\LoadThis.rom"**. to load it on the SCC Cartridge Flash-ROM, use [FL.COM](https://github.com/gdx-msx/FL/tree/master/FL-V133) from version 1.33.

## Note

ROMs such as King Valley 2, Metal Gear 2, Pennant 2 use floppy disks for backups. If when running the ROM the message "No enough memory" occurs, it is probably that an additional disk or card reader (Sunrise, Carnivor or others) is present. Disconnect it and run the ROM again.


&copy; 2023 popolon-fr
