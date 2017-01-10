//
//  AppDelegate.swift
//  BingWallpaper
//
//  Created by John Stray on 2/1/17.
//  Copyright © 2017 John Stray. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var prefWindow: NSWindow!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let bingAPI = BingAPI()
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBOutlet weak var labelText: NSTextFieldCell!
    @IBOutlet weak var copyrightText: NSTextFieldCell!
    @IBOutlet weak var statusText: NSTextFieldCell!
    @IBOutlet weak var previewLabel: NSTextFieldCell!
    @IBOutlet weak var previewDate: NSTextFieldCell!
    @IBOutlet weak var previewImageContainer: NSImageCell!
    
    @IBAction func infoButton(_ sender: NSButton) {
        let wallpaperInfo = self.bingAPI.fetchWallpaperDetails()
        let infoURL = URL(string: wallpaperInfo[4] as! String)
        NSWorkspace.shared().open(infoURL!)
    }
    

    @IBAction func refreshClicked(_ sender: NSButton) {
        statusText.title = "Fetching image data..."
        fetchWallpaper()
    }
    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        statusText.title = "Fetching image data..."
        fetchWallpaper()
    }
    
    func fetchWallpaper() {
        
        let wallpaperInfo = self.bingAPI.fetchWallpaperDetails()
        let baseURL = wallpaperInfo[2] as! String
        
        let IMAGE_URL = NSURL(string: baseURL)
        let networkService = NetworkService(url: IMAGE_URL!)
        networkService.downloadImage(completion: { (data) in
            let image = NSImage(data: data as Data)
            DispatchQueue.main.async(execute: {
                self.previewImageContainer.image = image
                self.statusText.title = "Image Download Complete!"
                let wallpaperDetails = self.bingAPI.fetchWallpaperDetails()
                let cpyw = wallpaperDetails[1] as! String
                let date = wallpaperDetails[3] as! String
                
                self.labelText.title = wallpaperDetails[0] as! String
                self.copyrightText.title = wallpaperDetails[1] as! String
                self.previewLabel.title = wallpaperDetails[0] as! String
                self.previewDate.title = date + " - " + cpyw
            })
        })
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

