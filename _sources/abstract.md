# Abstract

Sea Ice is one of the essential climate variables as defined by the World Meteorological Organization and one of its key properties is it's thickness, the Sea Ice Thickness (SIT). While Altimeter products dominate the thick ice regime and slowly changing thicker ice cover, the retrieval of thin sea ice thickness is mainly performed by  thermal imager (e.g. {term}`MODIS` {cite}`Makynen2013`) and passive microwave observations.
Several variants for the retrieval of the thickness of thin sea ice were
proposed for space borne L-band microwave radiometers such as {term}`SMOS` by ESA and
{term}`SMAP` by NASA. The algorithm used here in this {term}`ATBD` is based on the
work of {cite}`Huntemann2014` and {cite}`Patilea2019`. It works originally on {term}`TB`
intensity and polarization difference in the 40-50° incidence angle range. In this {term}`ATBD` the algorithm is
modified to use directly instrument provided {term}`TB`s in horizontal and vertical
polarization, including their uncertainties. Another modification compared to
{cite}`Huntemann2014,Patilea2019` is the removal of a forced upper limit of 50
cm of retrievable ice thickness. Higher ice thicknesses, even though retrieved,
do come with higher uncertainties. With this modification it is more similar to the
ESA {term}`SMOS` algorithm {cite}`Tiankunze2014`, which use SMOS {term}`TB` closer to nadir and thus is not directly applicable to CIMR.. 
The evaluation is done using {term}`SMOS` brightness temperatures against the ESA CCI Round robin
data package {cite}`Pedersen2021` and the ESA {term}`SMOS` product. In addition an evaluation on simulated CIMR test scenes is performed.
