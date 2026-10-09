// Street Racing BR v2 - Login + Ranks + Pistas + Economia Balanceada
// Recursos: Login/Registro, 3 Pistas, Corrida Ranqueada, Time Trial, Elegy Exclusivo ADM
#pragma dynamic 32768
#define MIXED_SPELLINGS
#include <a_samp>

#define MAX_CP           60
#define MIN_JOGADORES    1
#define TEMPO_ABERTURA   20000
#define DINHEIRO_INICIAL 1000
#define DINHEIRO_ADM     99999999
#define VEL_MAX_BMW      1.6
#define BOOST_BMW        1.01
#define GRIP_BMW         0.30

#define MAX_SLOTS        8
#define VAGAS_INICIAIS   2
#define PRECO_VAGA       250000
#define N_CAMPOS         8
#define F_MODELO         0
#define F_COR1           1
#define F_COR2           2
#define F_RODA           3
#define F_NITRO          4
#define F_NEON           5
#define F_AERO           6
#define F_HID            7

#define MAX_APOSTA       5000000
#define TAXA_APOSTA      10
#define BONUS_DIARIO     3000
#define DIF_MAX_DUELO    150
#define TEMPO_DUELO      300000

#define NUM_PISTAS       3

#define D_CORRIDA_CARRO  100
#define D_LOJA           101
#define D_TUNING         102
#define D_RODAS          103
#define D_COR            104
#define D_GARAGEM        105
#define D_GARAGEM_ACAO   106
#define D_NITRO          107
#define D_AERO           108
#define D_NEON           109
#define D_APOSTA_VALOR   110
#define D_DUELO_CONF     111
#define D_DUELO          112
#define D_LOGIN          113
#define D_REGISTER       114
#define D_CONFIRM        115
#define D_MODO_CORRIDA   116
#define D_RANK_MENU      117
#define D_PISTA_MENU     118

new Float:CPs[MAX_CP][3];
new TotalCP;
new PistaAtual = 1;

// Pista 1: LV -> San Fierro
new Float:PistaLVSF[19][3] = {
    {1685.0, 1450.0, 11.0}, {1450.0, 1450.0, 11.0}, {1200.0, 1450.0, 11.0},
    {950.0, 1450.0, 11.0},  {700.0, 1450.0, 11.0},  {450.0, 1450.0, 11.0},
    {200.0, 1450.0, 11.0},  {-50.0, 1450.0, 11.0},  {-300.0, 1450.0, 11.0},
    {-550.0, 1500.0, 11.0}, {-800.0, 1600.0, 11.0}, {-1050.0, 1700.0, 11.0},
    {-1300.0, 1750.0, 11.0},{-1550.0, 1800.0, 11.0},{-1800.0, 1900.0, 11.0},
    {-2000.0, 2100.0, 11.0},{-2200.0, 2300.0, 11.0},{-2400.0, 2400.0, 11.0},
    {-2500.0, 2500.0, 11.0}
};

// Pista 2: LV -> Los Santos
new Float:PistaLVLS[20][3] = {
    {1685.0, 1450.0, 11.0}, {1600.0, 1200.0, 11.0}, {1500.0, 950.0, 11.0},
    {1400.0, 700.0, 11.0},  {1300.0, 500.0, 11.0},  {1200.0, 300.0, 11.0},
    {1100.0, 100.0, 11.0},  {1000.0, -100.0, 11.0}, {900.0, -300.0, 11.0},
    {800.0, -500.0, 11.0},  {700.0, -700.0, 11.0},  {600.0, -900.0, 11.0},
    {500.0, -1100.0, 11.0}, {400.0, -1300.0, 11.0}, {500.0, -1500.0, 11.0},
    {700.0, -1700.0, 11.0}, {900.0, -1800.0, 11.0}, {1100.0, -1900.0, 11.0},
    {1300.0, -2000.0, 11.0},{1500.0, -2000.0, 11.0}
};

new PistaNome[NUM_PISTAS][40] = {"Pista ADM (custom)", "Las Venturas -> San Fierro", "Las Venturas -> Los Santos"};

// Loja: sem Elegy (562). Precos altos.
new LojaModelo[7] = {560, 415, 411, 451, 541, 429, 506};
new LojaNome[7][16] = {"Sultan", "Cheetah", "Infernus", "Turismo", "Bullet", "Banshee", "Super GT"};
new LojaPreco[7] = {150000, 250000, 400000, 350000, 450000, 500000, 1200000};

new RodaId[6] = {1073, 1074, 1075, 1077, 1082, 1085};
new RodaNome[6][16] = {"Shadow", "Mega", "Rimshine", "Classic", "Import", "Atomic"};
new RodaPreco[6] = {8000, 9000, 10000, 12000, 15000, 20000};

new CorId[6] = {0, 1, 3, 6, 79, -1};
new CorNome[6][16] = {"Preto", "Branco", "Vermelho", "Amarelo", "Azul", "Aleatorio"};

new NitroId[3] = {1009, 1008, 1010};
new NitroPreco[3] = {15000, 30000, 50000};

new AeroId[20] = {1000, 1001, 1002, 1003, 1014, 1015, 1016, 1023, 1049, 1050, 1058, 1060, 1138, 1139, 1146, 1147, 1158, 1162, 1163, 1164};
new AeroNome[20][14] = {"Alien", "X-Flow", "Alpha", "Champ", "Drag", "Race", "Worx", "Fury", "Pro", "Win", "Vento", "Trofeu", "Rally", "Street", "Tuner", "Drift", "Speed", "Monster", "Cyber", "Neon"};
new AeroPreco[20] = {12000,13000,14000,15000,16000,17000,18000,19000,20000,21000,22000,23000,24000,25000,26000,27000,28000,29000,30000,32000};

new NeonNome[6][10] = {"Vermelho", "Azul", "Verde", "Amarelo", "Rosa", "Branco"};
new NeonPreco = 25000;
new NeonObj[MAX_VEHICLES + 1][2];

new Float:EntregaPos[6][3] = {
    {2495.0, -1688.0, 13.5}, {1480.0, -1740.0, 13.5}, {2227.0, -1721.0, 13.5},
    {1685.0, -2330.0, 13.5}, {400.0, -2088.0, 7.8},   {810.0, -1356.0, 13.5}
};
new EntregaNome[6][24] = {"Grove Street", "Centro (Prefeitura)", "Academia Ganton", "Aeroporto", "Pier Santa Maria", "Estacao Market"};

new bool:CorridaAberta, bool:CorridaRodando, bool:ModoDuelo, bool:ResetAgendado;
new bool:ModoRanqueada, bool:ModoTempo;
new bool:NaCorrida[MAX_PLAYERS];
new PlayerCP[MAX_PLAYERS], Veiculo[MAX_PLAYERS];
new Float:PosAntes[MAX_PLAYERS][3];
new Participantes, Chegaram, Contagem, TimerContagemID;
new ValorAposta, PotAposta;
new EscolhaCarro[MAX_PLAYERS], SlotCorrida[MAX_PLAYERS];
new TempoInicio[MAX_PLAYERS], TimerTempoID;

new bool:DueloAtivo;
new DueloP1, DueloP2, DueloTimerID;
new DesafioAlvo[MAX_PLAYERS], DesafioDe[MAX_PLAYERS];
new ErroDuelo[96];

new bool:Carregado[MAX_PLAYERS];
new bool:Logado[MAX_PLAYERS];
new bool:Registrando[MAX_PLAYERS];
new bool:DinheiroInf[MAX_PLAYERS];
new Garagem[MAX_PLAYERS][MAX_SLOTS][N_CAMPOS];
new bool:SlotTravado[MAX_PLAYERS][MAX_SLOTS];
new Vagas[MAX_PLAYERS], SlotAtivo[MAX_PLAYERS], SlotSel[MAX_PLAYERS], UltimoBonus[MAX_PLAYERS];
new CarroPessoal[MAX_PLAYERS], CarroAdm[MAX_PLAYERS];
new RankPontos[MAX_PLAYERS];

new ConfirmTipo[MAX_PLAYERS], ConfirmPreco[MAX_PLAYERS], ConfirmData[MAX_PLAYERS];

new bool:EntregaAtiva[MAX_PLAYERS];
new EntregaPremio[MAX_PLAYERS];

new RankNome[3][16] = {"Amador", "Profissional", "Elite"};

main() {}

// ------------------------------------------------------------- util
stock AtanGraus(Float:z)
{
    new Float:a = z;
    if (a < 0.0) a = -a;
    new Float:r = 0.785398 * z - z * (a - 1.0) * (0.2447 + 0.0663 * a);
    return r * 57.29578;
}
stock Atan2Graus(Float:y, Float:x)
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

stock HashSenha(const senha[])
{
    new h = 5381;
    for (new i = 0; senha[i] != 0; i++) h = ((h << 5) + h) + senha[i];
    if (h < 0) h = -h;
    return h;
}

