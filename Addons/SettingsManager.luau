if (getgenv()["SettingsManager"]) then
	return;
end;


-- // ( Variables )
loadstring(game:HttpGet("https://raw.githubusercontent.com/clonefunction/LinoriaModded/refs/heads/main/Variables.luau"))();
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/clonefunction/LinoriaModded/refs/heads/main/Addons/ThemeManager.luau"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/clonefunction/LinoriaModded/refs/heads/main/Addons/SaveManager.luau"))()
local SettingsManager = {};



do
	SettingsManager["Library"] = nil;
	SettingsManager["Folder"] = nil;
	local NotificationCount = 1;



	-- // ( Apply Menu )
	function SettingsManager:ApplyMenu(Groupbox)
		Groupbox:AddLabel("Menu keybind"):AddKeyPicker("menu_keybind", { ["Default"] = "RightShift", ["Text"] = "Menu keybind", ["NoUI"] = true });
        Groupbox:AddToggle("keybind_list_enabled", { ["Text"] = "Keybind list enabled", ["Default"] = true,
            ["Callback"] = function(Value)
                Library["KeypickerListStyle"]["Visible"] = Value;
            end;
        });
        Groupbox:AddDropdown("keybind_list_mode", { ["Text"] = "Keybind list mode", ["Values"] = {"Active","All","Toggled"}, ["Default"] = 3,
            ["Callback"] = function(Value)
                Library["KeypickerListStyle"]["Mode"] = Value;
            end;
        });
        Groupbox:AddSlider("keybind_list_transparency", { ["Text"] = "Keybind list transparency", ["Default"] = 100, ["Min"] = 1, ["Max"] = 100, ["Rounding"] = 0, ["Suffix"] = '%', ["Compact"] = true ,
            ["Callback"] = function(Value)
                Library:SetKeybindTransparency(1 - (Value / 100));
            end;
        });


		Library["ToggleKeybind"] = Options["menu_keybind"];
	end;



	-- // ( Apply Notification )
	function SettingsManager:ApplyNotification(Groupbox)
		Groupbox:AddToggle("notification_forcecolor_enabled", { ["Text"] = "Force color", ["Default"] = false });
		Groupbox:AddLabel("Colors"):AddColorPicker("notification_main_color", { ["Title"] = "Notification main color", ["Default"] = Library["MainColor"]
		}):AddColorPicker("notification_accent_color", { ["Title"] = "Notification accent color", ["Default"] = Library["AccentColor"]
		}):AddColorPicker("notification_outline_color", { ["Title"] = "Notification outline color", ["Default"] = Library["OutlineColor"]
		}):AddColorPicker("notification_font_color", { ["Title"] = "Notification font color", ["Default"] = Library["FontColor"] });
		Groupbox:AddDropdown("notification_bar_side", { ["Text"] = "Barside", ["Values"] = {"Left", "Right", "Top", "Bottom"}, ["Default"] = 3, ["Multi"] = false,
			["Callback"] = function(Value)
				Library["NotificationStyle"]["BarSide"] = Value;
			end;
		});

		Groupbox:AddSlider("notification_position_x", { ["Text"] = "X", ["Min"] = 0, ["Max"] = 1, ["Default"] = 0.5, ["Rounding"] = 2, ["Compact"] = true,
		}):AddSlider("notification_position_y", { ["Text"] = "Y", ["Min"] = 0, ["Max"] = 1, ["Default"] = 0.65, ["Rounding"] = 2, ["Compact"] = true });
		Groupbox:AddSlider("notification_transparency", { ["Text"] = "Transparency", ["Min"] = 20, ["Max"] = 100, ["Default"] = 100, ["Rounding"] = 0, ["Suffix"] = "%", ["Compact"] = true,
			["Callback"] = function(Value)
				Library["NotificationStyle"]["Transparency"] = (100 - Value) / 100;
			end;
		});

		Groupbox:AddButton({ ["Text"] = "Send notification",
			["Func"] = function()
				Library:Notify(tostring(NotificationCount), 5)
				NotificationCount *= 2;
			end;
		});


		local function OnChangedPosition()
			local XValue = Options["notification_position_x"]["Value"];
			local YValue = Options["notification_position_y"]["Value"];
			Library:SetNotificationPosition(XValue, YValue);
		end;


		local function OnChanged(Value)
			if (Value) then
				Library["NotificationStyle"]["OverrideColor"] = function()
					local Key = {
						["MainColor"] = Options["notification_main_color"]["Value"],
						["AccentColor"] = Options["notification_accent_color"]["Value"],
						["OutlineColor"] = Options["notification_outline_color"]["Value"],
						["FontColor"] = Options["notification_font_color"]["Value"]
					};

					return Key;
				end;
			else
				Library["NotificationStyle"]["OverrideColor"] = nil;
			end;
		end;


		Toggles["notification_forcecolor_enabled"]:OnChanged(OnChanged);
		Options["notification_position_x"]:OnChanged(OnChangedPosition);
		Options["notification_position_y"]:OnChanged(OnChangedPosition);
	end;



	-- // ( Apply Background )
	function SettingsManager:ApplyBackground(Groupbox)
		Groupbox:AddLabel("Background color"):AddColorPicker("menu_background_color", { ["Title"] = "Background color", ["Default"] = color3_fromrgb(0, 0, 0) });
		Groupbox:AddSlider("menu_background_transparency", { ["Text"] = "Transparency", ["Min"] = 0, ["Max"] = 1, ["Default"] = 0.75, ["Rounding"] = 2, ["Compact"] = true });
		Groupbox:AddSlider("menu_background_blur", { ["Text"] = "Background blur", ["Min"] = 0, ["Max"] = 10, ["Default"] = 0, ["Rounding"] = 1, ["Suffix"] = "x", ["Compact"] = true });
	

		local ScreenGui = Library:CreateInstance("ScreenGui", {
			["Name"] = "",
            ["IgnoreGuiInset"] = true,
            ["DisplayOrder"] = -768,
            ["Enabled"] = Library:IsVisible(),
            ["Parent"] = Hui
		});

		local BackgroundFrame = Library:CreateInstance("Frame", {
			["Name"] = "",
            ["Size"] = udim2_new(1, 0, 1, 0),
            ["Position"] = udim2_new(0, 0, 0, 0),
            ["BorderSizePixel"] = 0,
            ["BackgroundColor3"] = Options["menu_background_color"]["Value"],
            ["BackgroundTransparency"] = Options["menu_background_transparency"]["Value"],
            ["Parent"] = ScreenGui
		});


		local BackgroundBlur = Library:CreateInstance("BlurEffect", {
            ["Name"] = "",
            ["Size"] = 0,
            ["Enabled"] = Library:IsVisible(),
            ["Parent"] = Lighting
        });


		local function OnChangedColor(Color)
			BackgroundFrame["BackgroundColor3"] = Color;
		end;


		local function OnChangedTransparency(Value)
			BackgroundFrame["BackgroundTransparency"] = Value;
		end;


		local function OnChangedBlur(Value)
            if (Value == 0) then
                BackgroundBlur["Enabled"] = false;
                return;
            end;

            BackgroundBlur["Enabled"] = Library:IsVisible();
            BackgroundBlur["Size"] = Value * 2;
        end;


		local function OnVisible(Visible)
           	ScreenGui["Enabled"] = Visible;
			BackgroundBlur["Enabled"] = Visible;
        end;


		Options["menu_background_color"]:OnChanged(OnChangedColor);
		Options["menu_background_transparency"]:OnChanged(OnChangedTransparency);
		Options["menu_background_blur"]:OnChanged(OnChangedBlur);
		Library:OnEvent("VisibilityChanged"):Connect(OnVisible);
	end;
	


	-- // ( Set Library )
	function SettingsManager:SetLibrary(Lib)
		self["Library"] = Lib;
	end;


	-- // ( Set Folder )
	function SettingsManager:SetFolder(Folder)
		self["Folder"] = Folder;
	end;



	-- // ( Apply to Tab )
	function SettingsManager:ApplyToTab(Tab)
		if not (self["Library"]) then
			warn("SettingsManager.Library needs to be set first.");
			return;
		end;


		local MenuTabbox = Tab:AddLeftTabbox();
		local Menu = MenuTabbox:AddTab("Menu");
		local Notifications = MenuTabbox:AddTab("Notifications");
		local Background = Tab:AddRightGroupbox("Background");
		if (self["Folder"] == nil) then
			warn("SettingsManager.Folder needs to be set first.");
			return;
		end;

		self:ApplyMenu(Menu);
		self:ApplyNotification(Notifications);
		self:ApplyBackground(Background);

		ThemeManager:SetLibrary(self["Library"]);
		SaveManager:SetLibrary(self["Library"]);
		SaveManager:IgnoreThemeSettings();
		ThemeManager:SetFolder(self["Folder"]);
		SaveManager:SetFolder(self["Folder"]);
		SaveManager:BuildConfigSection(Tab);
		ThemeManager:ApplyToTab(Tab);
		--SaveManager:LoadAutoloadConfig()
	end;
end;


getgenv()["SettingsManager"] = SettingsManager;
return SettingsManager;
