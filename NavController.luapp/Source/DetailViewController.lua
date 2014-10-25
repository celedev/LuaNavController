local UIControl = require 'UIKit.UIControl'
local UIGeometry = require 'UIKit.UIGeometry'

local isiOS7 = objc.UIDevice.currentDevice.systemVersion >= "7.0"

local UIViewController = objc.UIViewController

local DetailViewController = class.createClass ("DetailViewController", UIViewController)

function DetailViewController:loadView ()
    -- We overwrite the loadView method to manage the nib file as a dynamic resource
    getResource ('data.' .. self.nibName, 'nib', self, 'nibResource')
end

DetailViewController:declareSetters { nibResource = function (self, nibObject)
                                                        nibObject:instantiateWithOwner_options (self, nil)
                                                        if isiOS7 then 
                                                            self.edgesForExtendedLayout = UIGeometry.UIRectEdge.None
                                                        end
                                                        self:viewDidChange()
                                                    end,
                                    }

function DetailViewController:viewDidChange ()
    
    local detailView = self.view
    self.imageView         = detailView:viewWithTag(101)
    self.textLabel         = detailView:viewWithTag(102)
    self.detailedTextLabel = detailView:viewWithTag(103)
    self.checkedImageView  = detailView:viewWithTag(104)
    self.switch            = detailView:viewWithTag(105)
    
    if (self.switch) then
        self.switch:addTarget_action_forControlEvents (self, 'handleSwitch', UIControl.Events.ValueChanged)
        self.switch.on = self.dataController and self.dataController:dataForItemAtIndex(self.dataItemIndex).checked
    end
    
    self:updateDisplay ()
end

function DetailViewController:viewWillAppear (animated)
    
    self:updateDisplay ()
    -- Register for resource changed messages
   self:addMessageHandler ({"data_table_updated", 'DetailViewController class updated'}, "updateDisplay")
    
    self[UIViewController]:viewWillAppear (animated)
end

function DetailViewController:viewWillDisappear (animated)
    -- unregister for resource changed messages
    self:removeMessageHandler()
    
    self[UIViewController]:viewWillDisappear (animated)
end

function DetailViewController:handleSwitch (sender)
    if self.dataController then
        local itemData = self.dataController:dataForItemAtIndex (self.dataItemIndex)
        
        if itemData.checked ~= sender.on then
            itemData.checked = sender.on;
            self:setCheckedStatusImage (itemData)
        end
    end    
end
DetailViewController:publishActionMethod ('handleSwitch')

function DetailViewController:setCheckedStatusImage (itemData)
    if self.checkedImageView then 
        getResource (itemData.checked and 'data.checked' or 'data.unchecked', 'public.image', self.checkedImageView, 'image')
    end
end

function DetailViewController:updateDisplay (message, name, object)
    
    if self.dataController then
        local itemData = self.dataController:dataForItemAtIndex (self.dataItemIndex)
        
        local itemImageName = itemData.image
        if itemImageName then
            getResource ('data.' .. itemImageName, 'public.image', self.imageView, 'image')
        end
        
        local itemTitle = itemData.text
        self.title = itemTitle
        self.textLabel.text = itemTitle
        
        self.detailedTextLabel.text = itemData.detail
        self:setCheckedStatusImage (itemData)
    end
end

message.post 'DetailViewController class updated'

return DetailViewController