stock LerInts(const linha[], valores[], maximo)
{
    new n = 0, i = 0, len = strlen(linha);
    while (i < len && n < maximo)
    {
        while (i < len && linha[i] == ' ') i++;
        if (i >= len || linha[i] == '\r' || linha[i] == '\n') break;
        valores[n] = strval(linha[i]); n++;
        while (i < len && linha[i] != ' ' && linha[i] != '\r' && linha[i] != '\n') i++;
    }
    return n;
}
stock PrecoModelo(modelo)
{
    for (new i = 0; i < 7; i++) if (LojaModelo[i] == modelo) return LojaPreco[i];
    if (modelo == 562) return 200000;
    return 0;
}
stock NomeModelo(modelo, nome[], tam)
{
    for (new i = 0; i < 7; i++) if (LojaModelo[i] == modelo) { format(nome, tam, "%s", LojaNome[i]); return 1; }
    if (modelo == 562) { format(nome, tam, "Elegy (ADM)"); return 1; }
    format(nome, tam, "Modelo %d", modelo); return 0;
}
stock LimparSlot(playerid, slot)
{
    for (new k = 0; k < N_CAMPOS; k++) Garagem[playerid][slot][k] = 0;
    SlotTravado[playerid][slot] = false; return 1;
}
stock NovoCarroSlot(playerid, slot, modelo)
{
    LimparSlot(playerid, slot);
    Garagem[playerid][slot][F_MODELO] = modelo;
    Garagem[playerid][slot][F_COR1] = random(126);
    Garagem[playerid][slot][F_COR2] = random(126);
    return 1;
}
stock SlotLivre(playerid)
{
    for (new s = 0; s < Vagas[playerid] && s < MAX_SLOTS; s++)
        if (Garagem[playerid][s][F_MODELO] == 0) return s;
    return -1;
}
stock RemoverNeon(v)
{
    if (v < 1 || v > MAX_VEHICLES) return 0;
    for (new i = 0; i < 2; i++) if (NeonObj[v][i] != 0) { DestroyObject(NeonObj[v][i]); NeonObj[v][i] = 0; }
    return 1;
}
stock AplicarNeon(v, tipo)
{
    RemoverNeon(v);
    if (tipo < 1 || tipo > 6) return 0;
    new modelo = 18646 + tipo;
    NeonObj[v][0] = CreateObject(modelo, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    NeonObj[v][1] = CreateObject(modelo, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    AttachObjectToVehicle(NeonObj[v][0], v, -0.8, 0.0, -0.7, 0.0, 0.0, 0.0);
    AttachObjectToVehicle(NeonObj[v][1], v,  0.8, 0.0, -0.7, 0.0, 0.0, 0.0);
    return 1;
}
stock DestruirVeiculo(v)
{
    if (v < 1 || v > MAX_VEHICLES) return 0;
    RemoverNeon(v); DestroyVehicle(v); return 1;
}
stock InstalarComp(v, comp, slotmod)
{
    AddVehicleComponent(v, comp);
    if (GetVehicleComponentInSlot(v, slotmod) == comp) return 1;
    return 0;
}
stock CriarVeiculoSlot(playerid, slot, Float:x, Float:y, Float:z, Float:a)
{
    new v = CreateVehicle(Garagem[playerid][slot][F_MODELO], x, y, z, a, Garagem[playerid][slot][F_COR1], Garagem[playerid][slot][F_COR2], -1);
    if (Garagem[playerid][slot][F_RODA] > 0) AddVehicleComponent(v, Garagem[playerid][slot][F_RODA]);
    if (Garagem[playerid][slot][F_NITRO] > 0) AddVehicleComponent(v, Garagem[playerid][slot][F_NITRO]);
    if (Garagem[playerid][slot][F_AERO] > 0) AddVehicleComponent(v, Garagem[playerid][slot][F_AERO]);
    if (Garagem[playerid][slot][F_HID] > 0) AddVehicleComponent(v, Garagem[playerid][slot][F_HID]);
    if (Garagem[playerid][slot][F_NEON] > 0) AplicarNeon(v, Garagem[playerid][slot][F_NEON]);
    return v;
}

stock CarregarPistaAtual()
{
    TotalCP = 0;
    if (PistaAtual == 0)
    {
        if (!fexist("pista.txt")) return 0;
        new File:f = fopen("pista.txt", io_read);
        if (!f) return 0;
        new linha[64];
        while (TotalCP < MAX_CP && fread(f, linha))
        {
            new i1 = strfind(linha, " "); if (i1 == -1) continue;
            new i2 = strfind(linha, " ", false, i1 + 1); if (i2 == -1) continue;
            CPs[TotalCP][0] = floatstr(linha);
            CPs[TotalCP][1] = floatstr(linha[i1 + 1]);
            CPs[TotalCP][2] = floatstr(linha[i2 + 1]);
            TotalCP++;
        }
        fclose(f);
    }
    else if (PistaAtual == 1)
    {
        for (new i = 0; i < 19; i++) { CPs[i][0] = PistaLVSF[i][0]; CPs[i][1] = PistaLVSF[i][1]; CPs[i][2] = PistaLVSF[i][2]; }
        TotalCP = 19;
    }
    else if (PistaAtual == 2)
    {
        for (new i = 0; i < 20; i++) { CPs[i][0] = PistaLVLS[i][0]; CPs[i][1] = PistaLVLS[i][1]; CPs[i][2] = PistaLVLS[i][2]; }
        TotalCP = 20;
    }
    return TotalCP;
}

stock SalvarPista()
{
    if (PistaAtual != 0) return 1;
    new File:f = fopen("pista.txt", io_write); if (!f) return 0;
    new linha[64];
    for (new i = 0; i < TotalCP; i++) { format(linha, sizeof(linha), "%.2f %.2f %.2f\n", CPs[i][0], CPs[i][1], CPs[i][2]); fwrite(f, linha); }
    fclose(f); return 1;
}

stock MostrarCP(playerid)
{
    new cp = PlayerCP[playerid];
    if (cp >= TotalCP - 1) SetPlayerRaceCheckpoint(playerid, 1, CPs[cp][0], CPs[cp][1], CPs[cp][2], 0.0, 0.0, 0.0, 12.0);
    else SetPlayerRaceCheckpoint(playerid, 0, CPs[cp][0], CPs[cp][1], CPs[cp][2], CPs[cp+1][0], CPs[cp+1][1], CPs[cp+1][2], 12.0);
}

// ------------------------------------------------------------- forwards
forward IniciarContagem();
forward Contar();
forward ResetarCorrida();
forward DueloTimeout();
forward MantemDinheiro();
forward BoostAdm();
forward AtualizarTempo();

// ------------------------------------------------------------- init
public OnGameModeInit()
{
    SetGameModeText("Street Racing BR v2");
    UsePlayerPedAnims();
    EnableStuntBonusForAll(0);
    AddPlayerClass(0,   1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(29,  1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(60,  1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(106, 1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    SetTimer("MantemDinheiro", 3000, true);
    SetTimer("BoostAdm", 50, true);
    return 1;
}

public OnPlayerConnect(playerid)
{
    NaCorrida[playerid] = false;
    Carregado[playerid] = false;
    Logado[playerid] = false;
    Registrando[playerid] = false;
    DinheiroInf[playerid] = false;
    EntregaAtiva[playerid] = false;
    Veiculo[playerid] = INVALID_VEHICLE_ID;
    CarroPessoal[playerid] = INVALID_VEHICLE_ID;
    CarroAdm[playerid] = INVALID_VEHICLE_ID;
    SlotAtivo[playerid] = -1;
    SlotSel[playerid] = -1;
    SlotCorrida[playerid] = -1;
    Vagas[playerid] = VAGAS_INICIAIS;
    UltimoBonus[playerid] = 0;
    RankPontos[playerid] = 0;
    DesafioAlvo[playerid] = INVALID_PLAYER_ID;
    DesafioDe[playerid] = INVALID_PLAYER_ID;
    for (new s = 0; s < MAX_SLOTS; s++) LimparSlot(playerid, s);

    new nome[MAX_PLAYER_NAME], arq[64];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "conta_%s.txt", nome);

    if (fexist(arq))
    {
        ShowPlayerDialog(playerid, D_LOGIN, DIALOG_STYLE_PASSWORD, "Login",
            "Bem-vindo de volta! Digite sua senha:", "Entrar", "Sair");
    }
    else
    {
        ShowPlayerDialog(playerid, D_REGISTER, DIALOG_STYLE_PASSWORD, "Registro",
            "Bem-vindo! Crie uma senha para sua conta:", "Registrar", "Sair");
    }
    SetPlayerPos(playerid, 1759.0, -1898.0, 13.56);
    SetPlayerCameraPos(playerid, 1765.0, -1898.0, 15.0);
    SetPlayerCameraLookAt(playerid, 1759.0, -1898.0, 13.56);
    TogglePlayerSpectating(playerid, 1);
    TogglePlayerSpectating(playerid, 0);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    SairCorrida(playerid, 0);
    SalvarConta(playerid);
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (DesafioAlvo[i] == playerid) DesafioAlvo[i] = INVALID_PLAYER_ID;
        if (DesafioDe[i] == playerid) DesafioDe[i] = INVALID_PLAYER_ID;
    }
    if (Veiculo[playerid] != INVALID_VEHICLE_ID) DestruirVeiculo(Veiculo[playerid]);
    if (CarroPessoal[playerid] != INVALID_VEHICLE_ID) DestruirVeiculo(CarroPessoal[playerid]);
    if (CarroAdm[playerid] != INVALID_VEHICLE_ID) DestruirVeiculo(CarroAdm[playerid]);
    Veiculo[playerid] = INVALID_VEHICLE_ID;
    CarroPessoal[playerid] = INVALID_VEHICLE_ID;
    CarroAdm[playerid] = INVALID_VEHICLE_ID;
    Carregado[playerid] = false;
    Logado[playerid] = false;
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
    if (!Logado[playerid])
    {
        SetPlayerPos(playerid, 1759.0, -1898.0, 13.56);
        return 1;
    }
    SairCorrida(playerid, 0);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    new dia = gettime() / 86400;
    if (dia > UltimoBonus[playerid])
    {
        new msg[96];
        UltimoBonus[playerid] = dia;
        GivePlayerMoney(playerid, BONUS_DIARIO);
        SalvarConta(playerid);
        format(msg, sizeof(msg), "[BONUS DIARIO] Voce recebeu $%d! Volte amanha.", BONUS_DIARIO);
        SendClientMessage(playerid, 0x00FF00FF, msg);
    }
    return 1;
}

public OnVehicleDeath(vehicleid, killerid) { RemoverNeon(vehicleid); return 1; }

// ------------------------------------------------------------- conta
stock DefinirDinheiro(playerid, valor)
{
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, valor);
}

stock SalvarGaragem(playerid)
{
    if (!Logado[playerid]) return 0;
    new nome[MAX_PLAYER_NAME], arq[64], linha[100];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "garagem_%s.txt", nome);
    new File:f = fopen(arq, io_write);
    if (!f) return 0;
    format(linha, sizeof(linha), "%d %d %d\n", Vagas[playerid], UltimoBonus[playerid], RankPontos[playerid]);
    fwrite(f, linha);
    for (new s = 0; s < MAX_SLOTS; s++)
    {
        format(linha, sizeof(linha), "%d %d %d %d %d %d %d %d\n",
            Garagem[playerid][s][F_MODELO], Garagem[playerid][s][F_COR1], Garagem[playerid][s][F_COR2],
            Garagem[playerid][s][F_RODA], Garagem[playerid][s][F_NITRO], Garagem[playerid][s][F_NEON],
            Garagem[playerid][s][F_AERO], Garagem[playerid][s][F_HID]);
        fwrite(f, linha);
    }
    fclose(f);
    return 1;
}

stock CarregarGaragem(playerid)
{
    new nome[MAX_PLAYER_NAME], arq[64], linha[128], v[8], n;
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "garagem_%s.txt", nome);
    Vagas[playerid] = VAGAS_INICIAIS;
    UltimoBonus[playerid] = 0;
    RankPontos[playerid] = 0;
    for (new s = 0; s < MAX_SLOTS; s++) LimparSlot(playerid, s);
    if (fexist(arq))
    {
        new File:f = fopen(arq, io_read);
        if (f)
        {
            if (fread(f, linha))
            {
                n = LerInts(linha, v, 3);
                if (n >= 1) Vagas[playerid] = v[0];
                if (n >= 2) UltimoBonus[playerid] = v[1];
                if (n >= 3) RankPontos[playerid] = v[2];
                if (Vagas[playerid] < VAGAS_INICIAIS) Vagas[playerid] = VAGAS_INICIAIS;
                if (Vagas[playerid] > MAX_SLOTS) Vagas[playerid] = MAX_SLOTS;
            }
            new slot = 0;
            while (slot < MAX_SLOTS && fread(f, linha))
            {
                n = LerInts(linha, v, N_CAMPOS);
                if (n >= N_CAMPOS)
                {
                    for (new k = 0; k < N_CAMPOS; k++) Garagem[playerid][slot][k] = v[k];
                    if (Garagem[playerid][slot][F_MODELO] < 400 || Garagem[playerid][slot][F_MODELO] > 611) LimparSlot(playerid, slot);
                }
                slot++;
            }
            fclose(f);
        }
    }
    return 1;
}

stock CarregarConta(playerid)
{
    new nome[MAX_PLAYER_NAME], arq[64], linha[80];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "conta_%s.txt", nome);
    new din = DINHEIRO_INICIAL;
    if (fexist(arq))
    {
        new File:f = fopen(arq, io_read);
        if (f)
        {
            fread(f, linha);
            fclose(f);
            din = strval(linha);
        }
    }
    DefinirDinheiro(playerid, din);
    CarregarGaragem(playerid);
}

