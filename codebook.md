# Variable Definitions

The following variables may be found among data in the [Final Tables](https://github.com/jamisoncrawford/expo/tree/master/Final%20Tables) folder of the `expo` repository.

* `project`: Name of the construction project, i.e. "Expo Center", for the record
    - Added externally, not scraped; uniform with other projects' data
* `name`: Name of the costruction company, e.g. "Pompey Construction", for the record
    - Companies have been abbreviated (e.g. "LLC", "Inc." are removed)
    - Original company `name` is available in `expo_tidy_raw.csv`
* `month`: Reporting month indicated per payment record, e.g. "May"
    - Variable may be deprecated in future, as year is not explicitly indicated
* `ending`: Processing date indicated per payment record, "YYYY-MM-DD" format
    - Most values are converted from Excel 5-digit date classes using package `zoo`
    - Some values were coerced to `Date` class from "M DD, YYYY" format
* `sex`: The gender of the aggregate payment record
* `race`: The race or ethnicity of the aggregate payment record
* `category`: The class of worker, abbreviated and simplified from original values
* `title`: Aggregate worker occupation per SOC (Standard Occupational Classification) system
* `soc`: Aggregate worker occupation SOC code
* `employees`: Total unique employees in aggregate for working period, `sex`, and `race`
* `hours`: Total hours worked in aggregate by employees per period, `sex`, and `race`
* `wages`: Total qages earned in aggregate by employee per period, `sex`, and `race`
