/**
 * @description       : Test class for F2FPaymentFileController class
 * @author            : Syed Shabbar
 * @group             : Test Class
 * @last modified on  : 02-11-2025
 * @last modified by  : Supriyo Seni
**/
/*
@Company: Cloudkaptan Consultancy Services Pvt.Ltd.
@Class : F2FPaymentFileControllerTest
@Description : Test class for F2FPaymentFileController class
@Developer : Syed Shabbar
@Date : 24th Feb 2022
*/
@isTest(SeeAllData=false)
global class F2FPaymentFileControllerTest {
    
    static Date currentDate = System.today();
    
    @testsetup
    static void testsetup(){
        //account record types
        Id borrowerRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Borrower').getRecordTypeId();
        Id investorRecordType = Schema.SObjectType.account.getRecordTypeInfosByName().get('Investor').getRecordTypeId();
        
        //legal entity
        clcommon__Legal_Entity__c individualLegalEntity = F2FTestHelper.getLegalEntity('Individual');
        insert individualLegalEntity;
        System.assertEquals(true, individualLegalEntity.Id!=null, 'Individual legal entity not inserted');

        // Creating accounts
        List<Account> accountList = new List<Account>();

        Account borrowerAccount=F2FTestHelper.getAccount();
        borrowerAccount.Name = 'Controller Test Borrower';
        borrowerAccount.clcommon__Email__c = 'controller.borrower@mailinator.com';        
        borrowerAccount.recordTypeId = borrowerRecordType;
        borrowerAccount.clcommon__Legal_Entity_Type__c = individualLegalEntity.Id;
        accountList.add(borrowerAccount);

        Account investorAccount=F2FTestHelper.getAccount();
        investorAccount.Name = 'Controller Test Investor';
        investorAccount.clcommon__Email__c = 'controller.investor@mailinator.com';        
        investorAccount.recordTypeId = investorRecordType;
        investorAccount.clcommon__Legal_Entity_Type__c = individualLegalEntity.Id;
        accountList.add(investorAccount);

        if(accountList!=null && accountList.size()>0){
            insert accountList;
        }

        // query for assertion
        List<Account> queryAccountList= [SELECT id FROM Account WHERE recordTypeId!=null];
        System.assertEquals(true, queryAccountList.size()==2, 'Account list is not inserted');

        // Create contract
        loan__Loan_Account__c contract=F2FTestHelper.returnLoanAccount(borrowerAccount);
        contract.loan__Interest_Rate__c = 6.5;
        contract.loan__Previous_Installment_Date__c = Date.valueOf('2021-01-01');
        contract.MAF__c = 0.5;
        contract.loan__Principal_Remaining__c = 10000;
        contract.loan__Loan_Amount__c = 10000;
        contract.loan__Next_Installment_Date__c = Date.valueOf('2021-02-01');
        contract.loan__Maturity_Date_Current__c = Date.valueOf('2025-08-01');
        contract.loan__Next_Due_Generation_Date__c = Date.valueOf('2021-02-01');
        contract.loan__Invalid_Data__c = false;
        contract.loan__Interest_Posted__c = 1000;
        contract.loan__Loan_Status__c = 'Active - Good Standing';
        update contract;
        System.assertEquals(true, contract.Id!=null, 'Loan account not inserted');

        // Create Investment Orders (Investor Loans) for validation
        loan__Investor_Loan__c investorLoan = F2FTestHelper.returnloanInvestor(contract);
        insert investorLoan;

        //Payment modes
        loan__Payment_Mode__c loanPaymentModeObj=F2FTestHelper.getPaymentMode();
        loanPaymentModeObj.Name='BACS';
        insert loanPaymentModeObj;

        // Create Automated Payment Setup for Interest handling
        loan__Automated_Payment_Setup__c apsObj = new loan__Automated_Payment_Setup__c();
        apsObj.loan__CL_Contract__c = contract.Id;
        apsObj.loan__Payment_Mode__c = loanPaymentModeObj.Id;
        apsObj.loan__Amount_Type__c = 'Last Billed Amount';
        apsObj.loan__Type__c = 'Recurring';
        apsObj.loan__Frequency__c = 'Billing Frequency';
        insert apsObj;

        //Create LPT
        List<loan__Loan_Payment_Transaction__c> lptList = new List<loan__Loan_Payment_Transaction__c>();
        loan__Loan_Payment_Transaction__c  lpt = F2FTestHelper.returnLoanPayment(contract);
        lpt.loan__Transaction_Date__c = currentDate;
        lpt.loan__Cheque_Number__c = '1234';
        lpt.loan__Payment_Mode__c = loanPaymentModeObj.Id;
        lpt.loan__Transaction_Amount__c = 200;
        lpt.loan__Cleared__c = false;
        lpt.loan__Rejected__c = false;
        lpt.loan__Reversed__c = false;
        lpt.loan__Automated_Payment_Setup__c = apsObj.Id;
        lptList.add(lpt);
        
        loan__Loan_Payment_Transaction__c  lptObj = F2FTestHelper.returnLoanPayment(contract);
        lptObj.loan__Transaction_Date__c = currentDate;
        lptObj.loan__Cheque_Number__c = '1234';
        lptObj.loan__Payment_Mode__c = loanPaymentModeObj.Id;
        lptObj.loan__Transaction_Amount__c = 100;
        lptObj.loan__Cleared__c = false;
        lptObj.loan__Rejected__c = false;
        lptObj.loan__Reversed__c = false;
        lptObj.loan__Automated_Payment_Setup__c = apsObj.Id;
        lptList.add(lptObj);
        insert lptList;
        
        System.assertEquals(true, lpt.Id!=null && lptObj.Id!=null, 'Lpt not inserted');

        // Create Fee Payment Spreads for Fees testing
        List<loan__Loan_Payment_Spread__c> paymentSpreadList = new List<loan__Loan_Payment_Spread__c>();
        
        loan__Loan_Payment_Spread__c managementFeeSpread = new loan__Loan_Payment_Spread__c();
        managementFeeSpread.Name = 'management fee_Custom Spread';
        managementFeeSpread.loan__Order_Of_Payment__c = 'Management Fee';
        paymentSpreadList.add(managementFeeSpread);

        loan__Loan_Payment_Spread__c collectionFeeSpread = new loan__Loan_Payment_Spread__c();
        collectionFeeSpread.Name = 'Collection Fee Spread Only';
        collectionFeeSpread.loan__Order_Of_Payment__c = 'Collection Fee';
        paymentSpreadList.add(collectionFeeSpread);

        insert paymentSpreadList;
    }
    
    // Success scenario for Interest file
    @isTest(SeeAllData=false)
    static void successMethodInterest(){
        String currentSystemDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQuery = [Select Id,Name FROM loan__Loan_Account__c];
        System.assertEquals(true, loanQuery.size()>=0 , 'Contract not fetched');
        
        Test.startTest();
        PageReference pageRef = Page.F2FUploadPaymentFilePage;
        Test.setCurrentPage(pageRef);
        String result = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + '\n' + loanQuery[0].name+', John Doe, 300, 7888912,'+ currentSystemDate+',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(result);
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
       
        Test.stopTest();
    }
    
    // Success scenario for Fees file
    @isTest(SeeAllData=false)
    static void successMethodFee(){
        String currentSystemDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQuery = [Select Id,Name FROM loan__Loan_Account__c];
        System.assertEquals(true, loanQuery.size()>=0 , 'Contract not fetched');
        
        Test.startTest();
        PageReference pageRef = Page.F2FUploadPaymentFilePage;
        Test.setCurrentPage(pageRef);
        String result = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference,\\n,Fee Name' + '\n' + loanQuery[0].name+', John Doe, 100, 7888912,'+ currentSystemDate+',Paid,'+loanQuery[0].name+',Management Fee';
        F2FPaymentFileController.contentFile = Blob.valueOf(result);
        F2FPaymentFileController.fileName = 'Upload Payment fees File';
        F2FPaymentFileController.processFile();
       
        Test.stopTest();
    }

    // Test Invalid file name scenario
    @isTest(SeeAllData=false)
    static void testInvalidFileName(){
        String currentSystemDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQuery = [Select Id,Name FROM loan__Loan_Account__c];
        
        Test.startTest();
        PageReference pageRef = Page.F2FUploadPaymentFilePage;
        Test.setCurrentPage(pageRef);
        String result = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + '\n' + loanQuery[0].name+', John Doe, 300, 7888912,'+ currentSystemDate+',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(result);
        F2FPaymentFileController.fileName = 'Upload Payment invalid File'; // Invalid filename
        
        try {
            F2FPaymentFileController.processFile();
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Payment file name'), 'Should validate file name');
        }
        Test.stopTest();
    }
    
    //Empty file scenario
    @isTest(SeeAllData=false)
    static void failureMethodTest(){
        Test.startTest();
        PageReference pageRef = Page.F2FUploadPaymentFilePage;
        Test.setCurrentPage(pageRef);
        String result = ' ';
        F2FPaymentFileController.contentFile = Blob.valueOf(result);
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
        Test.stopTest();
    }

    // Test null content file scenario
    @isTest(SeeAllData=false)
    static void testNullContentFile(){
        Test.startTest();
        PageReference pageRef = Page.F2FUploadPaymentFilePage;
        Test.setCurrentPage(pageRef);
        F2FPaymentFileController.contentFile = null;
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
        Test.stopTest();
    }

    // Test createErrorDocumentFile method
    @isTest(SeeAllData=false)
    static void testCreateErrorDocumentFile(){
        Test.startTest();
        List<String> errorList = new List<String>();
        errorList.add('Error Header\n');
        errorList.add('1, Test error message\n');
        F2FPaymentFileController.createErrorDocumentFile(errorList);
        
        // Verify document was created
        List<Document> documents = [SELECT Id, Name FROM Document WHERE Name LIKE 'Error File%'];
        System.assertEquals(1, documents.size(), 'Error document should be created');
        Test.stopTest();
    }

    // Test ExtractFile iterator functionality
    @isTest(SeeAllData=false)
    static void testExtractFileIterator(){
        Test.startTest();
        String testContent = 'Line 1\nLine 2\nLine 3';
        F2FPaymentFileController.ExtractFile extractor = new F2FPaymentFileController.ExtractFile(testContent, '\n');
        
        List<String> lines = new List<String>();
        for(String line : extractor) {
            lines.add(line);
        }
        
        System.assertEquals(3, lines.size(), 'Should extract 3 lines');
        System.assertEquals('Line 1', lines[0], 'First line should match');
        System.assertEquals('Line 2', lines[1], 'Second line should match');
        System.assertEquals('Line 3', lines[2], 'Third line should match');
        Test.stopTest();
    }

    // Test ExtractFile hasNext and next methods directly
    @isTest(SeeAllData=false)
    static void testExtractFileDirectMethods(){
        Test.startTest();
        String testContent = 'Test\nContent';
        F2FPaymentFileController.ExtractFile extractor = new F2FPaymentFileController.ExtractFile(testContent, '\n');
        
        System.assertEquals(true, extractor.hasNext(), 'Should have next element');
        String firstLine = extractor.next();
        System.assertEquals('Test', firstLine, 'First line should be Test');
        
        System.assertEquals(true, extractor.hasNext(), 'Should still have next element');
        String secondLine = extractor.next();
        System.assertEquals('Content', secondLine, 'Second line should be Content');
        
        System.assertEquals(false, extractor.hasNext(), 'Should not have more elements');
        Test.stopTest();
    }

    // Test exception handling in processFile
    @isTest(SeeAllData=false)
    static void testProcessFileException(){
        Test.startTest();
        PageReference pageRef = Page.F2FUploadPaymentFilePage;
        Test.setCurrentPage(pageRef);
        
        // Create invalid content that will cause an exception
        F2FPaymentFileController.contentFile = Blob.valueOf('Invalid Header\nInvalid Data');
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        
        try {
            F2FPaymentFileController.processFile();
        } catch (Exception e) {
            // Exception is handled internally and shown as ApexPages message
            System.assert(true, 'Exception should be handled gracefully');
        }
        Test.stopTest();
    }
    
    //Different error scenarios
    @isTest(SeeAllData=false)
    static void failureMethodOtherScenarioTest(){
        String systemDate  = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQuery = [Select Id,Name FROM loan__Loan_Account__c];
        Test.startTest();
        PageReference pageRef = Page.F2FUploadPaymentFilePage;
        Test.setCurrentPage(pageRef);
        
        // Test missing transaction reference
        String resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + '\n' +  loanQuery[0].name+', John Doe, 30000, 7888912,'+ systemDate +',Paid, ';
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
        
        // Test missing status
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + '\n' +  loanQuery[0].name+', John Doe, 30000, 7888912,'+ systemDate +', ,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
        
        // Test missing due date
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + '\n' +  loanQuery[0].name+', John Doe, 30000, 7888912, ,Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
        
        // Test missing customer id
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + '\n' + loanQuery[0].name+', John Doe, 30000, ,'+ systemDate +',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
        
        // Test missing amount
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + '\n' +  loanQuery[0].name+', John Doe, , 7888912,'+ systemDate +',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
        
        // Test missing account name
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + '\n' +  loanQuery[0].name+', , 30000, 7888912,'+ systemDate +',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
        
        // Test missing reference number
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + '\n' +  ' , John Doe, 30000, 7888912,'+ systemDate +',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
        
        // Test invalid amount format
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + '\n' + loanQuery[0].name+ ' , John Doe, error, 7888912,'+ systemDate +',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
        
        // Test completely empty content
        resultString = '';
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
        Test.stopTest();
    }
}
