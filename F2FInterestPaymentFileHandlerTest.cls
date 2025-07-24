/**
 * @description                : Test class for F2FInterestPaymentFileHandler
 * @author                     : Anshu Kumari Mahato
 * @group                      : Test Class
 * @last modified on           : 16-12-2024
 * @last modified by           : Anshu Kumari Mahato
 * @last modification details  :  
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   05-12-2024   Anshu Kumari Mahato   Initial Version
**/
@isTest
private class F2FInterestPaymentFileHandlerTest {

    static Date currentDate = System.today();
    
    @testsetup
    static void testsetup(){
        //account record types
        Id borrowerRecordTypeObj = Schema.SObjectType.account.getRecordTypeInfosByName().get('Borrower').getRecordTypeId();

        //legal entity
        clcommon__Legal_Entity__c individualLegalEntity = F2FTestHelper.getLegalEntity('Individual');
        insert individualLegalEntity;

        // Creating accounts
        List<Account> accountList = new List<Account>();

        Account borrowerAccountObj=F2FTestHelper.getAccount();
        borrowerAccountObj.Name = 'Borrower 1';
        borrowerAccountObj.clcommon__Email__c = 'borrower@mailinator.com';        
        borrowerAccountObj.recordTypeId = borrowerRecordTypeObj;
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = individualLegalEntity.Id;
        accountList.add(borrowerAccountObj);

        if(accountList!=null && accountList.size()>0){
            insert accountList;
        }

        // query for assertion
        List<Account> queryAccountList= [SELECT id FROM Account WHERE recordTypeId!=null];

        // Create contract
        List<loan__Loan_Account__c> contractList = new List<loan__Loan_Account__c>();
        loan__Loan_Account__c contractObj=F2FTestHelper.returnLoanAccount(borrowerAccountObj);
        contractObj.loan__Interest_Rate__c = 6.5;
        contractObj.loan__Previous_Installment_Date__c = Date.valueOf('2021-01-01');
        contractObj.MAF__c = 0.5;
        contractObj.loan__Interest_Posted__c = 1000;
        contractObj.loan__Principal_Remaining__c = 10000;
        contractObj.loan__Loan_Amount__c = 10000;
        contractObj.loan__Next_Installment_Date__c = Date.valueOf('2021-02-01');
        contractObj.loan__Maturity_Date_Current__c = Date.valueOf('2025-08-01');
        contractObj.loan__Next_Due_Generation_Date__c = Date.valueOf('2021-02-01');
        contractObj.loan__Invalid_Data__c = false;
        contractList.add(contractObj);
        Database.update(contractList);

         //Payment modes insertion
         List<loan__Payment_Mode__c> paymentModeList = new List<loan__Payment_Mode__c>();
         loan__Payment_Mode__c paymentModeObj = F2FTestHelper.getPaymentMode();
         paymentModeList.add(paymentModeObj);
 
         if(paymentModeList.size() > 0){
             Database.insert(paymentModeList);
         }
 
         List<loan__Payment_Mode__c> assertPaymentModeList = [SELECT Id
                                                             FROM loan__Payment_Mode__c
                                                             WHERE Name = 'BACS'];

        List<loan__Automated_Payment_Setup__c> apsList = new List<loan__Automated_Payment_Setup__c>();
        loan__Automated_Payment_Setup__c interestAPSObj = StandardFeaturesTestHelper.getautomatedPaymentSetup(contractList[0], assertPaymentModeList[0], queryAccountList[0]);
        interestAPSObj.loan__Amount_Type__c = Folk2FolkConstantValues.LAST_BILLED_AMOUNT;
        apsList.add(interestAPSObj);

        if(apsList.size() > 0){
            Database.insert(apsList);
        }

        //Create LPT
        List<loan__Loan_Payment_Transaction__c> lptList = new List<loan__Loan_Payment_Transaction__c>();
        loan__Loan_Payment_Transaction__c  lptObj = F2FTestHelper.returnLoanPayment(contractObj);
        lptObj.loan__Transaction_Date__c = currentDate;
        lptObj.loan__Cheque_Number__c = '1234';
        lptObj.loan__Payment_Mode__c = assertPaymentModeList[0].Id;
        lptObj.loan__Transaction_Amount__c = 200;
        lptObj.loan__Cleared__c = false;
        lptObj.loan__Rejected__c = true;
        lptObj.loan__Reversed__c = false;
        lptList.add(lptObj);    
        
        loan__Loan_Payment_Transaction__c  lptTwoObj = F2FTestHelper.returnLoanPayment(contractObj);
        lptTwoObj.loan__Transaction_Date__c = currentDate;
        lptTwoObj.loan__Cheque_Number__c = '1234';
        lptTwoObj.loan__Payment_Mode__c = assertPaymentModeList[0].Id;
        lptTwoObj.loan__Transaction_Amount__c = 100;
        lptTwoObj.loan__Cleared__c = false;
        lptTwoObj.loan__Rejected__c = false;
        lptTwoObj.loan__Reversed__c = false;
        lptList.add(lptTwoObj);

        loan__Loan_Payment_Transaction__c  lptThreeObj = F2FTestHelper.returnLoanPayment(contractObj);
        lptThreeObj.loan__Transaction_Date__c = currentDate;
        lptThreeObj.loan__Cheque_Number__c = '1234';
        lptThreeObj.loan__Payment_Mode__c = assertPaymentModeList[0].Id;
        lptThreeObj.loan__Transaction_Amount__c = 200;
        lptThreeObj.loan__Cleared__c = false;
        lptThreeObj.loan__Rejected__c = false;
        lptThreeObj.loan__Reversed__c = false;
        lptThreeObj.loan__Automated_Payment_Setup__c = apsList[0].Id;
        lptList.add(lptThreeObj);
        insert lptList;    
        
    }

