  CREATE OR REPLACE NONEDITIONABLE PACKAGE "PIOTR"."PTF_SLIDING_WINDOW_CALC" IS

    type number_rt IS RECORD(pointer VARCHAR2(100),wartosc NUMBER);
    type bin_float_rt IS RECORD(pointer VARCHAR2(100),wartosc BINARY_FLOAT);    
    type bin_double_rt IS RECORD(pointer VARCHAR2(100),wartosc BINARY_DOUBLE);    
    type number_aat IS TABLE OF number_rt INDEX BY PLS_INTEGER;
    type bin_float_aat IS TABLE OF bin_float_rt INDEX BY PLS_INTEGER;
    type bin_double_aat IS TABLE OF bin_double_rt INDEX BY PLS_INTEGER;
    type table_of_number_nt_t IS TABLE OF DBMS_TF.TAB_NUMBER_T;
    type table_of_bin_float_nt_t IS TABLE OF DBMS_TF.TAB_BINARY_FLOAT_T;
    type table_of_bin_double_nt_t IS TABLE OF DBMS_TF.TAB_BINARY_DOUBLE_T;
    
    FUNCTION describe(  tab IN OUT DBMS_TF.TABLE_T
                        ,calc_cols IN DBMS_TF.COLUMNS_T
                        ,shown_cols IN DBMS_TF.COLUMNS_T DEFAULT NULL
                        , window_size IN NUMBER DEFAULT 1
                        , include_curr_row IN NUMBER DEFAULT 1
                        , additional_value NUMBER DEFAULT NULL
                        , calc_operation IN VARCHAR2 DEFAULT 'SUM') RETURN DBMS_TF.DESCRIBE_T;
    PROCEDURE open(window_size IN NUMBER DEFAULT 1, include_curr_row IN NUMBER DEFAULT 1, additional_value NUMBER DEFAULT NULL, calc_operation IN VARCHAR2 DEFAULT 'SUM');                
    PROCEDURE fetch_rows(window_size IN NUMBER DEFAULT 1, include_curr_row IN NUMBER DEFAULT 1, additional_value NUMBER DEFAULT NULL, calc_operation IN VARCHAR2 DEFAULT 'SUM');
    PROCEDURE close(window_size IN NUMBER DEFAULT 1, include_curr_row IN NUMBER DEFAULT 1, additional_value NUMBER DEFAULT NULL, calc_operation IN VARCHAR2 DEFAULT 'SUM');
END ptf_sliding_window_calc;

/
