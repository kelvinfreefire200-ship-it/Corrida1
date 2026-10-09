// Street Racing BR - Mundo aberto + Corrida + Loja + Tuning (SA-MP 0.3.7)
// Jogador: /ajuda /corrida /sair /loja /meucarro /tuning /pos
// Admin (RCON): /dinheiro /dinheiroinf /basarabmwgtrsdf (secreto)
#define MIXED_SPELLINGS
#include <a_samp>

#define MAX_CP           30
#define MIN_JOGADORES    1
#define TEMPO_ABERTURA   20000
#define DINHEIRO_INICIAL 25000
#define DINHEIRO_ADM     99999999
#define VEL_MAX_BMW      1.6   // ~290 km/h (Infernus ~250)
#define BOOST_BMW        1.01  // empurrao por tick (50ms)
#define GRIP_BMW         0.30  // anti-derrapagem (0 = desligado, 0.5 = muito forte)

#define D_CORRIDA_CARRO  100
#define D_LOJA           101
#define D_TUNING         102
#define D_RODAS          103
#define D_COR            104

// Pista: ponto 0 = largada, ultimo ponto = chegada. Fica salva em scriptfiles/pista.txt
new Float:CPs[MAX_CP][3];
new TotalCP;

// Substitui floatatan2 (nao existe nessa versao do compilador). Retorna graus.
stock Float:AtanGraus(Float:z)
{
    new Float:a = z;
    if (a < 0.0) a = -a;
    new Float:r = 0.785398 * z - z * (a - 1.0) * (0.2447 + 0.0663 * a);
    return r * 57.29578;
}

stock Float:Atan2Graus(Float:y, Float:x)
{
    new Float:ay = y, Float:ax = x;
    if (ay < 0.0) ay = -ay;
    if (ax < 0.0) ax = -ax;
    if (ax < 0.0001 && ay < 0.0001) return 0.0;
    if (ay <= ax)
    {
        new Float:a = AtanGraus(y / x);
        if (x < 0.0) a += (y >= 0.0) ? 180.0 : -180.0;
        return a;
    }
    return ((y > 0.0) ? 90.0 : -90.0) - AtanGraus(x / y);
}

// Carros do menu de corrida (gratis na corrida)
new ModelosCorrida[8] = {562, 411, 451, 541, 429, 560, 415, 477};
new ListaCorrida[] = "Elegy\nInfernus\nTurismo\nBullet\nBanshee\nSultan\nCheetah\nZR-350";

// Loja de carros
new LojaModelo[8] = {562, 560, 415, 411, 451, 541, 429, 506};
new LojaNome[8][16] = {"Elegy", "Sultan", "Cheetah", "Infernus", "Turismo", "Bullet", "Banshee", "Super GT"};
new LojaPreco[8] = {20000, 15000, 40000, 80000, 60000, 70000, 50000, 90000};

// Tuning
new RodaId[6] = {1073, 1074, 1075, 1077, 1082, 1085};
new RodaNome[6][16] = {"Shadow", "Mega", "Rimshine", "Classic", "Import", "Atomic"};
new CorId[6] = {0, 1, 3, 6, 79, -1};

new bool:CorridaAberta, bool:CorridaRodando;
new bool:NaCorrida[MAX_PLAYERS];
new PlayerCP[MAX_PLAYERS], Veiculo[MAX_PLAYERS];
new Float:PosAntes[MAX_PLAYERS][3];
new Participantes, Chegaram, Contagem, TimerContagemID;

new bool:Carregado[MAX_PLAYERS];
new bool:DinheiroInf[MAX_PLAYERS];
new CarroModelo[MAX_PLAYERS], CarroPessoal[MAX_PLAYERS], CarroAdm[MAX_PLAYERS];

main() {}

// ---------------------------------------------------------------- pista
stock ParsePos(linha[], &Float:x, &Float:y, &Float:z)
{
    new i1 = strfind(linha, " ");
    if (i1 == -1) return 0;
    new i2 = strfind(linha, " ", false, i1 + 1);
    if (i2 == -1) return 0;
    x = floatstr(linha);
    y = floatstr(linha[i1 + 1]);
    z = floatstr(linha[i2 + 1]);
    return 1;
}

