/**
 * @description                : This class is a helper for processing F2F payment files,
 *                               specifically for interest and fees payments with comprehensive validation.
 * @author                     : Md Sameer
 * @group                      : Helper Class
 * @last modified on           : 17-07-2025
 * @last modified by           : Md Sameer
 * @last modification details  :
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   10-07-2025   Md Sameer   Initial Version
 * 1.1   16-07-2025   Md Sameer   Added optimizations and bug fixes
**/
public inherited sharing class F2FPaymentFileHelper {

    // Instance variables for payment file handlers
    public Object currentFileInstance;
    public Map<String, Decimal> loanNameVsAmountMap;
    public HandlerUtils handlerUtilInst;

    /**
    * @description Initializes the helper with the appropriate payment file handler based on the identifier.
    *               Validates input parameters and sets up the correct handler instance.
    * @author Md Sameer | 11-07-2025
    * @param callerInst The handler instance (Interest or Fees payment handler)
    * @param loanNameVsAmountMap Map containing loan names and their corresponding amounts
    **/
    public F2FPaymentFileHelper(Object callerInst, Map<String, Decimal> loanNameVsAmountMap) {
        // Validate input parameters to ensure they are not null
        ValidationUtil.throwErrorOnCondition(callerInst == null || loanNameVsAmountMap == null,
            'Params provided for F2FPaymentFileHelper instantiation are null'
        );
        ValidationUtil.throwErrorOnCondition((!(callerInst instanceof F2FInterestPaymentFileHandler)
            && !(callerInst instanceof F2FFeesPaymentFileHandler)),
            'Invalid payment file handler instance provided.');

        // Initialize the handler utility instance for error handling
        this.handlerUtilInst = new HandlerUtils();
        // Initialize the class current file instance from the caller instance
        this.currentFileInstance = callerInst;
        // Store the loan name to amount mapping for validation processing
        this.loanNameVsAmountMap = loanNameVsAmountMap;
    }

    /**
    * @description Retrieves loan account details for the given set of loan names.
    *               Uses SOQL to fetch essential loan information needed for validation.
    * @author Md Sameer | 15-07-2025
    * @param loanNameSet Set of loan names to query
    * @return Map of loan names to their corresponding loan account objects
    **/
    public Map<String, loan__Loan_Account__c> getLoanDetails(Set<String> loanNameSet) {
        Map<String, loan__Loan_Account__c> resultMap = new Map<String, loan__Loan_Account__c>();

        // Query loan accounts with essential fields needed for validation
        for (loan__Loan_Account__c eachLoanObj :
                [SELECT Id,
                        Name,
                        loan__Invalid_Data__c,
                        loan__Loan_Status__c,
                        loan__Interest_Posted__c
                    FROM loan__Loan_Account__c
                    WHERE Name IN: loanNameSet
                    WITH SYSTEM_MODE]) {
            resultMap.put(eachLoanObj.Name, eachLoanObj);
        }
        return resultMap;
    }

    /**
    * @description Calculates the sum of interest postings for loans from Investment Orders.
    *               Uses aggregate query for efficient calculation of posting sums.
    * @author Md Sameer | 15-07-2025
    * @param loanNameSet Set of loan names to calculate postings for
    * @param loanNameVsLoanObjMap Map of loan names to their corresponding loan objects
    * @return Map of loan names to their total interest posting amounts
    **/
    public Map<String, Decimal> getIOPostingSum(Set<String> loanNameSet,
            Map<String, loan__Loan_Account__c> loanNameVsLoanObjMap) {
        Map<String, Decimal> resultMap = new Map<String, Decimal>();

        // Create temporary map to hold loan id vs loan names as aggr returns id vs value
        Map<Id, String> loanIdVsNameMap = new Map<Id, String>();
        for (String eachLoan : loanNameVsLoanObjMap.keySet()) {
            loanIdVsNameMap.put(loanNameVsLoanObjMap.get(eachLoan).Id, eachLoan);
        }

        // Use aggregate query to efficiently sum interest postings by loan
        for (AggregateResult eachAggResult : [
            SELECT loan__Loan__r.Id loanAcccId,
                SUM(Interest_posted__c) interestPostingSum
                FROM loan__Investor_Loan__c
                WHERE loan__Loan__r.Name IN :loanNameSet
                WITH SYSTEM_MODE
                GROUP BY loan__Loan__r.Id
        ]) {
            resultMap.put(
                loanIdVsNameMap.get((Id)eachAggResult.get('loanAcccId')),
                (Decimal)eachAggResult.get('interestPostingSum')
            );
        }
        return resultMap;
    }

    /**
    * @description Identifies loans that have reversal issues in their payment transactions.
    *               Checks for inconsistent states in cleared, reversed, and paid to investor flags.
    * @author Md Sameer | 15-07-2025
    * @param loanNameSet Set of loan names to check for reversal issues
    * @return Set of loan names that have reversal issues
    **/
    public Set<String> getReversalIssueLoanMap(Set<String> loanNameSet) {
        Set<String> resultSet = new Set<String>();

        // Query for loan payment transactions with potential reversal issues
        for (loan__Loan_Payment_Transaction__c eachLoanPaymentTrans :
                [SELECT loan__Loan_Account__r.Name
                    FROM loan__Loan_Payment_Transaction__c
                    WHERE ((loan__Cleared__c = true
                        AND loan__Reversed__c = false
                        AND loan__Rejected__c = false
                        AND loan__Paid_to_Investor__c != true)
                    OR
                        (loan__Cleared__c = true
                        AND loan__Reversed__c = true
                        AND loan__Paid_to_Investor__c != false
                        AND loan__Paid_to_Investor_Reversed__c != true))
                    AND loan__Loan_Account__r.Name IN :loanNameSet
                    WITH SYSTEM_MODE]) {
            resultSet.add(eachLoanPaymentTrans.loan__Loan_Account__r.Name);
        }
        return resultSet;
    }

    /**
    * @description Performs comprehensive validation for interest payment files.
    *               Validates loan existence, status, data integrity, and posting amounts.
    * @author Md Sameer | 11-07-2025
    **/
    public void interestFileValidation() {
        if (loanNameVsAmountMap.isEmpty()) {
            return; // No loans to validate, exit early
        }
        loan__Loan_Account__c loanObj;
        // Cache the loan name set to avoid multiple keySet() calls
        Set<String> loanNameSet = new Set<String>(loanNameVsAmountMap.keySet());

        // Fetch all required data for validation in bulk to optimize performance
        Map<String, loan__Loan_Account__c> loanNameVsLoanObjMap = getLoanDetails(loanNameSet);
        Map<String, Decimal> loanNameVsIOPostingMap = getIOPostingSum(loanNameSet, loanNameVsLoanObjMap);
        Set<String> reversalIssueLoanSet = getReversalIssueLoanMap(loanNameSet);

        // Validate each loan against all required criteria
        for (String eachLoanName : loanNameSet) {
            loanObj = loanNameVsLoanObjMap.get(eachLoanName);
            // Run all validations and remove loan from processing if any validation fails
            if (!(
                isLoanNameValid(eachLoanName, loanObj) &&
                isLoanNotInvalidData(loanObj) &&
                isLoanStatusValid(loanObj) &&
                isClearingAmountValid(loanObj) &&
                isPostingDiffValid(loanObj, loanNameVsIOPostingMap) &&
                isNoReversalLPTIssue(loanObj, reversalIssueLoanSet)
            )) {
                // Remove invalid loans from processing
                loanNameVsAmountMap.remove(eachLoanName);
            }
        }
        // Display error message if validation errors were found
        showErrorMessage(F2FPaymentFileController.INTEREST_KEYWORD);
    }

    /**
    * @description Performs validation for fees payment files.
    *               Validates basic loan criteria like existence, status, and data integrity.
    * @author Md Sameer | 11-07-2025
    **/
    public void feesFileValidation() {
        if (loanNameVsAmountMap.isEmpty()) {
            return; // No loans to validate, exit early
        }
        loan__Loan_Account__c loanObj;
        // Cache the loan name set to avoid multiple keySet() calls
        Set<String> loanNameSet = new Set<String>(loanNameVsAmountMap.keySet());

        // Fetch loan details for validation
        Map<String, loan__Loan_Account__c> loanNameVsLoanObjMap = getLoanDetails(loanNameSet);

        // Validate each loan against all required criteria
        for (String eachLoanName : loanNameSet) {
            loanObj = loanNameVsLoanObjMap.get(eachLoanName);
            // Run all validations and remove loan from processing if any validation fails
            if (!(
                isLoanNameValid(eachLoanName, loanObj) &&
                isLoanNotInvalidData(loanObj) &&
                isLoanStatusValid(loanObj)
                // Additional conditions can be added here as needed for fees validation
            )) {
                // Remove invalid loans from processing
                loanNameVsAmountMap.remove(eachLoanName);
            }
        }

        // Display error message if validation errors were found
        showErrorMessage(F2FPaymentFileController.FEE_KEYWORD);
    }

    /**
    * @description Validates if a loan name exists in the system.
    *               Adds error message if loan is not found.
    * @author Md Sameer | 15-07-2025
    * @param eachLoanName The loan name to validate
    * @param loanObj Contains the loan object to validate against
    * @return True if loan data is valid, false otherwise
    **/
    public Boolean isLoanNameValid(String eachLoanName, loan__Loan_Account__c loanObj) {
        if (loanObj == null) {
            handlerUtilInst.incrementErrorCount(currentFileInstance);
            handlerUtilInst.addErrorToList(currentFileInstance, handlerUtilInst.getErrorListSize(currentFileInstance) +
                Folk2FolkConstantValues.TEXT_IN_COMMMA + 'The entered ' + eachLoanName +
                ' could not be found in the org.' + Folk2FolkConstantValues.NEXT_LINE);
            return false;
        }
        return true;
    }

    /**
    * @description Validates that a loan does not have invalid data flag set.
    *               Adds error message if loan has invalid data.
    * @author Md Sameer | 16-07-2025
    * @param loanObj Contains the loan object to validate against
    * @return True if loan data is valid, false otherwise
    **/
    public Boolean isLoanNotInvalidData(loan__Loan_Account__c loanObj) {
        if (loanObj.loan__Invalid_Data__c) {
            handlerUtilInst.incrementErrorCount(currentFileInstance);
            handlerUtilInst.addErrorToList(currentFileInstance, handlerUtilInst.getErrorListSize(currentFileInstance) +
                Folk2FolkConstantValues.TEXT_IN_COMMMA + 'The loan ' + loanObj.Name +
                ' has invalid data true.' + Folk2FolkConstantValues.NEXT_LINE);
            return false;
        }
        return true;
    }

    /**
    * @description Validates if a loan is in active good or bad standing status.
    *               Adds error message if loan status is invalid.
    * @author Md Sameer | 16-07-2025
    * @param loanObj Contains the loan object to validate against
    * @return True if loan status is valid, false otherwise
    **/
    public Boolean isLoanStatusValid(loan__Loan_Account__c loanObj) {
        if (ValidationUtil.getAndResults(new List<Boolean>{
                loanObj.loan__Loan_Status__c != Folk2FolkConstantValues.ACTIVE_GOOD_STANDING,
                loanObj.loan__Loan_Status__c != Folk2FolkConstantValues.ACTIVE_BAD_STANDING})) {
            handlerUtilInst.incrementErrorCount(currentFileInstance);
            handlerUtilInst.addErrorToList(currentFileInstance, handlerUtilInst.getErrorListSize(currentFileInstance) +
                Folk2FolkConstantValues.TEXT_IN_COMMMA + 'The loan ' + loanObj.Name +
                ' is not Active Good - Standing or Active Bad - Standing.' + Folk2FolkConstantValues.NEXT_LINE);
            return false;
        }
        return true;
    }

    /**
    * @description Validates that the clearing amount is not more than the interest posted.
    *               This prevents negative interest postings.
    * @author Md Sameer | 16-07-2025
    * @param loanObj Contains the loan object to validate against
    * @return True if clearing amount is valid, false otherwise
    **/
    public Boolean isClearingAmountValid(loan__Loan_Account__c loanObj) {
        if ((loanObj.loan__Interest_Posted__c - loanNameVsAmountMap.get(loanObj.Name)) < F2FLoanConstants.ZERO) {
            handlerUtilInst.incrementErrorCount(currentFileInstance);
            handlerUtilInst.addErrorToList(currentFileInstance, handlerUtilInst.getErrorListSize(currentFileInstance) +
                Folk2FolkConstantValues.TEXT_IN_COMMMA + 'The clearing amount on the file for the loan ' + loanObj.Name +
                ' is more than the contract interest posted. This may cause negative interest postings.' + Folk2FolkConstantValues.NEXT_LINE);
            return false;
        }
        return true;
    }

    /**
    * @description Validates the difference between contract interest posted and Investment Order postings.
    *               Ensures the difference is within acceptable tolerance (≤ 1).
    * @author Md Sameer | 16-07-2025
    * @param loanObj Contains the loan object to validate against
    * @param loanNameVsIOPostingMap Map of loan names to their IO posting sums
    * @return True if posting difference is valid, false otherwise
    **/
    public Boolean isPostingDiffValid(loan__Loan_Account__c loanObj, Map<String, Decimal> loanNameVsIOPostingMap) {
        // Check if loan has any Investment Order interest postings
        if (!loanNameVsIOPostingMap.containsKey(loanObj.Name)) {
            handlerUtilInst.incrementErrorCount(currentFileInstance);
            handlerUtilInst.addErrorToList(currentFileInstance, handlerUtilInst.getErrorListSize(currentFileInstance) +
                Folk2FolkConstantValues.TEXT_IN_COMMMA + 'The loan ' + loanObj.Name +
                ' does not have any Investment Orders.' + Folk2FolkConstantValues.NEXT_LINE);
            return false;
        }

        // Check if the difference between contract and IO postings is within tolerance £1
        if (Math.abs(loanObj.loan__Interest_Posted__c - loanNameVsIOPostingMap.get(loanObj.Name)) > F2FLoanConstants.ONE) {
            handlerUtilInst.incrementErrorCount(currentFileInstance);
            handlerUtilInst.addErrorToList(currentFileInstance, handlerUtilInst.getErrorListSize(currentFileInstance) +
                Folk2FolkConstantValues.TEXT_IN_COMMMA + 'The loan ' + loanObj.Name +
                ' has a difference > £1 with respect to contract interest posted and the sum of interest posted in Investment Orders.'
                + Folk2FolkConstantValues.NEXT_LINE);
            return false;
        }
        return true;
    }

    /**
    * @description Validates if a loan has reversal issues in its payment transactions.
    *               Checks for inconsistent transaction states that could cause payout issues.
    * @author Md Sameer | 16-07-2025
    * @param loanObj Contains the loan object to validate against
    * @param reversalIssueLoanSet Set of loan names with reversal issues
    * @return True if no reversal issues, false otherwise
    **/
    public Boolean isNoReversalLPTIssue(loan__Loan_Account__c loanObj, Set<String> reversalIssueLoanSet) {
        if (reversalIssueLoanSet.contains(loanObj.Name)) {
            handlerUtilInst.incrementErrorCount(currentFileInstance);
            handlerUtilInst.addErrorToList(currentFileInstance, handlerUtilInst.getErrorListSize(currentFileInstance) +
                Folk2FolkConstantValues.TEXT_IN_COMMMA + 'The loan ' + loanObj.Name +
                ' has an incorrect LPT perhaps due to reversal, which may cause a payout issue.' + Folk2FolkConstantValues.NEXT_LINE);
            return false;
        }
        return true;
    }

    /**
    * @description Displays appropriate error message based on the file type identifier.
    *               Uses ApexPages to show error messages to the user.
    * @author Md Sameer | 16-07-2025
    * @param identifier The file type identifier (Interest or Fee)
    **/
    public void showErrorMessage(String identifier) {
        // Display error message if validation errors were found
        if (handlerUtilInst.getErrorListSize(currentFileInstance) > F2FLoanConstants.ZERO) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'There are errors in the {fileType} payment file. '
                + 'Please check the error file for details.'.replace('{fileType}', identifier)
            ));
        }
    }

    /**
     * @description Utility class that provides methods to handle errors and error lists
     *              for F2F payment file handlers. Supports both Interest and Fees handlers.
     */
    public class HandlerUtils {

        /**
        * @description Gets the size of the error list from the handler object.
        * @author Md Sameer | 16-07-2025
        * @param handlerObj The handler object (Interest or Fees payment handler)
        * @return Size of the error list
        **/
        public Integer getErrorListSize(Object handlerObj) {
            if (handlerObj instanceof F2FInterestPaymentFileHandler) {
                return ((F2FInterestPaymentFileHandler) handlerObj).errorList.size();
            } else if (handlerObj instanceof F2FFeesPaymentFileHandler) {
                return ((F2FFeesPaymentFileHandler) handlerObj).errorList.size();
            }
            return F2FLoanConstants.ZERO;
        }

        /**
        * @description Gets the error count from the handler object.
        * @author Md Sameer | 16-07-2025
        * @param handlerObj The handler object (Interest or Fees payment handler)
        * @return Current error count
        **/
        public Integer getErrorCount(Object handlerObj) {
            if (handlerObj instanceof F2FInterestPaymentFileHandler) {
                return ((F2FInterestPaymentFileHandler) handlerObj).errorCount;
            } else if (handlerObj instanceof F2FFeesPaymentFileHandler) {
                return ((F2FFeesPaymentFileHandler) handlerObj).errorCount;
            }
            return F2FLoanConstants.ZERO;
        }

        /**
        * @description Increments the error count in the handler object.
        *               Handles null values by initializing to 1.
        * @author Md Sameer | 16-07-2025
        * @param handlerObj The handler object to increment error count for
        **/
        public void incrementErrorCount(Object handlerObj) {
            if (handlerObj instanceof F2FInterestPaymentFileHandler) {
                F2FInterestPaymentFileHandler handler = (F2FInterestPaymentFileHandler) handlerObj;
                handler.errorCount = (handler.errorCount == null) ? F2FLoanConstants.ONE : handler.errorCount + F2FLoanConstants.ONE;
            } else if (handlerObj instanceof F2FFeesPaymentFileHandler) {
                F2FFeesPaymentFileHandler handler = (F2FFeesPaymentFileHandler) handlerObj;
                handler.errorCount = (handler.errorCount == null) ? F2FLoanConstants.ONE : handler.errorCount + F2FLoanConstants.ONE;
            }
        }

        /**
        * @description Adds an error message to the error list in the handler object.
        * @author Md Sameer | 16-07-2025
        * @param handlerObj The handler object to add error message to
        * @param errorMsg The error message to add
        **/
        public void addErrorToList(Object handlerObj, String errorMsg) {
            if (handlerObj instanceof F2FInterestPaymentFileHandler) {
                ((F2FInterestPaymentFileHandler) handlerObj).errorList.add(errorMsg);
            } else if (handlerObj instanceof F2FFeesPaymentFileHandler) {
                ((F2FFeesPaymentFileHandler) handlerObj).errorList.add(errorMsg);
            }
        }
    }
}