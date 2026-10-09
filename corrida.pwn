// Street Racing BR - Mundo aberto + Corrida + Loja + Garagem + Tuning + Apostas (SA-MP 0.3.7)
// Jogador: /ajuda /corrida /sair /loja /garagem (/meucarro) /guardar /tuning /apostacarro /entrega /cancelarentrega /pos
// Admin (RCON): /dinheiro /dinheiroinf /addcp /desfazercp /limparpista /basarabmwgtrsdf (secreto)
#pragma dynamic 16384
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

// ---- garagem
#define MAX_SLOTS        6        // maximo de vagas
#define VAGAS_INICIAIS   2        // vagas gratis
#define PRECO_VAGA       25000    // preco de cada vaga extra
#define N_CAMPOS         8
#define F_MODELO         0
#define F_COR1           1
#define F_COR2           2
#define F_RODA           3
#define F_NITRO          4
#define F_NEON           5
#define F_AERO           6
#define F_HID            7

// ---- economia
#define MAX_APOSTA       200000   // entrada maxima de uma corrida com aposta
#define TAXA_APOSTA      10       // % do pote que some da economia
#define BONUS_DIARIO     5000
#define DIF_MAX_DUELO    120      // 120 = carros podem ter ate 20% de diferenca de valor
#define TEMPO_DUELO      300000   // 5 min: se ninguem chegar, a aposta de carro e cancelada

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
new NitroId[3] = {1009, 1008, 1010};          // 2x, 5x, 10x
new NitroPreco[3] = {1500, 3000, 5000};
new AeroId[20] = {1000, 1001, 1002, 1003, 1014, 1015, 1016, 1023, 1049, 1050, 1058, 1060, 1138, 1139, 1146, 1147, 1158, 1162, 1163, 1164};
new AeroNome[20][10] = {"Pro", "Win", "Drag", "Alpha", "Champ", "Race", "Worx", "Fury", "Alien", "X-Flow", "Alien", "X-Flow", "Alien", "X-Flow", "X-Flow", "Alien", "X-Flow", "Alien", "X-Flow", "Alien"};
new NeonNome[6][10] = {"Vermelho", "Azul", "Verde", "Amarelo", "Rosa", "Branco"};
new NeonObj[MAX_VEHICLES + 1][2];

// Entregas (outra forma de ganhar dinheiro). Ajuste as coordenadas com /pos se quiser.
new Float:EntregaPos[6][3] = {
    {2495.0, -1688.0, 13.5}, {1480.0, -1740.0, 13.5}, {2227.0, -1721.0, 13.5},
    {1685.0, -2330.0, 13.5}, {400.0, -2088.0, 7.8},   {810.0, -1356.0, 13.5}
};
new EntregaNome[6][24] = {"Grove Street", "Centro (Prefeitura)", "Academia Ganton", "Aeroporto", "Pier Santa Maria", "Estacao Market"};

// ---- estado da corrida
new bool:CorridaAberta, bool:CorridaRodando, bool:ModoDuelo, bool:ResetAgendado;
new bool:NaCorrida[MAX_PLAYERS];
new PlayerCP[MAX_PLAYERS], Veiculo[MAX_PLAYERS];
new Float:PosAntes[MAX_PLAYERS][3];
new Participantes, Chegaram, Contagem, TimerContagemID;
new ValorAposta, PotAposta;
new EscolhaCarro[MAX_PLAYERS], SlotCorrida[MAX_PLAYERS];

// ---- aposta de carro (duelo)
new bool:DueloAtivo;
new DueloP1, DueloP2, DueloTimerID;
new DesafioAlvo[MAX_PLAYERS], DesafioDe[MAX_PLAYERS];
new ErroDuelo[96];

// ---- conta / garagem
new bool:Carregado[MAX_PLAYERS];
new bool:DinheiroInf[MAX_PLAYERS];
new Garagem[MAX_PLAYERS][MAX_SLOTS][N_CAMPOS];
new bool:SlotTravado[MAX_PLAYERS][MAX_SLOTS];
new Vagas[MAX_PLAYERS], SlotAtivo[MAX_PLAYERS], SlotSel[MAX_PLAYERS], UltimoBonus[MAX_PLAYERS];
new CarroPessoal[MAX_PLAYERS], CarroAdm[MAX_PLAYERS];

