/*****************************************************************************************************
 
Class    :  GroupBy
Developer:  Blue Wolf Group LLC
Created  :  Feb 12, 2014
Modified :  March 14, 2014
Objective:  This class is used to manipulate SObjects and group them in maps.
 
*****************************************************************************************************/ 
global class GroupBy
{
    global static Map<Date, List<sObject>> dates( String field, List<sObject> records )
    {
        Map<Date, List<sObject>> returnMap = new Map<Date, List<sObject>>();

        for ( sObject record : records )
        {
            Date key = (Date)record.get( field );

            if ( returnMap.containsKey( key ) )
            {
                returnMap.get( key ).add( record );
            }
            else
            {
                returnMap.put( key, new List<sObject>{ record } );
            }
        }

        return returnMap;
    }

    global static Map<DateTime, List<sObject>> datetimes( String field, List<sObject> records )
    {
        Map<DateTime, List<sObject>> returnMap = new Map<DateTime, List<sObject>>();

        for ( sObject record : records )
        {
            DateTime key = (DateTime)record.get( field );

            if ( returnMap.containsKey( key ) )
            {
                returnMap.get( key ).add( record );
            }
            else
            {
                returnMap.put( key, new List<sObject>{ record } );
            }
        }

        return returnMap;
    }

    global static Map<Decimal, List<sObject>> decimals( String field, List<sObject> records )
    {
        Map<Decimal, List<sObject>> returnMap = new Map<Decimal, List<sObject>>();

        for ( sObject record : records )
        {
            Decimal key = (Decimal)record.get( field );

            if ( returnMap.containsKey( key ) )
            {
                returnMap.get( key ).add( record );
            }
            else
            {
                returnMap.put( key, new List<sObject>{ record } );
            }
        }

        return returnMap;
    }

    global static Map<Integer, List<sObject>> integers( String field, List<sObject> records )
    {
        Map<Integer, List<sObject>> returnMap = new Map<Integer, List<sObject>>();

        for ( sObject record : records )
        {
            Integer key = (Integer)record.get( field );

            if ( returnMap.containsKey( key ) )
            {
                returnMap.get( key ).add( record );
            }
            else
            {
                returnMap.put( key, new List<sObject>{ record } );
            }
        }

        return returnMap;
    }

    global static Map<Id, List<sObject>> ids( String field, List<sObject> records )
    {
        Map<Id, List<sObject>> returnMap = new Map<Id, List<sObject>>();

        for ( sObject record : records )
        {
            Id key = (Id)record.get( field );

            if ( returnMap.containsKey( key ) )
            {
                returnMap.get( key ).add( record );
            }
            else
            {
                returnMap.put( key, new List<sObject>{ record } );
            }
        }

        return returnMap;
    }

    global static Map<String, List<sObject>> strings( String field, List<sObject> records )
    {
        Map<String, List<sObject>> returnMap = new Map<String, List<sObject>>();

        for ( sObject record : records )
        {
            String key = (String)record.get( field );

            if ( returnMap.containsKey( key ) )
            {
                returnMap.get( key ).add( record );
            }
            else
            {
                returnMap.put( key, new List<sObject>{ record } );
            }
        }

        return returnMap;
    }
}