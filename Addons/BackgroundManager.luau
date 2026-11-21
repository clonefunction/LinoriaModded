if (getgenv()["BackgroundManager"]) then
	return;
end;



-- // ( Variables )
loadstring(game:HttpGet("https://raw.githubusercontent.com/clonefunction/LinoriaModded/refs/heads/main/Variables.luau"))();
local BackgroundManager = {};


do
	BackgroundManager["Library"] = nil;
	local BackgroundFrame = nil;
	local BackgroundBlur = nil;



	local function OnBackgroundManagerCreated()
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




	function BackgroundManager:CreateBackgroundManager(Groupbox)
		if not (self["Library"]) then
			warn("BackgroundManager.Library needs to be set first.");
			return;
		end;

		Groupbox:AddLabel("Background color"):AddColorPicker("menu_background_color", { ["Title"] = "Background color", ["Default"] = color3_fromrgb(0, 0, 0) });
		Groupbox:AddSlider("menu_background_transparency", { ["Text"] = "Transparency", ["Min"] = 0, ["Max"] = 1, ["Default"] = 0.85, ["Rounding"] = 2, ["Compact"] = true });
		OnBackgroundManagerCreated();
	end;


	function BackgroundManager:SetLibrary(Lib)
		self["Library"] = Lib;
	end;
end;


getgenv()["BackgroundManager"] = BackgroundManager;
return BackgroundManager;
