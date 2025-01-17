trigger OpportunityTrigger on Opportunity (before update, before delete) {

    /*
    * Question 5
    * Opportunity Trigger
    * When an opportunity is updated validate that the amount is greater than 5000.
    * Error Message: 'Opportunity amount must be greater than 5000'
    * Trigger should only fire on update.
    */
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Opportunity opp : Trigger.new) {
            if (opp.Amount < 5000) {
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }

    /*
    * Question 7
    * Opportunity Trigger
    * When an opportunity is updated set the primary contact on the opportunity to the contact on the same account with the title of 'CEO'.
    * Trigger should only fire on update.
    */
        // Obtain set of account ids from the Opportunity records.
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.new) {
            if (opp.Primary_Contact__c == null && opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

		// Query the Contacts with Title = 'CEO' and put into a Map.  Loop through Opportunities and set Primary_Contact__c to the contact with Title = 'CEO'.
        Map<Id, Contact> contactMap = new Map<Id,Contact>();
		for (Contact con : [SELECT Id, AccountId FROM Contact WHERE Title = 'CEO' AND AccountId IN :accountIds]) {
			contactMap.put(con.AccountId, con);

            // Loop through the opportunities and set Primary_Contact__c based on the AccountId in the contactMap.
            for (Opportunity opp : Trigger.new) {
                if (contactMap.containskey(opp.AccountId)) {
                    opp.Primary_Contact__c = contactMap.get(opp.AccountId).Id;
                }
            }
        }
    }


    /*
     * Question 6
	 * Opportunity Trigger
	 * When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
	 * Error Message: 'Cannot delete closed opportunity for a banking account that is won'
	 * Trigger should only fire on delete.
	 */
    if (Trigger.isBefore && Trigger.isDelete) {
        // Obtain Set of account ids from the opportunties that are Closed Won.
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity oldOpp : Trigger.old) {
            if (oldOpp.StageName == 'Closed Won') {
                accountIds.add(oldOpp.AccountId);
            }
        }

        // Query the Accounts using set of accountIds above to put into Map where Key-Account Id and Value-Account Industry.
        Map<Id, Account> accountMap = new Map<Id,Account>([SELECT Id, Industry FROM Account WHERE Id IN :accountIds]);

        // Loop through the 'old' opportunities and throw error if Opportunity StageName is 'Closed Won' and Account Industry is 'Banking'.
        for (Opportunity oldOpp : Trigger.old) {
            if (oldOpp.StageName == 'Closed Won') {
                Account relatedAccount = accountMap.get(oldOpp.AccountId);
                if (relatedAccount.Industry == 'Banking') {
                    oldOpp.addError('Cannot delete closed opportunity for a banking account that is won');
                }
            }
        }
    }
}