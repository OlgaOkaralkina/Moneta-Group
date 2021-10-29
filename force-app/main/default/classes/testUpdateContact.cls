public class testUpdateContact {
    
    public static Decimal Add2(Decimal A1, Decimal A2) {
        Decimal result = A1 + A2;
        return result;
    }
    
    public static void NewContact(String ConIDList){
        List <Contact> conList;
        List <ID> lstID = ConIDList.split(',');
        conList = [Select 
        LastName,FirstName,Salutation,MiddleName,Suffix,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,OtherLatitude,OtherLongitude,OtherGeocodeAccuracy,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,MailingLatitude,MailingLongitude,MailingGeocodeAccuracy,Phone,Fax,MobilePhone,HomePhone,OtherPhone,AssistantPhone,Email,Title,Department,AssistantName,LeadSource,Birthdate,Description,OwnerId,HasOptedOutOfEmail,HasOptedOutOfFax,DoNotCall,FinServ__AnnualIncome__c,FinServ__Citizenship__c,FinServ__CountryOfBirth__c,FinServ__CountryOfResidence__c,FinServ__CreatedFromLead__c,FinServ__CurrentEmployer__c,FinServ__EmployedSince__c,FinServ__Facebook__c,FinServ__Gender__c,FinServ__LanguagesSpoken__c,FinServ__LinkedIn__c,FinServ__MaritalStatus__c,FinServ__NumberOfDependents__c,Occupation__c,FinServ__PreferredName__c,FinServ__PrimaryAddressIsBilling__c,FinServ__PrimaryAddressIsMailing__c,FinServ__PrimaryAddressIsOther__c,FinServ__PrimaryAddressIsShipping__c,FinServ__PrimaryLanguage__c,FinServ__SecondaryLanguage__c,FinServ__SourceSystemId__c,FinServ__TaxBracket__c,FinServ__TaxId__c,FinServ__Twitter__c,FinServ__WeddingAnniversary__c,Address_Type__c,Address_is_Primary__c,Assistant_Email__c,Birth_State__c,Client_Communication__c,Comment__c,Communication_Preference__c,Company_Care_of__c,Compliance__c,Contact_Status__c,Contact_Type__c,Does_Not_Want_To_Receive_Mail__c,Driver_s_License_Number__c,Driver_s_License_State__c,Email_Comment__c,Email_Type__c,Estate_Planning_and_Philanthropy__c,Events__c,Family_CFO_Services__c,Financial_Independence__c,Graduation_Year__c,Greeting_Line__c,Important_Announcements__c,Institutional_Consulting__c,Investments__c,Job_Title__c,Last_Interaction_Date__c,Local_Events__c,Maiden_Name__c,Mailing_Street_2nd__c,Marketing__c,Moneta_News__c,Mother_s_Maiden_Name__c,Newsletter__c,Next_Interaction_Date__c,Opt_Out_of_All_Bulk_Emails__c,Phone_Comment__c,Phone_Extension__c,Phone_Type__c,Proactive_Tax_Planning__c,Prospecting__c,Public__c,Reference_Note__c,Risk_Management__c,SSN_TIN__c,School_College__c,Spouse__c,State_of_Residence__c,Team__c,FinServ__ContactPreference__c,FinServ__ReferredByContact__c,FinServ__ReferredByUser__c,FinServ__ReferrerScore__c,iContactforSF__iContact_Contact_Id__c,Resident_Alien__c,Best_Time_to_Call__c,Date_added_to_Pipeline__c,Date_of_Birth__c,Estimated_Annual_Fee_Bill__c,Estimated_Billable_Assets__c,Mailing_Attention__c,Predicted_Year_of_First_Invoice__c,Referral_Type__c,Referred_By__c,Lead_Source__c,Predicted_First_Invoice_Date__c,ContactPreference__c,Country_of_Issuance__c,Date_of_Death__c,Employment_Status__c,ID_Number__c,Spouse_Name__c,State_of_Issuance__c,OASP_FSC__Languages__c,OASP_FSC__Level__c,OASP_FSC__Rep_Number__c,OASP_FSC__Sync__c,inspire1__Chatter_Free_User_Id__c,inspire1__Hourly_Rate__c,inspire1__Working_Hours_per_Day__c,Citizenship__c,M_A_External_Contact_ID__c,Center_of_Influence__c,Investments_team__c,Relationship_Lead__c,FinServ__Occupation__c
        from Contact where ID in :lstID];
        for (Contact con:conList)
        {
            Contact con2 = new Contact(
            LastName=con.LastName,FirstName=con.FirstName,Salutation=con.Salutation,MiddleName=con.MiddleName,Suffix=con.Suffix,OtherStreet=con.OtherStreet,OtherCity=con.OtherCity,OtherState=con.OtherState,OtherPostalCode=con.OtherPostalCode,OtherCountry=con.OtherCountry,OtherLatitude=con.OtherLatitude,OtherLongitude=con.OtherLongitude,OtherGeocodeAccuracy=con.OtherGeocodeAccuracy,MailingStreet=con.MailingStreet,MailingCity=con.MailingCity,MailingState=con.MailingState,MailingPostalCode=con.MailingPostalCode,MailingCountry=con.MailingCountry,MailingLatitude=con.MailingLatitude,MailingLongitude=con.MailingLongitude,MailingGeocodeAccuracy=con.MailingGeocodeAccuracy,Phone=con.Phone,Fax=con.Fax,MobilePhone=con.MobilePhone,HomePhone=con.HomePhone,OtherPhone=con.OtherPhone,AssistantPhone=con.AssistantPhone,Email=con.Email,Title=con.Title,Department=con.Department,AssistantName=con.AssistantName,LeadSource=con.LeadSource,Birthdate=con.Birthdate,Description=con.Description,OwnerId=con.OwnerId,HasOptedOutOfEmail=con.HasOptedOutOfEmail,HasOptedOutOfFax=con.HasOptedOutOfFax,DoNotCall=con.DoNotCall,FinServ__AnnualIncome__c=con.FinServ__AnnualIncome__c,FinServ__Citizenship__c=con.FinServ__Citizenship__c,FinServ__CountryOfBirth__c=con.FinServ__CountryOfBirth__c,FinServ__CountryOfResidence__c=con.FinServ__CountryOfResidence__c,FinServ__CreatedFromLead__c=con.FinServ__CreatedFromLead__c,FinServ__CurrentEmployer__c=con.FinServ__CurrentEmployer__c,FinServ__EmployedSince__c=con.FinServ__EmployedSince__c,FinServ__Facebook__c=con.FinServ__Facebook__c,FinServ__Gender__c=con.FinServ__Gender__c,FinServ__LanguagesSpoken__c=con.FinServ__LanguagesSpoken__c,FinServ__LinkedIn__c=con.FinServ__LinkedIn__c,FinServ__MaritalStatus__c=con.FinServ__MaritalStatus__c,FinServ__NumberOfDependents__c=con.FinServ__NumberOfDependents__c,Occupation__c=con.Occupation__c,FinServ__PreferredName__c=con.FinServ__PreferredName__c,FinServ__PrimaryAddressIsBilling__c=con.FinServ__PrimaryAddressIsBilling__c,FinServ__PrimaryAddressIsMailing__c=con.FinServ__PrimaryAddressIsMailing__c,FinServ__PrimaryAddressIsOther__c=con.FinServ__PrimaryAddressIsOther__c,FinServ__PrimaryAddressIsShipping__c=con.FinServ__PrimaryAddressIsShipping__c,FinServ__PrimaryLanguage__c=con.FinServ__PrimaryLanguage__c,FinServ__SecondaryLanguage__c=con.FinServ__SecondaryLanguage__c,FinServ__SourceSystemId__c=con.FinServ__SourceSystemId__c,FinServ__TaxBracket__c=con.FinServ__TaxBracket__c,FinServ__TaxId__c=con.FinServ__TaxId__c,FinServ__Twitter__c=con.FinServ__Twitter__c,FinServ__WeddingAnniversary__c=con.FinServ__WeddingAnniversary__c,Address_Type__c=con.Address_Type__c,Address_is_Primary__c=con.Address_is_Primary__c,Assistant_Email__c=con.Assistant_Email__c,Birth_State__c=con.Birth_State__c,Client_Communication__c=con.Client_Communication__c,Comment__c=con.Comment__c,Communication_Preference__c=con.Communication_Preference__c,Company_Care_of__c=con.Company_Care_of__c,Compliance__c=con.Compliance__c,Contact_Status__c=con.Contact_Status__c,Contact_Type__c=con.Contact_Type__c,Does_Not_Want_To_Receive_Mail__c=con.Does_Not_Want_To_Receive_Mail__c,Driver_s_License_Number__c=con.Driver_s_License_Number__c,Driver_s_License_State__c=con.Driver_s_License_State__c,Email_Comment__c=con.Email_Comment__c,Email_Type__c=con.Email_Type__c,Estate_Planning_and_Philanthropy__c=con.Estate_Planning_and_Philanthropy__c,Events__c=con.Events__c,Family_CFO_Services__c=con.Family_CFO_Services__c,Financial_Independence__c=con.Financial_Independence__c,Graduation_Year__c=con.Graduation_Year__c,Greeting_Line__c=con.Greeting_Line__c,Important_Announcements__c=con.Important_Announcements__c,Institutional_Consulting__c=con.Institutional_Consulting__c,Investments__c=con.Investments__c,Job_Title__c=con.Job_Title__c,Last_Interaction_Date__c=con.Last_Interaction_Date__c,Local_Events__c=con.Local_Events__c,Maiden_Name__c=con.Maiden_Name__c,Mailing_Street_2nd__c=con.Mailing_Street_2nd__c,Marketing__c=con.Marketing__c,Moneta_News__c=con.Moneta_News__c,Mother_s_Maiden_Name__c=con.Mother_s_Maiden_Name__c,Newsletter__c=con.Newsletter__c,Next_Interaction_Date__c=con.Next_Interaction_Date__c,Opt_Out_of_All_Bulk_Emails__c=con.Opt_Out_of_All_Bulk_Emails__c,Phone_Comment__c=con.Phone_Comment__c,Phone_Extension__c=con.Phone_Extension__c,Phone_Type__c=con.Phone_Type__c,Proactive_Tax_Planning__c=con.Proactive_Tax_Planning__c,Prospecting__c=con.Prospecting__c,Public__c=con.Public__c,Reference_Note__c=con.Reference_Note__c,Risk_Management__c=con.Risk_Management__c,SSN_TIN__c=con.SSN_TIN__c,School_College__c=con.School_College__c,Spouse__c=con.Spouse__c,State_of_Residence__c=con.State_of_Residence__c,Team__c=con.Team__c,FinServ__ContactPreference__c=con.FinServ__ContactPreference__c,FinServ__ReferredByContact__c=con.FinServ__ReferredByContact__c,FinServ__ReferredByUser__c=con.FinServ__ReferredByUser__c,FinServ__ReferrerScore__c=con.FinServ__ReferrerScore__c,iContactforSF__iContact_Contact_Id__c=con.iContactforSF__iContact_Contact_Id__c,Resident_Alien__c=con.Resident_Alien__c,Best_Time_to_Call__c=con.Best_Time_to_Call__c,Date_added_to_Pipeline__c=con.Date_added_to_Pipeline__c,Date_of_Birth__c=con.Date_of_Birth__c,Estimated_Annual_Fee_Bill__c=con.Estimated_Annual_Fee_Bill__c,Estimated_Billable_Assets__c=con.Estimated_Billable_Assets__c,Mailing_Attention__c=con.Mailing_Attention__c,Predicted_Year_of_First_Invoice__c=con.Predicted_Year_of_First_Invoice__c,Referral_Type__c=con.Referral_Type__c,Referred_By__c=con.Referred_By__c,Lead_Source__c=con.Lead_Source__c,Predicted_First_Invoice_Date__c=con.Predicted_First_Invoice_Date__c,ContactPreference__c=con.ContactPreference__c,Country_of_Issuance__c=con.Country_of_Issuance__c,Date_of_Death__c=con.Date_of_Death__c,Employment_Status__c=con.Employment_Status__c,ID_Number__c=con.Driver_s_License_Number__c,Spouse_Name__c=con.Spouse_Name__c,State_of_Issuance__c=con.Driver_s_License_State__c,OASP_FSC__Languages__c=con.OASP_FSC__Languages__c,OASP_FSC__Level__c=con.OASP_FSC__Level__c,OASP_FSC__Rep_Number__c=con.OASP_FSC__Rep_Number__c,OASP_FSC__Sync__c=con.OASP_FSC__Sync__c,inspire1__Chatter_Free_User_Id__c=con.inspire1__Chatter_Free_User_Id__c,inspire1__Hourly_Rate__c=con.inspire1__Hourly_Rate__c,inspire1__Working_Hours_per_Day__c=con.inspire1__Working_Hours_per_Day__c,Citizenship__c=con.Citizenship__c,M_A_External_Contact_ID__c=con.M_A_External_Contact_ID__c,Center_of_Influence__c=con.Center_of_Influence__c,Investments_team__c=con.Investments_team__c,Relationship_Lead__c=con.Relationship_Lead__c,FinServ__Occupation__c=con.FinServ__Occupation__c
            );
            upsert con2;
            //Move all the attachments
            moveContactsAddress(con.ID, con2.ID);
            moveContactsNotes(con.ID, con2.ID);
            moveContactsPhone(con.ID, con2.ID);
            moveContactsEmail(con.ID, con2.ID);
            moveContactsTask(con.ID, con2.ID);
            moveContactsiMsgStats(con.ID, con2.ID);
            moveContactsMDCMsgStat(con.ID, con2.ID);
            moveContactsMDCClickedLinks(con.ID, con2.ID);
            moveContactsEvent(con.ID, con2.ID);
            copyContactsRelations(con.ID, con2.ID);
            moveHoHAccountContactRel(con.ID, con2.ID);
            
        }
    }
    
    public static void moveContactsAddress(String conID1, String conID2){
        List <Additional_Addresses__c> LsAdd;
        LsAdd = [Select ID, Contact__c from Additional_Addresses__c where Contact__c = :conID1];
        For(Additional_Addresses__c iAdd:LsAdd)
            iAdd.Contact__c = conID2;
		Update LsAdd;   
    }
    
    
    private static void moveHoHAccountContactRel(String conID1, String conID2){
        List <Account> LsAdd;
        LsAdd = [Select ID from Account where Head_of_Household__c = :conID1];
        For(Account iAdd:LsAdd)
            iAdd.Head_of_Household__c = conID2;
		Update LsAdd;   
    }
    
	public static void moveContactsNotes(String conID1, String conID2){
        List <Notes__c> LsAdd;
        LsAdd = [Select ID, Associated_Contact__c from Notes__c where Associated_Contact__c = :conID1];
        For(Notes__c iAdd:LsAdd)
            iAdd.Associated_Contact__c = conID2;
        Update LsAdd;   
    }
    
	public static void moveContactsPhone(String conID1, String conID2){
        List <Additional_Phone_Number__c> LsAdd;
        LsAdd = [Select ID, Contact__c from Additional_Phone_Number__c where Contact__c = :conID1];
        For(Additional_Phone_Number__c iAdd:LsAdd)
            iAdd.Contact__c = conID2;
        Update LsAdd;   
    }
        
	public static void moveContactsEmail(String conID1, String conID2){
		List <Additional_Email__c> LsAdd;
        LsAdd = [Select ID, Contact__c from Additional_Email__c where Contact__c = :conID1];
        For(Additional_Email__c iAdd:LsAdd)
            iAdd.Contact__c = conID2;
        Update LsAdd;  
    }
    
	private static void moveContactsTask(String conID1, String conID2){
		List <Task> LsAdd;
        LsAdd = [Select ID, WhoID from Task where WhoID = :conID1];
        For(Task iAdd:LsAdd)
            iAdd.WhoID = conID2;
        Update LsAdd;  
    }  
    
	private static void moveContactsiMsgStats(String conID1, String conID2){
		List <iContactforSF__iContact_Message_Statistic__c> LsAdd;
        LsAdd = [Select ID, iContactforSF__Contact__c from iContactforSF__iContact_Message_Statistic__c where iContactforSF__Contact__c = :conID1];
        For(iContactforSF__iContact_Message_Statistic__c iAdd:LsAdd)
            iAdd.iContactforSF__Contact__c = conID2;
        Update LsAdd;  
    }    
    
	private static void moveContactsMDCMsgStat(String conID1, String conID2){
		List <MDC_Message_Statistics__c> LsAdd;
        LsAdd = [Select ID, Contact__c from MDC_Message_Statistics__c where Contact__c = :conID1];
        For(MDC_Message_Statistics__c iAdd:LsAdd)
            iAdd.Contact__c = conID2;
        Update LsAdd;  
    }   
    
	private static void moveContactsMDCClickedLinks(String conID1, String conID2){
		List <MDC_Clicked_Links__c> LsAdd;
        LsAdd = [Select ID, Contact__c from MDC_Clicked_Links__c where Contact__c = :conID1];
        For(MDC_Clicked_Links__c iAdd:LsAdd)
            iAdd.Contact__c = conID2;
        Update LsAdd;  
    }       
    
	private static void moveContactsEvent(String conID1, String conID2){
		List <Event> LsAdd;
        LsAdd = [Select ID, WhoID from Event where WhoID = :conID1];
        For(Event iAdd:LsAdd)
            iAdd.WhoID = conID2;
        Update LsAdd;  
    }      
    
    
    private static void copyContactsRelations(String conID1, String conID2){
        List <AccountContactRelation> LsACR;
        LsACR = [Select ID, ContactId,FinServ__Primary__c,FinServ__PrimaryGroup__c,Roles,FinServ__Rollups__c,AccountId,FinServ__IncludeInGroup__c from AccountContactRelation where ContactId = :conID1];
        For(AccountContactRelation iACR:LsACR){
        AccountContactRelation iACR2 =  new AccountContactRelation(
        ContactId = conID2,FinServ__Primary__c = iACR.FinServ__Primary__c,FinServ__PrimaryGroup__c = iACR.FinServ__PrimaryGroup__c,Roles = iACR.Roles,FinServ__Rollups__c = iACR.FinServ__Rollups__c,AccountId = iACR.AccountId,FinServ__IncludeInGroup__c = iACR.FinServ__IncludeInGroup__c);
        Upsert iACR2;
        }
    }  
    
}