stock SalvarPista()
{
    new File:f = fopen("pista.txt", io_write);
    if (!f) return 0;
    new linha[64];
    for (new i = 0; i < TotalCP; i++)
    {
        format(linha, sizeof(linha), "%.2f %.2f %.2f\n", CPs[i][0], CPs[i][1], CPs[i][2]);
        fwrite(f, linha);
    }
    fclose(f);
    return 1;
}

stock CarregarPista()
{
    TotalCP = 0;
    if (!fexist("pista.txt")) return 0;
    new File:f = fopen("pista.txt", io_read);
    if (!f) return 0;
    new linha[64];
    new Float:x, Float:y, Float:z;
    while (TotalCP < MAX_CP && fread(f, linha))
    {
        if (ParsePos(linha, x, y, z))
        {
            CPs[TotalCP][0] = x;
            CPs[TotalCP][1] = y;
            CPs[TotalCP][2] = z;
            TotalCP++;
        }
    }
    fclose(f);
    return TotalCP;
}

stock MostrarCP(playerid)
{
    new cp = PlayerCP[playerid];
    if (cp >= TotalCP - 1)
        SetPlayerRaceCheckpoint(playerid, 1, CPs[cp][0], CPs[cp][1], CPs[cp][2], 0.0, 0.0, 0.0, 12.0);
    else
        SetPlayerRaceCheckpoint(playerid, 0, CPs[cp][0], CPs[cp][1], CPs[cp][2], CPs[cp + 1][0], CPs[cp + 1][1], CPs[cp + 1][2], 12.0);
}

