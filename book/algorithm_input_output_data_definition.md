# Algorithm Input and Output Data Definition (IODD)

The processing starts from a recent SIC
map (in swath projection). Land-mask information should be contained in the SIC
map. Land is removed before processing and while a flag for ice-free ocean can
be used, those pixels would be retrieved as 0&nbsp;cm in any case. The input for the
ice thickness consists of $T_{b,h}$ and $T_{b,v}$ at 1.4 GHz and their
uncertainties (currently NeΔT) which are assumed Gaussian noise in this retrieval. The
corresponding output is thickness of thin sea ice.




## Input data

| Field | Description | Shape/Amount |
| ---   | ----------- | ------------ |
| L1B TB | L1B Brightness Temperature at L-band (both H and V polarization) | full swath or section of it (Nscans, Npos) |
| L1B NeΔT | Random radiometric uncertainty of the channels | full swath or section of it (Nscans, Npos) |
| sea-ice and land mask | A recent sea-ice concentration field including land information | SIC and land-mask collocated to swath. |

## Output data
The ouput is in EAES2 grid of the Northern and Southern Hemispheres at 12.5&nbsp;km.

| Field | Description | Shape/Amount |
| ----- | ----------- | ------------ |
| L2 SIT | Sea Ice Thickness | 1440x1440 |
| SIT uncertainty (4 fields) | Retrieval uncertainties: the total uncertainty as well as the 3 contributions separately. | 1440x1440 |
| Status Flag | A flag indicating status of retrieval, e.g. “nominal”, “over land”, “ice-free”, “50+cm” | 1440x1440 |

Note: over land areas, only the status flags will have a valid value, all the others will have “NaN” (_FillValue). Over ice-free ocean, the SIT will be 0 cm.


## Auxiliary data

Auxiliary data are used to improve the retrieval. They are not mandatory, but the retrieval will be
less accurate without them. This includes the masks for filling shelf and land areas. While Land areas are assumed
fixed, shelf ice is changing over time, in particular pronounced in the Antarctic. The shelf ice
mask is used to exclude shelf ice from the retrieval. The land mask is used to exclude land areas
from the retrieval. The CIMR sea ice concentration product may be used for masking.

