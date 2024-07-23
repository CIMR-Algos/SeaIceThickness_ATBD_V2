# Introduction, purpose and scope

This is a ATBD for a {term}`SIT` retrieval algorithm for {term}`CIMR`. The method
described here is planned to use CIMR L1b brightness temperatures and
corresponding output will be L2, i.e. gridded sea ice thickness values in
EASE2 coordinates. For the retrieval only L-band brightness temperatures will be used in H and V polarization. Required information for the
retrieval include the {term}`TB` and corresponding uncertainties. The
algorithm is based on the work of {cite}`Huntemann2014` and {cite}`Patilea2019` works originally on
intensity and polarization difference. In this ATBD the algorithm is modified
to use directly instrument provided horizontal and vertical {term}`TB` polarization,
including their uncertainties. 

This document is describing the algorithm and processing steps and the
processing of the L2 {term}`SIT` product. The document is intended for the
{term}`CIMR` users and parties interested in the details of the algorithm. It
is not intended to replace a product user guide. The algorithm is demonstrated in Jupyter notebooks where the code cells are not displayed in this book variant. The main algorithm and supporting routines will
be separated from the notebooks in the `algorithm` directory of this repository.






