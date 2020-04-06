public with sharing class DataTableWrapperController {

    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecords(String objectName, String fieldToQuery, String filters){
        String query = 'SELECT ' + fieldToQuery + ' FROM ' + objectName;
        if (String.isNotBlank(filters)){
            query += ' WHERE ' + filters;
        }
        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Map<String, String>> getFieldDetails(String objectName, String fieldToQuery, String filters){
        //Covert Object and Field Names to Lower case
        objectName = objectName.toLowerCase();
        fieldToQuery = fieldToQuery.toLowerCase();

        Map<Schema.DisplayType, String> fieldDisplayTypeToJsTypeMap = buildSFTypeToJsTypeMap();
        Map<String, Map<String, String>> fieldNameToDetailsMap = new Map<String, Map<String, String>>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        for (String fieldName : fieldToQuery.split(',')) {
            fieldName = fieldName.replace(' ','');
            if (fieldMap.containsKey(fieldName)) {
                Schema.SObjectField fieldDetail = fieldMap.get(fieldName);
                Schema.DisplayType displayType = fieldDetail.getDescribe().getType();
                String fieldLabel = fieldDetail.getDescribe().getLabel();
                String apiName = fieldDetail.getDescribe().getName();
                if (fieldDisplayTypeToJsTypeMap.containsKey(displayType)) {
                    Map<String, String> fieldDetailsMap = new Map<String, String>(); 
                    fieldDetailsMap.put('label', fieldLabel);
                    fieldDetailsMap.put('apiname', apiName);
                    fieldDetailsMap.put('displaytype', fieldDisplayTypeToJsTypeMap.get(displayType));
                    fieldNameToDetailsMap.put(fieldName, fieldDetailsMap);
                }
            }
            
        }
        return fieldNameToDetailsMap;
    }

    private static Map<Schema.DisplayType, String> buildSFTypeToJsTypeMap() {
        Map<Schema.DisplayType, String> fieldDisplayTypeToJsTypeMap = new Map<Schema.DisplayType, String>();
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.BOOLEAN, 'boolean');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.COMBOBOX, 'text');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.CURRENCY, 'currency');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.DATACATEGORYGROUPREFERENCE, 'text');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.DATE, 'date');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.DOUBLE, 'number');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.EMAIL, 'email');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.ID, 'text');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.INTEGER, 'number');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.LONG, 'number');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.MULTIPICKLIST, 'text');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.PERCENT, 'number');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.PHONE, 'phone');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.PICKLIST, 'text');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.REFERENCE, 'id');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.STRING, 'text');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.TEXTAREA, 'text');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.TIME, '');
        fieldDisplayTypeToJsTypeMap.put(Schema.DisplayType.URL, '');
        return fieldDisplayTypeToJsTypeMap;
    }
}