stock SalvarConta(playerid)
{
    if (!Carregado[playerid] || !Logado[playerid]) return 0;
    new nome[MAX_PLAYER_NAME], arq[64], linha[80];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "conta_%s.txt", nome);
    new File:f = fopen(arq, io_write);
    if (f)
    {
        new senhaHash = 0;
        new arq2[80];
        format(arq2, sizeof(arq2), "senha_%s.txt", nome);
        new File:f2 = fopen(arq2, io_read);
        if (f2) { fread(f2, linha); fclose(f2); senhaHash = strval(linha); }
        format(linha, sizeof(linha), "%d %d", GetPlayerMoney(playerid), senhaHash);
        fwrite(f, linha);
        fclose(f);
    }
    SalvarGaragem(playerid);
    return 1;
}

stock TemDinheiro(playerid, valor)
{
    if (GetPlayerMoney(playerid) < valor)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Dinheiro insuficiente.");
        return 0;
    }
    return 1;
}

stock Cobrar(playerid, valor)
{
    if (!TemDinheiro(playerid, valor)) return 0;
    GivePlayerMoney(playerid, -valor);
    SalvarConta(playerid);
    return 1;
}

stock RankDoJogador(playerid)
{
    if (RankPontos[playerid] >= 25) return 2;
    if (RankPontos[playerid] >= 10) return 1;
    return 0;
}

// ------------------------------------------------------------- garagem
stock SpawnarCarroPessoal(playerid, slot)
{
    if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro (/sair).");
    if (slot < 0 || slot >= MAX_SLOTS || Garagem[playerid][slot][F_MODELO] == 0) return SendClientMessage(playerid, 0xFF0000FF, "Vaga vazia. Compre um carro em /loja.");
    if (SlotTravado[playerid][slot]) return SendClientMessage(playerid, 0xFF0000FF, "Esse carro esta em uma aposta.");
    if (CarroPessoal[playerid] != INVALID_VEHICLE_ID) DestruirVeiculo(CarroPessoal[playerid]);
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    CarroPessoal[playerid] = CriarVeiculoSlot(playerid, slot, x, y, z + 1.0, a);
    SlotAtivo[playerid] = slot;
    PutPlayerInVehicle(playerid, CarroPessoal[playerid], 0);
    return 1;
}

stock NoCarroPessoal(playerid)
{
    new v = GetPlayerVehicleID(playerid);
    if (v != 0 && v == CarroPessoal[playerid]) return 1;
    return 0;
}

stock SlotDoTuning(playerid)
{
    if (!NoCarroPessoal(playerid) || SlotAtivo[playerid] < 0)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Entre no seu carro (/garagem) para modificar.");
        return -1;
    }
    if (SlotTravado[playerid][SlotAtivo[playerid]])
    {
        SendClientMessage(playerid, 0xFF0000FF, "Esse carro esta em uma aposta.");
        return -1;
    }
    return SlotAtivo[playerid];
}

stock Instalar(playerid, comp, slotmod, preco, campo, const nomeparte[])
{
    new s = SlotDoTuning(playerid);
    if (s < 0) return 0;
    if (!TemDinheiro(playerid, preco)) return 0;
    if (!InstalarComp(GetPlayerVehicleID(playerid), comp, slotmod))
    {
        SendClientMessage(playerid, 0xFF0000FF, "Essa peca nao serve nesse carro. Nada foi cobrado.");
        return 0;
    }
    Garagem[playerid][s][campo] = comp;
    Cobrar(playerid, preco);
    new msg[80];
    format(msg, sizeof(msg), "%s instalado(a)!", nomeparte);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}

stock MostrarGaragem(playerid)
{
    new lista[600], linha[80], nome[24];
    lista[0] = 0;
    for (new s = 0; s < Vagas[playerid]; s++)
    {
        if (Garagem[playerid][s][F_MODELO] == 0)
            format(linha, sizeof(linha), "%d. (vaga vazia)\n", s + 1);
        else
        {
            NomeModelo(Garagem[playerid][s][F_MODELO], nome, sizeof(nome));
            if (SlotTravado[playerid][s]) format(linha, sizeof(linha), "%d. %s [em aposta]\n", s + 1, nome);
            else format(linha, sizeof(linha), "%d. %s\n", s + 1, nome);
        }
        strcat(lista, linha);
    }
    if (Vagas[playerid] < MAX_SLOTS)
    {
        format(linha, sizeof(linha), "Comprar vaga extra - $%d\n", PRECO_VAGA);
        strcat(lista, linha);
    }
    ShowPlayerDialog(playerid, D_GARAGEM, DIALOG_STYLE_LIST, "Minha garagem", lista, "Escolher", "Fechar");
}

