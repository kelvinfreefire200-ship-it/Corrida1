// ============================================================
//  SAMP UNDERGROUND - estilo Need for Speed Underground
//  Telas: Titulo -> Perfil (novo/carregar) -> Menu Principal
//  Menu Principal: Go Underground, Quick Race, Statistics,
//                  Customize Ride, Options, Play Online (modo livre)
//  Salve em gamemodes/nfs.pwn e crie scriptfiles/users/
//
//  Como usar o menu: toque num item para SELECIONAR, toque de novo
//  (ou no botao CONFIRMAR) para entrar. VOLTAR volta uma tela.
//  HUD: velocimetro, marcha, giro, nitro, tempo. Drag de 402 m com
//  contagem e tempo interpolado. Nitro: instale em Customize Ride.
//  100% botoes, 0% comandos. Na corrida e no modo livre aparece o
//  botao MENU (canto superior direito) para voltar a garagem.
//  Admin (RCON) tem tambem o botao POS para ver coordenadas.
// ============================================================
#include <a_samp>

// ---------- Dialogs ----------
#define DLG_LOGIN     1
#define DLG_REGISTER  2
#define DLG_COLOR     5
#define DLG_RIMS      6
#define DLG_NEON      7
#define DLG_PAINTJOB  8
#define DLG_STATS     9

// ---------- Geral ----------
#define CAR_MODEL     562      // Elegy
#define LOBBY_VW      1000
#define MAX_RACES     3
#define MAX_CPS       8

// ---------- UI ----------
#define FONT_TITLE    2        // troque para testar outras fontes (0-3)
#define FONT_ITEM     1
#define CURSOR_COLOR  0x66CCFFFF

#define SCR_NONE      0
#define SCR_TITLE     1
#define SCR_MENU      2
#define SCR_HUD       3       // durante corrida / modo livre: botao MENU

#define MENU_PROFILE  0
#define MENU_MAIN     1
#define MENU_RACES    2
#define MENU_CUSTOM   3
#define MAX_MENUS     4
#define MAX_ITEMS     7

#define TD_BG         0
#define TD_LOGOBOX    1
#define TD_LOGO       2
#define TD_PANEL      3
#define TD_TITLE      4
#define TD_DESCBOX    5
#define TD_DESC       6
#define TD_BACK       7
#define TD_BACKTXT    8
#define TD_NEXT       9
#define TD_NEXTTXT    10
#define TD_HINT       11
#define TD_ROW0       12      // 12..18
#define TD_LAB0       19      // 19..25
#define TD_SPD        26      // HUD
#define TD_SPDLAB     27
#define TD_GEAR       28
#define TD_RPMBG      29
#define TD_RPM        30
#define TD_NOSBG      31
#define TD_NOS        32
#define TD_TIME       33
#define TD_CPTXT      34
#define TD_BANNER     35
#define TD_NOSTXT     36
#define TD_MONEY      37
#define TD_COUNT      38

// ---------- Economia ----------
#define START_MONEY   10000
#define PRICE_COLOR   500
#define PRICE_PAINT   1500
#define PRICE_NITRO   3000
#define PRICE_RIMS    2000
#define PRICE_KIT     5000
#define PRICE_NEON    2500
#define DRAG_REWARD   3000

#define DRAG_LEN      402.0   // 1/4 de milha em metros

// ---------- Lobby / garagem (AJUSTE com /pos) ----------
new Float:LobbyCar[4] = {1041.0, -1026.0, 32.2, 270.0};
new Float:LobbyCam[3] = {1046.5, -1031.5, 34.0};

// ---------- Corridas ----------
new RaceName[MAX_RACES][24] = {"Corrida 1 - Centro", "Corrida 2 - Praia", "Corrida 3 - Highway"};
new Float:RaceStart[MAX_RACES][4];
new Float:RaceCP[MAX_RACES][MAX_CPS][3];
new RaceCPCount[MAX_RACES];

// ---------- Jogadores ----------
new bool:pLogged[MAX_PLAYERS];
new pCar[MAX_PLAYERS];
new pRace[MAX_PLAYERS];
new pCP[MAX_PLAYERS];
new pStart[MAX_PLAYERS];
new pNeonObj[MAX_PLAYERS][2];
new pBest[MAX_PLAYERS][MAX_RACES];
new pBestDrag[MAX_PLAYERS];

// ---------- Perfil salvo (users/NOME.ini) ----------
new pHash[MAX_PLAYERS][65];
new pMoney[MAX_PLAYERS];
new pColor[MAX_PLAYERS];
new pPaintjob[MAX_PLAYERS];     // -1 = sem adesivo
new pNeon[MAX_PLAYERS];         // -1 = sem neon
new pRims[MAX_PLAYERS];         // 0 = rodas de fabrica
new bool:pKit[MAX_PLAYERS];
new RaceReward[MAX_RACES] = {1500, 2500, 4000};
new bool:pLocked[MAX_PLAYERS];     // true enquanto o carro esta travado (contagem)
new bool:pDrag[MAX_PLAYERS];
new pToken[MAX_PLAYERS];           // invalida timers antigos
new pDragTimer[MAX_PLAYERS];
new Float:pDragPrevD[MAX_PLAYERS];
new pDragPrevT[MAX_PLAYERS];
new bool:pHasNitro[MAX_PLAYERS];
new Float:pNitro[MAX_PLAYERS];
new pLastSpd[MAX_PLAYERS];
new pLastGear[MAX_PLAYERS];

// Drag: pista reta no sentido LESTE (angulo 270). AJUSTE com o botao POS.
new Float:DragStart[4] = {1400.0, -2500.0, 13.5, 270.0};

// Velocidade maxima de cada marcha (km/h) - so visual do HUD
new Float:GearMax[6] = {50.0, 90.0, 130.0, 175.0, 220.0, 270.0};

new pScreen[MAX_PLAYERS];
new pMenu[MAX_PLAYERS];
new pSel[MAX_PLAYERS];
new bool:pDialogOpen[MAX_PLAYERS];
new PlayerText:pTD[MAX_PLAYERS][TD_COUNT];

// ---------- Menus ----------
new MenuTitle[MAX_MENUS][16];
new MenuItem[MAX_MENUS][MAX_ITEMS][24];
new MenuDesc[MAX_MENUS][MAX_ITEMS][72];
new MenuCount[MAX_MENUS];
new MenuBack[MAX_MENUS] = {-1, -1, MENU_MAIN, MENU_MAIN};

// ---------- Tuning ----------
new ColorIds[6]   = {0, 1, 3, 79, 6, 126};
new NeonModels[6] = {18647, 18648, 18649, 18650, 18651, 18652};

