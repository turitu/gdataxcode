//
//  AppDelegate.m
//  gdataxcode
//
//  Created by Markus Landin on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "GData.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}


/*
 Ladda user-url:en för att få tillbaka feed med info om album
*/
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"applicationDidFinishLaunching()");
    // Insert code here to initialize your application
    
    GDataServiceGooglePhotos *photoservice = [self createPhotoService];
    NSURL *feedUrl = [GDataServiceGooglePhotos photoFeedURLForUserID:@"markuslandin"
                                                             albumID:nil albumName:nil
                                                             photoID:nil kind:nil access:nil];
    
    [feedUrl isFileURL];
    
    NSLog(@"Laddar url: %@", [feedUrl absoluteString]);
    [photoservice fetchFeedWithURL:feedUrl 
                          delegate:self 
                 didFinishSelector:@selector(albumFeedHandlerCB:finishedWithFeed:error:)];
    
    /*GDataServiceGooglePhotos *photoservice = nil;
    
    photoservice = [[GDataServiceGooglePhotos alloc] init];
    [photoservice setUserAgent:@"markusapp"];
    [photoservice setShouldCacheResponseData:YES];
    [photoservice setUserCredentialsWithUsername:nil password:nil];*/
    
    //NSURL *feedUrl = [photoservice photoFeedURLForUserID:@"markuslandin" albumID:@"Lilltjejen"];

    //NSURL *feedUrl = [GDataServiceGooglePhotos photoFeedURLForUserID:@"markuslandin" albumID:@"diversepublikabilder" albumName:nil photoID:nil kind:nil access:nil];
    //NSURL *feedUrl = [photoservice photoFeedURLForUserID:@"markuslandin" albumID:@"diversepublikabilder" albumName:nil photoID:nil kind:nil access:nil];
    
    //GDataQueryGooglePhotos *photoquery = nil;
    //photoquery = [[GDataQueryGooglePhotos alloc] init];
    //photoquery = [GDataQueryGooglePhotos photoQueryWithFeedURL:feedUrl];
    //photoquery = [GDataQueryGooglePhotos photoQueryForUserID:@"markuslandin" albumID:nil albumName:nil photoID:nil];

     //ticket = [service fetchFeedWithURL:feedURL
       //                        delegate:self
         //             didFinishSelector:@selector(entryListFetchTicket:finishedWithFeed:error:)];     
     
    //[self testfunc];
    //[self loadLogo];
}
 
-(GDataServiceGooglePhotos*)createPhotoService
{
    GDataServiceGooglePhotos *photoservice = nil;
    photoservice = [[GDataServiceGooglePhotos alloc] init];
    [photoservice setUserAgent:@"markusapp"];
    [photoservice setShouldCacheResponseData:YES];
    [photoservice setUserCredentialsWithUsername:nil password:nil];
    return photoservice;
}

-(void)loadfeed: (GDataServiceGooglePhotos *)photoservice
{
    GDataQueryGooglePhotos *photoquery = [[GDataQueryGooglePhotos alloc] init];

}

/*  
 Callback för album feeden. (Som svar på att vi laddat url:en med user id)
 Identifierar första albumet
 Skriver ut albumnamnet i konsolen.
 Anropar subfunktion för att ladda info om albumet.
*/
- (void)albumFeedHandlerCB:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedBase *)feed error:(NSError *)error
{	
    if (error == nil)
	{
		GDataFeedPhoto *albumsfeed = (GDataFeedPhoto *)feed;
        int nbrAlbums = [[albumsfeed entries] count];
		GDataEntryPhotoAlbum *album = (GDataEntryPhotoAlbum *)[[albumsfeed entries] objectAtIndex:1]; // 0 = första albumet
        NSString *albumName = [[album title] stringValue];   
        NSLog(@"Album: %@", albumName);
        NSString *albumId = [album GPhotoID];
        NSLog(@"Album ID: %@", albumId);
        
        [self fetchPhotosList:album];
	}
	else {
		NSLog(@"fetch error: %@", error);
	}    
    
}


