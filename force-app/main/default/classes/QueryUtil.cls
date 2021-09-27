public with sharing class QueryUtil {
    public static String getQueryString(string objectAPIName, set<String> setFields, string limitVal, string whereClause){
    	
    	String queryString = 'Select Id ';
    	String defaultClosingQuery = ' FROM ' + objectAPIName;
    	queryString += defaultClosingQuery;
    	
    	//Append fields passed in
    	if(setFields != null && !setFields.isEmpty()){
    		queryString = 'Select ';
    		for(string s: setFields){
    			queryString += s + ', ';
    		}
    		queryString = queryString.trim();
    		queryString = queryString.removeEnd(',');
	    	queryString += defaultClosingQuery;
	    	queryString += ' WHERE ' + whereClause;
	    	if(limitVal != null){
		    	//Add limit
		    	queryString += ' LIMIT ' + limitVal;
	    	}
    	}
    	return queryString;
    }
}