forward RaceCountdown(playerid, n, token);
forward BackToLobby(playerid, token);
forward ClearBanner(playerid, token);
forward StartTitle(playerid);
forward HudUpdate();
forward DragTick(playerid);
forward StartDrag(playerid);
forward SetNeon(playerid, idx);
forward RemoveNeon(playerid);
forward ApplyBodyKit(veh);
forward SetCarLights(veh, bool:on);

forward ShowMenuScreen(playerid, menu);
forward StartRace(playerid, r);
forward SendToLobby(playerid);
forward ShowModsDialog(playerid);

// ============================================================
//  HELPERS
// ============================================================
PName(playerid)
{
    new n[MAX_PLAYER_NAME];
    GetPlayerName(playerid, n, sizeof n);
    return n;
}

Msg(playerid, const text[])
{
    SendClientMessage(playerid, 0xFFFF00FF, text);
}

// ---------- Perfil: ler e salvar ----------
ParseInts(const str[], out[], max)
{
    new n = 0, i = 0;
    while(str[i] && n < max)
    {
        while(str[i] == ' ') i++;
        if(!str[i] || str[i] == '\n' || str[i] == '\r') break;
        out[n++] = strval(str[i]);
        while(str[i] && str[i] != ' ') i++;
    }
    return n;
}

LoadProfile(playerid, const data[])
{
    new d[11] = {START_MONEY, 0, -1, -1, 0, 0, 0, 0, 0, 0, 0};
    ParseInts(data, d, 11);
    pMoney[playerid]    = d[0];
    pColor[playerid]    = d[1];
    pPaintjob[playerid] = d[2];
    pNeon[playerid]     = d[3];
    pRims[playerid]     = d[4];
    pKit[playerid]      = (d[5] != 0);
    pHasNitro[playerid] = (d[6] != 0);
    pBestDrag[playerid] = d[7];
    pBest[playerid][0]  = d[8];
    pBest[playerid][1]  = d[9];
    pBest[playerid][2]  = d[10];
    pNitro[playerid]    = 100.0;
}

SaveProfile(playerid)
{
    if(!pLogged[playerid]) return;
    new f[64], line[160];
    format(f, sizeof f, "users/%s.ini", PName(playerid));
    new File:h = fopen(f, io_write);
    if(!h) return;
    fwrite(h, pHash[playerid]);
    fwrite(h, "\n");
    format(line, sizeof line, "%d %d %d %d %d %d %d %d %d %d %d\n",
        pMoney[playerid], pColor[playerid], pPaintjob[playerid], pNeon[playerid], pRims[playerid],
        pKit[playerid] ? 1 : 0, pHasNitro[playerid] ? 1 : 0, pBestDrag[playerid],
        pBest[playerid][0], pBest[playerid][1], pBest[playerid][2]);
    fwrite(h, line);
    fclose(h);
}

AddCP(r, i, Float:x, Float:y, Float:z)
{
    RaceCP[r][i][0] = x; RaceCP[r][i][1] = y; RaceCP[r][i][2] = z;
    if(i + 1 > RaceCPCount[r]) RaceCPCount[r] = i + 1;
}

SetupRaces()
{
    RaceStart[0][0] = 1531.0; RaceStart[0][1] = -1675.0; RaceStart[0][2] = 13.4; RaceStart[0][3] = 270.0;
    AddCP(0, 0, 1380.0, -1675.0, 13.4);
    AddCP(0, 1, 1300.0, -1580.0, 13.4);
    AddCP(0, 2, 1300.0, -1440.0, 13.4);
    AddCP(0, 3, 1450.0, -1400.0, 13.4);
    AddCP(0, 4, 1530.0, -1500.0, 13.4);
    AddCP(0, 5, 1531.0, -1650.0, 13.4);

    RaceStart[1][0] = 400.0; RaceStart[1][1] = -1800.0; RaceStart[1][2] = 7.0; RaceStart[1][3] = 0.0;
    AddCP(1, 0, 380.0, -1700.0, 7.5);
    AddCP(1, 1, 370.0, -1600.0, 10.0);
    AddCP(1, 2, 480.0, -1530.0, 20.0);
    AddCP(1, 3, 600.0, -1500.0, 14.0);
    AddCP(1, 4, 700.0, -1590.0, 14.0);

    RaceStart[2][0] = 2500.0; RaceStart[2][1] = -1700.0; RaceStart[2][2] = 13.4; RaceStart[2][3] = 90.0;
    AddCP(2, 0, 2700.0, -1700.0, 12.0);
    AddCP(2, 1, 2800.0, -1500.0, 12.0);
    AddCP(2, 2, 2700.0, -1300.0, 30.0);
    AddCP(2, 3, 2500.0, -1250.0, 32.0);
    AddCP(2, 4, 2400.0, -1450.0, 24.0);
    AddCP(2, 5, 2480.0, -1680.0, 13.4);
}

AddItem(menu, const text[], const desc[])
{
    new i = MenuCount[menu];
    if(i >= MAX_ITEMS) return;
    format(MenuItem[menu][i], 24, "%s", text);
    format(MenuDesc[menu][i], 72, "%s", desc);
    MenuCount[menu]++;
}

SetupMenus()
{
    format(MenuTitle[MENU_PROFILE], 16, "PERFIL");
    AddItem(MENU_PROFILE, "NOVO PERFIL",     "Crie um novo perfil de piloto");
    AddItem(MENU_PROFILE, "CARREGAR PERFIL", "Carregue seu perfil existente");
    AddItem(MENU_PROFILE, "SAIR",            "Sair do servidor");

    format(MenuTitle[MENU_MAIN], 16, "MENU PRINCIPAL");
    AddItem(MENU_MAIN, "GO UNDERGROUND", "Modo carreira (em breve)");
    AddItem(MENU_MAIN, "QUICK RACE",     "Teste sua habilidade em corridas rapidas");
    AddItem(MENU_MAIN, "STATISTICS",     "Veja seus melhores tempos");
    AddItem(MENU_MAIN, "CUSTOMIZE RIDE", "Tunagem: pintura, rodas, kit visual e neon");
    AddItem(MENU_MAIN, "OPTIONS",        "Opcoes (em breve)");
    AddItem(MENU_MAIN, "PLAY ONLINE",    "Saia da garagem e dirija livremente");

    format(MenuTitle[MENU_RACES], 16, "QUICK RACE");
    AddItem(MENU_RACES, "CORRIDA 1", "Circuito pelo centro da cidade");
    AddItem(MENU_RACES, "CORRIDA 2", "Sprint pela praia");
    AddItem(MENU_RACES, "CORRIDA 3", "Highway em alta velocidade");
    AddItem(MENU_RACES, "DRAG",      "Arrancada de 402 metros (1/4 de milha)");

    format(MenuTitle[MENU_CUSTOM], 16, "CUSTOMIZE");
    AddItem(MENU_CUSTOM, "PINTURA",    "Troque a cor do carro - $500");
    AddItem(MENU_CUSTOM, "ADESIVOS",   "Vinis / paintjobs - $1500");
    AddItem(MENU_CUSTOM, "NITRO",      "Instale nitro - $3000");
    AddItem(MENU_CUSTOM, "RODAS",      "Escolha as rodas - $2000");
    AddItem(MENU_CUSTOM, "KIT VISUAL", "Aerofolio, para-choques e saias - $5000");
    AddItem(MENU_CUSTOM, "NEON",       "Luz neon embaixo do carro - $2500");
}