// ---- entregas
new bool:EntregaAtiva[MAX_PLAYERS];
new EntregaPremio[MAX_PLAYERS];

main() {}

// ---------------------------------------------------------------- utilidades
stock LerInts(const linha[], valores[], maximo)
{
    new n = 0, i = 0, len = strlen(linha);
    while (i < len && n < maximo)
    {
        while (i < len && linha[i] == ' ') i++;
        if (i >= len || linha[i] == '\r' || linha[i] == '\n') break;
        valores[n] = strval(linha[i]);
        n++;
        while (i < len && linha[i] != ' ' && linha[i] != '\r' && linha[i] != '\n') i++;
    }
    return n;
}

stock PrecoModelo(modelo)
{
    for (new i = 0; i < 8; i++)
        if (LojaModelo[i] == modelo) return LojaPreco[i];
    return 0;
}

stock NomeModelo(modelo, nome[], tam)
{
    for (new i = 0; i < 8; i++)
    {
        if (LojaModelo[i] == modelo)
        {
            format(nome, tam, "%s", LojaNome[i]);
            return 1;
        }
    }
    format(nome, tam, "Modelo %d", modelo);
    return 0;
}

stock LimparSlot(playerid, slot)
{
    for (new k = 0; k < N_CAMPOS; k++) Garagem[playerid][slot][k] = 0;
    SlotTravado[playerid][slot] = false;
    return 1;
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
    for (new i = 0; i < 2; i++)
    {
        if (NeonObj[v][i] != 0)
        {
            DestroyObject(NeonObj[v][i]);
            NeonObj[v][i] = 0;
        }
    }
    return 1;
}

stock AplicarNeon(v, tipo)
{
    RemoverNeon(v);
    if (tipo < 1 || tipo > 6) return 0;
    new modelo = 18646 + tipo; // 18647 vermelho ... 18652 branco
    NeonObj[v][0] = CreateObject(modelo, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    NeonObj[v][1] = CreateObject(modelo, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    AttachObjectToVehicle(NeonObj[v][0], v, -0.8, 0.0, -0.7, 0.0, 0.0, 0.0);
    AttachObjectToVehicle(NeonObj[v][1], v, 0.8, 0.0, -0.7, 0.0, 0.0, 0.0);
    return 1;
}

stock DestruirVeiculo(v)
{
    if (v < 1 || v > MAX_VEHICLES) return 0;
    RemoverNeon(v);
    DestroyVehicle(v);
    return 1;
}

// Tenta instalar a peca e confere se o carro aceitou (1 = ok, 0 = nao serve nesse carro)
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
forward IniciarContagem();
forward Contar();
forward ResetarCorrida();
forward DueloTimeout();
forward MantemDinheiro();
forward BoostAdm();

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
    EntregaAtiva[playerid] = false;
    Veiculo[playerid] = INVALID_VEHICLE_ID;
    CarroPessoal[playerid] = INVALID_VEHICLE_ID;
    CarroAdm[playerid] = INVALID_VEHICLE_ID;
    SlotAtivo[playerid] = -1;
    SlotSel[playerid] = -1;
    SlotCorrida[playerid] = -1;
    Vagas[playerid] = VAGAS_INICIAIS;
    UltimoBonus[playerid] = 0;
    DesafioAlvo[playerid] = INVALID_PLAYER_ID;
    DesafioDe[playerid] = INVALID_PLAYER_ID;
    for (new s = 0; s < MAX_SLOTS; s++) LimparSlot(playerid, s);
    SendClientMessage(playerid, 0xFFFF00FF, "Bem-vindo ao Street Racing! Digite /ajuda para ver os comandos.");
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
        new dia = gettime() / 86400;
        if (dia > UltimoBonus[playerid])
        {
            new msg[80];
            UltimoBonus[playerid] = dia;
            GivePlayerMoney(playerid, BONUS_DIARIO);
            SalvarConta(playerid);
            format(msg, sizeof(msg), "Bonus diario recebido: $%d! Volte amanha para mais.", BONUS_DIARIO);
            SendClientMessage(playerid, 0x00FF00FF, msg);
        }
    }
    return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
    RemoverNeon(vehicleid);
    return 1;
}

