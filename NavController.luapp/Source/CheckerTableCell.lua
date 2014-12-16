
local UiTableViewCell = require 'UIKit.UITableViewCell'
local UiControl       = require 'UIKit.UIControl'
local UiButton        = require 'UIKit.UIButton'
local NsLayoutConstraint = require 'UIKit.NSLayoutConstraint'

local NSLayoutAttribute = NsLayoutConstraint.NSLayoutAttribute
local NSLayoutRelation = NsLayoutConstraint.NSLayoutRelation

local UITableViewCell = objc.UITableViewCell
local NSLayoutConstraint = objc.NSLayoutConstraint

local UpdateCheckerTableCellMessage = "CheckerTableCell updated"

local CheckerTableCell = class.createClass ('CheckerTableCell', UITableViewCell)

function CheckerTableCell:initWithStyle_reuseIdentifier(style , reuseIdentifier)
    
    self = self[UITableViewCell]:initWithStyle_reuseIdentifier (style , reuseIdentifier)
    
    if self ~= nil then
        self.accessoryType = UiTableViewCell.AccessoryType.DetailDisclosureButton
        
        local contentView = self.contentView
        
        if objc.UIDevice.currentDevice.systemVersion >= "7.0" then
            -- Needed for a correct cell layout, but this causes an exception in layoutSubviews under iOS 6
            contentView.translatesAutoresizingMaskIntoConstraints = false
        end
    
        local cellBackgroundColor = self:backgroundColor()
        
        -- Cell's label
        self.textLabel:setTranslatesAutoresizingMaskIntoConstraints(false)
        self.textLabel.backgroundColor = cellBackgroundColor
        self.textLabel.opaque = false
        self.textLabel.textColor = objc.UIColor:blackColor()
        self.textLabel.highlightedTextColor = objc.UIColor:whiteColor()
        
        -- cell's check button
        local checkButton = objc.UIButton:buttonWithType(UiButton.Type.Custom)
        checkButton:setTranslatesAutoresizingMaskIntoConstraints(false)
        checkButton.backgroundColor = cellBackgroundColor
        checkButton.contentVerticalAlignment   = UiControl.ContentVerticalAlignment.Center;
        checkButton.contentHorizontalAlignment = UiControl.ContentHorizontalAlignment.Center;
        checkButton:addTarget_action_forControlEvents (self, 'toggleCheck', UiControl.Events.TouchDown)
        self.checkButton = checkButton
        
        contentView:addSubview(checkButton);
        
        self:setNeedsUpdateConstraints()
        
        self:addMessageHandler(UpdateCheckerTableCellMessage, "refresh")
    end
    
    return self
end

local fontSize = 35
local fontFamilyName = "Avenir Next"
local fontName = "AvenirNext-MediumItalic"
local familyFontsName = objc.UIFont:fontNamesForFamilyName (fontFamilyName)

function CheckerTableCell:setAppearance ()
    -- add code here for configuring the cell if needed
end

-- Use a global for the shared tableCellHeight so it wont be reset to a default value after each update
tableCellHeight = tableCellHeight or 40 -- dummy init value

function CheckerTableCell.classMethod:setCellHeight(cellHeight)
    tableCellHeight = cellHeight - 1
    
    -- post an updated message so the constraints will be re-evaluated in all CheckerTableCell instances
    message.post (UpdateCheckerTableCellMessage)
end

local checkedImage
local uncheckedImage

local metrics = objc.toDictionary { margin = 8, spacing = 15 }

