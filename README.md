# Sliding window implementation of Polymorphic Table Function
## Usage
This implementation of polymorphic table function allows us to calculate some of standard mathematical functions for any table/view of our choice.
>[!NOTE]
>This version supports currently SUM, AVERAGE, MIN, MAX and MEDIAN.

## Requirements
For this function to correctly work, two packages called PTF_SLIDING_WINDOWS_SUPPORT_PACK and PTF_SLIDING_WINDOW_CALC needs to be compiled in the same schema as our function.  
The DDL for our function is under this location [link](https://github.com/PiotrBelniak/Polymorphic-Table-Function-Window-Calculation/blob/main/ptf_sliding_window_calc_function.sql) 

## How to use function
The syntax is as follows
```bash
ptf_sliding_window(
    tab TABLE
    ,calc_cols COLUMNS
    ,shown_cols COLUMNS DEFAULT NULL
    ,window_size NUMBER DEFAULT 1
    ,include_curr_row IN NUMBER DEFAULT 1  
    , additional_value NUMBER DEFAULT NULL
    ,calc_operation IN VARCHAR2 DEFAULT 'SUM')
```
where:  
- tab is the name of our table/view. We write the name of our table without quote signs.   If necessary, PARTITION BY clause can be included specifying appropriate columns(they do not have be included in either calc_cols or shown_cols).
- calc_cols should contain only the name of columns that we would like to use the function on. We need to use pseudo-operator COLUMNS specifying list of columns. The column can be of number, binary float or binary double datatype.
- shown_cols should contain only the name of columns that we would like to receive from our function untouched. We need to use pseudo-operator COLUMNS specifying list of columns.
- window_size allows us to specify, how many preceding rows should be taken into account while calculating our analytic function.
- include_curr_row specifies, whether current row should be part of the window. If yes, then window size specified in previous parameter is increased by one. Only valid values for this parameter are 0 or 1.
- additional_value is parameter utilized for percentile function allowing us to specify, what percentile we want computed. Allowed values are from 1 to 100.  
    >In this version Percentile is not supported; therefore this parameter should be left NULL.
- calc_operation specifies, what calculation we would like to perform. Current options are SUM, AVERAGE, MIN, MAX and MEDIAN.

## Example of usage
In this example we are calculating averages for sums and quantities of sold products within each country for each month(data is randomized). Our window is 12 preceding rows without current row and we utilize both partition by and order by clauses.  
For comparison the built-in versions of sliding window average function is used.   Below is the snippet of SQL query code along with some of result.
![obraz](https://github.com/PiotrBelniak/Polymorphic-Table-Function-Window-Calculation/assets/169681378/a1224333-9afd-4648-873a-a4d557de8fdf)

## How it works
Details on the algorithm are in the separate documentation. Please see link:
