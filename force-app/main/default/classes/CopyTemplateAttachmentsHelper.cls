public without sharing class CopyTemplateAttachmentsHelper {

    public static void copyTemplateAttachments(Map<Id, inspire1__Project_Tasks__c> projectAndTemplateMap) {
        FeedItem[] feeds = [
            SELECT
                Id, 
                Title, 
                Body, 
                ContentData,
                ContentFileName, 
                Type,
                ParentId
            FROM FeedItem
            WHERE 
                ParentId IN :projectAndTemplateMap.keySet()
                AND Type = 'ContentPost'
                AND IsDeleted = false
        ];

        for (FeedItem feed : feeds) {
            feed.Id = null;
            feed.ParentId = projectAndTemplateMap.get(feed.ParentId).Id;
        }
        
        insert feeds;
    }
    
    public static void createFeedItem(Id parentId) {
        FeedItem[] fis = new FeedItem[] { new FeedItem(Title = 'test item #1', Type = 'ContentPost', ContentData = Blob.valueof('VGVzdCBJdGVtICMx'), ContentFileName = 'file.doc', Body = 'Test Item #1', ParentId = parentId) };
        insert fis;
    }
}