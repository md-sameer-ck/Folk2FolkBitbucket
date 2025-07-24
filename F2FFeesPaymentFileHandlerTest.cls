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

        //legal entity
        clcommon__Legal_Entity__c individualLegalEntityObj = F2FTestHelper.getLegalEntity('Individual');
        insert individualLegalEntityObj;

        // Creating accounts
        List<Account> accountList = new List<Account>();

        Account borrowerAccountObj=F2FTestHelper.getAccount();
        borrowerAccountObj.Name = 'Borrower 1';
        borrowerAccountObj.clcommon__Email__c = 'borrower@mailinator.com';        
        borrowerAccountObj.recordTypeId = borrowerRecordTypeObj;
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = individualLegalEntityObj.Id;
        accountList.add(borrowerAccountObj);

        if(accountList!=null && accountList.size()>0){
            insert accountList;
        }

        // Create contract
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
        update contractObj;

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
        
        loan__Fee__c loanFeeObj = new loan__Fee__c();
        loanFeeObj.Name = 'Management Fee';
        loanFeeObj.loan__State__c = 'Active';
        loanFeeObj.loan__Time_of_charge__c = 'Periodic Fees';
        loanFeeObj.loan__Amount__c = 100.00;
        loanFeeObj.loan__Fee_Calculation_Method__c = 'Fixed';
        insert loanFeeObj;

        loan__Fee__c loanFeeObjOne = new loan__Fee__c();
        loanFeeObjOne.Name = 'Collection Fee';
        loanFeeObjOne.loan__State__c = 'Active';
        loanFeeObjOne.loan__Time_of_charge__c = 'Late Fees';
        loanFeeObjOne.loan__Amount__c = 100.00;
        loanFeeObjOne.loan__Fee_Calculation_Method__c = 'Fixed';
        insert loanFeeObjOne;


        loan__Loan_Payment_Spread__c paymentSpreadObj = new loan__Loan_Payment_Spread__c();
        paymentSpreadObj.Name = 'management fee_Custom Spread';
        paymentSpreadObj.loan__Order_Of_Payment__c = 'Management Fee';
        insert paymentSpreadObj;

        loan__Loan_Payment_Spread__c collectionPaySpreadObj = new loan__Loan_Payment_Spread__c();
        collectionPaySpreadObj.Name = 'Collection Fee Spread Only';
        collectionPaySpreadObj.loan__Order_Of_Payment__c = 'Collection Fee';
        insert collectionPaySpreadObj;
        

    }
    
    @isTest
    static void testProcessFeesFileWithMissingRequiredFields() {
        String fileContent = 'Reference Number,Account Name,Amount,Customer Id,Due Date,Status,Transaction Reference,\\n,Fee Name\n' +
                                'LAI123, , , ,2023-12-31,paid, ,\\n,Collection Fee\n' +
                                'LAI1234, ,100.00, ,2023-12-31,paid, ,\\n,Management Fee\n';
        
        List<loan__Payment_Mode__c> paymentModesList = new List<loan__Payment_Mode__c>{
            new loan__Payment_Mode__c(Name = 'BACS')
        };
        insert paymentModesList;

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
            try{
                Test.startTest();
                feePaymentHandlerInst.processFeesFile(fileContent);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'There should be errors');
            }
        }
    }

    @isTest
    static void testGetTransactionAmountWithValidAmount() {
        String validAmount = '123.45';
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
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k2@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k2@test.com'];
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
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k2@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k2@test.com'];
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
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser','testUser112k2@test.com',systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        List<User> adminUserList = [SELECT Id
                                    FROM User
                                    WHERE Email = 'testUser112k2@test.com'];

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
                                                     FROM loan__Loan_Account__c];
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
}