# Algorithm Performance Assessment

A first {ref}`Validation` is performed as well as a {ref}`Testscenes` 

## L1 E2ES Demonstration Reference Scenario (Picasso) scene definition
We are using three test scenes for the performance evaluation, the two DEVALGO test scenes and the SCEPS polar test scene.

## Algorithm Performance Metrics (MPEF)
For SIT we have two major performance metrics which are based on a reference dataset. These are
* mean difference (bias) 
* standard deviation of the differences

These metrics help in evaluating the accuracy and reliability of the algorithm's outputs compared to the expected results. However, there is currently no dataset which provides the truth of SIT on the scale of the output of the CIMR SIT product. Therefore, both, the reference dataset as well as the CIMR data on which the algorithm is applied are not representing a real scenario but only demonstrate a strategy under the assumption that both datasets would exist.


## Algorithm Calibration Data Set (ACDAT)
The algorithm is tuned with SMOS data and simulated ice thicknesses from 2010 as described in detail in the {ref}`fw-model` Sction.

## Algorithm Validation Data Set (AVDAT)
The CIMR SIT algorithm output is applied to SMOS data and compared to the ESA SMOS SIT dataset, as well as to the RRDP thin ice dataset in {ref}`Validation`. In addition the algorithm is applied to CIMR L1b simulated data from the SCEPS project, namely the polar scene. Here the comparison is done to the corresponding geo reference data provided by the SCEPS project.

## Test Results using Demonstration Reference Scenario
The test results are shown in {ref}`Testscenes` for the DEVALGO testcards 1 and 2 as well as for the SCEPS polar scene.

## Algorithm Performance Assessment using Demonstration Reference Scenario
The performance of the SIT retrieval on the reference data is shown in {ref}`Testscenes`, assesing the overall differences.

## Roadmap for future ATBD development

The possibilities for improvement of the SIT algorithm are can be roughly divided into following categories
1. **Improvement of reference data**: For developing a more sophisticated forward model and include more dimensions a bigger reference dataset could be used (empirical improvements)
2. **Incorporation of SIC as part of SIT estimation** To improve SIT retrieval for the ice edge and other regions with open ocean influence on the brightness temperatures, the SIC could be part of the retrieval.
3. **Transitioning to a full physical forward model**: With best estimates of influence of geophysical variables, with potential of retrieval of more variables (see Multi Parameter Retrieval)
4. **Spatio-Temporal constraints and optimization**: Since the change of ice thickness is limited within a certain time and space, the retrieval could be constrained in a similar way. This is also strongly linked to the ice concentration incorporation and possible constraint on ice volume in a certain area.
5. **Validation and verification of the algorithm**: Continuous assessment of the algorithm's performance against real-world observations and datasets to ensure its reliability and accuracy in various conditions.
6. **Incorporation of more auxillary data sources**: Incorporating more external data, like atmospheric and surface analysis data or data products from other satellites.