function CheckerTableCell:updateConstraints()
    
    local contentView = self.contentView
    contentView:removeConstraints(contentView.constraints)
    
    -- contentView.backgroundColor = objc.UIColor.yellowColor -- Uncomment to see the view frame
    contentView.backgroundColor = self.backgroundColor -- Uncomment to hide the view frame
    
    -- position in superview
    local contentSuperview = contentView.superview
    
    if self.contentSuperViewConstraints == nil then
        -- contentSuperview:removeConstraints (self.contentSuperViewConstraints)
        self.contentSuperViewConstraints = { NSLayoutConstraint:constraintWithItem_attribute_relatedBy_toItem_attribute_multiplier_constant
                                             (contentView, NSLayoutAttribute.Left,
                                              NSLayoutRelation.Equal,
                                              contentSuperview, NSLayoutAttribute.Left,
                                              1, 0),
                                             NSLayoutConstraint:constraintWithItem_attribute_relatedBy_toItem_attribute_multiplier_constant
                                             (contentView, NSLayoutAttribute.Top,
                                              NSLayoutRelation.Equal,
                                              contentSuperview, NSLayoutAttribute.Top,
                                              1, 0)
                                           }                                   
        contentSuperview:addConstraints (self.contentSuperViewConstraints)
    end
    
    local views = objc.toDictionary { button = self.checkButton, text = self.textLabel }
    
    -- horizontal layout
    contentView:addConstraints (NSLayoutConstraint:constraintsWithVisualFormat_options_metrics_views ("|-margin-[button]-spacing-[text]-(>=margin)-|", 0, metrics, views))
    -- center the button vertically
    contentView:addConstraints (NSLayoutConstraint:constraintsWithVisualFormat_options_metrics_views ("V:|-margin-[button]-margin-|", 0, metrics, views ))
    
    -- center the text label vertically with the button
    contentView:addConstraint (NSLayoutConstraint:constraintWithItem_attribute_relatedBy_toItem_attribute_multiplier_constant
                               (self.textLabel, NSLayoutAttribute.CenterY,
                                NSLayoutRelation.Equal,
                                self.checkButton, NSLayoutAttribute.CenterY,
                                1, 0))
    
    -- Force the content view height to the cell heigth
    contentView:addConstraint (NSLayoutConstraint:constraintWithItem_attribute_relatedBy_toItem_attribute_multiplier_constant
                               (contentView, NSLayoutAttribute.Height,
                                NSLayoutRelation.Equal,
                                nil, NSLayoutAttribute.None,
                                1, tableCellHeight))
    
    -- Add aspect ration constraint for the button
    do
        local aspectRatio = 1
        
        if checkedImage ~= nil then
            aspectRatio = checkedImage.size.width / checkedImage.size.height
        end
        
        local checkButton = self.checkButton
        
        -- checkButton.backgroundColor = objc.UIColor.redColor
        -- checkButton.backgroundColor = self.backgroundColor
        
        checkButton:removeConstraints(checkButton.constraints)
        
        -- Aspect ratio
        checkButton:addConstraint (NSLayoutConstraint:constraintWithItem_attribute_relatedBy_toItem_attribute_multiplier_constant 
                                   (checkButton, NSLayoutAttribute.Width, 
                                    NSLayoutRelation.Equal, 
                                    checkButton, NSLayoutAttribute.Height,
                                    aspectRatio , 0))
    end
    
    self[UITableViewCell]:updateConstraints ()
end

function CheckerTableCell:layoutSubviews ()
    self[UITableViewCell]:layoutSubviews ()
    
    local contentView = self.contentView
     
    local textMargin =  metrics.margin * 1.5
    local fontSize = contentView.bounds.size.height - 2 * textMargin
    self.textLabel.font = objc.UIFont:fontWithName_size(fontName, fontSize)
    
    -- Layout the views again
    self[UITableViewCell]:layoutSubviews ()
end

function CheckerTableCell:toggleCheck (sender)
    self.checked = not self.checked
    
    -- update itemInfo (model)
    self._itemInfo.checked = self.checked
end

CheckerTableCell:publishActionMethod ("toggleCheck")


CheckerTableCell:declareSetters { itemInfo = function (self, itemInfo)
                                                 self._itemInfo = itemInfo
                                                 self.textLabel.text = itemInfo.text
                                                 self.checked = itemInfo.checked
                                             end,
                                  checked = function (self, isChecked)
                                                self._checked = isChecked
                                                self.checkButton:setBackgroundImage_forState (isChecked and checkedImage or uncheckedImage, UiControl.State.Normal)
                                            end
                                }
CheckerTableCell:declareGetters { itemInfo = function (self) return self._itemInfo end,
                                  checked = function (self) return self._checked end
                                }

function CheckerTableCell:refresh ()
    self:setNeedsUpdateConstraints()
end

-- Get the checked and Unchecked button images and store them in upvalues
getResource ('data.checked', 'png', function (resourceImage) checkedImage = resourceImage end)
getResource ('data.unchecked', 'png', function (resourceImage) uncheckedImage = resourceImage end)

-- Post the specific updaye message for this module to trigger the refresh of all cells
message.post (UpdateCheckerTableCellMessage)

return CheckerTableCell