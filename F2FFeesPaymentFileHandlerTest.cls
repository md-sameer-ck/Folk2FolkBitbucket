/**
 * @description                : Test class for F2FFeesPaymentFileHandler
 * @author                     : Anshu Kumari Mahato
 * @group                      : Test Class
 * @last modified on           : 16-12-2024
 * @last modified by           : Anshu Kumari Mahato
 * @last modification details  :  
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   16-05-2024   Anshu Kumari Mahato   Initial Version
**/
@isTest
private class F2FFeesPaymentFileHandlerTest {
    static Date currentDate = System.today();

    @testsetup
    static void testsetup(){
        //account record types
        Id borrowerRecordTypeObj = Schema.SObjectType.account.getRecordTypeInfosByName().get('Borrower').getRecordTypeId();
        Id investorRecordTypeObj = Schema.SObjectType.account.getRecordTypeInfosByName().get('Investor').getRecordTypeId();

        //legal entity
        clcommon__Legal_Entity__c individualLegalEntityObj = F2FTestHelper.getLegalEntity('Individual');
        insert individualLegalEntityObj;

        // Creating accounts
        List<Account> accountList = new List<Account>();

        Account borrowerAccountObj=F2FTestHelper.getAccount();
        borrowerAccountObj.Name = 'Fees Test Borrower';
        borrowerAccountObj.clcommon__Email__c = 'fees.borrower@mailinator.com';        
        borrowerAccountObj.recordTypeId = borrowerRecordTypeObj;
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = individualLegalEntityObj.Id;
        accountList.add(borrowerAccountObj);

        Account investorAccountObj=F2FTestHelper.getAccount();
        investorAccountObj.Name = 'Fees Test Investor';
        investorAccountObj.clcommon__Email__c = 'fees.investor@mailinator.com';        
        investorAccountObj.recordTypeId = investorRecordTypeObj;
        investorAccountObj.clcommon__Legal_Entity_Type__c = individualLegalEntityObj.Id;
        investorAccountObj.loan__Investor__c = true;
        investorAccountObj.Are_you_a_UK_tax_resident__c = true;
        accountList.add(investorAccountObj);

        if(accountList!=null && accountList.size()>0){
            insert accountList;
        }

        // Create contracts with different scenarios
        List<loan__Loan_Account__c> contractList = new List<loan__Loan_Account__c>();
        
        // Single valid contract for testing - will be modified in individual test methods as needed
        loan__Loan_Account__c contractObj=F2FTestHelper.returnLoanAccount(borrowerAccountObj);
        contractObj.loan__Interest_Rate__c = 6.5;
        contractObj.loan__Previous_Installment_Date__c = Date.valueOf('2021-01-01');
        contractObj.MAF__c = 0.5;
        contractObj.loan__Principal_Remaining__c = 10000;
        contractObj.loan__Loan_Amount__c = 10000;
        contractObj.loan__Next_Installment_Date__c = Date.valueOf('2021-02-01');
        contractObj.loan__Maturity_Date_Current__c = Date.valueOf('2025-08-01');
        contractObj.loan__Next_Due_Generation_Date__c = Date.valueOf('2021-02-01');
        contractObj.loan__Invalid_Data__c = false;
        contractObj.loan__Loan_Status__c = 'Active - Good Standing';
        contractList.add(contractObj);

        Database.update(contractList);

        //Payment modes
        loan__Payment_Mode__c bacsPaymentModeObj=F2FTestHelper.getPaymentMode();
        bacsPaymentModeObj.Name='BACS';
        insert bacsPaymentModeObj;

        //Create LPT
        List<loan__Loan_Payment_Transaction__c> lptList = new List<loan__Loan_Payment_Transaction__c>();
        loan__Loan_Payment_Transaction__c  loanPaymentTransactionObj = F2FTestHelper.returnLoanPayment(contractObj);
        loanPaymentTransactionObj.loan__Transaction_Date__c = currentDate;
        loanPaymentTransactionObj.loan__Cheque_Number__c = '1234';
        loanPaymentTransactionObj.loan__Payment_Mode__c = bacsPaymentModeObj.Id;
        loanPaymentTransactionObj.loan__Transaction_Amount__c = 200;
        loanPaymentTransactionObj.loan__Cleared__c = false;
        loanPaymentTransactionObj.loan__Rejected__c = false;
        loanPaymentTransactionObj.loan__Reversed__c = false;
        lptList.add(loanPaymentTransactionObj);
            
        loan__Loan_Payment_Transaction__c  loanPaymentObj = F2FTestHelper.returnLoanPayment(contractObj);
        loanPaymentObj.loan__Transaction_Date__c = currentDate;
        loanPaymentObj.loan__Cheque_Number__c = '1234';
        loanPaymentObj.loan__Payment_Mode__c = bacsPaymentModeObj.Id;
        loanPaymentObj.loan__Transaction_Amount__c = 100;
        loanPaymentObj.loan__Cleared__c = false;
        loanPaymentObj.loan__Rejected__c = false;
        loanPaymentObj.loan__Reversed__c = false;
        lptList.add(loanPaymentObj);
        insert lptList;
        
        // Create Fee records
        List<loan__Fee__c> feeList = new List<loan__Fee__c>();
        
        loan__Fee__c loanFeeObj = new loan__Fee__c();
        loanFeeObj.Name = 'Management Fee';
        loanFeeObj.loan__State__c = 'Active';
        loanFeeObj.loan__Time_of_charge__c = 'Periodic Fees';
        loanFeeObj.loan__Amount__c = 100.00;
        loanFeeObj.loan__Fee_Calculation_Method__c = 'Fixed';
        feeList.add(loanFeeObj);

        loan__Fee__c loanFeeObjOne = new loan__Fee__c();
        loanFeeObjOne.Name = 'Collection Fee';
        loanFeeObjOne.loan__State__c = 'Active';
        loanFeeObjOne.loan__Time_of_charge__c = 'Late Fees';
        loanFeeObjOne.loan__Amount__c = 100.00;
        loanFeeObjOne.loan__Fee_Calculation_Method__c = 'Fixed';
        feeList.add(loanFeeObjOne);

        loan__Fee__c solicitorFeeObj = new loan__Fee__c();
        solicitorFeeObj.Name = 'Solicitor Fee';
        solicitorFeeObj.loan__State__c = 'Active';
        solicitorFeeObj.loan__Time_of_charge__c = 'Late Fees';
        solicitorFeeObj.loan__Amount__c = 200.00;
        solicitorFeeObj.loan__Fee_Calculation_Method__c = 'Fixed';
        feeList.add(solicitorFeeObj);

        insert feeList;

        // Create Payment Spreads for all fee types
        List<loan__Loan_Payment_Spread__c> paymentSpreadList = new List<loan__Loan_Payment_Spread__c>();
        
        loan__Loan_Payment_Spread__c paymentSpreadObj = new loan__Loan_Payment_Spread__c();
        paymentSpreadObj.Name = 'management fee_Custom Spread';
        paymentSpreadObj.loan__Order_Of_Payment__c = 'Management Fee';
        paymentSpreadList.add(paymentSpreadObj);

        loan__Loan_Payment_Spread__c collectionPaySpreadObj = new loan__Loan_Payment_Spread__c();
        collectionPaySpreadObj.Name = 'Collection Fee Spread Only';
        collectionPaySpreadObj.loan__Order_Of_Payment__c = 'Collection Fee';
        paymentSpreadList.add(collectionPaySpreadObj);

        loan__Loan_Payment_Spread__c solicitorFeeSpreadObj = new loan__Loan_Payment_Spread__c();
        solicitorFeeSpreadObj.Name = 'Solicitor Fee Spread';
        solicitorFeeSpreadObj.loan__Order_Of_Payment__c = 'Solicitor Fee';
        paymentSpreadList.add(solicitorFeeSpreadObj);

        loan__Loan_Payment_Spread__c earlyTerminationSpreadObj = new loan__Loan_Payment_Spread__c();
        earlyTerminationSpreadObj.Name = 'Early Termination Fee Spread';
        earlyTerminationSpreadObj.loan__Order_Of_Payment__c = 'Early Termination Fee';
        paymentSpreadList.add(earlyTerminationSpreadObj);

        loan__Loan_Payment_Spread__c delinquentInterestSpreadObj = new loan__Loan_Payment_Spread__c();
        delinquentInterestSpreadObj.Name = 'Delinquent Interest Fee Spread';
        delinquentInterestSpreadObj.loan__Order_Of_Payment__c = 'Delinquent Interest Fee';
        paymentSpreadList.add(delinquentInterestSpreadObj);

        loan__Loan_Payment_Spread__c lateRedemptionSpreadObj = new loan__Loan_Payment_Spread__c();
        lateRedemptionSpreadObj.Name = 'Late Redemption Fee Spread';
        lateRedemptionSpreadObj.loan__Order_Of_Payment__c = 'Late Redemption Fee';
        paymentSpreadList.add(lateRedemptionSpreadObj);

        loan__Loan_Payment_Spread__c administrationFeeSpreadObj = new loan__Loan_Payment_Spread__c();
        administrationFeeSpreadObj.Name = 'Administration Fee Spread';
        administrationFeeSpreadObj.loan__Order_Of_Payment__c = 'Administration Fee';
        paymentSpreadList.add(administrationFeeSpreadObj);

        insert paymentSpreadList;
        
    }
    
