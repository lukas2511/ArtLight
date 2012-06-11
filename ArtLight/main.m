//
//  main.m
//  ArtLight
//
//  Created by Lukas Schauer on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "artnet/artnet.h"

int main(int argc, char *argv[])
{
	artnet_node node;
	node = artnet_new(NULL, 0);
	artnet_set_node_type(node, ARTNET_RAW);
	if (artnet_start(node) != ARTNET_EOK) {
		printf("Oh verdammt es ist alles kaputt: %s\n", artnet_strerror());
	}
    uint8_t dmx[3];
    unsigned char *data;
    NSInteger i, pixels, components[3];
    NSImage *image;
    NSBitmapImageRep *bitmapRep;
    CGImageRef image1;
    image1 = CGDisplayCreateImage(kCGDirectMainDisplay);
    bitmapRep = [NSBitmapImageRep alloc];
    bitmapRep = [bitmapRep initWithCGImage:image1];
    pixels = ([bitmapRep pixelsWide] * [bitmapRep pixelsHigh]);
    [bitmapRep release];
    while(1){
        NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
        CGImageRelease(image1);
        image1=NULL;
        image1 = CGDisplayCreateImage(kCGDirectMainDisplay);
        
        bitmapRep = [NSBitmapImageRep alloc];
        bitmapRep = [bitmapRep initWithCGImage:image1];
        // Create an NSImage and add the bitmap rep to it...
        image = [NSImage alloc];
        [image init];
        [image addRepresentation:bitmapRep];
        //[image addRepresentation:bitmapRep];
        
        components[0]=0;
        components[1]=0;
        components[2]=0;
        i = 0;
        
        data = bitmapRep.bitmapData;
        //data = [bitmapRep bitmapData];
        
        do {
            data++;
            components[0] += *data++;
            components[1] += *data++;
            components[2] += *data++;
        } while (++i < pixels);
        
        dmx[0] = (CGFloat)components[0] / pixels;
        dmx[1] = (CGFloat)components[1] / pixels;
        dmx[2] = (CGFloat)components[2] / pixels;
        
        artnet_raw_send_dmx(node, 0, 1, dmx);
        artnet_raw_send_dmx(node, 0, 2, dmx);
        artnet_raw_send_dmx(node, 0, 3, dmx);

        [bitmapRep release];
        [image release];
        [loopPool drain];
    }
    //return NSApplicationMain(argc, (const char **)argv);
}