// ============================================================
//  TEXTDRAW HELPERS
// ============================================================
PlayerText:MkBox(playerid, Float:x, Float:y, Float:x2, Float:h, color, bool:sel = false)
{
    new PlayerText:t = CreatePlayerTextDraw(playerid, x, y, "_");
    PlayerTextDrawUseBox(playerid, t, 1);
    PlayerTextDrawBoxColor(playerid, t, color);
    PlayerTextDrawLetterSize(playerid, t, 0.0, h / 9.6);
    PlayerTextDrawTextSize(playerid, t, x2, sel ? h : 0.0);
    PlayerTextDrawSetShadow(playerid, t, 0);
    if(sel) PlayerTextDrawSetSelectable(playerid, t, 1);
    PlayerTextDrawShow(playerid, t);
    return t;
}

Banner(playerid, const text[])
{
    if(pTD[playerid][TD_BANNER] != PlayerText:INVALID_TEXT_DRAW)
        PlayerTextDrawSetString(playerid, pTD[playerid][TD_BANNER], text);
}

KillDragTimer(playerid)
{
    if(pDragTimer[playerid]) { KillTimer(pDragTimer[playerid]); pDragTimer[playerid] = 0; }
}

PlayerText:MkText(playerid, Float:x, Float:y, const text[], font, Float:lx, Float:ly, color, align)
{
    new PlayerText:t = CreatePlayerTextDraw(playerid, x, y, text);
    PlayerTextDrawFont(playerid, t, font);
    PlayerTextDrawLetterSize(playerid, t, lx, ly);
    PlayerTextDrawColor(playerid, t, color);
    PlayerTextDrawAlignment(playerid, t, align);
    PlayerTextDrawSetShadow(playerid, t, 0);
    PlayerTextDrawSetOutline(playerid, t, 0);
    PlayerTextDrawBackgroundColor(playerid, t, 0x000000FF);
    PlayerTextDrawSetProportional(playerid, t, 1);
    PlayerTextDrawShow(playerid, t);
    return t;
}

