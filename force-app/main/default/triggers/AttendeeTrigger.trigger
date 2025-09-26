/**
 * @description Trigger on the Attendee__c object to handle pre-save validation.
 * It calls the AttendeeService class to check event capacity.
 */
trigger AttendeeTrigger on Attendee__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        AttendeeService.checkEventCapacity(Trigger.new);
    }
}