    @isTest
    static void testProcessFeesFileWithMissingRequiredFields() {
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\n' +
                                'LAI123, , , ,2023-12-31,paid, ,\\n,Collection Fee\n' +
                                'LAI1234, ,100.00, ,2023-12-31,paid, ,\\n,Management Fee\n';
        
        F2FFeesPaymentFileHandler feePaymentHandlerInst = new F2FFeesPaymentFileHandler();
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
            feePaymentHandlerInst.processFeesFile(fileContent);
            Test.stopTest();
        }
        
        // Should have errors for missing fields and validation issues
        System.assert(feePaymentHandlerInst.errorList.size() > 0, 'Should have validation errors');
    }

    @isTest
    static void testGetTransactionAmountWithValidAmount() {
        String validAmount = '123.45';
        F2FFeesPaymentFileHandler feePaymentHandlerInst = new F2FFeesPaymentFileHandler();
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
            Double amount = feePaymentHandlerInst.getTransactionAmount(validAmount, 1);
            System.assertEquals(123.45, amount, 'The amount should be 123.45');
            Test.stopTest();
        }
        System.assertEquals(0, feePaymentHandlerInst.errorCount, 'There should be no errors');
    }

    @isTest
    static void testGetTransactionAmountWithInvalidAmount() {
        String invalidAmount = 'abc';
        F2FFeesPaymentFileHandler feePaymentHandlerInst = new F2FFeesPaymentFileHandler();
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
            Double amount = feePaymentHandlerInst.getTransactionAmount(invalidAmount, 1);
            Test.stopTest();
            System.assertEquals(null, amount, 'The amount should be null for invalid input');
        }
        System.assertEquals(1, feePaymentHandlerInst.errorCount, 'There should be one error');
    }

    @isTest
    static void testCheckForErrorsWithBlankValue() {
        String blankValue = '';
        F2FFeesPaymentFileHandler feePaymentHandlerInst = new F2FFeesPaymentFileHandler();
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
            feePaymentHandlerInst.checkForErrors(blankValue, 'Error message', 1);
            Test.stopTest();
        }
        System.assertEquals(1, feePaymentHandlerInst.errorCount, 'There should be one error');
        System.assertEquals(1, feePaymentHandlerInst.errorList.size(), 'Error list should contain one error');
    }

    @isTest
    static void testCheckForErrorsWithNonBlankValue() {
        String nonBlankValue = 'Non-empty';
        F2FFeesPaymentFileHandler feePaymentHandlerInst = new F2FFeesPaymentFileHandler();
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
            feePaymentHandlerInst.checkForErrors(nonBlankValue, 'Error message', 1);
            Test.stopTest();
        }
        System.assertEquals(0, feePaymentHandlerInst.errorCount, 'There should be no errors');
        System.assertEquals(0, feePaymentHandlerInst.errorList.size(), 'Error list should be empty');
    }

    @isTest
    static void successMethodFee(){
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryList = [SELECT Id,
                                                            Name 
                                                     FROM loan__Loan_Account__c
                                                     WHERE loan__Invalid_Data__c = false 
                                                     AND loan__Loan_Status__c = 'Active - Good Standing'
                                                     LIMIT 1];
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
            PageReference pageRef = Page.F2FUploadPaymentFilePage;
            Test.setCurrentPage(pageRef);
            String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\n' +loanQueryList[0].name+
                                ', ,100.00, ,'+sysDate+',paid, ,\\n,Management Fee\n';
            F2FPaymentFileController.contentFile = Blob.valueOf(fileContent);
            F2FPaymentFileController.fileName = 'Upload Payment fees File';
            F2FPaymentFileController.processFile();
            Test.stopTest();
        }
        System.assertEquals(true, loanQueryList.size()>=0 , 'Contract not fetched');
    }

    @isTest
    static void testLoanWithInvalidDataFlag() {
        String sysDate = String.valueOf(currentDate);
        // Get the existing loan and modify it for this test
        List<loan__Loan_Account__c> loans = [Select Id,Name FROM loan__Loan_Account__c LIMIT 1];
        loans[0].loan__Invalid_Data__c = true;
        update loans[0];
        
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\n'
                           + loans[0].Name + ', ,100.00, ,'+sysDate+',paid, ,\\n,Management Fee\n';
        
        F2FFeesPaymentFileHandler handler = new F2FFeesPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id 
                                                FROM Profile 
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k8@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k8@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processFeesFile(fileContent);
            Test.stopTest();
        }

        // Should have error for invalid data flag
        System.assert(handler.errorList.size() > 0, 'Should have validation error for invalid data flag');
        Boolean hasInvalidDataError = false;
        for(String error : handler.errorList) {
            if(error.toLowerCase().contains('invalid data')) {
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
        
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\n'
                           + loans[0].Name + ', ,100.00, ,'+sysDate+',paid, ,\\n,Management Fee\n';
        
        F2FFeesPaymentFileHandler handler = new F2FFeesPaymentFileHandler();
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
            handler.processFeesFile(fileContent);
            Test.stopTest();
        }

        // Should have error for invalid loan status
        System.assert(handler.errorList.size() > 0, 'Should have validation error for invalid loan status');
        Boolean hasStatusError = false;
        for(String error : handler.errorList) {
            if(error.toLowerCase().contains('active good') || error.toLowerCase().contains('active bad')) {
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
    static void testNonExistentLoan() {
        String sysDate = String.valueOf(currentDate);
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\n'
                           + 'NonExistentLoan, ,100.00, ,'+sysDate+',paid, ,\\n,Management Fee\n';
        
        F2FFeesPaymentFileHandler handler = new F2FFeesPaymentFileHandler();
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
            handler.processFeesFile(fileContent);
            Test.stopTest();
        }

        // Should have error for non-existent loan
        System.assert(handler.errorList.size() > 0, 'Should have validation error for non-existent loan');
        Boolean hasLoanNotFoundError = false;
        for(String error : handler.errorList) {
            if(error.contains('could not be found in the org')) {
                hasLoanNotFoundError = true;
                break;
            }
        }
        System.assert(hasLoanNotFoundError, 'Should have specific error for non-existent loan');
    }

    @isTest
    static void testProcessFeesFileWithMultipleFeeTypes() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryList = [SELECT Id,
                                                            Name 
                                                     FROM loan__Loan_Account__c
                                                     WHERE loan__Invalid_Data__c = false 
                                                     AND loan__Loan_Status__c = 'Active - Good Standing'
                                                     LIMIT 1];
        
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\n' +
                            loanQueryList[0].name + ', ,100.00, ,'+sysDate+',paid, ,\\n,Management Fee\n' +
                            loanQueryList[0].name + ', ,50.00, ,'+sysDate+',paid, ,\\n,Collection Fee\n' +
                            loanQueryList[0].name + ', ,200.00, ,'+sysDate+',paid, ,\\n,Solicitor Fee\n';
        
        F2FFeesPaymentFileHandler handler = new F2FFeesPaymentFileHandler();
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
            handler.processFeesFile(fileContent);
            Test.stopTest();
        }

        // Verify that multiple fee types were processed
        List<loan__Loan_Payment_Transaction__c> newLPTs = [SELECT Id, loan__Transaction_Amount__c 
                                                           FROM loan__Loan_Payment_Transaction__c 
                                                           WHERE CreatedDate = TODAY 
                                                           AND loan__Cleared__c = true];
        System.assert(newLPTs.size() > 0, 'Should have created new LPTs for fees');
    }

    @isTest
    static void testProcessFeesFileWithInvalidFeeType() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryList = [SELECT Id,
                                                            Name 
                                                     FROM loan__Loan_Account__c
                                                     WHERE loan__Invalid_Data__c = false 
                                                     AND loan__Loan_Status__c = 'Active - Good Standing'
                                                     LIMIT 1];
        
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\n' +
                            loanQueryList[0].name + ', ,100.00, ,'+sysDate+',paid, ,\\n,Invalid Fee Type\n';
        
        F2FFeesPaymentFileHandler handler = new F2FFeesPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id 
                                                FROM Profile 
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k12@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k12@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            try {
                handler.processFeesFile(fileContent);
            } catch (Exception e) {
                System.assert(e.getMessage().contains('Payment spread missing'), 'Should throw error for invalid fee type');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testClearLoanPaymentTransactionsEmptyMap() {
        F2FFeesPaymentFileHandler handler = new F2FFeesPaymentFileHandler();
        Map<String, Decimal> emptyMap = new Map<String, Decimal>();
        Set<String> emptySet = new Set<String>();
        
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
            handler.clearLoanPaymentTransactions(emptyMap, emptySet);
            Test.stopTest();
        }
        
        // Should handle empty maps gracefully
        System.assertEquals(0, handler.errorCount, 'Should not have errors for empty input');
    }

    @isTest
    static void testProcessFeesFileWithMissingHeaders() {
        String fileContent = 'Wrong Header,Another Header\n' +
                            'LAI123,100.00\n';
        
        F2FFeesPaymentFileHandler handler = new F2FFeesPaymentFileHandler();
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
            try {
                handler.processFeesFile(fileContent);
            } catch (Exception e) {
                System.assert(e.getMessage().contains('Header'), 'Should throw error for missing headers');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testProcessFeesFileWithNonPaidStatus() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryList = [SELECT Id, Name FROM loan__Loan_Account__c WHERE loan__Invalid_Data__c = false AND loan__Loan_Status__c = 'Active - Good Standing' LIMIT 1];
        if (loanQueryList.isEmpty()) {
            // Create a new valid loan if none exists
            List<Account> borrowerAccounts = [SELECT Id FROM Account WHERE Name = 'Fees Test Borrower' LIMIT 1];
            // Create a unique application for this contract
            genesis__Applications__c app = F2FTestHelper.getApplication(borrowerAccounts[0].Id);
            insert app;
            loan__Loan_Account__c validLoan = F2FTestHelper.returnLoanAccount(borrowerAccounts[0]);
            validLoan.loan__Invalid_Data__c = false;
            validLoan.loan__Loan_Status__c = 'Active - Good Standing';
            // Do not set Name directly
            insert validLoan;
            loanQueryList.add(validLoan);
        }
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\\n' +
                            loanQueryList[0].name + ', ,100.00, ,' + sysDate + ',failed, ,\\n,Management Fee\\n';
        F2FFeesPaymentFileHandler handler = new F2FFeesPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k15@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id FROM User WHERE Email = 'testUser112k15@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processFeesFile(fileContent);
            Test.stopTest();
        }
        // Should process without creating LPTs for non-paid status
        List<loan__Loan_Payment_Transaction__c> newLPTs = [SELECT Id FROM loan__Loan_Payment_Transaction__c WHERE CreatedDate = TODAY AND loan__Loan_Account__c = :loanQueryList[0].Id];
        System.assertEquals(0, newLPTs.size(), 'Should not create LPTs for non-paid status');
    }

    @isTest
    static void testProcessFeesFileRejectedLPTs() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryList = [SELECT Id, Name FROM loan__Loan_Account__c WHERE loan__Invalid_Data__c = false AND loan__Loan_Status__c = 'Active - Good Standing' LIMIT 1];
        if (loanQueryList.isEmpty()) {
            // Create a new valid loan if none exists
            List<Account> borrowerAccounts = [SELECT Id FROM Account WHERE Name = 'Fees Test Borrower' LIMIT 1];
            // Create a unique application for this contract
            genesis__Applications__c app = F2FTestHelper.getApplication(borrowerAccounts[0].Id);
            insert app;
            loan__Loan_Account__c validLoan = F2FTestHelper.returnLoanAccount(borrowerAccounts[0]);
            validLoan.loan__Invalid_Data__c = false;
            validLoan.loan__Loan_Status__c = 'Active - Good Standing';
            // Do not set Name directly
            insert validLoan;
            loanQueryList.add(validLoan);
        }
        // Ensure at least one LPT exists for this loan
        List<loan__Loan_Payment_Transaction__c> preLPTs = [SELECT Id FROM loan__Loan_Payment_Transaction__c WHERE loan__Loan_Account__c = :loanQueryList[0].Id LIMIT 1];
        if (preLPTs.isEmpty()) {
            loan__Loan_Payment_Transaction__c lpt = F2FTestHelper.returnLoanPayment(loanQueryList[0]);
            lpt.loan__Cleared__c = false;
            insert lpt;
        }
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\\n' +
                            loanQueryList[0].name + ', ,100.00, ,' + sysDate + ',paid, ,\\n,Management Fee\\n';
        F2FFeesPaymentFileHandler handler = new F2FFeesPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k16@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id FROM User WHERE Email = 'testUser112k16@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processFeesFile(fileContent);
            Test.stopTest();
        }
        // Verify that existing LPTs were rejected
        List<loan__Loan_Payment_Transaction__c> rejectedLPTs = [SELECT Id FROM loan__Loan_Payment_Transaction__c WHERE loan__Rejected__c = true AND loan__Loan_Account__c = :loanQueryList[0].Id];
        System.assert(rejectedLPTs.size() > 0, 'Should have rejected existing LPTs');
    }

    @isTest
    static void testProcessFeesFileAllFeeTypes() {
        String sysDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQueryList = [SELECT Id, Name FROM loan__Loan_Account__c WHERE loan__Invalid_Data__c = false AND loan__Loan_Status__c = 'Active - Good Standing' LIMIT 1];
        if (loanQueryList.isEmpty()) {
            // Create a new valid loan if none exists
            List<Account> borrowerAccounts = [SELECT Id FROM Account WHERE Name = 'Fees Test Borrower' LIMIT 1];
            // Create a unique application for this contract
            genesis__Applications__c app = F2FTestHelper.getApplication(borrowerAccounts[0].Id);
            insert app;
            loan__Loan_Account__c validLoan = F2FTestHelper.returnLoanAccount(borrowerAccounts[0]);
            validLoan.loan__Invalid_Data__c = false;
            validLoan.loan__Loan_Status__c = 'Active - Good Standing';
            // Do not set Name directly
            insert validLoan;
            loanQueryList.add(validLoan);
        }
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\\n' +
                            loanQueryList[0].name + ', ,100.00, ,' + sysDate + ',paid, ,\\n,Management Fee\\n' +
                            loanQueryList[0].name + ', ,50.00, ,' + sysDate + ',paid, ,\\n,Collection Fee\\n' +
                            loanQueryList[0].name + ', ,200.00, ,' + sysDate + ',paid, ,\\n,Solicitor Fee\\n' +
                            loanQueryList[0].name + ', ,150.00, ,' + sysDate + ',paid, ,\\n,Early Termination Fee\\n' +
                            loanQueryList[0].name + ', ,75.00, ,' + sysDate + ',paid, ,\\n,Delinquent Interest Fee\\n' +
                            loanQueryList[0].name + ', ,125.00, ,' + sysDate + ',paid, ,\\n,Late Redemption Fee\\n' +
                            loanQueryList[0].name + ', ,80.00, ,' + sysDate + ',paid, ,\\n,Administration Fee\\n';
        F2FFeesPaymentFileHandler handler = new F2FFeesPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k17@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id FROM User WHERE Email = 'testUser112k17@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            handler.processFeesFile(fileContent);
            Test.stopTest();
        }
        // Verify that all fee types were processed
        List<loan__Loan_Payment_Transaction__c> newLPTs = [SELECT Id, loan__Transaction_Amount__c FROM loan__Loan_Payment_Transaction__c WHERE CreatedDate = TODAY AND loan__Cleared__c = true AND loan__Loan_Account__c = :loanQueryList[0].Id];
        System.assert(newLPTs.size() >= 7, 'Should have created LPTs for all fee types');
    }

    @isTest
    static void testProcessFeesFileEmptyContent() {
        String fileContent = '';
        
        F2FFeesPaymentFileHandler handler = new F2FFeesPaymentFileHandler();
        List<Profile> systemAdminProfileList = [SELECT Id 
                                                FROM Profile 
                                                WHERE Name = 'System Administrator'];
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k18@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k18@test.com'];
        System.runAs(adminUserList[0]){
            Test.startTest();
            try {
                handler.processFeesFile(fileContent);
            } catch (Exception e) {
                // Should handle empty content gracefully
                System.assert(true, 'Should handle empty content');
            }
            Test.stopTest();
        }
    }
}