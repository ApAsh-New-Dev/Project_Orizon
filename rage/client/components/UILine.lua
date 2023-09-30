---
--- @author Dylan MALANDAIN
--- @version 2.0.0
--- @since 2020
---
--- RageUI Is Advanced UI Libs in LUA for make beautiful interface like RockStar GAME.
---
---
--- Commercial Info.
--- Any use for commercial purposes is strictly prohibited and will be punished.
---
--- @see RageUI
---

---@type table

local SettingsButtonBase = {
    Rectangle = { Y = 0, Width = 420, Height = 38 },
    Line = { X = 8, Y = 15 },
    SelectedSprite = { Dictionary = "commonmenu", Texture = "gradient_nav", Y = 0, Width = 431, Height = 38 },
}

local SettingsButton = {
    Rectangle = { Y = 0, Width = 431, Height = 38 },
    Text = { X = 8, Y = 3, Scale = 0.33 },
}

local SettingsButtonMini = {
    Rectangle = { Y = 0, Width = 431, Height = 20 },
    Text = { X = 8, Y = 3, Scale = 0.33 },
}

local SettingsButtonUltraMini = {
    Rectangle = { Y = 0, Width = 431, Height = 10 },
    Text = { X = 8, Y = 3, Scale = 0.33 },
}


function RageUI.Line(Style)
    local CurrentMenu = RageUI.CurrentMenu
    if CurrentMenu ~= nil then
        if CurrentMenu() then
            local Option = RageUI.Options + 1
            if CurrentMenu.Pagination.Minimum <= Option and CurrentMenu.Pagination.Maximum >= Option then
                if Style then
                    if Style.BackgroundColor then
                        RenderRectangle(CurrentMenu.X, CurrentMenu.Y + SettingsButtonBase.SelectedSprite.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, SettingsButtonBase.SelectedSprite.Width + CurrentMenu.WidthOffset, SettingsButtonBase.SelectedSprite.Height, Style.BackgroundColor[1], Style.BackgroundColor[2], Style.BackgroundColor[3], Style.BackgroundColor[4])
                    end
                    if Style.Line then
                        RenderRectangle(CurrentMenu.X + SettingsButtonBase.Line.X + (CurrentMenu.WidthOffset * 0.8 ~= 0 and CurrentMenu.WidthOffset * 0.8 or 60), CurrentMenu.Y + SettingsButtonBase.Line.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 300, 3, Style.Line[1], Style.Line[2], Style.Line[3], Style.Line[4])
                    end
                else
                    RenderRectangle(CurrentMenu.X + SettingsButtonBase.Line.X + (CurrentMenu.WidthOffset * 0.8 ~= 0 and CurrentMenu.WidthOffset * 0.8 or 60), CurrentMenu.Y + SettingsButtonBase.Line.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 300, 3, 255, 128, 0, 255)
                end

                RageUI.ItemOffset = RageUI.ItemOffset + SettingsButtonBase.Rectangle.Height
                if (CurrentMenu.Index == Option) then
                    if (RageUI.LastControl) then
                        CurrentMenu.Index = Option - 1
                        if (CurrentMenu.Index < 1) then
                            CurrentMenu.Index = RageUI.CurrentMenu.Options
                        end
                    else
                        CurrentMenu.Index = Option + 1
                    end
                end
            end
            RageUI.Options = RageUI.Options + 1
        end
    end
end

