[![build_html](https://github.com/CIMR-Algos/SeaIceThickness_ATBD_V2/actions/workflows/build_html.yml/badge.svg)](https://github.com/CIMR-Algos/SeaIceThickness_ATBD_V2/actions/workflows/build_html.yml)

# CIMR L2 Sea Ice Thickness ATBD

This repository holds the ATBD (JupyterBook) v2 for a prototype Level-2 Sea Ice Thickness product for the CIMR mission.

An HTML build of the ATBD is [online](https://cimr-algos.github.io/SeaIceThickness_ATBD_V2/intro.html).

## Building the ATBD

To build the ATBD, you will need to have Python installed on your system. You can install the required Python packages by running:

```bash
# Clone the repository
git clone git@github.com:CIMR-Algos/SeaIceThickness_ATBD_V2.git
cd SeaIceThickness_ATBD_V2
# Create a virtual environment and install the required packages
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
# Install Julia and packages
curl -fsSL https://install.julialang.org | sh -s -- -y

source ${HOME}/.bashrc # assuming you are using bash, starting a new shell would also work

cd book

#set environment variables to use the correct python and julia
export JULIA_CONDAPKG_BACKEND=Null
export JULIA_PYTHONCALL_EXE=../.venv/bin/python

# install julia kernel for jupyter
julia -e "using Pkg; Pkg.add([\"IJulia\",\"Revise\"));Pkg.build(\"IJulia\")"

# install julia packages
julia --project=../sit_atbd_env_jl -e "using Pkg; Pkg.instantiate()"

# Build the ATBD
make all
```

The ATBD will be built in the `_build/html` directory.

> [!IMPORTANT]  
> The environment variable `DEVALGO_INPUT_DATA_PATH` is used to specify the path to the input data. If not set, the `Testscenes.ipynb` notebook will not run and the book will not compile.

## Running the notebooks
For execution as notebooks, the correct path of the python executable must be set using the environment variable `JULIA_PYTHONCALL_EXE`, just like in the build process. It is probably more robust to use a absolute path to the python executable.

## Script for CIMR L1b to L2 SIT processing
... to be added


## Additional information

The ATBD was developed in the context of the ESA-funded CIMR DEVALGO study (2022-2024) (contract 4000137493). More information on the DEVALGO study
and other ATBDs it produced is available from [CIMR-Algos](https://github.com/CIMR-Algos).