/**
 * @description This service class contains the business logic for the AttendeeTrigger.
 * It is responsible for checking the event capacity before a new attendee is created.
 */
public with sharing class AttendeeService {

    /**
     * @description Checks if a new attendee can be added to an event without exceeding the event's capacity.
     * @param newAttendees A list of new Attendee__c records from the trigger context.
     */
    public static void checkEventCapacity(List<Attendee__c> newAttendees) {
        // Collect all unique Event IDs from the new attendees to query for them.
        Set<Id> eventIds = new Set<Id>();
        for (Attendee__c attendee : newAttendees) {
            if (attendee.Event__c != null) {
                eventIds.add(attendee.Event__c);
            }
        }

        // Map to store Event data. We use a map to easily access records by their ID.
        Map<Id, Event__c> eventsWithAttendees = new Map<Id, Event__c>([
            SELECT Id, Max_Capacity__c, (SELECT Id FROM Attendees__r)
            FROM Event__c
            WHERE Id IN :eventIds
        ]);

        // Loop through the new attendees to check capacity.
        for (Attendee__c attendee : newAttendees) {
            Event__c relatedEvent = eventsWithAttendees.get(attendee.Event__c);
            
            // Check if a related event was found and if capacity is exceeded.
            if (relatedEvent != null) {
                Integer currentAttendees = relatedEvent.Attendees__r.size();
                Integer maxCapacity = (Integer)relatedEvent.Max_Capacity__c;
                
                if (currentAttendees >= maxCapacity) {
                    // Add an error to the attendee record to prevent it from being saved.
                    attendee.addError('This event has reached its maximum capacity of ' + maxCapacity + '.');
                }
            }
        }
    }
}