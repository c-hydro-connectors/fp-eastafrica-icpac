# fp-eastafrica-icpac
For installing the system start with the file in the "setup" folder. 
The installation path is pecified in the bash files, in the LIBS_PATH variable.

In the detail, the file should be installed in the following order:
- setup_libs_system_hmc.sh will install the basic libraries for Continuum (hdf, nc, zlib)
- setup_libs_system_cdo.sh will install cdo and the required libraries
- setup_libs_conda_fp-base.sh will install miniconda and a basic floodproofs python environment
