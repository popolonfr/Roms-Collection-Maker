# Welcome and thank you for your interest.

This tool for Windows is used to facilitate the creation of ROM compilations for the [**Flash ROM SCC cartridge**](https://www.msx.org/wiki/Popolon-fr_Flash-ROM_SCC_Cartridge) with a simple menu to run them. It consists of a set of [**BATCH**](https://en.wikipedia.org/wiki/Batch_file) scripts and the [**Zasm**](https://k1.spdns.de/Develop/Projects/zasm/Distributions/) compiler which is integrated into the project.

## To start

Download the [**"Roms-Collection-Maker"**](https://github.com/popolonfr/Roms-Collection-Maker/archive/refs/heads/main.zip) directory from Github and copy to the chosen location on your hard drive.

## Copy files and directories

Copy the ROMs (**".ROM"**) to the **".\Roms-Collection-Maker\Roms\"** directory. The total must not exceed 16384KB. Roms and MegaRoms that are not compatible will need to be converted with the corresponding [**IPS patch**](https://www.msx.org/wiki/How_to_use_IPS_files)  found (if it exists) in the **".\Patches\"** directory. Each patch has an associated text file containing information such as the checksum and the real name of the ROM that can be patched. When generating the ROM list, patches will be searched for and automatically applied to the corresponding ROM.

## Create and edit ROM list

Run **".\1- Build the List.bat"**. This action will create the list of ROMs and save it in the **".\Build\EditThisList.asm"** file. Edit the list and change the filenames that are in quotes in the third column to how you want them to appear in the menu without changing the number of characters which should remain at 40 for each name. 

The first and second columns indicate the number of the first memory page where the ROM is stored. These page numbers are automatically calculated when generating the ROM list. In the third column specify the generation of MSX from which the ROM is compatible. 0 for MSX1, 1 for MSX2, 2 for MSX2+, 3 for Turbo-R. By indicating 1 (ROM MSX2), the name of the ROM will not be displayed in the list on the MSX1 computers. For a correct display, it is necessary to indicate the last ROM of each generation by adding 128 to its value. Add 32 to make the ROM run with a BIOS reset.

## Create the final ROM

Run **"2- Build the Rom.bat"** to create the final ROM **".\Build\LoadThis.rom"**. to load it on the SCC Cartridge Flash-ROM, use [**FL.COM**](https://github.com/gdx-msx/FL/tree/master/FL-V133) from version 1.33.

At this step if **".\Build\EditThisList.asm"** does not exist it will be created automatically before finalizing the ROM. Subsequently, it will always be possible to modify the list and start this step again.

## Note

ROMs such as King Valley 2, Metal Gear 2, Pennant 2 use floppy disks for backups. If when running the ROM the message [**"No enough memory"**](https://www.msx.org/wiki/No_enough_memory) occurs, it is probably that an additional disk or card reader (Sunrise, Carnivor or others) is present. Disable it and run the ROM again.

Currently, the tool is not digitally signed, so Windows will prevent it from running and display a warning message with two choices: "deny" or "more details." Choose "more details" if you want to run it anyway, and make sure you only download the tool from Github.com.

&copy; 2025 popolon-fr

