/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EventInvitationControllerTest {

    static testMethod void testAll() {
    	Contact c = new Contact(firstName = 'test', lastName = 'contact email',email='test@test.com');
    	insert c;
    	
    	List<Contact> allContacts = [select id,name,email,phone,title,mobilephone from Contact limit 100];
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(allContacts);
		EventInvitationController ext = new EventInvitationController(setcon);
		ext.cancelEvent();
		ext.getHasNextPage();
		ext.getHasPreviousPage();
		ext.nextPage();
		ext.previousPage();
		ext.newEvent = new Event(subject = 'Email',startDateTime = System.now(), endDateTime=System.now().addhours(4),WhoId = allContacts.get(0).id );
		ext.saveEvent();
		for(EventInvitationController.wContact wc: ext.contactsToDisplay){
			wc.isSelected = true;
		}
		ext.persistSelectedRecords(ext.contactsToDisplay);
		ext.processInvitation();
		//ext.
    }
}