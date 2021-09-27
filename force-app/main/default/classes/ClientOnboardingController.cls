public with sharing class ClientOnboardingController {

    public Onboarding_Request__c onboardingRequest;
    List<OB_Account__c> obAccounts;
    List<OB_New_Account__c> trustees;

    public Request OnboardRequestWrapperObj{get;set;}

    public class Request{
        public Onboarding_Request__c onboardingRequest{get;set;}
        public List<OB_Account__c> obAccounts{get;set;}
        public List<OB_New_Account__c> trustees{get;set;}
      //  public Map<Id, clockingDistance> clockDistanceMap {get;set;}
      //  public string ticketLocationAddress{get;set;}
      //  public List<ContentDocumentLink> Docs{get;set;}
    }
    public ClientOnboardingController() {
        String onboardingId = ApexPages.currentPage().getParameters().get('id');
        onboardingRequest = getOnboardingRequest(onboardingId);
        obAccounts = getOB_Accounts(onboardingId);
        trustees = getTrustees(onboardingId);
        /*
        if(ticketAssignment.Ticket__c != NULL){
            this.ticket = getTicketReord(ticketAssignment.Ticket__c);
            this.invoice = getTechInvoice(ticketAssignmentId);
        }
  */      
        onboardRequestWrapperObj = new Request();
        onboardRequestWrapperObj.onboardingRequest = this.onboardingRequest;
        onboardRequestWrapperObj.obAccounts = this.obAccounts;
        onboardRequestWrapperObj.trustees = this.trustees;
      //  ticketWrapperObj.ticket = this.ticket;
      //  ticketWrapperObj.MyInvoice = this.invoice;
    }

    public static Onboarding_Request__c getOnboardingRequest(Id onboardingId){
        Onboarding_Request__c onboard_Request;
        onboard_Request = [Select Id, Name, Client_Team__c, Comments__c, 
                            Onboarding_Status__c, Due_Date__c, Household__c, Household__r.Name,
                            Packet_Delivery_Preference__c, Partner_Split_client__c, Processor_assigned__c, Send_EA_ADV__c, CreatedBy.Name, CreatedDate
                            from Onboarding_Request__c where Id = :onboardingId];

        return onboard_Request;
    }

    public static List<OB_Account__c> getOB_Accounts(Id onboardingId){
        
        List<OB_Account__c> onboard_Request = [Select Id, Name, Account_Number__c,Account_Owner__r.Name, Account_Sub_Type__c,Account_URL__c, Account_Type__c,ACH_Instructions__c,
        Additional_Requests__c,Billable__c,Billing_Account__c,Check_Instructions__c,Custodian__c,Discretionary__c,Funding_Account_Name__c,
        Funding_Account_Number__c,Funding_Method__c,Journal_Instructions__c, Linking_Method__c,Moneta_Managed__c,Money_Movement__c,
        Other_Custodian__c,Plan_Name__c,Registration__c,Remove_RIA__c,Retirement_Account__c, RecordType.Name
        from OB_Account__c where Onboarding_Request__r.Id = :onboardingId order by RecordType.Name, Name];

        return onboard_Request;
    }

    public static List<OB_New_Account__c> getTrustees(Id onboardingId){
        
        List<OB_New_Account__c> trustees = [Select OB_Account__r.Id, Id, Name, Date_of_Birth__c, First_or_Trust_Name__c, Last_Name__c,Beneficiary_Trustee_Contact_in_SF__r.Id,
        Beneficiary_Trustee_Contact_in_SF__r.FirstName ,Beneficiary_Trustee_Contact_in_SF__r.LastName ,
        Percentage__c, Relationship__c, SSN__c
         from OB_New_Account__c where OB_Account__r.Onboarding_Request__r.Id = :onboardingId Order by OB_Account__r.Id, Percentage__c];

        return trustees;
    }
    /*
Select Id, Name, Account_Number__c,Account_Owner__c, Account_Sub_Type__c,Account_URL__c, Account_Type__c,ACH_Instructions__c,
Additional_Requests__c,Billable__c,Billing_Account__c,Check_Instructions__c,Custodian__c,Discretionary__c,Funding_Account_Name__c,
Funding_Account_Number__c,Funding_Method__c,Journal_Instructions__c, Linking_Method__c,Moneta_Managed__c,Money_Movement__c,
Other_Custodian__c,Plan_Name__c,Registration__c,Remove_RIA__c,Retirement_Account__c,
(Select OB_New_Account__r.Id from OB_New_Account__r)
from OB_Account__c where Onboarding_Request__r.Id = 'a14P0000002oxrKIAQ'


Select OB_Account__r.Id, Id, Name, Date_of_Birth__c, First_or_Trust_Name__c, Last_Name__c,
Percentage__c, Relationship__c, SSN__c
 from OB_New_Account__c where OB_Account__r.Onboarding_Request__r.Id = 'a14P0000002oxrKIAQ'
    */
}