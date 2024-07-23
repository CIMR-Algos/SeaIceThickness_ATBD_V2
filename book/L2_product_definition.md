# Level-2 product definition

The Level-2 product is the result of the processing from Level-1b brightness
temperatures to Level-2 ice thickness. The product is provided in the EASE2 grid for the Northern and Southern Hemispheres, [EPSG:6931](https://epsg.io/6931) and [EPSG:6932](https://epsg.io/6932) resampled at 12.5&nbsp;km resolution. The product is provided in
NetCDF format and contains the following variables following the [CF
conventions](http://cfconventions.org/):

(product_variables)=
| variable name | description | unit | dimensions |
| --- | ---- | ---| ---- |
| `sea_ice_thickness` | mean ice thickness in given grid cell as per retrieval | m | 1440 x 1440 |
| `sea_ice_thickness standard_error` | the standard error as described in {ref}`uncertainties` | m | 1440 x 1440 |
| `sea_ice_thickness quality_flag` | product quality flag | 1 | 1440 x 1440 | 


The quality flag is a 16-bit mask with the following bits:
(product_flags)=
| Bit | Description |
| --- | ---- |
| 0 | Validity of the retrieved ice thickness (set for valid) |
| 1 | Land mask (set for land) |
| 2 | Ice shelf mask (set for ice shelf) |
| 3 | Sea ice edge mask (set for sea ice edge) |
| 4 | full sea ice cover mask (set for sea ice concentration > 0.90) |
| 5-16 | Reserved |


The quality flag is an important indicator for users of the product. While for
full ice coverage of a grid cell the retrieval gives the best, i.e., lowest uncertainty sea ice thickness results,
the retrieval is still valid for lower ice concentrations. The sea ice edge mask is set
for grid cells where the retrieval is influenced by the presence of the sea
ice edge. The ice shelf mask is set for grid cells where the retrieval is
not valid due to the presence of an ice shelf. The land mask bit is set for
grid cells where the retrieval is not valid due to the presence of land.
The validity of the retrieved ice thickness is set for grid cells where the
retrieval is valid in general, which is the major indicator for users of
the product.
