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
        //legal entity
        clcommon__Legal_Entity__c individualLegalEntity = F2FTestHelper.getLegalEntity('Individual');
        insert individualLegalEntity;
        System.assertEquals(true, individualLegalEntity.Id!=null, 'Individual legal entity not inserted');

        // Creating accounts
        List<Account> accountList = new List<Account>();

        Account borrowerAccount=F2FTestHelper.getAccount();
        borrowerAccount.Name = 'Borrower 1';
        borrowerAccount.clcommon__Email__c = 'borrower@mailinator.com';        
        borrowerAccount.recordTypeId = borrowerRecordType;
        borrowerAccount.clcommon__Legal_Entity_Type__c = individualLegalEntity.Id;
        accountList.add(borrowerAccount);

        if(accountList!=null && accountList.size()>0){
            insert accountList;
        }

        // query for assertion
        List<Account> queryAccountList= [SELECT id FROM Account WHERE recordTypeId!=null];
        System.assertEquals(true, queryAccountList.size()==1, 'Account list is not inserted');

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
        update contract;
        System.assertEquals(true, contract.Id!=null, 'Loan account not inserted');

        //Payment modes
        loan__Payment_Mode__c loanPaymentModeObj=F2FTestHelper.getPaymentMode();
        loanPaymentModeObj.Name='loanPaymentModeObj';
        insert loanPaymentModeObj;

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
        lptList.add(lpt);
        
        
        loan__Loan_Payment_Transaction__c  lptObj = F2FTestHelper.returnLoanPayment(contract);
        lptObj.loan__Transaction_Date__c = currentDate;
        lptObj.loan__Cheque_Number__c = '1234';
        lptObj.loan__Payment_Mode__c = loanPaymentModeObj.Id;
        lptObj.loan__Transaction_Amount__c = 100;
        lptObj.loan__Cleared__c = false;
        lptObj.loan__Rejected__c = false;
        lptObj.loan__Reversed__c = false;
        lptList.add(lptObj);
        insert lptList;
        
        System.assertEquals(true, lpt.Id!=null && lptObj.Id!=null, 'Lpt not inserted');
    }
    
    
    // Success scenario
    @isTest(SeeAllData=false)
    static void successMethodInterest(){
        String currentSystemDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQuery = [Select Id,Name FROM loan__Loan_Account__c];
        System.assertEquals(true, loanQuery.size()>=0 , 'Contract not fetched');
        
        Test.startTest();
        PageReference pageRef = Page.F2FUploadPaymentFilePage;
        Test.setCurrentPage(pageRef);
        String result = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + Folk2FolkConstantValues.NEXT_LINE + loanQuery[0].name+', John Doe, 30000, 7888912,'+ currentSystemDate+',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(result);
        F2FPaymentFileController.fileName = 'Upload Payment interest File';
        F2FPaymentFileController.processFile();
       
        Test.stopTest();
    }
    
     @isTest(SeeAllData=false)
    static void successMethodFee(){
        String currentSystemDate = String.valueOf(currentDate);
        List<loan__Loan_Account__c> loanQuery = [Select Id,Name FROM loan__Loan_Account__c];
        System.assertEquals(true, loanQuery.size()>=0 , 'Contract not fetched');
        
        Test.startTest();
        PageReference pageRef = Page.F2FUploadPaymentFilePage;
        Test.setCurrentPage(pageRef);
        String result = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + Folk2FolkConstantValues.NEXT_LINE + loanQuery[0].name+', John Doe, 30000, 7888912,'+ currentSystemDate+',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(result);
        F2FPaymentFileController.fileName = 'Upload Payment fees File';
        F2FPaymentFileController.processFile();
       
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
        String resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + Folk2FolkConstantValues.NEXT_LINE +  loanQuery[0].name+', John Doe, 30000, 7888912,'+ systemDate +',Paid, ';
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.processFile();
        F2FPaymentFileController.fileName = 'Upload Payment File';
        
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + Folk2FolkConstantValues.NEXT_LINE +  loanQuery[0].name+', John Doe, 30000, 7888912,'+ systemDate +', ,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.processFile();
        F2FPaymentFileController.fileName = 'Upload Payment File';
        
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + Folk2FolkConstantValues.NEXT_LINE +  loanQuery[0].name+', John Doe, 30000, 7888912, ,Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.processFile();
        F2FPaymentFileController.fileName = 'Upload Payment File';
        
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + Folk2FolkConstantValues.NEXT_LINE + loanQuery[0].name+', John Doe, 30000, ,'+ systemDate +',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.processFile();
        F2FPaymentFileController.fileName = 'Upload Payment File';
        
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + Folk2FolkConstantValues.NEXT_LINE +  loanQuery[0].name+', John Doe, , 7888912,'+ systemDate +',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.processFile();
        F2FPaymentFileController.fileName = 'Upload Payment File';
        
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + Folk2FolkConstantValues.NEXT_LINE +  loanQuery[0].name+', , 30000, 7888912,'+ systemDate +',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.processFile();
        F2FPaymentFileController.fileName = 'Upload Payment File';
        
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + Folk2FolkConstantValues.NEXT_LINE +  ' , John Doe, 30000, 7888912,'+ systemDate +',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.processFile();
        F2FPaymentFileController.fileName = 'Upload Payment File';
        
        resultString = 'Reference Number, Account Name,Amount,Customer Id, Due Date, Status,Transaction Reference' + Folk2FolkConstantValues.NEXT_LINE + loanQuery[0].name+ ' , John Doe, error, 7888912,'+ systemDate +',Paid,'+loanQuery[0].name;
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.processFile();
        F2FPaymentFileController.fileName = 'Upload Payment File';
        
        resultString = '';
        F2FPaymentFileController.contentFile = Blob.valueOf(resultString);
        F2FPaymentFileController.processFile();
        F2FPaymentFileController.fileName = 'Upload Payment File';
        Test.stopTest();
    }
}