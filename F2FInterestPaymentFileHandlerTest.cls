/**
 * @description       : This class handles the interest payment file process
 * @author            : Anshu Kumari Mahato
 * @group             : Apex Class
 * @last modified on  : 24-07-2025
 * @last modified by  : Md Sameer
**/
public inherited sharing class F2FInterestPaymentFileHandler {

    public List<String> errorList = new List<String>();
    public Integer errorCount = F2FLoanConstants.ZERO;
    public static final String LPT_COULD_NOT_CLEARED = 'could not be cleared. Please check if LPTs with older Transaction Date exist.';
    public Set<Id> clearedLptIdSet = new Set<Id>();
    public Map<Id, loan__Loan_Payment_Transaction__c> lptIdVsLptRecordMap;

    /**
    * @description Processes the content of the interest payment file, extracting and validating data, and initiating loan payment transaction clearing.
    * @param fileContent The content of the uploaded file as a String.
    **/
    public void processInterestFile(String fileContent) {
        Integer lineEntry = F2FLoanConstants.ZERO;
        List<String> columnList = new List<String>();
        Map<String, Decimal> loanNameVsAmountMap = new Map<String, Decimal>();
        String currentLine;
        Map<String, Integer> headerIndexMap = new Map<String, Integer>();
        String headerInstance = Folk2FolkConstantValues.BLANK_SPACE;
        List<String> headerList;
        List<String> headerNameList;

        // Initialize the file extractor to parse the file content line by line.
        F2FPaymentFileController.ExtractFile extractorInst = new F2FPaymentFileController.ExtractFile(fileContent, Folk2FolkConstantValues.NEXT_LINE);
        if (extractorInst.hasNext()) {
            headerInstance = extractorInst.next();
        }
        headerList = headerInstance.split(Folk2FolkConstantValues.TEXT_IN_COMMMA);

        // Map headers to their column indices for quick reference.
        for (String header : headerList) {
            headerIndexMap.put(header.trim(), headerList.indexOf(header));
        }

        while (extractorInst.hasNext()) {
            currentLine = extractorInst.next().remove(Folk2FolkConstantValues.NEXT_LINE);
            lineEntry++;

            columnList = currentLine.split(Folk2FolkConstantValues.TEXT_IN_COMMMA);

            // Validate that all expected headers are present.
            headerNameList = Folk2FolkConstantValues.HEADER_NAME_LIST;
            for (String headerName : headerNameList) {
                ValidationUtil.throwErrorOnCondition(!headerIndexMap.containsKey(headerName), Folk2FolkConstantValues.ERROR_3 + headerName + Folk2FolkConstantValues.ERROR_4);
            }

            // Extract required fields from the current line.
            String loanReferenceNumber = columnList.get(headerIndexMap.get(Folk2FolkConstantValues.REFERENCE_NUMBER));
            String transactionAmount = columnList.get(headerIndexMap.get(Folk2FolkConstantValues.PAYMENT_AMOUNT));
            String status = columnList.get(headerIndexMap.get(Folk2FolkConstantValues.PAYMENT_STATUS));
            String dueDate = columnList.get(headerIndexMap.get(Folk2FolkConstantValues.PAYMENT_DUE_DATE));

            // Validate the presence of essential fields.
            checkForErrors(loanReferenceNumber, Folk2FolkConstantValues.REFERENCE_NUMBER_MISSING, lineEntry);
            checkForErrors(transactionAmount, Folk2FolkConstantValues.AMOUNT_MISSING, lineEntry);
            checkForErrors(status, Folk2FolkConstantValues.MISSING_STATUS, lineEntry);
            checkForErrors(dueDate, Folk2FolkConstantValues.PAYMENT_DUE_DATE_MISSING, lineEntry);

            // Process payment amounts only if status is PAID.
            Double paymentAmount = getTransactionAmount(transactionAmount, lineEntry);
            if (String.isNotBlank(status) && status.equalsIgnoreCase(Folk2FolkConstantValues.PAID) && paymentAmount != null && String.isNotBlank(loanReferenceNumber)) {
                loanNameVsAmountMap.put(loanReferenceNumber, paymentAmount);
            }
        }

        // If there are no file errors, proceed with further loan validations
        F2FPaymentFileHelper helperClassInst = new F2FPaymentFileHelper(this, loanNameVsAmountMap);
        helperClassInst.interestFileValidation();
        //proceed to clear the loans with no validation errors
        clearLoanPaymentTransactions(helperClassInst.loanNameVsAmountMap);
    }

    /**
    * @description Checks for missing or invalid values and records errors.
    * @param value The value to validate.
    * @param errorMessage The error message to log if validation fails.
    * @param line The line number in the file where the error occurred.
    **/
    @TestVisible
    private void checkForErrors(String value, String errorMessage, Integer line) {
        if (String.isBlank(value)) {
            errorCount++;
            errorList.add(String.valueOf(errorCount) + Folk2FolkConstantValues.TEXT_IN_COMMMA + errorMessage + String.valueOf(line) + Folk2FolkConstantValues.NEXT_LINE);
        }
    }

    /**
    * @description Converts the transaction amount string to a Double, recording an error if conversion fails.
    * @param transactionAmount The transaction amount as a string.
    * @param line The line number in the file where the transaction amount is located.
    * @return The transaction amount as a Double or null if conversion fails.
    **/
    @TestVisible
    private Double getTransactionAmount(String transactionAmount, Integer line) {
        try {
            return Double.valueOf(transactionAmount);
        } catch (TypeException typeException) {
            errorCount++;
            errorList.add(String.valueOf(errorCount) + Folk2FolkConstantValues.TEXT_IN_COMMMA + Folk2FolkConstantValues.ERROR_7 + String.valueOf(line) + Folk2FolkConstantValues.NEXT_LINE);
            return null;
        }
    }

    /**
     * @description Clears loan payment transactions by processing each loan account and updating its transactions.
     * @param loanNameVsAmountMap A map of loan reference names to their respective payment amounts.
    **/
    @TestVisible
    private void clearLoanPaymentTransactions(Map<String, Decimal> loanNameVsAmountMap) {
        if (loanNameVsAmountMap.isEmpty()) {
            return;
        }

        lptIdVsLptRecordMap = new Map<Id, loan__Loan_Payment_Transaction__c>();
        List<loan__Loan_Payment_Transaction__c> updateloanPaymentList = new List<loan__Loan_Payment_Transaction__c>();

        // Fetch loan accounts and associated transactions for processing.
        List<loan__Loan_Account__c> loanList = [SELECT Id,
                                                        Name,
                                                        (SELECT Id,
                                                                Name,
                                                                loan__Cleared__c,
                                                                loan__Transaction_Time__c,
                                                                loan__Transaction_Amount__c,
                                                                loan__Loan_Account__r.Name,
                                                                loan__Automated_Payment_Setup__r.loan__Amount_Type__c
                                                        FROM loan__Loan_Payment_Transactions__r
                                                        WHERE loan__Cleared__c = false
                                                        AND loan__Rejected__c = false
                                                        AND loan__Reversed__c = false
                                                        AND loan__Automated_Payment_Setup__r.loan__Amount_Type__c =: Folk2FolkConstantValues.LAST_BILLED_AMOUNT
                                                        AND loan__Automated_Payment_Setup__r.loan__Type__c =: Folk2FolkConstantValues.RECURRING
                                                        ORDER BY loan__Transaction_Time__c ASC)
                                                FROM loan__Loan_Account__c
                                                WHERE Name IN :loanNameVsAmountMap.keySet() WITH SYSTEM_MODE];

        for (loan__Loan_Account__c loanObj : loanList) {
            Decimal remainingAmount = loanNameVsAmountMap.get(loanObj.Name);

            // Create a context object for processing transactions.
            ProcessLoanPaymentContext context = new ProcessLoanPaymentContext(remainingAmount, updateloanPaymentList, loanObj);

            // Process each loan account's transactions and adjust the remaining amount.
            processLoanPaymentTransactions(loanObj.loan__Loan_Payment_Transactions__r, context);
        }

        // Perform a bulk update on loan payment transactions.
        SecureDMLUtil.updateSObject(updateloanPaymentList, true, AccessLevel.SYSTEM_MODE);

        // Validate the cleared transactions for accuracy.
        validateClearedLPTs();
    }

    /**
     * @description Processes individual loan payment transactions and adjusts the remaining amount accordingly.
     * @param loanPaymentList List of loan payment transaction records to process.
     * @param context Contextual data including remaining amount, updates list, and loan account.
     */
    @TestVisible
    private void processLoanPaymentTransactions(List<loan__Loan_Payment_Transaction__c> loanPaymentList,ProcessLoanPaymentContext context) {
        for (loan__Loan_Payment_Transaction__c loanPaymentObj : loanPaymentList) {
            lptIdVsLptRecordMap.put(loanPaymentObj.Id, loanPaymentObj);

            // Check if the payment amount is sufficient to clear the transaction.
            if ((loanPaymentObj.loan__Transaction_Amount__c - Folk2FolkConstantValues.PAYMENT_TOLERANCE) <= context.remainingAmount) {
                loanPaymentObj.loan__Cleared__c = true;
                context.updateloanPaymentList.add(loanPaymentObj);
                context.remainingAmount -= loanPaymentObj.loan__Transaction_Amount__c;
            } else {
                // Log an error for insufficient payment amount.
                addErrorForInsufficientAmount(loanPaymentObj, context.loanObj.Name);
                //adding LPT id as an error message for non cleared LPT is already added
                clearedLptIdSet.add(loanPaymentObj.Id);
            }
        }

        // Log an error if there is excess payment amount that cannot be allocated.
        if (context.remainingAmount > 0) {
            addErrorForExcessAmount(context.loanObj.Name, context.remainingAmount);
        }
    }

    /**
     * @description Holds context data for processing loan payment transactions.
     */
    public class ProcessLoanPaymentContext {
        public Decimal remainingAmount;
        public List<loan__Loan_Payment_Transaction__c> updateloanPaymentList;
        public loan__Loan_Account__c loanObj;

    /**
     * @description Constructor for initializing the ProcessLoanPaymentContext object, which holds context-specific
     *              data for processing loan payment transactions.
     * @param remainingAmount The amount still available for clearing loan payment transactions.
     * @param updateloanPaymentList The list where updated loan payment transactions will be collected for bulk update.
     * @param loanObj The loan account associated with the current set of transactions being processed.
     **/
    public ProcessLoanPaymentContext(Decimal remainingAmount, List<loan__Loan_Payment_Transaction__c> updateloanPaymentList, loan__Loan_Account__c loanObj) {
        this.remainingAmount = remainingAmount;
        this.updateloanPaymentList = updateloanPaymentList;
        this.loanObj = loanObj;
    }

    }

    /**
    * @description Adds an error when the payment amount is insufficient to clear the transaction.
    * @param loanPaymentObj The loan payment transaction that could not be cleared.
    * @param loanAccountName The name of the loan account associated with the transaction.
    **/
    @TestVisible
    private void addErrorForInsufficientAmount(loan__Loan_Payment_Transaction__c loanPaymentObj, String loanAccountName) {
        // This method logs errors when individual loan payment transactions cannot be cleared due to insufficient payment.
        errorCount++;
        errorList.add(String.valueOf(errorCount) + Folk2FolkConstantValues.TEXT_IN_COMMMA + Folk2FolkConstantValues.AMOUNT_NOT_ENOUGH + String.valueOf(loanPaymentObj.Name) + Folk2FolkConstantValues.BLANK_SPACE + loanAccountName + Folk2FolkConstantValues.NEXT_LINE);
    }

    /**
    * @description Adds an error for excess payment amount that cannot be allocated to any transaction.
    * @param loanAccountName The name of the loan account.
    * @param remainingAmount The unallocated excess payment amount.
    **/
    @TestVisible
    private void addErrorForExcessAmount(String loanAccountName, Decimal remainingAmount) {
        errorCount++;
        errorList.add(String.valueOf(errorCount) + Folk2FolkConstantValues.TEXT_IN_COMMMA + Folk2FolkConstantValues.EXCESS_AMOUNT_RECEIVED + String.valueOf(remainingAmount) + Folk2FolkConstantValues.BLANK_SPACE + loanAccountName + Folk2FolkConstantValues.NEXT_LINE);
    }

    /**
    * @description Validates that all cleared loan payment transactions have been properly updated.
    **/
    @TestVisible
    private void validateClearedLPTs() {
        clearedLptIdSet = new Set<Id>();
        // Retrieve IDs of cleared transactions for validation.
        for (loan__Loan_Payment_Transaction__c eachClearedLptId : [SELECT Id
                                                                    FROM loan__Loan_Payment_Transaction__c
                                                                    WHERE loan__Cleared__c = true
                                                                    AND Id IN :lptIdVsLptRecordMap.keySet() WITH SYSTEM_MODE]) {
            clearedLptIdSet.add(eachClearedLptId.Id);
        }

        // Check for any transactions that could not be cleared.
        for (Id eachLptId : lptIdVsLptRecordMap.keySet()) {
            if (!clearedLptIdSet.contains(eachLptId)) {
                // Log errors for transactions that could not be cleared.
                errorCount++;
                errorList.add(String.valueOf(errorCount) + Folk2FolkConstantValues.TEXT_IN_COMMMA + String.valueOf(lptIdVsLptRecordMap.get(eachLptId).loan__Loan_Account__r.Name) + Folk2FolkConstantValues.BLANK_SPACE + String.valueOf(lptIdVsLptRecordMap.get(eachLptId).Name) + Folk2FolkConstantValues.BLANK_SPACE + LPT_COULD_NOT_CLEARED + Folk2FolkConstantValues.NEXT_LINE);
            }
        }
    }
}
