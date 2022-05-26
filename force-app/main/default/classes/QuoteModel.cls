public with sharing class QuoteModel {
    public SBQQ__Quote__c record;
    public QuoteLineModel[] lineItems;
    public QuoteLineGroupModel[] lineItemGroups;
    public Integer nextKey;
    public Boolean applyAdditionalDiscountLast;
    public Boolean applyPartnerDiscountFirst;
    public Boolean channelDiscountsOffList;
    public Decimal customerTotal;
    public Decimal netTotal;
    public Decimal netNonSegmentTotal;

	public SBQQ__Quote__c getRecord() {
		return this.record;
	}

	public void setRecord(SBQQ__Quote__c record) {
		this.record = record;
	}

	public QuoteLineModel[] getLineItems() {
		return this.lineItems;
	}

	public void setLineItems(QuoteLineModel[] lineItems) {
		this.lineItems = lineItems;
	}

	public QuoteLineGroupModel[] getLineItemGroups() {
		return this.lineItemGroups;
	}

	public void setLineItemGroups(QuoteLineGroupModel[] lineItemGroups) {
		this.lineItemGroups = lineItemGroups;
	}

	public Integer getNextKey() {
		return this.nextKey;
	}

	public void setNextKey(Integer nextKey) {
		this.nextKey = nextKey;
	}

	public Boolean getApplyAdditionalDiscountLast() {
		return this.applyAdditionalDiscountLast;
	}

	public void setApplyAdditionalDiscountLast(Boolean applyAdditionalDiscountLast) {
		this.applyAdditionalDiscountLast = applyAdditionalDiscountLast;
	}

	public Boolean getApplyPartnerDiscountFirst() {
		return this.applyPartnerDiscountFirst;
	}

	public void setApplyPartnerDiscountFirst(Boolean applyPartnerDiscountFirst) {
		this.applyPartnerDiscountFirst = applyPartnerDiscountFirst;
	}

	public Boolean getChannelDiscountsOffList() {
		return this.channelDiscountsOffList;
	}

	public void setChannelDiscountsOffList(Boolean channelDiscountsOffList) {
		this.channelDiscountsOffList = channelDiscountsOffList;
	}

	public Decimal getCustomerTotal() {
		return this.customerTotal;
	}

	public void setCustomerTotal(Decimal customerTotal) {
		this.customerTotal = customerTotal;
	}

	public Decimal getNetTotal() {
		return this.netTotal;
	}

	public void setNetTotal(Decimal netTotal) {
		this.netTotal = netTotal;
	}

	public Decimal getNetNonSegmentTotal() {
		return this.netNonSegmentTotal;
	}

	public void setNetNonSegmentTotal(Decimal netNonSegmentTotal) {
		this.netNonSegmentTotal = netNonSegmentTotal;
	}

}