HideUI(playerid, bool:cancel = true)
{
    for(new i = 0; i < TD_COUNT; i++)
    {
        if(pTD[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid, pTD[playerid][i]);
            pTD[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }
    pScreen[playerid] = SCR_NONE;
    if(cancel) CancelSelectTextDraw(playerid);
}

SetSel(playerid, sel)
{
    new m = pMenu[playerid];
    pSel[playerid] = sel;
    for(new i = 0; i < MenuCount[m]; i++)
    {
        new PlayerText:row = pTD[playerid][TD_ROW0 + i];
        new PlayerText:lab = pTD[playerid][TD_LAB0 + i];
        if(i == sel)
        {
            PlayerTextDrawBoxColor(playerid, row, 0x000000C0);
            PlayerTextDrawColor(playerid, lab, 0xFFFFFFFF);
        }
        else
        {
            PlayerTextDrawBoxColor(playerid, row, 0x00000010);
            PlayerTextDrawColor(playerid, lab, 0x8FD3FFFF);
        }
        PlayerTextDrawShow(playerid, row);
        PlayerTextDrawShow(playerid, lab);
    }
    PlayerTextDrawSetString(playerid, pTD[playerid][TD_DESC], MenuDesc[m][sel]);
}

// ---------- Tela de titulo ----------
ShowTitleScreen(playerid)
{
    HideUI(playerid, false);
    pScreen[playerid] = SCR_TITLE;
    pDialogOpen[playerid] = false;
    pTD[playerid][TD_BG]   = MkBox(playerid, 0.0, 0.0, 640.0, 480.0, 0x000000FF, true);
    pTD[playerid][TD_LOGO] = MkText(playerid, 320.0, 150.0, "SAMP UNDERGROUND", FONT_TITLE, 0.9, 3.6, 0xBFE6FFFF, 2);
    pTD[playerid][TD_HINT] = MkText(playerid, 320.0, 330.0, "TOQUE PARA CONTINUAR", FONT_ITEM, 0.45, 1.6, 0x6FB8E6FF, 2);
    pTD[playerid][TD_DESC] = MkText(playerid, 320.0, 440.0, "Servidor SAMP Underground", FONT_ITEM, 0.28, 1.1, 0x5A8CA8FF, 2);
    SelectTextDraw(playerid, CURSOR_COLOR);
}

// ---------- Telas de menu ----------
public ShowMenuScreen(playerid, menu)
{
    HideUI(playerid, false);
    pScreen[playerid] = SCR_MENU;
    pMenu[playerid] = menu;
    pDialogOpen[playerid] = false;

    pTD[playerid][TD_LOGOBOX] = MkBox(playerid, 15.0, 18.0, 330.0, 42.0, 0x0B3C5FAA);
    pTD[playerid][TD_LOGO]    = MkText(playerid, 24.0, 22.0, "SAMP UNDERGROUND", FONT_TITLE, 0.6, 2.2, 0xCFEFFFFF, 1);
    if(menu != MENU_PROFILE)
    {
        new ms[24];
        format(ms, sizeof ms, "$ %d", pMoney[playerid]);
        pTD[playerid][TD_MONEY] = MkText(playerid, 24.0, 66.0, ms, FONT_TITLE, 0.5, 1.8, 0x66FF99FF, 1);
    }
    pTD[playerid][TD_PANEL]   = MkBox(playerid, 345.0, 70.0, 625.0, 262.0, 0x0B3C5F99);
    pTD[playerid][TD_TITLE]   = MkText(playerid, 615.0, 76.0, MenuTitle[menu], FONT_TITLE, 0.5, 2.0, 0xE6F6FFFF, 3);

    for(new i = 0; i < MenuCount[menu]; i++)
    {
        new Float:y = 108.0 + i * 31.0;
        pTD[playerid][TD_ROW0 + i] = MkBox(playerid, 352.0, y, 618.0, 27.0, 0x00000010, true);
        pTD[playerid][TD_LAB0 + i] = MkText(playerid, 610.0, y + 5.0, MenuItem[menu][i], FONT_ITEM, 0.42, 1.5, 0x8FD3FFFF, 3);
    }

    pTD[playerid][TD_DESCBOX] = MkBox(playerid, 345.0, 340.0, 625.0, 24.0, 0x0B3C5F99);
    pTD[playerid][TD_DESC]    = MkText(playerid, 485.0, 345.0, MenuDesc[menu][0], FONT_ITEM, 0.32, 1.2, 0x9FE0FFFF, 2);

    pTD[playerid][TD_BACK]    = MkBox(playerid, 15.0, 430.0, 160.0, 24.0, 0x0B3C5FAA, true);
    pTD[playerid][TD_BACKTXT] = MkText(playerid, 87.0, 435.0, "VOLTAR", FONT_ITEM, 0.38, 1.3, 0xFFFFFFFF, 2);
    pTD[playerid][TD_NEXT]    = MkBox(playerid, 168.0, 430.0, 313.0, 24.0, 0x0B3C5FAA, true);
    pTD[playerid][TD_NEXTTXT] = MkText(playerid, 240.0, 435.0, "CONFIRMAR", FONT_ITEM, 0.38, 1.3, 0xFFFFFFFF, 2);
    pTD[playerid][TD_HINT]    = MkText(playerid, 330.0, 436.0, "toque 1x: selecionar  -  2x: confirmar", FONT_ITEM, 0.26, 1.0, 0x5A8CA8FF, 1);

    SetSel(playerid, 0);
    SelectTextDraw(playerid, CURSOR_COLOR);
    return 1;
}

// ---------- HUD (corrida / modo livre) ----------
ShowHUD(playerid)
{
    HideUI(playerid, false);
    pScreen[playerid] = SCR_HUD;
    pDialogOpen[playerid] = false;
    pTD[playerid][TD_BACK]    = MkBox(playerid, 535.0, 18.0, 625.0, 24.0, 0x0B3C5FCC, true);
    pTD[playerid][TD_BACKTXT] = MkText(playerid, 580.0, 23.0, "MENU", FONT_ITEM, 0.38, 1.3, 0xFFFFFFFF, 2);

    // velocimetro / marcha / giro / nitro (canto inferior direito)
    pTD[playerid][TD_RPMBG]   = MkBox(playerid, 400.0, 368.0, 620.0, 8.0, 0x00000099);
    pTD[playerid][TD_RPM]     = MkBox(playerid, 400.0, 368.0, 401.0, 8.0, 0x33AAFFFF);
    pTD[playerid][TD_GEAR]    = MkText(playerid, 410.0, 380.0, "1", FONT_TITLE, 0.9, 3.4, 0x33AAFFFF, 1);
    pTD[playerid][TD_SPD]     = MkText(playerid, 612.0, 380.0, "0", FONT_TITLE, 0.9, 3.4, 0xFFFFFFFF, 3);
    pTD[playerid][TD_SPDLAB]  = MkText(playerid, 618.0, 424.0, "KM/H", FONT_ITEM, 0.3, 1.1, 0x8FD3FFFF, 3);
    new nosLabel[12];
    if(pHasNitro[playerid]) format(nosLabel, sizeof nosLabel, "NITRO");
    else format(nosLabel, sizeof nosLabel, "SEM NITRO");
    pTD[playerid][TD_NOSTXT]  = MkText(playerid, 400.0, 434.0, nosLabel, FONT_ITEM, 0.28, 1.0, 0xFFCC00FF, 1);
    pTD[playerid][TD_NOSBG]   = MkBox(playerid, 400.0, 446.0, 620.0, 8.0, 0x00000099);
    pTD[playerid][TD_NOS]     = MkBox(playerid, 400.0, 446.0, 401.0, 8.0, 0xFFCC00FF);

    // tempo / checkpoint (topo) e aviso grande (contagem, resultado)
    pTD[playerid][TD_TIME]    = MkText(playerid, 320.0, 18.0, "_", FONT_TITLE, 0.5, 1.8, 0xFFFFFFFF, 2);
    pTD[playerid][TD_CPTXT]   = MkText(playerid, 320.0, 44.0, "_", FONT_ITEM, 0.35, 1.3, 0x8FD3FFFF, 2);
    pTD[playerid][TD_BANNER]  = MkText(playerid, 320.0, 130.0, "_", FONT_TITLE, 1.2, 4.2, 0xFFFFFFFF, 2);
    pLastSpd[playerid] = -1;
    pLastGear[playerid] = -1;
    if(IsPlayerAdmin(playerid))   // botao de desenvolvedor: mostra suas coordenadas
    {
        pTD[playerid][TD_NEXT]    = MkBox(playerid, 440.0, 18.0, 530.0, 24.0, 0x5F3C0BCC, true);
        pTD[playerid][TD_NEXTTXT] = MkText(playerid, 485.0, 23.0, "POS", FONT_ITEM, 0.38, 1.3, 0xFFFFFFFF, 2);
    }
    SelectTextDraw(playerid, CURSOR_COLOR);
}

ShowPos(playerid)
{
    new Float:x, Float:y, Float:z, Float:a, s[96];
    if(IsPlayerInAnyVehicle(playerid))
    {
        GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
        GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
    }
    else
    {
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
    }
    format(s, sizeof s, "Pos: %.1f, %.1f, %.1f  Angulo: %.1f", x, y, z, a);
    SendClientMessage(playerid, 0xFFFFFFFF, s);
}

// ---------- Dinheiro ----------
RefreshMoney(playerid)
{
    if(pScreen[playerid] != SCR_MENU) return;
    if(pTD[playerid][TD_MONEY] == PlayerText:INVALID_TEXT_DRAW) return;
    new s[24];
    format(s, sizeof s, "$ %d", pMoney[playerid]);
    PlayerTextDrawSetString(playerid, pTD[playerid][TD_MONEY], s);
}

bool:Buy(playerid, price)
{
    if(pMoney[playerid] < price)
    {
        Msg(playerid, "Dinheiro insuficiente!");
        return false;
    }
    pMoney[playerid] -= price;
    RefreshMoney(playerid);
    SaveProfile(playerid);
    return true;
}

Reward(playerid, amount, bool:record)
{
    new s[64];
    if(record) amount += amount / 4;
    pMoney[playerid] += amount;
    if(record) format(s, sizeof s, "Premio: $%d (novo recorde!)", amount);
    else format(s, sizeof s, "Premio: $%d", amount);
    SendClientMessage(playerid, 0x00FF00FF, s);
    SaveProfile(playerid);
}

OpenDialog(playerid, id, style, const title[], const body[], const b1[], const b2[])
{
    pDialogOpen[playerid] = true;
    CancelSelectTextDraw(playerid);
    ShowPlayerDialog(playerid, id, style, title, body, b1, b2);
}

ShowStats(playerid)
{
    new s[256], line[64];
    s[0] = 0;
    for(new r = 0; r < MAX_RACES; r++)
    {
        if(pBest[playerid][r])
            format(line, sizeof line, "%s: %d.%03d s\n", RaceName[r], pBest[playerid][r] / 1000, pBest[playerid][r] % 1000);
        else
            format(line, sizeof line, "%s: --\n", RaceName[r]);
        strcat(s, line, sizeof s);
    }
    if(pBestDrag[playerid])
        format(line, sizeof line, "Drag 402m: %d.%03d s\n", pBestDrag[playerid] / 1000, pBestDrag[playerid] % 1000);
    else
        format(line, sizeof line, "Drag 402m: --\n");
    strcat(s, line, sizeof s);
    OpenDialog(playerid, DLG_STATS, DIALOG_STYLE_MSGBOX, "Statistics - melhores tempos", s, "OK", "");
}

public ShowModsDialog(playerid)
{
    ShowMenuScreen(playerid, MENU_CUSTOM);
    return 1;
}

// ============================================================
//  ACOES DO MENU
// ============================================================
MenuBackAction(playerid)
{
    new b = MenuBack[pMenu[playerid]];
    if(b != -1) ShowMenuScreen(playerid, b);
}

FreeRoam(playerid)
{
    SetPlayerVirtualWorld(playerid, 0);
    SetVehicleVirtualWorld(pCar[playerid], 0);
    TogglePlayerControllable(playerid, 1);
    SetCameraBehindPlayer(playerid);
    pLocked[playerid] = false;
    pDrag[playerid] = false;
    ShowHUD(playerid);
    Msg(playerid, "Modo livre! Use o botao MENU para voltar.");
}

MenuConfirm(playerid)
{
    new m = pMenu[playerid], s = pSel[playerid];
    new f[64];
    switch(m)
    {
        case MENU_PROFILE:
        {
            format(f, sizeof f, "users/%s.ini", PName(playerid));
            switch(s)
            {
                case 0:
                {
                    if(fexist(f)) { Msg(playerid, "Esse perfil ja existe! Use CARREGAR PERFIL."); return; }
                    OpenDialog(playerid, DLG_REGISTER, DIALOG_STYLE_PASSWORD, "Novo perfil", "Crie uma senha (min. 4 caracteres):", "Criar", "Voltar");
                }
                case 1:
                {
                    if(!fexist(f)) { Msg(playerid, "Perfil nao encontrado! Use NOVO PERFIL."); return; }
                    OpenDialog(playerid, DLG_LOGIN, DIALOG_STYLE_PASSWORD, "Carregar perfil", "Digite sua senha:", "Entrar", "Voltar");
                }
                case 2: Kick(playerid);
            }
        }
        case MENU_MAIN:
        {
            switch(s)
            {
                case 0: Msg(playerid, "Modo carreira em construcao!");
                case 1: ShowMenuScreen(playerid, MENU_RACES);
                case 2: ShowStats(playerid);
                case 3: ShowMenuScreen(playerid, MENU_CUSTOM);
                case 4: Msg(playerid, "Opcoes em construcao!");
                case 5: FreeRoam(playerid);
            }
        }
        case MENU_RACES:
        {
            if(s < MAX_RACES) StartRace(playerid, s);
            else StartDrag(playerid);
        }
        case MENU_CUSTOM:
        {
            switch(s)
            {
                case 0: OpenDialog(playerid, DLG_COLOR, DIALOG_STYLE_LIST, "Pintura",
                            "Preto\nBranco\nVermelho\nAzul\nAmarelo\nRosa", "Aplicar", "Voltar");
                case 1: OpenDialog(playerid, DLG_PAINTJOB, DIALOG_STYLE_LIST, "Adesivos",
                            "Adesivo 1\nAdesivo 2\nAdesivo 3\nSem adesivo", "Aplicar", "Voltar");
                case 2:
                {
                    if(pHasNitro[playerid]) Msg(playerid, "Voce ja tem nitro instalado!");
                    else if(Buy(playerid, PRICE_NITRO))
                    {
                        pHasNitro[playerid] = true;
                        pNitro[playerid] = 100.0;
                        SaveProfile(playerid);
                        Msg(playerid, "Nitro instalado! Use o botao de tiro (clique esquerdo / CTRL) para ativar.");
                    }
                }
                case 3: OpenDialog(playerid, DLG_RIMS, DIALOG_STYLE_LIST, "Rodas",
                            "Shadow\nMega\nRimshine\nWires\nClassic\nTwist\nCutter\nSwitch\nGrove\nImport\nDollar\nTrance\nAtomic",
                            "Aplicar", "Voltar");
                case 4:
                {
                    if(pKit[playerid]) Msg(playerid, "Voce ja tem o kit visual!");
                    else if(Buy(playerid, PRICE_KIT))
                    {
                        pKit[playerid] = true;
                        ApplyBodyKit(pCar[playerid]);
                        SaveProfile(playerid);
                        Msg(playerid, "Kit visual instalado!");
                    }
                }
                case 5: OpenDialog(playerid, DLG_NEON, DIALOG_STYLE_LIST, "Neon",
                            "Vermelho\nAzul\nVerde\nAmarelo\nRosa\nBranco\nDesligar", "Aplicar", "Voltar");
            }
        }
    }
}

ApplyBodyKit(veh)
{
    AddVehicleComponent(veh, 1147);
    AddVehicleComponent(veh, 1171);
    AddVehicleComponent(veh, 1149);
    AddVehicleComponent(veh, 1036);
    AddVehicleComponent(veh, 1040);
}

// ============================================================
//  CALLBACKS DE TEXTDRAW
// ============================================================
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == Text:INVALID_TEXT_DRAW)
    {
        // ESC: mantem o jogador no menu
        if(pScreen[playerid] != SCR_NONE && !pDialogOpen[playerid]) SelectTextDraw(playerid, CURSOR_COLOR);
        return 1;
    }
    return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(pScreen[playerid] == SCR_TITLE)
    {
        if(playertextid == pTD[playerid][TD_BG]) ShowMenuScreen(playerid, MENU_PROFILE);
        return 1;
    }
    if(pScreen[playerid] == SCR_HUD)
    {
        if(playertextid == pTD[playerid][TD_BACK]) SendToLobby(playerid);
        else if(playertextid == pTD[playerid][TD_NEXT]) ShowPos(playerid);
        return 1;
    }
    if(pScreen[playerid] != SCR_MENU) return 1;

    if(playertextid == pTD[playerid][TD_NEXT]) { MenuConfirm(playerid); return 1; }
    if(playertextid == pTD[playerid][TD_BACK]) { MenuBackAction(playerid); return 1; }

    for(new i = 0; i < MenuCount[pMenu[playerid]]; i++)
    {
        if(playertextid == pTD[playerid][TD_ROW0 + i])
        {
            if(pSel[playerid] == i) MenuConfirm(playerid);
            else SetSel(playerid, i);
            return 1;
        }
    }
    return 1;
}

