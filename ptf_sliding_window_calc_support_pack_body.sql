CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "PIOTR"."PTF_SLIDING_WINDOWS_SUPPORT_PACK" 
IS
    function sql_text_operation_setup(sql_string VARCHAR2,operacja VARCHAR2, with_curr_row NUMBER) RETURN VARCHAR2
    IS
        retval VARCHAR2(32767);
    BEGIN
        CASE 
            WHEN operacja = 'SUM' THEN
                retval:=REGEXP_REPLACE(REPLACE(REPLACE(REPLACE(sql_string
                        ,' mechanism_for_incomplete_window ',' auxiliary_storage(MOD(ostatni_wiersz+rid,wielkosc_okna+1-curr_row_modifier)):=intermediate_rst(rid);
                        result_set_coll(rid):=CASE WHEN result_set_coll.EXISTS(rid-1) THEN result_set_coll(rid-1) ELSE additional_value END+intermediate_rst(rid); ')
                        ,' mechanism_for_full_window ',' result_set_coll(rid):=CASE WHEN result_set_coll.EXISTS(rid-1) THEN result_set_coll(rid-1) ELSE additional_value END+intermediate_rst(rid)-auxiliary_storage(MOD(ostatni_wiersz+rid,wielkosc_okna+1-curr_row_modifier));
                        auxiliary_storage(MOD(ostatni_wiersz+rid,wielkosc_okna+1-curr_row_modifier)):=intermediate_rst(rid); '),' placeholder_variables ',' additional_value placeholder2_type := :addit_val;'),' placeholder_operations([12]{1})');
                IF with_curr_row = 1 THEN
                    retval:=REPLACE(retval,' END LOOP; ',' END LOOP; :addit_val:=result_set_coll(:rct); FOR i IN REVERSE 2..:rct  LOOP result_set_coll(i):=result_set_coll(i-1); END LOOP; result_set_coll(1):=CASE WHEN ostatni_wiersz=0 THEN NULL ELSE additional_value END;');
                ELSE
                    retval:=REPLACE(retval,' :aux_store:=auxiliary_storage; ', ' :aux_store:=auxiliary_storage; :addit_val:=result_set_coll(:rct); ');
                END IF;
            WHEN operacja = 'AVERAGE' THEN
                retval:=REGEXP_REPLACE(REPLACE(REPLACE(REPLACE(sql_string
                        ,' mechanism_for_incomplete_window ',' auxiliary_storage(MOD(ostatni_wiersz+rid,wielkosc_okna+1-curr_row_modifier)):=intermediate_rst(rid);
                        result_set_coll(rid):=((CASE WHEN result_set_coll.EXISTS(rid-1) THEN result_set_coll(rid-1) ELSE additional_value END)*(ostatni_wiersz+rid-1)+intermediate_rst(rid))/(ostatni_wiersz+rid); ')
                        ,' mechanism_for_full_window ',' result_set_coll(rid):=((CASE WHEN result_set_coll.EXISTS(rid-1) THEN result_set_coll(rid-1) ELSE additional_value END)*(wielkosc_okna+1-curr_row_modifier)+intermediate_rst(rid)-auxiliary_storage(MOD(ostatni_wiersz+rid,wielkosc_okna+1-curr_row_modifier)))/(wielkosc_okna+1-curr_row_modifier);
                        auxiliary_storage(MOD(ostatni_wiersz+rid,wielkosc_okna+1-curr_row_modifier)):=intermediate_rst(rid); '),' placeholder_variables ',' additional_value placeholder2_type := :addit_val;'),' placeholder_operations([12]{1})');
                IF with_curr_row = 1 THEN
                    retval:=REPLACE(retval,' END LOOP; ',' END LOOP; :addit_val:=result_set_coll(:rct); FOR i IN REVERSE 2..:rct  LOOP result_set_coll(i):=result_set_coll(i-1); END LOOP; result_set_coll(1):=CASE WHEN ostatni_wiersz=0 THEN NULL ELSE additional_value END;');
                ELSE
                    retval:=REPLACE(retval,' :aux_store:=auxiliary_storage; ', ' :aux_store:=auxiliary_storage; :addit_val:=result_set_coll(:rct); ');
                END IF;
            WHEN operacja IN ('MAX','MIN','MEDIAN','PERCENTILE' )THEN
                retval:=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(sql_string
                        ,' mechanism_for_incomplete_window ',' curr_row:=MOD(ostatni_wiersz+rid-1,wielkosc_okna+1-curr_row_modifier); auxiliary_storage(curr_row):=intermediate_rst(rid); mapping_table_1(curr_row):=curr_row;
                        mapping_table_2(curr_row):=curr_row; temp_result(curr_row):=intermediate_rst(rid);
                        IF curr_row>0 AND temp_result(curr_row)<temp_result(curr_row-1) THEN LOOP EXIT WHEN curr_row-counter=0 OR temp_result(curr_row-counter)>=temp_result(curr_row-counter-1);
                        additional_number_2:=mapping_table_2(curr_row-counter-1); additional_number_1:=mapping_table_1(additional_number_2); temp_result(curr_row-counter-1):=temp_result(curr_row-counter);/*przepisuje wartosc z wyzszego indeksu na ni¿szy*/
                        mapping_table_1(mapping_table_2(curr_row-counter-1)):=mapping_table_1(mapping_table_2(curr_row-counter)); mapping_table_1(mapping_table_2(curr_row-counter)):=additional_number_1;
                        mapping_table_2(curr_row-counter-1):=mapping_table_2(curr_row-counter); mapping_table_2(curr_row-counter):=additional_number_2;
                        temp_result(curr_row-counter):=auxiliary_storage(mapping_table_2(curr_row-counter)); counter:=counter+1; END LOOP; END IF; ')
                        ,' mechanism_for_full_window ',' curr_row:=mapping_table_1(MOD(ostatni_wiersz+rid-1,wielkosc_okna+1-curr_row_modifier)); auxiliary_storage(MOD(ostatni_wiersz+rid-1,wielkosc_okna+1-curr_row_modifier)):=intermediate_rst(rid);
                        temp_result(curr_row):=intermediate_rst(rid); IF curr_row>0 AND temp_result(curr_row)<temp_result(curr_row-1) THEN LOOP EXIT WHEN curr_row-counter=0 OR temp_result(curr_row-counter)>=temp_result(curr_row-counter-1); additional_number_2:=mapping_table_2(curr_row-counter-1);
                        additional_number_1:=mapping_table_1(additional_number_2); temp_result(curr_row-counter-1):=temp_result(curr_row-counter);/*przepisuje wartosc z wyzszego indeksu na ni¿szy*/
                        mapping_table_1(mapping_table_2(curr_row-counter-1)):=mapping_table_1(mapping_table_2(curr_row-counter)); mapping_table_1(mapping_table_2(curr_row-counter)):=additional_number_1;
                        mapping_table_2(curr_row-counter-1):=mapping_table_2(curr_row-counter); mapping_table_2(curr_row-counter):=additional_number_2;
                        temp_result(curr_row-counter):=auxiliary_storage(mapping_table_2(curr_row-counter)); counter:=counter+1; END LOOP;
                        ELSIF curr_row <wielkosc_okna-curr_row_modifier AND temp_result(curr_row)>temp_result(curr_row+1) THEN LOOP EXIT WHEN curr_row+counter=wielkosc_okna-curr_row_modifier OR temp_result(curr_row+counter)<=temp_result(curr_row+counter+1);
                        additional_number_2:=mapping_table_2(curr_row+counter+1); additional_number_1:=mapping_table_1(additional_number_2);
                        temp_result(curr_row+counter+1):=temp_result(curr_row+counter); mapping_table_1(mapping_table_2(curr_row+counter+1)):=mapping_table_1(mapping_table_2(curr_row+counter));/*przepisuje wartosc mappingu z wyzszego indeksu na ni¿szy*/
                        mapping_table_1(mapping_table_2(curr_row+counter)):=additional_number_1; mapping_table_2(curr_row+counter+1):=mapping_table_2(curr_row+counter);
                        mapping_table_2(curr_row+counter):=additional_number_2; temp_result(curr_row+counter):=auxiliary_storage(mapping_table_2(curr_row+counter));
                        counter:=counter+1; END LOOP; END IF; ')
                        ,' placeholder_variables ','temp_result placeholder_type:= :temp_store; mapping_table_1 DBMS_TF.TAB_NUMBER_T:= :mapping_1; mapping_table_2 DBMS_TF.TAB_NUMBER_T:= :mapping_2;
                        additional_number_1 NUMBER:=0; additional_number_2 NUMBER:=0; counter NUMBER:=0; curr_row NUMBER;')
                        ,' placeholder_operations2', ' counter:=0; placeholder_result;')
                        ,' :aux_store:=auxiliary_storage; ', ' :aux_store:=auxiliary_storage; :mapping_1:=mapping_table_1; :mapping_2:=mapping_table_2; :temp_store:=temp_result;');
                        IF with_curr_row = 0 THEN
                            CASE operacja
                                WHEN 'MAX' THEN retval:=REPLACE(REPLACE(retval,'placeholder_result','result_set_coll(rid):=temp_result(LEAST(ostatni_wiersz*1024+rid-1,wielkosc_okna-curr_row_modifier))'),'placeholder_operations1');
                                WHEN 'MIN' THEN retval:=REPLACE(REPLACE(retval,'placeholder_result','result_set_coll(rid):=temp_result(0)'),'placeholder_operations1');
                                WHEN 'MEDIAN' THEN retval:=REPLACE(REPLACE(retval,'placeholder_result','result_set_coll(rid):=(temp_result(FLOOR(LEAST(ostatni_wiersz+rid-1,wielkosc_okna-curr_row_modifier)/2))+temp_result(CEIL(LEAST(ostatni_wiersz+rid-1,wielkosc_okna-curr_row_modifier)/2)))/2'),'placeholder_operations1');
                            END CASE;
                        ELSIF with_curr_row = 1 THEN
                            CASE operacja
                                WHEN 'MAX' THEN retval:=REPLACE(REPLACE(retval,'placeholder_operations1','result_set_coll(rid):=CASE WHEN temp_result.EXISTS(0) THEN temp_result(LEAST(ostatni_wiersz+rid-1,wielkosc_okna-curr_row_modifier)) ELSE NULL END;'),'placeholder_result;');
                                WHEN 'MIN' THEN retval:=REPLACE(REPLACE(retval,'placeholder_operations1','result_set_coll(rid):=CASE WHEN temp_result.EXISTS(0) THEN temp_result(0) ELSE NULL END; '),'placeholder_result;');
                                WHEN 'MEDIAN' THEN retval:=REPLACE(REPLACE(retval,'placeholder_operations1','result_set_coll(rid):=CASE WHEN temp_result.EXISTS(0) THEN (temp_result(FLOOR(LEAST(ostatni_wiersz+rid-1,wielkosc_okna-curr_row_modifier)/2))+temp_result(CEIL(LEAST(ostatni_wiersz+rid-1,wielkosc_okna)/2)))/2 ELSE NULL END;'),'placeholder_result;');
                            END CASE;
                        END IF;
            ELSE
                RAISE_APPLICATION_ERROR(-20103,'Method currently not supported');
        END CASE;
        RETURN retval;
    END;

    function sql_text_datatype_setup(sql_string VARCHAR2,typ_zmiennej PLS_INTEGER) RETURN VARCHAR2
    IS
        retval VARCHAR2(32767);
    BEGIN
        CASE typ_zmiennej
            WHEN DBMS_TF.TYPE_BINARY_DOUBLE THEN
                retval:= REPLACE(REPLACE(sql_string,'placeholder_type','DBMS_TF.TAB_BINARY_DOUBLE_T'),'placeholder2_type','BINARY_DOUBLE');
            WHEN DBMS_TF.TYPE_BINARY_FLOAT THEN
                retval:= REPLACE(REPLACE(sql_string,'placeholder_type','DBMS_TF.TAB_BINARY_FLOAT_T'),'placeholder2_type','BINARY_FLOAT');
            WHEN DBMS_TF.TYPE_NUMBER THEN
                retval:= REPLACE(REPLACE(sql_string,'placeholder_type','DBMS_TF.TAB_NUMBER_T'),'placeholder2_type','NUMBER');    
        END CASE;    
        RETURN retval;
    END;    
END;

/
