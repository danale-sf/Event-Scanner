public with sharing class EventInvitationController {
     //Wrapper class to hold the Contacts
     public class wContact{
        public Contact c{get;set;}
        public Boolean isSelected{get;set;}
      
        public wContact(Contact c){
          this.c = c;
          isSelected = false;
        }//end constructor
    }//end inner class
    
    public Event newEvent{get;set;}
    public String subject{get;set;}
    public Boolean showEventPanel{get;set;}
    public Boolean showContactPanel{get;set;}
    public Boolean showConfirmationPanel{get;set;}
    public Integer invitationCount{get;set;}
    List<Id> insertedPresenceIds = new List<Id>();
    List<Presence__c> presencesForCurrentEvent = new List<Presence__c>();
    List<Contact> contactsFromController = new List<Contact>();
    Set<Contact> contactsSelected{get;set;}
    Integer currentPageNum = 1;
    Boolean paginationInvoked = false;
    
   String oldFilterId=''; 
   
   //Holds the contacts that are displayed in a single screen
   public List<wContact> contactsToDisplay{
        get{
            if(contactsToDisplay.isEmpty()
                    || (stndSetCtrller.getFilterId() != oldFilterId)
                    || paginationInvoked){
                    oldFilterId = stndSetCtrller.getFilterId();
                    System.debug('stndSetCtrller.getFilterId()---'+stndSetCtrller.getFilterId());
                    System.debug('oldFilterId---'+oldFilterId);     
                    System.debug('contactsSelected in getter---'+contactsSelected);
              //contactsToDisplay = new List<wContact>();
              contactsToDisplay.clear();
              contactsFromController = (List<Contact>)stndSetCtrller.getRecords();
              //stndSetCtrller.setpageNumber(currentPageNum);
              for(Contact c: contactsFromController){
                 wContact wc = new wContact(c);
                 contactsToDisplay.add(wc);
                 if(contactsSelected.contains(c))
                    wc.isSelected = true;
               }
               System.debug('contacts to display in getter---'+contactsToDisplay);
               System.debug('filter id in getter---'+stndSetCtrller.getFilterId()); 
            }//end check on contactsToDisplay size
            
           return contactsToDisplay;
        }
        set;}
    
    //Holds reference to the StandardSetController    
    ApexPages.StandardSetController stndSetCtrller;
    
    public EventInvitationController(ApexPages.StandardSetController controller) {
    	if(!Test.isRunningTest())
       		controller.addFields(new List<String>{'Id','Name','Email','Title','Phone'});
       stndSetCtrller = controller;
       stndSetCtrller.setPageSize(10);
       newEvent = new Event();
       showEventPanel = true;
       showContactPanel = false;
       showConfirmationPanel = false;
       contactsToDisplay = new List<wContact>();
       contactsSelected = new Set<Contact>();
       oldFilterId = controller.getFilterId();
    }//end Constructor
    
    //Cancel creating an event
    public PageReference cancelEvent() {
        return null;
    }
    
    //Saves the Event
    public void saveEvent(){
        System.debug('newevent---'+newEvent);
        try{
        	insert newEvent;
        }catch(Exception e){
        	System.debug('exc---'+e.getMessage());
        }
        showEventPanel = false;
        showConfirmationPanel = false;
        showContactPanel = true;
    }//end saveEvent()
    
    //Processes the invitation to the selected Contacts
    public void processInvitation(){
      persistSelectedRecords(contactsToDisplay);
      
      Event evt = [select Event_Id__c from Event where id =: newEvent.id];
      createPresenceRecords(contactsSelected, evt.Event_Id__c);
      sendInvitations(contactsSelected);
      updatePresenceStatusAndQRCode();
      showConfirmationPanel = true;
      showEventPanel = false;
      showContactPanel = false;
    }//end processInvitation()
    
    //Creates Presence records for all the Contacts selected 
    public void createPresenceRecords(Set<Contact>contactsSelected, String eventId){
        List<Presence__c> presences = new List<Presence__c>();
        //Loop through all the selected Contacts and create one presence record for each, using the eventId
        for(Contact c: contactsSelected){
                Presence__c p = new Presence__c(Contact__c = c.id, Event_Id__c = eventId  );
                presences.add(p);
        }
        List<Database.Saveresult> presenceInsertResults;
        try{
            presenceInsertResults = Database.insert(presences,true);
        }catch(Exception e){
                System.debug('exception in inserting presences---'+e.getMessage());
        }
        for(Database.SaveResult sr : presenceInsertResults){
        	if(sr.isSuccess())
        		insertedPresenceIds.add(sr.getId());
        }
    }//end createPresenceRecords()
    
    //Sends invitations to the selected contacts using a set Email template.
    //Hard-coded for this demo.
    public void sendInvitations(Set<Contact> contactsSelected){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                for(Presence__c p:[select id,Contact__c from presence__c where contact__c in:contactsSelected and id in:insertedPresenceIds]){
                        presencesForCurrentEvent.add(p);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId('00XE0000000Ys2Y');
                email.setTargetObjectId(p.Contact__c);
                email.setWhatId(p.id);
                email.setSaveAsActivity(true);
                emailList.add(email);    
                }
                
                if (emailList != null && emailList.size() > 0) {
                    try {
                        Messaging.sendEmail(emailList);
                    }catch (Exception e) {
                        System.debug('ERROR - Sending email confirmation - ' + e.getMessage());
                    }                  
                }
                        
    }//end sendInvitations()
    
    //Updates the Presence records with QR Code and also the status to 'Invited'
    public void updatePresenceStatusAndQRCode(){
       //List<Presence__c> presencesToUpdate = new List<Presence__c>();
       for(Presence__c p: presencesForCurrentEvent){
          p.qr_code_image__c ='<img src="http://chart.apis.google.com/chart?cht=qr&chl='+p.id+'&chs=256x256"></img>';
          p.Status__c = 'Invited';
       }
       invitationCount = presencesForCurrentEvent.size();
       List<Database.Saveresult> presenceUpdateResults;
       try{
        presenceUpdateResults = Database.update(presencesForCurrentEvent,true);
       }catch(Exception e){
        System.debug('exception in updating presences---'+e.getMessage());
       }
    }//end updatePresenceStatusAndQRCode()
    
    //Stores the selected Contacts in all the pages in a single Set, so as to persist the selection between pages
    public void persistSelectedRecords(List<wContact> contactsToDisplay){
        System.debug('contactsToDisplay in persist method---'+contactsToDisplay);
        for(wContact wc: contactsToDisplay){
                if(wc.isSelected
                        && !contactsSelected.contains(wc.c)){
                        contactsSelected.add(wc.c);
                }       
        }
        System.debug('contactsSelected in persist method---'+contactsSelected);
    }//end persistSelectedRecords()
    
    //Takes to a previous page in the standardSetController
    public void previousPage(){
      paginationInvoked = true;
      if(getHasPreviousPage()){
        //as the previous page exists, go back one page num n requery using the setcontroller and set the page num to this
        currentPageNum -= 1;
        System.debug('currentPageNum in previous--'+currentPageNum);
        
        persistSelectedRecords(contactsToDisplay);
        stndSetCtrller.setpageNumber(currentPageNum);
        //stndSetCtrller.previous();
      }//end outer if
    }//end previousPage()
    
    //Takes to the next page in the StandardSetController
    public void nextPage(){
      paginationInvoked = true;
      if(gethasNextPage()){
        currentPageNum += 1;
        System.debug('currentPageNum in nextpage--'+currentPageNum);
        
        persistSelectedRecords(contactsToDisplay);
        stndSetCtrller.setpageNumber(currentPageNum);
        //stndSetCtrller.next();
       }//end outer if
    }//end nextPage()
    
    //Checks if previous page exists in the StandardSetController
    public Boolean getHasPreviousPage(){
      if((stndSetCtrller != null) &&(stndSetCtrller.getHasPrevious()))
        return true;
      else
        return false;
    }
    
    //Checks if next page exists in the StandardSetController
    public Boolean getHasNextPage(){
      if((stndSetCtrller != null) &&(stndSetCtrller.getHasNext()))
        return true;
      else
        return false;
    }
  
}