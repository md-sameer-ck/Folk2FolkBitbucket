/**
 * @description                : Test class for F2FPaymentFileHelper
 * @author                     : Md Sameer
 * @group                      : Test Class
 * @last modified on           : 25-07-2025
 * @last modified by           : Md Sameer
 * @last modification details  :
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   17-07-2025   Md Sameer            Initial Version
**/
@isTest
private class F2FPaymentFileHelperTest {

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
        borrowerAccountObj.Name = 'Helper Test Borrower';
        borrowerAccountObj.clcommon__Email__c = 'helper.borrower@mailinator.com';
        borrowerAccountObj.recordTypeId = borrowerRecordTypeObj;
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = individualLegalEntity.Id;
        accountList.add(borrowerAccountObj);

        Account investorAccountObj=F2FTestHelper.getAccount();
        investorAccountObj.Name = 'Helper Test Investor';
        investorAccountObj.clcommon__Email__c = 'helper.investor@mailinator.com';
        investorAccountObj.recordTypeId = investorRecordTypeObj;
        investorAccountObj.clcommon__Legal_Entity_Type__c = individualLegalEntity.Id;
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
        contractObj.loan__Interest_Posted__c = 1000;
        contractObj.loan__Principal_Remaining__c = 10000;
        contractObj.loan__Loan_Amount__c = 10000;
        contractObj.loan__Invalid_Data__c = false;
        contractObj.loan__Loan_Status__c = 'Active - Good Standing';
        contractList.add(contractObj);

        Database.update(contractList);

        // Create Investment Orders (Investor Loans) for validation
        List<loan__Investor_Loan__c> investorLoanList = new List<loan__Investor_Loan__c>();

        // Valid investor loan with matching interest posted
        loan__Investor_Loan__c investorLoan = F2FTestHelper.returnloanInvestor(contractObj);
        investorLoanList.add(investorLoan);

        // Investor loan with difference > 1 for posting difference validation
        loan__Investor_Loan__c investorLoan2 = F2FTestHelper.returnloanInvestor(contractObj); // Reusing contractObj for this test
        investorLoanList.add(investorLoan2);

        insert investorLoanList;

        // Create LPTs for reversal issue testing
        List<loan__Payment_Mode__c> paymentModeList = new List<loan__Payment_Mode__c>();
        loan__Payment_Mode__c paymentModeObj = F2FTestHelper.getPaymentMode();
        paymentModeList.add(paymentModeObj);
        Database.insert(paymentModeList);

        List<loan__Loan_Payment_Transaction__c> lptList = new List<loan__Loan_Payment_Transaction__c>();

        // LPT with reversal issue - cleared=true, reversed=true, paid_to_investor=true, but paid_to_investor_reversed=false
        loan__Loan_Payment_Transaction__c lptReversalIssue = F2FTestHelper.returnLoanPayment(contractObj);
        lptReversalIssue.loan__Payment_Mode__c = paymentModeList[0].Id;
        lptReversalIssue.loan__Cleared__c = true;
        lptReversalIssue.loan__Reversed__c = true;
        lptReversalIssue.loan__Rejected__c = false;
        lptReversalIssue.loan__Paid_to_Investor__c = true;
        lptReversalIssue.loan__Paid_to_Investor_Reversed__c = false; // Should be true for proper reversal
        lptList.add(lptReversalIssue);

        // LPT with another reversal issue pattern
        loan__Loan_Payment_Transaction__c lptReversalIssue2 = F2FTestHelper.returnLoanPayment(contractObj); // Reusing contractObj for this test
        lptReversalIssue2.loan__Payment_Mode__c = paymentModeList[0].Id;
        lptReversalIssue2.loan__Cleared__c = true;
        lptReversalIssue2.loan__Reversed__c = false;
        lptReversalIssue2.loan__Rejected__c = false;
        lptReversalIssue2.loan__Paid_to_Investor__c = false; // Should be true when cleared
        lptList.add(lptReversalIssue2);

