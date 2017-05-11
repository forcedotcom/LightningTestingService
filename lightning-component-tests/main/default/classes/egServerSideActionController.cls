public class egServerSideActionController {
    @AuraEnabled
    public static account[] searchAccounts(String searchString) {

        // This controller is totally insecure. It's a stub for use with testing only

        searchString = '%'+searchString+'%';
        Account[] searchList = [SELECT Id, Name FROM Account WHERE Name LIKE :searchString];
        return searchList;
    }
}
