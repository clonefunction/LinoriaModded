Players = cloneref(game:GetService("Players"));
Teams = cloneref(game:GetService("Teams"));
LocalPlayer = Players["LocalPlayer"];
Mouse = LocalPlayer:GetMouse();

Workspace = cloneref(game:GetService("Workspace"));
Camera = Workspace["CurrentCamera"];

RunService = cloneref(game:GetService("RunService"));
RenderStepped = RunService["RenderStepped"];

InputService = cloneref(game:GetService("UserInputService"));
TextService = cloneref(game:GetService("TextService"));
TweenService = cloneref(game:GetService("TweenService"));
SoundService = cloneref(game:GetService("SoundService"));
Lighting = cloneref(game:GetService("Lighting"));
Hui = cloneref(gethui());


math_floor = clonefunction(math["floor"]);
math_clamp = clonefunction(math["clamp"]);
math_max = clonefunction(math["max"]);
math_min = clonefunction(math["min"]);
math_ceil = clonefunction(math["ceil"]);
math_round = clonefunction(math["round"]);

task_wait = clonefunction(task["wait"]);
task_spawn = clonefunction(task["spawn"]);
task_delay = clonefunction(task["delay"]);

table_sort = clonefunction(table["sort"]);
table_pack = clonefunction(table["pack"]);
table_unpack = clonefunction(table["unpack"]);
table_insert = clonefunction(table["insert"]);
table_clear = clonefunction(table["clear"]);
table_remove = clonefunction(table["remove"]);
table_concat = clonefunction(table["concat"]);
table_find = clonefunction(table["find"]);

color3_new = clonefunction(Color3["new"]);
color3_fromrgb = clonefunction(Color3["fromRGB"]);
color_sequence_new = clonefunction(ColorSequence["new"]);
color_sequence_keypoint_new = clonefunction(ColorSequenceKeypoint["new"]);
color3_fromhex = clonefunction(Color3["fromHex"]);

vector2_new = clonefunction(Vector2["new"]);
vector3_new = clonefunction(Vector3["new"]);
vector3_zero = Vector3["zero"];

udim_new = clonefunction(UDim["new"]);
udim2_new = clonefunction(UDim2["new"]);
udim2_from_offset = clonefunction(UDim2["fromOffset"]);

instance_new = clonefunction(Instance["new"]);

string_char = clonefunction(string["char"]);
string_find = clonefunction(string["find"]);