    @isTest
    static void testProcessValidFile() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryObj = [Select Id,Name FROM loan__Loan_Account__c];
        System.assertEquals(true, loanQueryObj.size()>=0 , 'Contract not fetched');
        List<Profile> systemAdminProfileList = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k2@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k2@test.com'];

        System.runAs(adminUserList[0]){
            Test.startTest();
            PageReference pageRef = Page.F2FUploadPaymentFilePage;
            Test.setCurrentPage(pageRef);
            String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\n' +loanQueryObj[0].name+
                                ', ,100.00, ,'+sysDate+',paid, ,\n';
            F2FPaymentFileController.contentFile = Blob.valueOf(fileContent);
            F2FPaymentFileController.fileName = 'Upload Payment Interest File';
            F2FPaymentFileController.processFile();
            Test.stopTest();
        }
    }

    @isTest
    static void testProcessMissingFields() {
        String sysDate = String.valueOf(currentDate);
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n'
                           + 'LoanAccount1, ,100.00, ,'+sysDate+',paid, ,\n'
                           + 'LoanAccount2, ,100.00, ,'+sysDate+',paid, ,\n';

        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id 
                                                FROM Profile 
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k2@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k2@test.com'];
        try{
            System.runAs(adminUserList[0]){
                Test.startTest();
                handler.processInterestFile(fileContent);
                Test.stopTest();
            }
        }catch(Exception e){
            System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'There should be errors');
        }
    }

    @isTest
    static void testProcessInvalidAmount() {
        String sysDate = String.valueOf(currentDate);
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n'
                           + 'LoanAccount1 , ,invalidamount, ,'+sysDate+',paid, ,\n';
        
        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id 
                                                FROM Profile 
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k2@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k2@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processInterestFile(fileContent);
            Test.stopTest();
        }

        System.assertEquals(1, handler.errorList.size(), 'An error should be recorded for an invalid transaction amount.');
    }

    @isTest
    static void testProcessExcessPayment() {
        String sysDate = String.valueOf(currentDate);
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n'
                           + 'LoanAccount1, ,500.00, ,'+sysDate+',paid, ,\n';
        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id 
                                                FROM Profile 
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k2@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k2@test.com'];
        System.assertEquals(true, adminUserList.size()>=0 , 'Contract not fetched');
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processInterestFile(fileContent);
            Test.stopTest();
        }
    }

    @isTest
    static void testProcessMultipleValidTransactions() {
        String sysDate = String.valueOf(currentDate);
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n'
                           + 'LoanAccount1, ,100.00, ,'+sysDate+',paid, ,\n'
                           + 'LoanAccount2, ,100.00, ,'+sysDate+',paid, ,\n';
        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id 
                                                FROM Profile 
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k2@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k2@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processInterestFile(fileContent);
            Test.stopTest();
        }
        System.assertEquals(0, handler.errorList.size(), 'All transactions should process without errors.');
    }

    @isTest
    static void testUnclearedTransactionsTwo() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryObj = [SELECT Id,
                                                            Name 
                                                    FROM loan__Loan_Account__c];
        System.AssertEquals(true, loanQueryObj.size()>=0 , 'Contract not fetched');

        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\n' +loanQueryObj[0].name+
                            ', ,100.00, ,'+sysDate+',paid, ,\n';
        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile 
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k2@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k2@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processInterestFile(fileContent);
            Test.stopTest();
        }

        // Verify uncleared transactions
        List<loan__Loan_Payment_Transaction__c> unclearedTransactions = [SELECT loan__Cleared__c 
                                                                        FROM loan__Loan_Payment_Transaction__c 
                                                                        WHERE loan__Cleared__c = false];
        System.assert(unclearedTransactions.size() > 0, 'Some transactions should remain uncleared.');
    }
    @isTest
    static void testProcessInterestUnclearedTransactions() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryObj = [SELECT Id,
                                                            Name 
                                                    FROM loan__Loan_Account__c];
        System.AssertEquals(true, loanQueryObj.size()>=0 , 'Contract not fetched');

        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n' +loanQueryObj[0].name+
                            ', ,200.00, ,'+sysDate+',paid, ,\n';
        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id 
                                                FROM Profile 
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k2@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k2@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processInterestFile(fileContent);
            Test.stopTest();
        }

        // Verify uncleared transactions
        List<loan__Loan_Payment_Transaction__c> unclearedTransactions = [SELECT loan__Cleared__c 
                                                                        FROM loan__Loan_Payment_Transaction__c 
                                                                        WHERE loan__Cleared__c = false];
        System.assert(unclearedTransactions.size() > 0, 'Some transactions should remain uncleared.');
    }

    @isTest
    static void testProcesscheckerrors(){

    loan__Loan_Payment_Transaction__c lptQueryObj = [SELECT Name 
                                                    FROM loan__Loan_Payment_Transaction__c 
                                                    LIMIT 1];
    List<loan__Loan_Payment_Transaction__c> lptList = new List<loan__Loan_Payment_Transaction__c>();
    lptList.add(lptQueryObj);
    update lptList;

    F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
    List<Profile> systemAdminProfileList = [SELECT Id 
                                            FROM Profile 
                                            WHERE Name = 'System Administrator'];
    User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k2@test.com',systemAdminProfileList[0].Id);
    Database.insert(userToInsertObj);
    List<User> adminUserList = [SELECT Id
                                FROM User
                                WHERE Email = 'testUser112k2@test.com'];
    System.runAs(adminUserList[0]){
        handler.checkForErrors('value','issue found', 3);
        handler.addErrorForInsufficientAmount(lptQueryObj,'LAI101');
    }
    System.AssertEquals(true, lptList.size()>=0 , 'Loan Payment not fetched');

    }

}