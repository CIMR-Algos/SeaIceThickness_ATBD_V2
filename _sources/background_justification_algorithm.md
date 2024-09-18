# Background and justification of selected algorithm


Over the course of the different L-band radiometers such as {term}`SMOS` and
{term}`SMAP`, several algorithms were proposed and implemented for the
retrieval of the {term}`SIT`.  {cite}`Tiankunze2014` presented an algorithm
which is used today in the ESA {term}`SMOS` official {term}`SIT` product. While
it is based on a combination of physical models, it provides similar {term}`SIT`
values to the empirical formulation from {cite}`Huntemann2014`, although,
extending the range of retrievable {term}`SIT` values up to 1&nbsp;m of ice thickness
for growing sea ice in freeze-up conditions.
The algorithm from {cite}`Tiankunze2014` uses {term}`SMOS` incidence angles
close to nadir and thus no polarization information. While the algorithm from
{cite}`Huntemann2014` uses SMOS incidence angles observations at incidence angles from 40° to 50°, which makes it suitable for an adaption to {term}`CIMR` with an incidence angle of 52° at L-band.

This algorithm used for CIMR {term}`SIT` retrieval is using the empirical variant of {cite}`Huntemann2014` and {cite}`Patilea2019`, but also extended to higher ice
thicknesses at increased uncertainty. Technically this is achieved by
considering a certain background ice thickness with a very low weight. Once the
sensitivity of brightness temperatures to thickness decreases in the thick ice
case, the relative weight on the background value is increasing. This is done to avoid the
retrieval of unrealistically high ice thicknesses without artificially
constraining at a fixed boundary of 50&nbsp;cm like in {cite}`Huntemann2014` and
{cite}`Patilea2019`. Another difference to the original formulation is the use of 
horizontal and vertical polarization instead of intensity and polarization
difference. The motivation is that the horizontal and vertical
polarization are directly obtained from the instrument without transformation.
For illustration, the intensity and polarization difference are still serving as
comparisons for the $T_{b,v}$ and $T_{b,h}$ based retrieval. The entire algorithm is
described in detail in {ref}`retrievalalgorithm`.


