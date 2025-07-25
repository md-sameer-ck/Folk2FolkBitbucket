/**
 * @description       : Class to handle fees payment file processing.
 * @author            : Anshu Kumari Mahato
 * @group             : Apex Class
 * @last modified on  : 17-07-2025
 * @last modified by  : Md Sameer
**/
public inherited sharing class F2FFeesPaymentFileHandler {

    // List to store errors encountered during processing
    public List<String> errorList = new List<String>();
    // Counter to track the number of errors
    public Integer errorCount = F2FLoanConstants.ZERO;

     // Constants for common strings
     private static final String FEE_NAME = 'Fee Name';
     private static final String FEE_NAME_MISSING = 'Fee Name Missing From Fees Payment File';
     private static final String PAYMENT_SPREAD_MISSING = 'No payment spread found for creation of new LPT for loan-';
     private static final String PAYMENT_MODE_NOT_FOUND = 'Payment Mode Not Found';
     private static final String PAYMENT_SPREAD_NOT_FOUND = 'Payment Spread Not Found';
     private static final String FEE_QUERY = '%Fee%';
     private static final String REDEMPTION_QUERY ='%Redemption%';
     public static final List<String> HEADER_NAME_LIST = new List<String>{'Reference Number','Account Name','Amount','Customer Id','Due Date','Status','Transaction Reference','\\n'};

    /**
    * @description This methods process the file for fee payments
    * @author Anshu Kumari Mahato | 05-09-2024
    * @param fileContent
    **/
    public void processFeesFile(String fileContent){
        Integer lineEntry = F2FLoanConstants.ZERO;
        List<String> columnList = new List<String>();
        Map<String,Decimal> loanNameVsAmountMap = new Map<String,Decimal>();
        String currentLine;
        Map<String,Integer> headerIndexMap = new Map<String,Integer>();
        String headerInstance = Folk2FolkConstantValues.BLANK_STRING;
        List<String> headerList;
        List<String> headerNameList;
        Set<String> loanNameSet = new Set<String>();
        F2FPaymentFileController.ExtractFile extractorInst = new F2FPaymentFileController.ExtractFile(fileContent, Folk2FolkConstantValues.NEXT_LINE);
        if(extractorInst.hasNext()) {
            headerInstance = extractorInst.next();
        }
        //split header into index map
        headerList = headerInstance.split(Folk2FolkConstantValues.TEXT_IN_COMMMA);

        for(String header : headerList) {
            headerIndexMap.put(header.trim(), headerList.indexOf(header));
        }

        while(extractorInst.hasNext()){
            currentLine = extractorInst.next().remove(Folk2FolkConstantValues.NEXT_LINE);
            lineEntry++;

            // Get all coloumns one by one from right to left seperated by ','
            columnList = currentLine.split(Folk2FolkConstantValues.TEXT_IN_COMMMA);

            /* Note : Reference number, amount and status are mandatory*/
            // Check if the required headers are present or not
            headerNameList = HEADER_NAME_LIST;
            headerNameList.add(FEE_NAME);

            // This will contain header format
            for(String headerName : headerNameList){
                ValidationUtil.throwErrorOnCondition(!headerIndexMap.containsKey(headerName), Folk2FolkConstantValues.ERROR_3 + headerName + Folk2FolkConstantValues.ERROR_4);
            }
            //Check if required columnList contain values or not
            String loanReferenceNumber = columnList.get(headerIndexMap.get(Folk2FolkConstantValues.REFERENCE_NUMBER));
            String transactionAmount = columnList.get(headerIndexMap.get(Folk2FolkConstantValues.PAYMENT_AMOUNT));
            String status = columnList.get(headerIndexMap.get(Folk2FolkConstantValues.PAYMENT_STATUS));
            String dueDate = columnList.get(headerIndexMap.get(Folk2FolkConstantValues.PAYMENT_DUE_DATE));
            String feeName = columnList.get(headerIndexMap.get(FEE_NAME));

            // Check for missing or incorrect data and record errors
            checkForErrors(loanReferenceNumber,Folk2FolkConstantValues.REFERENCE_NUMBER_MISSING,lineEntry);
            checkForErrors(transactionAmount,Folk2FolkConstantValues.AMOUNT_MISSING,lineEntry);
            checkForErrors(status,Folk2FolkConstantValues.MISSING_STATUS,lineEntry);
            checkForErrors(dueDate,Folk2FolkConstantValues.PAYMENT_DUE_DATE_MISSING,lineEntry);
            checkForErrors(feeName,FEE_NAME_MISSING,lineEntry);

            // Convert transaction amount to Double and process payment if valid
            Double paymentAmount = getTransactionAmount(transactionAmount,lineEntry);
            if(String.isNotBlank(status) && status.equalsIgnoreCase(Folk2FolkConstantValues.PAID) && paymentAmount != null && String.isNotBlank(loanReferenceNumber)){
                loanNameSet.add(loanReferenceNumber);
                loanNameVsAmountMap.put(loanReferenceNumber + F2FLoanConstants.UNDERSCORE + feeName,paymentAmount);
            }
        }

        // If there are no file errors, proceed with further loan validations
        F2FPaymentFileHelper helperClassInst = new F2FPaymentFileHelper(this, loanNameVsAmountMap);
        helperClassInst.feesFileValidation();
        //proceed to clear the loans with no validation errors
        clearLoanPaymentTransactions(helperClassInst.loanNameVsAmountMap, loanNameSet);
    }

    /**
    * @description | This method checks for missing values and logs errors accordingly.
    * @param value : Value to check for errors
    * @param errorMessage : Error message to add if value is missing
    * @param line : Line number where the error occurred
    **/
    public void checkForErrors(String value, String errorMessage, Integer line){
        if(String.isBlank(value)){
            errorCount++;
            errorList.add(String.valueOf(errorCount) + Folk2FolkConstantValues.TEXT_IN_COMMMA + errorMessage + String.valueOf(line) + Folk2FolkConstantValues.NEXT_LINE);
        }
    }

    /**
    * @description | This method converts the transaction amount to Double and handles errors during conversion.
    * @param transactionAmount : Transaction amount as String
    * @param line : Line number for error reporting
    * @return Double : Parsed transaction amount
    **/
    public Double getTransactionAmount(String transactionAmount, Integer line){
        try {
            return Double.valueOf(transactionAmount);
        } catch(TypeException typeException) {
            errorCount++;
            errorList.add(String.valueOf(errorCount) + Folk2FolkConstantValues.TEXT_IN_COMMMA + Folk2FolkConstantValues.ERROR_7
                            + String.valueOf(line) + Folk2FolkConstantValues.NEXT_LINE);
            return null;
        }
    }

    /**
    * @description |  This method rejects old payment transactions and inserts new ones and clear them
    * @param loanNameVsAmountMap : Map containing loan names and payment amounts
    * @param loanNameSet : Set containing loan reference numbers
    **/
    public void clearLoanPaymentTransactions(Map<String,Decimal> loanNameVsAmountMap,Set<String> loanNameSet){
        List<loan__Loan_Payment_Transaction__c>  updateloanPaymentList = new List<loan__Loan_Payment_Transaction__c>();
        List<loan__Loan_Payment_Transaction__c>  insertloanPaymentList = new List<loan__Loan_Payment_Transaction__c>();
        Map<String,loan__Loan_Account__c> loanNameVsLoanMap = new Map<String,loan__Loan_Account__c>();
        Map<String,loan__Loan_Payment_Spread__c> spreadNameVsSpreadMap = new Map<String,loan__Loan_Payment_Spread__c>();
        List<loan__Loan_Payment_Transaction__c>  loanPaymentList = new List<loan__Loan_Payment_Transaction__c>();
        Map<String,String> feeNameVsSystemSpreadMap = new Map<String,String>();

        // Predefined fee-to-spread mappings
        feeNameVsSystemSpreadMap.put(F2FLoanConstants.EARLY_TERMINATION_INTEREST_INVESTOR_PARTIAL_NAME,F2FLoanConstants.EARLY_TERMINATION_INTEREST_INVESTOR_PARTIAL_DESC);
        feeNameVsSystemSpreadMap.put(F2FLoanConstants.DELINQUENT_INTEREST_FEE_NAME,F2FLoanConstants.DELINQUENT_INTEREST_FEE_DESC);
        feeNameVsSystemSpreadMap.put(F2FLoanConstants.SOLICITOR_FEE_NAME,F2FLoanConstants.SOLICITOR_FEE_DESC);
        feeNameVsSystemSpreadMap.put(F2FLoanConstants.LATE_REDEMPTION_FEE_NAME,F2FLoanConstants.LATE_REDEMPTION_FEE_DESC);
        feeNameVsSystemSpreadMap.put(F2FLoanConstants.EARLY_TERMINATION_FEE,F2FLoanConstants.EARLY_TERMINATION_FEE_DESC);
        feeNameVsSystemSpreadMap.put(F2FLoanConstants.EARLY_TERMINATION_INTEREST_INVESTOR_FULL_NAME,F2FLoanConstants.EARLY_TERMINATION_INTEREST_INVESTOR_FULL_DESC);
        feeNameVsSystemSpreadMap.put(F2FLoanConstants.COLLECTION_FEE_NAME,F2FLoanConstants.COLLECTION_FEE_DESC);
        feeNameVsSystemSpreadMap.put(F2FLoanConstants.MANAGEMENT_FEE_NAME,F2FLoanConstants.MANAGEMENT_FEE_DESC);
        feeNameVsSystemSpreadMap.put(F2FLoanConstants.ADMINISTRATION_FEE,F2FLoanConstants.ADMINISTRATION_FEE_DESC);
        if(loanNameVsAmountMap.isEmpty() || loanNameSet.isEmpty()){
            return;
        }
        // Fetch loan accounts and payment spreads based on loan names and fee names
        List<loan__Loan_Account__c> loanList =[SELECT id,
                                                        Name,
                                                        (SELECT Id,
                                                                Name,
                                                                loan__Cleared__c,
                                                                loan__Transaction_Time__c,
                                                                loan__Transaction_Amount__c,
                                                                loan__Loan_Account__r.name,
                                                                loan__Automated_Payment_Setup__r.loan__Amount_Type__c
                                                            FROM loan__Loan_Payment_Transactions__r
                                                            WHERE loan__Cleared__c = false
                                                            AND loan__Rejected__c = false
                                                            AND loan__Reversed__c = false)
                                                FROM loan__Loan_Account__c
                                                WHERE Name
                                                IN: loanNameSet
                                                WITH SYSTEM_MODE];
        for(loan__Loan_Account__c loanObj :  loanList){
            loanNameVsLoanMap.put(loanObj.name,loanObj);

            // Add payments for the current loan to the aggregated list
            if (loanObj.loan__Loan_Payment_Transactions__r != null) {
                loanPaymentList.addAll(loanObj.loan__Loan_Payment_Transactions__r);
            }
        }
        // Reject existing LPTs
        for(loan__Loan_Payment_Transaction__c loanPaymentObj : loanPaymentList){
            loanPaymentObj.loan__Rejected__c = true;
            updateloanPaymentList.add(loanPaymentObj);
        }
        SecureDMLUtil.updateSObject(updateloanPaymentList,true,AccessLevel.SYSTEM_MODE);
        List<loan__Payment_Mode__c> paymentModeList = [SELECT id,
                                                                Name
                                                        FROM loan__Payment_Mode__c
                                                        WHERE Name =: Folk2FolkConstantValues.BACS_PAYEMENT
                                                        WITH SYSTEM_MODE];
        ValidationUtil.throwErrorOnCondition(paymentModeList.isEmpty(), PAYMENT_MODE_NOT_FOUND);

        List<loan__Loan_Payment_Spread__c> paymentSpreadList = [SELECT id,
                                                                        Name,
                                                                        loan__Order_Of_Payment__c
                                                                FROM loan__Loan_Payment_Spread__c
                                                                WHERE (Name like :FEE_QUERY OR Name like :REDEMPTION_QUERY)
                                                                WITH SYSTEM_MODE];
        ValidationUtil.throwErrorOnCondition(paymentSpreadList.isEmpty(), PAYMENT_SPREAD_NOT_FOUND);
        for(loan__Loan_Payment_Spread__c paymentSpreadObj : paymentSpreadList){
            spreadNameVsSpreadMap.put(paymentSpreadObj.name,paymentSpreadObj);
        }
        // Process payment transactions for loan payment creation
        for(String mapKey : loanNameVsAmountMap.keySet()){
            String loanName = ((mapKey.split(F2FLoanConstants.UNDERSCORE))[0]).trim();
            String feeName = ((mapKey.split(F2FLoanConstants.UNDERSCORE))[1]).trim();
            Decimal paymentAmount = loanNameVsAmountMap.get(mapKey);
            // Create loan payment Transaction for each row Fee Payment Spread
            loan__Loan_Payment_Transaction__c loanPaymentFeeObj = new loan__Loan_Payment_Transaction__c();
            loanPaymentFeeObj.loan__Loan_Account__c = loanNameVsLoanMap.get(loanName).id;
            loanPaymentFeeObj.loan__Transaction_Amount__c = paymentAmount;
            loanPaymentFeeObj.loan__Transaction_Date__c = ValidationUtil.getCurrentSystemDate();
            loanPaymentFeeObj.loan__Payment_Mode__c = paymentModeList[0].id;
            ValidationUtil.throwErrorOnCondition(!feeNameVsSystemSpreadMap.containsKey(feeName)
                    || spreadNameVsSpreadMap.get(feeNameVsSystemSpreadMap?.get(feeName)) == null,PAYMENT_SPREAD_MISSING+loanName);
            loanPaymentFeeObj.loan__Loan_Payment_Spread__c = spreadNameVsSpreadMap.get(feeNameVsSystemSpreadMap?.get(feeName))?.id;
            insertloanPaymentList.add(loanPaymentFeeObj);
        }
        SecureDMLUtil.insertSObject(insertloanPaymentList,true,AccessLevel.SYSTEM_MODE);
        // Clear newLy created LPTs
        List<loan__Loan_Payment_Transaction__c> loanPaymentToClearList = [SELECT id,
                                                                                    Name,
                                                                                    loan__Cleared__c
                                                                            FROM loan__Loan_Payment_Transaction__c
                                                                            WHERE loan__Cleared__c = false
                                                                            AND loan__Rejected__c = false
                                                                            AND loan__Reversed__c = false
                                                                            AND loan__Loan_Account__r.Name IN : loanNameSet
                                                                            AND createdDate = TODAY
                                                                            WITH SYSTEM_MODE];
        for(loan__Loan_Payment_Transaction__c loanPaymentToClearObj : loanPaymentToClearList){
            loanPaymentToClearObj.loan__Cleared__c = true;
        }
        SecureDMLUtil.updateSObject(loanPaymentToClearList,true,AccessLevel.SYSTEM_MODE);
    }
}
