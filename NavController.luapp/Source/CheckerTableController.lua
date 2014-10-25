local UIView      = require "UIKit.UIView"
local UITableView = require "UIKit.UITableView"
local NSPropertyList = require "Foundation.NSPropertyList"

local CheckerCell          = require "CheckerTableCell"
local DetailViewController = require "DetailViewController"

local UITableViewController = objc.UITableViewController

local CheckerTableViewController = class.createClass ("CheckerTableViewController", UITableViewController)

local myCellId = 'myCellId'

function CheckerTableViewController:loadView ()
    
    -- create the tableView
    local tableView = objc.UITableView:newWithFrame_style (objc.UIScreen:mainScreen().applicationFrame, 
                                                           UITableView.Style.Plain)
    tableView.autoresizingMask = UIView.Autoresizing.FlexibleHeight + UIView.Autoresizing.FlexibleWidth
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView:registerClass_forCellReuseIdentifier(CheckerCell, myCellId)
    
    self.tableView = tableView
    
    -- read the table data. "_tableItems" corresponds to a setter declared below.
    getResource ("data.tableItems", 'plist', self, "_tableItems")
    
    -- subscribe to all module and resource load messages (actually, this is overkill for this example!) 
    self:addMessageHandler ({"system.did_load_module", "system.did_load_resource"}, "refresh")
    
    self:configure ()
end

function CheckerTableViewController:configure ()
    -- The configure method is called by the loadView and refresh methods.
    -- It contains the code that we want to execute each time we change the code

    self.title = "Fruits"
    
    self.tableView.rowHeight = 60
    
    -- update the height in the tableViewCell
    CheckerCell:setCellHeight(self.tableView.rowHeight)
    
    -- And force a reload of the table
    self.tableView:reloadData ()
end

CheckerTableViewController:declareSetters { _tableItems = function (self, plistResource)
                                                              self.tableItems = plistResource
                                                              -- post a notification for interested objects
                                                              message.post ('data_table_updated')
                                                          end
                                          }
-- Data source protocol

function CheckerTableViewController:numberOfSectionsInTableView (tableView)
    return 1
end

function CheckerTableViewController:tableView_numberOfRowsInSection (tableView, sectionIndex)
    local tableItems = self.tableItems
    -- return tableItems.count if tableItems is non-nil, or otherwise 0
    return tableItems and tableItems.count or 0
end

function CheckerTableViewController:tableView_cellForRowAtIndexPath(tableView, indexPath)
    
    local cell = tableView:dequeueReusableCellWithIdentifier (myCellId)
    
    cell.itemInfo = self.tableItems [indexPath.row + 1] -- Lua indexes start at 1
    
    cell:setAppearance()
    
    return cell
end

 function CheckerTableViewController:tableView_didSelectRowAtIndexPath (tableView, indexPath)
    
    local selectedCell = tableView:cellForRowAtIndexPath(indexPath)
    
    -- dont' keep the selection
    tableView:deselectRowAtIndexPath_animated(indexPath, true)
    
    -- Behave like if the button was pressed
    selectedCell:toggleCheck (self)
end

function CheckerTableViewController:tableView_accessoryButtonTappedForRowWithIndexPath (tableView, indexPath)
    
    local tappedCell = tableView:cellForRowAtIndexPath(indexPath)
    local cellItem = self.tableItems [indexPath.row + 1]
    
    local detailController = DetailViewController:newWithNibName_bundle ('DetailViewController', nil)
    detailController.dataController = self
    detailController.dataItemIndex = indexPath.row + 1
    
    local appDelegate = objc.UIApplication:sharedApplication().delegate
    appDelegate.navController:pushViewController_animated (detailController, true)
end

function CheckerTableViewController:dataForItemAtIndex(itemIndex)
    return self.tableItems [itemIndex]
end

function CheckerTableViewController:refresh ()
    self:configure()
end

return CheckerTableViewController
