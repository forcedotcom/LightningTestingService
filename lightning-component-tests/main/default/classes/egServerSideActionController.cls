public class egServerSideActionController {
    @AuraEnabled
    public static account[] searchAccounts(String searchString) {
        searchString = '%'+searchString+'%';
        Account[] searchList = [select id, name from account where name LIKE :searchString];
        return searchList;
    }
}