// ============================================================
//  GAMEMODE
// ============================================================
public OnGameModeInit()
{
    SetGameModeText("SAMP Underground");
    AddPlayerClass(0, 1041.0, -1026.0, 32.0, 0.0, 0, 0, 0, 0, 0, 0);
    ShowPlayerMarkers(0);
    UsePlayerPedAnims();
    EnableStuntBonusForAll(0);
    SetWorldTime(0);
    SetWeather(10);
    SetupRaces();
    SetupMenus();
    SetTimer("HudUpdate", 100, true);
    return 1;
}

public OnPlayerConnect(playerid)
{
    pLogged[playerid] = false;
    pCar[playerid] = 0;
    pRace[playerid] = -1;
    pScreen[playerid] = SCR_NONE;
    pDialogOpen[playerid] = false;
    pNeonObj[playerid][0] = pNeonObj[playerid][1] = INVALID_OBJECT_ID;
    for(new i = 0; i < TD_COUNT; i++) pTD[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    for(new r = 0; r < MAX_RACES; r++) pBest[playerid][r] = 0;
    LoadProfile(playerid, "");   // zera tudo ate o login carregar o perfil
    pLocked[playerid] = true;
    pDrag[playerid] = false;
    pToken[playerid] = 0;
    pDragTimer[playerid] = 0;
    pHasNitro[playerid] = false;
    pNitro[playerid] = 100.0;
    SetPlayerTime(playerid, 0, 0);
    SetPlayerColor(playerid, 0x00FFFFFF);
    SetTimerEx("StartTitle", 500, false, "i", playerid);
    return 1;
}

public StartTitle(playerid)
{
    if(!IsPlayerConnected(playerid) || pLogged[playerid]) return 1;
    TogglePlayerSpectating(playerid, 1);
    SetPlayerCameraPos(playerid, LobbyCam[0], LobbyCam[1], LobbyCam[2]);
    SetPlayerCameraLookAt(playerid, LobbyCar[0], LobbyCar[1], LobbyCar[2]);
    ShowTitleScreen(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    KillDragTimer(playerid);
    SaveProfile(playerid);
    HideUI(playerid, false);
    RemoveNeon(playerid);
    if(pCar[playerid]) DestroyVehicle(pCar[playerid]);
    pCar[playerid] = 0;
    pLogged[playerid] = false;
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    if(pLogged[playerid]) SpawnPlayer(playerid);
    return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    return pLogged[playerid] ? 1 : 0;
}

public OnPlayerSpawn(playerid)
{
    if(!pLogged[playerid]) return 1;
    SetPlayerTime(playerid, 0, 0);
    SendToLobby(playerid);
    return 1;
}

// ============================================================
//  LOBBY / GARAGEM
// ============================================================
EnsureCar(playerid)
{
    if(pCar[playerid]) return pCar[playerid];
    new v = CreateVehicle(CAR_MODEL, LobbyCar[0], LobbyCar[1], LobbyCar[2], LobbyCar[3], pColor[playerid], pColor[playerid], -1);
    pCar[playerid] = v;
    SetCarLights(v, true);
    // reaplica a tunagem salva no perfil
    if(pPaintjob[playerid] >= 0) ChangeVehiclePaintjob(v, pPaintjob[playerid]);
    if(pRims[playerid]) AddVehicleComponent(v, pRims[playerid]);
    if(pKit[playerid]) ApplyBodyKit(v);
    SetNeon(playerid, pNeon[playerid]);
    return v;
}

SetCarLights(veh, bool:on)
{
    new e, l, a, d, b, bo, o;
    GetVehicleParamsEx(veh, e, l, a, d, b, bo, o);
    SetVehicleParamsEx(veh, 1, on ? 1 : 0, a, d, b, bo, o);
}

public SendToLobby(playerid)
{
    new v = EnsureCar(playerid);
    new vw = LOBBY_VW + playerid;
    DisablePlayerRaceCheckpoint(playerid);
    pToken[playerid]++;
    KillDragTimer(playerid);
    pRace[playerid] = -1;
    pDrag[playerid] = false;
    pLocked[playerid] = true;
    SetPlayerVirtualWorld(playerid, vw);
    SetVehicleVirtualWorld(v, vw);
    SetVehiclePos(v, LobbyCar[0], LobbyCar[1], LobbyCar[2]);
    SetVehicleZAngle(v, LobbyCar[3]);
    RepairVehicle(v);
    PutPlayerInVehicle(playerid, v, 0);
    TogglePlayerControllable(playerid, 0);
    SetPlayerCameraPos(playerid, LobbyCam[0], LobbyCam[1], LobbyCam[2]);
    SetPlayerCameraLookAt(playerid, LobbyCar[0], LobbyCar[1], LobbyCar[2]);
    ShowMenuScreen(playerid, MENU_MAIN);
    return 1;
}

public BackToLobby(playerid, token)
{
    if(IsPlayerConnected(playerid) && pLogged[playerid] && pToken[playerid] == token) SendToLobby(playerid);
    return 1;
}

// ============================================================
//  CORRIDA
// ============================================================
public StartRace(playerid, r)
{
    new v = pCar[playerid];
    ShowHUD(playerid);
    pToken[playerid]++;
    KillDragTimer(playerid);
    pDrag[playerid] = false;
    pLocked[playerid] = true;
    pRace[playerid] = r;
    pCP[playerid] = 0;
    SetPlayerVirtualWorld(playerid, 0);
    SetVehicleVirtualWorld(v, 0);
    SetVehiclePos(v, RaceStart[r][0], RaceStart[r][1], RaceStart[r][2]);
    SetVehicleZAngle(v, RaceStart[r][3]);
    PutPlayerInVehicle(playerid, v, 0);
    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid, 0);
    GameTextForPlayer(playerid, RaceName[r], 2000, 3);
    SetTimerEx("RaceCountdown", 2000, false, "iii", playerid, 3, pToken[playerid]);
    return 1;
}

public StartDrag(playerid)
{
    new v = pCar[playerid];
    ShowHUD(playerid);
    pToken[playerid]++;
    KillDragTimer(playerid);
    pRace[playerid] = -1;
    pDrag[playerid] = true;
    pLocked[playerid] = true;
    SetPlayerVirtualWorld(playerid, 0);
    SetVehicleVirtualWorld(v, 0);
    SetVehiclePos(v, DragStart[0], DragStart[1], DragStart[2]);
    SetVehicleZAngle(v, DragStart[3]);
    PutPlayerInVehicle(playerid, v, 0);
    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid, 0);
    SetPlayerRaceCheckpoint(playerid, 1, DragStart[0] + DRAG_LEN, DragStart[1], DragStart[2], 0.0, 0.0, 0.0, 12.0);
    Banner(playerid, "~w~PREPARE-SE");
    SetTimerEx("RaceCountdown", 2000, false, "iii", playerid, 3, pToken[playerid]);
    return 1;
}

