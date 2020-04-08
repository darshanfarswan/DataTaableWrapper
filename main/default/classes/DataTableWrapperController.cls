public with sharing class DataTableWrapperController {

    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecords(String objectName, String fieldsToQuery, String filters){
        String query = 'SELECT ' + fieldsToQuery + ' FROM ' + objectName;
        if (String.isNotBlank(filters)){
            query += ' WHERE ' + filters;
        }
        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Map<String, String>> getFieldDetails(String objectName, String fieldsToQuery, String filters){
        //Covert Object and Field Names to Lower case
        objectName = objectName.toLowerCase();
        fieldsToQuery = fieldsToQuery.toLowerCase();

        Map<Schema.DisplayType, String> fieldDisplayTypeToJsTypeMap = buildSFTypeToJsTypeMap();
        Map<String, Map<String, String>> fieldNameToDetailsMap = new Map<String, Map<String, String>>();
        DescribeSObjectResult objectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectResult.fields.getMap();
        
        for (String fieldName : fieldsToQuery.split(',')) {
            fieldName = fieldName.replace(' ','');
            if (fieldMap.containsKey(fieldName)) {
                Schema.DescribeFieldResult fieldDescribeResult = fieldMap.get(fieldName).getDescribe();
                Schema.DisplayType displayType = fieldDescribeResult.getType();
                String fieldLabel = fieldDescribeResult.getLabel();
                String apiName = fieldDescribeResult.getName();
                if (fieldDisplayTypeToJsTypeMap.containsKey(displayType)) {
                    Map<String, String> fieldDetailsMap = new Map<String, String>(); 
                    fieldDetailsMap.put('label', fieldLabel);
                    fieldDetailsMap.put('apiname', apiName);
                    fieldDetailsMap.put('displaytype', fieldDisplayTypeToJsTypeMap.get(displayType));
                    fieldDetailsMap.put('objectPluralName', objectResult.getLabelPlural());
                    System.debug('adding' + fieldName);
                    fieldNameToDetailsMap.put(fieldName, fieldDetailsMap);
                }
            } else {
                //Check for relationship and get base field Name
                if (fieldName.contains('.')) {
                    List<String> splitFieldRelationshipAndName = fieldName.split('\\.');
                    String relationshipName = splitFieldRelationshipAndName.get(0);
                    String relatedField = splitFieldRelationshipAndName.get(1);
                    String relationshipField = getRelationshipFieldName(relationshipName);
                    if (String.isnotBlank(relationshipField)) {
                        if (fieldMap.containsKey(relationshipField)) {
                            Schema.DescribeFieldResult fieldDescribeResult = fieldMap.get(relationshipField).getDescribe();
                            String relationFieldApiName = fieldDescribeResult.getRelationshipName();
                            Schema.sObjectType referencedObject = fieldDescribeResult.getReferenceTo().get(0);
                            Map<String, Schema.SObjectField> relationshipFieldMap = referencedObject.getDescribe().fields.getMap();
                            if (relationshipFieldMap.containsKey(relatedField)) {
                                Schema.DescribeFieldResult relationFieldDescribeResult = relationshipFieldMap.get(relatedField).getDescribe();
                                Schema.DisplayType displayType = relationFieldDescribeResult.getType();
                                String fieldLabel = relationFieldDescribeResult.getLabel();
                                String apiName = relationFieldDescribeResult.getName();
                                if (fieldDisplayTypeToJsTypeMap.containsKey(displayType)) {
                                    Map<String, String> fieldDetailsMap = new Map<String, String>(); 
                                    fieldDetailsMap.put('label', fieldLabel);
                                    fieldDetailsMap.put('apiname', relationFieldApiName + '_' + apiName);
                                    fieldDetailsMap.put('displaytype', fieldDisplayTypeToJsTypeMap.get(displayType));
                                    fieldDetailsMap.put('objectPluralName', objectResult.getLabelPlural());
                                    System.debug('adding' + fieldName);
                                    fieldNameToDetailsMap.put(fieldName, fieldDetailsMap);
                                }
                            }
                        }
                    }
                }
            }
        }
        for (String key : fieldNameToDetailsMap.keySet()) {
            System.debug(key);
            System.debug(fieldNameToDetailsMap.get(key));
        }

        return fieldNameToDetailsMap;
    }

    private static String getRelationshipFieldName(String relationshipName) {
        String relationshipFieldName = '';
        //Verify if field contains the relationship
        if (relationshipName.endsWith('__r')) {
            relationshipFieldName = relationshipName.replace('__r', '__c');
        } else {
            relationshipFieldName = relationshipName + 'id';
        }
        return relationshipFieldName;
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