/**
 * @description       : This class the helper class to support loan functionality
 * @author            : Akashdip Sinha
 * @group             : Cloudkaptan Consultancy Services Pvt. Ltd
 * @last modified on  : 02-11-2025
 * @last modified by  : Supriyo Seni
**/
@isTest
public inherited sharing class LoanTestHelper {
    
    /**
    * @description | create charges record
    * @author Supriyo Seni | 02-11-2025 
    * @param loanId 
    * @param feeId 
    * @return loan__Charge__c 
    **/
    public static loan__Charge__c getCharge(Id loanId,Id feeId){
        Date currentSystemDate = Date.today();
        loan__Charge__c chargeObj = new loan__Charge__c();
        chargeObj.loan__Loan_Account__c = loanId;
        chargeObj.loan__Original_Amount__c = 100;
        chargeObj.loan__Transaction_Creation_Date__c = currentSystemDate;
        chargeObj.loan__Fee__c = feeId;
        chargeObj.loan__Date__c = currentSystemDate;
        return chargeObj;
    }

    /**
    * @description : create fee payment record for test class
    * @author Rohit Roy | 16/01/2024 
    * @param chargeId 
    * @param loanPaymentId 
    * @return loan__Fee_Payment__c 
    **/
    public static loan__Fee_Payment__c getFeePayment(Id chargeId, Id loanPaymentId){
        loan__Fee_Payment__c feePaymentObj = new loan__Fee_Payment__c();
        feePaymentObj.loan__Transaction_Amount__c = 30;
        feePaymentObj.loan__Transaction_Date__c = Date.today();
        feePaymentObj.loan__Charge__c = chargeId;
        feePaymentObj.loan__Loan_Payment_Transaction__c = loanPaymentId;
        return feePaymentObj;
    }

    /**
    * @description : create ipt record for test class
    * @author Rohit Roy | 17/01/2024 
    * @param contractId 
    * @return loan__Interest_Posting_Transaction__c 
    **/
    public static loan__Interest_Posting_Transaction__c returnIPT(Id contractId){
        loan__Interest_Posting_Transaction__c iptObj = new loan__Interest_Posting_Transaction__c();
        iptObj.loan__Is_Paid__c = false;
        iptObj.loan__Reversed__c = false;
        iptObj.loan__Interest_Posted__c = 54.16;
        iptObj.loan__Loan_Contract__c = contractId;
        iptObj.loan__Interest_Paid__c = 0;
        iptObj.loan__Transaction_Due_Date__c = Date.Today().addMonths(1);
        iptObj.loan__Is_Posted__c = true;
        iptObj.loan__Discarded__c = false;
        return iptObj;
    }
}