public with sharing class egServerSideActionController {
    @AuraEnabled
    public static account[] searchAccounts(String searchString) {

        // Calling server may result in data dependent undertministic tests.
        // Therefore, its a best practice to mock server side calls. 
        // For demosntration purpose, this apex action just returns a static list.

        /*
        searchString = '%'+searchString+'%';
        Account[] searchList = [SELECT Id, Name FROM Account WHERE Name LIKE :searchString];
        */

        List<Account> accts = new List<Account>();
        accts.add(new Account(name=searchString + '-1'));
        accts.add(new Account(name=searchString + '-2'));
        accts.add(new Account(name=searchString + '-3'));
        return accts;
    }
}
