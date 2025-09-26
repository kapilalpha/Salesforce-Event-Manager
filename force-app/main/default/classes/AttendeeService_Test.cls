/**
 * @description Test class for AttendeeService.cls to ensure code coverage and functionality.
 */
@isTest
private class AttendeeService_Test {

    private static String getUniqueId() {
        return System.currentTimeMillis() + '' + Math.random();
    }

    /**
     * @description Tests the successful creation of attendees when the event capacity is not exceeded.
     */
    @isTest
    static void testEventCapacitySuccess() {
        // Create an Event with a capacity of 2. Make the name unique to avoid duplicates.
        String uniqueEventName = 'Test Event ' + getUniqueId();
        Event__c event1 = new Event__c(Name = uniqueEventName, Max_Capacity__c = 2, Date__c = Date.today());
        insert event1;

        // Create a list of attendees to insert.
        List<Attendee__c> newAttendees = new List<Attendee__c>();
        newAttendees.add(new Attendee__c(Name = 'Attendee One ' + getUniqueId(), Event__c = event1.Id, Email__c = 'test1@example.com'));
        newAttendees.add(new Attendee__c(Name = 'Attendee Two ' + getUniqueId(), Event__c = event1.Id, Email__c = 'test2@example.com'));

        // Use a try-catch block to handle the DML operation.
        Test.startTest();
        try {
            insert newAttendees;
        } catch (DmlException e) {
            System.assert(false, 'An unexpected DML exception occurred: ' + e.getMessage());
        }
        Test.stopTest();

        // Verify that the attendees were successfully inserted.
        System.assertEquals(2, [SELECT Id FROM Attendee__c WHERE Event__c = :event1.Id].size(), 'Attendees should have been successfully created.');
    }

    /**
     * @description Tests the failure scenario where adding a new attendee exceeds the event capacity.
     */
    @isTest
    static void testEventCapacityFailure() {
        // Create an Event with a capacity of 1. Make the name unique to avoid duplicates.
        String uniqueEventName = 'Test Event ' + getUniqueId();
        Event__c event2 = new Event__c(Name = uniqueEventName, Max_Capacity__c = 1, Date__c = Date.today());
        insert event2;

        // Create an initial attendee to fill the capacity.
        String uniqueAttendeeName = 'Initial Attendee ' + getUniqueId();
        Attendee__c initialAttendee = new Attendee__c(Name = uniqueAttendeeName, Event__c = event2.Id, Email__c = 'initial@example.com');
        insert initialAttendee;

        // We use Test.startTest() here to ensure the previous DML operation is committed.
        Test.startTest();

        // Create a list with one more attendee, which should exceed the capacity.
        List<Attendee__c> newAttendees = new List<Attendee__c>();
        newAttendees.add(new Attendee__c(Name = 'Attendee Three ' + getUniqueId(), Event__c = event2.Id, Email__c = 'test3@example.com'));

        // Use a try-catch block to test for the expected DML exception.
        Boolean dmlExceptionCaught = false;
        try {
            insert newAttendees;
        } catch (DmlException e) {
            dmlExceptionCaught = true;
            // Assert that the error message is the one we expect from the trigger.
            System.assert(e.getMessage().contains('This event has reached its maximum capacity of 1.'), 'DML exception message did not match expected error.');
        }

        Test.stopTest();

        // Verify that a DML exception was caught.
        System.assert(dmlExceptionCaught, 'A DML exception should have been caught, but was not.');
    }
}