public with sharing class CurrencyConverter {
    public static Decimal converter(String Code, Decimal Price) {
        CurrencyType c = [SELECT  ConversionRate FROM CurrencyType WHERE (IsActive=TRUE AND ISOcode=:Code)];
        Decimal rate = c.ConversionRate;
        Decimal fixedPrice = Price*rate; //Price in Discount Schedule Currency type
        //System.debug(fixedPrice);
        return fixedPrice;

    }
}
