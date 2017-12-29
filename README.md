# STAR-Extract-Quartiles
Ruby script for calculating annual quartiles from Renaissance STAR Test historical extracts.

# Instructions
* Download the script
* Edit the various paths on lines 4,5,7, 122, and 123
* Prepare your STAR extract:
    * Insert a column next to the AssessmentDate and call it SchoolYear. Use this formula to calculate a school year based on the date (in my case, I only cared about the last 4 years):
    ````
    =IF(W2>DATEVALUE("8/1/17"),"2017-2018",IF(W2>DATEVALUE("8/1/16"),"2016-2017",IF(W2>DATEVALUE("8/1/15"),"2015-2016",IF(W2>DATEVALUE("8/1/14"),"2014-2015","<2014"))))
    ````
    * Delete all columns except SchoolName, SchoolYear, Grade, PercentileRank, WindowName, ScreeningCategoryGroupAdjustment. For me, this sped up the CSV.read runtime from 55 seconds to 8 seconds.
* Run the script with the command ruby quickquartiles.rb