/*
 Requesting a list of photos -- Listing photos in an album
 (Dev guide: https://developers.google.com/picasa-web/docs/2.0/developers_guide_protocol#ListPhotos )
 (Dev guide: https://developers.google.com/picasa-web/docs/2.0/reference#Parameters )
 Sätt maxstorlek på bilderna som ska hämtas
 Ladda url:en för albumet, tex
 https://photos.googleapis.com/data/feed/api/user/markuslandin/albumid/5146578133798094961 (...?imgmax=1440)
 Registrera callback för svarsfeed med info om albumets bilder
*/
- (void)fetchPhotosList:(GDataEntryPhotoAlbum *)album
{
    NSURL *feedUrl = [[album feedLink] URL];
    GDataServiceGooglePhotos *photoservice = [self createPhotoService];
    
    GDataQueryGooglePhotos *query = [GDataQueryGooglePhotos photoQueryWithFeedURL:feedUrl];
    [query setImageSize:1440];
    NSLog(@"Laddar url: %@", [[query URL] absoluteString]);
    [photoservice fetchFeedWithURL:[query URL] 
                          delegate:self 
                 didFinishSelector:@selector(photosFeedHandlerCB:finishedWithFeed:error:)];
        
    /*NSLog(@"Laddar url: %@", [feedUrl absoluteString]);
    [photoservice fetchFeedWithURL:feedUrl 
                          delegate:self 
                 didFinishSelector:@selector(photosFeedHandlerCB:finishedWithFeed:error:)];*/
}

#pragma mark LADDA BILDEN
/*
 Callback för svarsfeed med info om albumets bilder
 Identifiera första bilden i albumet
*/
- (void)photosFeedHandlerCB:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedBase *)feed error:(NSError *)error
{	
    GDataFeedPhotoAlbum *photosFeed = (GDataFeedPhotoAlbum *)feed;
    int nbrPhotos = [[photosFeed entries] count]; // antal foton i albumet.
    GDataEntryPhoto *photoEntry = [[photosFeed entries] objectAtIndex:1]; // plocka ut andra bilden i albumet
    NSLog(@"Photo name: %@", [[photoEntry title] stringValue]);
    
    
    // TODO: Identifiera url:en till den faktiska bilden, och spara ner till disk.
  
    NSArray *mediaContents = [[photoEntry mediaGroup] mediaContents];
    GDataMediaContent *imageContent;
    imageContent = [GDataUtilities firstObjectFromArray:mediaContents
                                              withValue:@"image"
                                             forKeyPath:@"medium"];    
    NSURL *downloadURL = [NSURL URLWithString:[imageContent URLString]];    
        NSLog(@"Laddar bild: %@", [downloadURL absoluteString]);
    
    // TODO: Kolla hur exemplet "fångar upp" bilden så att den kan visas
    
}

// photoEntry är albumets (första) bild som ska ladda
- (void)loadPhoto: (GDataEntryPhoto *)photoEntry
{
    // TODO: Detta är funktionen för att identifiera url:en till bilden, och ladda den. Implementera!
    NSArray *mediaContents = [[photoEntry mediaGroup] mediaContents];
    GDataMediaContent *imageContent;
    imageContent = [GDataUtilities firstObjectFromArray:mediaContents
                                              withValue:@"image"
                                             forKeyPath:@"medium"];
    
/*
    if (error == nil) {
        // now download the uploaded photo data
        NSString *savePath = [ticket propertyForKey:@"save path"];
        
        // we'll search for the media content element with the medium attribute of
        // "image" to find the download URL; there may be more than one
        // media:content element
        //
        // http://code.google.com/apis/picasaweb/docs/2.0/reference.html#media_content
        NSArray *mediaContents = [[photoEntry mediaGroup] mediaContents];
        GDataMediaContent *imageContent;
        imageContent = [GDataUtilities firstObjectFromArray:mediaContents
                                                  withValue:@"image"
                                                 forKeyPath:@"medium"];
        if (imageContent) {
            NSURL *downloadURL = [NSURL URLWithString:[imageContent URLString]];
            
            // requestForURL:ETag:httpMethod: sets the user agent header of the
            // request and, when using ClientLogin, adds the authorization header
            GDataServiceGooglePhotos *service = [self googlePhotosService];
            NSMutableURLRequest *request = [service requestForURL:downloadURL
                                                             ETag:nil
                                                       httpMethod:nil];
            // fetch the request
            GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
            [fetcher setAuthorizer:[service authorizer]];
            
            // http logs are easier to read when fetchers have comments
            [fetcher setCommentWithFormat:@"downloading %@",
             [[photoEntry title] stringValue]];
            
            [fetcher beginFetchWithDelegate:self
                          didFinishSelector:@selector(downloadFetcher:finishedWithData:error:)];
            
            [fetcher setProperty:savePath forKey:@"save path"];
            [fetcher setProperty:photoEntry forKey:@"photo entry"];
        } else {
            // no image content for this photo entry; this shouldn't happen for
            // photos
        }
    }
*/
    
/*    
    NSURL *url = [NSURL URLWithString: @"http://www.google.com/images/logos/ps_logo2.png"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:NULL 
                                                     error:&error];
    if (!data) {
        NSLog(@"fetch error: %@", [error localizedDescription]);
        return;
    }
    
    NSLog(@"The file is %lu bytes", [data length]);
    
    BOOL written = [data writeToFile:@"/tmp/google.png" options:0 error:&error];
    
    if (!written) {
        NSLog(@"Write failed");
    }  
 */
}