public ClearBanner(playerid, token)
{
    if(IsPlayerConnected(playerid) && pToken[playerid] == token) Banner(playerid, "_");
    return 1;
}

DragGo(playerid)
{
    pStart[playerid] = GetTickCount();
    pDragPrevD[playerid] = 0.0;
    pDragPrevT[playerid] = 0;
    KillDragTimer(playerid);
    pDragTimer[playerid] = SetTimerEx("DragTick", 40, true, "i", playerid);
}

DragFinish(playerid, et)
{
    new Float:vx, Float:vy, Float:vz, s[96];
    GetVehicleVelocity(pCar[playerid], vx, vy, vz);
    new spd = floatround(floatsqroot(vx * vx + vy * vy + vz * vz) * 180.0);
    KillDragTimer(playerid);
    DisablePlayerRaceCheckpoint(playerid);
    pDrag[playerid] = false;
    new bool:rec = (pBestDrag[playerid] == 0 || et < pBestDrag[playerid]);
    if(rec) pBestDrag[playerid] = et;
    Reward(playerid, DRAG_REWARD, rec);
    format(s, sizeof s, "~g~%d.%03d s", et / 1000, et % 1000);
    Banner(playerid, s);
    format(s, sizeof s, "Drag 402m: %d.%03d s - velocidade final %d km/h", et / 1000, et % 1000, spd);
    SendClientMessage(playerid, 0x00FF00FF, s);
    SetTimerEx("BackToLobby", 5000, false, "ii", playerid, pToken[playerid]);
}

