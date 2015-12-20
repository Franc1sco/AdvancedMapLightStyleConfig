#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define VERSION "1.0"

new String:skyname[32];
new String:lightlevel[2];

new String:hora[128];
new hora_int;

new bool:por_defecto;
new bool:custom;

public Plugin:myinfo =
{
    name = "SM advanced lightstyle",
    author = "Franc1sco steam: franug",
    description = "Set lightstyle with more options",
    version = VERSION,
    url = "http://servers-cfg.foroactivo.com/"
};

public OnPluginStart()
{
	CreateConVar("sm_advlightstyle_version", VERSION, "Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
}


public LoadKV()
{
	new Handle:kv = CreateKeyValues("advLigheStyle");
	if (!FileToKeyValues(kv,"cfg/sourcemod/advanced_lightstyle.txt"))
	{
		SetFailState("File cfg/sourcemod/advanced_lightstyle.txt not found");
	}

	new repeticion = 0;
	while(!KvJumpToKey(kv, hora))
	{
		hora_int = StringToInt(hora);
		--hora_int;
		if(hora_int < 0)
			hora_int = 23;

		IntToString(hora_int, hora, sizeof(hora));
		++repeticion;
		if(repeticion > 26)
			SetFailState("Failed to get hour");
	}

        decl String:defecto[24];
        KvGetString(kv, "default", defecto, sizeof(defecto), "no");

	if (StrContains(defecto, "no") == -1)
	{
		por_defecto = true;
	}
	else
	{
		por_defecto = false;
		KvGetString(kv,"lightlevel",lightlevel, sizeof(lightlevel));
		KvGetString(kv,"skyname",skyname, sizeof(skyname));
	}

        decl String:custom_skybox[24];
        KvGetString(kv, "custom", custom_skybox, sizeof(custom_skybox), "no");

	if (StrContains(custom_skybox, "no") == -1)
		custom = true;
	else
		custom = false;


	KvGoBack(kv);
	
	CloseHandle(kv);	
}


public OnMapStart()
{
        FormatTime(hora, sizeof(hora), "%H", GetTime());
	LoadKV();

	if(por_defecto)
		return;

	if(custom)
	{
		decl String:skyname_download1[128];
		Format(skyname_download1, sizeof(skyname_download1), "materials/skybox/%s.vtf",skyname);
		AddFileToDownloadsTable(skyname_download1);

		decl String:skyname_download2[128];
		Format(skyname_download2, sizeof(skyname_download2), "materials/skybox/%s.vmt",skyname);
		AddFileToDownloadsTable(skyname_download2);
	}

	ServerCommand("sv_skyname %s",skyname);
	
	SetLightStyle(0,lightlevel);

}