function RageUI.Line2(Style)
    local CurrentMenu = RageUI.CurrentMenu
    if CurrentMenu ~= nil then
        if CurrentMenu() then
            local Option = RageUI.Options + 1
            if CurrentMenu.Pagination.Minimum <= Option and CurrentMenu.Pagination.Maximum >= Option then
                if Style then
                    if Style.BackgroundColor then
                        RenderRectangle(CurrentMenu.X, CurrentMenu.Y + SettingsButtonBase.SelectedSprite.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, SettingsButtonBase.SelectedSprite.Width + CurrentMenu.WidthOffset, SettingsButtonBase.SelectedSprite.Height, Style.BackgroundColor[1], Style.BackgroundColor[2], Style.BackgroundColor[3], Style.BackgroundColor[4])
                    end
                    if Style.Line then
                        RenderRectangle(CurrentMenu.X + SettingsButtonBase.Line.X + (CurrentMenu.WidthOffset * 0.8 ~= 0 and CurrentMenu.WidthOffset * 0.8 or 60), CurrentMenu.Y + SettingsButtonBase.Line.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 300, 3, Style.Line[1], Style.Line[2], Style.Line[3], Style.Line[4])
                    end
                else
                    RenderRectangle(CurrentMenu.X + SettingsButtonBase.Line.X + (CurrentMenu.WidthOffset * 0.8 ~= 0 and CurrentMenu.WidthOffset * 0.8 or 60), CurrentMenu.Y + SettingsButtonBase.Line.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 300, 3, 0, 0, 255, 255)
                end

                RageUI.ItemOffset = RageUI.ItemOffset + SettingsButtonBase.Rectangle.Height
                if (CurrentMenu.Index == Option) then
                    if (RageUI.LastControl) then
                        CurrentMenu.Index = Option - 1
                        if (CurrentMenu.Index < 1) then
                            CurrentMenu.Index = RageUI.CurrentMenu.Options
                        end
                    else
                        CurrentMenu.Index = Option + 1
                    end
                end
            end
            RageUI.Options = RageUI.Options + 1
        end
    end
end

function RageUI.Color(R,G,B,O)
    local CurrentMenu = RageUI.CurrentMenu
    local Description = RageUI.Settings.Items.Description;
    if CurrentMenu ~= nil then
        if CurrentMenu() then
            local Option = RageUI.Options + 1
            if CurrentMenu.Pagination.Minimum <= Option and CurrentMenu.Pagination.Maximum >= Option then

                RenderRectangle(CurrentMenu.X + Description.Bar.Y + 60 + CurrentMenu.SubtitleHeight , CurrentMenu.Y + Description.Bar.Y + 2.5 + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, Description.Bar.Width - 120 + CurrentMenu.WidthOffset, Description.Bar.Height - 0.7, R, G, B, O)
                RageUI.ItemOffset = RageUI.ItemOffset + SettingsButtonBase.Rectangle.Height + Description.Bar.Height 
                if (CurrentMenu.Index == Option) then
                    if (RageUI.LastControl) then
                        CurrentMenu.Index = Option - 0
                        if (CurrentMenu.Index < 0) then
                            CurrentMenu.Index = RageUI.CurrentMenu.Options
                        end
                    else
                        CurrentMenu.Index = Option + 0
                    end
                end
            end
            RageUI.Options = RageUI.Options + 0
        end
    end
end


function RageUI.RenderText(Label)
    local CurrentMenu = RageUI.CurrentMenu
    if CurrentMenu ~= nil then
        if CurrentMenu() then
            local Option = RageUI.Options + 1
            if CurrentMenu.Pagination.Minimum <= Option and CurrentMenu.Pagination.Maximum >= Option then
                if (Label ~= nil) then
                    RenderRectangle(CurrentMenu.X + SettingsButton.Text.X + (CurrentMenu.WidthOffset * 0.5 ~= 0 and CurrentMenu.WidthOffset * 2.5 or 20), CurrentMenu.Y + SettingsButton.Text.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 375, 35, 255, 255, 255, 255)
                    RenderRectangle(CurrentMenu.X + SettingsButton.Text.X + (CurrentMenu.WidthOffset * 0.5 ~= 0 and CurrentMenu.WidthOffset * 2.5 or 20), CurrentMenu.Y + SettingsButton.Text.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 375, 30, 0, 0, 0, 255)
                    RenderText(Label, CurrentMenu.X + SettingsButton.Text.X + (CurrentMenu.WidthOffset * 0.5 ~= 0 and CurrentMenu.WidthOffset * 2.5 or 200), CurrentMenu.Y + SettingsButton.Text.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 0, SettingsButton.Text.Scale, 255, 245, 245, 255, 1)
                end
                RageUI.ItemOffset = RageUI.ItemOffset + SettingsButton.Rectangle.Height
                if (CurrentMenu.Index == Option) then
                    if (RageUI.LastControl) then
                        CurrentMenu.Index = Option - 1
                        if (CurrentMenu.Index < 1) then
                            CurrentMenu.Index = RageUI.CurrentMenu.Options
                        end
                    else
                        CurrentMenu.Index = Option + 1
                    end
                end
            end
            RageUI.Options = RageUI.Options + 1
        end
    end
