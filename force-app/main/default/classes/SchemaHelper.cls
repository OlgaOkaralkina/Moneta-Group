public with sharing class SchemaHelper {

    private static Map<String, Schema.DescribeSObjectResult> objectResultCache = new Map<String, Schema.DescribeSObjectResult>();
    private static Map<String, Map<String, Schema.SObjectField>> objectFieldsCache = new Map<String, Map<String, Schema.SObjectField>>();

    public static Schema.DescribeSobjectResult getObjectInfo(String type) {
        return getObjectsInfo(new String[] { type })[0];
    }

    public static Schema.DescribeSobjectResult[] getObjectsInfo(String[] types) {
        Schema.DescribeSobjectResult[] result = new List<Schema.DescribeSobjectResult>();

        List<String> typesForRetrieving = new List<String>();
        
        for (String type : types) {
            if (!objectResultCache.keySet().contains(type))
                typesForRetrieving.add(type);
        }

        if (!typesForRetrieving.isEmpty()) {
            Schema.DescribeSobjectResult[] newResults = Schema.describeSObjects(typesForRetrieving);

            for (Schema.DescribeSobjectResult dsor : newResults) {
                objectResultCache.put(dsor.getName(), dsor);
            }
        }

        for (String type : types) {
            result.add(objectResultCache.get(type));
        }

        return result;
    }

    public static Map<String, Schema.SObjectField> getFieldsMap(String type) {
        Map<String, Schema.SObjectField> result = objectFieldsCache.get(type);

        if (result == null) {
            System.debug('Gettings fields map for ' + type);
            Schema.DescribeSobjectResult dsor = getObjectInfo(type);

            result = dsor.fields.getMap();
            objectFieldsCache.put(dsor.getName(), result);
        }

        return result;
    }
    
    public static String[] getInaccessible(String type) {
        String[] result = new String[]{};

        Map<String, Schema.SObjectField> sof = getFieldsMap(type);
        if (sof == null)
            return result;

        for (String fieldToCheck : sof.keySet()) {
            if (!sof.get(fieldToCheck).getDescribe().isAccessible()) {
                System.debug('Field [' + fieldToCheck + '] is ' + sof.get(fieldToCheck).getDescribe().isAccessible());
                result.add(sof.get(fieldToCheck).getDescribe().getLocalName());
            }
        }

        return result;
    }
}