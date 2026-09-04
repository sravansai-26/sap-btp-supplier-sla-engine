CLASS lhc_slalog DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR SLALog RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR SLALog RESULT result.

    METHODS calculatePenalty FOR DETERMINE ON MODIFY
      IMPORTING keys FOR SLALog~calculatePenalty.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR SLALog~validateDates.

    METHODS approvePenalty FOR MODIFY
      IMPORTING keys FOR ACTION SLALog~approvePenalty RESULT result.

    METHODS waivePenalty FOR MODIFY
      IMPORTING keys FOR ACTION SLALog~waivePenalty RESULT result.
ENDCLASS.

CLASS lhc_slalog IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD calculatePenalty.
    READ ENTITIES OF ZI_SUPPLIER_SLA IN LOCAL MODE
      ENTITY SLALog
      FIELDS ( ExpectedDelivery ActualDelivery PenaltyRate Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(records).

    LOOP AT records INTO DATA(ls_rec).
      DATA(lv_delay) = 0.
      DATA(lv_penalty) = 0.

      IF ls_rec-ActualDelivery IS NOT INITIAL AND ls_rec-ExpectedDelivery IS NOT INITIAL.
        IF ls_rec-ActualDelivery > ls_rec-ExpectedDelivery.
          lv_delay = ls_rec-ActualDelivery - ls_rec-ExpectedDelivery.
          lv_penalty = lv_delay * ls_rec-PenaltyRate.
        ENDIF.
      ENDIF.

      DATA(lv_status) = ls_rec-Status.
      IF lv_status IS INITIAL.
        lv_status = 'Pending Review'.
      ENDIF.

      MODIFY ENTITIES OF ZI_SUPPLIER_SLA IN LOCAL MODE
        ENTITY SLALog
        UPDATE FIELDS ( DelayDays PenaltyAmount Status )
        WITH VALUE #( ( %tky           = ls_rec-%tky
                        DelayDays      = lv_delay
                        PenaltyAmount  = lv_penalty
                        Status         = lv_status ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.
    READ ENTITIES OF ZI_SUPPLIER_SLA IN LOCAL MODE
      ENTITY SLALog
      FIELDS ( ActualDelivery )
      WITH CORRESPONDING #( keys )
      RESULT DATA(records).

    LOOP AT records INTO DATA(ls_rec).
      IF ls_rec-ActualDelivery > cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = ls_rec-%tky ) TO failed-slalog.
        APPEND VALUE #( %tky = ls_rec-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Actual delivery date cannot be in the future.' )
                      ) TO reported-slalog.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD approvePenalty.
    MODIFY ENTITIES OF ZI_SUPPLIER_SLA IN LOCAL MODE
      ENTITY SLALog
      UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN keys ( %tky   = key-%tky
                                      Status = 'Approved' ) ).

    READ ENTITIES OF ZI_SUPPLIER_SLA IN LOCAL MODE
      ENTITY SLALog
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(records).

    result = VALUE #( FOR rec IN records ( %tky   = rec-%tky
                                           %param = rec ) ).
  ENDMETHOD.

  METHOD waivePenalty.
    MODIFY ENTITIES OF ZI_SUPPLIER_SLA IN LOCAL MODE
      ENTITY SLALog
      UPDATE FIELDS ( Status PenaltyAmount )
      WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                      Status        = 'Waived'
                                      PenaltyAmount = 0 ) ).

    READ ENTITIES OF ZI_SUPPLIER_SLA IN LOCAL MODE
      ENTITY SLALog
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(records).

    result = VALUE #( FOR rec IN records ( %tky   = rec-%tky
                                           %param = rec ) ).
  ENDMETHOD.

ENDCLASS.