end


--[[function RageUI.Separator(Label)
    local CurrentMenu = RageUI.CurrentMenu
    if CurrentMenu ~= nil then
        if CurrentMenu() then
            local Option = RageUI.Options + 1
            if CurrentMenu.Pagination.Minimum <= Option and CurrentMenu.Pagination.Maximum >= Option then
                if (Label ~= nil) then
                    RenderText(Label, CurrentMenu.X + SettingsButton.Text.X + (CurrentMenu.WidthOffset * 2.5 ~= 0 and CurrentMenu.WidthOffset * 2.5 or 200), CurrentMenu.Y + SettingsButton.Text.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 0, SettingsButton.Text.Scale, 245, 245, 245, 255, 1)
                end
                RageUI.ItemOffset = RageUI.ItemOffset + SettingsButton.Rectangle.Height
                if (CurrentMenu.Index == Option) then
                    if (RageUI.LastControl) then
                        CurrentMenu.Index = Option - 1
                        if (CurrentMenu.Index < 1) then
                            CurrentMenu.Index = RageUI.CurrentMenu.Options
                        end
                    else
                        CurrentMenu.Index = Option + 1
                    end
                end
            end
            RageUI.Options = RageUI.Options + 1
        end
    end
end]]

function RageUI.SeparatorMini(Label)
    local CurrentMenu = RageUI.CurrentMenu
    if CurrentMenu ~= nil then
        if CurrentMenu() then
            local Option = RageUI.Options + 1
            if CurrentMenu.Pagination.Minimum <= Option and CurrentMenu.Pagination.Maximum >= Option then
                if (Label ~= nil) then
                    RenderText(Label, CurrentMenu.X + SettingsButtonMini.Text.X + (CurrentMenu.WidthOffset * 2.5 ~= 0 and CurrentMenu.WidthOffset * 2.5 or 200), CurrentMenu.Y + SettingsButtonMini.Text.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 0, SettingsButtonMini.Text.Scale, 245, 245, 245, 255, 1)
                end
                RageUI.ItemOffset = RageUI.ItemOffset + SettingsButtonMini.Rectangle.Height
                if (CurrentMenu.Index == Option) then
                    if (RageUI.LastControl) then
                        CurrentMenu.Index = Option - 1
                        if (CurrentMenu.Index < 1) then
                            CurrentMenu.Index = RageUI.CurrentMenu.Options
                        end
                    else
                        CurrentMenu.Index = Option + 1
                    end
                end
            end
            RageUI.Options = RageUI.Options + 1
        end
    end
end

function RageUI.SeparatorUltraMini(Label)
    local CurrentMenu = RageUI.CurrentMenu
    if CurrentMenu ~= nil then
        if CurrentMenu() then
            local Option = RageUI.Options + 1
            if CurrentMenu.Pagination.Minimum <= Option and CurrentMenu.Pagination.Maximum >= Option then
                if (Label ~= nil) then
                    RenderText(Label, CurrentMenu.X + SettingsButtonUltraMini.Text.X + (CurrentMenu.WidthOffset * 2.5 ~= 0 and CurrentMenu.WidthOffset * 2.5 or 200), CurrentMenu.Y + SettingsButtonUltraMini.Text.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 0, SettingsButtonUltraMini.Text.Scale, 245, 245, 245, 255, 1)
                end
                RageUI.ItemOffset = RageUI.ItemOffset + SettingsButtonUltraMini.Rectangle.Height
                if (CurrentMenu.Index == Option) then
                    if (RageUI.LastControl) then
                        CurrentMenu.Index = Option - 1
                        if (CurrentMenu.Index < 1) then
                            CurrentMenu.Index = RageUI.CurrentMenu.Options
                        end
                    else
                        CurrentMenu.Index = Option + 1
                    end
                end
            end
            RageUI.Options = RageUI.Options + 1
        end
    end
end



