/**
 * @description                : This is helper class for Folk2Folk test classes.
 * @author                     : Bhaskar Ray
 * @group                      : Test Helper Class
 * @last modified on           : 29-11-2023
 * @last modified by           : Md Sameer
 * @last modification details  :
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0                Bhaskar Ray Initial Version
 * 2.0   29-11-2023   Md Sameer   Added getautomatedPaymentSetup
**/
@isTest(SeeAllData=false)
public inherited sharing class StandardFeaturesTestHelper {
    /**
    * @description This is a method that returns the user after fillung up data.
    * @author Bhaskar Ray |
    * @param lastName
    * @param email
    * @param profileId
    * @return User
    **/
    public static User getUser(String lastName, String email, Id profileId){
        User userObj = new User();
        userObj.lastName = lastName;
        userObj.profileId = ProfileId;
        userObj.username = Email;
        userObj.email = Email;
        userObj.TimeZoneSidKey = 'GMT';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.EmailEncodingKey = 'UTF-8';
        userObj.LocaleSidKey = 'en_US';
        userObj.Alias = lastName;
        return userObj;
    }

    /**
    * @description This method creates an Automated Payment Setup record for the loan account passes.
    * @author Md Sameer | 29-11-2023
    * @param loanAccount has loan account for which APS is to created.
    * @param paymentMode has payment mode for which APS is to created, generally 'BACS'.
    * @param borrowerAccount has borrower account for which APS is to created.
    * @return loan__Automated_Payment_Setup__c returns APS to be attached to LPT.
    **/
    public static loan__Automated_Payment_Setup__c getautomatedPaymentSetup(loan__Loan_Account__c loanAccount,
            loan__Payment_Mode__c paymentMode, Account borrowerAccount){
        //Bank Account insertion
        List<loan__Bank_Account__c> bankAccListQuery = [SELECT Id
                                                            FROM loan__Bank_Account__c
                                                            WHERE loan__Account__c =: borrowerAccount.Id];
        List<loan__Bank_Account__c> bankAccList = new List<loan__Bank_Account__c>();
        loan__Bank_Account__c bankAcc = F2FTestHelper.getBankAccount(borrowerAccount);
        bankAccList.add(bankAcc);
        //if bank account already exists for the borrower
        if (bankAccListQuery.size() == 0){
            Database.insert(bankAccList);

            bankAccListQuery = [SELECT Id
                                        FROM loan__Bank_Account__c
                                        WHERE loan__Account__c =: borrowerAccount.Id];
            System.assertEquals(true, bankAccListQuery.size() == 1, 'Bank Account not inserted');
        }

        //create an Automated Payment Setup with general required fields
        loan__Automated_Payment_Setup__c automatedPaymentSetup = new loan__Automated_Payment_Setup__c();
        automatedPaymentSetup.loan__CL_Contract__c = loanAccount.Id;
        automatedPaymentSetup.loan__Payment_Mode__c = paymentMode.Id;
        automatedPaymentSetup.loan__Setup_Date__c = Date.valueOf('2021-01-01');
        automatedPaymentSetup.loan__Debit_Date__c = Date.valueOf('2021-02-01');
        automatedPaymentSetup.loan__Active__c = true;
        automatedPaymentSetup.loan__Type__c = Folk2FolkConstantValues.RECURRING;
        automatedPaymentSetup.loan__Frequency__c = Folk2FolkConstantValues.BILLING_FREQUENCY;
        automatedPaymentSetup.loan__Amount_Type__c = Folk2FolkConstantValues.LAST_BILLED_AMOUNT;
        automatedPaymentSetup.loan__Actual_Date__c = Date.valueOf('2021-02-01');
        automatedPaymentSetup.loan__Bank_Account__c = bankAccListQuery[0].Id;
        automatedPaymentSetup.loan__Amount_Type_Split_Factor__c = 1;
        automatedPaymentSetup.loan__Recurring_ACH_End_Date__c = Date.valueOf('2021-08-01');
        return automatedPaymentSetup;
    }
}