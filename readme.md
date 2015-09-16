# Lua Nav Controller

LuaNavController is a simple UITableView-based CodeFlow application for iOS, with a list view and a detail view, entirely written in Lua.

### Resources

LuaNavController illustrates the various ways to use live resource update in CodeFlow. It includes resources of various types: images, plist and interface builder xib files.

All resources are truly live: if you edit any of them or replace it with a compatible file (try dragging a file from the finder over a resource in the files list), you see right away the change in the application. 

You can also do live-update with the Interface Builder file (xib file) for the DetailViewController. When you edit the file in Xcode and save it, a few seconds later the changes are propagated to you app and you can see them in the real context. 

In the code, this live nib update is achieved by overwriting the  DetailViewController `loadView` method and instantiating the nib manually in the corresponding setter. Have a look at the code in DetailViewController and you will see that the corresponding processing is really simple.

### Notifications

This application also contains examples of inter-objects notifications. 

For example, CheckerTableViewController defines a setter `_tableItems` for handling the updates of the plist resource and in the setter function, it posts a  custom message `'data_table_updated'`.

DetailViewController subscribes to this message in its `viewDidAppear` method, so its `updateDisplay` is called when the data table is changed.

### Live auto-layout tuning

 The CheckerTableCell class is a UITableViewCell subclass that adds a button to the basic iOS table cell. CheckerTableCell is autolayout-based and defines a set of constraints in its `updateConstraints` method.
 
 In this case, live-update is simply achieved by calling `self:setNeedsUpdateConstraints()` after each update of the module code, or when the tableView row height is changed.
 
## Configuration required

A Mac with Celedev CodeFlow version 0.9.18 or later.

Works on iPhone or iPad, running iOS 7.1 or later.

## How to use this code sample

1. Open the CodeFlow project for this sample application.  
  This will automatically update the associated Xcode project, so that paths and other build settings are correctly set for your environment.

2. Open the associated Xcode project. You can do this in CodeFlow with the menu command `Program -> Open Xcode Project`.

3. Run the application on a device or in the simulator.

4. In CodeFlow, select the application in the `Target` popup menu in the project window toolbar. The app stops on a breakpoint at the first line of the Lua program.

5. Click on the `Continue` button in the toolbar (or use the CodeFlow debugger for stepping in the program) 

6. Enjoy the power of live coding with CodeFlow

## Troubleshooting

- **Some libraries / header files in the sample app Xcode project are missing**

  **⇒ Fix**: open the corresponding CodeFlow project, and CodeFlow will update the associated Xcode project, so that paths and libraries are correctly set.

- **Link errors (missing symbols) occur when I compile the Xcode project**

  **Most probable cause**: if you are using Xcode 5 (and thus iOS 7.1 SDK), these errors occur because the sample app is configured for the iOS 8 SDK.

  **⇒ Fix**: In the CodeFlow project, use the bindings library for the iOS 7.1 SDK in replacement of the one for the iOS 8 SDK
    - Download [CodeFlow bindings for iOS 7.1 SDK](https://www.celedev.com/en/support/downloads/codeflow-bindings-ios7-1-sdk.dmg), and double-click on the .luabindings library file to install it in codeFlow; 
    - If needed, select the iOS 7.1 SDK library in CodeFlow project (menu `Program -> Select SDK Library -> iOS 7.1 SDK` or using the contextual menu on the current iOS External Lib);
    - CodeFlow will then update the associated Xcode project so that it links with the iOS 7.1 SDK bindings libraries.

## License

This application is provided under the MIT License (MIT)

Copyright (c) 2014-2015 Celedev.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.