function RageUI.Line3()
    local CurrentMenu = RageUI.CurrentMenu
    if CurrentMenu ~= nil then
        if CurrentMenu() then
            local Option = RageUI.Options + 1
            if CurrentMenu.Pagination.Minimum <= Option and CurrentMenu.Pagination.Maximum >= Option then
                RenderText("_____________________", CurrentMenu.X + SettingsButton.Text.X+6.5 + (CurrentMenu.WidthOffset * 2.5 ~= 0 and CurrentMenu.WidthOffset * 2.5 or 200), CurrentMenu.Y + SettingsButton.Text.Y-6 + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 0, SettingsButton.Text.Scale, 245, 245, 245, 255, 1)
                RageUI.ItemOffset = RageUI.ItemOffset + SettingsButton.Rectangle.Height
                if (CurrentMenu.Index == Option) then
                    if (RageUI.LastControl) then
                        CurrentMenu.Index = Option - 1
                        if (CurrentMenu.Index < 1) then
                            CurrentMenu.Index = RageUI.CurrentMenu.Options
                        end
                    else
                        CurrentMenu.Index = Option + 1
                    end
                end
            end
            RageUI.Options = RageUI.Options + 1
        end
    end
end

--- Reference : https://github.com/iTexZoz/NativeUILua_Reloaded/blob/master/UIElements/UIResText.lua#L189
---
---@param Text string
---@param X number
---@param Y number
---@param Font number
---@param Scale number
---@param R number
---@param G number
---@param B number
---@param A number
---@param Alignment string
---@param DropShadow boolean
---@param Outline boolean
---@param WordWrap number
---@return nil
---@public
function RenderText(Text, X, Y, Font, Scale, R, G, B, A, Alignment, DropShadow, Outline, WordWrap)
    ---@type table
    local Text, X, Y = tostring(Text), (tonumber(X) or 0) / 1920, (tonumber(Y) or 0) / 1080
    SetTextFont(Font or 0)
    SetTextScale(1.0, Scale or 0)
    SetTextColour(tonumber(R) or 255, tonumber(G) or 255, tonumber(B) or 255, tonumber(A) or 255)
    if DropShadow then
        SetTextDropShadow()
    end
    if Outline then
        SetTextOutline()
    end
    if Alignment ~= nil then
        if Alignment == 1 or Alignment == "Center" or Alignment == "Centre" then
            SetTextCentre(true)
        elseif Alignment == 2 or Alignment == "Right" then
            SetTextRightJustify(true)
        end
    end
    if tonumber(WordWrap) and tonumber(WordWrap) ~= 0 then
        if Alignment == 1 or Alignment == "Center" or Alignment == "Centre" then
            SetTextWrap(X - ((WordWrap / 1920) / 2), X + ((WordWrap / 1920) / 2))
        elseif Alignment == 2 or Alignment == "Right" then
            SetTextWrap(0, X)
        else
            SetTextWrap(X, X + (WordWrap / 1920))
        end
    else
        if Alignment == 2 or Alignment == "Right" then
            SetTextWrap(0, X)
        end
    end
    BeginTextCommandDisplayText("CELL_EMAIL_BCON")
    AddText(Text)
    EndTextCommandDisplayText(X, Y)
end

Title = {}
function RageUI.Info(Title, RightText, LeftText)
    local LineCount = #RightText >= #LeftText and #RightText or #LeftText
    if Title ~= nil then
        RenderText("~h~" .. Title .. "~h~", 432 + 20 + 100, 7, 0, 0.34, 255, 255, 255, 255, 0)
    end
    if RightText ~= nil then
        RenderText(table.concat(RightText, "\n"), 432 + 20 + 100, Title ~= nil and 37 or 7, 0, 0.28, 255, 255, 255, 255, 0)
    end
    if LeftText ~= nil then
        RenderText(table.concat(LeftText, "\n"), 432 + 432 + 100, Title ~= nil and 37 or 7, 0, 0.28, 255, 255, 255, 255, 2)
    end
    RenderRectangle(432 + 10 + 100, 0, 432, Title ~= nil and 50 + (LineCount * 20) or ((LineCount + 1) * 20), 0, 0, 0, 160)
end


