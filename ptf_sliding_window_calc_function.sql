CREATE OR REPLACE NONEDITIONABLE FUNCTION "PIOTR"."PTF_SLIDING_WINDOW" (
    tab TABLE
    ,calc_cols COLUMNS
    ,shown_cols COLUMNS DEFAULT NULL
    ,window_size NUMBER DEFAULT 1
    ,include_curr_row IN NUMBER DEFAULT 1  
    , additional_value NUMBER DEFAULT NULL
    ,calc_operation IN VARCHAR2 DEFAULT 'SUM') RETURN TABLE
    PIPELINED TABLE POLYMORPHIC USING ptf_sliding_window_calc;

/
