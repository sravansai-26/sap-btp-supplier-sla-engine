@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Core View for Supplier SLA'
define root view entity ZI_SUPPLIER_SLA
  as select from zslarecord
{
  key record_uuid           as RecordUuid,
      vendor_id             as VendorId,
      po_number             as PoNumber,
      expected_delivery     as ExpectedDelivery,
      actual_delivery       as ActualDelivery,
      delay_days            as DelayDays,
      penalty_rate          as PenaltyRate,
      currency              as Currency,
      @Semantics.amount.currencyCode: 'Currency'
      penalty_amount        as PenaltyAmount,
      status                as Status,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
