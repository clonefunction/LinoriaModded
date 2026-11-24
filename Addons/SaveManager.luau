if (getgenv()["SaveManager"]) then
	return;
end;



-- // ( Variables )
loadstring(game:HttpGet("https://raw.githubusercontent.com/clonefunction/LinoriaModded/refs/heads/main/Variables.luau"))();
local SaveManager = {};


do
	SaveManager["Folder"] = "LinoriaModded/Addons";
	SaveManager["Ignore"] = {};
		SaveManager["Parser"] = {
		["Toggle"] = {
			["Save"] = function(Idx, Object)
				return {["Type"] = "Toggle", ["Idx"] = Idx, ["Value"] = Object["Value"]};
			end,
			["Load"] = function(Idx, Object)
				if not (Toggles[Idx]) then
					return;
				end;

				Toggles[Idx]:SetValue(Object["Value"]);
			end;
		},
		["Slider"] = {
			["Save"] = function(Idx, Object)
				return {["Type"] = "Slider", ["Idx"] = Idx, ["Value"] = tostring(Object["Value"])};
			end,
			["Load"] = function(Idx, Object)
				if not Options[Idx] then
					return;
				end;

				Options[Idx]:SetValue(Object["Value"])
			end;
		},
		["Dropdown"] = {
			["Save"] = function(Idx, Object)
				return {["Type"] = "Dropdown", ["Idx"] = Idx, ["Value"] = Object["Value"], ["Mutli"] = Object["Multi"]};
			end,
			["Load"] = function(Idx, Object)
				if not (Options[Idx]) then
					return;
				end;

				Options[Idx]:SetValue(Object["Value"]);
			end;
		},
		["ColorPicker"] = {
			["Save"] = function(Idx, Object)
				return {["Type"] = "ColorPicker", ["Idx"] = Idx, ["Value"] = Object["Value"]:ToHex(), ["Transparency"] = Object["Transparency"]};
			end,
			["Load"] = function(Idx, Object)
				if not (Options[Idx]) then
					return;
				end;

				Options[Idx]:SetValueRGB(color3_fromhex(Object["Value"]), (Options[Idx]["HasTransparency"] and Object["Transparency"]) or (0));
			end;
		},
		["KeyPicker"] = {
			["Save"] = function(Idx, Object)
				return {["Type"] = 'KeyPicker', ["Idx"] = Idx, ["Mode"] = Object["Mode"], ["Key"] = Object["Value"]};
			end,
			["Load"] = function(Idx, Object)
				if not (Options[Idx]) then
					return;
				end;

				Options[Idx]:SetValue({Object["Key"], Object["Mode"]});
			end;
		},
		["Input"] = {
			["Save"] = function(Idx, Object)
				return {["Type"] = "Input", ["Idx"] = Idx, ["Text"] = Object["Value"]};
			end,
			["Load"] = function(Idx, Object)
				if (Options[Idx] and typeof(Object["Text"]) == "string") then
					Options[Idx]:SetValue(Object["Text"]);
				end;
			end;
		};
	};



	-- // ( Set Ignore Indexes )
	function SaveManager:SetIgnoreIndexes(List)
		for _, Key in next, List do
			self["Ignore"][Key] = true;
		end;
	end;



	-- // ( Set Folder )
	function SaveManager:SetFolder(Folder)
		self["Folder"] = Folder;
		self:BuildFolderTree();
	end;



	-- // ( Save )
	function SaveManager:Save(Name)
		if not (Name) then
			return false, "No config file is selected.";
		end;

		local Path = self["Folder"] .. "/Settings/" .. Name .. ".json";
		local Data = {
			Objects = {}
		};

		for Idx, Toggle in next, Toggles do
			if (self["Ignore"][Idx]) then
				continue;
			end;

			table_insert(Data["Objects"], self["Parser"][Toggle["Type"]]["Save"](Idx, Toggle));
		end;

		for Idx, Option in next, Options do
			if not (self["Parser"][Option["Type"]]) then
				continue;
			end;

			if (self["Ignore"][Idx]) then
				continue;
			end;

			table_insert(Data["Objects"], self["Parser"][Option["Type"]]["Save"](Idx, Option))
		end;

		local Success, Encoded = pcall(HttpService["JSONEncode"], HttpService, Data)
		if not (Success) then
			return false, "Failed to encode data.";
		end;

		writefile(Path, Encoded)
		return true;
	end;



	-- // ( Load )
	function SaveManager:Load(Name)
		if not (Name) then
			return false, "No config file is selected.";
		end;
		
		local File = self["Folder"] .. "/Settings/" .. Name .. ".json";
		if not (isfile(File)) then
			return false, "Invalid file.";
		end;

		local Success, Decoded = pcall(HttpService["JSONDecode"], HttpService, readfile(File))
		if not (Success) then
			return false, "Decode error.";
		end;

		for _, Option in next, Decoded["Objects"] do
			if (self["Parser"][Option["Type"]]) then
				task_spawn(function()
					self["Parser"][Option["Type"]]["Load"](Option["Idx"], Option);
				end);
			end;
		end;

		return true;
	end;



	-- // ( Ignore Theme Settings )
	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor",
			"ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName",
		});
	end;



	-- // ( Build Folder Tree )
	function SaveManager:BuildFolderTree()
		local Paths = {
			self["Folder"],
			self["Folder"] .. "/Themes",
			self["Folder"] .. "/Settings"
		};

		for Idx = 1, rawlen(Paths) do
			local Str = Paths[Idx]
			if not (isfolder(Str)) then
				makefolder(Str);
			end;
		end;
	end;



	-- // ( Refresh Config List )
	function SaveManager:RefreshConfigList()
		local List = listfiles(self.Folder .. "/Settings");
		local Out = {};

		for Idx = 1, rawlen(List) do
			local File = List[Idx];
			if (File:sub(-5) == ".json") then
				local Position = File:find('.json', 1, true);
				local Start = Position;
				local Character = File:sub(Position, Position);

				while (Character ~= "/" and Character ~= "\\" and Character ~= "") do
					Position = Position - 1;
					Character = File:sub(Position, Position);
				end

				if (Character == "/") or (Character == "\\") then
					table_insert(Out, File:sub(Position + 1, Start - 1));
				end;
			end;
		end;
		
		return Out;
	end;



	-- // ( Set Library )
	function SaveManager:SetLibrary(Lib)
		self["Library"] = Lib;
	end;



	-- // ( Load Autoload Config )
	function SaveManager:LoadAutoloadConfig()
		if not (isfile(self["Folder"] .. "/Settings/autoload.txt")) then
			return;
		end;

		local Name = readfile(self["Folder"] .. "/Settings/autoload.txt")
		local Success, Err = self:Load(Name)
		if not (Success) then
			return self["Library"]:Notify('Failed to load autoload config: ' .. Err)
		end
		
		self["Library"]:Notify(string_format("Auto loaded config %q", Name))
	end



	-- // ( Delete config )
	function SaveManager:DeleteConfig(Name)
		if not (Name) then
			return false, "No config file is selected.";
		end;
		
		local File = self["Folder"] .. "/Settings/" .. Name .. ".json";
		if not (isfile(File)) then
			return false, "Invalid file.";
		end;

		delfile(File);
		return true;
	end;



	-- // ( Build Config Section )
	function SaveManager:BuildConfigSection(tab)
		if not (self["Library"]) then
			warn("Must set SaveManager.Library");
			return;
		end;

		local groupbox = tab:AddRightGroupbox("Configuration");
		groupbox:AddInput("SaveManager_ConfigName", { ["Text"] = "Config name" });
		groupbox:AddDropdown("SaveManager_ConfigList", { ["Text"] = 'Config list', ["Values"] = self:RefreshConfigList(), ["AllowNull"] = true });
		groupbox:AddDivider();
		groupbox:AddButton({ ["Text"] = "Create config", 
			["Func"] = function()
				local Name = Options["SaveManager_ConfigName"]["Value"];
				if (Name:gsub(" ", "") == "") then
					return self["Library"]:Notify("Invalid config name (empty).", 2);
				end;

				local Success, Err = self:Save(Name);
				if not (Success) then
					return self.Library:Notify("Failed to save config: " .. Err);
				end;


				self.Library:Notify(string_format('Created config %q', Name));
				Options["SaveManager_ConfigList"]:SetValues(self:RefreshConfigList());
				Options["SaveManager_ConfigList"]:SetValue(nil);
			end;
		}):AddButton({ ["Text"] = "Load config", 
			["Func"] = function()
				local Name = Options["SaveManager_ConfigList"]["Value"];
				local Success, Err = self:Load(Name);
				if not (Success) then
					return self["Library"]:Notify("Failed to load config: " .. Err);
				end;

				self["Library"]:Notify(string_format("Loaded config %q", Name))
			end;
		});


		groupbox:AddButton({ ["Text"] = "Overwrite config", ["DoubleClick"] = true, 
			["Func"] = function()
				local Name = Options["SaveManager_ConfigList"]["Value"];
				local Success, Err = self:Save(Name);
				if not (Success) then
					return self["Library"]:Notify("Failed to overwrite config: " .. Err);
				end;

				self["Library"]:Notify(string_format("Overwrote config %q", Name));
			end;
		}):AddButton({ ["Text"] = "Delete config", ["DoubleClick"] = true,
			["Func"] = function()
				local Name = Options["SaveManager_ConfigList"]["Value"];
				local Success, Err = self:DeleteConfig(Name);

				if not (Success) then
					return self["Library"]:Notify("Failed to delete config: " .. Err);
				end;


				self["Library"]:Notify(`Deleted config: {Name}`);
				Options["SaveManager_ConfigList"]:SetValues(self:RefreshConfigList());
				Options["SaveManager_ConfigList"]:SetValue(nil);
			end;
		});


		groupbox:AddDivider();
		groupbox:AddButton({ ["Text"] = "Refresh list", 
			["Func"] = function()
				Options["SaveManager_ConfigList"]:SetValues(self:RefreshConfigList());
				Options["SaveManager_ConfigList"]:SetValue(nil);
			end;
		});

		groupbox:AddButton({ ["Text"] = "Set autoload", 
			["Func"] = function()
				local Name = Options["SaveManager_ConfigList"]["Value"];
				if not (Name) then
					return;
				end;

				writefile(self["Folder"] .. "/Settings/autoload.txt", Name);

				SaveManager["AutoloadLabel"]:SetText("Current autoload config: " .. Name);
				self["Library"]:Notify(string_format("Set %q to auto load", Name));
			end;
		}):AddButton({ ["Text"] = "Remove autoload", ["DoubleClick"] = true, 
			["Func"] = function()
				if (isfile(self["Folder"] .. '/Settings/autoload.txt')) then
					delfile(self["Folder"] .. '/Settings/autoload.txt');
				end;

				SaveManager["AutoloadLabel"]:SetText("Current autoload config: none")
				self["Library"]:Notify("Removed autoload config.");
			end;
		});

		SaveManager["AutoloadLabel"] = groupbox:AddLabel("Current autoload config: none", true)

		if (isfile(self["Folder"] .. "/Settings/autoload.txt")) then
			local Name = readfile(self["Folder"] .. "/Settings/autoload.txt");
			SaveManager["AutoloadLabel"]:SetText('Current autoload config: ' .. Name);
		end;

		SaveManager:SetIgnoreIndexes({"SaveManager_ConfigList", "SaveManager_ConfigName"});
	end;

	SaveManager:BuildFolderTree();
end;


getgenv()["SaveManager"] = SaveManager;
return SaveManager;
