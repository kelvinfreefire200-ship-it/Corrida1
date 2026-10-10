// ============================================================
// STREET RACING BR v3 - TUDO QUE VOCE PEDIU
// ============================================================
// 1. Login/Registro com senha        -> D_LOGIN / D_REGISTER
// 2. Loja com carros CAROS           -> LojaPreco[]
// 3. Carro inicial gratis (Elegy)    -> NovoCarroSlot(playerid, 0, 562)
// 4. Corrida SO com carro proprio    -> so aceita escolha 8
// 5. Pistas LV->SF e LV->LS          -> PistaLVSF / PistaLVLS
// 6. Corrida ranqueada min 2         -> ModoRanqueada
// 7. /tempo (contra relogio)         -> ModoTempo
// 8. /elegyadm (exclusivo admin)     -> nao aparece na loja
// 9. Confirmacao antes de comprar    -> D_CONFIRM
// 10. Neon funcionando               -> AplicarNeon
// ============================================================

#pragma dynamic 32768
#define MIXED_SPELLINGS
#include <a_samp>

#define MAX_CP           60
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

#define DINHEIRO_INICIAL 1000
#define DINHEIRO_ADM     99999999
#define BONUS_DIARIO     3000
#define MAX_APOSTA       5000000
#define TAXA_APOSTA      10
#define TEMPO_ABERTURA   20000
#define TEMPO_DUELO      300000
#define DIF_MAX_DUELO    150
#define MAX_CP_PISTA     60

#define NUM_PISTAS       1

// IDs de dialogos
#define D_LOGIN          200
#define D_REGISTER       201
#define D_MODO_CORRIDA   202
#define D_APOSTA_VALOR   203
#define D_PISTA_MENU     204
#define D_LOJA           205
#define D_CONFIRM        206
#define D_GARAGEM        207
#define D_GARAGEM_ACAO   208
#define D_TUNING         209
#define D_NITRO          210
#define D_AERO           211
#define D_RODAS          212
#define D_NEON           213
#define D_COR            214
#define D_DUELO_CONF     215
#define D_DUELO          216

// ------------------------------------------------------------
// PISTAS
// ------------------------------------------------------------
new Float:CPs[MAX_CP][3];
new Float:LargadaPos[5][4]; // X, Y, Z, angulo para cada vaga
new bool:LargadaDefinida[5];
new bool:YouTubeOficial[MAX_PLAYERS];
new TotalCP = 0;
new PistaAtual = 0;

new PistaNome[NUM_PISTAS][40] = {"Pista personalizada (ADM)"};

// ------------------------------------------------------------
// LOJA - CARROS CAROS (nao tem Elegy 562 - esse e exclusivo admin)
// ------------------------------------------------------------
#define TOTAL_CARROS_LOJA 50
new LojaModelo[TOTAL_CARROS_LOJA] = {
    401, 410, 436, 439, 445, 466, 467, 492, 496, 517,
    518, 526, 527, 529, 533, 540, 546, 547, 549, 550,
    551, 555, 558, 559, 560, 561, 562, 565, 566, 567,
    575, 576, 580, 585, 587, 589, 602, 603, 400, 404,
    405, 409, 412, 419, 421, 426, 434, 477, 480, 506
};
new LojaNome[TOTAL_CARROS_LOJA][16] = {
    "Bravura", "Manana", "Previon", "Stallion", "Admiral", "Glendale", "Oceanic", "Greenwood", "Blista", "Majestic",
    "Buccaneer", "Fortune", "Cadrona", "Willard", "Feltzer", "Vincent", "Intruder", "Primo", "Tampa", "Sunrise",
    "Merit", "Windsor", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Flash", "Tahoma", "Savanna",
    "Stafford", "Broadway", "Stafford2", "Emperor", "Euros", "Club", "Alpha", "Phoenix", "Landstalker", "Perennial",
    "Sentinel", "Stretch", "Voodoo", "Esperanto", "Washington", "Premier", "Hotknife", "ZR-350", "Comet", "Super GT"
};
new LojaPreco[TOTAL_CARROS_LOJA] = {
    5000, 6000, 7000, 8000, 10000, 10000, 11000, 12000, 15000, 15000,
    18000, 20000, 22000, 25000, 28000, 30000, 32000, 35000, 38000, 40000,
    45000, 50000, 55000, 60000, 70000, 75000, 80000, 85000, 90000, 95000,
    100000, 105000, 110000, 115000, 120000, 125000, 130000, 140000, 150000, 160000,
    170000, 180000, 190000, 200000, 220000, 240000, 260000, 280000, 300000, 350000
};

// ------------------------------------------------------------
// TUNING
// ------------------------------------------------------------
new RodaId[6] = {1073, 1074, 1075, 1077, 1082, 1085};
new RodaNome[6][16] = {"Shadow", "Mega", "Rimshine", "Classic", "Import", "Atomic"};
new RodaPreco[6] = {8000, 9000, 10000, 12000, 15000, 20000};

new CorId[6] = {0, 1, 3, 6, 79, -1};
new CorNome[6][16] = {"Preto", "Branco", "Vermelho", "Amarelo", "Azul", "Aleatorio"};

new NitroId[3] = {1009, 1008, 1010};
new NitroPreco[3] = {15000, 30000, 50000};

new AeroId[20] = {1000, 1001, 1002, 1003, 1014, 1015, 1016, 1023, 1049, 1050, 1058, 1060, 1138, 1139, 1146, 1147, 1158, 1162, 1163, 1164};
new AeroNome[20][14] = {"Alien","X-Flow","Alpha","Champ","Drag","Race","Worx","Fury","Pro","Win","Vento","Trofeu","Rally","Street","Tuner","Drift","Speed","Monster","Cyber","Neon"};
new AeroPreco[20] = {12000,13000,14000,15000,16000,17000,18000,19000,20000,21000,22000,23000,24000,25000,26000,27000,28000,29000,30000,32000};

new NeonNome[6][10] = {"Vermelho","Azul","Verde","Amarelo","Rosa","Branco"};
new NeonPreco = 25000;
new NeonObj[MAX_VEHICLES + 1][2];

// ------------------------------------------------------------
// ENTREGAS
// ------------------------------------------------------------
new Float:EntregaPos[6][3] = {
    {2495.0, -1688.0, 13.5}, {1480.0, -1740.0, 13.5}, {2227.0, -1721.0, 13.5},
    {1685.0, -2330.0, 13.5}, {400.0, -2088.0, 7.8},   {810.0, -1356.0, 13.5}
};
new EntregaNome[6][24] = {"Grove Street","Centro","Academia Ganton","Aeroporto","Pier","Estacao Market"};

// ------------------------------------------------------------
// ESTADO
// ------------------------------------------------------------
new bool:CorridaAberta, bool:CorridaRodando, bool:ModoDuelo, bool:ResetAgendado;
new bool:ModoRanqueada, bool:ModoTempo;
new bool:NaCorrida[MAX_PLAYERS];
new PlayerCP[MAX_PLAYERS], Veiculo[MAX_PLAYERS];
new Float:PosAntes[MAX_PLAYERS][3];
new Participantes, Chegaram, Contagem, TimerContagemID;
new ValorAposta, PotAposta;
new EscolhaCarro[MAX_PLAYERS], SlotCorrida[MAX_PLAYERS];
new TempoInicio[MAX_PLAYERS];

new bool:DueloAtivo;
new DueloP1, DueloP2, DueloTimerID;
new DesafioAlvo[MAX_PLAYERS], DesafioDe[MAX_PLAYERS];
new ErroDuelo[96];