public DragTick(playerid)
{
    if(!IsPlayerConnected(playerid) || !pDrag[playerid])
    {
        KillDragTimer(playerid);
        return 1;
    }
    new Float:x, Float:y, Float:z;
    GetVehiclePos(pCar[playerid], x, y, z);
    new Float:d = floatabs(x - DragStart[0]);
    new t = GetTickCount() - pStart[playerid];
    if(d >= DRAG_LEN)
    {
        // interpola o instante exato em que cruzou a linha
        new Float:frac = (DRAG_LEN - pDragPrevD[playerid]) / (d - pDragPrevD[playerid]);
        new et = pDragPrevT[playerid] + floatround((t - pDragPrevT[playerid]) * frac);
        DragFinish(playerid, et);
        return 1;
    }
    pDragPrevD[playerid] = d;
    pDragPrevT[playerid] = t;
    return 1;
}

// ---------- HUD: velocimetro, marcha, giro, nitro, tempo ----------
UpdateHud(playerid)
{
    new v = pCar[playerid];
    if(!v || GetPlayerVehicleID(playerid) != v) return;

    new Float:vx, Float:vy, Float:vz;
    GetVehicleVelocity(v, vx, vy, vz);
    new Float:spd = floatsqroot(vx * vx + vy * vy + vz * vz) * 180.0;

    // nitro proprio (barra do HUD)
    if(pHasNitro[playerid])
    {
        new keys, ud, lr;
        GetPlayerKeys(playerid, keys, ud, lr);
        if((keys & KEY_FIRE) && pNitro[playerid] > 0.0 && !pLocked[playerid] && spd < 270.0)
        {
            SetVehicleVelocity(v, vx * 1.025, vy * 1.025, vz * 1.025);
            pNitro[playerid] -= 2.0;
            if(pNitro[playerid] < 0.0) pNitro[playerid] = 0.0;
        }
        else if(pNitro[playerid] < 100.0) pNitro[playerid] += 0.4;
    }

    // marcha e giro (simulados a partir da velocidade)
    new g = 0;
    while(g < 5 && spd > GearMax[g]) g++;
    new Float:lo = (g == 0) ? 0.0 : GearMax[g - 1] * 0.6;
    new Float:frac = (spd - lo) / (GearMax[g] - lo);
    if(frac < 0.0) frac = 0.0;
    if(frac > 1.0) frac = 1.0;
    new Float:rpm = 0.2 + 0.8 * frac;

    new ispd = floatround(spd), s[16];
    if(ispd != pLastSpd[playerid])
    {
        pLastSpd[playerid] = ispd;
        format(s, sizeof s, "%d", ispd);
        PlayerTextDrawSetString(playerid, pTD[playerid][TD_SPD], s);
    }
    if(g != pLastGear[playerid])
    {
        pLastGear[playerid] = g;
        format(s, sizeof s, "%d", g + 1);
        PlayerTextDrawSetString(playerid, pTD[playerid][TD_GEAR], s);
    }

    PlayerTextDrawTextSize(playerid, pTD[playerid][TD_RPM], 400.0 + 220.0 * rpm, 0.0);
    PlayerTextDrawBoxColor(playerid, pTD[playerid][TD_RPM], rpm > 0.9 ? 0xFF3322FF : 0x33AAFFFF);
    PlayerTextDrawShow(playerid, pTD[playerid][TD_RPM]);

    PlayerTextDrawTextSize(playerid, pTD[playerid][TD_NOS], 401.0 + 219.0 * (pNitro[playerid] / 100.0), 0.0);
    PlayerTextDrawShow(playerid, pTD[playerid][TD_NOS]);

    // tempo e checkpoint
    if((pRace[playerid] != -1 || pDrag[playerid]) && !pLocked[playerid])
    {
        new t = GetTickCount() - pStart[playerid], ts[24];
        format(ts, sizeof ts, "%d:%02d.%03d", t / 60000, (t / 1000) % 60, t % 1000);
        PlayerTextDrawSetString(playerid, pTD[playerid][TD_TIME], ts);
        if(pRace[playerid] != -1)
            format(ts, sizeof ts, "CHECKPOINT %d/%d", pCP[playerid] + 1, RaceCPCount[pRace[playerid]]);
        else
        {
            new Float:x, Float:y, Float:z;
            GetVehiclePos(v, x, y, z);
            format(ts, sizeof ts, "%d / 402 m", floatround(floatabs(x - DragStart[0])));
        }
        PlayerTextDrawSetString(playerid, pTD[playerid][TD_CPTXT], ts);
    }
}

public HudUpdate()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && pScreen[i] == SCR_HUD) UpdateHud(i);
    }
    return 1;
}

ShowCP(playerid)
{
    new r = pRace[playerid], c = pCP[playerid], n = RaceCPCount[r];
    if(c >= n) return 0;
    if(c == n - 1)
        SetPlayerRaceCheckpoint(playerid, 1, RaceCP[r][c][0], RaceCP[r][c][1], RaceCP[r][c][2], 0.0, 0.0, 0.0, 10.0);
    else
        SetPlayerRaceCheckpoint(playerid, 0, RaceCP[r][c][0], RaceCP[r][c][1], RaceCP[r][c][2],
            RaceCP[r][c + 1][0], RaceCP[r][c + 1][1], RaceCP[r][c + 1][2], 8.0);
    return 1;
}

