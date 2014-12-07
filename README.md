nRF24LE1_Example
================

This is an example application for the [nRF24LE1](http://www.nordicsemi.com/eng/Products/2.4GHz-RF/nRF24LE1) using [SDCC](http://sdcc.sourceforge.net/) and the [nRF24LE1_SDK](https://github.com/DeanCording/nRF24LE1_SDK).

Download the zip file of the repository and unpack it in your working directory.  Source code is located in the _src_ directory.  Header files can be placed in the _include_ directory.

The nRF24LE1 comes in three different packages - 24, 32, and 48 pins.  In the Makefile, you will need to specify which package type you are compiling for.

It is assumed that the nRF24LE1_SDK directory is in the same working directory as your application.  If not, you will need to edit the Makefile to change the _EXTERNINCDIRS_ and _EXTERNLIBDIRS_ to point to the correct location.

To build your application, type 'make all'.  The compiled hex file will be located in the _flash_ directory.

Applications can be loaded onto the nRF24LE1 using the Arduino based [programmer](https://github.com/DeanCording/nRF24LE1_Programmer) by typing 'make upload'.