/**
 * @description       : Controller class called from F2FUploadPaymentFile page
                        to choose and upload a Payment Return File manually and store it
                        in Payment Return File Folder in Salesforce Document
 * @author            : Priyanka Pramanik
 * @group             : CloudKaptan Consultancy Services Pvt. Ltd.
 * @last modified on  : 16-07-2025
 * @last modified by  : Md Sameer
**/

public without sharing class F2FPaymentFileController {

    public static final String INTEREST_KEYWORD = 'interest';
    public static final String FEE_KEYWORD = 'fees';
    public static final String SUCCESS_MESSAGE = 'All loans have been validated and cleared successfully.';

    /**
    * @description | The method defines a static, non-serialized Blob variable to store file content, with public getter and setter methods.
    **/
    public static transient Blob contentFile{get; set;}

    /**
    * @description | The method defines a static variable to store the file name as a String, with public getter and setter methods for accessing and modifying its value.
    **/
    public static String fileName{get; set;}


    /**
    * @description | Reads & process the uploaded file
    * @author Supriyo Seni | 05-09-2024
    **/
    public static void processFile() {
        List<String> errorList = new List<String>();
        try{
            // Validate the file
            if(contentFile == null || String.isBlank(contentFile.toString())) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Folk2FolkConstantValues.ERROR_1));
                return;
            }
            ValidationUtil.throwErrorOnCondition(!(fileName.contains(INTEREST_KEYWORD) || fileName.contains(FEE_KEYWORD)) , Folk2FolkConstantValues.PAYMENT_FILE_NAME);
            //file processing logic for interest payment file
            if(fileName.contains(INTEREST_KEYWORD)){
                F2FInterestPaymentFileHandler interestPaymentFileInst = new F2FInterestPaymentFileHandler();
                interestPaymentFileInst.processInterestFile(contentFile.toString());
                List<String> interestErrorList = interestPaymentFileInst.errorList;
                if(!interestErrorList.isEmpty()){
                    errorList.addAll(interestErrorList);
                }
            //file processing logic for fee payment file
            }else if(fileName.contains(FEE_KEYWORD)){
                F2FFeesPaymentFileHandler feePaymentFileInst = new F2FFeesPaymentFileHandler();
                feePaymentFileInst.processFeesFile(contentFile.toString());
                List<String> feesErrorList = feePaymentFileInst.errorList;
                if(!feesErrorList.isEmpty()){
                    errorList.addAll(feesErrorList);
                }
            }
            if(!errorList.isEmpty()) {
                errorList.add(Folk2FolkConstantValues.ZERO_INTEGER, Folk2FolkConstantValues.ERROR_FILE_HEADER);  // ERROR File Header
                createErrorDocumentFile(errorList);
                return;
            }
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, SUCCESS_MESSAGE));
        } catch(Exception exe) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, exe.getMessage()));
        }
    }


    /**
    * @description | This function joins all the errors and then insert it and
    *  displays the exception
    * @author Anshu kumari mahato | 03-12-2024
    * @param csvErrorsList
    **/
    public static void createErrorDocumentFile(List<String> csvErrorsList) {
        // TODO --- Create document for errors
        String csvError = Folk2FolkConstantValues.BLANK_STRING;
        for(String error : csvErrorsList){
            csvError = csvError + error;
        }

        List<Folder> folderlist = [SELECT Id
                                        FROM Folder
                                        WHERE Name = :Folk2FolkConstantValues.PAYMENT_FILE_PROCESS_ERROR
                                        WITH SYSTEM_MODE
                                        LIMIT 1];
        ValidationUtil.throwErrorOnCondition(folderlist.isEmpty(), Folk2FolkConstantValues.PAYMENT_FILE_ERROR_FOLDER_NOT_FOUND);
        Document errorDocumentObj = new Document(Name = Folk2FolkConstantValues.ERROR_FILE_NAME + System.now(),
                                                Body = Blob.valueOf(csvError),
                                                ContentType = Folk2FolkConstantValues.TEXT_PLAIN_CONTENT_TYPE,
                                                Type = Folk2FolkConstantValues.TXT_TYPE,
                                                Description = Folk2FolkConstantValues.ERROR_FILE_DESCRIPTION,
                                                FolderId = folderlist[0].Id);
        SecureDMLUtil.insertSObject(new List<Document>{errorDocumentObj} ,false,AccessLevel.SYSTEM_MODE);
    }

/**
 * @description | This class handles the extraction of files or data with custom logic for processing and handling file-related operations.
**/
    public without sharing class ExtractFile implements Iterator<String>, Iterable<String> {
        private String currentData;
        private Integer currentDataIndex = F2FLoanConstants.ZERO;
        private String splitPattern = Folk2FolkConstantValues.NEXT_LINE;

        /**
        * @description | Extracting the file
        *  @author Anshu kumari mahato | 01-12-2024
        * @param content
        * @param pattern
        **/
        public ExtractFile(String content, String pattern) {
            currentData = content;
            splitPattern= pattern;
        }

        /**
        * @description | The method returns true if there are more elements to iterate over, and false otherwise.
        *  @author Anshu kumari mahato | 01-12-2024
        * @return Boolean
        **/
        public Boolean hasNext(){
            return currentDataIndex < currentData.length() ? true : false;
        }

        /**
        * @description | The method returns the next element in the iteration and advances the iterator.
        * @author Anshu kumari mahato | 01-12-2024
        * @return String
        **/
        public String next(){
            String row;
            Integer key = currentData.indexOf(splitPattern, currentDataIndex);
            if (key == -(F2FLoanConstants.ONE)) {
                key = currentData.length();
            }
            row = currentData.subString(currentDataIndex, key);
            currentDataIndex= key + F2FLoanConstants.ONE;
            return row;
        }

        /**
        * @description | The method defines an iterator that allows sequential access to a collection of String elements.
        *  @author Anshu kumari mahato | 01-12-2024
        * @return iterator | It returns an iterator object that can be used to traverse the elements one by one.
        **/
        public iterator<String> iterator(){
            return this;
        }
    }

}