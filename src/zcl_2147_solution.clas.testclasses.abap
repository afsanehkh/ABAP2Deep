*"* use this source file for your ABAP unit test classes
class ltcl_find_flights_ definition final for testing
  duration MEDIUM
  risk level harmless.

  private section.
    methods:
      test_find_cargo_flight for testing raising cx_static_check.
endclass.


class ltcl_find_flights_ implementation.

  method test_find_cargo_flight.

    SELECT SINGLE FROM /lrn/cargoflight
        FIELDS carrier_id, connection_id, flight_date, airport_from_id, airport_to_id
        WHERE maximum_load - actual_load >= 1
        INTO @DATA(some_flight_data).

*   F sy-subrc = 0.
*   cl_abap_unit_assert=>fail( 'No suitable data in table' ).
*   NDIF.

    TRY.

        DATA(the_carrier) = lcl_carrier=>get_instance( i_carrier_id = some_flight_data-carrier_id ).
*    CATCH cx_abap_invalid_value.
*        cl_abap_unit_assert=>fail( 'Carrier does not exist' ).
    CATCH cx_root INTO DATA(exc_root).
        cl_abap_unit_assert=>fail( exc_root->get_text(  ) ).

    ENDTRY.


    the_carrier->find_cargo_flight(
         EXPORTING
           i_airport_from_id = some_flight_data-airport_from_id
           i_airport_to_id   = some_flight_data-airport_to_id
           i_from_date       = some_flight_data-flight_date
           i_cargo           = 1
         IMPORTING
           e_flight =     DATA(flight)
           e_days_later = DATA(days_later)
     ).

    cl_abap_unit_assert=>assert_bound( act = flight
                                        msg = 'Method find_cargo_flight does not return a result'
                                        ).

    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = days_later
                                        msg = 'Method find_cargo_flight returns wrong result'
                                        ).



  endmethod.

endclass.

