/*****************************************************************************************************
 
Class    :  Pluck
Developer:  Blue Wolf Group LLC
Created  :  Feb 12, 2014
Modified :  March 14, 2014
Objective:  This class is used to manipulate SObjects and extract relevant field values into sets.
 
*****************************************************************************************************/ 
global class Pluck
{
    global static Object pluck( String field, sObject obj )
    {
        return obj.get( field );
    }

    global static Set<Object> pluck( String field, List<sObject> objs )
    {
        Set<Object> plucked = new Set<Object>();

        for ( sObject obj : objs )
        {
            Object val = pluck( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    global static Date pluckDate( String field, sObject obj )
    {
        return (Date)pluck( field, obj );
    }

    global static Set<Date> dates( String field, Map<Id, sObject> objs )
    {
        return dates( field, objs.values() );
    }

    global static Set<Date> dates( String field, List<sObject> objs )
    {
        Set<Date> plucked = new Set<Date>();

        for ( sObject obj : objs )
        {
            Date val = pluckDate( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    global static Datetime pluckDatetime( String field, sObject obj )
    {
        return (Datetime)pluck( field, obj );
    }

    global static Set<Datetime> datetimes( String field, Map<Id, sObject> objs )
    {
        return datetimes( field, objs.values() );
    }

    global static Set<Datetime> datetimes( String field, List<sObject> objs )
    {
        Set<Datetime> plucked = new Set<Datetime>();

        for ( sObject obj : objs )
        {
            Datetime val = pluckDatetime( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    global static Decimal pluckDecimal( String field, sObject obj )
    {
        return (Decimal)pluck( field, obj );
    }

    global static Set<Decimal> decimals( String field, Map<Id, sObject> objs )
    {
        return decimals( field, objs.values() );
    }

    global static Set<Decimal> decimals( String field, List<sObject> objs )
    {
        Set<Decimal> plucked = new Set<Decimal>();

        for ( sObject obj : objs )
        {
            Decimal val = pluckDecimal( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    global static Integer pluckInteger( String field, sObject obj )
    {
        return (Integer)pluck( field, obj );
    }

    global static Set<Integer> integers( String field, Map<Id, sObject> objs )
    {
        return integers( field, objs.values() );
    }

    global static Set<Integer> integers( String field, List<sObject> objs )
    {
        Set<Integer> plucked = new Set<Integer>();

        for ( sObject obj : objs )
        {
            Integer val = pluckInteger( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    global static Map<Id, Set<sObject>> fieldToSObjects(String field, List<sObject>objs)
    {
        Map<Id, Set<sObject>> objTosObjects = new Map<Id, Set<sObject>>();
        for( sObject obj : objs )
        {
            Id fieldVal = (Id)obj.get( field );
            if( !objTosObjects.containsKey( fieldVal ) ) 
                objTosObjects.put( fieldVal, new Set<sObject>() );
            objTosObjects.get( fieldVal ).add( obj );
        }
        return objTosObjects;
    }

    global static Set<Id> ids( List<sObject> objs )
    {
        return new Map<Id, sObject>( objs ).keySet();
    }

    global static Set<Id> ids( Map<Id, sObject> objs )
    {
        return ids( objs.values() );
    }

    global static Id pluckId( String field, sObject obj )
    {
        return (Id)pluck( field, obj );
    }

    global static Set<Id> ids( String field, Map<Id, sObject> objs )
    {
        return ids( field, objs.values() );
    }

    global static Set<Id> ids( String field, List<sObject> objs )
    {
        Set<Id> plucked = new Set<Id>();

        for ( sObject obj : objs )
        {
            Id val = pluckId( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    global static String pluckString( String field, sObject obj )
    {
        return (String)pluck( field, obj );
    }

    global static Set<String> strings( String field, Map<Id, sObject> objs )
    {
        return strings( field, objs.values() );
    }

    global static Set<String> strings( String field, List<sObject> objs )
    {
        Set<String> plucked = new Set<String>();

        for ( sObject obj : objs )
        {
            String val = pluckString( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }
}