if (getgenv()["MenuManager"]) then
	return;
end;


-- // ( Variables )
loadstring(game:HttpGet("https://raw.githubusercontent.com/clonefunction/LinoriaModded/refs/heads/main/Variables.luau"))();
local MenuManager = {};


do
	MenuManager["Library"] = nil;
	local BackgroundFrame = nil;
	local BackgroundBlur = nil;



	local function OnBackgroundCreated()
		local ScreenGui = Library:CreateInstance("ScreenGui", {
			["Name"] = "",
            ["IgnoreGuiInset"] = true,
            ["DisplayOrder"] = -768,
            ["Enabled"] = Library:IsVisible(),
            ["Parent"] = Hui
		});

		BackgroundFrame = Library:CreateInstance("Frame", {
			["Name"] = "",
            ["Size"] = udim2_new(1, 0, 1, 0),
            ["Position"] = udim2_new(0, 0, 0, 0),
            ["BorderSizePixel"] = 0,
            ["BackgroundColor3"] = Options["menu_background_color"]["Value"],
            ["BackgroundTransparency"] = Options["menu_background_transparency"]["Value"],
            ["Parent"] = ScreenGui
		});



		local function OnChangedColor(Color)
			BackgroundFrame["BackgroundColor3"] = Color;
		end;


		local function OnChangedTransparency(Value)
			BackgroundFrame["BackgroundTransparency"] = Value;
		end;


		local function OnVisible(Visible)
           	ScreenGui["Enabled"] = Visible;
        end;


		Options["menu_background_color"]:OnChanged(OnChangedColor);
		Options["menu_background_transparency"]:OnChanged(OnChangedTransparency);
		Library:OnEvent("VisibilityChanged"):Connect(OnVisible);
	end;



	function MenuManager:CreateMenuManager(Groupbox)
		if not (self["Library"]) then
			warn("MenuManager.Library needs to be set first.");
			return;
		end;

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



	function MenuManager:CreateBackgroundManager(Groupbox)
		if not (self["Library"]) then
			warn("MenuManager.Library needs to be set first.");
			return;
		end;

		Groupbox:AddLabel("Background color"):AddColorPicker("menu_background_color", { ["Title"] = "Background color", ["Default"] = color3_fromrgb(0, 0, 0) });
		Groupbox:AddSlider("menu_background_transparency", { ["Text"] = "Transparency", ["Min"] = 0, ["Max"] = 1, ["Default"] = 0.85, ["Rounding"] = 2, ["Compact"] = true });
		OnBackgroundCreated();
	end;


	function MenuManager:SetLibrary(Lib)
		self["Library"] = Lib;
	end;
end;


getgenv()["MenuManager"] = MenuManager;
return MenuManager;
