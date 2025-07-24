/**
 * @description       : Test Helper Class
 * @author            : Syed Shabbar Shahzad
 * @group             : Helper class
 * @last modified on  : 02-18-2025
 * @last modified by  : Supriyo Seni
**/

@isTest(SeeAllData=false)
public without sharing class F2FTestHelper {

    public static Date currentSystemDate=Date.today();
    public static String fullName;

    /**
    * @description | Get Account
    * @author Supriyo Seni | 02-18-2025 
    * @return Account 
    **/
    public static Account getAccount(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.clcommon__Email__c = 'testf2faccount@id.com';
        acc.Phone = '1234567890';
        acc.First_name__c = 'Test';
        acc.Last_Name__c = 'Account';
        fullName = acc.Name;
        return acc;
    }

    /**
    * @description | Get contact with accountId
    * @author Supriyo Seni | 02-18-2025 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact getContact(Id accountId){
        Contact individualContact = new Contact();
        individualContact.LastName = 'Test Contact';
        individualContact.AccountId = accountId;
        return individualContact;
    }

    /**
    * @description | Get BACS payment mode
    * @author Supriyo Seni | 02-18-2025 
    * @return loan__Payment_Mode__c 
    **/
    public static loan__Payment_Mode__c getPaymentMode(){
        loan__Payment_Mode__c lpm = new loan__Payment_Mode__c();
        lpm.Name='BACS';
        return lpm;
    }

    /**
    * @description | This methos is  used ti get the Application
    * @author Supriyo Seni | 02-18-2025 
    * @param acc 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c getApplication(Id acc){
       genesis__Applications__c app = new genesis__Applications__c();
       app.genesis__Loan_Amount__c = 100000.00;
       app.genesis__Interest_Rate__c = 6.5;
       app.genesis__Term__c = 5;
       app.genesis__Interest_Only_Period__c = 4;
       app.genesis__Account__c = acc;
       app.genesis__Product_Type__c = 'LOAN';
       return app;
    }

    /**
    * @description | This method is used to get the contract
    * @author Supriyo Seni | 02-18-2025 
    * @param acc 
    * @return loan__Loan_Account__c 
    **/
    public static loan__Loan_Account__c getContract(Id acc){
        loan__Loan_Account__c loan = new loan__Loan_Account__c();
        return loan;
    }

    /**
    * @description | This method can be used to get the Loan Application
    * @author Supriyo Seni | 02-18-2025 
    * @param acc 
    * @return peer__Loan_Application__c 
    **/
    public static peer__Loan_Application__c getLoanApplication(Account acc){
        peer__Loan_Application__c la = new peer__Loan_Application__c();
        la.peer__Borrower__c=acc.Id;
        la.peer__Requested_Loan_Amount__c=100000;
        la.peer__Interest_Rate__c=6.5;
        la.peer__Term__c=5;
        return la;
    }

    /**
    * @description | Get the booking order
    * @author Supriyo Seni | 02-18-2025 
    * @param investorAccount 
    * @return peer__Booking_Order__c 
    **/
    public static peer__Booking_Order__c getBookingOrder(Account investorAccount){
        peer__Booking_Order__c bookingOrder = new peer__Booking_Order__c();
        bookingOrder.peer__Investor__c = investorAccount.Id;
        return bookingOrder;
    }

    /**
    * @description | Get peer__Investment_Booking__c
    * @author Supriyo Seni | 02-18-2025 
    * @param laApp 
    * @param bo 
    * @return peer__Investment_Booking__c 
    **/
    public static peer__Investment_Booking__c getInvestmentBooking(peer__Loan_Application__c laApp,peer__Booking_Order__c bo){

        peer__Investment_Booking__c investmentBooking = new peer__Investment_Booking__c();
        investmentBooking.peer__Loan_Application__c =laApp.Id;
        investmentBooking.peer__Booking_Order__c=bo.Id;
        investmentBooking.peer__Investment_Amount__c = 100000;
        investmentBooking.peer__Certificate_Rate__c = laApp.peer__Interest_Rate__c;
        investmentBooking.peer__Service_Rate__c = 0;

        return investmentBooking;
    }

    /**
    * @description | Get loan__Investor_Fund_Transaction__c
    * @author Supriyo Seni | 02-18-2025 
    * @param investorAccount 
    * @return loan__Investor_Fund_Transaction__c 
    **/
    public static loan__Investor_Fund_Transaction__c getInvestorFundTransaction(Account investorAccount){
        loan__Investor_Fund_Transaction__c investorFundTransaction = new loan__Investor_Fund_Transaction__c();
        investorFundTransaction.loan__Account__c = investorAccount.Id;
        return investorFundTransaction;
    }

    /**
    * @description | Get Task
    * @author Supriyo Seni | 02-18-2025 
    * @return Task 
    **/
    public static Task getTask() {
        Task task = new Task();
        task.Status = Folk2FolkConstantValues.OPEN;
        return task;
    }

    /**
    * @description | Get loan__Bank_Account__c
    * @author Supriyo Seni | 02-18-2025 
    * @param acc 
    * @return loan__Bank_Account__c 
    **/
    public static loan__Bank_Account__c getBankAccount(Account acc){
        loan__Bank_Account__c bacc = new loan__Bank_Account__c();
        bacc.loan__Bank_Name__c='icici';
        bacc.loan__Bank_Account_Number__c='78654459';
        bacc.peer__Branch_Code__c = '667788';
        bacc.loan__Account__c=acc.Id;
        bacc.loan__Active__c = true;
        return bacc;
    }

    /**
    * @description | Get loan__Other_Transaction__c
    * @author Supriyo Seni | 02-18-2025 
    * @param contractId 
    * @return loan__Other_Transaction__c 
    **/
    public static loan__Other_Transaction__c getOtherTransaction(Id contractId){
        loan__Other_Transaction__c otherTransaction = new loan__Other_Transaction__c();
        otherTransaction.loan__Loan_Account__c = contractId;
        return otherTransaction;
    }

    /**
    * @description | Get clcommon__Bank_Account__c
    * @author Supriyo Seni | 02-18-2025 
    * @param acc 
    * @return clcommon__Bank_Account__c 
    **/
    public static clcommon__Bank_Account__c getCommonBankAccount(Account acc){
        clcommon__Bank_Account__c bacc = new clcommon__Bank_Account__c();
        bacc.clcommon__Bank_Name__c='icici';
        bacc.clcommon__Bank_Account_Number__c='77665544';
        bacc.Branch_Code__c= '887766';
        bacc.clcommon__Account__c=acc.Id;
        bacc.clcommon__Active__c = true;
        return bacc;
    }

    /**
    * @description | get loan__Repayment_Schedule__c
    * @author Supriyo Seni | 02-18-2025 
    * @param lac 
    * @return loan__Repayment_Schedule__c 
    **/
    public static loan__Repayment_Schedule__c getAmotizationSchedule(loan__Loan_Account__c lac){
        loan__Repayment_Schedule__c ash = new loan__Repayment_Schedule__c();
        ash.loan__Loan_Account__c = lac.Id;
        ash.loan__Due_Date__c=Date.Today()-12;
        ash.loan__Due_Principal__c=10000;
        ash.loan__Due_Interest__c=1000;
        ash.loan__Balance__c=100000;
        return ash;
    }

    /**
    * @description | Get loan__Periodic_Fee_Setup__c
    * @author Supriyo Seni | 02-18-2025 
    * @param loanId 
    * @param feeName 
    * @return loan__Periodic_Fee_Setup__c 
    **/
    public static loan__Periodic_Fee_Setup__c getPeriodicFee(Id loanId, String feeName){
        loan__Periodic_Fee_Setup__c fee = new loan__Periodic_Fee_Setup__c();
        fee.loan__Amount__c = 1000;
        fee.loan__Lending_Account__c  = loanId;
        fee.loan__Active__c = true;
        return fee;
    }

    /**
    * @description | Get loan__Loan_Account__c
    * @author Supriyo Seni | 02-18-2025 
    * @param dummyClient 
    * @return loan__Loan_Account__c 
    **/
    public static loan__Loan_Account__c returnLoanAccount(Account dummyClient) {
        loan.TestHelper.createSeedDataForTesting();
        loan__Currency__c curr = loan.TestHelper.createCurrency();
        //Create a dummy MF_Account
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');

        //Create a Fee Set
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount,dummyAccount);
        dummyFee.loan__Time_of_charge__c ='Pre-Paid Fees';
        dummyFee.loan__Amount__c = 100;
        update dummyFee;
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();
        loan__Fee_Junction__c dummyFeeJunction;
        dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);

        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        //custom************** start
        list<loan__User_Branch_Info__c> userbranchAssign= new list<loan__User_Branch_Info__c>();
        for(loan__Office_Name__c ofc : [select id from loan__Office_Name__c]){
            userbranchAssign.add(new loan__User_Branch_Info__c(loan__User__c=userInfo.getUserId(),loan__Branch__c=ofc.Id));
        }
        insert userbranchAssign;
        //custom***************** end

        //Create a dummy Loan Product
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount,
                            curr,
                            dummyFeeSet);

        dummyLP.loan__Min_Loan_Amount__c = 10000;
        dummyLP.loan__Max_Loan_Amount__c = 20000000;

        loan__Loan_Purpose__c dummyLoanPurpose = loan.TestHelper.createLoanPurpose();
        dummyLoanPurpose.loan__Loan_Purpose_Code__c = 'Refinance';

        //Create a dummy Loan Account
        loan__Loan_Account__c loanAccount = loan.TestHelper.createLoanAccountForAccountObj(dummyLP,
                                                    dummyClient,
                                                    dummyFeeSet,
                                                    dummyLoanPurpose,
                                                    dummyOffice);
        loanAccount.loan__Number_of_Installments__c     = 5;
        loanAccount.Loan__Loan_Status__c                = 'Approved';
        loanAccount.Loan__Fees_Remaining__c             = 100;
        loanAccount.Loan__Interest_Remaining__c         = 500;
        loanAccount.loan__Interest_Rate__c         = 6.5;
        loanAccount.Loan__Principal_Remaining__c        = 10000;//custom previous 10000
        loanAccount.loan__Loan_Product_Name__c = dummyLP.Id;//custo
        loanAccount.Loan__Fractionalization_Status__c   = 'Active';
        loanAccount.Loan__Pay_off_Amount_As_Of_Today__c = loanAccount.loan__Fees_Remaining__c + loanAccount.loan__Principal_Remaining__c;
        loanAccount.loan__Loan_Amount__c=10000; //custom previous 10000
        loanAccount.loan__First_Installment_Date__c = currentSystemDate;

        return loanAccount;
    }

    /**
    * @description | Get loan__Loan_Disbursal_Transaction__c
    * @author Supriyo Seni | 02-18-2025 
    * @param contractObj 
    * @return loan__Loan_Disbursal_Transaction__c 
    **/
    public static loan__Loan_Disbursal_Transaction__c  returnLoanDisbursal(loan__Loan_Account__c contractObj) {
        loan__Loan_Disbursal_Transaction__c  loanDisbursal  =  new loan__Loan_Disbursal_Transaction__c();
        loanDisbursal.loan__Financed_Amount__c       =  1000;
        loanDisbursal.loan__Disbursal_Date__c = currentSystemDate;
        loanDisbursal.loan__Loan_Account__c   =   contractObj.id;
        return loanDisbursal;
    }

    /**
    * @description | return loan__Loan_Payment_Transaction__c
    * @author Supriyo Seni | 02-18-2025 
    * @param contractObj 
    * @return loan__Loan_Payment_Transaction__c 
    **/
    public static loan__Loan_Payment_Transaction__c  returnLoanPayment(loan__Loan_Account__c contractObj) {
        loan__Loan_Payment_Transaction__c loanPayment = new loan__Loan_Payment_Transaction__c();
        loanPayment.loan__Transaction_Amount__c = 5000;
        loanPayment.loan__Transaction_Date__c = currentSystemDate;
        loanPayment.loan__Loan_Account__c = contractObj.id;
        return loanPayment;
    }

    /**
    * @description | get loan__Investor_Loan__c
    * @author Supriyo Seni | 02-18-2025 
    * @param lac 
    * @return loan__Investor_Loan__c 
    **/
    public static loan__Investor_Loan__c returnloanInvestor(loan__Loan_Account__c lac){
        loan__Investor_Loan__c lil = new loan__Investor_Loan__c();
        lil.loan__Investment_Amount__c=1000;
        lil.loan__Certificate_Rate__c=5;
        lil.loan__Service_Rate__c=1;
        lil.loan__Loan__c=lac.Id;
        lil.loan__Loan_Principal_Remaining__c=500;
        return lil;
    }

    /**
    * @description | insert peer__Investment_Order_Sale_Transaction__c
    * @author Supriyo Seni | 02-18-2025 
    * @param parent 
    * @param child 
    * @param type 
    * @param buyer 
    **/
    public static void insertSaleTransaction(String parent, String child, String type, String buyer) {
        peer__Investment_Order_Sale_Transaction__c investmentOrderSaleTxnObj = new peer__Investment_Order_Sale_Transaction__c();
        investmentOrderSaleTxnObj.peer__Parent_Investment_Order__c = parent;
        investmentOrderSaleTxnObj.peer__Child_Investment_Order__c = child;
        investmentOrderSaleTxnObj.peer__Type__c = type;
        investmentOrderSaleTxnObj.peer__Buyer__c = buyer;
        investmentOrderSaleTxnObj.peer__Price_per_Share__c = 1;
        investmentOrderSaleTxnObj.peer__Number_of_Shares__c = 20000;
        insert investmentOrderSaleTxnObj;
    }

    /**
    * @description | get loan__Loan_Purpose__c
    * @author Supriyo Seni | 02-18-2025 
    * @param purposeName 
    * @return loan__Loan_Purpose__c 
    **/
    public static loan__Loan_Purpose__c getPurpose(String purposeName){
        loan__Loan_Purpose__c purpose = new loan__Loan_Purpose__c();
        purpose.Name = purposeName;
        purpose.loan__Description__c ='Test purpose';
        purpose.loan__Loan_Purpose_Code__c = '1223';
        return purpose;
    }

    /**
    * @description | self made investor loan transaction
    * @author Supriyo Seni | 02-18-2025 
    * @param lpt 
    * @param io 
    * @return loan__Investor_Loan_Account_Txns__c 
    **/
    public static loan__Investor_Loan_Account_Txns__c returnInvestorLoanTransaction(loan__Loan_Payment_Transaction__c lpt,loan__Investor_Loan__c io){
        loan__Investor_Loan_Account_Txns__c ilt=new loan__Investor_Loan_Account_Txns__c();
        //Date currentSystemDate  = Date.Today();
        ilt.loan__Transaction_Date__c=currentSystemDate;
        ilt.loan__Loan_Payment_Transaction__c=lpt.Id;
        ilt.loan__Investor_Loan__c=io.Id;
        ilt.loan__Interest_Paid__c=1000;
        ilt.loan__Txn_Amount__c  =5000;
        ilt.loan__Principal_Paid__c=1000;
        return ilt;
    }

    /**
    * @description | legal entity object
    * @author Supriyo Seni | 02-18-2025 
    * @param name 
    * @return clcommon__Legal_Entity__c 
    **/
    public static clcommon__Legal_Entity__c getLegalEntity(String name){
        List<String> legalList=label.LegalEntityName.split(',');
        Set<String> legalEntities = new Set<String>();
        for(String legalString : legalList){
            legalEntities.add(legalString);
        }
        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        if(legalEntities.contains(name)){
            legalEntity.Name = name;
        }
        return legalEntity;
    }

    /**
    * @description | conversion Mapping header
    * @author Supriyo Seni | 02-18-2025 
    * @return genesis__Conversion_Mapping_Header__c 
    **/
    public static genesis__Conversion_Mapping_Header__c getConversionMappingHeader(){
        genesis__Conversion_Mapping_Header__c convHeader = new genesis__Conversion_Mapping_Header__c();
        convHeader.genesis__Product_Type__c = 'LOAN';
        convHeader.genesis__Custom_Contract_Generation_Class__c = 'Loan.ContractProcessor';
        return convHeader;
    }

    /**
    * @description | conversion Mapping
    * @author Supriyo Seni | 02-18-2025 
    * @param header 
    * @return genesis__Conversion_Mapping__c 
    **/
    public static genesis__Conversion_Mapping__c getConversionMapping(Id header){
        genesis__Conversion_Mapping__c convMapping = new genesis__Conversion_Mapping__c();
        convMapping.genesis__Application_Object_Name__c = 'genesis__Applications__c';
        convMapping.genesis__Contract_Object_Name__c = 'loan__Loan_Account__c';
        convMapping.genesis__Product_Type__c = 'Loan';
        convMapping.genesis__Conversion_Mapping_Header__c = header;
        return convMapping;
    }

    /**
    * @description | insert note type
    * @author Supriyo Seni | 02-18-2025 
    * @return peer__Note_Type__c 
    **/
    public static peer__Note_Type__c getNoteType(){
        peer__Note_Type__c noteType = new peer__Note_Type__c();
        noteType.peer__Denomination__c = 1;
        return noteType;
    }

    /**
    * @description | set up for convertApplicationToContract API
    * @author Supriyo Seni | 02-18-2025 
    **/
    public static void getUserBranchAssignment(){
        loan.TestHelper.createSeedDataForTesting();
        loan__Office_Name__c dummyOffice = loan.TestHelper.createOffice();
        list<loan__User_Branch_Info__c> userbranchAssign= new list<loan__User_Branch_Info__c>();
        for(loan__Office_Name__c ofc : [select id from loan__Office_Name__c]){
            userbranchAssign.add(new loan__User_Branch_Info__c(loan__User__c=userInfo.getUserId(),loan__Branch__c=ofc.Id));
        }
        insert userbranchAssign;

        loan__Currency__c curr = loan.TestHelper.createCurrency();
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest','10000 - ASSETS');
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest','30000 - INCOME');
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr,dummyIncAccount,dummyAccount);
        dummyFee.loan__Time_of_charge__c ='Pre-Paid Fees';
        dummyFee.loan__Amount__c = 100;
        update dummyFee;
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet();

        loan__Fee_Junction__c dummyFeeJunction;
        dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee,dummyFeeSet);
        loan__Loan_Product__c dummyLP = loan.TestHelper.createLoanProduct(dummyOffice,
                            dummyAccount,
                            curr,
                            dummyFeeSet);
        List<loan__Org_Parameters__c> orgParams= [Select id, loan__Disable_Triggers__c from loan__Org_Parameters__c];
        orgParams[0].loan__Disable_Triggers__c = true;
        update orgParams;
        dummyLP.Name = 'F2F Loan Product';
        dummyLP.loan__Min_Loan_Amount__c = 100000;
        dummyLP.loan__Max_Loan_Amount__c = 20000000;
        dummyLP.loan__Min_Number_of_Installments__c = 3;
        dummyLP.loan__Max_Number_of_Installments__c = 18;
        dummyLP.loan__Min_Interest_Rate__c = 5;
        dummyLP.loan__Max_Interest_Rate__c = 10;
        dummyLP.loan__Default_Interest_Rate__c =6.5;
        dummyLP.loan__Funding_in_Tranches__c = false;
        update dummyLP;
        orgParams[0].loan__Disable_Triggers__c = false;
        update orgParams;

        Id loanRecordType = Schema.SObjectType.clcommon__CL_Product__c.getRecordTypeInfosByName().get('Loan').getRecordTypeId();
        clcommon__CL_Product__c applicationProduct = new clcommon__CL_Product__c();
        applicationProduct.clcommon__Product_Name__c = 'F2F Loan Product';
        applicationProduct.loan__Lending_Product__c = dummyLP.Id;
        applicationProduct.RecordTypeId = loanRecordType;
        insert applicationProduct;
    }

    /**
    * @description | get loan__Batch_Process_Log__c
    * @author Supriyo Seni | 02-18-2025 
    * @param className 
    * @return loan__Batch_Process_Log__c 
    **/
    public static loan__Batch_Process_Log__c getBatchProcessLog(String className){
        loan__Batch_Process_Log__c batchLog = new loan__Batch_Process_Log__c();
        batchLog.Name = className;
        batchLog.loan__Time__c = currentSystemDate;
        return batchLog;
    }
    
    /**
    * @description | get payment mode
    * @author Supriyo Seni | 02-18-2025 
    * @param paymentModeName 
    * @return loan__Payment_Mode__c 
    **/
    public static loan__Payment_Mode__c getPaymentMode(String paymentModeName){
        loan__Payment_Mode__c mode = new loan__Payment_Mode__c();
        mode.Name = paymentModeName;
        return mode;
    }

    /**
    * @description | get funding transaction
    * @author Supriyo Seni | 02-18-2025 
    * @param borrowerApplicationId 
    * @return genesis__Funding_Transaction__c 
    **/
    public static genesis__Funding_Transaction__c getFundingTransaction(Id borrowerApplicationId){
        genesis__Funding_Transaction__c fundTransaction = new genesis__Funding_Transaction__c();
        fundTransaction.genesis__Amount__c = 80000;
        fundTransaction.genesis__Application__c = borrowerApplicationId;
        return fundTransaction;
    }

    /**
    * @description | get Fee defination
    * @author Supriyo Seni | 02-18-2025 
    * @param feeName 
    * @return clcommon__Fee_Definition__c 
    **/
    public static clcommon__Fee_Definition__c getFeeDefination(String feeName){
        clcommon__Fee_Definition__c feeDefination = new clcommon__Fee_Definition__c();
        feeDefination.Name = feeName;
        feeDefination.clcommon__Amount__c = 100;
        feeDefination.clcommon__Calculation_Method__c = 'Fixed';
        feeDefination.clcommon__Type__c='Pre-Paid Fees';
        feeDefination.clcommon__Active__c=true;
        return feeDefination;
    }
    
    /**
    * @description | get clcommon fees
    * @author Supriyo Seni | 02-18-2025 
    * @param appId 
    * @param feeDefination 
    * @param loanFee 
    * @return clcommon__Fee__c 
    **/
    public static clcommon__Fee__c getPrePaidFee(Id appId, clcommon__Fee_Definition__c feeDefination, loan__Fee__c loanFee){
        clcommon__Fee__c fees = new clcommon__Fee__c();
        fees.genesis__Application__c = appId;
        fees.clcommon__Original_Amount__c = feeDefination.clcommon__Amount__c;
        fees.clcommon__Fee_Definition__c = feeDefination.Id;
        fees.clcommon__Type__c = feeDefination.clcommon__Type__c;
        fees.Loan_Fee__c = loanFee.Id;
        fees.clcommon__Date__c = currentSystemDate;
        return fees;
    }
    
    /**
    * @description | get loan fees
    * @author Supriyo Seni | 02-18-2025 
    * @param feeName 
    * @return loan__Fee__c 
    **/
    public static loan__Fee__c getLoanFee(String feeName){
        loan__Fee__c loanFee = new loan__Fee__c();
        loanFee.Name = feeName;
        loanFee.loan__Amount__c = 0.00;
        loanFee.loan__State__c = 'Active';
        loanFee.loan__Fee_Category__c = 'Loan';
        loanFee.loan__Time_of_charge__c = 'Pre-Paid Fees';
        loanFee.loan__Fee_Calculation_Method__c = 'Fixed';
        return loanFee;
    }

    /**
    * @description | insert Party Type
    * @author Supriyo Seni | 02-18-2025 
    * @param partyTypeName 
    * @return clcommon__Party_Type__c 
    **/
    public static clcommon__Party_Type__c getPartyType(String partyTypeName){
        clcommon__Party_Type__c partyType = new clcommon__Party_Type__c();
        partyType.Name = partyTypeName;
        return partyType;
    }

    /**
    * @description | insert party with partyAccount and application
    * @author Supriyo Seni | 02-18-2025 
    * @param customerAccount 
    * @param app 
    * @param partyType 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c createParty(Account customerAccount, genesis__Applications__c app, clcommon__Party_Type__c partyType){
        clcommon__Party__c partyObj = new clcommon__Party__c();
        partyObj.genesis__Application__c = app.Id;
        partyObj.clcommon__Account__c = customerAccount.Id;
        partyObj.clcommon__Type__c = partyType.Id;
        return partyObj;
    }

    /**
    * @description | create loan__Contract_Pre_Paid_Fee__c
    * @author Supriyo Seni | 02-18-2025 
    * @param loanId 
    * @param feeName 
    * @return loan__Contract_Pre_Paid_Fee__c 
    **/
    public static loan__Contract_Pre_Paid_Fee__c contractPrePaidFee(Id loanId, String feeName){
        loan__Contract_Pre_Paid_Fee__c contractFee = new loan__Contract_Pre_Paid_Fee__c();
        contractFee.loan__Amount__c = 1000;
        contractFee.loan__Fee_Name__c = feeName;
        contractFee.loan__Contract__c  = loanId;
        return contractFee;
    }

    /**
    * @description | create disbursal transaction distribution
    * @author Supriyo Seni | 02-18-2025 
    * @param disbursal 
    * @return loan__Disbursal_Txn_Distribution__c 
    **/
    public static loan__Disbursal_Txn_Distribution__c returnDisbursalTransactionDistribution(loan__Loan_Disbursal_Transaction__c disbursal){
        loan__Disbursal_Txn_Distribution__c disbursalDistribution = new loan__Disbursal_Txn_Distribution__c();
        disbursalDistribution.loan__Loan_Disbursal_Transaction__c = disbursal.id;
        return disbursalDistribution;
    }
    
    /**
    * @description | return contact used for community user creation
    * @author Supriyo Seni | 02-18-2025 
    * @return Contact 
    **/
    public static Contact returnCommunityUserContact(){

        Account acc = F2FTestHelper.getAccount();
        insert acc;
        Contact con = new Contact();
        con.FirstName = 'Test Contact';
        con.LastName = 'Test Contact';
        con.Email = 'testf2fcontact@id.com';
        con.Phone = acc.Phone;
        con.accountId = acc.Id;
        con.ownerId = userInfo.getUserId();
        insert con;
        return con;

    }
    
    /**
    * @description | return the address for the user
    * @author Supriyo Seni | 02-18-2025 
    * @param acc 
    * @return clcommon__Address__c 
    **/
    public static clcommon__Address__c createAddress(Account acc){
        clcommon__Address__c address = new clcommon__Address__c();
        address.clcommon__Account__c = acc.Id;
        address.clcommon__Address_Line_2__c = 'Test';
        address.Address_Line_3__c = 'Test';
        address.House_no_name__c = 'Test';
        address.clcommon__City__c = 'Test';
        address.clcommon__County__c = 'Test';
        address.clcommon__Zip_Code__c = '123321';
        address.Months_At_Current_Address__c = 3;
        address.Years_At_Current_Address__c = 3;
        address.clcommon__Previous_Address__c = false;
        address.clcommon__Current_Address__c = true;
        address.Same_as_Company_Address__c = false;
        return address;
    }
    
    /**
    * @description | create community user
    * @author Supriyo Seni | 02-18-2025 
    * @param profileName 
    * @return User 
    **/
    public static User returnCommUser(String profileName){

        Contact con = F2FTestHelper.returnCommunityUserContact();
        fullName = con.LastName;
        User usr = new User();
        usr.UserName = con.Email;
        usr.Alias = fullName.substring(0,3);
        usr.emailencodingkey = 'UTF-8';
        usr.languagelocalekey = 'en_US';
        usr.localesidkey = 'en_US';
        usr.timezonesidkey = 'America/Los_Angeles';
        usr.FirstName = con.FirstName;
        usr.LastName = con.LastName;
        usr.Email = con.Email;
        usr.Phone = con.Phone;
        usr.ContactId = con.Id;
        usr.CommunityNickName = con.Email;
        usr.ProfileId = [SELECT ID FROM profile WHERE name=: profileName limit 1].id;
        insert usr;
        return usr;
    }

    /**
    * @description | return account for creation
    * @author Supriyo Seni | 02-18-2025 
    * @param name 
    * @return Account 
    **/
    public static Account createAccount(String name){
        Account acc = new Account();
        acc.Name = 'Test' + name;
        acc.Phone = '1234567890';
        acc.clcommon__Email__c = 'test'+ name + '@mailinator.com';
        fullName = acc.Name;
        return acc;
    }

    /**
    * @description | return record type
    * @author Supriyo Seni | 02-18-2025 
    * @param name 
    * @param objName 
    * @return Id 
    **/
    public static Id fetchRecordType(String name, String objName){
        RecordType recordType = [SELECT Id , Name FROM RecordType WHERE  sobjecttype=: objName AND Name=: name LIMIT 1];
        return recordType.Id;
    }

    /**
    * @description | create Admin community user
    * @author Supriyo Seni | 02-18-2025 
    * @param profileName 
    * @return User 
    **/
    public static User returnAdminCommUser(String profileName){

        Contact con = F2FTestHelper.returnCommunityUserContact();
        fullName = con.LastName;
        User usr = new User();
        usr.UserName = con.Email;
        usr.Alias = fullName.substring(0,3);
        usr.emailencodingkey = 'UTF-8';
        usr.languagelocalekey = 'en_US';
        usr.localesidkey = 'en_US';
        usr.timezonesidkey = 'America/Los_Angeles';
        usr.FirstName = con.FirstName;
        usr.LastName = con.LastName;
        usr.Email = con.Email;
        usr.Phone = con.Phone;
        // usr.ContactId = con.Id;
        usr.CommunityNickName = con.Email;
        usr.ProfileId = [SELECT ID FROM profile WHERE name=: profileName limit 1].id;
        // insert usr;
        return usr;
    }

    /**
    * @description | creating cl product
    * @author Supriyo Seni | 02-18-2025 
    * @param productName 
    * @return clcommon__CL_Product__c 
    **/
    public static clcommon__CL_Product__c createCLproduct(String productName){
        clcommon__CL_Product__c product = new clcommon__CL_Product__c();
        product.clcommon__Product_Name__c = productName;
        insert product;
        return product;
    }

    /**
    * @description | creating Email Template
    * @author Supriyo Seni | 02-18-2025 
    * @param templateName 
    * @return EmailTemplate 
    **/
    public static EmailTemplate createEmailTemplate(String templateName){
        EmailTemplate template = new EmailTemplate();
        template.isActive = true;
        template.DeveloperName = templateName;
        // template.FolderId = UserInfo.getUserId();
        template.TemplateType = 'Text';
        template.Name = templateName;
        insert template;
        return template;
    }

    /**
    * @description | creating document category
    * @author Supriyo Seni | 02-18-2025 
    * @param name 
    * @return clcommon__Document_Category__c 
    **/
    public static clcommon__Document_Category__c createDocumentCategory(String name) {
        clcommon__Document_Category__c category = new clcommon__Document_Category__c();
        category.clcommon__Category_Name__c = name;
        insert category;
        return category;
    }

    /**
    * @description | creating quick quote
    * @author Supriyo Seni | 02-18-2025 
    * @return genesis__Quick_Quotes__c 
    **/
    public static genesis__Quick_Quotes__c createQuickQuote() {
        genesis__Quick_Quotes__c quickQuote = new genesis__Quick_Quotes__c();
        insert quickQuote;
        return quickQuote;
    }

    /**
    * @description | create custom settings
    * @author Supriyo Seni | 02-18-2025 
    **/
    public static void createCustomSettings() {
        FOLK2FOLK_Configurable_Parameters__c setting = new FOLK2FOLK_Configurable_Parameters__c();
        setting.Borrower_Portal_URL__c='abc.com';
        setting.Investor_Portal_URL__c='xyz.com';
        setting.Difference_between_Term_and_IOP__c = 1;
        setting.Interest_Percentage__c = 6.5;
        insert setting;
    }

    /**
    * @description | create Collateral Type
    * @author Supriyo Seni | 02-18-2025 
    * @param name 
    **/
    public static void createCollateralType(String name) {
        clcommon__Collateral_Type__c collateralType = new clcommon__Collateral_Type__c();
        collateralType.Name = name;
        insert collateralType;
    }

    /**
    * @description | get Collateral
    * @author Supriyo Seni | 02-18-2025 
    * @return clcommon__Collateral__c 
    **/
    public static clcommon__Collateral__c getCollateral() {
        F2FTestHelper.createCollateralType('Real Estate');
        List<clcommon__Collateral_Type__c> assertcollateralType = [ SELECT Id
                                                                    FROM clcommon__Collateral_Type__c
                                                                    WHERE Name = 'Real Estate' ];
        System.assertEquals(true, assertcollateralType.size()>0, 'Collateral type not inserted');
        clcommon__Collateral__c collateral = new clcommon__Collateral__c();
        collateral.clcommon__Estimated_Value__c = 500000;
        collateral.clcommon__Collateral_Name__c = 'Security';
        collateral.clcommon__Collateral_Type__c = assertcollateralType[0].Id;
        return collateral;
    }

    /**
    * @description | create Application Collateral
    * @author Supriyo Seni | 02-18-2025 
    * @param appId 
    * @param collateralId 
    **/
    public static void createApplicationCollateral(Id appId, Id collateralId) {
        genesis__Application_Collateral__c applicationCollateral = new genesis__Application_Collateral__c();
        applicationCollateral.genesis__Application__c = appId;
        applicationCollateral.genesis__Collateral__c = collateralId;
        insert applicationCollateral;
    }

    /**
    * @description | create relationship role
    * @author Supriyo Seni | 02-18-2025 
    * @param roleName 
    * @return String 
    **/
    public static String createRelationshipRole(String roleName) {
        clcommon__Reciprocal_Role__c role = new clcommon__Reciprocal_Role__c();
        role.Name = roleName;
        insert role;
        return role.Id;
    }

    /**
    * @description | create relationship
    * @author Supriyo Seni | 02-18-2025 
    * @param accountId 
    * @param relatedAccountId 
    * @param roleName 
    **/
    public static void createRelationship(Id accountId, Id relatedAccountId, String roleName) {
        clcommon__Relationship__c relationShip = new clcommon__Relationship__c();
        String role = createRelationshipRole(roleName);
        relationShip.clcommon__Entity__c = accountId;
        relationShip.clcommon__Related_Entity__c = relatedAccountId;
        relationShip.clcommon__Relationship__c = role;
        insert relationShip;
    }

    /**
    * @description | create POA relationship
    * @author Supriyo Seni | 02-18-2025 
    * @param poaAccountId 
    * @param relatedAccountId 
    **/
    public static void createPOARelationship(Id poaAccountId, Id relatedAccountId) {
        clcommon__Relationship__c relationship = new clcommon__Relationship__c();
        String role = createRelationshipRole(Folk2FolkConstantValues.POA_RECORD_TYPE);
        relationship.clcommon__Entity__c = poaAccountId;
        relationship.clcommon__Related_Entity__c = relatedAccountId;
        relationship.clcommon__Relationship__c = role;
        relationship.POA_Approved__c = true;
        insert relationship;
    }

    /**
    * @description | create Content version
    * @author Supriyo Seni | 02-18-2025 
    * @param title 
    * @return ContentVersion 
    **/
    public static ContentVersion createContentVersion(String title) {
        ContentVersion content=new ContentVersion();
        content.Title=title;
        content.PathOnClient='/' + content.Title + '.jpg';
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body');
        content.VersionData=bodyBlob;
        content.origin = 'H';
        return content;
    }

    /**
    * @description | create Content document link
    * @author Supriyo Seni | 02-18-2025 
    * @return ContentDocumentLink 
    **/
    public static ContentDocumentLink createContentDocumentLink() {
        ContentDocumentLink contentLink = new ContentDocumentLink();
        return contentLink;
    }

    /**
    * @description | create batch config
    * @author Supriyo Seni | 02-18-2025 
    **/
    public static void createBatchConfig() {
        Batch_Config__c batchConfig = new Batch_Config__c();
        batchConfig.F2FAutoWithdrawalBatch_Size__c = 200;
        batchConfig.F2FDocumentSubmissionReminderBatch__c = 200;
        batchConfig.F2FRescheduleLoan_Size__c = 200;
        batchConfig.F2FUpdatePeriodicFeeBatch_Size__c = 200;
        batchConfig.NotifyInvestorWhenBorrowerInArrearsJob__c = 200;
        batchConfig.RedemptionUpdateToInvestorsJob_Size__c = 200;
        batchConfig.UpdateMAFforLatePaymentJob_Size__c = 200;
        insert batchConfig;
    }

    /**
    * @description | create Integration Family
    * @author Supriyo Seni | 02-18-2025 
    * @param name 
    * @return intframework__Integration_Family__c 
    **/
    public static intframework__Integration_Family__c createIntegrationFamily(String name) {
        intframework__Integration_Family__c family = new intframework__Integration_Family__c();
        family.Name = name;
        return family;
    }

    /**
    * @description |  creating Integration API Type
    * @author Supriyo Seni | 02-18-2025 
    * @param family 
    * @param name 
    * @return intframework__Integration_API_Type__c 
    **/
    public static intframework__Integration_API_Type__c createAPIType(Id family, String name) {
        intframework__Integration_API_Type__c apiType = new intframework__Integration_API_Type__c();
        apiType.intframework__Integration_Family__c = family;
        apiType.Name = name;
        return apiType;
    }

    /**
    * @description | create Integration Provider
    * @author Supriyo Seni | 02-18-2025 
    * @param family 
    * @param name 
    * @return intframework__Integration_Provider__c 
    **/
    public static intframework__Integration_Provider__c createProvider(Id family, String name) {
        intframework__Integration_Provider__c provider = new intframework__Integration_Provider__c();
        provider.intframework__Integration_Family__c = family;
        provider.intframework__Provider_Name__c = name;
        provider.Name = name;
        provider.intframework__Active__c = true;
        return provider;
    }

    /**
    * @description | creating Integration Configuration
    * @author Supriyo Seni | 02-18-2025 
    * @param provider 
    * @param name 
    * @return intframework__Integration_Configuration__c 
    **/
    public static intframework__Integration_Configuration__c createConfiguration(Id provider, String name) {
        intframework__Integration_Configuration__c configuration = new intframework__Integration_Configuration__c();
        configuration.intframework__Integration_Provider__c = provider;
        configuration.Name = name;
        return configuration;
    }

    /**
    * @description | create Integration API Configuration
    * @author Supriyo Seni | 02-18-2025 
    * @param name 
    * @return intframework__Integration_API_Configuration__c 
    **/
    public static intframework__Integration_API_Configuration__c createAPIConfig(String name) {
        intframework__Integration_API_Configuration__c apiConfig = new intframework__Integration_API_Configuration__c();
        //apiConfig.intframework__Use_Response_Mocker__c = false;
        apiConfig.Name = name;
        return apiConfig;
    }

    /**
    * @description | Mock Class
    **/
    public class Mock implements HttpCalloutMock {
        /**
        * @description | Get Mock Response
        * @author Supriyo Seni | 02-18-2025 
        * @param req 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest req) {
            return getMockResponse(req.getEndpoint(), 200);
        }
    }

    /**
    * @description | method to get mock response according to endpoint
    * @author Supriyo Seni | 02-18-2025 
    * @param endpoint 
    * @param statusCode 
    * @return HttpResponse 
    **/
    public static HttpResponse getMockResponse(String endpoint, Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setHeader('Content-Type', 'application/json');
        if(endpoint.contains('decisionanalytics/crosscore/nprxuz82vn3d/services/v0/applications/3')) {
            res.setBody('{"responseHeader":{"requestType":"Bankwizard","clientReferenceId":"DM_RB-2","expRequestId":"RB000000660716","messageTime":"2023-12-27T04:31:20Z","overallResponse":{"decision":"CONTINUE","decisionText":"Continue","decisionReasons":["exactmatchonperson,exactmatchonaddress,bankaccountmatched"],"recommendedNextActions":[],"spareObjects":[]},"responseCode":"R0201","responseType":"INFO","responseMessage":"WorkflowComplete.","tenantID":"1f30200d9a3348dcb0821a3e3d3abe"},"clientResponsePayload":{"orchestrationDecisions":[{"sequenceId":"1","decisionSource":"BankWizard","decision":"ACCEPT","decisionReasons":["exactmatchonperson,exactmatchonaddress,bankaccountmatched"],"score":0,"decisionText":"Continue","nextAction":"Continue","decisionTime":"2023-12-27T04:31:21Z"}],"decisionElements":[{"serviceName":"Bankwizard","applicantId":"APPLICANT_1","decision":"Match","matches":[{"name":"Accountowner","value":"Match"}],"scores":[{"name":"Personaldetails","score":9,"type":"SCORE"},{"name":"Address","score":9,"type":"SCORE"}],"records":[{"externalLookups":[{"source":"BankWizardService","externalData":[{"fieldName":"accountVerificationStatus","fieldValue":"Match"},{"fieldName":"accountOwnerMatch","fieldValue":"Match"},{"fieldName":"personalDetailsScore","fieldValue":"9"},{"fieldName":"addressScore","fieldValue":"9"}],"contactId":"MainContact_1"}]}]}]},"originalRequestData":{"source":"WEB","control":[{"value":"MODELA","option":"MODEL_CODE"}],"contacts":[{"person":{"typeOfPerson":"APPLICANT","personDetails":{"dateOfBirth":"1973-08-31"},"names":[{"type":"CURRENT","surName":"RAJAPAKSA","id":"MainPersonName_1","firstName":"SHARON"}]},"id":"MainContact_1","bankAccount":{"type":"Single","sortCode":"070116","id":"MainBankAccount_1","clearAccountNumber":"00035305"},"addresses":[{"street2":"MARKYATE","street":"HIGHSTREET","postTown":"ST.ALBANS","postal":"AL38LE","id":"MainAppAddress_1","county":"HERTFORDSHIRE","buildingNumber":"80B","buildingName":"80B","addressType":"CURRENT"}]}],"application":{"applicants":[{"type":"INDIVIDUAL","knownCustomer":true,"id":"APPLICANT_1","contactId":"MainContact_1","consent":true,"applicantType":"APPLICANT"}]}}}');
        } else if(endpoint.contains('https://uk-api.experian.com/oauth2/experianone/v1/token')){
            res.setBody('{"issued_at":"1707406575","expires_in":"1800","token_type":"Bearer","access_token":"eyJraWQiOiJJSmpTMXJQQjdJODBHWjgybmNsSlZPQkF3V3B3ZTVYblNKZUdSZHdpcEY5IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJTWVNURU0uVUFUQVBJQGZvbGsyZm9sa2x0ZC5jb20iLCJFbWFpbCI6bnVsbCwiRmlyc3ROYW1lIjpudWxsLCJpc3MiOiJFWFBFUklBTiIsIkxhc3ROYW1lIjpudWxsLCJleHAiOjE3MDc0MDgzNzUsImlhdCI6MTcwNzQwNjU3NSwianRpIjoiNDI5MjE4OTQtMWY3ZC00ZjA5LTliNjItNTNhMDU4OGM2MTUyIn0.odBunrKw-rvWHjZL1ntQWlpp9vuRtoyErF9JWvAS92413O2C1_ZN5eVMR6kob1WiBbvjO25ux1jgYNhkmeKtXgLbLO-2G11l8gImu2WOvLlKKZsPQWpwYneA3yg4HBn4hrwtZSyPiX4-Cp8LFApb-4NZr_8wqvic3-vf7QBID9ivyDKJF5caFS25HqowEQ49lvBUoYMDwKiY0nrAzfJobbUAzzFcWB1MqPzImAa6HwzgEanjKYrXz-QS0Gt9281zRWjzN-kpTGOGmVBSCOOfCG6fwftP5DsH7tIgDS6GKVJdKzx1Q65U5BBEJ4AlG1vtiKvUXAikCe2ELNgHVYlCcw","refresh_token":"4OOniEhrqtRftVPiv67tS2yUWak3myUL"}}');
        } else if(endpoint.contains('/monitorApi/v1_0/api/businesses?uniqueId=') || endpoint.contains('/monitorApi/v1_0/api/persons?uniqueId=')) {
            res.setBody('');
            res.setStatusCode(204);
        } else if(endpoint.contains('monitorApi/v1_0/api/businesses') || endpoint.contains('monitorApi/v1_0/api/persons')
                || endpoint.contains('/monitorApi/v1_0/api/businesses?uniqueId=') || endpoint.contains('/monitorApi/v1_0/api/persons?uniqueId=')) {
            res.setBody('1234');
        } else if(endpoint.contains('risk/consumer/v2/dataselect/application')) {
            res.setBody('{"Response":{"Applicants":[{"ApplicantIdentifier":1,"Person":{"Title":"MRS.","Forename":"GEMMA","MiddleName":"KERNE","Surname":"MASIC","Suffix":"","Gender":"","DateOfBirth":"1984-09-20","FormattedName":"Mrs. G Masic","Age":{"Years":"36","Months":"09"}},"Alias":[{"Title":"MRS.","Forename":"GEMMA","MiddleName":"KERNE","Surname":"MASIC","Suffix":"","Gender":""}]}],"Locations":[{"LocationIdentifier":1,"UKLocation":{"HouseNumber":"17","Street":"FOX LEA WALK","District":"SEGHILL","PostTown":"CRAMLINGTON","County":"NORTHUMBERLAND","Postcode":"NE237TD"}}],"Residencies":[{"ApplicantIdentifier":1,"LocationIdentifier":1,"Type":"C","TimeAt":{"Years":"03","Months":"01"},"ResidentFrom":"2018-05-07","ResidentTo":"2021-06-07","VRConfirmation":{"Confirmed":"N","YrsERSP":"09","YrsERSF":"09"},"CanBeSearched":"Y"}],"FullConsumerData":{"ConsumerDataSummary":{"SummaryDetails":{"DataOverflow":"N","PublicInfoSummary":{"Number":0},"CAISSummary":{"CAISPrevSearches":{"NumberUpTo3Months":0,"Num3To6Months":0,"Num6To12Months":0,"TotalNumber":0}},"SummaryFlags":{"CIFAS":"N","CML":"N","PreviousOccupant":"Y","NoConfirmAtPrevLoc":"N","Arrangement":"N","ReportedDeceased":"N","ReportedGoneAway":"N","ClaimedOnCreditIns":"N","DebtManagement":"N","AccountQuery":"N","Recourse":"N","VoluntaryTerm":"N","PartSettle":"N","DebtAssign":"N","OwnAccount":"N","OwnSearch":"N","PreviousLocation":"N","AdditionalLocation":"N","ForwardLocation":"N"},"NoCCount":"0","LocationConfirmCnt":1,"LocationConfirm":[{"Location":"C","Level":"1","Source":"V"}]}},"ConsumerData":{"VotersRollLocation":[{"LocationIndicator":"C","ApplicantIndicator":"1","VRollStreetDetails":[{"StreetMatchLevel":"4","InformationSource":"A","MOSAICCode":"0","PAFDistrictNumber":"241","SegmentIDNumber":"1","ACORNCode":"99","BatchNumber":"001","VRLocation":{"Street":"FOX LEA WALK","District":"SEGHILL","PostTown":"CRAMLINGTON","County":"NORTHUMBERLAND","Postcode":"NE237TD"}}]}],"VotersRollPerson":[{"LocationIndicator":"C","ApplicantIndicator":"1","VRollPersonDetails":[{"MatchDetails":{"HouseMatchLevel":"4","BureauRefCategory":"1","MatchTo":"1","MatchType":"I"},"InformationSource":"A","Sex":"F","SegmentIDNumber":1,"SurnameReg":"2001","POCCYear":2011,"DatesRegLeft":"082001082010","Name":{"Forename":"GEMMA","MiddleName":"KERNE","Surname":"CROXFORD"},"HouseNumber":"17"}]}],"Association":[{"LocationIndicator":"C","ApplicantIndicator":"1","AssociationDetails":[{"MatchDetails":{"StreetMatchLevel":"4","HouseMatchLevel":"4","BureauRefCategory":"1"},"Source":"S","DateOfBirth":"1984-09-20","InformationType":"I","CompanyType":"00","InformationDate":"2021-06-07","InformationSource":"P","InformationSupplier":"J6554","DOBAssociateOrAlias":"1984-09-20","AssociateName":{"Title":"MRS.","Forename":"GEMMA","MiddleName":"KERNE","Surname":"MASIC"},"Name":{"Title":"MRS.","Forename":"GEMMA","MiddleName":"KERNE","Surname":"MASIC"},"Location":{"HouseNumber":"17","Street":"FOX LEA WALK","District":"SEGHILL","PostTown":"CRAMLINGTON","County":"NORTHUMBERLAND","Postcode":"NE23 7TD"}},{"MatchDetails":{"StreetMatchLevel":"4","HouseMatchLevel":"4","BureauRefCategory":"1"},"Source":"S","DateOfBirth":"1984-09-20","InformationType":"F","InformationDate":"2021-06-07","InformationSource":"P","InformationSupplier":"J6229","DOBAssociateOrAlias":"1984-09-20","AssociateName":{"Title":"MRS.","Forename":"GEMMA","MiddleName":"KERNE","Surname":"MASIC"},"Name":{"Title":"MRS.","Forename":"GEMMA","MiddleName":"KERNE","Surname":"MASIC"},"Location":{"HouseNumber":"17","Street":"FOX LEA WALK","PostTown":"SEGHILL","County":"NORTHUMBERLAND","Postcode":"NE23 7TD"}}]}]},"ControlDetails":{"AccountNumber":"J6554","CAISSource":"000","CMLCode":"000","SeeVoters":"Y","SeeAssociations":"Y","SeePublicInfo":"Y","SeeCIFAS":"N","SeeCAIS":"N","SeeCML":"N","SeeCAPS":"Y","SeeAddrLinks":"Y","SearchDate":"2021-06-07","SearchTime":"084847","SeeGAIN":"N","SeeDirectors":"N"}},"ConsumerSummary":{"PremiumValueData":{"TPD":{"NDHHO":"Y"},"CII":{"NDSPCII":0,"NDSPACII":0},"Mosaic":{"EA4M01":0,"EA4M02":0,"EA4M03":0,"EA4M04":0,"EA4M05":0,"EA4M06":0,"EA4M07":0,"EA4M08":0,"EA4M09":0,"EA4M10":0,"EA4M11":0,"EA4M12":0,"EA4T01":0,"EA5T01":0,"EA5T02":0,"NDG01":4,"EA4N01":0,"EA4N02":0,"EA4N03":0,"EA4N04":0,"EA4N05":0,"NDG02":843,"NDG03":3,"NDG04":286,"NDG05":0,"NDG06":0,"NDG07":0,"NDG08":0,"NDG09":0,"NDG10":0,"NDG11":0,"NDG12":0},"Scoring":{"NDSI21":"10CON","E5S01":"1","E5S02":"3","E5S041":"10","E5S051":775,"E5S042":0,"E5S052":-999,"E5S043":0,"E5S053":-999,"NDHHOSCORE":0,"NDVALSCORE":0},"AddrLink":{"NDLNK01":"N"},"Director":{"NDDIRSP":"N","NDDIRSPA":"N"},"AgeDoB":{"NDDOB":"84-09-20","EA5S01":36,"EA4S01":0,"EA4S03":0,"EA4S05":0,"EA4S07":0}},"Summary":{"ElectoralRoll":{"E4Q01":2,"E4Q02":2,"E4Q03":0,"E4Q04":0,"E4Q05":5,"E4Q06":5,"E4Q07":0,"E4Q08":0,"E4Q09":5,"E4Q10":5,"E4Q11":0,"E4Q12":0,"E4Q13":5,"E4Q14":5,"E4Q15":0,"E4Q16":0,"E4Q17":"1","E4Q18":"1","E4R01":1,"E4R02":"NE237TD","EA4R01PM":0,"EA4R01CJ":0,"EA4R01PJ":0,"NDERL01":1,"NDERL02":1,"EA2Q01":3,"EA2Q02":0,"NDERLMACA":"P","EA5U01":1,"EA5U02":0},"PublicInfo":{"E1A01":0,"E1A02":0,"E1A03":0,"EA1C01":"N","EA1D01":0,"EA1D02":0,"EA1D03":0,"E2G01":0,"E2G02":0,"E2G03":0,"EA2I01":"N","EA2J01":0,"EA2J02":0,"EA2J03":0,"EA4Q06":"N","SPBRPRESENT":"N","SPABRPRESENT":"N"},"CAIS":{"E1A04":0,"E1A05":0,"E1A06":0,"E1A07":0,"E1A08":0,"E1A09":0,"E1A10":0,"E1A11":0,"E1B01":0,"E1B02":0,"E1B03":"N","E1B04":0,"E1B05":"N","E1B06":0,"E1B07":"N","E1B08":"N","E1B09":0,"E1B10":0,"E1B11":0,"E1B12":0,"E1B13":0,"NDECC01":0,"NDECC02":0,"NDECC03":0,"NDECC04":0,"NDECC07":0,"NDECC08":0,"E1C01":"N","E1C02":0,"E1C03":0,"E1C04":0,"E1C05":0,"E1C06":0,"EA1B02":0,"E1D01":0,"E1D02":0,"E1D03":0,"E1D04":0,"NDHAC01":0,"NDHAC02":0,"NDHAC03":0,"NDHAC04":0,"NDHAC05":0,"NDHAC09":0,"NDINC01":0,"EA1F02":"N","EA1F03":"N","E2G04":0,"E2G05":0,"E2G06":0,"E2G07":0,"E2G08":0,"E2G09":0,"E2G10":0,"E2G11":0,"E2H01":0,"E2H02":0,"E2H03":"N","E2H04":0,"E2H05":"N","E2H06":0,"E2H07":"N","E2H08":"N","E2H09":0,"E2H10":0,"E2H11":0,"E2H12":0,"E2H13":0,"NDECC05":0,"NDECC09":0,"NDECC10":0,"E2I01":"N","E2I02":0,"E2I03":0,"E2I04":0,"E2I05":0,"E2I06":0,"EA2H02":0,"E2J01":0,"E2J02":0,"E2J03":0,"E2J04":0,"NDHAC10":0,"NDHAC06":0,"NDHAC07":0,"NDHAC08":0,"NDINC02":0,"EA2L02":"N","EA2L03":"N","NDECC06":0,"NDINC03":0},"CAPS":{"E1E01":0,"E1E02":0,"EA1B01":0,"NDPSD01":0,"NDPSD02":0,"NDPSD03":0,"NDPSD04":0,"NDPSD05":0,"NDPSD06":0,"EA1E01":0,"EA1E02":0,"EA1E03":0,"EA1E04":0,"E2K01":0,"E2K02":0,"EA2H01":0,"NDPSD07":0,"NDPSD08":0,"NDPSD09":0,"NDPSD10":0,"EA2K01":0,"EA2K02":0,"EA2K03":0,"EA2K04":0,"NDPSD11":0},"CIFAS":{"EA1A01":"N","EA2G01":"N","EA4P01":"N","EA4P02":0},"CML":{"EA1C02":"N","EA2I02":"N"},"GAIN":{"EA1G01":"N","EA1G02":"N","EA2M01":"N","EA2M02":"N"},"NOC":{"EA4Q07":"N","EA4Q08":"N","EA4Q09":"N","EA4Q10":"N","EA4Q11":"N","EA4Q01":"N","EA4Q02":"N","EA4Q03":"N","EA4Q04":"N","EA4Q05":"N"},"TPD":{"NDOPTOUT":"N"}}},"ClientData":{"ClientAccountNumber":"J6554","ClientBranchNumber":"","ClientRef":"","JobNumber":"","ExperianReference":"5FDJS76HRS"},"ThirdPartyData":{"OutcomeCode":"01"}},"Metrics":{"ProcessStarted":"2021-06-07T07:48:47.162Z","ProcessEnded":"2021-06-07T07:48:47.580Z","TimeTakeninMs":418,"Steps":[{"Name":"Authorisation","TimeTakeninMs":24},{"Name":"Validation","TimeTakeninMs":1},{"Name":"TransformationIn","TimeTakeninMs":3},{"Name":"ServiceCall","TimeTakeninMs":378},{"Name":"TransformationOut","TimeTakeninMs":7}]}}');
        } else if(endpoint.contains('/oauth2/v1/token')) {
            res.setBody('{"access_token":"abcd"}');
        } else if(endpoint.contains('commercialdelphiscore')) {
            res.setBody('{"BusinessRef":"01234567","CommercialDelphi":{"CommDelphiScore":0,"CommDelphiBand":"7","CommDelphiBandText":"Dissolved","OverrideIndicator":"N","CreditRating":0,"CreditRatingOverrideIndicator":"N","CreditLimit":0,"CreditLimitOverrideIndicator":"N","ParentIndicator":"N","CreditText":"The company has been dissolved.","CreditTextOverrideIndicator":"N"}}');
        } else if(endpoint.contains('delphicashflow')) {
            res.setBody('{"RegNumber": "10813901","DelphiCashflowScore": 2544,"DelphiCashflowScorecard": "123"}');
        } else if(endpoint.contains('risk/business/v3/decisioningplus/limiteddecisionandreport')) {
            res.setBody('{"Decision":"Accept","DecisionDetails":{"DecisionDate":"2021-07-05T15:38:37.000+01:00","BusinessName":"EXPERIAN LIMITED","LegalEntity":"L","BusinessRef":"00653331","CreditPolicyId":"2544","CreditPolicyName":"Test Credit Policy","RecommendedCreditLimit":"6900000","CommercialDelphiScore":"100","CommercialDelphiRiskBand":"Very Low Risk","Decision":[{"type":"Final","Value":"Accept"}],"TriggeredRule":[{"name":"Banking & Financial Services-CS","ruleNumber":"1","type":"DecisionTree","Value":"If score is 100 to 101 then Accept."}],"Override":[]},"Report":{"LtdCompanyData":{"RegNumber":"00653331","CommercialName":"EXPERIAN LIMITED","Identification":{"LegalStatus":"2","IncorporationDate":"1960-03-22","FilingDetails":{"DatabaseAccountsOutOfDate":"N","FiledAccountsOutOfDate":"N","LatestAccounts":"2020-03-31","LatestReturns":"2020-10-20"},"PrevSearches":{"NumPrevSearch":"12","NumPrevSearch3Mth":"3","NumPrevSearch6Mth":"6","NumPrevSearch12Mth":"12"}},"ManagementInfo":{"LatestReturns":"2020-10-20","NumDirs":"46","NumSecs":"4","NumCurrDirs":"5","NumPrevDirs":"41","DirectorAvgAge":"0","DirectorAvgLength":"52","NumCurrDirectorLast12":"0","NumAppointmentsLast12":"0","NumResignationsLast12":"0","NumDisqualifications":"0"},"PaymentPerformance":{"PaymentFull":{"AvgDBT3Mnths":"12","AvgDBT6Mnths":"11","AvgDBT12Mnths":"12"}},"Financials":{"Accounts":[{"DateOfAccounts":"2020-03-31","BalanceSheet":{"TangibleAssetsDetails":{"TangibleAssets":"57000","LandBuildings":"23000","OtherTangibleAssets":"34000"},"TotalFixedNonCurrentAssets":"728000","LongTermFinancialLiabilitiesDetails":{"FinanceLeasesHirePurchase":"16000","FinanceLease":"16000","HirePurchase":"0","OtherLongTermLoans":"0"},"SharePremium":"17000","RetainedEarnings":"196000","RevaluationReserve":"0","Other":"0","TotalShareholdersFunds":"213000","NetWorth":"-44000"},"ProfitLoss":{"OperatingProfit":"55000","InterestPayableDetails":{"InterestPayable":"14000"},"NetProfitLoss":"-68000"}}],"Ratios":[{"DebtGearing":"-1172.73"}]},"Mortgages":{"NumMortgages":"0"}}}}');
        } else if (endpoint.contains('/services/apexrest/peer/v1/accounts/getLenderStatement/')){
            res.setBody('{  "status": "SUCCESS",  "rowNumber": -1,  "response": [    {      "txnObj": {        "attributes": {          "type": "loan__Investor_Fund_Transaction__c",          "url": "/services/data/v32.0/sobjects/loan__Investor_Fund_Transaction__c/aAa3L0000004DAGSA2"        },        "Id": "aAa3L0000004DAGSA2",        "Name": "IFT-000001031",        "loan__Transaction_Amount__c": 100000,        "loan__Transaction_Type__c": "DEPOSIT",        "loan__Transaction_Date__c": "2019-03-15",        "loan__Balance_After__c": 100000,        "loan__Cleared__c": true,        "loan__Reversed__c": false,        "CreatedDate": "2021-09-23T16:23:25.000+0000",        "loan__Rejected__c": false      },      "transactionType": "DEPOSIT",      "transactionId": "IFT-000001031",      "transactionDatetime": "2019-03-15T00:00:00.000Z",      "transactionDate": "2019-03-15",      "transactionAmount": 100000,      "sharePercent": null,      "reversed": false,      "relatedLoan": null,      "rejected": false,      "principal": null,      "lateFee": null,      "interest": null,      "fee": null,      "cleared": true,      "availableFunds": 100000,      "amountInFunding": 0    },    {      "txnObj": {        "attributes": {          "type": "loan__Investor_Loan_Account_Txns__c",          "url": "/services/data/v32.0/sobjects/loan__Investor_Loan_Account_Txns__c/aAb3L00000001JVSAY"        },        "Id": "aAb3L00000001JVSAY",        "Name": "ILTID-0000001609",        "loan__Txn_Amount__c": 80000,        "CreatedDate": "2021-09-23T16:25:23.000+0000",        "loan__Interest_Service_Charge__c": 0,        "loan__Late_Fee_Service_Charge__c": 0,        "loan__Interest_Paid__c": 0,        "loan__Late_Fees_Paid__c": 0,        "loan__Principal_Paid__c": 0,        "loan__Post_Date__c": "2019-03-15",        "loan__Transaction_Date__c": "2019-03-15",        "loan__Vat__c": 0,        "loan__Tax__c": 0,        "loan__Charged_Off_Principal__c": 0,        "loan__Charged_Off_Interest__c": 0,        "loan__Charged_Off_Fees__c": 0,        "loan__Investor_Loan__c": "aAc3L00000002CoSAI",        "loan__Total_Service_Charge__c": 0,        "loan__Txn_Code__c": "ACTIVE",        "loan__Txn_Description__c": "Investment Activated",        "loan__Investor_Loan__r": {          "attributes": {            "type": "loan__Investor_Loan__c",            "url": "/services/data/v32.0/sobjects/loan__Investor_Loan__c/aAc3L00000002CoSAI"          },          "Id": "aAc3L00000002CoSAI",          "loan__Status__c": "Active",          "loan__Share_rounded__c": 80,          "loan__Loan__c": "aAq3L0000004D3CSAU",          "loan__Loan__r": {            "attributes": {              "type": "loan__Loan_Account__c",              "url": "/services/data/v32.0/sobjects/loan__Loan_Account__c/aAq3L0000004D3CSAU"            },            "Id": "aAq3L0000004D3CSAU",            "Name": "LAI-00000580",            "loan__Account__c": "0013L00000DGo90QAD",            "loan__Account__r": {              "attributes": {                "type": "Account",                "url": "/services/data/v32.0/sobjects/Account/0013L00000DGo90QAD"              },              "Id": "0013L00000DGo90QAD"            }          }        }      },      "transactionType": "WITHDRAWAL - Invested in Loan",      "transactionId": "ILTID-0000001609",      "transactionDatetime": "2019-03-15T00:00:00.000Z",      "transactionDate": "2019-03-15",      "transactionAmount": 80000,      "sharePercent": 80,      "reversed": null,      "relatedLoan": "LAI-00000580",      "rejected": null,      "principal": null,      "lateFee": null,      "interest": null,      "fee": null,      "cleared": null,      "availableFunds": 20000,      "amountInFunding": 0    }  ],  "errorNumber": 0,  "errorMessage": null,  "errorCode": "NO_ERROR",  "content": []}');
        }
        return res;
    }
    
    /**
    * @description | method to create clcommon__Questionnaire_Definition__c instance
    * @author Supriyo Seni | 02-18-2025 
    * @param name 
    * @return clcommon__Questionnaire_Definition__c 
    **/
    public static clcommon__Questionnaire_Definition__c createQuestionnaireDefination(String name){
        clcommon__Questionnaire_Definition__c questionDefination = new clcommon__Questionnaire_Definition__c();
        questionDefination.Name = name;
        return questionDefination;
    }

    /**
    * @description | create questionarei instance for an account
    * @author Supriyo Seni | 02-18-2025 
    * @param accountId 
    * @param questionairedDef 
    * @return clcommon__Questionnaire_Instance__c 
    **/
    public static clcommon__Questionnaire_Instance__c createQuestionnaireInstance(Id accountId, Id questionairedDef){
        clcommon__Questionnaire_Instance__c questionInstance = new clcommon__Questionnaire_Instance__c();
        questionInstance.Account__c = accountId;
        questionInstance.clcommon__Questionnaire_Definition__c = questionairedDef;
        questionInstance.IP_Address__c = '8.8.8.8';
        questionInstance.Random_Section_Index__c = '1,2,3,4,5,6,7,8,9,10,11,12,13';
        return questionInstance;
    }

    /**
    * @description | method to create clcommon__Questionnaire_Section_Definition__c instance    
    * @author Supriyo Seni | 02-18-2025 
    * @param name 
    * @param questionDefinationId 
    * @param risk 
    * @return clcommon__Questionnaire_Section_Definition__c 
    **/
    public static clcommon__Questionnaire_Section_Definition__c createQuestionnaireSectionDefination(String name, Id questionDefinationId, String risk){
        clcommon__Questionnaire_Section_Definition__c questionSectionDefination = new clcommon__Questionnaire_Section_Definition__c();
        questionSectionDefination.Name = name;
        questionSectionDefination.clcommon__Questionnaire_Definition__c = questionDefinationId;
        questionSectionDefination.clcommon__Section_Name__c = risk;
        return questionSectionDefination;
    }

    /**
    * @description | method to create clcommon__Question_Definition__c instance
    * @author Supriyo Seni | 02-18-2025 
    * @param description 
    * @param title 
    * @return clcommon__Question_Definition__c 
    **/
    public static clcommon__Question_Definition__c createQuestionDefination(String description, String title){
        clcommon__Question_Definition__c questionDefination = new clcommon__Question_Definition__c();
        questionDefination.clcommon__Question_Description__c = description;
        questionDefination.Question_Title__c = title;
        return questionDefination;
    }

    /**
    * @description | method to create n number of question responses
    * @author Supriyo Seni | 02-18-2025 
    * @param questionInstanceId 
    * @param maxNumber 
    * @return List<clcommon__Question_Response__c> 
    **/
    public static List<clcommon__Question_Response__c> createQuestionResponse(String questionInstanceId, Integer maxNumber){
        List<clcommon__Question_Response__c> questionResponseList  = new List<clcommon__Question_Response__c>();
        for (Integer count = 0; count < maxNumber; count++) {
            clcommon__Question_Response__c questionResponse = new clcommon__Question_Response__c();
            questionResponse.clcommon__Questionnaire_Instance__c = questionInstanceId;
            questionResponse.Score__c = 1;
            questionResponseList.add(questionResponse);
        }
        return questionResponseList;
    }

    /**
    * @description | method to create clcommon__Question__c instance
    * @author Supriyo Seni | 02-18-2025 
    * @param questionId 
    * @param name 
    * @param sectionDefinationId 
    * @return clcommon__Question__c 
    **/
    public static clcommon__Question__c createQuestion(Id questionId, String name, Id sectionDefinationId){
        clcommon__Question__c question = new clcommon__Question__c();
        question.clcommon__Question_Definition__c = questionId;
        question.clcommon__Questionnaire_Section_Definition__c	= sectionDefinationId;
        question.Name = name;
        return question;
    }
    
    /**
    * @description | method to create clcommon__Answer_Definition__c instance
    * @author Supriyo Seni | 02-18-2025 
    * @param questionId 
    * @return clcommon__Answer_Definition__c 
    **/
    public static clcommon__Answer_Definition__c createAnswerDefination(Id questionId){
        clcommon__Answer_Definition__c answerList = new clcommon__Answer_Definition__c();
        answerList.clcommon__Question_Definition__c = questionId;
        answerList.clcommon__Score__c	= 1;
        answerList.clcommon__Value__c = 'Test value';
        return answerList;
    }

    /**
    * @description | method to create clcommon__category_attachment_association__c instance
    * @author Supriyo Seni | 02-18-2025 
    * @param docCategoryId 
    * @return clcommon__category_attachment_association__c 
    **/
    public static clcommon__category_attachment_association__c createAttachmentAssociation(Id docCategoryId){
        clcommon__category_attachment_association__c attachment = new clcommon__category_attachment_association__c();
        attachment.clcommon__Document_Category__c = docCategoryId;
        return attachment;
    }

    /**
    * @description | method to create Attachment instance
    * @author Supriyo Seni | 02-18-2025 
    * @param appId 
    * @return Attachment 
    **/
    public static Attachment createAttachment(Id appId){
        Attachment attachmentT = new Attachment(
        ParentId = appId,
        Body = Blob.valueOf('Unit Test ContentVersion Body'),
        Name = 'abc.pdf');
        insert attachmentT;
        return attachmentT;
    }

    /**
    * @description | method to create loan__Coborrower__c instance
    * @author Supriyo Seni | 02-18-2025 
    * @param accountId 
    * @param contactId 
    * @param partyType 
    * @return loan__Coborrower__c 
    **/
    public static loan__Coborrower__c getLoanCoBorrower(String accountId, String contactId, String partyType) {
        loan__Coborrower__c coBorrower = new loan__Coborrower__c ();
        coBorrower.loan__Account__c = accountId;
        coBorrower.loan__Loan__c = contactId;
        coBorrower.loan__Party_Type__c  = partyType;
        return coBorrower;
    }

    /**
    * @description | method to create loan__Loan_account_Due_Details__c instance
    * @author Supriyo Seni | 02-18-2025 
    * @return loan__Loan_account_Due_Details__c 
    **/
    public static loan__Loan_account_Due_Details__c createBill(){
        loan__Loan_account_Due_Details__c dueDetails = new loan__Loan_account_Due_Details__c();
        return dueDetails;
    }

    /**
    * @description | method to create loan__Loan_Transaction_Summary__c instance
    * @author Supriyo Seni | 02-18-2025 
    * @param contractId 
    * @param type 
    * @return loan__Loan_Transaction_Summary__c 
    **/
    public static loan__Loan_Transaction_Summary__c contractTransaction(Id contractId, String type){
        loan__Loan_Transaction_Summary__c trans = new loan__Loan_Transaction_Summary__c();
        trans.loan__Last_Transaction_Type__c = type;
        trans.loan__Loan_Account__c = contractId;
        return trans;
    }


    /**
    * @description | method to create loan__Loan_Payment_Transaction__c instance
    * @author Supriyo Seni | 02-18-2025 
    * @param contract 
    * @return loan__Loan_Payment_Transaction__c 
    **/
    public static loan__Loan_Payment_Transaction__c createLoanPayment(loan__Loan_Account__c contract){
        loan__Loan_Payment_Transaction__c lpt = F2FTestHelper.returnLoanPayment(contract);
        lpt.loan__Principal__c = 2000;
        lpt.loan__Fees__c = 1000;
        lpt.loan__Interest__c = 2000;
        insert lpt;
        return lpt;
    }

    /**
    * @description : this method returns user for test classes
    * @author Rohit Roy | 14/11/2023
    * @param profileName
    * @return User
    **/
    public static User getUser(String profileName){
        User objUser = new User();
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        objUser.Username = uniqueName + '@test' + orgId + '.org';
        objUser.Alias = uniqueName.substring(18, 23);
        objUser.LastName = 'Test';
        objUser.TimeZoneSidKey = 'Europe/London';
        objUser.LocaleSidKey = 'en_AU';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.Email = uniqueName + '@test' + orgId + '.org';
        List<Profile> profileList =[SELECT Id
                                        FROM Profile
                                        WHERE Name =: profileName];
        objUser.ProfileId = profileList[0].Id;
        return objUser;
    }

    /**
    * @description : this method returns investor portal user for test classes
    * @author Rohit Roy | 14/11/2023
    * @param contactObj
    * @return User
    **/
    public static User getPortalUser(Contact contactObj){
        User userObj = new User();
        userObj.UserName = contactObj.Email;
        userObj.FirstName = contactObj.FirstName;
        userObj.LastName = contactObj.LastName;
        userObj.Email = contactObj.Email;
        userObj.ContactId = contactObj.Id;
        userObj.CommunityNickName = contactObj.Email;
        userObj.ProfileId = [SELECT ID
                        FROM profile
                        WHERE name =: Folk2FolkConstantValues.INVESTOR_COMMUNITY_PROFILE
                        LIMIT 1].id;
        userObj.Alias = userObj.LastName.substring(0, 3);
        userObj.emailencodingkey = 'UTF-8';
        userObj.languagelocalekey = 'en_US';
        userObj.localesidkey = 'en_AU';
        userObj.timezonesidkey = 'Europe/London';
        return userObj;
    }

    /**
    * @description | This method returns custom settings for test classes
    * @author Rohit Roy | 14/11/2023
    * @return FOLK2FOLK_Configurable_Parameters__c
    **/
    public static FOLK2FOLK_Configurable_Parameters__c getCustomSettings() {
        FOLK2FOLK_Configurable_Parameters__c configValusObj = new FOLK2FOLK_Configurable_Parameters__c();
        configValusObj.Borrower_Portal_URL__c='abc.com';
        configValusObj.Investor_Portal_URL__c='xyz.com';
        configValusObj.Difference_between_Term_and_IOP__c = 1;
        configValusObj.Interest_Percentage__c = 6.5;
        return configValusObj;
    }
}