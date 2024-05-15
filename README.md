# Sliding window implementation of Polymorphic Table Function
## Usage
This implementation of polymorphic table function allows us to calculate some of standard mathematical functions for any table/view of our choice.
>[!NOTE]
>This version support currently SUM, AVERAGE, MIN, MAX and MEDIAN.

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
- tab is the name of our table/view. We write the name of our table without quote signs.
- calc_cols should contain only the name of columns that we would like to use the function on.