stock MostrarLoja(playerid)
{
    new lista[400], linha[60];
    lista[0] = 0;
    for (new i = 0; i < 7; i++)
    {
        format(linha, sizeof(linha), "%s - $%d\n", LojaNome[i], LojaPreco[i]);
        strcat(lista, linha);
    }
    ShowPlayerDialog(playerid, D_LOJA, DIALOG_STYLE_LIST, "Concessionaria", lista, "Comprar", "Fechar");
}

// ------------------------------------------------------------- entregas
stock CancelarEntrega(playerid)
{
    if (!EntregaAtiva[playerid]) return 0;
    EntregaAtiva[playerid] = false;
    DisablePlayerCheckpoint(playerid);
    return 1;
}

stock IniciarEntrega(playerid)
{
    new Float:x, Float:y, Float:z, Float:dx, Float:dy, Float:dist = 0.0, d = 0, msg[128];
    GetPlayerPos(playerid, x, y, z);
    for (new t = 0; t < 12; t++)
    {
        d = random(6);
        dx = EntregaPos[d][0] - x;
        dy = EntregaPos[d][1] - y;
        dist = floatsqroot(dx * dx + dy * dy);
        if (dist >= 400.0) break;
    }
    EntregaAtiva[playerid] = true;
    EntregaPremio[playerid] = 2500 + floatround(dist * 1.2);
    SetPlayerCheckpoint(playerid, EntregaPos[d][0], EntregaPos[d][1], EntregaPos[d][2], 8.0);
    format(msg, sizeof(msg), "Entrega: va ate %s. Pagamento: $%d", EntregaNome[d], EntregaPremio[playerid]);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if (!EntregaAtiva[playerid]) return 1;
    if (!IsPlayerInAnyVehicle(playerid))
    {
        SendClientMessage(playerid, 0xFF0000FF, "Voce precisa chegar de carro!");
        return 1;
    }
    new msg[80];
    EntregaAtiva[playerid] = false;
    DisablePlayerCheckpoint(playerid);
    GivePlayerMoney(playerid, EntregaPremio[playerid]);
    SalvarConta(playerid);
    format(msg, sizeof(msg), "Entrega concluida! Voce recebeu $%d", EntregaPremio[playerid]);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}

// ------------------------------------------------------------- duelo
stock ChecarDuelo(a, b)
{
    if (!IsPlayerConnected(a) || !IsPlayerConnected(b) || a == b) { format(ErroDuelo, sizeof(ErroDuelo), "Jogador invalido."); return 0; }
    if (!Logado[a] || !Logado[b]) { format(ErroDuelo, sizeof(ErroDuelo), "Os dois precisam estar logados."); return 0; }
    if (CorridaAberta || CorridaRodando || ModoDuelo || DueloAtivo) { format(ErroDuelo, sizeof(ErroDuelo), "Ja existe corrida em andamento."); return 0; }
    if (TotalCP < 3) { format(ErroDuelo, sizeof(ErroDuelo), "Pista nao configurada."); return 0; }
    if (NaCorrida[a] || NaCorrida[b]) { format(ErroDuelo, sizeof(ErroDuelo), "Os dois precisam estar fora de corridas."); return 0; }
    if (!NoCarroPessoal(a) || !NoCarroPessoal(b) || SlotAtivo[a] < 0 || SlotAtivo[b] < 0) { format(ErroDuelo, sizeof(ErroDuelo), "Os dois dentro do carro da garagem."); return 0; }
    new sa = SlotAtivo[a], sb = SlotAtivo[b];
    if (SlotTravado[a][sa] || SlotTravado[b][sb]) { format(ErroDuelo, sizeof(ErroDuelo), "Um dos carros ja esta em aposta."); return 0; }
    if (SlotLivre(a) == -1 || SlotLivre(b) == -1) { format(ErroDuelo, sizeof(ErroDuelo), "Os dois precisam ter 1 vaga livre."); return 0; }
    new pa = PrecoModelo(Garagem[a][sa][F_MODELO]);
    new pb = PrecoModelo(Garagem[b][sb][F_MODELO]);
    if (pa <= 0 || pb <= 0) { format(ErroDuelo, sizeof(ErroDuelo), "Esse carro nao pode ser apostado."); return 0; }
    if ((pa > pb && pa * 100 > pb * DIF_MAX_DUELO) || (pb > pa && pb * 100 > pa * DIF_MAX_DUELO))
    { format(ErroDuelo, sizeof(ErroDuelo), "Valores muito diferentes (max 50%%)."); return 0; }
    return 1;
}

stock CancelarDuelo()
{
    if (!DueloAtivo) return 0;
    DueloAtivo = false;
    KillTimer(DueloTimerID);
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i)) continue;
        for (new s = 0; s < MAX_SLOTS; s++) SlotTravado[i][s] = false;
    }
    SendClientMessageToAll(0xFFFF00FF, "A aposta de carros foi cancelada.");
    return 1;
}

stock ResolverDuelo(vencedor, perdedor)
{
    if (!DueloAtivo) return 0;
    DueloAtivo = false;
    KillTimer(DueloTimerID);
    new sv = SlotCorrida[vencedor], sp = SlotCorrida[perdedor];
    if (sv >= 0) SlotTravado[vencedor][sv] = false;
    if (sp >= 0) SlotTravado[perdedor][sp] = false;
    if (sp < 0 || Garagem[perdedor][sp][F_MODELO] == 0) { SendClientMessageToAll(0xFF0000FF, "Aposta anulada."); return 0; }
    new livre = SlotLivre(vencedor);
    if (livre == -1) { SendClientMessageToAll(0xFF0000FF, "Garagem do vencedor cheia. Aposta anulada."); return 0; }
    new nomeCarro[24], nv[MAX_PLAYER_NAME], np[MAX_PLAYER_NAME], msg[160];
    NomeModelo(Garagem[perdedor][sp][F_MODELO], nomeCarro, sizeof(nomeCarro));
    GetPlayerName(vencedor, nv, sizeof(nv));
    GetPlayerName(perdedor, np, sizeof(np));
    for (new k = 0; k < N_CAMPOS; k++) Garagem[vencedor][livre][k] = Garagem[perdedor][sp][k];
    LimparSlot(perdedor, sp);
    if (SlotAtivo[perdedor] == sp) SlotAtivo[perdedor] = -1;
    SalvarConta(vencedor);
    SalvarConta(perdedor);
    format(msg, sizeof(msg), "%s venceu a aposta e ficou com o %s de %s!", nv, nomeCarro, np);
    SendClientMessageToAll(0xFFFF00FF, msg);
    return 1;
}

public DueloTimeout() { if (!DueloAtivo) return 1; CancelarDuelo(); AgendarReset(500); return 1; }

stock IniciarDuelo(a, b)
{
    new sa = SlotAtivo[a], sb = SlotAtivo[b], na[MAX_PLAYER_NAME], nb[MAX_PLAYER_NAME], msg[160];
    DueloAtivo = true;
    ModoDuelo = true;
    DueloP1 = a;
    DueloP2 = b;
    ValorAposta = 0;
    PotAposta = 0;
    SlotTravado[a][sa] = true;
    SlotTravado[b][sb] = true;
    CorridaAberta = true;
    EntrarNaCorrida(a, 8);
    EntrarNaCorrida(b, 8);
    GetPlayerName(a, na, sizeof(na));
    GetPlayerName(b, nb, sizeof(nb));
    format(msg, sizeof(msg), "APOSTA DE CARROS: %s x %s! Quem perder entrega o carro! Largada em 5s!", na, nb);
    SendClientMessageToAll(0xFF8800FF, msg);
    SetTimer("IniciarContagem", 5000, false);
    DueloTimerID = SetTimer("DueloTimeout", TEMPO_DUELO, false);
    return 1;
}

// ------------------------------------------------------------- corrida
stock AgendarReset(tempo)
{
    if (ResetAgendado) return 0;
    ResetAgendado = true;
    SetTimer("ResetarCorrida", tempo, false);
    return 1;
}