new bool:Carregado[MAX_PLAYERS];
new bool:Logado[MAX_PLAYERS];
new bool:DinheiroInf[MAX_PLAYERS];
new Garagem[MAX_PLAYERS][MAX_SLOTS][N_CAMPOS];
new bool:SlotTravado[MAX_PLAYERS][MAX_SLOTS];
new Vagas[MAX_PLAYERS], SlotAtivo[MAX_PLAYERS], SlotSel[MAX_PLAYERS], UltimoBonus[MAX_PLAYERS];
new CarroPessoal[MAX_PLAYERS], CarroAdm[MAX_PLAYERS];
new RankPontos[MAX_PLAYERS];
// Mercado de veiculos: um anuncio por jogador, mantido enquanto ele estiver online.
new bool:AnuncioAtivo[MAX_PLAYERS];
new AnuncioSlot[MAX_PLAYERS], AnuncioPreco[MAX_PLAYERS];

// Codigo promocional ativo; cada jogador pode resgatar o codigo uma vez por sessao.
new bool:PromoAtivo;
new PromoCodigo[32];
new PromoPremio;
new PromoUsado[MAX_PLAYERS][32];


new ConfirmTipo[MAX_PLAYERS], ConfirmPreco[MAX_PLAYERS], ConfirmData[MAX_PLAYERS];

new bool:EntregaAtiva[MAX_PLAYERS];
new EntregaPremio[MAX_PLAYERS];

new RankNome[3][16] = {"Amador","Profissional","Elite"};

// ============================================================
// FORWARDS (obrigatorio para nao dar erro no compilador)
// ============================================================
forward IniciarContagem();
forward Contar();
forward ResetarCorrida();
forward DueloTimeout();
forward MantemDinheiro();
forward BoostAdm();
forward SalvarContaComSenha(playerid, const senha[]);
forward SairCorrida(playerid, voltar);
forward AgendarReset(tempo);
forward EntrarNaCorrida(playerid, escolha);
forward CarregarPistaAtual();
forward SalvarPista();
forward MostrarCP(playerid);

main() {}

// ============================================================
// FUNCOES UTILITARIAS
// ============================================================
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
    for (new i = 0; i < TOTAL_CARROS_LOJA; i++) if (LojaModelo[i] == modelo) return LojaPreco[i];
    if (modelo == 562) return 200000;
    return 0;
}

stock NomeModelo(modelo, nome[], tam)
{
    for (new i = 0; i < TOTAL_CARROS_LOJA; i++) if (LojaModelo[i] == modelo) { format(nome, tam, "%s", LojaNome[i]); return 1; }
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

stock SalvarLargadas()
{
    for (new i = 0; i < 5; i++)
    {
        new arquivo[24], linha[128];
        format(arquivo, sizeof(arquivo), "largada%d.txt", i + 1);
        if (LargadaDefinida[i])
        {
            new File:f = fopen(arquivo, io_write);
            if (!f) return 0;
            format(linha, sizeof(linha), "%.4f %.4f %.4f %.4f\n", LargadaPos[i][0], LargadaPos[i][1], LargadaPos[i][2], LargadaPos[i][3]);
            fwrite(f, linha);
            fclose(f);
        }
    }
    return 1;
}

stock CarregarLargadas()
{
    for (new i = 0; i < 5; i++)
    {
        new arquivo[24], linha[128], a, b, c;
        format(arquivo, sizeof(arquivo), "largada%d.txt", i + 1);
        LargadaDefinida[i] = false;
        if (!fexist(arquivo)) continue;
        new File:f = fopen(arquivo, io_read);
        if (!f) continue;
        if (fread(f, linha))
        {
            a = strfind(linha, " ");
            b = (a == -1) ? -1 : strfind(linha, " ", false, a + 1);
            c = (b == -1) ? -1 : strfind(linha, " ", false, b + 1);
            if (a != -1 && b != -1 && c != -1)
            {
                LargadaPos[i][0] = floatstr(linha);
                LargadaPos[i][1] = floatstr(linha[a + 1]);
                LargadaPos[i][2] = floatstr(linha[b + 1]);
                LargadaPos[i][3] = floatstr(linha[c + 1]);
                LargadaDefinida[i] = true;
            }
        }
        fclose(f);
    }
    return 1;
}

stock CarregarPistaAtual()
{
    TotalCP = 0;
    if (!fexist("pista.txt")) return 0;
    new File:f = fopen("pista.txt", io_read);
    if (!f) return 0;
    new linha[64];
    while (TotalCP < MAX_CP && fread(f, linha))
    {
        new i1 = strfind(linha, " ");
        if (i1 == -1) continue;
        new i2 = strfind(linha, " ", false, i1 + 1);
        if (i2 == -1) continue;
        CPs[TotalCP][0] = floatstr(linha);
        CPs[TotalCP][1] = floatstr(linha[i1 + 1]);
        CPs[TotalCP][2] = floatstr(linha[i2 + 1]);
        TotalCP++;
    }
    fclose(f);
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

stock DefinirDinheiro(playerid, valor)
{
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, valor);
}

stock TemDinheiro(playerid, valor)
{
    if (GetPlayerMoney(playerid) < valor) { SendClientMessage(playerid, 0xFF0000FF, "Dinheiro insuficiente."); return 0; }
    return 1;
}

stock Cobrar(playerid, valor)
{
    if (!TemDinheiro(playerid, valor)) return 0;
    GivePlayerMoney(playerid, -valor);
    return 1;
}

stock RankDoJogador(playerid)
{
    if (RankPontos[playerid] >= 25) return 2;
    if (RankPontos[playerid] >= 10) return 1;
    return 0;
}

// ============================================================
// LOGIN / REGISTRO
// ============================================================
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
    PromoUsado[playerid][0] = 0;
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
    new senhaHash = 0;
    new File:f = fopen(arq, io_read);
    if (f) { fread(f, linha); fclose(f); new pos = strfind(linha, " "); if (pos != -1) senhaHash = strval(linha[pos+1]); }
    f = fopen(arq, io_write);
    if (f)
    {
        format(linha, sizeof(linha), "%d %d", GetPlayerMoney(playerid), senhaHash);
        fwrite(f, linha);
        fclose(f);
    }
    SalvarGaragem(playerid);
    return 1;
}

// ============================================================
// GARAGEM / SPAWN
// ============================================================
stock SpawnarCarroPessoal(playerid, slot)
{
    if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro (/sair).");
    if (slot < 0 || slot >= MAX_SLOTS || Garagem[playerid][slot][F_MODELO] == 0) return SendClientMessage(playerid, 0xFF0000FF, "Vaga vazia.");
    if (SlotTravado[playerid][slot]) return SendClientMessage(playerid, 0xFF0000FF, "Esse carro esta em aposta.");
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
        SendClientMessage(playerid, 0xFF0000FF, "Esse carro esta em aposta.");
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
        SendClientMessage(playerid, 0xFF0000FF, "Essa peca nao serve nesse carro.");
        return 0;
    }
    Garagem[playerid][s][campo] = comp;
    Cobrar(playerid, preco);
    new msg[80];
    format(msg, sizeof(msg), "%s instalado(a)!", nomeparte);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    SalvarConta(playerid);
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
    new lista[1600], linha[60];
    lista[0] = 0;
    for (new i = 0; i < TOTAL_CARROS_LOJA; i++)
    {
        format(linha, sizeof(linha), "%s - $%d\n", LojaNome[i], LojaPreco[i]);
        strcat(lista, linha);
    }
    ShowPlayerDialog(playerid, D_LOJA, DIALOG_STYLE_LIST, "Concessionaria", lista, "Comprar", "Fechar");
}

// ============================================================
// ENTREGAS
// ============================================================
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

