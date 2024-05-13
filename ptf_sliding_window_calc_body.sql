CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "PIOTR"."PTF_SLIDING_WINDOW_CALC" 
IS
    temp_result_number_nt table_of_number_nt_t;
    temp_result_bin_float_nt table_of_bin_float_nt_t;
    temp_result_bin_double_nt table_of_bin_double_nt_t;
    mapping_tables_1 table_of_number_nt_t;
    mapping_tables_2 table_of_number_nt_t;
    auxiliary_number_storage table_of_number_nt_t;
    auxiliary_bin_float_storage table_of_bin_float_nt_t;
    auxiliary_bin_double_storage table_of_bin_double_nt_t;    
    
    dyn_sql_string_template CONSTANT VARCHAR2(32767):='DECLARE result_set_coll placeholder_type; ' ||
                                                ' intermediate_rst placeholder_type:= :rst; ' ||
                                                ' auxiliary_storage placeholder_type:= :aux_store; ' ||
                                                ' ostatni_wiersz NUMBER:= :lrow; ' ||
                                                ' wielkosc_okna NUMBER:= :window_size; ' ||
                                                ' curr_row_modifier NUMBER:= :modifier; ' ||
                                                ' placeholder_variables ' ||
                                                ' BEGIN ' ||
                                                ' FOR rid IN 1..:rct LOOP ' || 
                                                ' placeholder_operations1 ' ||
                                                ' IF ostatni_wiersz+rid<=wielkosc_okna+1-curr_row_modifier THEN mechanism_for_incomplete_window ' ||
                                                ' ELSE mechanism_for_full_window' ||
                                                ' END IF; ' ||
                                                ' placeholder_operations2 ' ||
                                                ' END LOOP; ' ||
                                                ' :result_coll:=result_set_coll; ' || 
                                                ' :aux_store:=auxiliary_storage; ' || 
                                                ' END; ' ;
  
    FUNCTION describe(  tab IN OUT DBMS_TF.TABLE_T
                        ,calc_cols IN DBMS_TF.COLUMNS_T
                        ,shown_cols IN DBMS_TF.COLUMNS_T DEFAULT NULL
                        , window_size IN NUMBER DEFAULT 1
                        , include_curr_row IN NUMBER DEFAULT 1
                        , additional_value NUMBER DEFAULT NULL
                        , calc_operation IN VARCHAR2 DEFAULT 'SUM') RETURN DBMS_TF.DESCRIBE_T AS
        col_indeks PLS_INTEGER:=1;
        not_existent_column EXCEPTION;
        incorrect_calc_col EXCEPTION;
        incorrect_operation EXCEPTION;
        existence_indicator BOOLEAN;  
        new_cols DBMS_TF.COLUMNS_NEW_T;
        new_cols_ind PLS_INTEGER:=1;
        cstore_num_t DBMS_TF.CSTORE_NUM_T;
    BEGIN
        IF UPPER(calc_operation) NOT IN ('SUM','AVERAGE','MAX','MEDIAN','MIN'/*,'PERCENTILE'*/) THEN
            RAISE incorrect_operation;
        ELSIF UPPER(calc_operation) = 'PERCENTILE' AND additional_value IS NULL THEN
            RAISE incorrect_operation;
        END IF;

        FOR a IN 1..tab.column.count() LOOP
            tab.column(a).PASS_THROUGH:=FALSE;
            tab.column(a).FOR_READ:=FALSE;
        END LOOP;

        FOR b IN 1 .. shown_cols.count() LOOP
            LOOP
                IF NOT tab.column(col_indeks).PASS_THROUGH THEN
                    tab.column(col_indeks).PASS_THROUGH := tab.column(col_indeks).DESCRIPTION.NAME = shown_cols(b);
                    existence_indicator:=tab.column(col_indeks).PASS_THROUGH;
                END IF;
                EXIT WHEN existence_indicator OR col_indeks=tab.column.count();
                col_indeks:=col_indeks+1;
            END LOOP;
            IF NOT existence_indicator THEN
                RAISE not_existent_column;
            END IF;
            col_indeks:=1;
            existence_indicator:=FALSE;
        END LOOP;

        FOR c IN 1 .. calc_cols.count() LOOP
            LOOP
                IF NOT tab.column(col_indeks).FOR_READ THEN
                    tab.column(col_indeks).FOR_READ := tab.column(col_indeks).DESCRIPTION.NAME = calc_cols(c);
                    existence_indicator:=tab.column(col_indeks).FOR_READ;
                END IF;
                EXIT WHEN existence_indicator OR col_indeks=tab.column.count();
                col_indeks:=col_indeks+1;
            END LOOP;
            IF NOT existence_indicator THEN
                RAISE not_existent_column;
            END IF;
            col_indeks:=1;
            existence_indicator:=FALSE;
        END LOOP;   

        FOR d IN 1..tab.column.count() LOOP
            IF tab.column(d).FOR_READ AND tab.column(d).description.type IN (DBMS_TF.TYPE_BINARY_DOUBLE,DBMS_TF.TYPE_BINARY_FLOAT,DBMS_TF.TYPE_NUMBER) THEN
                cstore_num_t(DBMS_TF.COLUMN_TYPE_NAME(tab.column(d).description)):=new_cols_ind;
                new_cols(new_cols_ind):= tab.column(d).description;
                new_cols(new_cols_ind).name:= REPLACE(tab.column(d).description.name,'"') || '_calced';
                new_cols_ind:=new_cols_ind+1;
            ELSIF tab.column(d).FOR_READ AND tab.column(d).description.type NOT IN (DBMS_TF.TYPE_BINARY_DOUBLE,DBMS_TF.TYPE_BINARY_FLOAT,DBMS_TF.TYPE_NUMBER) THEN
                RAISE incorrect_calc_col;
            END IF;
        END LOOP;

        cstore_num_t('col_count'):=new_cols.COUNT;
        RETURN DBMS_TF.describe_t(new_columns => new_cols, CSTORE_NUM => cstore_num_t);
    EXCEPTION
        WHEN not_existent_column THEN
            RAISE_APPLICATION_ERROR(-20100,'One of columns provided is not valid column name.');
        WHEN incorrect_calc_col THEN
            RAISE_APPLICATION_ERROR(-20101,'One of calculated columns is not of number type.');
        WHEN incorrect_operation THEN
            RAISE_APPLICATION_ERROR(-20103,'Operation is either not existent or not supported.');
    END;
    
    PROCEDURE open(window_size IN NUMBER DEFAULT 1, include_curr_row IN NUMBER DEFAULT 1, additional_value NUMBER DEFAULT NULL, calc_operation IN VARCHAR2 DEFAULT 'SUM')
    IS
        col_count NUMBER;
    BEGIN
        IF DBMS_TF.CSTORE_EXISTS('BINARY_DOUBLE') THEN
            DBMS_TF.CSTORE_GET('BINARY_DOUBLE',col_count);
            auxiliary_bin_double_storage:=table_of_bin_double_nt_t();
            auxiliary_bin_double_storage.EXTEND(col_count);
            temp_result_bin_double_nt:=table_of_bin_double_nt_t();
            temp_result_bin_double_nt.EXTEND(col_count);   
        END IF;
        
        IF DBMS_TF.CSTORE_EXISTS('BINARY_FLOAT') THEN
            DBMS_TF.CSTORE_GET('BINARY_FLOAT',col_count);
            auxiliary_bin_float_storage:=table_of_bin_float_nt_t();
            auxiliary_bin_float_storage.EXTEND(col_count);
            temp_result_bin_float_nt:=table_of_bin_float_nt_t();
            temp_result_bin_float_nt.EXTEND(col_count);   
        END IF;
        
        IF DBMS_TF.CSTORE_EXISTS('NUMBER') THEN
            DBMS_TF.CSTORE_GET('NUMBER',col_count);
            auxiliary_number_storage:=table_of_number_nt_t();
            auxiliary_number_storage.EXTEND(col_count);
            temp_result_number_nt:=table_of_number_nt_t();
            temp_result_number_nt.EXTEND(col_count); 
        END IF;
        
        IF calc_operation NOT IN ('SUM','AVERAGE') THEN
            DBMS_TF.CSTORE_GET('col_count',col_count);
            mapping_tables_1:=table_of_number_nt_t();
            mapping_tables_2:=table_of_number_nt_t();
            mapping_tables_1.EXTEND(col_count);   
            mapping_tables_2.EXTEND(col_count);   
        END IF;
        
        DBMS_TF.XSTORE_SET('ostatni_wiersz',0);
    END;

    PROCEDURE fetch_rows(window_size IN NUMBER DEFAULT 1, include_curr_row IN NUMBER DEFAULT 1, additional_value NUMBER DEFAULT NULL, calc_operation IN VARCHAR2 DEFAULT 'SUM') AS
        rst DBMS_TF.ROW_SET_T;
        col_num DBMS_TF.TAB_NUMBER_T;
        col_bin_float DBMS_TF.TAB_BINARY_FLOAT_T;
        col_bin_double DBMS_TF.TAB_BINARY_DOUBLE_T;
        rct PLS_INTEGER;
        cct PLS_INTEGER;
        lrow NUMBER;
        dyn_sql_string VARCHAR2(32767);
        curr_row_modifier NUMBER;
    BEGIN
        IF include_curr_row=1 THEN
            curr_row_modifier:=0;
        ELSE
            curr_row_modifier:=1;
        END IF;
        
        DBMS_TF.GET_ROW_SET(rst, row_count => rct, col_count => cct);    
        DBMS_TF.XSTORE_GET('ostatni_wiersz',lrow);
        DBMS_TF.XSTORE_SET('ostatni_wiersz',lrow+rct);

        FOR cid IN 1..cct LOOP
            dyn_sql_string:=ptf_sliding_windows_support_pack.sql_text_operation_setup(sql_string => dyn_sql_string_template,operacja => calc_operation, with_curr_row=>curr_row_modifier);
            CASE rst(cid).description.type
                WHEN DBMS_TF.TYPE_BINARY_DOUBLE THEN
                
                    col_bin_double.DELETE;
                    dyn_sql_string:=ptf_sliding_windows_support_pack.sql_text_datatype_setup(sql_string => dyn_sql_string,typ_zmiennej=>DBMS_TF.TYPE_BINARY_DOUBLE);
                    
                    IF calc_operation IN ('SUM','AVERAGE') THEN
                        temp_result_bin_double_nt(cid)(1):=CASE WHEN temp_result_bin_double_nt(cid).EXISTS(1) THEN temp_result_bin_double_nt(cid)(1) ELSE TO_BINARY_DOUBLE(0) END;            
                        EXECUTE IMMEDIATE dyn_sql_string 
                            USING   IN rst(cid).TAB_BINARY_DOUBLE,IN OUT auxiliary_bin_double_storage(cid)
                                    ,IN lrow,IN window_size,IN curr_row_modifier,IN OUT temp_result_bin_double_nt(cid)(1), IN rct, OUT col_bin_double;
                    ELSE
                        EXECUTE IMMEDIATE dyn_sql_string 
                            USING   IN rst(cid).TAB_BINARY_DOUBLE,IN OUT auxiliary_bin_double_storage(cid)
                                    ,IN lrow,IN window_size,IN curr_row_modifier,IN OUT temp_result_bin_double_nt(cid)
                                    , IN OUT mapping_tables_1(cid), IN OUT mapping_tables_2(cid), IN rct, OUT col_bin_double;
                    END IF;
                    DBMS_TF.PUT_COL(cid, col_bin_double);

                WHEN DBMS_TF.TYPE_BINARY_FLOAT THEN
                
                    col_bin_float.DELETE;
                    dyn_sql_string:=ptf_sliding_windows_support_pack.sql_text_datatype_setup(sql_string => dyn_sql_string,typ_zmiennej=>DBMS_TF.TYPE_BINARY_FLOAT);
                    
                    IF calc_operation IN ('SUM','AVERAGE') THEN
                        temp_result_bin_float_nt(cid)(1):=CASE WHEN temp_result_bin_float_nt(cid).EXISTS(1) THEN temp_result_bin_float_nt(cid)(1) ELSE TO_BINARY_FLOAT(0) END;     
                        EXECUTE IMMEDIATE dyn_sql_string 
                            USING   IN rst(cid).TAB_BINARY_FLOAT,IN OUT auxiliary_bin_float_storage(cid)
                                    ,IN lrow,IN window_size,IN curr_row_modifier,IN OUT temp_result_bin_float_nt(cid)(1), IN rct, OUT col_bin_float;
                    ELSE
                        EXECUTE IMMEDIATE dyn_sql_string 
                            USING   IN rst(cid).TAB_BINARY_FLOAT,IN OUT auxiliary_bin_float_storage(cid)
                                    ,IN lrow,IN window_size,IN curr_row_modifier,IN OUT temp_result_bin_float_nt(cid)
                                    , IN OUT mapping_tables_1(cid), IN OUT mapping_tables_2(cid), IN rct, OUT col_bin_float;
                    END IF; 
                    DBMS_TF.PUT_COL(cid, col_bin_float);

                WHEN DBMS_TF.TYPE_NUMBER THEN
                     
                    col_num.DELETE;
                    dyn_sql_string:=ptf_sliding_windows_support_pack.sql_text_datatype_setup(sql_string => dyn_sql_string,typ_zmiennej=>DBMS_TF.TYPE_NUMBER);  
                    IF calc_operation IN ('SUM','AVERAGE') THEN
                        temp_result_number_nt(cid)(1):=CASE WHEN temp_result_number_nt(cid).EXISTS(1) THEN temp_result_number_nt(cid)(1) ELSE 0 END;  
                        EXECUTE IMMEDIATE dyn_sql_string 
                            USING   IN rst(cid).TAB_NUMBER,IN OUT auxiliary_number_storage(cid)
                                    ,IN lrow,IN window_size,IN curr_row_modifier,IN OUT temp_result_number_nt(cid)(1), IN rct, OUT col_num;
                    ELSE
                        EXECUTE IMMEDIATE dyn_sql_string 
                            USING   IN rst(cid).TAB_NUMBER,IN OUT auxiliary_number_storage(cid)
                                    ,IN lrow,IN window_size,IN curr_row_modifier,IN OUT temp_result_number_nt(cid)
                                    , IN OUT mapping_tables_1(cid), IN OUT mapping_tables_2(cid), IN rct, OUT col_num;
                    END IF; 
                    DBMS_TF.PUT_COL(cid, col_num);                    
                ELSE   
                    RAISE_APPLICATION_ERROR(-20102,'Column is not calculable.');
            END CASE;
        END LOOP;
    END;
    
    procedure close(window_size IN NUMBER DEFAULT 1, include_curr_row IN NUMBER DEFAULT 1, additional_value NUMBER DEFAULT NULL, calc_operation IN VARCHAR2 DEFAULT 'SUM')
    IS
    BEGIN
        IF DBMS_TF.CSTORE_EXISTS('BINARY_DOUBLE') THEN
            auxiliary_bin_double_storage.DELETE;
            temp_result_bin_double_nt.DELETE;  
        END IF;
        
        IF DBMS_TF.CSTORE_EXISTS('BINARY_FLOAT') THEN
            auxiliary_bin_float_storage.DELETE;
            temp_result_bin_float_nt.DELETE;
        END IF;
        
        IF DBMS_TF.CSTORE_EXISTS('NUMBER') THEN
            auxiliary_number_storage.DELETE;
            temp_result_number_nt.DELETE;
        END IF;    
        IF calc_operation NOT IN ('SUM','AVERAGE') THEN
            mapping_tables_1.DELETE;
            mapping_tables_2.DELETE;
        END IF;
        DBMS_SESSION.FREE_UNUSED_USER_MEMORY;
    END;
END ptf_sliding_window_calc;

/
