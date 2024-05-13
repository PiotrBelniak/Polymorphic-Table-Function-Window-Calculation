CREATE OR REPLACE NONEDITIONABLE PACKAGE "PIOTR"."PTF_SLIDING_WINDOWS_SUPPORT_PACK" 
IS
    function sql_text_operation_setup(sql_string VARCHAR2,operacja VARCHAR2, with_curr_row NUMBER) RETURN VARCHAR2;
    function sql_text_datatype_setup(sql_string VARCHAR2,typ_zmiennej PLS_INTEGER) RETURN VARCHAR2;
END;

/
