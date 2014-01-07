# Makefile
#
# Make file for compiling nRF24LE1 applications using SDCC and nRF24LE1_SDK

# Specify the target device pin package. Options are 24, 32, or 48 
PINS := 24

TARGETNAME := _target_sdcc_nrf24le1_$(PINS)

# Add include directories (outside this folder) that make needs to know about (separated by a space)
# These MUST be the relative path from within this directory to the desired directory (no absolute paths)
export EXTERNINCDIRS = ../nRF24LE1_SDK/$(TARGETNAME)/include ../nRF24LE1_SDK/include
export EXTERNLIBDIRS = ../nRF24LE1_SDK/$(TARGETNAME)/lib

# Functions needed by this makefile and the one that builds the source packages (MakefileSrc)
export ECHO = @echo
export RM = rm
export SED = sed
export MKDIR = mkdir
export TR = tr
export BLACKHOLE = /dev/null
export PWD = pwd
export CD = cd
export LS = ls
PACKIHX = packihx
TAIL = tail

# Programs to use for creating dependencies, compiling source files, and creating the library file, respectively
DEP = sdcc
CC  = sdcc
# Program to use for the linker
LK = sdcc

# Flags for above programs when calling them from the command line
DFLAGS = -MM $(INCDIRS) $<
CFLAGS = --model-large --std-c99 $(INCDIRS) -c $< -o "$(OBJDIR)/"
LFLAGS = --model-large --code-loc 0x0000 --code-size 0x4000 --xram-loc 0x0000 --xram-size 0x400 -o $(MAINIHX) $(LIBDIRS) $(LIBFILES) $(OBJFILES)

# File extensions for dependency files, source files, object files, and library files, respectively
DEPEXT = d
SRCEXT = c
OBJEXT = rel


SRCDIR = src
INCDIR = include
OBJDIR = obj
DEPDIR = dep
FLASHDIR = flash
OBJFILES = $(strip $(shell $(LS) $(OBJDIR)/*.rel))
MAINHEX = $(FLASHDIR)/main.hex
MAINIHX = $(FLASHDIR)/main.ihx

LIBFILES := $(foreach _dir,$(EXTERNLIBDIRS),$(strip $(shell $(LS) $(_dir))))
LIBDIRS := $(foreach _dir,$(EXTERNLIBDIRS),-L $(_dir))

INCDIRS = -I$(INCDIR) $(foreach dir,$(strip $(EXTERNINCDIRS)),-I$(dir))

SRCFILES := $(shell $(LS) $(SRCDIR)/*.$(SRCEXT))
OBJFILES = $(subst .$(SRCEXT),.$(OBJEXT),$(subst $(SRCDIR),$(OBJDIR),$(SRCFILES)))
DEPFILES = $(subst .$(SRCEXT),.$(DEPEXT),$(subst $(SRCDIR),$(DEPDIR),$(SRCFILES)))

-include $(DEPFILES)

all: build link

build: $(OBJFILES)
	$(if $(FILESMODIFIED),$(ECHO)) 

$(OBJDIR)/%.$(OBJEXT) : $(SRCDIR)/%.$(SRCEXT) $(DEPDIR)/%.$(DEPEXT)
	$(ECHO)
	$(ECHO) "Building object file '$@'"
	[ -d $(OBJDIR) ] || $(MKDIR) $(OBJDIR) > $(BLACKHOLE)
	$(CC) $(CFLAGS)
	$(ECHO) "Finished building object file '$@'"
	$(eval FILESMODIFIED = 1)

$(DEPDIR)/%.$(DEPEXT): $(SRCDIR)/%.$(SRCEXT)
	$(ECHO)
	$(ECHO) "Building dependency file '$@'"
	[ -d $(DEPDIR) ] || $(MKDIR) $(DEPDIR) > $(BLACKHOLE)
	$(ECHO) "$(OBJDIR)/" | $(TR) -d '\n' | $(TR) -d '\r' > $@.tmp
	$(DEP) $(DFLAGS) >> $@.tmp
	$(SED) 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.tmp > $@
	$(RM) -f $@.tmp
	$(ECHO) "Finished building dependency file '$@'"
	$(eval FILESMODIFIED = 1)

.SECONDARY: $(OBJFILES) $(DEPFILES)

link:
	$(ECHO)
	$(ECHO) "Linking project"
	$(LK) $(LFLAGS)
	$(ECHO) "Finished linking project!"
	$(ECHO)
	$(ECHO) "Converting hex file"
	$(PACKIHX) $(MAINIHX) > $(MAINHEX)
	$(ECHO) "Finished converting hex file"
	$(ECHO)
	$(ECHO) "Memory statistics:"
	$(TAIL) -n 5 $(FLASHDIR)/main.mem

.PHONY: clean

clean:
	$(if $(OBJDIR),$(RM) -rf $(OBJDIR)/*)
	$(if $(DEPDIR),$(RM) -rf $(DEPDIR)/*)
	$(if $(FLASHDIR),$(RM) -rf $(FLASHDIR)/*)