// ============================================================
// DUELO (aposta de carro)
// ============================================================
stock ChecarDuelo(a, b)
{
    if (!IsPlayerConnected(a) || !IsPlayerConnected(b) || a == b) { format(ErroDuelo, sizeof(ErroDuelo), "Jogador invalido."); return 0; }
    if (!Logado[a] || !Logado[b]) { format(ErroDuelo, sizeof(ErroDuelo), "Os dois precisam estar logados."); return 0; }
    if (CorridaAberta || CorridaRodando || ModoDuelo || DueloAtivo) { format(ErroDuelo, sizeof(ErroDuelo), "Ja existe corrida."); return 0; }
    if (TotalCP < 3) { format(ErroDuelo, sizeof(ErroDuelo), "Pista nao configurada."); return 0; }
    if (NaCorrida[a] || NaCorrida[b]) { format(ErroDuelo, sizeof(ErroDuelo), "Fora de corridas primeiro."); return 0; }
    if (!NoCarroPessoal(a) || !NoCarroPessoal(b) || SlotAtivo[a] < 0 || SlotAtivo[b] < 0) { format(ErroDuelo, sizeof(ErroDuelo), "Os dois no carro da garagem."); return 0; }
    new sa = SlotAtivo[a], sb = SlotAtivo[b];
    if (SlotTravado[a][sa] || SlotTravado[b][sb]) { format(ErroDuelo, sizeof(ErroDuelo), "Carro em aposta."); return 0; }
    if (SlotLivre(a) == -1 || SlotLivre(b) == -1) { format(ErroDuelo, sizeof(ErroDuelo), "Vaga livre necessaria."); return 0; }
    new pa = PrecoModelo(Garagem[a][sa][F_MODELO]);
    new pb = PrecoModelo(Garagem[b][sb][F_MODELO]);
    if (pa <= 0 || pb <= 0) { format(ErroDuelo, sizeof(ErroDuelo), "Carro nao pode ser apostado."); return 0; }
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
    SendClientMessageToAll(0xFFFF00FF, "Aposta cancelada.");
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
    if (livre == -1) { SendClientMessageToAll(0xFF0000FF, "Garagem cheia."); return 0; }
    new nomeCarro[24], nv[MAX_PLAYER_NAME], np[MAX_PLAYER_NAME], msg[160];
    NomeModelo(Garagem[perdedor][sp][F_MODELO], nomeCarro, sizeof(nomeCarro));
    GetPlayerName(vencedor, nv, sizeof(nv));
    GetPlayerName(perdedor, np, sizeof(np));
    for (new k = 0; k < N_CAMPOS; k++) Garagem[vencedor][livre][k] = Garagem[perdedor][sp][k];
    LimparSlot(perdedor, sp);
    if (SlotAtivo[perdedor] == sp) SlotAtivo[perdedor] = -1;
    SalvarConta(vencedor);
    SalvarConta(perdedor);
    format(msg, sizeof(msg), "%s venceu e ficou com o %s de %s!", nv, nomeCarro, np);
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
    ValorAposta = 0; PotAposta = 0;
    SlotTravado[a][sa] = true;
    SlotTravado[b][sb] = true;
    CorridaAberta = true;
    EntrarNaCorrida(a, 8);
    EntrarNaCorrida(b, 8);
    GetPlayerName(a, na, sizeof(na));
    GetPlayerName(b, nb, sizeof(nb));
    format(msg, sizeof(msg), "APOSTA DE CARROS: %s x %s! Largada em 5s!", na, nb);
    SendClientMessageToAll(0xFF8800FF, msg);
    SetTimer("IniciarContagem", 5000, false);
    DueloTimerID = SetTimer("DueloTimeout", TEMPO_DUELO, false);
    return 1;
}

// ============================================================
// CORRIDA
// ============================================================
stock AgendarReset(tempo)
{
    if (ResetAgendado) return 0;
    ResetAgendado = true;
    SetTimer("ResetarCorrida", tempo, false);
    return 1;
}

stock EntrarNaCorrida(playerid, escolha)
{
    new slot = -1;
    if (escolha != 8) return 0; // SO carro proprio!
    slot = SlotAtivo[playerid];
    if (slot < 0 || Garagem[playerid][slot][F_MODELO] == 0)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Chame seu carro em /garagem primeiro.");
        return 0;
    }
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
    new Float:pz = CPs[0][2] + 1.0;
    if (idx < 5 && LargadaDefinida[idx])
    {
        px = LargadaPos[idx][0];
        py = LargadaPos[idx][1];
        pz = LargadaPos[idx][2];
        ang = LargadaPos[idx][3];
    }
    if (CarroPessoal[playerid] != INVALID_VEHICLE_ID)
    {
        DestruirVeiculo(CarroPessoal[playerid]);
        CarroPessoal[playerid] = INVALID_VEHICLE_ID;
    }
    Veiculo[playerid] = CriarVeiculoSlot(playerid, slot, px, py, pz, ang);
    SlotAtivo[playerid] = slot;
    PutPlayerInVehicle(playerid, Veiculo[playerid], 0);
    return 1;
}

