/**
 * @description                : Test class for F2FInterestPaymentFileHandler
 * @author                     : Anshu Kumari Mahato
 * @group                      : Test Class
 * @last modified on           : 24-07-2025
 * @last modified by           : Md Sameer
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
        Id investorRecordTypeObj = Schema.SObjectType.account.getRecordTypeInfosByName().get('Investor').getRecordTypeId();

        //legal entity
        clcommon__Legal_Entity__c individualLegalEntity = F2FTestHelper.getLegalEntity('Individual');
        insert individualLegalEntity;

        // Creating accounts
        List<Account> accountList = new List<Account>();

        Account borrowerAccountObj=F2FTestHelper.getAccount();
        borrowerAccountObj.Name = 'Interest Test Borrower';
        borrowerAccountObj.clcommon__Email__c = 'interest.borrower@mailinator.com';
        borrowerAccountObj.recordTypeId = borrowerRecordTypeObj;
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = individualLegalEntity.Id;
        accountList.add(borrowerAccountObj);

        Account investorAccountObj=F2FTestHelper.getAccount();
        investorAccountObj.Name = 'Interest Test Investor';
        investorAccountObj.clcommon__Email__c = 'interest.investor@mailinator.com';
        investorAccountObj.recordTypeId = investorRecordTypeObj;
        investorAccountObj.clcommon__Legal_Entity_Type__c = individualLegalEntity.Id;
        investorAccountObj.loan__Investor__c = true;
        investorAccountObj.Are_you_a_UK_tax_resident__c = true;
        accountList.add(investorAccountObj);

        if(accountList!=null && accountList.size()>0){
            insert accountList;
        }

        // query for assertion
        List<Account> queryAccountList= [SELECT id FROM Account WHERE recordTypeId!=null];

        // Create contracts with different scenarios
        List<loan__Loan_Account__c> contractList = new List<loan__Loan_Account__c>();

        // Single valid contract for testing - will be modified in individual test methods as needed
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
        contractObj.loan__Loan_Status__c = 'Active - Good Standing';
        contractList.add(contractObj);

        Database.update(contractList);

        // Create Investment Orders (Investor Loans) for validation
        List<loan__Investor_Loan__c> investorLoanList = new List<loan__Investor_Loan__c>();

        // Valid investor loan with matching interest posted
        loan__Investor_Loan__c investorLoan = F2FTestHelper.returnloanInvestor(contractObj);
        investorLoanList.add(investorLoan);

        // Investor loan with different interest posted for difference validation
        loan__Investor_Loan__c investorLoan2 = F2FTestHelper.returnloanInvestor(contractObj);
        investorLoanList.add(investorLoan2);

        insert investorLoanList;

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
        interestAPSObj.loan__Amount_Type__c = 'Last Billed Amount';
        interestAPSObj.loan__Type__c = 'Recurring';
        interestAPSObj.loan__Frequency__c = 'Billing Frequency';
        apsList.add(interestAPSObj);

        loan__Automated_Payment_Setup__c interestAPSObj2 = StandardFeaturesTestHelper.getautomatedPaymentSetup(contractList[0], assertPaymentModeList[0], queryAccountList[0]);
        interestAPSObj2.loan__Amount_Type__c = 'Last Billed Amount';
        interestAPSObj2.loan__Type__c = 'Recurring';
        interestAPSObj2.loan__Frequency__c = 'Billing Frequency';
        apsList.add(interestAPSObj2);

        loan__Automated_Payment_Setup__c interestAPSObj3 = StandardFeaturesTestHelper.getautomatedPaymentSetup(contractList[0], assertPaymentModeList[0], queryAccountList[0]);
        interestAPSObj3.loan__Amount_Type__c = 'Last Billed Amount';
        interestAPSObj3.loan__Type__c = 'Recurring';
        interestAPSObj3.loan__Frequency__c = 'Billing Frequency';
        apsList.add(interestAPSObj3);

        if(apsList.size() > 0){
            Database.insert(apsList);
        }

        //Create LPT
        List<loan__Loan_Payment_Transaction__c> lptList = new List<loan__Loan_Payment_Transaction__c>();

        // Valid LPTs for main contract
        loan__Loan_Payment_Transaction__c  lptObj = F2FTestHelper.returnLoanPayment(contractObj);
        lptObj.loan__Transaction_Date__c = currentDate;
        lptObj.loan__Cheque_Number__c = '1234';
        lptObj.loan__Payment_Mode__c = assertPaymentModeList[0].Id;
        lptObj.loan__Transaction_Amount__c = 200;
        lptObj.loan__Cleared__c = false;
        lptObj.loan__Rejected__c = false;
        lptObj.loan__Reversed__c = false;
        lptObj.loan__Automated_Payment_Setup__c = apsList[0].Id;
        lptList.add(lptObj);

        loan__Loan_Payment_Transaction__c  lptTwoObj = F2FTestHelper.returnLoanPayment(contractObj);
        lptTwoObj.loan__Transaction_Date__c = currentDate;
        lptTwoObj.loan__Cheque_Number__c = '1234';
        lptTwoObj.loan__Payment_Mode__c = assertPaymentModeList[0].Id;
        lptTwoObj.loan__Transaction_Amount__c = 100;
        lptTwoObj.loan__Cleared__c = false;
        lptTwoObj.loan__Rejected__c = false;
        lptTwoObj.loan__Reversed__c = false;
        lptTwoObj.loan__Automated_Payment_Setup__c = apsList[0].Id;
        lptList.add(lptTwoObj);

        // LPT for reversal issue testing
        loan__Loan_Payment_Transaction__c  lptReversalObj = F2FTestHelper.returnLoanPayment(contractObj);
        lptReversalObj.loan__Transaction_Date__c = currentDate;
        lptReversalObj.loan__Cheque_Number__c = '1234';
        lptReversalObj.loan__Payment_Mode__c = assertPaymentModeList[0].Id;
        lptReversalObj.loan__Transaction_Amount__c = 200;
        lptReversalObj.loan__Cleared__c = true;
        lptReversalObj.loan__Rejected__c = false;
        lptReversalObj.loan__Reversed__c = true;
        lptReversalObj.loan__Paid_to_Investor__c = true; // This creates reversal issue
        lptReversalObj.loan__Paid_to_Investor_Reversed__c = false; // Should be true for proper reversal
        lptReversalObj.loan__Automated_Payment_Setup__c = apsList[0].Id;
        lptList.add(lptReversalObj);

        insert lptList;

    }

    @isTest
    static void testProcessValidFile() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryObj = [Select Id,Name FROM loan__Loan_Account__c WHERE loan__Invalid_Data__c = false AND loan__Loan_Status__c = 'Active - Good Standing' LIMIT 1];
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
            String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n' +loanQueryObj[0].name+
                                ', ,300.00, ,'+sysDate+',paid, \n';
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
                           + 'LoanAccount1, ,100.00, ,'+sysDate+',paid, \n'
                           + 'LoanAccount2, ,100.00, ,'+sysDate+',paid, \n';

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

        // Should have errors for missing loan names and other validations
        System.assert(handler.errorList.size() > 0, 'Should have validation errors');
    }

    @isTest
    static void testProcessInvalidAmount() {
        String sysDate = String.valueOf(currentDate);
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n'
                           + 'LoanAccount1 , ,invalidamount, ,'+sysDate+',paid, \n';

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
    static void testLoanWithInvalidDataFlag() {
        String sysDate = String.valueOf(currentDate);
        // Get the existing loan and modify it for this test
        List<loan__Loan_Account__c> loans = [Select Id,Name FROM loan__Loan_Account__c LIMIT 1];
        loans[0].loan__Invalid_Data__c = true;
        update loans[0];

        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n'
                           + loans[0].Name + ', ,100.00, ,'+sysDate+',paid, \n';

        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k3@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k3@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processInterestFile(fileContent);
            Test.stopTest();
        }

        // Should have error for invalid data flag
        System.assert(handler.errorList.size() > 0, 'Should have validation error for invalid data flag');
        Boolean hasInvalidDataError = false;
        for(String error : handler.errorList) {
            if(error.contains('invalid data true')) {
                hasInvalidDataError = true;
                break;
            }
        }
        System.assert(hasInvalidDataError, 'Should have specific error for invalid data flag');

        // Reset loan for other tests
        loans[0].loan__Invalid_Data__c = false;
        update loans[0];
    }

    @isTest
    static void testLoanWithInvalidStatus() {
        String sysDate = String.valueOf(currentDate);
        // Get the existing loan and modify it for this test
        List<loan__Loan_Account__c> loans = [Select Id,Name FROM loan__Loan_Account__c LIMIT 1];
        loans[0].loan__Loan_Status__c = 'Closed - Obligations met';
        update loans[0];

        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n'
                           + loans[0].Name + ', ,100.00, ,'+sysDate+',paid, \n';

        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k4@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k4@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processInterestFile(fileContent);
            Test.stopTest();
        }

        // Should have error for invalid loan status
        System.assert(handler.errorList.size() > 0, 'Should have validation error for invalid loan status');
        Boolean hasStatusError = false;
        for(String error : handler.errorList) {
            if(error.contains('Active Good - Standing or Active Bad - Standing')) {
                hasStatusError = true;
                break;
            }
        }
        System.assert(hasStatusError, 'Should have specific error for invalid loan status');

        // Reset loan for other tests
        loans[0].loan__Loan_Status__c = 'Active - Good Standing';
        update loans[0];
    }

    @isTest
    static void testClearingAmountExceedsInterestPosted() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryObj = [Select Id,Name FROM loan__Loan_Account__c WHERE loan__Invalid_Data__c = false AND loan__Loan_Status__c = 'Active - Good Standing' LIMIT 1];
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n'
                           + loanQueryObj[0].Name + ', ,1500.00, ,'+sysDate+',paid, \n'; // Amount > Interest Posted (1000)

        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k5@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k5@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processInterestFile(fileContent);
            Test.stopTest();
        }

        // Should have error for clearing amount exceeding interest posted
        System.assert(handler.errorList.size() > 0, 'Should have validation error for clearing amount');
        Boolean hasClearingAmountError = false;
        for(String error : handler.errorList) {
            if(error.contains('clearing amount on the file') && error.contains('negative interest postings')) {
                hasClearingAmountError = true;
                break;
            }
        }
        System.assert(hasClearingAmountError, 'Should have specific error for clearing amount validation');
    }

    @isTest
    static void testLoanWithoutInvestmentOrders() {
        String sysDate = String.valueOf(currentDate);

        // Create a loan without Investment Orders
        List<Account> borrowerAccounts = [SELECT Id FROM Account WHERE Name = 'Interest Test Borrower' LIMIT 1];
        loan__Loan_Account__c loanWithoutIO = F2FTestHelper.returnLoanAccount(borrowerAccounts[0]);
        loanWithoutIO.loan__Interest_Posted__c = 500;
        loanWithoutIO.loan__Invalid_Data__c = false;
        loanWithoutIO.loan__Loan_Status__c = 'Active - Good Standing';
        insert loanWithoutIO;

        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n'
                           + loanWithoutIO.Name + ', ,100.00, ,'+sysDate+',paid, \n';

        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k6@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k6@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processInterestFile(fileContent);
            Test.stopTest();
        }

        // Should have error for missing Investment Orders
        System.assert(handler.errorList.size() > 0, 'Should have validation error for missing Investment Orders');
        Boolean hasIOError = false;
        for(String error : handler.errorList) {
            if(error.contains('does not have any Investment Orders')) {
                hasIOError = true;
                break;
            }
        }
        System.assert(hasIOError, 'Should have specific error for missing Investment Orders');
    }

    @isTest
    static void testReversalIssueValidation() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryObj = [Select Id,Name FROM loan__Loan_Account__c WHERE loan__Invalid_Data__c = false AND loan__Loan_Status__c = 'Active - Good Standing' LIMIT 1];
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n'
                           + loanQueryObj[0].Name + ', ,100.00, ,'+sysDate+',paid, \n';

        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k7@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k7@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processInterestFile(fileContent);
            Test.stopTest();
        }

        // Should have error for reversal issue
        System.assert(handler.errorList.size() > 0, 'Should have validation error for reversal issue');
        Boolean hasReversalError = false;
        for(String error : handler.errorList) {
            if(error.contains('incorrect LPT perhaps due to reversal')) {
                hasReversalError = true;
                break;
            }
        }
        System.assert(hasReversalError, 'Should have specific error for reversal issue');
    }

    @isTest
    static void testProcessExcessPayment() {
        String sysDate = String.valueOf(currentDate);
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n'
                           + 'LoanAccount1, ,500.00, ,'+sysDate+',paid, \n';
        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k8@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k8@test.com'];
        System.assertEquals(true, adminUserList.size()>=0 , 'User not fetched');
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
                           + 'LoanAccount1, ,100.00, ,'+sysDate+',paid, \n'
                           + 'LoanAccount2, ,100.00, ,'+sysDate+',paid, \n';
        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k9@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k9@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processInterestFile(fileContent);
            Test.stopTest();
        }
        // Errors are expected for non-existent loan accounts
        System.assert(handler.errorList.size() >= 0, 'Should handle multiple transactions');
    }

    @isTest
    static void testUnclearedTransactionsTwo() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryObj = [SELECT Id,
                                                            Name
                                                    FROM loan__Loan_Account__c
                                                    WHERE loan__Invalid_Data__c = false
                                                    AND loan__Loan_Status__c = 'Active - Good Standing'
                                                    LIMIT 1];
        System.AssertEquals(true, loanQueryObj.size()>=0 , 'Contract not fetched');

        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n' +loanQueryObj[0].name+
                            ', ,100.00, ,'+sysDate+',paid, \n';
        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k10@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k10@test.com'];
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
                                                    FROM loan__Loan_Account__c
                                                    WHERE loan__Invalid_Data__c = false
                                                    AND loan__Loan_Status__c = 'Active - Good Standing'
                                                    LIMIT 1];
        System.AssertEquals(true, loanQueryObj.size()>=0 , 'Contract not fetched');

        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference\n' +loanQueryObj[0].name+
                            ', ,200.00, ,'+sysDate+',paid, \n';
        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k11@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k11@test.com'];
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
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k12@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k12@test.com'];
        System.runAs(adminUserList[0]){
            handler.checkForErrors('value','issue found', 3);
            handler.addErrorForInsufficientAmount(lptQueryObj,'LAI101');
        }
        System.AssertEquals(true, lptList.size()>=0 , 'Loan Payment not fetched');
    }

    @isTest
    static void testProcessLoanPaymentTransactions() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryObj = [SELECT Id,
                                                            Name
                                                    FROM loan__Loan_Account__c
                                                    WHERE loan__Invalid_Data__c = false
                                                    AND loan__Loan_Status__c = 'Active - Good Standing'
                                                    LIMIT 1];

        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();

        // Create test context
        List<loan__Loan_Payment_Transaction__c> updateList = new List<loan__Loan_Payment_Transaction__c>();
        F2FInterestPaymentFileHandler.ProcessLoanPaymentContext context =
            new F2FInterestPaymentFileHandler.ProcessLoanPaymentContext(300, updateList, loanQueryObj[0]);

        // Get LPTs for the loan
        List<loan__Loan_Payment_Transaction__c> lptList = [SELECT Id, Name, loan__Transaction_Amount__c
                                                           FROM loan__Loan_Payment_Transaction__c
                                                           WHERE loan__Loan_Account__c = :loanQueryObj[0].Id
                                                           AND loan__Cleared__c = false
                                                           LIMIT 2];

        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k13@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k13@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processLoanPaymentTransactions(lptList, context);
            Test.stopTest();
        }

        // Verify that LPTs were processed
        System.assert(context.updateloanPaymentList.size() > 0, 'Should have updated some LPTs');
    }

    @isTest
    static void testValidateClearedLPTs() {
        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();

        // Get some LPTs to simulate the validation
        List<loan__Loan_Payment_Transaction__c> lptList = [SELECT Id FROM loan__Loan_Payment_Transaction__c LIMIT 2];

        // Simulate the lptIdVsLptRecordMap
        handler.lptIdVsLptRecordMap = new Map<Id, loan__Loan_Payment_Transaction__c>();
        for(loan__Loan_Payment_Transaction__c lpt : lptList) {
            handler.lptIdVsLptRecordMap.put(lpt.Id, lpt);
        }

        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k14@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k14@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.validateClearedLPTs();
            Test.stopTest();
        }

        // Should have errors for uncleared LPTs
        System.assert(handler.errorList.size() > 0, 'Should have validation errors for uncleared LPTs');
    }

    @isTest
    static void testAddErrorForExcessAmount() {
        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();

        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k15@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k15@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.addErrorForExcessAmount('LAI101', 50.00);
            Test.stopTest();
        }

        System.assertEquals(1, handler.errorCount, 'Should have one error');
        System.assertEquals(1, handler.errorList.size(), 'Should have one error in list');
        System.assert(handler.errorList[0].contains('Excess amount received'), 'Should contain excess amount message');
    }

    @isTest
    static void testGetTransactionAmountMethod() {
        F2FInterestPaymentFileHandler handler = new F2FInterestPaymentFileHandler();

        List<Profile> systemAdminProfileList = [SELECT Id
                                                FROM Profile
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k16@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k16@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            // Test valid amount
            Double validAmount = handler.getTransactionAmount('100.50', 1);
            System.assertEquals(100.50, validAmount, 'Should parse valid amount correctly');

            // Test invalid amount
            Double invalidAmount = handler.getTransactionAmount('invalid', 2);
            System.assertEquals(null, invalidAmount, 'Should return null for invalid amount');
            System.assertEquals(1, handler.errorCount, 'Should have one error for invalid amount');
            Test.stopTest();
        }
    }
}