public RaceCountdown(playerid, n, token)
{
    if(!IsPlayerConnected(playerid) || pToken[playerid] != token) return 1;
    if(n > 0)
    {
        new s[16];
        format(s, sizeof s, "~y~%d", n);
        Banner(playerid, s);
        SetTimerEx("RaceCountdown", 1000, false, "iii", playerid, n - 1, token);
        return 1;
    }
    Banner(playerid, "~g~GO!");
    SetTimerEx("ClearBanner", 1000, false, "ii", playerid, token);
    TogglePlayerControllable(playerid, 1);
    pLocked[playerid] = false;
    if(pDrag[playerid])
    {
        DragGo(playerid);
        return 1;
    }
    pStart[playerid] = GetTickCount();
    pCP[playerid] = 0;
    ShowCP(playerid);
    return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    if(pRace[playerid] == -1) return 1;
    pCP[playerid]++;
    if(pCP[playerid] >= RaceCPCount[pRace[playerid]])
    {
        new r = pRace[playerid];
        DisablePlayerRaceCheckpoint(playerid);
        new t = GetTickCount() - pStart[playerid];
        new bool:rec = (pBest[playerid][r] == 0 || t < pBest[playerid][r]);
        if(rec) pBest[playerid][r] = t;
        Reward(playerid, RaceReward[r], rec);
        new msg[96];
        format(msg, sizeof msg, "Voce terminou %s em %d.%03d segundos!", RaceName[r], t / 1000, t % 1000);
        SendClientMessage(playerid, 0x00FF00FF, msg);
        new bs[32];
        format(bs, sizeof bs, "~g~%d.%03d s", t / 1000, t % 1000);
        Banner(playerid, bs);
        pRace[playerid] = -1;
        SetTimerEx("BackToLobby", 4000, false, "ii", playerid, pToken[playerid]);
    }
    else ShowCP(playerid);
    return 1;
}

// ============================================================
//  NEON
// ============================================================
RemoveNeon(playerid)
{
    for(new i = 0; i < 2; i++)
    {
        if(pNeonObj[playerid][i] != INVALID_OBJECT_ID)
        {
            DestroyObject(pNeonObj[playerid][i]);
            pNeonObj[playerid][i] = INVALID_OBJECT_ID;
        }
    }
}

SetNeon(playerid, idx)
{
    RemoveNeon(playerid);
    if(idx < 0 || !pCar[playerid]) return;
    new Float:x, Float:y, Float:z;
    GetVehiclePos(pCar[playerid], x, y, z);
    pNeonObj[playerid][0] = CreateObject(NeonModels[idx], x, y, z, 0.0, 0.0, 0.0);
    pNeonObj[playerid][1] = CreateObject(NeonModels[idx], x, y, z, 0.0, 0.0, 0.0);
    AttachObjectToVehicle(pNeonObj[playerid][0], pCar[playerid], -0.8, 0.0, -0.7, 0.0, 0.0, 0.0);
    AttachObjectToVehicle(pNeonObj[playerid][1], pCar[playerid],  0.8, 0.0, -0.7, 0.0, 0.0, 0.0);
}

// ============================================================
//  DIALOGS
// ============================================================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    pDialogOpen[playerid] = false;
    switch(dialogid)
    {
        case DLG_REGISTER:
        {
            if(!response) { ShowMenuScreen(playerid, MENU_PROFILE); return 1; }
            if(strlen(inputtext) < 4)
            {
                OpenDialog(playerid, DLG_REGISTER, DIALOG_STYLE_PASSWORD, "Novo perfil", "Senha muito curta! Minimo 4 caracteres:", "Criar", "Voltar");
                return 1;
            }
            new hash[65];
            SHA256_PassHash(inputtext, "nfs_salt", hash, sizeof hash);
            format(pHash[playerid], 65, "%s", hash);
            LoadProfile(playerid, "");          // valores iniciais
            pLogged[playerid] = true;
            SaveProfile(playerid);
            HideUI(playerid);
            TogglePlayerSpectating(playerid, 0);
            return 1;
        }
        case DLG_LOGIN:
        {
            if(!response) { ShowMenuScreen(playerid, MENU_PROFILE); return 1; }
            new hash[65], stored[80], data[160], f[64];
            SHA256_PassHash(inputtext, "nfs_salt", hash, sizeof hash);
            format(f, sizeof f, "users/%s.ini", PName(playerid));
            new File:h = fopen(f, io_read);
            if(h) { fread(h, stored); fread(h, data); fclose(h); }
            if(strcmp(stored, hash, false, 64) == 0)
            {
                format(pHash[playerid], 65, "%s", hash);
                LoadProfile(playerid, data);
                pLogged[playerid] = true;
                HideUI(playerid);
                TogglePlayerSpectating(playerid, 0);
            }
            else
                OpenDialog(playerid, DLG_LOGIN, DIALOG_STYLE_PASSWORD, "Carregar perfil", "Senha incorreta! Tente de novo:", "Entrar", "Voltar");
            return 1;
        }
        case DLG_STATS:
        {
            ShowMenuScreen(playerid, MENU_MAIN);
            return 1;
        }
        case DLG_COLOR:
        {
            if(response && Buy(playerid, PRICE_COLOR))
            {
                pColor[playerid] = ColorIds[listitem];
                ChangeVehicleColor(pCar[playerid], pColor[playerid], pColor[playerid]);
                SaveProfile(playerid);
            }
            ShowModsDialog(playerid);
            return 1;
        }
        case DLG_PAINTJOB:
        {
            if(response)
            {
                if(listitem == 3)    // remover adesivo e gratis
                {
                    pPaintjob[playerid] = -1;
                    ChangeVehiclePaintjob(pCar[playerid], 255);
                    SaveProfile(playerid);
                }
                else if(Buy(playerid, PRICE_PAINT))
                {
                    pPaintjob[playerid] = listitem;
                    ChangeVehiclePaintjob(pCar[playerid], listitem);
                    SaveProfile(playerid);
                }
            }
            ShowModsDialog(playerid);
            return 1;
        }
        case DLG_RIMS:
        {
            if(response && Buy(playerid, PRICE_RIMS))
            {
                pRims[playerid] = 1073 + listitem;
                AddVehicleComponent(pCar[playerid], pRims[playerid]);
                SaveProfile(playerid);
            }
            ShowModsDialog(playerid);
            return 1;
        }
        case DLG_NEON:
        {
            if(response)
            {
                if(listitem == 6)    // desligar e gratis
                {
                    pNeon[playerid] = -1;
                    SetNeon(playerid, -1);
                    SaveProfile(playerid);
                }
                else if(Buy(playerid, PRICE_NEON))
                {
                    pNeon[playerid] = listitem;
                    SetNeon(playerid, listitem);
                    SaveProfile(playerid);
                }
            }
            ShowModsDialog(playerid);
            return 1;
        }
    }
    return 0;
}

// ============================================================
//  SEM COMANDOS: tudo e feito por botoes. Qualquer /comando e ignorado.
// ============================================================
public OnPlayerCommandText(playerid, cmdtext[])
{
    return 1;
}