public IniciarContagem()
{
    new minimo = 1;
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

// ============================================================
// CALLBACKS
// ============================================================
public OnGameModeInit()
{
    SetGameModeText("Street Racing BR v3");
    UsePlayerPedAnims();
    EnableStuntBonusForAll(0);
    AddPlayerClass(0,   1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(29,  1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(60,  1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(106, 1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    SetTimer("MantemDinheiro", 3000, true);
    SetTimer("BoostAdm", 50, true);
    CarregarPistaAtual();
    CarregarLargadas();
    return 1;
}

public OnPlayerConnect(playerid)
{
    NaCorrida[playerid] = false;
    Carregado[playerid] = false;
    Logado[playerid] = false;
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
    PromoUsado[playerid][0] = 0;
    DesafioAlvo[playerid] = INVALID_PLAYER_ID;
    DesafioDe[playerid] = INVALID_PLAYER_ID;
    for (new s = 0; s < MAX_SLOTS; s++) LimparSlot(playerid, s);

    new nome[MAX_PLAYER_NAME], arq[64];
    GetPlayerName(playerid, nome, sizeof(nome));
    CarregarTagYouTube(playerid);
    format(arq, sizeof(arq), "conta_%s.txt", nome);

    if (fexist(arq))
    {
        ShowPlayerDialog(playerid, D_LOGIN, DIALOG_STYLE_PASSWORD, "Login",
            "Bem-vindo de volta! Digite sua senha:", "Entrar", "Sair");
    }
    else
    {
        ShowPlayerDialog(playerid, D_REGISTER, DIALOG_STYLE_PASSWORD, "Registro",
            "Bem-vindo! Crie uma senha (min 3 letras):", "Registrar", "Sair");
    }
    return 1;
}

public OnPlayerText(playerid, text[])
{
    new nome[MAX_PLAYER_NAME], mensagem[192];
    GetPlayerName(playerid, nome, sizeof(nome));
    if (YouTubeOficial[playerid])
        format(mensagem, sizeof(mensagem), "[YouTube Oficial] %s: %s", nome, text);
    else
        format(mensagem, sizeof(mensagem), "%s: %s", nome, text);
    SendClientMessageToAll(0xFFFFFFFF, mensagem);
    return 0;
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
    AnuncioAtivo[playerid] = false;
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
        format(msg, sizeof(msg), "[BONUS DIARIO] Voce recebeu $%d!", BONUS_DIARIO);
        SendClientMessage(playerid, 0x00FF00FF, msg);
    }
    return 1;
}

// Durante corridas, conserva o carro funcionando e evita explosao por dano.
public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
    if (CorridaRodando)
    {
        for (new i = 0; i < MAX_PLAYERS; i++)
        {
            if (IsPlayerConnected(i) && NaCorrida[i] && IsPlayerInAnyVehicle(i) && GetPlayerVehicleID(i) == vehicleid)
            {
                SetVehicleHealth(vehicleid, 1000.0);
                RepairVehicle(vehicleid);
                break;
            }
        }
    }
    return 1;
}

public OnVehicleDeath(vehicleid, killerid) { RemoverNeon(vehicleid); return 1; }

public OnPlayerEnterCheckpoint(playerid)
{
    if (!EntregaAtiva[playerid]) return 1;
    if (!IsPlayerInAnyVehicle(playerid))
    {
        SendClientMessage(playerid, 0xFF0000FF, "Precisa chegar de carro!");
        return 1;
    }
    new msg[80];
    EntregaAtiva[playerid] = false;
    DisablePlayerCheckpoint(playerid);
    GivePlayerMoney(playerid, EntregaPremio[playerid]);
    SalvarConta(playerid);
    format(msg, sizeof(msg), "Entrega concluida! +$%d", EntregaPremio[playerid]);
    SendClientMessage(playerid, 0x00FF00FF, msg);
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
        new nome[MAX_PLAYER_NAME], msg[180], premio = 0, tempo = 0;
        GetPlayerName(playerid, nome, sizeof(nome));
        NaCorrida[playerid] = false;
        tempo = gettime() - TempoInicio[playerid];

        if (ModoTempo)
        {
            // Recompensas equilibradas para corrida contra o tempo:
            // ate 1 minuto: $20.000; ate 2 minutos e 30 segundos: $12.000;
            // acima de 2 minutos e 30 segundos (incluindo 3+ minutos): $5.000.
            if (tempo <= 60) premio = 20000;
            else if (tempo <= 150) premio = 12000;
            else premio = 5000;
            format(msg, sizeof(msg), "[TEMPO] %s completou em %d segundos! +$%d", nome, tempo, premio);
            SendClientMessageToAll(0xFFFF00FF, msg);
            GivePlayerMoney(playerid, premio);
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
            if (Chegaram == 1) { premio = 50000 + (RankPontos[playerid] * 1000); RankPontos[playerid] += 5; }
            else if (Chegaram == 2) { premio = 20000; RankPontos[playerid] += 3; }
            else { premio = 8000; RankPontos[playerid] += 1; }
            GivePlayerMoney(playerid, premio);
            SalvarConta(playerid);
            format(msg, sizeof(msg), "[RANQUEADA] %d lugar: %s! +$%d | Pontos: %d (%s)", Chegaram, nome, premio, RankPontos[playerid], RankNome[RankDoJogador(playerid)]);
            SendClientMessageToAll(0x00FFFFFF, msg);
            if (Chegaram >= Participantes) AgendarReset(5000);
            return 1;
        }

        if (ValorAposta > 0) { if (Chegaram == 1) premio = PotAposta - (PotAposta * TAXA_APOSTA / 100); }
        else premio = 20000 / Chegaram;
        if (premio > 0)
        {
            format(msg, sizeof(msg), "%d lugar: %s! +$%d", Chegaram, nome, premio);
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

// ============================================================
// TAG ESPECIAL YOUTUBE OFICIAL (persistente por nick)
// ============================================================
stock CarregarTagYouTube(playerid)
{
    new nome[MAX_PLAYER_NAME], arquivo[64];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arquivo, sizeof(arquivo), "ytag_%s.txt", nome);
    YouTubeOficial[playerid] = fexist(arquivo);
    return 1;
}

stock SalvarTagYouTube(playerid, bool:conceder)
{
    new nome[MAX_PLAYER_NAME], arquivo[64];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arquivo, sizeof(arquivo), "ytag_%s.txt", nome);
    if (conceder)
    {
        new File:f = fopen(arquivo, io_write);
        if (!f) return 0;
        fwrite(f, "YouTube Oficial");
        fclose(f);
        YouTubeOficial[playerid] = true;
    }
    else
    {
        if (fexist(arquivo)) fremove(arquivo);
        YouTubeOficial[playerid] = false;
    }
    return 1;
}

// ============================================================
// COMANDOS
// ============================================================
public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!Logado[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "Faca login primeiro!");
        return 1;
    }

    if (!strcmp(cmdtext, "/dartag", true, 7) && (cmdtext[7] == ' ' || cmdtext[7] == '\\0'))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas o dono/admin (RCON) pode usar este comando.");
        new idTexto[8];
        strmid(idTexto, cmdtext, 8, strlen(cmdtext), sizeof(idTexto));
        new alvo = strval(idTexto);
        if (cmdtext[7] != ' ' || !IsPlayerConnected(alvo)) return SendClientMessage(playerid, 0xFF0000FF, "Use: /dartag [ID]");
        if (!SalvarTagYouTube(alvo, true)) return SendClientMessage(playerid, 0xFF0000FF, "Erro ao salvar a tag.");
        new nomeAlvo[MAX_PLAYER_NAME], msg[128];
        GetPlayerName(alvo, nomeAlvo, sizeof(nomeAlvo));
        format(msg, sizeof(msg), "Tag [YouTube Oficial] concedida para %s (ID %d).", nomeAlvo, alvo);
        SendClientMessage(playerid, 0x00FF00FF, msg);
        SendClientMessage(alvo, 0x00FF00FF, "Voce recebeu a tag especial [YouTube Oficial]!");
        return 1;
    }

    if (!strcmp(cmdtext, "/tirartag", true, 9) && (cmdtext[9] == ' ' || cmdtext[9] == '\\0'))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas o dono/admin (RCON) pode usar este comando.");
        new idTexto[8];
        strmid(idTexto, cmdtext, 10, strlen(cmdtext), sizeof(idTexto));
        new alvo = strval(idTexto);
        if (cmdtext[9] != ' ' || !IsPlayerConnected(alvo)) return SendClientMessage(playerid, 0xFF0000FF, "Use: /tirartag [ID]");
        SalvarTagYouTube(alvo, false);
        new nomeAlvo[MAX_PLAYER_NAME], msg[128];
        GetPlayerName(alvo, nomeAlvo, sizeof(nomeAlvo));
        format(msg, sizeof(msg), "Tag [YouTube Oficial] removida de %s (ID %d).", nomeAlvo, alvo);
        SendClientMessage(playerid, 0x00FF00FF, msg);
        SendClientMessage(alvo, 0xFFFF00FF, "Sua tag [YouTube Oficial] foi removida.");
        return 1;
    }

    if (!strcmp(cmdtext, "/ajuda", true))
    {
        SendClientMessage(playerid, 0xFFFF00FF, "=== COMANDOS ===");
        SendClientMessage(playerid, 0xFFFF00FF, "/corrida /ranqueada /tempo /sair /pistas");
        SendClientMessage(playerid, 0xFFFF00FF, "/loja /garagem /guardar /tuning /rank /toprank");
        SendClientMessage(playerid, 0xFFFF00FF, "/anunciarcarro [preco] /mercado /comprarcarro [id]");
        SendClientMessage(playerid, 0xFFFF00FF, "/apostacarro [id] /entrega /cancelarentrega /pos");
        SendClientMessage(playerid, 0xFFFF00FF, "/promo CODIGO (resgatar promocao)");
        SendClientMessage(playerid, 0xFFCC00FF, "ADM: /all mensagem | /criarpromo CODIGO VALOR | /dardinheiro ID VALOR");
        return 1;
    }

    // Resgatar codigo promocional: /promo CODIGO
    if (!strcmp(cmdtext, "/promo", true, 5) && (cmdtext[5] == ' ' || cmdtext[5] == 0))
    {
        if (cmdtext[5] != ' ' || cmdtext[6] == 0)
            return SendClientMessage(playerid, 0xFFFF00FF, "Uso: /promo CODIGO");
        if (!PromoAtivo)
            return SendClientMessage(playerid, 0xFF0000FF, "Nao ha codigo promocional ativo.");
        new codigo[32];
        strmid(codigo, cmdtext, 6, strlen(cmdtext), sizeof(codigo));
        if (strcmp(codigo, PromoCodigo, true) != 0)
            return SendClientMessage(playerid, 0xFF0000FF, "Codigo promocional invalido.");
        if (!strcmp(PromoUsado[playerid], PromoCodigo, true))
            return SendClientMessage(playerid, 0xFF0000FF, "Voce ja resgatou esse codigo.");
        GivePlayerMoney(playerid, PromoPremio);
        format(PromoUsado[playerid], 32, "%s", PromoCodigo);
        SalvarConta(playerid);
        new msg[128];
        format(msg, sizeof(msg), "Codigo resgatado! Voce recebeu $%d.", PromoPremio);
        return SendClientMessage(playerid, 0x00FF00FF, msg);
    }

    if (!strcmp(cmdtext, "/rank", true))
    {
        new msg[128], r = RankDoJogador(playerid);
        format(msg, sizeof(msg), "Rank: %s (%d pts)", RankNome[r], RankPontos[playerid]);
        return SendClientMessage(playerid, 0x00FF00FF, msg);
    }

    // MERCADO: anuncia o slot ativo usando /anunciarcarro [preco].
    if (!strcmp(cmdtext, "/anunciarcarro", true, 14) && (cmdtext[14] == ' ' || cmdtext[14] == 0))
    {
        if (cmdtext[14] != ' ') return SendClientMessage(playerid, 0xFFFF00FF, "Uso: /anunciarcarro [preco]");
        if (NaCorrida[playerid] || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Nao pode anunciar durante corrida ou X1.");
        new preco = strval(cmdtext[15]);
        if (preco < 1 || preco > 50000000) return SendClientMessage(playerid, 0xFF0000FF, "Preco permitido: $1 ate $50.000.000.");
        new slot = SlotAtivo[playerid];
        if (slot < 0 || slot >= MAX_SLOTS || Garagem[playerid][slot][F_MODELO] == 0)
            return SendClientMessage(playerid, 0xFF0000FF, "Selecione seu carro na garagem antes de anunciar.");
        if (SlotTravado[playerid][slot]) return SendClientMessage(playerid, 0xFF0000FF, "Esse carro esta bloqueado por uma aposta.");
        AnuncioAtivo[playerid] = true;
        AnuncioSlot[playerid] = slot;
        AnuncioPreco[playerid] = preco;
        new nome[MAX_PLAYER_NAME], msg[144];
        GetPlayerName(playerid, nome, sizeof(nome));
        format(msg, sizeof(msg), "Anuncio publicado: %s vende o modelo %d por $%d. Use /comprarcarro %d", nome, Garagem[playerid][slot][F_MODELO], preco, playerid);
        SendClientMessageToAll(0x33CCFFFF, msg);
        return 1;
    }

    if (!strcmp(cmdtext, "/mercado", true))
    {
        new achou = 0, nome[MAX_PLAYER_NAME], msg[144];
        SendClientMessage(playerid, 0x33CCFFFF, "=== MERCADO DE CARROS ONLINE ===");
        for (new i = 0; i < MAX_PLAYERS; i++)
        {
            if (!IsPlayerConnected(i) || !Logado[i] || !AnuncioAtivo[i]) continue;
            if (AnuncioSlot[i] < 0 || AnuncioSlot[i] >= MAX_SLOTS || Garagem[i][AnuncioSlot[i]][F_MODELO] == 0)
            {
                AnuncioAtivo[i] = false;
                continue;
            }
            GetPlayerName(i, nome, sizeof(nome));
            format(msg, sizeof(msg), "Vendedor %s (ID %d) | modelo %d | $%d | /comprarcarro %d", nome, i, Garagem[i][AnuncioSlot[i]][F_MODELO], AnuncioPreco[i], i);
            SendClientMessage(playerid, 0xFFFFFFFF, msg);
            achou++;
        }
        if (!achou) SendClientMessage(playerid, 0xAAAAAAFF, "Nao ha carros anunciados agora. Anuncie com /anunciarcarro [preco].");
        return 1;
    }

    if (!strcmp(cmdtext, "/comprarcarro", true, 13) && (cmdtext[13] == ' ' || cmdtext[13] == 0))
    {
        if (cmdtext[13] != ' ') return SendClientMessage(playerid, 0xFFFF00FF, "Uso: /comprarcarro [id_vendedor]");
        new vendedor = strval(cmdtext[14]);
        if (vendedor < 0 || vendedor >= MAX_PLAYERS || vendedor == playerid || !IsPlayerConnected(vendedor) || !AnuncioAtivo[vendedor])
            return SendClientMessage(playerid, 0xFF0000FF, "Anuncio/vendedor invalido.");
        if (NaCorrida[playerid] || NaCorrida[vendedor] || ModoDuelo)
            return SendClientMessage(playerid, 0xFF0000FF, "Compra indisponivel durante corridas ou X1.");
        new vs = AnuncioSlot[vendedor], livre = SlotLivre(playerid);
        if (vs < 0 || vs >= MAX_SLOTS || Garagem[vendedor][vs][F_MODELO] == 0)
        {
            AnuncioAtivo[vendedor] = false;
            return SendClientMessage(playerid, 0xFF0000FF, "O carro anunciado nao esta mais disponivel.");
        }
        if (livre == -1) return SendClientMessage(playerid, 0xFF0000FF, "Sua garagem esta cheia.");
        if (!TemDinheiro(playerid, AnuncioPreco[vendedor])) return 1;
        new preco = AnuncioPreco[vendedor], dados[N_CAMPOS];
        for (new k = 0; k < N_CAMPOS; k++) dados[k] = Garagem[vendedor][vs][k];
        GivePlayerMoney(playerid, -preco);
        GivePlayerMoney(vendedor, preco);
        for (new k = 0; k < N_CAMPOS; k++) Garagem[playerid][livre][k] = dados[k];
        LimparSlot(vendedor, vs);
        AnuncioAtivo[vendedor] = false;
        SalvarConta(playerid);
        SalvarConta(vendedor);
        new np[MAX_PLAYER_NAME], nv[MAX_PLAYER_NAME], aviso[144];
        GetPlayerName(playerid, np, sizeof(np)); GetPlayerName(vendedor, nv, sizeof(nv));
        format(aviso, sizeof(aviso), "%s comprou o carro de %s por $%d!", np, nv, preco);
        SendClientMessageToAll(0x33FF99FF, aviso);
        return 1;
    }

    // Ranking dos jogadores online por pontos de corrida.
    if (!strcmp(cmdtext, "/toprank", true))
    {
        new usados[MAX_PLAYERS], msg[128], nome[MAX_PLAYER_NAME];
        for (new pos = 0; pos < 5; pos++)
        {
            new melhor = INVALID_PLAYER_ID, pontos = -1;
            for (new i = 0; i < MAX_PLAYERS; i++)
            {
                if (!IsPlayerConnected(i) || !Logado[i] || usados[i]) continue;
                if (RankPontos[i] > pontos) { pontos = RankPontos[i]; melhor = i; }
            }
            if (melhor == INVALID_PLAYER_ID) break;
            usados[melhor] = 1;
            GetPlayerName(melhor, nome, sizeof(nome));
            format(msg, sizeof(msg), "%d. %s - %d pontos", pos + 1, nome, RankPontos[melhor]);
            SendClientMessage(playerid, 0xFFFF00FF, msg);
        }
        return 1;
    }

    // TROCAR PISTA
    if (!strcmp(cmdtext, "/pistas", true))
    {
        new lista[300], linha[64];
        lista[0] = 0;
        for (new i = 0; i < NUM_PISTAS; i++)
        {
            format(linha, sizeof(linha), "%s%s\n", (i == PistaAtual) ? "[ATUAL] " : "", PistaNome[i]);
            strcat(lista, linha);
        }
        ShowPlayerDialog(playerid, D_PISTA_MENU, DIALOG_STYLE_LIST, "Escolha a pista", lista, "Selecionar", "Fechar");
        return 1;
    }

    // MENU DE CORRIDA
    if (!strcmp(cmdtext, "/corrida", true))
    {
        if (CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Corrida em andamento.");
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Voce ja esta na corrida.");
        if (TotalCP < 3) return SendClientMessage(playerid, 0xFF0000FF, "Pista nao configurada.");
        if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem (/garagem).");
        ShowPlayerDialog(playerid, D_MODO_CORRIDA, DIALOG_STYLE_LIST, "Modo de corrida",
            "Corrida amistosa (aposta opcional)\nCorrida ranqueada (min. 2 jogadores)\nCorrida contra o tempo (solo)",
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
        SendClientMessageToAll(0x00FFFFFF, "Corrida RANQUEADA aberta! Min. 2 jogadores. Use /ranqueada!");
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
        SendClientMessage(playerid, 0x00FF00FF, "Contra o tempo! <5min = $200k!");
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
        format(texto, sizeof(texto), "Apostar seu %s contra o %s de %s?\nQuem perder entrega o carro!", meu, dele, nalvo);
        DesafioAlvo[playerid] = alvo;
        ShowPlayerDialog(playerid, D_DUELO_CONF, DIALOG_STYLE_MSGBOX, "Aposta de carro", texto, "Desafiar", "Cancelar");
        return 1;
    }

    if (!strcmp(cmdtext, "/entrega", true))
    {
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro.");
        if (EntregaAtiva[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Ja tem entrega ativa.");
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

    // ------- ADMIN -------
    // /all mensagem: anuncia para todos os jogadores conectados.
    if (!strcmp(cmdtext, "/all", true, 4) && (cmdtext[4] == ' ' || cmdtext[4] == 0))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        if (cmdtext[4] != ' ' || cmdtext[5] == 0)
            return SendClientMessage(playerid, 0xFFFF00FF, "Uso: /all mensagem para todos");
        new nome[MAX_PLAYER_NAME], texto[144], mensagem[128];
        GetPlayerName(playerid, nome, sizeof(nome));
        strmid(mensagem, cmdtext, 5, strlen(cmdtext), sizeof(mensagem));
        format(texto, sizeof(texto), "[ANUNCIO] %s: %s", nome, mensagem);
        SendClientMessageToAll(0x33CCFFFF, texto);
        return 1;
    }

    // /criarpromo CODIGO VALOR: cria o codigo e divulga no chat global.
    if (!strcmp(cmdtext, "/criarpromo", true, 11) && (cmdtext[11] == ' ' || cmdtext[11] == 0))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        if (cmdtext[11] != ' ' || cmdtext[12] == 0)
            return SendClientMessage(playerid, 0xFFFF00FF, "Uso: /criarpromo CODIGO VALOR");
        new args[96], codigo[32], valorTexto[16], espaco = -1;
        strmid(args, cmdtext, 12, strlen(cmdtext), sizeof(args));
        for (new i = 0; args[i] != 0; i++)
        {
            if (args[i] == ' ') { espaco = i; break; }
        }
        if (espaco <= 0 || args[espaco + 1] == 0)
            return SendClientMessage(playerid, 0xFFFF00FF, "Uso: /criarpromo CODIGO VALOR");
        strmid(codigo, args, 0, espaco, sizeof(codigo));
        strmid(valorTexto, args, espaco + 1, strlen(args), sizeof(valorTexto));
        new valor = strval(valorTexto);
        if (valor < 1 || valor > 10000000)
            return SendClientMessage(playerid, 0xFF0000FF, "Premio permitido: $1 ate $10.000.000.");
        format(PromoCodigo, sizeof(PromoCodigo), "%s", codigo);
        PromoPremio = valor;
        PromoAtivo = true;
        new aviso[144];
        format(aviso, sizeof(aviso), "[PROMO] Codigo: %s | Premio: $%d | Use /promo %s", PromoCodigo, PromoPremio, PromoCodigo);
        SendClientMessageToAll(0xFFFF00FF, aviso);
        return SendClientMessage(playerid, 0x00FF00FF, "Codigo promocional criado e anunciado para todos!");
    }

    // /dardinheiro ID VALOR: acrescenta dinheiro a um jogador conectado.
    if (!strcmp(cmdtext, "/dardinheiro", true, 12) && (cmdtext[12] == ' ' || cmdtext[12] == 0))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        if (cmdtext[12] != ' ' || cmdtext[13] == 0)
            return SendClientMessage(playerid, 0xFFFF00FF, "Uso: /dardinheiro ID VALOR");
        new args[64], idTexto[16], valorTexto[20], espaco = -1;
        strmid(args, cmdtext, 13, strlen(cmdtext), sizeof(args));
        for (new i = 0; args[i] != 0; i++)
        {
            if (args[i] == ' ') { espaco = i; break; }
        }
        if (espaco <= 0 || args[espaco + 1] == 0)
            return SendClientMessage(playerid, 0xFFFF00FF, "Uso: /dardinheiro ID VALOR");
        strmid(idTexto, args, 0, espaco, sizeof(idTexto));
        strmid(valorTexto, args, espaco + 1, strlen(args), sizeof(valorTexto));
        new alvo = strval(idTexto), valor = strval(valorTexto);
        if (alvo < 0 || alvo >= MAX_PLAYERS || !IsPlayerConnected(alvo))
            return SendClientMessage(playerid, 0xFF0000FF, "ID de jogador invalido ou desconectado.");
        if (valor < 1 || valor > 100000000)
            return SendClientMessage(playerid, 0xFF0000FF, "Valor permitido: $1 ate $100.000.000.");
        GivePlayerMoney(alvo, valor);
        SalvarConta(alvo);
        new nomeAlvo[MAX_PLAYER_NAME], msgAlvo[96], msgAdm[128];
        GetPlayerName(alvo, nomeAlvo, sizeof(nomeAlvo));
        format(msgAlvo, sizeof(msgAlvo), "Um administrador adicionou $%d ao seu saldo.", valor);
        SendClientMessage(alvo, 0x00FF00FF, msgAlvo);
        format(msgAdm, sizeof(msgAdm), "Voce adicionou $%d para %s (ID %d).", valor, nomeAlvo, alvo);
        return SendClientMessage(playerid, 0x00FF00FF, msgAdm);
    }

    if (!strcmp(cmdtext, "/dinheiro", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        DefinirDinheiro(playerid, DINHEIRO_ADM);
        return SendClientMessage(playerid, 0x00FF00FF, "Dinheiro ADM!");
    }

    if (!strcmp(cmdtext, "/dinheiroinf", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        DinheiroInf[playerid] = !DinheiroInf[playerid];
        return SendClientMessage(playerid, 0x00FF00FF, DinheiroInf[playerid] ? "Infinito ON" : "Infinito OFF");
    }

    // ELEGY EXCLUSIVO ADMIN
    if (!strcmp(cmdtext, "/elegyadm", true))
    {
        if (!IsPlayerAdmin(playerid)) return 0;
        new slot = SlotLivre(playerid);
        if (slot == -1) return SendClientMessage(playerid, 0xFF0000FF, "Garagem cheia.");
        NovoCarroSlot(playerid, slot, 562);
        SalvarConta(playerid);
        SpawnarCarroPessoal(playerid, slot);
        return SendClientMessage(playerid, 0x00FF00FF, "Elegy ADM entregue!");
    }

    // Salvar posicao de largada para os 5 primeiros jogadores da pista atual
    if (!strcmp(cmdtext, "/save", true) || !strcmp(cmdtext, "/save1", true) || !strcmp(cmdtext, "/save2", true) || !strcmp(cmdtext, "/save3", true) || !strcmp(cmdtext, "/save4", true) || !strcmp(cmdtext, "/save5", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        if (CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Nao pode salvar largada durante corrida.");
        new slotLargada = 0; // /save e /save1 salvam a posicao do jogador 1
        if (!strcmp(cmdtext, "/save2", true)) slotLargada = 1;
        else if (!strcmp(cmdtext, "/save3", true)) slotLargada = 2;
        else if (!strcmp(cmdtext, "/save4", true)) slotLargada = 3;
        else if (!strcmp(cmdtext, "/save5", true)) slotLargada = 4;
        new Float:x, Float:y, Float:z, Float:a;
        if (IsPlayerInAnyVehicle(playerid))
        {
            new veh = GetPlayerVehicleID(playerid);
            GetVehiclePos(veh, x, y, z);
            GetVehicleZAngle(veh, a);
        }
        else
        {
            GetPlayerPos(playerid, x, y, z);
            GetPlayerFacingAngle(playerid, a);
        }
        LargadaPos[slotLargada][0] = x;
        LargadaPos[slotLargada][1] = y;
        LargadaPos[slotLargada][2] = z;
        LargadaPos[slotLargada][3] = a;
        LargadaDefinida[slotLargada] = true;
        if (!SalvarLargadas()) return SendClientMessage(playerid, 0xFF0000FF, "Erro ao gravar arquivo da largada.");
        new msg[96];
        format(msg, sizeof(msg), "Posicao de largada %d salva para a pista atual!", slotLargada + 1);
        return SendClientMessage(playerid, 0x00FF00FF, msg);
    }

    if (!strcmp(cmdtext, "/novapista", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        if (CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Nao pode editar pista durante corrida.");
        PistaAtual = 0;
        TotalCP = 0;
        SalvarPista();
        SendClientMessage(playerid, 0x00FF00FF, "Nova pista iniciada. Dirija ate a largada e use /addcp para registrar os pontos.");
        return 1;
    }

    if (!strcmp(cmdtext, "/salvarpista", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        if (TotalCP < 3) return SendClientMessage(playerid, 0xFF0000FF, "Adicione pelo menos 3 checkpoints com /addcp.");
        if (!SalvarPista()) return SendClientMessage(playerid, 0xFF0000FF, "Erro ao salvar pista.txt.");
        new msg[96];
        format(msg, sizeof(msg), "Pista salva com %d checkpoints.", TotalCP);
        return SendClientMessage(playerid, 0x00FF00FF, msg);
    }

    if (!strcmp(cmdtext, "/apagarpista", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        if (CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Nao pode apagar pista durante corrida.");
        TotalCP = 0;
        SalvarPista();
        return SendClientMessage(playerid, 0xFFFF00FF, "Pista personalizada apagada.");
    }

    if (!strcmp(cmdtext, "/addcp", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        if (PistaAtual != 0) return SendClientMessage(playerid, 0xFF0000FF, "Use a pista personalizada (/pistas).");
        if (TotalCP >= MAX_CP) return SendClientMessage(playerid, 0xFF0000FF, "Limite.");
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
        return SendClientMessage(playerid, 0xFFFF00FF, "Removido.");
    }

    if (!strcmp(cmdtext, "/limparpista", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        TotalCP = 0;
        SalvarPista();
        return SendClientMessage(playerid, 0xFFFF00FF, "Pista apagada.");
    }

    if (!strcmp(cmdtext, "/pista", true))
    {
        new msg[80];
        format(msg, sizeof(msg), "Pista: %s (%d pts)", PistaNome[PistaAtual], TotalCP);
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
        return SendClientMessage(playerid, 0x00FF00FF, "Carro ADM criado!");
    }

    return 0;
}

// ============================================================
// DIALOGOS
// ============================================================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    // ---------- LOGIN ----------
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
                if (senhaSalva == 0 || HashSenha(inputtext) == senhaSalva)
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

    // ---------- REGISTRO ----------
    if (dialogid == D_REGISTER)
    {
        if (!response) { Kick(playerid); return 1; }
        if (strlen(inputtext) < 3) { SendClientMessage(playerid, 0xFF0000FF, "Senha curta (min 3)."); ShowPlayerDialog(playerid, D_REGISTER, DIALOG_STYLE_PASSWORD, "Registro", "Crie uma senha:", "Registrar", "Sair"); return 1; }
        SalvarContaComSenha(playerid, inputtext);
        Logado[playerid] = true;
        Carregado[playerid] = true;
        DefinirDinheiro(playerid, DINHEIRO_INICIAL);
        Vagas[playerid] = VAGAS_INICIAIS;
        RankPontos[playerid] = 0;
    PromoUsado[playerid][0] = 0;
        NovoCarroSlot(playerid, 0, 562); // Elegy inicial gratis
        SalvarConta(playerid);
        SendClientMessage(playerid, 0x00FF00FF, "Conta criada! Voce recebeu $1000 e um Elegy!");
        SendClientMessage(playerid, 0xFFFF00FF, "Use /garagem para pegar o carro e /corrida para competir!");
        SpawnPlayer(playerid);
        return 1;
    }

    if (!Logado[playerid]) return 1;
    if (!response) return 1;

    switch (dialogid)
    {
        // TROCAR PISTA
        case D_PISTA_MENU:
        {
            PistaAtual = listitem;
            CarregarPistaAtual();
            new msg[96];
            format(msg, sizeof(msg), "Pista: %s (%d pontos)", PistaNome[PistaAtual], TotalCP);
            SendClientMessage(playerid, 0x00FF00FF, msg);
        }

        // MENU DE MODO DE CORRIDA
        case D_MODO_CORRIDA:
        {
            if (listitem == 0) // amistosa
            {
                if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem.");
                EscolhaCarro[playerid] = 8;
                ShowPlayerDialog(playerid, D_APOSTA_VALOR, DIALOG_STYLE_INPUT, "Aposta",
                    "Valor (0 = gratis):", "Abrir", "Cancelar");
            }
            else if (listitem == 1) // ranqueada
            {
                if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem.");
                if (CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Corrida em andamento.");
                ModoRanqueada = true;
                CorridaAberta = true;
                EntrarNaCorrida(playerid, 8);
                SetTimer("IniciarContagem", TEMPO_ABERTURA, false);
                SendClientMessageToAll(0x00FFFFFF, "Corrida RANQUEADA! Min 2 jogadores. /ranqueada");
            }
            else // tempo
            {
                if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem.");
                ModoTempo = true;
                CorridaAberta = true;
                EntrarNaCorrida(playerid, 8);
                IniciarContagem();
                SendClientMessage(playerid, 0x00FF00FF, "Contra o tempo! <5min = $200k.");
            }
        }

        // APOSTA VALOR
        case D_APOSTA_VALOR:
        {
            if (CorridaAberta || CorridaRodando || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Ja existe corrida aberta.");
            if (NaCorrida[playerid]) return 1;
            new valor = strval(inputtext), msg[160];
            if (valor < 0) valor = 0;
            if (valor > MAX_APOSTA) { format(msg, sizeof(msg), "Max: $%d", MAX_APOSTA); return SendClientMessage(playerid, 0xFF0000FF, msg); }
            if (valor > 0) { if (!Cobrar(playerid, valor)) return 1; }
            ValorAposta = valor;
            PotAposta = valor;
            CorridaAberta = true;
            EntrarNaCorrida(playerid, 8);
            SetTimer("IniciarContagem", TEMPO_ABERTURA, false);
            if (valor > 0) { format(msg, sizeof(msg), "Corrida com APOSTA $%d! Use /corrida!", valor); SendClientMessageToAll(0x00FF00FF, msg); }
            else SendClientMessageToAll(0x00FF00FF, "Corrida aberta! Use /corrida!");
        }

        // LOJA - CONFIRMACAO
        case D_LOJA:
        {
            if (listitem < 0 || listitem >= TOTAL_CARROS_LOJA) return 1;
            if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Saia da corrida primeiro.");
            if (SlotLivre(playerid) == -1) return SendClientMessage(playerid, 0xFF0000FF, "Garagem cheia.");
            ConfirmTipo[playerid] = 1;
            ConfirmData[playerid] = listitem;
            ConfirmPreco[playerid] = LojaPreco[listitem];
            new texto[200];
            format(texto, sizeof(texto), "Comprar %s por $%d?\nSaldo: $%d", LojaNome[listitem], LojaPreco[listitem], GetPlayerMoney(playerid));
            ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar compra", texto, "Comprar", "Cancelar");
        }

        // GARAGEM
        case D_GARAGEM:
        {
            if (listitem < Vagas[playerid])
            {
                if (Garagem[playerid][listitem][F_MODELO] == 0) return SendClientMessage(playerid, 0xFF0000FF, "Vaga vazia.");
                SlotSel[playerid] = listitem;
                ShowPlayerDialog(playerid, D_GARAGEM_ACAO, DIALOG_STYLE_LIST, "Carro", "Tirar da garagem\nVender (60%)", "Escolher", "Voltar");
            }
            else if (Vagas[playerid] < MAX_SLOTS)
            {
                ConfirmTipo[playerid] = 2;
                ConfirmData[playerid] = 0;
                ConfirmPreco[playerid] = PRECO_VAGA;
                new texto[200];
                format(texto, sizeof(texto), "Comprar vaga extra por $%d?\nSaldo: $%d", PRECO_VAGA, GetPlayerMoney(playerid));
                ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar", texto, "Comprar", "Cancelar");
            }
        }

        case D_GARAGEM_ACAO:
        {
            new s = SlotSel[playerid];
            if (s < 0 || s >= MAX_SLOTS || Garagem[playerid][s][F_MODELO] == 0) return 1;
            if (listitem == 0) SpawnarCarroPessoal(playerid, s);
            else
            {
                if (SlotTravado[playerid][s]) return SendClientMessage(playerid, 0xFF0000FF, "Carro em aposta.");
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
                format(msg, sizeof(msg), "Vendido por $%d.", preco);
                SendClientMessage(playerid, 0x00FF00FF, msg);
            }
        }

        // TUNING MENU
        case D_TUNING:
        {
            if (SlotDoTuning(playerid) < 0) return 1;
            switch (listitem)
            {
                case 0: ShowPlayerDialog(playerid, D_NITRO, DIALOG_STYLE_LIST, "Nitro", "Nitro 2x - $15000\nNitro 5x - $30000\nNitro 10x - $50000", "Comprar", "Voltar");
                case 1:
                {
                    new lista[900], linha[64];
                    lista[0] = 0;
                    for (new i = 0; i < 20; i++) { format(linha, sizeof(linha), "%s - $%d\n", AeroNome[i], AeroPreco[i]); strcat(lista, linha); }
                    ShowPlayerDialog(playerid, D_AERO, DIALOG_STYLE_LIST, "Aerofolio", lista, "Comprar", "Voltar");
                }
                case 2:
                {
                    new lista[250], linha[48];
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

        // NITRO - CONFIRMACAO
        case D_NITRO:
        {
            ConfirmTipo[playerid] = 10;
            ConfirmData[playerid] = listitem;
            ConfirmPreco[playerid] = NitroPreco[listitem];
            new texto[200];
            format(texto, sizeof(texto), "Comprar Nitro por $%d?\nSaldo: $%d", NitroPreco[listitem], GetPlayerMoney(playerid));
            ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar", texto, "Comprar", "Cancelar");
        }

        // AERO - CONFIRMACAO
        case D_AERO:
        {
            ConfirmTipo[playerid] = 11;
            ConfirmData[playerid] = listitem;
            ConfirmPreco[playerid] = AeroPreco[listitem];
            new texto[200];
            format(texto, sizeof(texto), "Comprar Aerofolio %s por $%d?\nSaldo: $%d", AeroNome[listitem], AeroPreco[listitem], GetPlayerMoney(playerid));
            ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar", texto, "Comprar", "Cancelar");
        }

        // RODAS - CONFIRMACAO
        case D_RODAS:
        {
            ConfirmTipo[playerid] = 12;
            ConfirmData[playerid] = listitem;
            ConfirmPreco[playerid] = RodaPreco[listitem];
            new texto[200];
            format(texto, sizeof(texto), "Comprar Rodas %s por $%d?\nSaldo: $%d", RodaNome[listitem], RodaPreco[listitem], GetPlayerMoney(playerid));
            ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar", texto, "Comprar", "Cancelar");
        }

        // NEON
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
                new texto[200];
                format(texto, sizeof(texto), "Comprar Neon %s por $%d?\nSaldo: $%d", NeonNome[listitem], NeonPreco, GetPlayerMoney(playerid));
                ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar", texto, "Comprar", "Cancelar");
            }
        }

        // COR - CONFIRMACAO
        case D_COR:
        {
            ConfirmTipo[playerid] = 14;
            ConfirmData[playerid] = listitem;
            ConfirmPreco[playerid] = 5000;
            new texto[200];
            format(texto, sizeof(texto), "Pintar de %s por $5000?\nSaldo: $%d", CorNome[listitem], GetPlayerMoney(playerid));
            ShowPlayerDialog(playerid, D_CONFIRM, DIALOG_STYLE_MSGBOX, "Confirmar", texto, "Pintar", "Cancelar");
        }

        // CONFIRMACAO GERAL
        case D_CONFIRM:
        {
            new t = ConfirmTipo[playerid];
            if (t == 1)
            {
                new slot = SlotLivre(playerid);
                if (slot == -1) return SendClientMessage(playerid, 0xFF0000FF, "Garagem cheia.");
                if (!Cobrar(playerid, LojaPreco[ConfirmData[playerid]])) return 1;
                NovoCarroSlot(playerid, slot, LojaModelo[ConfirmData[playerid]]);
                SalvarConta(playerid);
                SendClientMessage(playerid, 0x00FF00FF, "Carro comprado!");
                SpawnarCarroPessoal(playerid, slot);
            }
            else if (t == 2)
            {
                if (!Cobrar(playerid, PRECO_VAGA)) return 1;
                Vagas[playerid]++;
                SalvarConta(playerid);
                SendClientMessage(playerid, 0x00FF00FF, "Vaga comprada!");
                MostrarGaragem(playerid);
            }
            else if (t == 10) Instalar(playerid, NitroId[ConfirmData[playerid]], CARMODTYPE_NITRO, NitroPreco[ConfirmData[playerid]], F_NITRO, "Nitro");
            else if (t == 11) Instalar(playerid, AeroId[ConfirmData[playerid]], CARMODTYPE_SPOILER, AeroPreco[ConfirmData[playerid]], F_AERO, "Aerofolio");
            else if (t == 12) Instalar(playerid, RodaId[ConfirmData[playerid]], CARMODTYPE_WHEELS, RodaPreco[ConfirmData[playerid]], F_RODA, "Rodas");
            else if (t == 13)
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
            else if (t == 14)
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
                    SendClientMessage(playerid, 0x00FF00FF, "Pintado!");
                }
            }
            ConfirmTipo[playerid] = 0;
        }

        // DUELO
        case D_DUELO_CONF:
        {
            new alvo = DesafioAlvo[playerid];
            if (!ChecarDuelo(playerid, alvo)) return SendClientMessage(playerid, 0xFF0000FF, ErroDuelo);
            new meu[24], dele[24], nome[MAX_PLAYER_NAME], texto[400];
            NomeModelo(Garagem[playerid][SlotAtivo[playerid]][F_MODELO], meu, sizeof(meu));
            NomeModelo(Garagem[alvo][SlotAtivo[alvo]][F_MODELO], dele, sizeof(dele));
            GetPlayerName(playerid, nome, sizeof(nome));
            format(texto, sizeof(texto), "%s te desafia a apostar o CARRO!\nDele: %s\nSeu: %s\nQuem perder entrega o carro. Aceita?", nome, meu, dele);
            DesafioDe[alvo] = playerid;
            ShowPlayerDialog(alvo, D_DUELO, DIALOG_STYLE_MSGBOX, "Aposta de carro", texto, "Aceitar", "Recusar");
            SendClientMessage(playerid, 0xFFFF00FF, "Desafio enviado.");
        }

        case D_DUELO:
        {
            new c = DesafioDe[playerid];
            DesafioDe[playerid] = INVALID_PLAYER_ID;
            if (c == INVALID_PLAYER_ID || !IsPlayerConnected(c) || DesafioAlvo[c] != playerid) return SendClientMessage(playerid, 0xFF0000FF, "Invalido.");
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

// ============================================================
// TIMERS ADMIN
// ============================================================
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
            x = x * (1.0 - 0.30) + fx * sp * 0.30;
            y = y * (1.0 - 0.30) + fy * sp * 0.30;
        }
        GetPlayerKeys(i, keys, ud, lr);
        if ((keys & KEY_SPRINT) && sp < 1.6)
        {
            x = x * 1.01;
            y = y * 1.01;
        }
        SetVehicleVelocity(v, x, y, z);
    }
    return 1;
}