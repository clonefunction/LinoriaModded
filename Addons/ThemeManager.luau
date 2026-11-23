if (getgenv()["ThemeManager"]) then
	return;
end;



-- // ( Variables )
loadstring(game:HttpGet("https://raw.githubusercontent.com/clonefunction/LinoriaModded/refs/heads/main/Variables.luau"))();
local ThemeManager = {};

do
	ThemeManager["Folder"] = "LinoriaModded/Addons";
	ThemeManager["Library"] = nil;
	ThemeManager["BuiltInThemes"] = {
		["Default"] = {1, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"181818","AccentColor":"c8c8c8","BackgroundColor":"141414","OutlineColor":"1f1f1f"}')},
		["Blue"] = {2, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"181818","AccentColor":"4777b6","BackgroundColor":"141414","OutlineColor":"1f1f1f"}')},
		["Sakura"] = {3, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"181818","AccentColor":"f4c2d0","BackgroundColor":"141414","OutlineColor":"1f1f1f"}')},
		["Primordial"] = {4, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191919","AccentColor":"d7a5af","BackgroundColor":"1e1e1e","OutlineColor":"282828"}')},
		["Neverlose"] = {5, HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"0a0f14","AccentColor":"00a0f0","BackgroundColor":"0a0f14","OutlineColor":"191919"}')},
	};



	-- // ( Apply Theme )
	function ThemeManager:ApplyTheme(theme)
		local CustomTheme = self:GetCustomTheme(theme)
		local Theme = (CustomTheme) or (self["BuiltInThemes"][theme]);
		if not (Theme) then
			return;
		end;

		local Scheme = Theme[2]
		for Index, col in next, CustomTheme or Scheme do
			self["Library"][Index] = color3_fromhex(col);
			if not (Options[Index]) then
				continue;
			end;

			Options[Index]:SetValueRGB(color3_fromhex(col));
		end;

		self:ThemeUpdate();
	end;



	-- // ( Theme Update )
	function ThemeManager:ThemeUpdate()
		local Index = {"FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor"};
		for _, Option in next, Index do
			if (Options and Options[Option]) then
				self["Library"][Option] = Options[Option]["Value"];
			end;
		end;

		self["Library"]["AccentColorDark"] = self["Library"]:GetDarkerColor(self["Library"]["AccentColor"]);
		self["Library"]:UpdateColorsUsingRegistry();
	end;



	-- // ( Load Default )
	function ThemeManager:LoadDefault()		
		local Theme = "Default";
		local Content = (isfile(self["Folder"] .. "/themes/default.txt") and readfile(self["Folder"] .. "/themes/default.txt"));
		local Default = true;

		if (Content) then
			if (self["BuiltInThemes"][Content]) then
				Theme = Content;
			elseif self:GetCustomTheme(Content) then
				Theme = Content;
				Default = false;
			end;
		elseif self["BuiltInThemes"][self["DefaultTheme"]] then
		 	Theme = self["DefaultTheme"];
		end;

		if (Default) then
			Options["ThemeManager_ThemeList"]:SetValue(Theme);
		else
			self:ApplyTheme(Theme);
		end;
	end;



	-- // ( Save Default )
	function ThemeManager:SaveDefault(theme)
		writefile(self["Folder"] .. "/themes/default.txt", theme);
	end;



	-- // ( Create Theme Manager )
	function ThemeManager:CreateThemeManager(groupbox)
		groupbox:AddLabel("Main color"):AddColorPicker("MainColor", { ["Title"] = "Main color", ["Default"] = self["Library"]["MainColor"] });
		groupbox:AddLabel("Accent color"):AddColorPicker("AccentColor", { ["Title"] = "Accent color", ["Default"] = self["Library"]["AccentColor"] });
		groupbox:AddLabel("Background color"):AddColorPicker("BackgroundColor", { ["Title"] = "Background color", ["Default"] = self["Library"]["BackgroundColor"] });
		groupbox:AddLabel("Outline color"):AddColorPicker("OutlineColor", { ["Title"] = "Outline color", ["Default"] = self["Library"]["OutlineColor"] });
		groupbox:AddLabel("Font color"):AddColorPicker("FontColor", { ["Title"] = "Font color", ["Default"] = self["Library"]["FontColor"] });

		local DefaultThemes = {};
		for Name, Theme in next, self["BuiltInThemes"] do
			table_insert(DefaultThemes, Name);
		end;

		table_sort(DefaultThemes, function(a, b)
			return self["BuiltInThemes"][a][1] < self["BuiltInThemes"][b][1];
		end);

		groupbox:AddDivider();
		groupbox:AddDropdown("ThemeManager_ThemeList", { ["Text"] = "Theme list", ["Values"] = DefaultThemes, ["Default"] = 1,
			["Callback"] = function(Value)
				self:ApplyTheme(Value);
			end;
		});

		groupbox:AddButton({ ["Text"] = "Set as default",
			["Func"] = function()
				local Value = Options["ThemeManager_ThemeList"]["Value"];
				self:SaveDefault(Value);
				self["Library"]:Notify(string_format("Set default theme to %q", Value));
			end;
		});

		groupbox:AddDivider();
		groupbox:AddInput("ThemeManager_CustomThemeName", { ["Text"] = "Custom theme name" });
		groupbox:AddDropdown("ThemeManager_CustomThemeList", { ["Text"] = "Custom themes", ["Values"] = self:ReloadCustomThemes(), ["AllowNull"] = true, ["Default"] = 1 });
		groupbox:AddDivider();
		
		groupbox:AddButton({ ["Text"] = "Save theme",
			["Func"] = function() 
				self:SaveCustomTheme(Options["ThemeManager_CustomThemeName"]["Value"]);

				Options["ThemeManager_CustomThemeList"]:SetValues(self:ReloadCustomThemes());
				Options["ThemeManager_CustomThemeList"]:SetValue(nil);
			end;
		}):AddButton({ ["Text"] = "Load theme",
			["Func"] = function()
				self:ApplyTheme(Options["ThemeManager_CustomThemeList"]["Value"]);
			end;
		});

		groupbox:AddButton({ ["Text"] = "Refresh list", 
			["Func"] = function()
				Options["ThemeManager_CustomThemeList"]:SetValues(self:ReloadCustomThemes());
				Options["ThemeManager_CustomThemeList"]:SetValue(nil);
			end;
		});

		groupbox:AddButton({ ["Text"] = "Set as default", 
			["Func"] = function()
				local Value = Options["ThemeManager_CustomThemeList"]["Value"]
				if (Value == nil) or (Value == "") then
					return;
				end;

				self:SaveDefault(Value);
				self.Library:Notify(string_format("Set default theme to %q", Value));
			end;
		})

		ThemeManager:LoadDefault();

		local function UpdateTheme()
			self:ThemeUpdate();
		end;


		Options["MainColor"]:OnChanged(UpdateTheme);
		Options["AccentColor"]:OnChanged(UpdateTheme);
		Options["BackgroundColor"]:OnChanged(UpdateTheme);
		Options["OutlineColor"]:OnChanged(UpdateTheme);
		Options["FontColor"]:OnChanged(UpdateTheme);
	end;



	-- // ( Get Custom Theme )
	function ThemeManager:GetCustomTheme(File)
		local Path = self["Folder"] .. "/themes/" .. File;
		if not (isfile(Path)) then
			return nil;
		end;

		local Data = readfile(Path)
		local Success, Decoded = pcall(HttpService["JSONDecode"], HttpService, Data)
		if not (Success) then
			return nil;
		end;

		return Decoded;
	end;


	
	-- // ( Save Custom Theme )
	function ThemeManager:SaveCustomTheme(File)
		if (File:gsub(" ", "") == "") then
			return self["Library"]:Notify("Invalid file name for theme (empty).", 3);
		end;

		local Theme = {};
		local Index = {"FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor"};
		for _, Option in next, Index do
			Theme[Option] = Options[Option]["Value"]:ToHex()
		end

		writefile(self["Folder"] .. "/themes/" .. File .. ".json", HttpService:JSONEncode(theme));
	end;



	-- // ( Reload Custom Themes )
	function ThemeManager:ReloadCustomThemes()
		local List = listfiles(self["Folder"] .. "/themes")
		local Out = {};

		for Idx = 1, rawlen(List) do
			local File = List[Idx];
			if (File:sub(-5) == ".json") then
				local Position = File:find(".json", 1, true);
				local Character = File:sub(Position, Position);
				while (Character ~= "/" and Character ~= "\\" and Character ~= "") do
					Position = Position - 1;
					Character = File:sub(Position, Position);
				end;

				if (Character == "/") or (Character == "\\") then
					table_insert(Out, File:sub(Position + 1));
				end;
			end;
		end;

		return Out;
	end;


	-- // ( Set Library )
	function ThemeManager:SetLibrary(Lib)
		self["Library"] = Lib;
	end;



	-- // ( Build Folder Tree )
	function ThemeManager:BuildFolderTree()
		local Paths = {};
		local parts = self.Folder:split("/");
		for Idx = 1, rawlen(parts) do
			Paths[rawlen(Paths) + 1] = table_concat(parts, "/", 1, Idx);
		end;

		table_insert(Paths, self["Folder"] .. "/Themes");
		table_insert(Paths, self["Folder"] .. "/Settings");

		for Idx = 1, rawlen(Paths) do
			local Str = Paths[Idx]
			if not (isfolder(Str)) then
				makefolder(Str);
			end;
		end;
	end;



	-- // ( Set Folder )
	function ThemeManager:SetFolder(Folder)
		self["Folder"] = Folder;
		self:BuildFolderTree();
	end;



	-- // ( Create GroupBox )
	function ThemeManager:CreateGroupBox(Tab)
		if not (self["Library"]) then
			warn("Must set ThemeManager.Library first.");
			return;
		end;

		return Tab:AddLeftGroupbox("Themes");
	end;



	-- // ( Apply to Tab )
	function ThemeManager:ApplyToTab(Tab)
		if not (self["Library"]) then
			warn("Must set ThemeManager.Library first.");
			return;
		end;

		local Groupbox = self:CreateGroupBox(Tab);
		self:CreateThemeManager(Groupbox);
	end;



	-- // ( Apply to Groupbox )
	function ThemeManager:ApplyToGroupbox(Groupbox)
		if not (self["Library"]) then
			warn("Must set ThemeManager.Library first.");
			return;
		end;

		self:CreateThemeManager(Groupbox);
	end;

	ThemeManager:BuildFolderTree();
end;


getgenv()["ThemeManager"] = ThemeManager;
return ThemeManager;