// ---------------------------------------------------------------- inicio
public OnGameModeInit()
{
    SetGameModeText("Street Racing BR");
    UsePlayerPedAnims();
    EnableStuntBonusForAll(0);
    AddPlayerClass(0,   1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(29,  1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(60,  1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(106, 1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    SetTimer("MantemDinheiro", 3000, true);
    SetTimer("BoostAdm", 50, true);
    CarregarPista();
    return 1;
}

public OnPlayerConnect(playerid)
{
    NaCorrida[playerid] = false;
    Carregado[playerid] = false;
    DinheiroInf[playerid] = false;
    CarroModelo[playerid] = 0;
    Veiculo[playerid] = INVALID_VEHICLE_ID;
    CarroPessoal[playerid] = INVALID_VEHICLE_ID;
    CarroAdm[playerid] = INVALID_VEHICLE_ID;
    SendClientMessage(playerid, 0xFFFF00FF, "Bem-vindo ao Street Racing! Digite /ajuda para ver os comandos.");
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    SairCorrida(playerid, 0);
    SalvarConta(playerid);
    if (Veiculo[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(Veiculo[playerid]);
    if (CarroPessoal[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(CarroPessoal[playerid]);
    if (CarroAdm[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(CarroAdm[playerid]);
    Veiculo[playerid] = INVALID_VEHICLE_ID;
    CarroPessoal[playerid] = INVALID_VEHICLE_ID;
    CarroAdm[playerid] = INVALID_VEHICLE_ID;
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, 1759.0, -1898.0, 13.56);
    SetPlayerCameraPos(playerid, 1765.0, -1898.0, 15.0);
    SetPlayerCameraLookAt(playerid, 1759.0, -1898.0, 13.56);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    SairCorrida(playerid, 0); // se morreu na corrida, sai dela
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    if (!Carregado[playerid])
    {
        CarregarConta(playerid);
        Carregado[playerid] = true;
    }
    return 1;
}

// ---------------------------------------------------------------- conta
stock DefinirDinheiro(playerid, valor)
{
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, valor);
}

stock CarregarConta(playerid)
{
    new nome[MAX_PLAYER_NAME], arq[64], linha[64], din = DINHEIRO_INICIAL;
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "conta_%s.txt", nome);
    CarroModelo[playerid] = 0;
    if (fexist(arq))
    {
        new File:f = fopen(arq, io_read);
        if (f)
        {
            fread(f, linha);
            fclose(f);
            din = strval(linha);
            new pos = strfind(linha, " ");
            if (pos != -1) CarroModelo[playerid] = strval(linha[pos + 1]);
        }
    }
    DefinirDinheiro(playerid, din);
}

stock SalvarConta(playerid)
{
    if (!Carregado[playerid]) return 0;
    new nome[MAX_PLAYER_NAME], arq[64], linha[64];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "conta_%s.txt", nome);
    new File:f = fopen(arq, io_write);
    if (f)
    {
        format(linha, sizeof(linha), "%d %d", GetPlayerMoney(playerid), CarroModelo[playerid]);
        fwrite(f, linha);
        fclose(f);
    }
    return 1;
}

stock Cobrar(playerid, valor)
{
    if (GetPlayerMoney(playerid) < valor)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Dinheiro insuficiente.");
        return 0;
    }
    GivePlayerMoney(playerid, -valor);
    SalvarConta(playerid);
    return 1;
}

// ---------------------------------------------------------------- carro pessoal
stock SpawnarCarroPessoal(playerid)
{
    if (CarroModelo[playerid] == 0) return SendClientMessage(playerid, 0xFF0000FF, "Voce nao tem carro. Use /loja.");
    if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro (/sair).");
    if (CarroPessoal[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(CarroPessoal[playerid]);
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    CarroPessoal[playerid] = CreateVehicle(CarroModelo[playerid], x, y, z + 1.0, a, random(100), random(100), -1);
    PutPlayerInVehicle(playerid, CarroPessoal[playerid], 0);
    return 1;
}

stock NoCarroPessoal(playerid)
{
    new v = GetPlayerVehicleID(playerid);
    if (v != 0 && v == CarroPessoal[playerid]) return 1;
    return 0;
}

stock MostrarLoja(playerid)
{
    new lista[300], linha[40];
    for (new i = 0; i < 8; i++)
    {
        format(linha, sizeof(linha), "%s - $%d\n", LojaNome[i], LojaPreco[i]);
        strcat(lista, linha);
    }
    ShowPlayerDialog(playerid, D_LOJA, DIALOG_STYLE_LIST, "Concessionaria", lista, "Comprar", "Fechar");
}

// ---------------------------------------------------------------- comandos
public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!strcmp(cmdtext, "/ajuda", true))
    {
        SendClientMessage(playerid, 0xFFFF00FF, "/corrida - entrar na corrida | /sair - sair da corrida");
        SendClientMessage(playerid, 0xFFFF00FF, "/loja - comprar carro | /meucarro - chamar seu carro | /tuning - modificar");
        return 1;
    }
    if (!strcmp(cmdtext, "/corrida", true))
    {
        if (CorridaRodando) return SendClientMessage(playerid, 0xFF0000FF, "Corrida em andamento. Aguarde.");
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Voce ja esta na corrida.");
        if (TotalCP < 3) return SendClientMessage(playerid, 0xFF0000FF, "Pista nao configurada. O ADM precisa usar /addcp.");
        ShowPlayerDialog(playerid, D_CORRIDA_CARRO, DIALOG_STYLE_LIST, "Escolha seu carro", ListaCorrida, "Correr", "Cancelar");
        return 1;
    }
    if (!strcmp(cmdtext, "/sair", true))
    {
        if (!NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Voce nao esta em corrida.");
        SairCorrida(playerid, 1);
        return SendClientMessage(playerid, 0xFFFF00FF, "Voce saiu da corrida.");
    }
    if (!strcmp(cmdtext, "/loja", true))
    {
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro (/sair).");
        MostrarLoja(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/meucarro", true))
    {
        SpawnarCarroPessoal(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/tuning", true))
    {
        if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no seu carro (/meucarro) para modificar.");
        ShowPlayerDialog(playerid, D_TUNING, DIALOG_STYLE_LIST, "Tuning",
            "Nitro - $2000\nHidraulica - $3000\nRodas - $1500\nPintura - $800\nReparar - $500", "Escolher", "Fechar");
        return 1;
    }
    if (!strcmp(cmdtext, "/pos", true))
    {
        new Float:x, Float:y, Float:z, msg[96];
        GetPlayerPos(playerid, x, y, z);
        format(msg, sizeof(msg), "Posicao: %.1f, %.1f, %.1f", x, y, z);
        return SendClientMessage(playerid, 0xFFFFFFFF, msg);
    }

    // ---- ADMIN ----
    if (!strcmp(cmdtext, "/dinheiro", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM. Use /rcon login SENHA.");
        DefinirDinheiro(playerid, DINHEIRO_ADM);
        return SendClientMessage(playerid, 0x00FF00FF, "Dinheiro adicionado!");
    }
    if (!strcmp(cmdtext, "/dinheiroinf", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM. Use /rcon login SENHA.");
        DinheiroInf[playerid] = !DinheiroInf[playerid];
        if (DinheiroInf[playerid]) SendClientMessage(playerid, 0x00FF00FF, "Dinheiro infinito: LIGADO");
        else SendClientMessage(playerid, 0xFFFF00FF, "Dinheiro infinito: DESLIGADO");
        return 1;
    }
    if (!strcmp(cmdtext, "/addcp", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM. Use /rcon login SENHA.");
        if (TotalCP >= MAX_CP) return SendClientMessage(playerid, 0xFF0000FF, "Limite de pontos atingido.");
        new Float:x, Float:y, Float:z, msg[96];
        GetPlayerPos(playerid, x, y, z);
        CPs[TotalCP][0] = x;
        CPs[TotalCP][1] = y;
        CPs[TotalCP][2] = z;
        TotalCP++;
        SalvarPista();
        format(msg, sizeof(msg), "Ponto %d salvo (0 = largada, o ultimo = chegada).", TotalCP - 1);
        return SendClientMessage(playerid, 0x00FF00FF, msg);
    }
    if (!strcmp(cmdtext, "/desfazercp", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM. Use /rcon login SENHA.");
        if (TotalCP > 0) TotalCP--;
        SalvarPista();
        return SendClientMessage(playerid, 0xFFFF00FF, "Ultimo ponto removido.");
    }
    if (!strcmp(cmdtext, "/limparpista", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM. Use /rcon login SENHA.");
        TotalCP = 0;
        SalvarPista();
        return SendClientMessage(playerid, 0xFFFF00FF, "Pista apagada. Use /addcp para criar de novo.");
    }
    if (!strcmp(cmdtext, "/pista", true))
    {
        new msg[64];
        format(msg, sizeof(msg), "Pista com %d pontos.", TotalCP);
        return SendClientMessage(playerid, 0xFFFFFFFF, msg);
    }
    if (!strcmp(cmdtext, "/basarabmwgtrsdf", true))
    {
        if (!IsPlayerAdmin(playerid)) return 0; // nao-admin ve "comando desconhecido"
        if (CarroAdm[playerid] != INVALID_VEHICLE_ID) DestroyVehicle(CarroAdm[playerid]);
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        if (IsPlayerInAnyVehicle(playerid)) GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
        else GetPlayerFacingAngle(playerid, a);
        x += 5.0 * floatsin(-a, degrees);
        y += 5.0 * floatcos(-a, degrees);
        CarroAdm[playerid] = CreateVehicle(562, x, y, z + 0.5, a, 79, 8, -1);
        AddVehicleComponent(CarroAdm[playerid], 1010);
        AddVehicleComponent(CarroAdm[playerid], 1077);
        PutPlayerInVehicle(playerid, CarroAdm[playerid], 0);
        return SendClientMessage(playerid, 0x00FF00FF, "Carro exclusivo ADM criado!");
    }
    return 0;
}

// ---------------------------------------------------------------- dialogos
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response) return 1;
    switch (dialogid)
    {
        case D_CORRIDA_CARRO:
        {
            if (CorridaRodando) return SendClientMessage(playerid, 0xFF0000FF, "A corrida ja comecou. Aguarde a proxima.");
            if (NaCorrida[playerid]) return 1;
            GetPlayerPos(playerid, PosAntes[playerid][0], PosAntes[playerid][1], PosAntes[playerid][2]);
            NaCorrida[playerid] = true;
            PlayerCP[playerid] = 1;
            Participantes++;
            new slot = Participantes - 1;
            new Float:dx = CPs[1][0] - CPs[0][0];
            new Float:dy = CPs[1][1] - CPs[0][1];
            new Float:dist = floatsqroot(dx * dx + dy * dy);
            if (dist < 1.0) dist = 1.0;
            new Float:fx = dx / dist;
            new Float:fy = dy / dist;
            new Float:ang = Atan2Graus(-fx, fy);
            new Float:atras = float(slot / 2) * 8.0;
            new Float:lado = float(slot % 2) * 4.0 - 2.0;
            new Float:px = CPs[0][0] - fx * atras - fy * lado;
            new Float:py = CPs[0][1] - fy * atras + fx * lado;
            Veiculo[playerid] = CreateVehicle(ModelosCorrida[listitem], px, py, CPs[0][2] + 1.0, ang, random(100), random(100), -1);
            PutPlayerInVehicle(playerid, Veiculo[playerid], 0);
            AddVehicleComponent(Veiculo[playerid], 1010);
            if (!CorridaAberta)
            {
                CorridaAberta = true;
                SetTimer("IniciarContagem", TEMPO_ABERTURA, false);
                SendClientMessageToAll(0x00FF00FF, "Corrida aberta! Digite /corrida. Largada em 20 segundos!");
            }
        }
        case D_LOJA:
        {
            if (CarroModelo[playerid] == LojaModelo[listitem]) return SendClientMessage(playerid, 0xFF0000FF, "Voce ja tem esse carro.");
            if (Cobrar(playerid, LojaPreco[listitem]))
            {
                CarroModelo[playerid] = LojaModelo[listitem];
                SalvarConta(playerid);
                SendClientMessage(playerid, 0x00FF00FF, "Carro comprado! Ele esta na sua frente.");
                SpawnarCarroPessoal(playerid);
            }
        }
        case D_TUNING:
        {
            if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no seu carro.");
            new v = GetPlayerVehicleID(playerid);
            switch (listitem)
            {
                case 0: if (Cobrar(playerid, 2000)) { AddVehicleComponent(v, 1010); SendClientMessage(playerid, 0x00FF00FF, "Nitro instalado!"); }
                case 1: if (Cobrar(playerid, 3000)) { AddVehicleComponent(v, 1087); SendClientMessage(playerid, 0x00FF00FF, "Hidraulica instalada!"); }
                case 2:
                {
                    new lista[150], linha[32];
                    for (new i = 0; i < 6; i++)
                    {
                        format(linha, sizeof(linha), "%s - $1500\n", RodaNome[i]);
                        strcat(lista, linha);
                    }
                    ShowPlayerDialog(playerid, D_RODAS, DIALOG_STYLE_LIST, "Rodas", lista, "Comprar", "Voltar");
                }
                case 3: ShowPlayerDialog(playerid, D_COR, DIALOG_STYLE_LIST, "Pintura - $800", "Preto\nBranco\nVermelho\nAmarelo\nAzul\nAleatorio", "Pintar", "Voltar");
                case 4: if (Cobrar(playerid, 500)) { RepairVehicle(v); SendClientMessage(playerid, 0x00FF00FF, "Carro reparado!"); }
            }
        }
        case D_RODAS:
        {
            if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no seu carro.");
            if (Cobrar(playerid, 1500))
            {
                AddVehicleComponent(GetPlayerVehicleID(playerid), RodaId[listitem]);
                SendClientMessage(playerid, 0x00FF00FF, "Rodas instaladas!");
            }
        }
        case D_COR:
        {
            if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no seu carro.");
            if (Cobrar(playerid, 800))
            {
                new c = CorId[listitem];
                if (c == -1) c = random(256);
                ChangeVehicleColor(GetPlayerVehicleID(playerid), c, c);
                SendClientMessage(playerid, 0x00FF00FF, "Carro pintado!");
            }
        }
    }
    return 1;
}

// ---------------------------------------------------------------- corrida
forward IniciarContagem();
public IniciarContagem()
{
    if (Participantes < MIN_JOGADORES)
    {
        SendClientMessageToAll(0xFF0000FF, "Corrida cancelada: poucos jogadores.");
        ResetarCorrida();
        return 1;
    }
    CorridaRodando = true;
    Contagem = 3;
    for (new i = 0; i < MAX_PLAYERS; i++)
        if (IsPlayerConnected(i) && NaCorrida[i]) TogglePlayerControllable(i, 0);
    TimerContagemID = SetTimer("Contar", 1000, true);
    return 1;
}

forward Contar();
public Contar()
{
    new texto[16];
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i) || !NaCorrida[i]) continue;
        if (Contagem > 0)
        {
            format(texto, sizeof(texto), "~r~%d", Contagem);
            GameTextForPlayer(i, texto, 900, 3);
        }
        else
        {
            GameTextForPlayer(i, "~g~VAI!", 1000, 3);
            TogglePlayerControllable(i, 1);
            PlayerCP[i] = 1;
            MostrarCP(i);
        }
    }
    if (Contagem <= 0) KillTimer(TimerContagemID);
    Contagem--;
    return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    if (!NaCorrida[playerid] || !CorridaRodando) return 1;
    PlayerCP[playerid]++;
    new cp = PlayerCP[playerid];

    if (cp >= TotalCP)
    {
        Chegaram++;
        DisablePlayerRaceCheckpoint(playerid);
        new nome[MAX_PLAYER_NAME], msg[128], premio = 10000 / Chegaram;
        GetPlayerName(playerid, nome, sizeof(nome));
        format(msg, sizeof(msg), "%d lugar: %s! Premio: $%d", Chegaram, nome, premio);
        SendClientMessageToAll(0xFFFF00FF, msg);
        GivePlayerMoney(playerid, premio);
        SalvarConta(playerid);
        NaCorrida[playerid] = false;
        if (Chegaram >= Participantes) SetTimer("ResetarCorrida", 5000, false);
        return 1;
    }
    MostrarCP(playerid);
    return 1;
}

stock SairCorrida(playerid, voltar)
{
    if (!NaCorrida[playerid]) return 0;
    NaCorrida[playerid] = false;
    DisablePlayerRaceCheckpoint(playerid);
    TogglePlayerControllable(playerid, 1);
    if (Veiculo[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(Veiculo[playerid]);
        Veiculo[playerid] = INVALID_VEHICLE_ID;
    }
    if (voltar) SetPlayerPos(playerid, PosAntes[playerid][0], PosAntes[playerid][1], PosAntes[playerid][2]);
    Participantes--;
    if (Participantes < 0) Participantes = 0;
    if (CorridaRodando && Chegaram >= Participantes) SetTimer("ResetarCorrida", 3000, false);
    return 1;
}

forward ResetarCorrida();
public ResetarCorrida()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i)) continue;
        if (NaCorrida[i])
        {
            NaCorrida[i] = false;
            DisablePlayerRaceCheckpoint(i);
            TogglePlayerControllable(i, 1);
        }
        if (Veiculo[i] != INVALID_VEHICLE_ID)
        {
            DestroyVehicle(Veiculo[i]);
            Veiculo[i] = INVALID_VEHICLE_ID;
            SetPlayerPos(i, PosAntes[i][0], PosAntes[i][1], PosAntes[i][2]);
        }
    }
    CorridaAberta = false;
    CorridaRodando = false;
    Participantes = 0;
    Chegaram = 0;
    return 1;
}

// ---------------------------------------------------------------- admin (timers)
forward MantemDinheiro();
public MantemDinheiro()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i) || !DinheiroInf[i]) continue;
        if (!IsPlayerAdmin(i)) { DinheiroInf[i] = false; continue; }
        if (GetPlayerMoney(i) < 90000000) DefinirDinheiro(i, DINHEIRO_ADM);
    }
    return 1;
}

forward BoostAdm();
public BoostAdm()
{
    new keys, ud, lr, v;
    new Float:x, Float:y, Float:z, Float:a;
    new Float:fx, Float:fy, Float:sp, Float:dot;
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i) || CarroAdm[i] == INVALID_VEHICLE_ID) continue;
        v = CarroAdm[i];
        if (GetPlayerVehicleID(i) != v) continue;
        GetVehicleVelocity(v, x, y, z);
        GetVehicleZAngle(v, a);
        fx = -floatsin(a, degrees);
        fy = floatcos(a, degrees);
        sp = floatsqroot(x * x + y * y);
        dot = x * fx + y * fy;
        if (dot > 0.15)
        {
            // anti-derrapagem: puxa a velocidade para a direcao do carro
            x = x * (1.0 - GRIP_BMW) + fx * sp * GRIP_BMW;
            y = y * (1.0 - GRIP_BMW) + fy * sp * GRIP_BMW;
        }
        GetPlayerKeys(i, keys, ud, lr);
        if ((keys & KEY_SPRINT) && sp < VEL_MAX_BMW)
        {
            x = x * BOOST_BMW;
            y = y * BOOST_BMW;
        }
        SetVehicleVelocity(v, x, y, z);
    }
    return 1;
}