/*
albumfeedhandler 
{
// get the photo entry's title
GDataEntryPhoto *photoEntry = [[mAlbumPhotosFeed entries] objectAtIndex:row];
return [[photoEntry title] stringValue];
}

// for the album selected in the top list, begin retrieving the list of
// photos
- (void)fetchSelectedAlbum {
    
    GDataEntryPhotoAlbum *album = [self selectedAlbum];
    if (album) {
        
        // fetch the photos feed
        NSURL *feedURL = [[album feedLink] URL];
        if (feedURL) {
            [self setPhotoFeed:nil];
            [self setPhotoFetchError:nil];
            [self setPhotoFetchTicket:nil];
            
            GDataServiceGooglePhotos *service = [self googlePhotosService];
            GDataServiceTicket *ticket;
            ticket = [service fetchFeedWithURL:feedURL
                                      delegate:self
                             didFinishSelector:@selector(photosTicket:finishedWithFeed:error:)];
            [self setPhotoFetchTicket:ticket];
            
            [self updateUI];
        }
    }
}
*/


- (void)feedHandler:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedBase *)feed error:(NSError *)error
{
    int j = 0;
    j++;
	
    if (error == nil)
	{
		GDataFeedPhoto *photofeed = (GDataFeedPhoto *)feed;
		int i;
        int nbrAlbums;
        
        nbrAlbums = [[photofeed entries] count];
		
        for (i = 0; i < nbrAlbums; i++) {
            NSString *albumName = nil;
            GDataEntryBase *entry = [[photofeed entries] objectAtIndex:i];
            //GDataEntryPhoto *photo = (GDataEntryPhoto *)entry;
            GDataEntryPhotoAlbum *album = (GDataEntryPhotoAlbum *)entry;
            albumName = [[album title] stringValue];
            NSLog(@"Album: %@", albumName);
            [entry alternateLink];
            NSString *albId = [album GPhotoID];
            
            NSLog(@"Album ID: %@", albId);
        }
        
/*		for (i = 0; i < [[vfeed entries] count]; i++)
		{
			GDataEntryBase *entry = [[vfeed entries] objectAtIndex:i];
			if (![entry respondsToSelector:@selector(mediaGroup)]) continue;
			
			GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo *)entry;
			
			NSArray *thumbnails = [[video mediaGroup] mediaThumbnails];
			if ([thumbnails count] == 0) continue;
			
			NSString *imageURLString = [[thumbnails objectAtIndex:0] URLString];
			[self fetchEntryImageURLString:imageURLString withVideo:video];
 		}*/
	}
	else {
		NSLog(@"fetch error: %@", error);
	}    
    
}

- (void)loadLogo
{
    NSURL *url = [NSURL URLWithString: @"http://www.google.com/images/logos/ps_logo2.png"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:NULL 
                                                     error:&error];
    if (!data) {
        NSLog(@"fetch error: %@", [error localizedDescription]);
        return;
    }
    
    NSLog(@"The file is %lu bytes", [data length]);
    
    BOOL written = [data writeToFile:@"/tmp/google.png" options:0 error:&error];
    
    if (!written) {
        NSLog(@"Write failed");
    }
}
- (void)testfunc
{
    int i = 0;
    i++;
}

@end