stock EntrarNaCorrida(playerid, escolha)
{
    new slot = -1, modelo = 0;
    if (escolha == 8)
    {
        slot = SlotAtivo[playerid];
        if (slot < 0 || Garagem[playerid][slot][F_MODELO] == 0)
        {
            SendClientMessage(playerid, 0xFF0000FF, "Chame seu carro em /garagem primeiro.");
            return 0;
        }
    }
    else return 0;

    CancelarEntrega(playerid);
    GetPlayerPos(playerid, PosAntes[playerid][0], PosAntes[playerid][1], PosAntes[playerid][2]);
    NaCorrida[playerid] = true;
    SlotCorrida[playerid] = slot;
    PlayerCP[playerid] = 1;
    Participantes++;
    new idx = Participantes - 1;
    new Float:dx = CPs[1][0] - CPs[0][0];
    new Float:dy = CPs[1][1] - CPs[0][1];
    new Float:dist = floatsqroot(dx * dx + dy * dy);
    if (dist < 1.0) dist = 1.0;
    new Float:fx = dx / dist;
    new Float:fy = dy / dist;
    new Float:ang = Atan2Graus(-fx, fy);
    new Float:atras = float(idx / 2) * 8.0;
    new Float:lado = float(idx % 2) * 4.0 - 2.0;
    new Float:px = CPs[0][0] - fx * atras - fy * lado;
    new Float:py = CPs[0][1] - fy * atras + fx * lado;
    if (CarroPessoal[playerid] != INVALID_VEHICLE_ID)
    {
        DestruirVeiculo(CarroPessoal[playerid]);
        CarroPessoal[playerid] = INVALID_VEHICLE_ID;
    }
    Veiculo[playerid] = CriarVeiculoSlot(playerid, slot, px, py, CPs[0][2] + 1.0, ang);
    SlotAtivo[playerid] = slot;
    PutPlayerInVehicle(playerid, Veiculo[playerid], 0);
    return 1;
}

public IniciarContagem()
{
    new minimo = MIN_JOGADORES;
    if (ValorAposta > 0 || ModoDuelo || ModoRanqueada) minimo = 2;
    if (Participantes < minimo)
    {
        SendClientMessageToAll(0xFF0000FF, "Corrida cancelada: poucos jogadores.");
        if (ValorAposta > 0)
        {
            for (new i = 0; i < MAX_PLAYERS; i++)
            {
                if (!IsPlayerConnected(i) || !NaCorrida[i]) continue;
                GivePlayerMoney(i, ValorAposta);
                SalvarConta(i);
            }
        }
        if (DueloAtivo) CancelarDuelo();
        ResetarCorrida();
        return 1;
    }
    CorridaRodando = true;
    Contagem = 3;
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && NaCorrida[i])
        {
            TogglePlayerControllable(i, 0);
            TempoInicio[i] = gettime();
        }
    }
    TimerContagemID = SetTimer("Contar", 1000, true);
    return 1;
}

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
            TempoInicio[i] = gettime();
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
        new nome[MAX_PLAYER_NAME], msg[160], premio = 0, tempo = 0;
        GetPlayerName(playerid, nome, sizeof(nome));
        NaCorrida[playerid] = false;
        tempo = gettime() - TempoInicio[playerid];

        if (ModoTempo)
        {
            new bonus = 0;
            if (tempo < 300) bonus = 200000;
            else if (tempo < 600) bonus = 100000;
            else bonus = 50000;
            format(msg, sizeof(msg), "[TEMPO] %s completou em %d segundos! Premio: $%d", nome, tempo, bonus);
            SendClientMessageToAll(0xFFFF00FF, msg);
            GivePlayerMoney(playerid, bonus);
            RankPontos[playerid] += 1;
            SalvarConta(playerid);
            AgendarReset(3000);
            return 1;
        }

        if (ModoDuelo)
        {
            if (DueloAtivo)
            {
                format(msg, sizeof(msg), "%s cruzou a chegada primeiro!", nome);
                SendClientMessageToAll(0xFFFF00FF, msg);
                new perdedor = DueloP2;
                if (playerid == DueloP2) perdedor = DueloP1;
                ResolverDuelo(playerid, perdedor);
            }
            AgendarReset(5000);
            return 1;
        }

        if (ModoRanqueada)
        {
            if (Chegaram == 1)
            {
                premio = 50000 + (RankPontos[playerid] * 1000);
                RankPontos[playerid] += 5;
            }
            else if (Chegaram == 2) { premio = 20000; RankPontos[playerid] += 3; }
            else { premio = 8000; RankPontos[playerid] += 1; }
            GivePlayerMoney(playerid, premio);
            SalvarConta(playerid);
            format(msg, sizeof(msg), "[RANQUEADA] %d lugar: %s! +$%d | Pontos: %d (%s)", Chegaram, nome, premio, RankPontos[playerid], RankNome[RankDoJogador(playerid)]);
            SendClientMessageToAll(0x00FFFFFF, msg);
            if (Chegaram >= Participantes) AgendarReset(5000);
            return 1;
        }

        // corrida normal com aposta
        if (ValorAposta > 0)
        {
            if (Chegaram == 1) premio = PotAposta - (PotAposta * TAXA_APOSTA / 100);
        }
        else premio = 20000 / Chegaram;

        if (premio > 0)
        {
            format(msg, sizeof(msg), "%d lugar: %s! Premio: $%d", Chegaram, nome, premio);
            GivePlayerMoney(playerid, premio);
            SalvarConta(playerid);
        }
        else format(msg, sizeof(msg), "%d lugar: %s!", Chegaram, nome);
        SendClientMessageToAll(0xFFFF00FF, msg);
        if (Chegaram >= Participantes) AgendarReset(5000);
        return 1;
    }
    MostrarCP(playerid);
    return 1;
}

stock SairCorrida(playerid, voltar)
{
    if (!NaCorrida[playerid]) return 0;
    if (ModoDuelo && DueloAtivo)
    {
        new outro = DueloP2;
        if (playerid == DueloP2) outro = DueloP1;
        if (CorridaRodando) { ResolverDuelo(outro, playerid); AgendarReset(4000); }
        else CancelarDuelo();
    }
    else if (!CorridaRodando && ValorAposta > 0)
    {
        GivePlayerMoney(playerid, ValorAposta);
        PotAposta -= ValorAposta;
        if (PotAposta < 0) PotAposta = 0;
        SalvarConta(playerid);
    }
    NaCorrida[playerid] = false;
    DisablePlayerRaceCheckpoint(playerid);
    TogglePlayerControllable(playerid, 1);
    if (Veiculo[playerid] != INVALID_VEHICLE_ID)
    {
        DestruirVeiculo(Veiculo[playerid]);
        Veiculo[playerid] = INVALID_VEHICLE_ID;
    }
    if (voltar) SetPlayerPos(playerid, PosAntes[playerid][0], PosAntes[playerid][1], PosAntes[playerid][2]);
    Participantes--;
    if (Participantes < 0) Participantes = 0;
    if (CorridaRodando && Chegaram >= Participantes) AgendarReset(3000);
    return 1;
}

public ResetarCorrida()
{
    ResetAgendado = false;
    if (DueloAtivo) CancelarDuelo();
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
            DestruirVeiculo(Veiculo[i]);
            Veiculo[i] = INVALID_VEHICLE_ID;
            SetPlayerPos(i, PosAntes[i][0], PosAntes[i][1], PosAntes[i][2]);
        }
        SlotCorrida[i] = -1;
    }
    CorridaAberta = false;
    CorridaRodando = false;
    ModoDuelo = false;
    ModoRanqueada = false;
    ModoTempo = false;
    Participantes = 0;
    Chegaram = 0;
    ValorAposta = 0;
    PotAposta = 0;
    return 1;
}

