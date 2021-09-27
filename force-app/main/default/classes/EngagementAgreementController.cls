public with sharing class EngagementAgreementController {


    public Onboarding_Request__c onboardingRequest;

    public Request OnboardRequestWrapperObj{get;set;}

    public class Request{
        public Onboarding_Request__c onboardingRequest{get;set;}
    }
    public EngagementAgreementController() {
        String onboardingId = ApexPages.currentPage().getParameters().get('id');
        onboardingRequest = getOnboardingRequest(onboardingId);
   
        onboardRequestWrapperObj = new Request();
        onboardRequestWrapperObj.onboardingRequest = this.onboardingRequest;

    }

    public static Onboarding_Request__c getOnboardingRequest(Id onboardingId){
        Onboarding_Request__c onboard_Request;
        onboard_Request = [Select Id, Name, Client_Team__c, Comments__c, 
                            Onboarding_Status__c, Due_Date__c, Household__c, Household__r.Name,
                            Packet_Delivery_Preference__c, Partner_Split_client__c, Processor_assigned__c, Send_EA_ADV__c, CreatedBy.Name, CreatedDate,
                            Accounts_Outside_of_Robo_Platform__c,Additional_Comments__c,Additional_Services_to_be_Provided__c,
                            Agreement_is_for__c,CreatedById,Discr__c,
                            Each_HH_Responsible_for_their_own_fees__c,Entity_s_Auth_Signor_s_w_Titles__c,
                            Fee_Schedule__c,Household_ID__c,Household_Name_s_and_ID_s__c,
                            If_No_provide_HH_Name_Resp_for_all_fees__c,Is_HH_aggregated_with_any_other_HH_s__c,
                            LastModifiedById,Legal_Name_of_Entity__c,Legal_Name_s_of_Individual_s_Signing__c,
                            Minimum_Annual_Fee__c,Negotiated_Fee_Schedule__c,Negotiated_Minimum_Annual_Fee__c,
                            Robo_Type__c,Signing_Pertner_s_Name__c,Type_of_Agreement__c
                            from Onboarding_Request__c where Id = :onboardingId];

        return onboard_Request;
    }
}