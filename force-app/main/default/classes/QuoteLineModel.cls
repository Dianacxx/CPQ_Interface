public with sharing class QuoteLineModel {
    public SBQQ__QuoteLine__c record;
    public Boolean amountDiscountProrated;
    public Integer parentGroupKey;
    public Integer parentItemKey;
    public Integer key;
    public Boolean upliftable;
    public String configurationType;
    public String configurationEvent;
    public Boolean reconfigurationDisabled;
    public Boolean descriptionLocked;
    public Boolean productQuantityEditable;
    public Decimal productQuantityScale;
    public String dimensionType;
    public Boolean productHasDimensions;
    public Decimal targetCustomerAmount;
    public Decimal targetCustomerTotal;
    public SBQQ__DiscountTier__c discount;

	public SBQQ__QuoteLine__c getRecord() {
		return this.record;
	}

	public void setRecord(SBQQ__QuoteLine__c record) {
		this.record = record;
	}
	
	public SBQQ__DiscountTier__c getDiscount() {
		return this.discount;
	}

	public void setDiscount(SBQQ__DiscountTier__c discount) {
		this.discount = discount;
	}


	public Integer getParentItemKey() {
		return this.parentItemKey;
	}

	public void setParentItemKey(Integer parentItemKey) {
		this.parentItemKey = parentItemKey;
	}

	public Integer getKey() {
		return this.key;
	}

	public void setKey(Integer key) {
		this.key = key;
	}

	public Boolean getUpliftable() {
		return this.upliftable;
	}

	public void setUpliftable(Boolean upliftable) {
		this.upliftable = upliftable;
	}

	public String getConfigurationType() {
		return this.configurationType;
	}

	public void setConfigurationType(String configurationType) {
		this.configurationType = configurationType;
	}

	public String getConfigurationEvent() {
		return this.configurationEvent;
	}

	public void setConfigurationEvent(String configurationEvent) {
		this.configurationEvent = configurationEvent;
	}

	public Boolean getReconfigurationDisabled() {
		return this.reconfigurationDisabled;
	}

	public void setReconfigurationDisabled(Boolean reconfigurationDisabled) {
		this.reconfigurationDisabled = reconfigurationDisabled;
	}

	public Boolean getDescriptionLocked() {
		return this.descriptionLocked;
	}

	public void setDescriptionLocked(Boolean descriptionLocked) {
		this.descriptionLocked = descriptionLocked;
	}

	public Boolean getProductQuantityEditable() {
		return this.productQuantityEditable;
	}

	public void setProductQuantityEditable(Boolean productQuantityEditable) {
		this.productQuantityEditable = productQuantityEditable;
	}

	public Decimal getProductQuantityScale() {
		return this.productQuantityScale;
	}

	public void setProductQuantityScale(Decimal productQuantityScale) {
		this.productQuantityScale = productQuantityScale;
	}

	public String getDimensionType() {
		return this.dimensionType;
	}

	public void setDimensionType(String dimensionType) {
		this.dimensionType = dimensionType;
	}

	public Boolean getProductHasDimensions() {
		return this.productHasDimensions;
	}

	public void setProductHasDimensions(Boolean productHasDimensions) {
		this.productHasDimensions = productHasDimensions;
	}

	public Decimal getTargetCustomerAmount() {
		return this.targetCustomerAmount;
	}

	public void setTargetCustomerAmount(Decimal targetCustomerAmount) {
		this.targetCustomerAmount = targetCustomerAmount;
	}

	public Decimal getTargetCustomerTotal() {
		return this.targetCustomerTotal;
	}

	public void setTargetCustomerTotal(Decimal targetCustomerTotal) {
		this.targetCustomerTotal = targetCustomerTotal;
	}

}