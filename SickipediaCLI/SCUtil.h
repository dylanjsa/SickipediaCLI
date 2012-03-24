//DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
//Version 2, December 2004 
//
//Copyright (C) 2004 Sam Hocevar <sam@hocevar.net> 
//
//Everyone is permitted to copy and distribute verbatim or modified 
//copies of this license document, and changing it is allowed as long 
//as the name is changed. 
//
//DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
//TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 
//
//0. You just DO WHAT THE FUCK YOU WANT TO. 
//
/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */

#ifndef SickipediaCLI_SCUtil_h
#define SickipediaCLI_SCUtil_h

#import <ncurses.h>

typedef int SCKeyCode;

static SCKeyCode SCRead() {
    return getch();
}

static void SCPause() {
    getch();
}

static void SCInitScreen() {
    initscr();
    noecho();
}

static void SCRebuildScreen() {
    refresh();
}

static void SCCleanup() {
    endwin();
}

static void SCSetBoldOn(BOOL enabled) {
    if(enabled) {
        attron(A_BOLD);
    }else{
        attroff(A_BOLD);
    }
}

static void SCWriteString(NSString *string) {
    printw([string UTF8String]);
}

static void SCWriteLine(NSString *string) {
    printw("%s\n", [string UTF8String]);
}

static void SCWriteBoldString(NSString *string) {
    SCSetBoldOn(YES);
    SCWriteString(string);
    SCSetBoldOn(NO);
}

static void SCWriteBoldLine(NSString *string) {
    SCSetBoldOn(YES);
    SCWriteLine(string);
    SCSetBoldOn(NO);
}

static void SCMove(CGPoint point) {
    move(point.y, point.x);
}

static void SCWriteLineAtPoint(CGPoint point, NSString *string) {
    SCMove(point);
    SCWriteLine(string);
}

static void SCWriteBoldLineAtPoint(CGPoint point, NSString *string) {
    SCMove(point);
    SCWriteBoldLine(string);
}

static CGSize SCGetScreenSize() {
    int x, y;
    getmaxyx(stdscr, y,x);
    
    return CGSizeMake(x, y);
}

#endif