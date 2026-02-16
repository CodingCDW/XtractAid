[Setup]
AppId={{13E7C8DB-51C2-4C65-A8E5-A39E20A46331}
AppName=XtractAid
AppVersion=0.1.0
AppPublisher=XtractAid
DefaultDirName={autopf}\XtractAid
DefaultGroupName=XtractAid
OutputDir=dist
OutputBaseFilename=XtractAid-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\XtractAid"; Filename: "{app}\xtractaid.exe"
Name: "{autodesktop}\XtractAid"; Filename: "{app}\xtractaid.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop icon"; GroupDescription: "Additional icons:"
