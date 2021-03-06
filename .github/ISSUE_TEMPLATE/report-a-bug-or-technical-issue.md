---
name: Report a bug or technical issue
about: This template allows users to report GCHP bugs and technical issues
title: "[BUG/ISSUE]"
labels: ''
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Compilation commands
2. Run commands

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Required information**
 - GEOS-Chem/GCHP version you are using [e.g. 12.3.2]
 - Compiler version that you are using [e.g. gfortran 8.2.0, ifort 17.0.4] 
 - MPI library and version [e.g. openmpi-3.1.1] 
 - netCDF and netCDF-Fortran library version
 - Computational environment [e.g. a cluster, or the AWS cloud]
 - The Amazon Machine Image (AMI) ID that you used (if you ran on the AWS cloud)
 - Are you using "out of the box" code, or have you made modifications?

**Input and log files to attach**
For more info, see: http://wiki.geos-chem.org/Submitting_GEOS-Chem_support_requests
 - The GCHP environment file [i.e. gchp.env]
 - The lastbuild file
 - The run configuration file [i.e. runConfig.log]
 - The GCHP compilation log file [i.e. compile.log]
 - The CAP restart file [i.e. cap_restart]
 - The input.geos file
 - The HEMCO_Config.rc file
 - The GCHP log file
 - The HEMCO.log file
 - Error output from your scheduler, if applicable [e.g. slurm*.out]
 - Any other error messages

**Additional context**
Add any other context about the problem here.
