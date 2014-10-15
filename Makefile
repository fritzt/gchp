#------------------------------------------------------------------------------
#          Harvard University Atmospheric Chemistry Modeling Group            !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: Makefile
#
# !DESCRIPTION: 
#\\
#\\
# !REMARKS:
# To build the programs, call "make" with the following syntax:
#                                                                             .
#   make -jN TARGET REQUIRED-FLAGS [ OPTIONAL-FLAGS ]
#                                                                             .
# To display a complete list of options, type "make help".
#                                                                             .
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# %%% NOTE: Normally you will not have to call this Makefile directly,     %%%
# %%% it will be called automatically from the Makefile in the directory   %%%
# %%% just above this one!                                                 %%%
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#                                                                             .
# Makefile uses the following variables:
#                                                                             .
# Variable   Description
# --------   -----------
# SHELL      Specifies the shell for "make" to use (usually SHELL=/bin/sh)
# ROOTDIR    Specifies the root-level directory of the GEOS-Chem code
# HDR        Specifies the directory where GEOS-Chem include files are found
# LIB        Specifies the directory where library files (*.a) are stored
# MOD        Specifies the directory where module files (*.mod) are stored
# AR         Sys var w/ name of library creator program (i.e., "ar", "ranlib")
# MAKE       Sys var w/ name of Make command (i.e, "make" or "gmake")
# R8         Specifies the c
#
# !REVISION HISTORY: 
#  18 Sep 2013 - M. Long     - Initial version
#EOP
#------------------------------------------------------------------------------
#BOC

# Define variables
SHELL   = /bin/sh
ROOTDIR = ..
HDR     = $(ROOTDIR)/Headers
HELP    = $(ROOTDIR)/help
LIB     = $(ROOTDIR)/lib
MOD     = $(ROOTDIR)/mod

# Include header file.  This returns variables CC, F90, FREEFORM, LD, R8,
# as well as the default Makefile compilation rules for source code files.
include $(ROOTDIR)/Makefile_header.mk

# Make sure ESMADIR is defined
# ----------------------------

ifndef BASEDIR
export BASEDIR=../
endif 
ifndef ESMADIR
ESMADIR:=./Shared
endif
ifndef ESMF_DIR
export ESMF_DIR=../ESMF
endif
       RCDIR   :=$(BASEDIR)/Registry/

# Compilation rules, flags, etc
# -----------------------------
ifeq ($(HPC),yes)
  include $(ESMADIR)/Config/ESMA_base.mk  # Generic stuff
  include $(ESMADIR)/Config/ESMA_arch.mk  # System dependencies
else
  include ./Shared/Config/ESMA_base.mk  # Generic stuff
  include ./Shared/Config/ESMA_arch.mk  # System dependencies
endif
# ESMF-specific settings
# ----------------------------
export ESMF_COMPILER=intel
export ESMF_COMM=openmpi
export ESMF_INSTALL_PREFIX=$(ESMF_DIR)/$(ARCH)
export ESMF_INSTALL_LIBDIR=$(ESMF_DIR)/$(ARCH)/lib
export ESMF_INSTALL_MODDIR=$(ESMF_DIR)/$(ARCH)/mod
export ESMF_INSTALL_HEADERDIR=$(ESMF_DIR)/$(ARCH)/include
export ESMF_F90COMPILEOPTS=-align all -fPIC -traceback 
export ESMF_CXXCOMPILEOPTS=-fPIC
export ESMF_OPENMP=OFF

#=============================================================================
# List of files to compile (the order is important!).  We specify these as
# a list of object files (*.o).  For each object file, the "make" utility
# will find the corresponding source code file (*.F) and compile it. 
#=============================================================================

# List of source files
SRC = $(wildcard *.F) $(wildcard *.F90)

# Replace .F and .F90 extensions with *.o
TMP = $(SRC:.F=.o)
OBJ = $(TMP:.F90=.o)

REGDIR    := Registry
ACGS      := GIGCchem_ExportSpec___.h GIGCchem_GetPointer___.h \
             GIGCchem_DeclarePointer___.h GIGCchem_History___.rc
#LIB_ESMF  := $(ESMF_DIR)/$(ARCH)/lib/libesmf.so
#LIB_MAPL  := $(ESMADIR)/$(ARCH)/libMAPL_Base.a # At this point, we only check for MAPL_Base

MAPL    := ./Shared
ESMF    := ./ESMF


#=============================================================================
# Makefile targets: type "make help" for a complete listing!
#=============================================================================

.PHONY: clean help

baselibs:
ifeq ($(wildcard $(ESMF)/esmf.install),)
	$(MAKE) -C $(ESMF)
	$(MAKE) -C $(ESMF) install
	@touch $(ESMF)/esmf.install
else	
endif
ifeq ($(wildcard $(MAPL)/mapl.install),)
	$(MAKE) -C $(MAPL) install
	@touch $(MAPL)/mapl.install
else	
endif

lib: $(ACGS) $(OBJ)
	$(AR) crs libGIGC.a $(OBJ)
	mv libGIGC.a $(LIB)

$(ACGS) : $(REGDIR)/Chem_Registry.rc $(REGDIR)/HEMCO_Registry.rc $(ACG) #$(REGDIR)/Dyn_Registry.rc
	@$(ACG) $(ACG_FLAGS) $(REGDIR)/Chem_Registry.rc
##	@$(ACG) $(ACG_FLAGS) $(REGDIR)/Dyn_Registry.rc
	@$(ACG) $(ACG_FLAGS) $(REGDIR)/HEMCO_Registry.rc

libesmf:
	@$(MAKE) -C $(GIGC) esmf

libmapl:
	@$(MAKE) -C $(GIGC) mapl

clean:
	rm -f *.o *.mod *___.h *___.rc

help:
	@$(MAKE) -C $(HELP)

#=============================================================================
# Dependencies listing (grep "USE " to get the list of module references!)
#
# From this list of dependencies, the "make" utility will figure out the
# correct order of compilation (so we don't have to do that ourselves!)
#=============================================================================

Chem_GridCompMod.o          : Chem_GridCompMod.F90 gigc_mpi_wrap.o                      \
		              gigc_chunk_mod.o gigc_type_mod.o 

#<<MSL>>HEMCO_GridCompMod.o         : HEMCO_GridCompMod.F90 gigc_mpi_wrap.o

GEOSChem.o		    : GEOSChem.F90 GIGC_GridCompMod.o

GEOS_ctmEnvGridComp.o	    : GEOS_ctmEnvGridComp.F90

GIGC_GridCompMod.o          : GIGC_GridCompMod.F90 Chem_GridCompMod.o \
	                      GEOS_ctmEnvGridComp.o

GIGC_Type_Mod.o             : gigc_type_mod.F
#<<MSL>>HEMCO_GridCompMod.o

gigc_initialization_mod.o   : gigc_initialization_mod.F90 gigc_mpi_wrap.o 

gigc_chunk_mod.o            : gigc_chunk_mod.F90 gigc_finalization_mod.o gigc_initialization_mod.o

#EOC