// ---------------------------------------------------------------- conta
stock DefinirDinheiro(playerid, valor)
{
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, valor);
}

stock SalvarGaragem(playerid)
{
    new nome[MAX_PLAYER_NAME], arq[64], linha[80];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "garagem_%s.txt", nome);
    new File:f = fopen(arq, io_write);
    if (!f) return 0;
    format(linha, sizeof(linha), "%d %d\n", Vagas[playerid], UltimoBonus[playerid]);
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

stock CarregarGaragem(playerid, modeloAntigo)
{
    new nome[MAX_PLAYER_NAME], arq[64], linha[128], v[8], n;
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "garagem_%s.txt", nome);
    Vagas[playerid] = VAGAS_INICIAIS;
    UltimoBonus[playerid] = 0;
    for (new s = 0; s < MAX_SLOTS; s++) LimparSlot(playerid, s);
    if (fexist(arq))
    {
        new File:f = fopen(arq, io_read);
        if (f)
        {
            if (fread(f, linha))
            {
                n = LerInts(linha, v, 2);
                if (n >= 1) Vagas[playerid] = v[0];
                if (n >= 2) UltimoBonus[playerid] = v[1];
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
    else if (modeloAntigo >= 400 && modeloAntigo <= 611)
    {
        // conta antiga: o carro unico vira o primeiro carro da garagem
        NovoCarroSlot(playerid, 0, modeloAntigo);
    }
    return 1;
}

stock CarregarConta(playerid)
{
    new nome[MAX_PLAYER_NAME], arq[64], linha[64], din = DINHEIRO_INICIAL, antigo = 0;
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "conta_%s.txt", nome);
    if (fexist(arq))
    {
        new File:f = fopen(arq, io_read);
        if (f)
        {
            fread(f, linha);
            fclose(f);
            din = strval(linha);
            new pos = strfind(linha, " ");
            if (pos != -1) antigo = strval(linha[pos + 1]);
        }
    }
    DefinirDinheiro(playerid, din);
    CarregarGaragem(playerid, antigo);
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
        format(linha, sizeof(linha), "%d 0", GetPlayerMoney(playerid));
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

// ---------------------------------------------------------------- garagem
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

// devolve o slot do carro que esta sendo tunado, ou -1
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
    new msg[64];
    format(msg, sizeof(msg), "%s instalado(a)!", nomeparte);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}

stock MostrarGaragem(playerid)
{
    new lista[400], linha[64], nome[20];
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
    new lista[300], linha[40];
    lista[0] = 0;
    for (new i = 0; i < 8; i++)
    {
        format(linha, sizeof(linha), "%s - $%d\n", LojaNome[i], LojaPreco[i]);
        strcat(lista, linha);
    }
    ShowPlayerDialog(playerid, D_LOJA, DIALOG_STYLE_LIST, "Concessionaria", lista, "Comprar", "Fechar");
}

stock MostrarEscolhaCorrida(playerid)
{
    new lista[220], titulo[48], nome[20];
    if (SlotAtivo[playerid] >= 0 && Garagem[playerid][SlotAtivo[playerid]][F_MODELO] != 0)
    {
        NomeModelo(Garagem[playerid][SlotAtivo[playerid]][F_MODELO], nome, sizeof(nome));
        format(lista, sizeof(lista), "%s\nMeu carro: %s", ListaCorrida, nome);
    }
    else format(lista, sizeof(lista), "%s", ListaCorrida);
    if (CorridaAberta && ValorAposta > 0) format(titulo, sizeof(titulo), "Escolha o carro - Entrada $%d", ValorAposta);
    else format(titulo, sizeof(titulo), "Escolha seu carro");
    ShowPlayerDialog(playerid, D_CORRIDA_CARRO, DIALOG_STYLE_LIST, titulo, lista, "Correr", "Cancelar");
}

// ---------------------------------------------------------------- entregas
stock CancelarEntrega(playerid)
{
    if (!EntregaAtiva[playerid]) return 0;
    EntregaAtiva[playerid] = false;
    DisablePlayerCheckpoint(playerid);
    return 1;
}

stock IniciarEntrega(playerid)
{
    new Float:x, Float:y, Float:z, Float:dx, Float:dy, Float:dist = 0.0, d = 0, msg[96];
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
    EntregaPremio[playerid] = 1500 + floatround(dist * 0.8);
    SetPlayerCheckpoint(playerid, EntregaPos[d][0], EntregaPos[d][1], EntregaPos[d][2], 8.0);
    format(msg, sizeof(msg), "Entrega: va ate %s (marcado no mapa). Pagamento: $%d", EntregaNome[d], EntregaPremio[playerid]);
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
    new msg[64];
    EntregaAtiva[playerid] = false;
    DisablePlayerCheckpoint(playerid);
    GivePlayerMoney(playerid, EntregaPremio[playerid]);
    SalvarConta(playerid);
    format(msg, sizeof(msg), "Entrega concluida! Voce recebeu $%d", EntregaPremio[playerid]);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}

// ---------------------------------------------------------------- aposta de carro (duelo)
stock ChecarDuelo(a, b)
{
    if (!IsPlayerConnected(a) || !IsPlayerConnected(b) || a == b)
    {
        format(ErroDuelo, sizeof(ErroDuelo), "Jogador invalido.");
        return 0;
    }
    if (CorridaAberta || CorridaRodando || ModoDuelo || DueloAtivo)
    {
        format(ErroDuelo, sizeof(ErroDuelo), "Ja existe uma corrida em andamento. Aguarde.");
        return 0;
    }
    if (TotalCP < 3)
    {
        format(ErroDuelo, sizeof(ErroDuelo), "Pista nao configurada.");
        return 0;
    }
    if (NaCorrida[a] || NaCorrida[b])
    {
        format(ErroDuelo, sizeof(ErroDuelo), "Os dois jogadores precisam estar fora de corridas.");
        return 0;
    }
    if (!NoCarroPessoal(a) || !NoCarroPessoal(b) || SlotAtivo[a] < 0 || SlotAtivo[b] < 0)
    {
        format(ErroDuelo, sizeof(ErroDuelo), "Os dois precisam estar dentro do carro da garagem (/garagem).");
        return 0;
    }
    new sa = SlotAtivo[a], sb = SlotAtivo[b];
    if (SlotTravado[a][sa] || SlotTravado[b][sb])
    {
        format(ErroDuelo, sizeof(ErroDuelo), "Um dos carros ja esta em uma aposta.");
        return 0;
    }
    if (SlotLivre(a) == -1 || SlotLivre(b) == -1)
    {
        format(ErroDuelo, sizeof(ErroDuelo), "Os dois precisam ter ao menos 1 vaga livre na garagem.");
        return 0;
    }
    new pa = PrecoModelo(Garagem[a][sa][F_MODELO]);
    new pb = PrecoModelo(Garagem[b][sb][F_MODELO]);
    if (pa <= 0 || pb <= 0)
    {
        format(ErroDuelo, sizeof(ErroDuelo), "Esse carro nao pode ser apostado.");
        return 0;
    }
    if ((pa > pb && pa * 100 > pb * DIF_MAX_DUELO) || (pb > pa && pb * 100 > pa * DIF_MAX_DUELO))
    {
        format(ErroDuelo, sizeof(ErroDuelo), "Os carros tem valores muito diferentes (maximo 20%% de diferenca).");
        return 0;
    }
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
    SendClientMessageToAll(0xFFFF00FF, "A aposta de carros foi cancelada. Ninguem perdeu o carro.");
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
    if (sp < 0 || Garagem[perdedor][sp][F_MODELO] == 0)
    {
        SendClientMessageToAll(0xFF0000FF, "Aposta de carros anulada (carro nao encontrado).");
        return 0;
    }
    new livre = SlotLivre(vencedor);
    if (livre == -1)
    {
        SendClientMessageToAll(0xFF0000FF, "Aposta de carros anulada: garagem do vencedor cheia.");
        return 0;
    }
    new nomeCarro[20], nv[MAX_PLAYER_NAME], np[MAX_PLAYER_NAME], msg[128];
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

public DueloTimeout()
{
    if (!DueloAtivo) return 1;
    CancelarDuelo();
    AgendarReset(500);
    return 1;
}

stock IniciarDuelo(a, b)
{
    new sa = SlotAtivo[a], sb = SlotAtivo[b], na[MAX_PLAYER_NAME], nb[MAX_PLAYER_NAME], msg[128];
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
    format(msg, sizeof(msg), "APOSTA DE CARROS: %s x %s! Quem perder entrega o carro. Largada em 5 segundos!", na, nb);
    SendClientMessageToAll(0xFF8800FF, msg);
    SetTimer("IniciarContagem", 5000, false);
    DueloTimerID = SetTimer("DueloTimeout", TEMPO_DUELO, false);
    return 1;
}

// ---------------------------------------------------------------- comandos
public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!strcmp(cmdtext, "/ajuda", true))
    {
        SendClientMessage(playerid, 0xFFFF00FF, "/corrida - abrir/entrar em corrida (com aposta opcional) | /sair - sair da corrida");
        SendClientMessage(playerid, 0xFFFF00FF, "/loja - comprar carro | /garagem - seus carros | /guardar - guardar o carro | /tuning - modificar");
        SendClientMessage(playerid, 0xFFFF00FF, "/apostacarro [id] - apostar seu carro contra outro jogador | /entrega - ganhar dinheiro | /cancelarentrega");
        return 1;
    }
    if (!strcmp(cmdtext, "/corrida", true))
    {
        if (CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Corrida em andamento. Aguarde.");
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Voce ja esta na corrida.");
        if (TotalCP < 3) return SendClientMessage(playerid, 0xFF0000FF, "Pista nao configurada. O ADM precisa usar /addcp.");
        MostrarEscolhaCorrida(playerid);
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
    if (!strcmp(cmdtext, "/garagem", true) || !strcmp(cmdtext, "/meucarro", true))
    {
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro (/sair).");
        MostrarGaragem(playerid);
        return 1;
    }
    if (!strcmp(cmdtext, "/guardar", true))
    {
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro (/sair).");
        if (CarroPessoal[playerid] == INVALID_VEHICLE_ID) return SendClientMessage(playerid, 0xFF0000FF, "Voce nao tem carro na rua.");
        DestruirVeiculo(CarroPessoal[playerid]);
        CarroPessoal[playerid] = INVALID_VEHICLE_ID;
        SlotAtivo[playerid] = -1;
        return SendClientMessage(playerid, 0x00FF00FF, "Carro guardado na garagem.");
    }
    if (!strcmp(cmdtext, "/tuning", true))
    {
        if (SlotDoTuning(playerid) < 0) return 1;
        ShowPlayerDialog(playerid, D_TUNING, DIALOG_STYLE_LIST, "Tuning",
            "Nitro\nAerofolio - $2500\nRodas - $1500\nHidraulica - $3000\nNeon - $4000\nPintura - $800\nReparar - $500", "Escolher", "Fechar");
        return 1;
    }
    if (!strcmp(cmdtext, "/apostacarro", true, 12) && (cmdtext[12] == ' ' || cmdtext[12] == 0))
    {
        if (cmdtext[12] == 0) return SendClientMessage(playerid, 0xFFFF00FF, "Use: /apostacarro [id do jogador] (os dois dentro dos carros da garagem)");
        new alvo = strval(cmdtext[13]);
        if (!ChecarDuelo(playerid, alvo)) return SendClientMessage(playerid, 0xFF0000FF, ErroDuelo);
        new meu[20], dele[20], nalvo[MAX_PLAYER_NAME], texto[300];
        NomeModelo(Garagem[playerid][SlotAtivo[playerid]][F_MODELO], meu, sizeof(meu));
        NomeModelo(Garagem[alvo][SlotAtivo[alvo]][F_MODELO], dele, sizeof(dele));
        GetPlayerName(alvo, nalvo, sizeof(nalvo));
        format(texto, sizeof(texto), "Voce vai apostar seu %s contra o %s de %s.\nQuem perder entrega o carro (com todo o tuning) ao vencedor!\n\nConfirmar desafio?", meu, dele, nalvo);
        DesafioAlvo[playerid] = alvo;
        ShowPlayerDialog(playerid, D_DUELO_CONF, DIALOG_STYLE_MSGBOX, "Aposta de carro", texto, "Desafiar", "Cancelar");
        return 1;
    }
    if (!strcmp(cmdtext, "/entrega", true))
    {
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro (/sair).");
        if (EntregaAtiva[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Voce ja tem uma entrega. Use /cancelarentrega para cancelar.");
        if (!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre em um carro para fazer entregas.");
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

// ---------------------------------------------------------------- dialogos
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (dialogid == D_DUELO && !response)
    {
        new c = DesafioDe[playerid];
        DesafioDe[playerid] = INVALID_PLAYER_ID;
        if (c != INVALID_PLAYER_ID && IsPlayerConnected(c)) SendClientMessage(c, 0xFF0000FF, "Seu desafio foi recusado.");
        return 1;
    }
    if (!response) return 1;
    switch (dialogid)
    {
        case D_CORRIDA_CARRO:
        {
            if (CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "A corrida ja comecou. Aguarde a proxima.");
            if (NaCorrida[playerid]) return 1;
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
            ShowPlayerDialog(playerid, D_APOSTA_VALOR, DIALOG_STYLE_INPUT, "Aposta em dinheiro",
                "Digite o valor da entrada da corrida.\nTodos pagam o mesmo valor e o vencedor leva o pote (menos 10% de taxa).\nDigite 0 para corrida gratis:", "Abrir", "Cancelar");
        }
        case D_APOSTA_VALOR:
        {
            if (CorridaAberta || CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Ja existe uma corrida aberta. Use /corrida.");
            if (NaCorrida[playerid]) return 1;
            new valor = strval(inputtext), msg[160];
            if (valor < 0) valor = 0;
            if (valor > MAX_APOSTA)
            {
                format(msg, sizeof(msg), "A entrada maxima e $%d.", MAX_APOSTA);
                return SendClientMessage(playerid, 0xFF0000FF, msg);
            }
            if (EscolhaCarro[playerid] == 8 && SlotAtivo[playerid] < 0) return SendClientMessage(playerid, 0xFF0000FF, "Chame seu carro em /garagem primeiro.");
            if (valor > 0)
            {
                if (!Cobrar(playerid, valor)) return 1;
            }
            ValorAposta = valor;
            PotAposta = valor;
            CorridaAberta = true;
            EntrarNaCorrida(playerid, EscolhaCarro[playerid]);
            SetTimer("IniciarContagem", TEMPO_ABERTURA, false);
            if (valor > 0)
            {
                format(msg, sizeof(msg), "Corrida com APOSTA aberta! Entrada: $%d (vencedor leva o pote, taxa de %d%%). Digite /corrida. Largada em 20 segundos!", valor, TAXA_APOSTA);
                SendClientMessageToAll(0x00FF00FF, msg);
            }
            else SendClientMessageToAll(0x00FF00FF, "Corrida aberta! Digite /corrida. Largada em 20 segundos!");
        }
        case D_LOJA:
        {
            if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro (/sair).");
            new slot = SlotLivre(playerid);
            if (slot == -1) return SendClientMessage(playerid, 0xFF0000FF, "Garagem cheia. Venda um carro ou compre uma vaga em /garagem.");
            if (!Cobrar(playerid, LojaPreco[listitem])) return 1;
            NovoCarroSlot(playerid, slot, LojaModelo[listitem]);
            SalvarConta(playerid);
            SendClientMessage(playerid, 0x00FF00FF, "Carro comprado! Ele foi para a sua garagem e esta na sua frente.");
            SpawnarCarroPessoal(playerid, slot);
        }
        case D_GARAGEM:
        {
            if (listitem < Vagas[playerid])
            {
                if (Garagem[playerid][listitem][F_MODELO] == 0) return SendClientMessage(playerid, 0xFF0000FF, "Vaga vazia. Compre um carro em /loja.");
                SlotSel[playerid] = listitem;
                ShowPlayerDialog(playerid, D_GARAGEM_ACAO, DIALOG_STYLE_LIST, "Carro", "Tirar da garagem\nVender (60% do valor)", "Escolher", "Voltar");
            }
            else if (Vagas[playerid] < MAX_SLOTS)
            {
                if (!Cobrar(playerid, PRECO_VAGA)) return 1;
                Vagas[playerid]++;
                SalvarConta(playerid);
                SendClientMessage(playerid, 0x00FF00FF, "Vaga extra comprada!");
                MostrarGaragem(playerid);
            }
        }
        case D_GARAGEM_ACAO:
        {
            new s = SlotSel[playerid];
            if (s < 0 || s >= MAX_SLOTS || Garagem[playerid][s][F_MODELO] == 0) return 1;
            if (listitem == 0) SpawnarCarroPessoal(playerid, s);
            else
            {
                if (SlotTravado[playerid][s]) return SendClientMessage(playerid, 0xFF0000FF, "Esse carro esta em uma aposta.");
                if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro (/sair).");
                new preco = PrecoModelo(Garagem[playerid][s][F_MODELO]) * 60 / 100, msg[64];
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
                case 0: ShowPlayerDialog(playerid, D_NITRO, DIALOG_STYLE_LIST, "Nitro", "Nitro 2x - $1500\nNitro 5x - $3000\nNitro 10x - $5000", "Comprar", "Voltar");
                case 1:
                {
                    new lista[700], linha[40];
                    lista[0] = 0;
                    for (new i = 0; i < 20; i++)
                    {
                        format(linha, sizeof(linha), "%s (#%d) - $2500\n", AeroNome[i], AeroId[i]);
                        strcat(lista, linha);
                    }
                    ShowPlayerDialog(playerid, D_AERO, DIALOG_STYLE_LIST, "Aerofolio", lista, "Comprar", "Voltar");
                }
                case 2:
                {
                    new lista[150], linha[32];
                    lista[0] = 0;
                    for (new i = 0; i < 6; i++)
                    {
                        format(linha, sizeof(linha), "%s - $1500\n", RodaNome[i]);
                        strcat(lista, linha);
                    }
                    ShowPlayerDialog(playerid, D_RODAS, DIALOG_STYLE_LIST, "Rodas", lista, "Comprar", "Voltar");
                }
                case 3:
                {
                    if (Garagem[playerid][SlotAtivo[playerid]][F_HID] > 0) SendClientMessage(playerid, 0xFF0000FF, "Esse carro ja tem hidraulica.");
                    else Instalar(playerid, 1087, CARMODTYPE_HYDRAULICS, 3000, F_HID, "Hidraulica");
                }
                case 4: ShowPlayerDialog(playerid, D_NEON, DIALOG_STYLE_LIST, "Neon - $4000", "Vermelho\nAzul\nVerde\nAmarelo\nRosa\nBranco\nRemover neon (gratis)", "Aplicar", "Voltar");
                case 5: ShowPlayerDialog(playerid, D_COR, DIALOG_STYLE_LIST, "Pintura - $800", "Preto\nBranco\nVermelho\nAmarelo\nAzul\nAleatorio", "Pintar", "Voltar");
                case 6:
                {
                    if (Cobrar(playerid, 500))
                    {
                        RepairVehicle(GetPlayerVehicleID(playerid));
                        SendClientMessage(playerid, 0x00FF00FF, "Carro reparado!");
                    }
                }
            }
        }
        case D_NITRO:
        {
            Instalar(playerid, NitroId[listitem], CARMODTYPE_NITRO, NitroPreco[listitem], F_NITRO, "Nitro");
        }
        case D_AERO:
        {
            Instalar(playerid, AeroId[listitem], CARMODTYPE_SPOILER, 2500, F_AERO, "Aerofolio");
        }
        case D_RODAS:
        {
            Instalar(playerid, RodaId[listitem], CARMODTYPE_WHEELS, 1500, F_RODA, "Rodas");
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
            else if (Cobrar(playerid, 4000))
            {
                AplicarNeon(GetPlayerVehicleID(playerid), listitem + 1);
                Garagem[playerid][s][F_NEON] = listitem + 1;
                SalvarConta(playerid);
                SendClientMessage(playerid, 0x00FF00FF, "Neon instalado!");
            }
        }
        case D_COR:
        {
            new s = SlotDoTuning(playerid);
            if (s < 0) return 1;
            if (Cobrar(playerid, 800))
            {
                new c = CorId[listitem];
                if (c == -1) c = random(126);
                ChangeVehicleColor(GetPlayerVehicleID(playerid), c, c);
                Garagem[playerid][s][F_COR1] = c;
                Garagem[playerid][s][F_COR2] = c;
                SalvarConta(playerid);
                SendClientMessage(playerid, 0x00FF00FF, "Carro pintado!");
            }
        }
        case D_DUELO_CONF:
        {
            new alvo = DesafioAlvo[playerid];
            if (!ChecarDuelo(playerid, alvo)) return SendClientMessage(playerid, 0xFF0000FF, ErroDuelo);
            new meu[20], dele[20], nome[MAX_PLAYER_NAME], texto[300];
            NomeModelo(Garagem[playerid][SlotAtivo[playerid]][F_MODELO], meu, sizeof(meu));
            NomeModelo(Garagem[alvo][SlotAtivo[alvo]][F_MODELO], dele, sizeof(dele));
            GetPlayerName(playerid, nome, sizeof(nome));
            format(texto, sizeof(texto), "%s desafia voce para uma corrida valendo o CARRO!\n\nO carro dele: %s\nO seu carro: %s\n\nQuem perder entrega o carro (com todo o tuning) ao vencedor. Aceita?", nome, meu, dele);
            DesafioDe[alvo] = playerid;
            ShowPlayerDialog(alvo, D_DUELO, DIALOG_STYLE_MSGBOX, "Aposta de carro", texto, "Aceitar", "Recusar");
            SendClientMessage(playerid, 0xFFFF00FF, "Desafio enviado. Aguarde a resposta.");
        }
        case D_DUELO:
        {
            new c = DesafioDe[playerid];
            DesafioDe[playerid] = INVALID_PLAYER_ID;
            if (c == INVALID_PLAYER_ID || !IsPlayerConnected(c) || DesafioAlvo[c] != playerid) return SendClientMessage(playerid, 0xFF0000FF, "Esse desafio nao e mais valido.");
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

// ---------------------------------------------------------------- corrida
stock AgendarReset(tempo)
{
    if (ResetAgendado) return 0;
    ResetAgendado = true;
    SetTimer("ResetarCorrida", tempo, false);
    return 1;
}

// escolha 0-7 = carro gratis da lista | 8 = carro da garagem (o que esta na rua)
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
    else if (escolha >= 0 && escolha < 8) modelo = ModelosCorrida[escolha];
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
    if (slot >= 0)
    {
        if (CarroPessoal[playerid] != INVALID_VEHICLE_ID)
        {
            DestruirVeiculo(CarroPessoal[playerid]);
            CarroPessoal[playerid] = INVALID_VEHICLE_ID;
        }
        SlotAtivo[playerid] = -1;
        Veiculo[playerid] = CriarVeiculoSlot(playerid, slot, px, py, CPs[0][2] + 1.0, ang);
    }
    else
    {
        Veiculo[playerid] = CreateVehicle(modelo, px, py, CPs[0][2] + 1.0, ang, random(100), random(100), -1);
        AddVehicleComponent(Veiculo[playerid], 1010);
    }
    PutPlayerInVehicle(playerid, Veiculo[playerid], 0);
    return 1;
}

public IniciarContagem()
{
    new minimo = MIN_JOGADORES;
    if (ValorAposta > 0 || ModoDuelo) minimo = 2;
    if (Participantes < minimo)
    {
        SendClientMessageToAll(0xFF0000FF, "Corrida cancelada: poucos jogadores.");
        if (ValorAposta > 0)
        {
            for (new i = 0; i < MAX_PLAYERS; i++)
            {
                if (!IsPlayerConnected(i) || !NaCorrida[i]) continue;
                GivePlayerMoney(i, ValorAposta); // devolve a entrada
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
        if (IsPlayerConnected(i) && NaCorrida[i]) TogglePlayerControllable(i, 0);
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
        new nome[MAX_PLAYER_NAME], msg[128], premio = 0;
        GetPlayerName(playerid, nome, sizeof(nome));
        NaCorrida[playerid] = false;

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

        if (ValorAposta > 0)
        {
            if (Chegaram == 1) premio = PotAposta - (PotAposta * TAXA_APOSTA / 100);
        }
        else premio = 10000 / Chegaram;

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
        if (CorridaRodando)
        {
            ResolverDuelo(outro, playerid); // abandonou = perdeu o carro
            AgendarReset(4000);
        }
        else CancelarDuelo();
    }
    else if (!CorridaRodando && ValorAposta > 0)
    {
        GivePlayerMoney(playerid, ValorAposta); // saiu antes da largada: recebe a entrada de volta
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
    Participantes = 0;
    Chegaram = 0;
    ValorAposta = 0;
    PotAposta = 0;
    return 1;
}

// ---------------------------------------------------------------- admin (timers)
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
