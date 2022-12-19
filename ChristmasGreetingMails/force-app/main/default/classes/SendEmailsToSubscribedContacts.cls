/**
 * @description       : This apex class is used to send mails to call subscribed contacts in batches
 * @author            : Concret.io
 * @group             : 
 * @last modified on  : 12-19-2022
 * @last modified by  : Concret.io
**/
public class  SendEmailsToSubscribedContacts implements Database.Batchable<sObject>,Database.Stateful{
    List<Contact> contactList=new List<Contact>();
    String fileContent='';
    String name='';
    public Process_Log__c newProcessLog=new Process_Log__c();
    public ContentVersion cVersion= new ContentVersion();
    public integer recordsProcessed=0;
    
    public SendEmailsToSubscribedContacts(Set<Id> AccountIds)
    {
        List<Contact> conList=[SELECT ID,Name,Account.Name,Email,Subscribed__c FROM Contact WHERE AccountId IN:AccountIds and Subscribed__c=true];
        newProcessLog.Total_Records__c=conList.size();
        contactList=conList;
    }
    
    public List<contact> start(Database.BatchableContext BC){
        return contactList;
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> conList){
        List<Messaging.SingleEmailMessage> emailList=new List<Messaging.SingleEmailMessage>();
        System.debug('execute');
        System.debug(conList);
        cVersion.Title='ContactEmailFile';
        cVersion.PathOnClient=cVersion.Title+'.txt';
        
        try{
            for(Contact con:conList)
            {
                if(name==con.Account.Name)
                {
                    fileContent+=con.Name+' added to email list, Subscribed '+con.Subscribed__c+'\n';
                }
                else
                {
                    fileContent+=con.Account.Name+'\n'+con.Name+' added to email list, Subscribed '+con.Subscribed__c+'\n';
                    name=con.Account.Name;
                }
                Messaging.SingleEmailMessage emailMsg=new Messaging.SingleEmailMessage();
                List<String> toAddress=new List<String>{con.Email};
                emailMsg.setToAddresses(toAddress);
                String emailsubject='Greetings!!!';
                emailMsg.setSubject(emailsubject);
                String disName='Karan kumar dua';
                emailMsg.setSenderDisplayName(disName);
                String content='Hi '+con.Name+',<br/>'+
                con.Account.Name+' Wishing you a Christmas thats merry and bright!';
                emailMsg.setHtmlBody(content);
                emailList.add(EmailMsg);
                recordsProcessed+=1;
            }
            cVersion.VersionData=Blob.valueOf(fileContent);
            newProcessLog.Records_Processed__c=recordsProcessed;
            UPSERT newProcessLog;
            Messaging.sendEmail(emailList);
        } 
        catch(System.Exception e)
        {
            System.debug(e.getMessage());
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
        Id logRecordId=[SELECT Id FROM Process_Log__c order by LastModifiedDate DESC LIMIT 1].Id;
        cVersion.Process_Log__c=logRecordId;
        try
        {
            INSERT cVersion;
        }
        catch(Exception e)
        {
            System.debug(e);
        }
    }
}