// ------------------------------------------------------------- comandos
public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!Logado[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "Faca login primeiro!");
        return 1;
    }

    if (!strcmp(cmdtext, "/ajuda", true))
    {
        SendClientMessage(playerid, 0xFFFF00FF, "=== Street Racing ===");
        SendClientMessage(playerid, 0xFFFF00FF, "/corrida - corrida normal | /ranqueada - corrida com ranking");
        SendClientMessage(playerid, 0xFFFF00FF, "/tempo - corrida contra o tempo | /sair - sair");
        SendClientMessage(playerid, 0xFFFF00FF, "/loja - comprar carro | /garagem - seus carros | /guardar");
        SendClientMessage(playerid, 0xFFFF00FF, "/tuning - modificar | /apostacarro [id] - apostar carro");
        SendClientMessage(playerid, 0xFFFF00FF, "/entrega - ganhar dinheiro | /cancelarentrega | /pos");
        SendClientMessage(playerid, 0xFFFF00FF, "/rank - ver seu rank | /pistas - trocar de pista");
        return 1;
    }

    if (!strcmp(cmdtext, "/rank", true))
    {
        new msg[128];
        new r = RankDoJogador(playerid);
        format(msg, sizeof(msg), "Seu rank: %s (%d pontos) | Vitorias para o proximo nivel: %d",
            RankNome[r], RankPontos[playerid], (r==0 ? 10-RankPontos[playerid] : (r==1 ? 25-RankPontos[playerid] : 0)));
        return SendClientMessage(playerid, 0x00FF00FF, msg);
    }

    if (!strcmp(cmdtext, "/pistas", true))
    {
        new lista[300], linha[64];
        lista[0] = 0;
        for (new i = 0; i < NUM_PISTAS; i++)
        {
            format(linha, sizeof(linha), "%s\n", PistaNome[i]);
            strcat(lista, linha);
        }
        ShowPlayerDialog(playerid, D_PISTA_MENU, DIALOG_STYLE_LIST, "Escolha a pista", lista, "Selecionar", "Fechar");
        return 1;
    }

    if (!strcmp(cmdtext, "/corrida", true))
    {
        if (CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Corrida em andamento.");
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Voce ja esta na corrida.");
        if (TotalCP < 3) return SendClientMessage(playerid, 0xFF0000FF, "Pista nao configurada.");
        ShowPlayerDialog(playerid, D_MODO_CORRIDA, DIALOG_STYLE_LIST, "Modo de corrida",
            "Corrida amistosa (aposta opcional)\nCorrida ranqueada (min. 2 jogadores, sobe rank)\nCorrida contra o tempo (solo)",
            "Escolher", "Fechar");
        return 1;
    }

    if (!strcmp(cmdtext, "/ranqueada", true))
    {
        if (CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Corrida em andamento.");
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Voce ja esta na corrida.");
        if (TotalCP < 3) return SendClientMessage(playerid, 0xFF0000FF, "Pista nao configurada.");
        if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem (/garagem).");
        ModoRanqueada = true;
        CorridaAberta = true;
        EntrarNaCorrida(playerid, 8);
        SetTimer("IniciarContagem", TEMPO_ABERTURA, false);
        SendClientMessageToAll(0x00FFFFFF, "Corrida RANQUEADA aberta! Min. 2 jogadores. Use /ranqueada para entrar!");
        return 1;
    }

    if (!strcmp(cmdtext, "/tempo", true))
    {
        if (CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Corrida em andamento.");
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Voce ja esta na corrida.");
        if (TotalCP < 3) return SendClientMessage(playerid, 0xFF0000FF, "Pista nao configurada.");
        if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem (/garagem).");
        ModoTempo = true;
        CorridaAberta = true;
        EntrarNaCorrida(playerid, 8);
        IniciarContagem();
        SendClientMessage(playerid, 0x00FF00FF, "Corrida contra o tempo iniciada! Menos de 5min = $200k!");
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
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro.");
        MostrarLoja(playerid);
        return 1;
    }

    if (!strcmp(cmdtext, "/garagem", true) || !strcmp(cmdtext, "/meucarro", true))
    {
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro.");
        MostrarGaragem(playerid);
        return 1;
    }

    if (!strcmp(cmdtext, "/guardar", true))
    {
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro.");
        if (CarroPessoal[playerid] == INVALID_VEHICLE_ID) return SendClientMessage(playerid, 0xFF0000FF, "Voce nao tem carro na rua.");
        DestruirVeiculo(CarroPessoal[playerid]);
        CarroPessoal[playerid] = INVALID_VEHICLE_ID;
        SlotAtivo[playerid] = -1;
        return SendClientMessage(playerid, 0x00FF00FF, "Carro guardado.");
    }

    if (!strcmp(cmdtext, "/tuning", true))
    {
        if (SlotDoTuning(playerid) < 0) return 1;
        ShowPlayerDialog(playerid, D_TUNING, DIALOG_STYLE_LIST, "Tuning",
            "Nitro\nAerofolio\nRodas\nHidraulica - $20000\nNeon - $25000\nPintura - $5000\nReparar - $2000",
            "Escolher", "Fechar");
        return 1;
    }

    if (!strcmp(cmdtext, "/apostacarro", true, 12) && (cmdtext[12] == ' ' || cmdtext[12] == 0))
    {
        if (cmdtext[12] == 0) return SendClientMessage(playerid, 0xFFFF00FF, "Use: /apostacarro [id]");
        new alvo = strval(cmdtext[13]);
        if (!ChecarDuelo(playerid, alvo)) return SendClientMessage(playerid, 0xFF0000FF, ErroDuelo);
        new meu[24], dele[24], nalvo[MAX_PLAYER_NAME], texto[400];
        NomeModelo(Garagem[playerid][SlotAtivo[playerid]][F_MODELO], meu, sizeof(meu));
        NomeModelo(Garagem[alvo][SlotAtivo[alvo]][F_MODELO], dele, sizeof(dele));
        GetPlayerName(alvo, nalvo, sizeof(nalvo));
        format(texto, sizeof(texto), "Voce vai apostar seu %s contra o %s de %s.\nQuem perder entrega o carro!\n\nConfirmar?", meu, dele, nalvo);
        DesafioAlvo[playerid] = alvo;
        ShowPlayerDialog(playerid, D_DUELO_CONF, DIALOG_STYLE_MSGBOX, "Aposta de carro", texto, "Desafiar", "Cancelar");
        return 1;
    }

    if (!strcmp(cmdtext, "/entrega", true))
    {
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro.");
        if (EntregaAtiva[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Ja tem entrega ativa. Use /cancelarentrega.");
        if (!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre em um carro.");
        IniciarEntrega(playerid);
        return 1;
    }

    if (!strcmp(cmdtext, "/cancelarentrega", true))
    {
        if (!CancelarEntrega(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Voce nao tem entrega.");
        return SendClientMessage(playerid, 0xFFFF00FF, "Entrega cancelada.");
    }

    if (!strcmp(cmdtext, "/pos", true))
    {
        new Float:x, Float:y, Float:z, msg[96];
        GetPlayerPos(playerid, x, y, z);
        format(msg, sizeof(msg), "Pos: %.1f, %.1f, %.1f", x, y, z);
        return SendClientMessage(playerid, 0xFFFFFFFF, msg);
    }

    // --- ADMIN ---
    if (!strcmp(cmdtext, "/dinheiro", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        DefinirDinheiro(playerid, DINHEIRO_ADM);
        return SendClientMessage(playerid, 0x00FF00FF, "Dinheiro adicionado!");
    }

    if (!strcmp(cmdtext, "/dinheiroinf", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        DinheiroInf[playerid] = !DinheiroInf[playerid];
        return SendClientMessage(playerid, 0x00FF00FF, DinheiroInf[playerid] ? "Infinito LIGADO" : "Infinito DESLIGADO");
    }

    if (!strcmp(cmdtext, "/elegyadm", true))
    {
        if (!IsPlayerAdmin(playerid)) return 0;
        new slot = SlotLivre(playerid);
        if (slot == -1) return SendClientMessage(playerid, 0xFF0000FF, "Garagem cheia.");
        NovoCarroSlot(playerid, slot, 562);
        SalvarConta(playerid);
        SpawnarCarroPessoal(playerid, slot);
        return SendClientMessage(playerid, 0x00FF00FF, "Elegy exclusivo ADM entregue!");
    }

    if (!strcmp(cmdtext, "/addcp", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        if (PistaAtual != 0) return SendClientMessage(playerid, 0xFF0000FF, "Troque para a pista ADM (/pistas).");
        if (TotalCP >= MAX_CP) return SendClientMessage(playerid, 0xFF0000FF, "Limite atingido.");
        new Float:x, Float:y, Float:z, msg[96];
        GetPlayerPos(playerid, x, y, z);
        CPs[TotalCP][0] = x;
        CPs[TotalCP][1] = y;
        CPs[TotalCP][2] = z;
        TotalCP++;
        SalvarPista();
        format(msg, sizeof(msg), "Ponto %d salvo.", TotalCP - 1);
        return SendClientMessage(playerid, 0x00FF00FF, msg);
    }

    if (!strcmp(cmdtext, "/desfazercp", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        if (TotalCP > 0) TotalCP--;
        SalvarPista();
        return SendClientMessage(playerid, 0xFFFF00FF, "Ultimo ponto removido.");
    }

    if (!strcmp(cmdtext, "/limparpista", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        TotalCP = 0;
        SalvarPista();
        return SendClientMessage(playerid, 0xFFFF00FF, "Pista ADM apagada.");
    }

    if (!strcmp(cmdtext, "/pista", true))
    {
        new msg[80];
        format(msg, sizeof(msg), "Pista atual: %s (%d pontos)", PistaNome[PistaAtual], TotalCP);
        return SendClientMessage(playerid, 0xFFFFFFFF, msg);
    }

    if (!strcmp(cmdtext, "/basarabmwgtrsdf", true))
    {
        if (!IsPlayerAdmin(playerid)) return 0;
        if (CarroAdm[playerid] != INVALID_VEHICLE_ID) DestruirVeiculo(CarroAdm[playerid]);
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

// ------------------------------------------------------------- dialogos
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    // ---- LOGIN / REGISTRO ----
    if (dialogid == D_LOGIN)
    {
        if (!response) { Kick(playerid); return 1; }
        new nome[MAX_PLAYER_NAME], arq[80], linha[80];
        GetPlayerName(playerid, nome, sizeof(nome));
        format(arq, sizeof(arq), "conta_%s.txt", nome);
        if (fexist(arq))
        {
            new File:f = fopen(arq, io_read);
            if (f)
            {
                fread(f, linha);
                fclose(f);
                new pos = strfind(linha, " ");
                new senhaSalva = 0;
                if (pos != -1) senhaSalva = strval(linha[pos + 1]);
                if (senhaSalva == 0)
                {
                    // conta antiga sem senha: aceita qualquer uma e define
                    SalvarContaComSenha(playerid, inputtext);
                    Logado[playerid] = true;
                    Carregado[playerid] = true;
                    CarregarConta(playerid);
                    SendClientMessage(playerid, 0x00FF00FF, "Login OK (senha definida).");
                    SpawnPlayer(playerid);
                    return 1;
                }
                if (HashSenha(inputtext) == senhaSalva)
                {
                    Logado[playerid] = true;
                    Carregado[playerid] = true;
                    CarregarConta(playerid);
                    SendClientMessage(playerid, 0x00FF00FF, "Login OK!");
                    SpawnPlayer(playerid);
                    return 1;
                }
            }
        }
        SendClientMessage(playerid, 0xFF0000FF, "Senha errada.");
        ShowPlayerDialog(playerid, D_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Digite a senha:", "Entrar", "Sair");
        return 1;
    }

    if (dialogid == D_REGISTER)
    {
        if (!response) { Kick(playerid); return 1; }
        if (strlen(inputtext) < 3) { SendClientMessage(playerid, 0xFF0000FF, "Senha muito curta (min 3)."); ShowPlayerDialog(playerid, D_REGISTER, DIALOG_STYLE_PASSWORD, "Registro", "Crie uma senha:", "Registrar", "Sair"); return 1; }
        SalvarContaComSenha(playerid, inputtext);
        Logado[playerid] = true;
        Carregado[playerid] = true;
        DefinirDinheiro(playerid, DINHEIRO_INICIAL);
        Vagas[playerid] = VAGAS_INICIAIS;
        RankPontos[playerid] = 0;
        NovoCarroSlot(playerid, 0, 562); // Elegy inicial gratis
        SalvarConta(playerid);
        SendClientMessage(playerid, 0x00FF00FF, "Conta criada! Voce recebeu $1000 e um Elegy gratis!");
        SendClientMessage(playerid, 0xFFFF00FF, "Use /garagem para pegar seu carro e /corrida para competir!");
        SpawnPlayer(playerid);
        return 1;
    }

    if (!Logado[playerid]) return 1;
    if (!response) return 1;

    switch (dialogid)
    {
        case D_PISTA_MENU:
        {
            PistaAtual = listitem;
            CarregarPistaAtual();
            new msg[96];
            format(msg, sizeof(msg), "Pista alterada: %s (%d pontos)", PistaNome[PistaAtual], TotalCP);
            SendClientMessage(playerid, 0x00FF00FF, msg);
        }

        case D_MODO_CORRIDA:
        {
            if (listitem == 0) // amistosa
            {
                if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem (/garagem).");
                EscolhaCarro[playerid] = 8;
                ShowPlayerDialog(playerid, D_APOSTA_VALOR, DIALOG_STYLE_INPUT, "Aposta",
                    "Valor da entrada (0 = corrida gratis):", "Abrir", "Cancelar");
            }
            else if (listitem == 1) // ranqueada
            {
                if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem (/garagem).");
                if (CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Corrida em andamento.");
                ModoRanqueada = true;
                CorridaAberta = true;
                EntrarNaCorrida(playerid, 8);
                SetTimer("IniciarContagem", TEMPO_ABERTURA, false);
                SendClientMessageToAll(0x00FFFFFF, "Corrida RANQUEADA aberta! Min. 2 jogadores. Use /corrida!");
            }
            else // tempo
            {
                if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem (/garagem).");
                ModoTempo = true;
                CorridaAberta = true;
                EntrarNaCorrida(playerid, 8);
                IniciarContagem();
                SendClientMessage(playerid, 0x00FF00FF, "Corrida contra o tempo! Menos de 5min = $200k.");
            }
        }

        case D_CORRIDA_CARRO:
        {
            if (listitem == 8 && SlotAtivo[playerid] < 0) return SendClientMessage(playerid, 0xFF0000FF, "Chame seu carro em /garagem primeiro.");
            if (CorridaAberta)
            {
                if (ValorAposta > 0)
                {
                    if (!Cobrar(playerid, ValorAposta)) return 1;
                    PotAposta += ValorAposta;
                }
                EntrarNaCorrida(playerid, listitem);
                return 1;
            }
            EscolhaCarro[playerid] = listitem;
            ShowPlayerDialog(playerid, D_APOSTA_VALOR, DIALOG_STYLE_INPUT, "Aposta",
                "Digite o valor (0 = gratis):", "Abrir", "Cancelar");
        }

        case D_APOSTA_VALOR:
        {
            if (CorridaAberta || CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Ja existe corrida aberta.");
            if (NaCorrida[playerid]) return 1;
            new valor = strval(inputtext), msg[160];
            if (valor < 0) valor = 0;
            if (valor > MAX_APOSTA) { format(msg, sizeof(msg), "Max: $%d", MAX_APOSTA); return SendClientMessage(playerid, 0xFF0000FF, msg); }
            if (EscolhaCarro[playerid] != 8) return SendClientMessage(playerid, 0xFF0000FF, "Somente carro proprio!");
            if (valor > 0) { if (!Cobrar(playerid, valor)) return 1; }
            ValorAposta = valor;
            PotAposta = valor;
            CorridaAberta = true;
            EntrarNaCorrida(playerid, 8);
            SetTimer("IniciarContagem", TEMPO_ABERTURA, false);
            if (valor > 0)
            {
                format(msg, sizeof(msg), "Corrida com APOSTA! Entrada: $%d. Use /corrida!", valor);
                SendClientMessageToAll(0x00FF00FF, msg);
            }
            else SendClientMessageToAll(0x00FF00FF, "Corrida aberta! Use /corrida!");
        }

        case D_LOJA:
        {
            if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro.");
            if (SlotLivre(playerid) == -1) return SendClientMessage(playerid, 0xFF0000FF, "Garagem cheia.");
            ConfirmTipo[playerid] = 1;
            ConfirmData[playerid] = listitem;
            ConfirmPreco[playerid] = LojaPreco[listitem];
            new texto[180];
            format(texto, sizeof(texto), "Comprar %s por $%d?\n\nSaldo atual: $%d", LojaNome[listitem], LojaPreco[listitem], GetPlayerMoney(playerid));
            ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar compra", texto, "Comprar", "Cancelar");
        }

        case D_GARAGEM:
        {
            if (listitem < Vagas[playerid])
            {
                if (Garagem[playerid][listitem][F_MODELO] == 0) return SendClientMessage(playerid, 0xFF0000FF, "Vaga vazia.");
                SlotSel[playerid] = listitem;
                ShowPlayerDialog(playerid, D_GARAGEM_ACAO, DIALOG_STYLE_LIST, "Carro", "Tirar da garagem\nVender (60% do valor)", "Escolher", "Voltar");
            }
            else if (Vagas[playerid] < MAX_SLOTS)
            {
                ConfirmTipo[playerid] = 2;
                ConfirmData[playerid] = 0;
                ConfirmPreco[playerid] = PRECO_VAGA;
                new texto[160];
                format(texto, sizeof(texto), "Comprar vaga extra por $%d?\nSaldo: $%d", PRECO_VAGA, GetPlayerMoney(playerid));
                ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar compra", texto, "Comprar", "Cancelar");
            }
        }

        case D_GARAGEM_ACAO:
        {
            new s = SlotSel[playerid];
            if (s < 0 || s >= MAX_SLOTS || Garagem[playerid][s][F_MODELO] == 0) return 1;
            if (listitem == 0) SpawnarCarroPessoal(playerid, s);
            else
            {
                if (SlotTravado[playerid][s]) return SendClientMessage(playerid, 0xFF0000FF, "Esse carro esta em aposta.");
                if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro.");
                new preco = PrecoModelo(Garagem[playerid][s][F_MODELO]) * 60 / 100, msg[80];
                if (SlotAtivo[playerid] == s)
                {
                    DestruirVeiculo(CarroPessoal[playerid]);
                    CarroPessoal[playerid] = INVALID_VEHICLE_ID;
                    SlotAtivo[playerid] = -1;
                }
                LimparSlot(playerid, s);
                GivePlayerMoney(playerid, preco);
                SalvarConta(playerid);
                format(msg, sizeof(msg), "Carro vendido por $%d.", preco);
                SendClientMessage(playerid, 0x00FF00FF, msg);
            }
        }

        case D_TUNING:
        {
            if (SlotDoTuning(playerid) < 0) return 1;
            switch (listitem)
            {
                case 0: ShowPlayerDialog(playerid, D_NITRO, DIALOG_STYLE_LIST, "Nitro", "Nitro 2x - $15000\nNitro 5x - $30000\nNitro 10x - $50000", "Comprar", "Voltar");
                case 1:
                {
                    new lista[800], linha[60];
                    lista[0] = 0;
                    for (new i = 0; i < 20; i++) { format(linha, sizeof(linha), "%s - $%d\n", AeroNome[i], AeroPreco[i]); strcat(lista, linha); }
                    ShowPlayerDialog(playerid, D_AERO, DIALOG_STYLE_LIST, "Aerofolio", lista, "Comprar", "Voltar");
                }
                case 2:
                {
                    new lista[200], linha[48];
                    lista[0] = 0;
                    for (new i = 0; i < 6; i++) { format(linha, sizeof(linha), "%s - $%d\n", RodaNome[i], RodaPreco[i]); strcat(lista, linha); }
                    ShowPlayerDialog(playerid, D_RODAS, DIALOG_STYLE_LIST, "Rodas", lista, "Comprar", "Voltar");
                }
                case 3:
                {
                    if (Garagem[playerid][SlotAtivo[playerid]][F_HID] > 0) SendClientMessage(playerid, 0xFF0000FF, "Ja tem hidraulica.");
                    else Instalar(playerid, 1087, CARMODTYPE_HYDRAULICS, 20000, F_HID, "Hidraulica");
                }
                case 4: ShowPlayerDialog(playerid, D_NEON, DIALOG_STYLE_LIST, "Neon - $25000", "Vermelho\nAzul\nVerde\nAmarelo\nRosa\nBranco\nRemover neon (gratis)", "Aplicar", "Voltar");
                case 5: ShowPlayerDialog(playerid, D_COR, DIALOG_STYLE_LIST, "Pintura - $5000", "Preto\nBranco\nVermelho\nAmarelo\nAzul\nAleatorio", "Pintar", "Voltar");
                case 6:
                {
                    if (Cobrar(playerid, 2000)) { RepairVehicle(GetPlayerVehicleID(playerid)); SendClientMessage(playerid, 0x00FF00FF, "Reparado!"); }
                }
            }
        }

        case D_NITRO:
        {
            ConfirmTipo[playerid] = 10;
            ConfirmData[playerid] = listitem;
            ConfirmPreco[playerid] = NitroPreco[listitem];
            new texto[160];
            format(texto, sizeof(texto), "Comprar Nitro por $%d?\nSaldo: $%d", NitroPreco[listitem], GetPlayerMoney(playerid));
            ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar", texto, "Comprar", "Cancelar");
        }

        case D_AERO:
        {
            ConfirmTipo[playerid] = 11;
            ConfirmData[playerid] = listitem;
            ConfirmPreco[playerid] = AeroPreco[listitem];
            new texto[160];
            format(texto, sizeof(texto), "Comprar Aerofolio %s por $%d?\nSaldo: $%d", AeroNome[listitem], AeroPreco[listitem], GetPlayerMoney(playerid));
            ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar", texto, "Comprar", "Cancelar");
        }

        case D_RODAS:
        {
            ConfirmTipo[playerid] = 12;
            ConfirmData[playerid] = listitem;
            ConfirmPreco[playerid] = RodaPreco[listitem];
            new texto[160];
            format(texto, sizeof(texto), "Comprar Rodas %s por $%d?\nSaldo: $%d", RodaNome[listitem], RodaPreco[listitem], GetPlayerMoney(playerid));
            ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar", texto, "Comprar", "Cancelar");
        }

        case D_NEON:
        {
            new s = SlotDoTuning(playerid);
            if (s < 0) return 1;
            if (listitem == 6)
            {
                AplicarNeon(GetPlayerVehicleID(playerid), 0);
                Garagem[playerid][s][F_NEON] = 0;
                SalvarConta(playerid);
                SendClientMessage(playerid, 0xFFFF00FF, "Neon removido.");
            }
            else
            {
                ConfirmTipo[playerid] = 13;
                ConfirmData[playerid] = listitem;
                ConfirmPreco[playerid] = NeonPreco;
                new texto[160];
                format(texto, sizeof(texto), "Comprar Neon %s por $%d?\nSaldo: $%d", NeonNome[listitem], NeonPreco, GetPlayerMoney(playerid));
                ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar", texto, "Comprar", "Cancelar");
            }
        }

        case D_COR:
        {
            ConfirmTipo[playerid] = 14;
            ConfirmData[playerid] = listitem;
            ConfirmPreco[playerid] = 5000;
            new texto[160];
            format(texto, sizeof(texto), "Pintar de %s por $5000?\nSaldo: $%d", CorNome[listitem], GetPlayerMoney(playerid));
            ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar", texto, "Pintar", "Cancelar");
        }

        case D_CONFIRM:
        {
            // se recusou, nao faz nada
            new t = ConfirmTipo[playerid];
            if (t == 1) // carro
            {
                new slot = SlotLivre(playerid);
                if (slot == -1) return SendClientMessage(playerid, 0xFF0000FF, "Garagem cheia.");
                if (!Cobrar(playerid, LojaPreco[ConfirmData[playerid]])) return 1;
                NovoCarroSlot(playerid, slot, LojaModelo[ConfirmData[playerid]]);
                SalvarConta(playerid);
                SendClientMessage(playerid, 0x00FF00FF, "Carro comprado!");
                SpawnarCarroPessoal(playerid, slot);
            }
            else if (t == 2) // vaga
            {
                if (!Cobrar(playerid, PRECO_VAGA)) return 1;
                Vagas[playerid]++;
                SalvarConta(playerid);
                SendClientMessage(playerid, 0x00FF00FF, "Vaga comprada!");
                MostrarGaragem(playerid);
            }
            else if (t == 10) // nitro
            {
                Instalar(playerid, NitroId[ConfirmData[playerid]], CARMODTYPE_NITRO, NitroPreco[ConfirmData[playerid]], F_NITRO, "Nitro");
            }
            else if (t == 11) // aero
            {
                Instalar(playerid, AeroId[ConfirmData[playerid]], CARMODTYPE_SPOILER, AeroPreco[ConfirmData[playerid]], F_AERO, "Aerofolio");
            }
            else if (t == 12) // roda
            {
                Instalar(playerid, RodaId[ConfirmData[playerid]], CARMODTYPE_WHEELS, RodaPreco[ConfirmData[playerid]], F_RODA, "Rodas");
            }
            else if (t == 13) // neon
            {
                new s = SlotDoTuning(playerid);
                if (s < 0) return 1;
                if (Cobrar(playerid, NeonPreco))
                {
                    AplicarNeon(GetPlayerVehicleID(playerid), ConfirmData[playerid] + 1);
                    Garagem[playerid][s][F_NEON] = ConfirmData[playerid] + 1;
                    SalvarConta(playerid);
                    SendClientMessage(playerid, 0x00FF00FF, "Neon instalado!");
                }
            }
            else if (t == 14) // cor
            {
                new s = SlotDoTuning(playerid);
                if (s < 0) return 1;
                if (Cobrar(playerid, 5000))
                {
                    new c = CorId[ConfirmData[playerid]];
                    if (c == -1) c = random(126);
                    ChangeVehicleColor(GetPlayerVehicleID(playerid), c, c);
                    Garagem[playerid][s][F_COR1] = c;
                    Garagem[playerid][s][F_COR2] = c;
                    SalvarConta(playerid);
                    SendClientMessage(playerid, 0x00FF00FF, "Carro pintado!");
                }
            }
            ConfirmTipo[playerid] = 0;
        }

        case D_DUELO_CONF:
        {
            new alvo = DesafioAlvo[playerid];
            if (!ChecarDuelo(playerid, alvo)) return SendClientMessage(playerid, 0xFF0000FF, ErroDuelo);
            new meu[24], dele[24], nome[MAX_PLAYER_NAME], texto[400];
            NomeModelo(Garagem[playerid][SlotAtivo[playerid]][F_MODELO], meu, sizeof(meu));
            NomeModelo(Garagem[alvo][SlotAtivo[alvo]][F_MODELO], dele, sizeof(dele));
            GetPlayerName(playerid, nome, sizeof(nome));
            format(texto, sizeof(texto), "%s te desafia para apostar o CARRO!\n\nCarro dele: %s\nSeu carro: %s\n\nQuem perder entrega o carro. Aceita?", nome, meu, dele);
            DesafioDe[alvo] = playerid;
            ShowPlayerDialog(alvo, D_DUELO, DIALOG_STYLE_MSGBOX, "Aposta de carro", texto, "Aceitar", "Recusar");
            SendClientMessage(playerid, 0xFFFF00FF, "Desafio enviado.");
        }

        case D_DUELO:
        {
            new c = DesafioDe[playerid];
            DesafioDe[playerid] = INVALID_PLAYER_ID;
            if (c == INVALID_PLAYER_ID || !IsPlayerConnected(c) || DesafioAlvo[c] != playerid) return SendClientMessage(playerid, 0xFF0000FF, "Desafio invalido.");
            if (!ChecarDuelo(c, playerid))
            {
                SendClientMessage(c, 0xFF0000FF, ErroDuelo);
                return SendClientMessage(playerid, 0xFF0000FF, ErroDuelo);
            }
            DesafioAlvo[c] = INVALID_PLAYER_ID;
            IniciarDuelo(c, playerid);
        }
    }
    return 1;
}

// ------------------------------------------------------------- admin timers
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

// helper usado no login
stock SalvarContaComSenha(playerid, const senha[])
{
    new nome[MAX_PLAYER_NAME], arq[80], linha[80];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "conta_%s.txt", nome);
    new File:f = fopen(arq, io_write);
    if (f)
    {
        format(linha, sizeof(linha), "%d %d", DINHEIRO_INICIAL, HashSenha(senha));
        fwrite(f, linha);
        fclose(f);
    }
    return 1;
}