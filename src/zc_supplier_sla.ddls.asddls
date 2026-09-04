@EndUserText.label: 'Projection View for Supplier SLA'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_SUPPLIER_SLA
  provider contract transactional_query
  as projection on ZI_SUPPLIER_SLA
{
  key RecordUuid,
      @Search.defaultSearchElement: true
      VendorId,
      @Search.defaultSearchElement: true
      PoNumber,
      ExpectedDelivery,
      ActualDelivery,
      DelayDays,
      PenaltyRate,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      PenaltyAmount,
      Status,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