        insert lptList;
    }

    @isTest
    static void testConstructorWithValidInterestHandler() {
        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put('LAI101', 100.0);

        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();

        Test.startTest();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);
        Test.stopTest();

        System.assertNotEquals(null, helper, 'Helper should be instantiated');
        System.assertNotEquals(null, helper.handlerUtilInst, 'Handler util should be instantiated');
    }

    @isTest
    static void testConstructorWithValidFeesHandler() {
        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put('LAI101', 100.0);

        F2FFeesPaymentFileHandler feesHandler = new F2FFeesPaymentFileHandler();

        Test.startTest();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(feesHandler, loanAmountMap);
        Test.stopTest();

        System.assertNotEquals(null, helper, 'Helper should be instantiated');
        System.assertNotEquals(null, helper.handlerUtilInst, 'Handler util should be instantiated');
    }

    @isTest
    static void testConstructorWithNullHandler() {
        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put('LAI101', 100.0);

        Test.startTest();
        try {
            F2FPaymentFileHelper helper = new F2FPaymentFileHelper(null, loanAmountMap);
            System.assert(false, 'Should throw exception for null handler');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('null'), 'Should throw validation error for null params');
        }
        Test.stopTest();
    }

    @isTest
    static void testConstructorWithNullLoanMap() {
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();

        Test.startTest();
        try {
            F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, null);
            System.assert(false, 'Should throw exception for null loan map');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('null'), 'Should throw validation error for null params');
        }
        Test.stopTest();
    }

    @isTest
    static void testConstructorWithInvalidHandler() {
        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put('LAI101', 100.0);

        String invalidHandler = 'Invalid Handler';

        Test.startTest();
        try {
            F2FPaymentFileHelper helper = new F2FPaymentFileHelper(invalidHandler, loanAmountMap);
            System.assert(false, 'Should throw exception for invalid handler');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Invalid payment file handler'), 'Should throw validation error for invalid handler');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetLoanDetails() {
        List<loan__Loan_Account__c> loans = [SELECT Id, Name FROM loan__Loan_Account__c LIMIT 2];
        Set<String> loanNameSet = new Set<String>();
        for(loan__Loan_Account__c loan : loans) {
            loanNameSet.add(loan.Name);
        }

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put('LAI101', 100.0);
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Map<String, loan__Loan_Account__c> result = helper.getLoanDetails(loanNameSet);
        Test.stopTest();

        System.assert(result.size() > 0, 'Should return loan details');
        for(String loanName : loanNameSet) {
            if(result.containsKey(loanName)) {
                System.assertNotEquals(null, result.get(loanName), 'Loan details should not be null');
            }
        }
    }

    @isTest
    static void testGetIOPostingSum() {
        List<loan__Loan_Account__c> loans = [SELECT Id, Name FROM loan__Loan_Account__c WHERE loan__Invalid_Data__c = false LIMIT 1];

        if(loans.size() == 0) {
            System.debug('No loans available for testing');
            return;
        }

        Set<String> loanNameSet = new Set<String>();
        Map<String, loan__Loan_Account__c> loanNameVsLoanObjMap = new Map<String, loan__Loan_Account__c>();

        for(loan__Loan_Account__c loan : loans) {
            loanNameSet.add(loan.Name);
            loanNameVsLoanObjMap.put(loan.Name, loan);
        }

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put('LAI101', 100.0);
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Map<String, Decimal> result = helper.getIOPostingSum(loanNameSet, loanNameVsLoanObjMap);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        // Should have posting sums for loans with Investment Orders - handle null values properly
        for(String loanName : loanNameSet) {
            if(result.containsKey(loanName) && result.get(loanName) != null) {
                System.assert(result.get(loanName) >= 0, 'Posting sum should be non-negative when present');
            } else {
                System.debug('No posting sum found for loan: ' + loanName);
            }
        }
    }

    @isTest
    static void testGetReversalIssueLoanMap() {
        List<loan__Loan_Account__c> loans = [SELECT Id, Name FROM loan__Loan_Account__c LIMIT 2];
        Set<String> loanNameSet = new Set<String>();
        for(loan__Loan_Account__c loan : loans) {
            loanNameSet.add(loan.Name);
        }

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put('LAI101', 100.0);
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Set<String> result = helper.getReversalIssueLoanMap(loanNameSet);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        // Should identify loans with reversal issues
        System.assert(result.size() > 0, 'Should find loans with reversal issues');
    }

    @isTest
    static void testInterestFileValidationWithValidLoans() {
        List<loan__Loan_Account__c> validLoans = [SELECT Id, Name FROM loan__Loan_Account__c WHERE loan__Invalid_Data__c = false AND loan__Loan_Status__c = 'Active - Good Standing' LIMIT 1];

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put(validLoans[0].Name, 100.0); // Small amount that won't exceed interest posted

        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        helper.interestFileValidation();
        Test.stopTest();

        // Should have some validation errors due to reversal issues, but loan should remain in map for basic validations
        System.assert(interestHandler.errorList.size() > 0, 'Should have validation errors due to test data setup');
    }

    @isTest
    static void testInterestFileValidationWithInvalidDataLoan() {
        // Get the existing loan and modify it for this test
        List<loan__Loan_Account__c> loans = [SELECT Id, Name FROM loan__Loan_Account__c LIMIT 1];
        loans[0].loan__Invalid_Data__c = true;
        update loans[0];

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put(loans[0].Name, 100.0);

        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        helper.interestFileValidation();
        Test.stopTest();

        // Should have validation error and loan should be removed from map
        System.assert(interestHandler.errorList.size() > 0, 'Should have validation errors');
        System.assert(!helper.loanNameVsAmountMap.containsKey(loans[0].Name), 'Invalid loan should be removed from map');

        // Reset loan for other tests
        loans[0].loan__Invalid_Data__c = false;
        update loans[0];
    }

    @isTest
    static void testInterestFileValidationWithInvalidStatusLoan() {
        // Get the existing loan and modify it for this test
        List<loan__Loan_Account__c> loans = [SELECT Id, Name FROM loan__Loan_Account__c LIMIT 1];
        loans[0].loan__Loan_Status__c = 'Closed - Obligations met';
        update loans[0];

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put(loans[0].Name, 100.0);

        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        helper.interestFileValidation();
        Test.stopTest();

        // Should have validation error and loan should be removed from map
        System.assert(interestHandler.errorList.size() > 0, 'Should have validation errors');
        System.assert(!helper.loanNameVsAmountMap.containsKey(loans[0].Name), 'Invalid status loan should be removed from map');

        // Reset loan for other tests
        loans[0].loan__Loan_Status__c = 'Active - Good Standing';
        update loans[0];
    }

    @isTest
    static void testInterestFileValidationWithExcessiveClearingAmount() {
        // Get the existing loan and modify it for this test
        List<loan__Loan_Account__c> loans = [SELECT Id, Name FROM loan__Loan_Account__c LIMIT 1];
        loans[0].loan__Interest_Posted__c = 100; // Set low amount for clearing validation
        update loans[0];

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put(loans[0].Name, 150.0); // Amount exceeds interest posted (100)

        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        helper.interestFileValidation();
        Test.stopTest();

        // Should have validation error for excessive clearing amount
        System.assert(interestHandler.errorList.size() > 0, 'Should have validation errors');
        Boolean hasExcessiveAmountError = false;
        for(String error : interestHandler.errorList) {
            if(error.contains('clearing amount on the file') && error.contains('negative interest postings')) {
                hasExcessiveAmountError = true;
                break;
            }
        }
        System.assert(hasExcessiveAmountError, 'Should have specific error for excessive clearing amount');

        // Reset loan for other tests
        loans[0].loan__Interest_Posted__c = 1000;
        update loans[0];
    }

    @isTest
    static void testFeesFileValidationWithValidLoans() {
        List<loan__Loan_Account__c> validLoans = [SELECT Id, Name FROM loan__Loan_Account__c WHERE loan__Invalid_Data__c = false AND loan__Loan_Status__c = 'Active - Good Standing' LIMIT 1];

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put(validLoans[0].Name, 100.0);

        F2FFeesPaymentFileHandler feesHandler = new F2FFeesPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(feesHandler, loanAmountMap);

        Test.startTest();
        helper.feesFileValidation();
        Test.stopTest();

        // Should pass basic validations for fees (no Investment Order validation for fees)
        System.assert(helper.loanNameVsAmountMap.containsKey(validLoans[0].Name), 'Valid loan should remain in map');
    }

    @isTest
    static void testFeesFileValidationWithInvalidLoans() {
        // Get the existing loan and modify it for this test
        List<loan__Loan_Account__c> loans = [SELECT Id, Name FROM loan__Loan_Account__c LIMIT 1];
        loans[0].loan__Invalid_Data__c = true;
        update loans[0];

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put(loans[0].Name, 100.0);

        F2FFeesPaymentFileHandler feesHandler = new F2FFeesPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(feesHandler, loanAmountMap);

        Test.startTest();
        helper.feesFileValidation();
        Test.stopTest();

        // Should have validation error and loan should be removed from map
        System.assert(feesHandler.errorList.size() > 0, 'Should have validation errors');
        System.assert(!helper.loanNameVsAmountMap.containsKey(loans[0].Name), 'Invalid loan should be removed from map');

        // Reset loan for other tests
        loans[0].loan__Invalid_Data__c = false;
        update loans[0];
    }

    @isTest
    static void testIsLoanNameValidWithValidLoan() {
        List<loan__Loan_Account__c> loans = [SELECT Id, Name FROM loan__Loan_Account__c LIMIT 1];

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Boolean result = helper.isLoanNameValid(loans[0].Name, loans[0]);
        Test.stopTest();

        System.assertEquals(true, result, 'Should return true for valid loan');
        System.assertEquals(0, interestHandler.errorCount, 'Should not have errors for valid loan');
    }

    @isTest
    static void testIsLoanNameValidWithNullLoan() {
        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Boolean result = helper.isLoanNameValid('NonExistentLoan', null);
        Test.stopTest();

        System.assertEquals(false, result, 'Should return false for null loan');
        System.assertEquals(1, interestHandler.errorCount, 'Should have one error for null loan');
    }

    @isTest
    static void testIsLoanNotInvalidDataWithInvalidLoan() {
        // First check if we have any loans with invalid data
        List<loan__Loan_Account__c> invalidLoans = [SELECT Id, Name, loan__Invalid_Data__c
                                                    FROM loan__Loan_Account__c
                                                    WHERE loan__Invalid_Data__c = true
                                                    LIMIT 1];

        // If no invalid loans exist, create one for testing
        if(invalidLoans.size() == 0) {
            List<loan__Loan_Account__c> validLoans = [SELECT Id, Name, loan__Invalid_Data__c
                                                    FROM loan__Loan_Account__c
                                                    LIMIT 1];
            if(validLoans.size() > 0) {
                validLoans[0].loan__Invalid_Data__c = true;
                update validLoans[0];
                invalidLoans = validLoans;
            } else {
                System.debug('No loans available for testing');
                return;
            }
        }

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Boolean result = helper.isLoanNotInvalidData(invalidLoans[0]);
        Test.stopTest();

        System.assertEquals(false, result, 'Should return false for loan with invalid data flag');
        System.assertEquals(1, interestHandler.errorCount, 'Should have one error for invalid loan');

        // Reset the loan if we modified it
        invalidLoans[0].loan__Invalid_Data__c = false;
        update invalidLoans[0];
    }

    @isTest
    static void testIsLoanStatusValidWithValidStatus() {
        List<loan__Loan_Account__c> validLoans = [SELECT Id, Name, loan__Loan_Status__c FROM loan__Loan_Account__c WHERE loan__Loan_Status__c = 'Active - Good Standing' LIMIT 1];

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Boolean result = helper.isLoanStatusValid(validLoans[0]);
        Test.stopTest();

        System.assertEquals(true, result, 'Should return true for valid loan status');
        System.assertEquals(0, interestHandler.errorCount, 'Should not have errors for valid status');
    }

    @isTest
    static void testIsLoanStatusValidWithInvalidStatus() {
        // First try to find an existing loan with invalid status
        List<loan__Loan_Account__c> invalidLoans = [SELECT Id, Name, loan__Loan_Status__c
                                                    FROM loan__Loan_Account__c
                                                    WHERE loan__Loan_Status__c = 'Closed - Obligations met'
                                                    LIMIT 1];

        // If no invalid loan exists, modify an existing one
        if(invalidLoans.size() == 0) {
            List<loan__Loan_Account__c> availableLoans = [SELECT Id, Name, loan__Loan_Status__c
                                                        FROM loan__Loan_Account__c
                                                        LIMIT 1];
            if(availableLoans.size() > 0) {
                availableLoans[0].loan__Loan_Status__c = 'Closed - Obligations met';
                update availableLoans[0];
                invalidLoans = availableLoans;
            } else {
                System.debug('No loans available for testing');
                return;
            }
        }

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Boolean result = helper.isLoanStatusValid(invalidLoans[0]);
        Test.stopTest();

        System.assertEquals(false, result, 'Should return false for invalid loan status');
        System.assertEquals(1, interestHandler.errorCount, 'Should have one error for invalid status');

        // Reset the loan status for other tests
        invalidLoans[0].loan__Loan_Status__c = 'Active - Good Standing';
        update invalidLoans[0];
    }

    @isTest
    static void testIsClearingAmountValidWithValidAmount() {
        List<loan__Loan_Account__c> loans = [SELECT Id, Name, loan__Interest_Posted__c FROM loan__Loan_Account__c WHERE loan__Interest_Posted__c > 0 LIMIT 1];

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put(loans[0].Name, 50.0); // Amount less than interest posted
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Boolean result = helper.isClearingAmountValid(loans[0]);
        Test.stopTest();

        System.assertEquals(true, result, 'Should return true for valid clearing amount');
        System.assertEquals(0, interestHandler.errorCount, 'Should not have errors for valid amount');
    }

    @isTest
    static void testIsClearingAmountValidWithExcessiveAmount() {
        List<loan__Loan_Account__c> loans = [SELECT Id, Name, loan__Interest_Posted__c FROM loan__Loan_Account__c LIMIT 1];
        loans[0].loan__Interest_Posted__c = 100; // Set low amount for this test
        update loans[0];

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        loanAmountMap.put(loans[0].Name, 150.0); // Amount exceeds interest posted
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Boolean result = helper.isClearingAmountValid(loans[0]);
        Test.stopTest();

        System.assertEquals(false, result, 'Should return false for excessive clearing amount');
        System.assertEquals(1, interestHandler.errorCount, 'Should have one error for excessive amount');

        // Reset loan for other tests
        loans[0].loan__Interest_Posted__c = 1000;
        update loans[0];
    }

    @isTest
    static void testIsPostingDiffValidWithValidDifference() {
        List<loan__Loan_Account__c> loans = [SELECT Id, Name, loan__Interest_Posted__c FROM loan__Loan_Account__c WHERE loan__Invalid_Data__c = false AND loan__Interest_Posted__c = 1000 LIMIT 1];

        Map<String, Decimal> loanNameVsIOPostingMap = new Map<String, Decimal>();
        loanNameVsIOPostingMap.put(loans[0].Name, 1000.0); // Exact match

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Boolean result = helper.isPostingDiffValid(loans[0], loanNameVsIOPostingMap);
        Test.stopTest();

        System.assertEquals(true, result, 'Should return true for valid posting difference');
        System.assertEquals(0, interestHandler.errorCount, 'Should not have errors for valid difference');
    }

    @isTest
    static void testIsPostingDiffValidWithExcessiveDifference() {
        List<loan__Loan_Account__c> loans = [SELECT Id, Name, loan__Interest_Posted__c FROM loan__Loan_Account__c LIMIT 1];
        loans[0].loan__Interest_Posted__c = 100; // Set amount for this test
        update loans[0];

        Map<String, Decimal> loanNameVsIOPostingMap = new Map<String, Decimal>();
        loanNameVsIOPostingMap.put(loans[0].Name, 95.0); // 5 difference, should fail (>1)

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Boolean result = helper.isPostingDiffValid(loans[0], loanNameVsIOPostingMap);
        Test.stopTest();

        System.assertEquals(false, result, 'Should return false for excessive posting difference');
        System.assertEquals(1, interestHandler.errorCount, 'Should have one error for excessive difference');

        // Reset loan for other tests
        loans[0].loan__Interest_Posted__c = 1000;
        update loans[0];
    }

    @isTest
    static void testIsPostingDiffValidWithNoInvestmentOrders() {
        // Create a loan without Investment Orders using unique name
        List<Account> borrowerAccounts = [SELECT Id FROM Account WHERE Name = 'Helper Test Borrower' LIMIT 1];
        loan__Loan_Account__c loanWithoutIO = new loan__Loan_Account__c();
        loanWithoutIO.loan__Account__c = borrowerAccounts[0].Id;
        loanWithoutIO.loan__Interest_Posted__c = 500;
        loanWithoutIO.loan__Invalid_Data__c = false;
        loanWithoutIO.loan__Loan_Status__c = 'Active - Good Standing';
        loanWithoutIO.loan__Principal_Remaining__c = 10000;
        loanWithoutIO.loan__Loan_Amount__c = 10000;
        // Set other required fields
        loanWithoutIO.loan__Loan_Purpose__c = 'Personal';
        loanWithoutIO.loan__Loan_Product_Name__c = 'Standard Loan';
        insert loanWithoutIO;

        Map<String, Decimal> loanNameVsIOPostingMap = new Map<String, Decimal>();
        // No entry for this loan in the map

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Boolean result = helper.isPostingDiffValid(loanWithoutIO, loanNameVsIOPostingMap);
        Test.stopTest();

        System.assertEquals(false, result, 'Should return false for loan without Investment Orders');
        System.assertEquals(1, interestHandler.errorCount, 'Should have one error for missing Investment Orders');
    }

    @isTest
    static void testIsNoReversalLPTIssueWithNoIssues() {
        // Create a loan without reversal issues using unique name
        List<Account> borrowerAccounts = [SELECT Id FROM Account WHERE Name = 'Helper Test Borrower' LIMIT 1];
        loan__Loan_Account__c cleanLoan = new loan__Loan_Account__c();
        cleanLoan.loan__Account__c = borrowerAccounts[0].Id;
        cleanLoan.loan__Invalid_Data__c = false;
        cleanLoan.loan__Loan_Status__c = 'Active - Good Standing';
        cleanLoan.loan__Principal_Remaining__c = 10000;
        cleanLoan.loan__Loan_Amount__c = 10000;
        // Set other required fields
        cleanLoan.loan__Loan_Purpose__c = 'Personal';
        cleanLoan.loan__Loan_Product_Name__c = 'Standard Loan';
        insert cleanLoan;

        Set<String> reversalIssueLoanSet = new Set<String>();
        // No reversal issues for this loan

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Boolean result = helper.isNoReversalLPTIssue(cleanLoan, reversalIssueLoanSet);
        Test.stopTest();

        System.assertEquals(true, result, 'Should return true for loan without reversal issues');
        System.assertEquals(0, interestHandler.errorCount, 'Should not have errors for clean loan');
    }

    @isTest
    static void testIsNoReversalLPTIssueWithIssues() {
        List<loan__Loan_Account__c> loans = [SELECT Id, Name FROM loan__Loan_Account__c WHERE loan__Invalid_Data__c = false LIMIT 1];

        Set<String> reversalIssueLoanSet = new Set<String>();
        reversalIssueLoanSet.add(loans[0].Name); // This loan has reversal issues

        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        Boolean result = helper.isNoReversalLPTIssue(loans[0], reversalIssueLoanSet);
        Test.stopTest();

        System.assertEquals(false, result, 'Should return false for loan with reversal issues');
        System.assertEquals(1, interestHandler.errorCount, 'Should have one error for reversal issue');
    }

    @isTest
    static void testShowErrorMessageInterest() {
        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        interestHandler.errorCount = 1;
        interestHandler.errorList.add('Test error');
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        PageReference pageRef = Page.F2FUploadPaymentFilePage;
        Test.setCurrentPage(pageRef);
        helper.showErrorMessage('interest');
        Test.stopTest();

        // Should add ApexPages message for errors
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assert(messages.size() > 0, 'Should have ApexPages messages');
    }

    @isTest
    static void testShowErrorMessageFees() {
        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FFeesPaymentFileHandler feesHandler = new F2FFeesPaymentFileHandler();
        feesHandler.errorCount = 1;
        feesHandler.errorList.add('Test error');
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(feesHandler, loanAmountMap);

        Test.startTest();
        PageReference pageRef = Page.F2FUploadPaymentFilePage;
        Test.setCurrentPage(pageRef);
        helper.showErrorMessage('fees');
        Test.stopTest();

        // Should add ApexPages message for errors
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assert(messages.size() > 0, 'Should have ApexPages messages');
    }

    @isTest
    static void testHandlerUtilsWithInterestHandler() {
        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        Test.startTest();
        // Test getErrorListSize
        Integer size = helper.handlerUtilInst.getErrorListSize(interestHandler);
        System.assertEquals(0, size, 'Should return 0 for empty error list');

        // Test getErrorCount
        Integer count = helper.handlerUtilInst.getErrorCount(interestHandler);
        System.assertEquals(0, count, 'Should return 0 for zero error count');

        // Test incrementErrorCount
        helper.handlerUtilInst.incrementErrorCount(interestHandler);
        System.assertEquals(1, interestHandler.errorCount, 'Should increment error count to 1');

        // Test addErrorToList
        helper.handlerUtilInst.addErrorToList(interestHandler, 'Test error');
        System.assertEquals(1, interestHandler.errorList.size(), 'Should add error to list');
        Test.stopTest();
    }

    @isTest
    static void testHandlerUtilsWithFeesHandler() {
        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FFeesPaymentFileHandler feesHandler = new F2FFeesPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(feesHandler, loanAmountMap);

        Test.startTest();
        // Test getErrorListSize
        Integer size = helper.handlerUtilInst.getErrorListSize(feesHandler);
        System.assertEquals(0, size, 'Should return 0 for empty error list');

        // Test getErrorCount
        Integer count = helper.handlerUtilInst.getErrorCount(feesHandler);
        System.assertEquals(0, count, 'Should return 0 for zero error count');

        // Test incrementErrorCount
        helper.handlerUtilInst.incrementErrorCount(feesHandler);
        System.assertEquals(1, feesHandler.errorCount, 'Should increment error count to 1');

        // Test addErrorToList
        helper.handlerUtilInst.addErrorToList(feesHandler, 'Test error');
        System.assertEquals(1, feesHandler.errorList.size(), 'Should add error to list');
        Test.stopTest();
    }

    @isTest
    static void testHandlerUtilsWithInvalidHandler() {
        Map<String, Decimal> loanAmountMap = new Map<String, Decimal>();
        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, loanAmountMap);

        String invalidHandler = 'Invalid Handler';

        Test.startTest();
        // Test methods with invalid handler
        Integer size = helper.handlerUtilInst.getErrorListSize(invalidHandler);
        System.assertEquals(0, size, 'Should return 0 for invalid handler');

        Integer count = helper.handlerUtilInst.getErrorCount(invalidHandler);
        System.assertEquals(0, count, 'Should return 0 for invalid handler');

        // These methods should handle invalid handler gracefully
        helper.handlerUtilInst.incrementErrorCount(invalidHandler);
        helper.handlerUtilInst.addErrorToList(invalidHandler, 'Test error');
        Test.stopTest();
    }

    @isTest
    static void testInterestFileValidationEmptyMap() {
        Map<String, Decimal> emptyLoanAmountMap = new Map<String, Decimal>();

        F2FInterestPaymentFileHandler interestHandler = new F2FInterestPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(interestHandler, emptyLoanAmountMap);

        Test.startTest();
        helper.interestFileValidation();
        Test.stopTest();

        // Should handle empty map gracefully
        System.assertEquals(0, interestHandler.errorCount, 'Should not have errors for empty map');
    }

    @isTest
    static void testFeesFileValidationEmptyMap() {
        Map<String, Decimal> emptyLoanAmountMap = new Map<String, Decimal>();

        F2FFeesPaymentFileHandler feesHandler = new F2FFeesPaymentFileHandler();
        F2FPaymentFileHelper helper = new F2FPaymentFileHelper(feesHandler, emptyLoanAmountMap);

        Test.startTest();
        helper.feesFileValidation();
        Test.stopTest();

        // Should handle empty map gracefully
        System.assertEquals(0, feesHandler.errorCount, 'Should not have errors for empty map');
    }

    //Utility method for unique user creation
    private static User createUniqueTestUser(String testMethodName) {
        List<Profile> systemAdminProfileList = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        String uniqueEmail = 'testUser_' + testMethodName + '_' + System.now().getTime() + '@test.com';
        User userToInsertObj = StandardFeaturesTestHelper.getUser('testUser', uniqueEmail, systemAdminProfileList[0].Id);
        Database.insert(userToInsertObj);
        return userToInsertObj;
    }
}
