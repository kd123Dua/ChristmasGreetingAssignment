/**
 * @description       : This is a test class to test whether emails apex jobs are executed successfully or not
 * @author            : Concret.io
 * @group             : 
 * @last modified on  : 12-19-2022
 * @last modified by  : Concret.io
**/
@isTest
private class SendChristmasGreetingsEmailBatchTest {
  @isTest
  private static void testSendChristmasGreetingsEmailBatch() {
    // Create test data
    Account account1 = new Account(Name = 'Test Account 1');
    insert account1;
    Contact contact1 = new Contact(FirstName = 'Test', LastName = 'Contact 1', Email = 'test1@example.com', AccountId = account1.Id, Subscribed__c = true);
    insert contact1;
    Contact contact2 = new Contact(FirstName = 'Test', LastName = 'Contact 2', Email = 'test2@example.com', AccountId = account1.Id, Subscribed__c = true);
    insert contact2;

    Account account2 = new Account(Name = 'Test Account 2');
    insert account2;
    Contact contact3 = new Contact(FirstName = 'Test', LastName = 'Contact 3', Email = 'test3@example.com', AccountId = account2.Id, Subscribed__c = true);
    insert contact3;

    Account account3 = new Account(Name = 'Test Account 3');
    insert account3;
    Contact contact4 = new Contact(FirstName = 'Test', LastName = 'Contact 4', Email = 'test4@example.com', AccountId = account3.Id, Subscribed__c = true);
    insert contact4;
    List<Account> acc=[SELECT Id FROM Account];
    Set<Id> accIds=new Set<Id>(); 
    for(Account a:acc)
    {
        accIds.add(a.Id);
    }
    
    Test.startTest();
    Id batchId=Database.executeBatch(new SendEmailsToSubscribedContacts(accIds));
    Test.stopTest();
   
    // Verify that the batch correctly updated the Process Log
    Process_Log__c processLog = [SELECT Records_Processed__c,Total_Records__c FROM Process_Log__c order by LastModifiedDate DESC LIMIT 1];
    System.assertEquals(4, processLog.Records_Processed__c);
    System.assertEquals(4,processLog.Total_Records__c);
   
    //verify that the batch correctly updated the contentversion
    ContentVersion cVersion = [SELECT FileType,Title FROM ContentVersion order by LastModifiedDate DESC LIMIT 1];
    System.assertEquals('TEXT',cVersion.FileType);
    System.assertEquals('ContactEmailFile',cversion.Title);
      
    
    //verification for job status
    AsyncApexJob job=[SELECT Id,Status,NumberOfErrors,JobItemsProcessed,TotaljobItems FROM AsyncApexJob WHERE Id=:batchId];
    System.assertEquals('Completed',job.Status);
    System.assertEquals(0,job.NumberOfErrors);
    System.assertEquals(1,job.TotalJobItems);
      
  }
}