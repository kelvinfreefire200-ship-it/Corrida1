// ============================================================
// STREET RACING BR v3 - TUDO QUE VOCE PEDIU
// ============================================================
// 1. Login/Registro com senha        -> D_LOGIN / D_REGISTER
// 2. Loja com carros CAROS           -> LojaPreco[]
// 3. Carro inicial gratis (Bravura)    -> NovoCarroSlot(playerid, 0, 401)
// 4. Corrida SO com carro proprio    -> so aceita escolha 8
// 5. Pistas LV->SF e LV->LS          -> PistaLVSF / PistaLVLS
// 6. Corrida ranqueada min 2         -> ModoRanqueada
// 7. /tempo (contra relogio)         -> ModoTempo
// 8. /elegyadm (exclusivo admin)     -> nao aparece na loja
// 9. Confirmacao antes de comprar    -> D_CONFIRM
// 10. Neon funcionando               -> AplicarNeon
// 11. Policia nivel 1-5 + cela 3 min -> secao POLICIA (todos os modos)
// 12. Bots da corrida solo corrigidos -> MoverVeiculo / BotTimer
// ============================================================

#pragma dynamic 32768
#define MIXED_SPELLINGS
#include <a_samp>

// ------------------------------------------------------------
// MODO NPC (somente open.mp)
// 1 = policia e bots sao NPCs de verdade, DIRIGINDO carros reais (recomendado)
// 0 = volta ao sistema antigo (carros vazios teleportados pelo script)
// Se ao iniciar o servidor aparecer "Run time error 19" com NPC_ no log,
// o seu open.mp nao tem o componente de NPC: troque para 0 e recompile.
// ------------------------------------------------------------
#define MODO_NPC 1
#if MODO_NPC
    #include <omp_npc>
#endif

#define MAX_CP           60
#define MAX_SLOTS        8
#define VAGAS_INICIAIS   2
#define PRECO_VAGA       250000
#define N_CAMPOS         15
#define F_MODELO         0
#define F_COR1           1
#define F_COR2           2
#define F_RODA           3
#define F_NITRO          4
#define F_NEON           5
#define F_AERO           6
#define F_HID            7
#define F_ROOF           8
#define F_FB             9
#define F_RB             10
#define F_EXH            11
#define F_SKI            12
#define F_SKI2           13
#define F_PJ             14

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
#define D_RADIO          217
#define D_TURBO          218
#define D_GAR_TURBO_CONF 219
#define D_GAR_TURBO_NIVEL 220
#define D_BODYKIT        221
#define D_BODYKIT_COMP   222
#define D_PECAS          223
#define D_PAINTJOB       224
#define D_MARCHA         225

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

// Rampas fixas criadas pelo administrador durante a partida.
#define MAX_RAMPAS_MAPA 50
new RampaObjeto[MAX_RAMPAS_MAPA];
new TotalRampasMapa = 0;

// ------------------------------------------------------------
// LOJA - CARROS CAROS (nao tem Elegy 562 - esse e exclusivo admin)
// ------------------------------------------------------------
#define TOTAL_CARROS_LOJA 67
new LojaModelo[TOTAL_CARROS_LOJA] = {
    401, 410, 436, 439, 445, 466, 467, 492, 496, 517,
    518, 526, 527, 529, 533, 540, 546, 547, 549, 550,
    551, 555, 558, 559, 560, 561, 562, 565, 566, 567,
    575, 576, 580, 585, 587, 589, 602, 603, 400, 404,
    405, 409, 412, 419, 421, 426, 434, 477, 480, 506,
    411, 415, 451, 474, 475, 479, 491, 494, 500, 502,
    503, 505, 507, 516, 541, 542, 545
};
new LojaNome[TOTAL_CARROS_LOJA][16] = {
    "Bravura", "Manana", "Previon", "Stallion", "Admiral", "Glendale", "Oceanic", "Greenwood",
    "Blista", "Majestic", "Buccaneer", "Fortune", "Cadrona", "Willard", "Feltzer", "Vincent",
    "Intruder", "Primo", "Tampa", "Sunrise", "Merit", "Windsor", "Uranus", "Jester",
    "Sultan", "Stratum", "Elegy", "Flash", "Tahoma", "Savanna", "Stafford", "Broadway",
    "Stafford2", "Emperor", "Euros", "Club", "Alpha", "Phoenix", "Landstalker", "Perennial",
    "Sentinel", "Stretch", "Voodoo", "Esperanto", "Washington", "Premier", "Hotknife", "ZR-350",
    "Comet", "Super GT", "Infernus", "Cheetah", "Turismo", "Hermes", "Sabre", "Regina",
    "Virgo", "Hotring Racer", "Mesa", "Hotring Racer A", "Hotring Racer B", "Rancher", "Elegant", "Nebula",
    "Bullet", "Clover", "Hustler"
};
new LojaPreco[TOTAL_CARROS_LOJA] = {
    5000, 6000, 7000, 8000, 10000, 10000, 11000, 12000, 15000, 15000,
    18000, 20000, 22000, 25000, 28000, 30000, 32000, 35000, 38000, 40000,
    45000, 50000, 55000, 60000, 70000, 75000, 80000, 85000, 90000, 95000,
    100000, 105000, 110000, 115000, 120000, 125000, 130000, 140000, 150000, 160000,
    170000, 180000, 190000, 200000, 220000, 240000, 260000, 280000, 300000, 350000,
    500000, 310000, 320000, 90000, 95000, 100000, 110000, 350000, 130000, 400000,
    420000, 150000, 125000, 140000, 500000, 80000, 180000
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
new bool:ModoRanqueada, bool:ModoTempo, bool:ModoDrag, bool:ModoBots;
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
new TurboNivel[MAX_PLAYERS]; // 0=desligado, 1=3%, 2=6%, 3=9%
new TurboComprado[MAX_PLAYERS]; // bits: nivel 1=1, nivel 2=2, nivel 3=4
new TurboSlotPendente[MAX_PLAYERS];
#define PRECO_TURBO_1 50000
#define PRECO_TURBO_2 150000
#define PRECO_TURBO_3 300000
// Mercado de veiculos: um anuncio por jogador, mantido enquanto ele estiver online.
new bool:AnuncioAtivo[MAX_PLAYERS];
new AnuncioSlot[MAX_PLAYERS], AnuncioPreco[MAX_PLAYERS];

// ------------------------------------------------------------
// MARCHA MANUAL / MODO DRAG
// ------------------------------------------------------------
#define MARCHA_MAX          4        // numero de marchas
#define MARCHA_DUPLO_MS     350      // tempo maximo entre os 2 toques no acelerador
#define MARCHA_PRAZO_MS     1200     // tempo para trocar depois que a luz acende
#define MARCHA_LUZ_ON       0.88     // luz acende com 88% do limite da marcha
#define MARCHA_LUZ_OFF      0.78     // luz apaga se a velocidade cair abaixo de 78%

// Velocidade maxima (km/h) de cada marcha. A ultima marcha nao tem limite (0.0).
new Float:MarchaLimite[MARCHA_MAX] = {70.0, 120.0, 170.0, 0.0};

new bool:MarchaManual[MAX_PLAYERS];      // preferencia do jogador (/marcha)
new bool:MarchaAtiva[MAX_PLAYERS];       // sistema rodando para o jogador (durante a corrida)
new bool:MarchaLuz[MAX_PLAYERS];         // luz vermelha acesa (hora de trocar)
new bool:MarchaMorto[MAX_PLAYERS];       // errou a troca, motor quebrado
new MarchaAtual[MAX_PLAYERS];
new MarchaUltimoToque[MAX_PLAYERS];
new MarchaLuzInicio[MAX_PLAYERS];
new MarchaBlink[MAX_PLAYERS];
new MarchaEstadoTD[MAX_PLAYERS];         // 0 apagada | 1 vermelha forte | 2 vermelha fraca
new PlayerText:MarchaTD[MAX_PLAYERS][2]; // [0] bolinha | [1] texto da marcha

// ------------------------------------------------------------
// BOTS (modo solo contra bots, sem plugin) - drag e ranqueada
// Os bots sao carros sem motorista conduzidos pelo script.
// ------------------------------------------------------------
#define BOTS_QTD            3        // quantidade de bots por corrida
#define BOT_VMAX_MIN        165.0    // velocidade maxima minima do bot (km/h)
#define BOT_VMAX_VAR        45.0     // + ate X km/h aleatorios por bot
#define BOT_ACEL            2.2      // aceleracao base (km/h por tick de 50ms)
#define BOT_FREIO           2.5      // desaceleracao em curva (km/h por tick)
#define BOT_GIRO_MAX        5.0      // graus que o bot pode virar por tick
#define BOT_RAIO_CP         14.0     // distancia para considerar o checkpoint atingido
#define BOTS_PREMIO_PCT     25       // % do premio normal nas corridas contra bots
#define BOTS_PONTOS_VITORIA 1        // pontos de rank ao vencer a ranqueada contra bots

new BotModelos[8] = {411, 541, 451, 415, 560, 559, 565, 562};
new BotNome[BOTS_QTD][12] = {"Bot Dudu", "Bot Kaue", "Bot Leo"};
new bool:BotAtivo[BOTS_QTD];
new bool:BotChegou[BOTS_QTD];
new BotVeiculo[BOTS_QTD];
new BotCP[BOTS_QTD];
new Float:BotVel[BOTS_QTD];
new Float:BotVMax[BOTS_QTD];
new Float:BotAcel[BOTS_QTD];
new Float:BotX[BOTS_QTD];     // posicao interna do bot (o script move o carro)
new Float:BotY[BOTS_QTD];
new Float:BotAng[BOTS_QTD];
new BotDono = -1;
#define BOT_ELASTICO_ATRAS  1.10     // bot atras do jogador 2+ checkpoints: ganha 10% de velocidade
#define BOT_ELASTICO_FRENTE 0.93     // bot 3+ checkpoints na frente: perde 7%

// ------------------------------------------------------------
// POLICIA + CELA (NAO e um modo: aparece em TODOS os modos de corrida)
// ------------------------------------------------------------
#define POL_INICIO_SEG      20       // segundos depois do VAI ate a policia aparecer (nivel 1)
#define POL_SEG_POR_NIVEL   30       // a cada X segundos o nivel sobe (ate o 5)
#define POL_NIVEL_MAX       5
#define POL_MAX_CARROS      4
#define POL_TICK            100      // ms do timer da policia
#define POL_RAIO_CONTATO    9.0      // distancia para a viatura "encostar" no seu carro
#define POL_DIST_MIN        4.5      // a viatura nao entra dentro do seu carro
#define POL_DIST_PERSEGUE   70.0     // acima disso a viatura segue a pista (checkpoints)
#define POL_SPAWN_MIN       45.0     // distancia minima do spawn da viatura ate voce
#define POL_VEL_TETO        320.0    // velocidade maxima absoluta da viatura (km/h)
#define POL_ACEL            5.0      // km/h por tick da viatura (acelerar)
#define POL_FREIO_CARRO     9.0      // km/h por tick da viatura (frear)
#define POL_GIRO_MAX        9.0      // graus por tick que a viatura pode virar
#define POL_PARADO_KMH      15.0     // abaixo disso, encostado, conta como "carro parado"
#define POL_PARADO_MS       1200     // tempo parado e encostado ate ser preso
#define POL_FREIO_POR_SEG   0.06     // o freio sobre o seu carro aumenta X por segundo encostado

#define PRESO_SEGUNDOS      180      // 3 minutos na cela
#define CELA_X              264.6288 // cela da delegacia (interior 6)
#define CELA_Y              77.5742
#define CELA_Z              1001.0391
#define CELA_A              270.0
#define CELA_INT            6
#define LIBERA_X            1759.0   // onde o jogador aparece ao ser solto
#define LIBERA_Y            -1898.0
#define LIBERA_Z            13.56

new PolQtd[POL_NIVEL_MAX]           = {1, 2, 2, 3, 4};                      // viaturas por nivel
new Float:PolVMax[POL_NIVEL_MAX]    = {140.0, 160.0, 180.0, 205.0, 230.0};  // km/h maximo por nivel
new Float:PolFreio[POL_NIVEL_MAX]   = {0.10, 0.14, 0.18, 0.24, 0.30};       // freio no seu carro por tick
new PolModelo[POL_NIVEL_MAX]        = {596, 597, 598, 490, 427};            // LS, SF, LV, FBI Rancher, Enforcer
new Float:PolRatio[POL_NIVEL_MAX]   = {0.97, 1.00, 1.04, 1.08, 1.12};       // velocidade da viatura em relacao a sua

new bool:PolAtivo[MAX_PLAYERS];
new PolNivel[MAX_PLAYERS];
new PolParadoMs[MAX_PLAYERS];
new PolContatoMs[MAX_PLAYERS];
new PolEstado[MAX_PLAYERS];
new PolVeiculo[MAX_PLAYERS][POL_MAX_CARROS];
new PolCP[MAX_PLAYERS][POL_MAX_CARROS];
new Float:PolVel[MAX_PLAYERS][POL_MAX_CARROS];
new Float:PolX[MAX_PLAYERS][POL_MAX_CARROS];
new Float:PolY[MAX_PLAYERS][POL_MAX_CARROS];
new Float:PolAng[MAX_PLAYERS][POL_MAX_CARROS];
new PlayerText:PolTD[MAX_PLAYERS];
new bool:PolTDok[MAX_PLAYERS];
new PolDist[MAX_PLAYERS];
new PolTick[MAX_PLAYERS];

// ------------------------------------------------------------
// NPCs MOTORISTAS (policia e bots) - usados quando MODO_NPC = 1
// ------------------------------------------------------------
#define SEM_NPC             (-1)
#define NPC_KMH_PARA_VEL    0.0055556    // km/h -> velocidade do NPC (1/180). Se os carros ficarem
                                         // lentos/rapidos demais, ajuste so este numero.
#define BOT_NPC_RAIO        24.0         // distancia para trocar para o proximo checkpoint
#define BOT_NPC_CICLO       4            // o bot e atualizado a cada 4 ticks (200ms)
#define BOT_PARADO_MS       2500         // bot parado ha tanto tempo = recolocado na pista
#define POL_PARADO_CARRO_MS 3000         // viatura presa ha tanto tempo = recolocada atras de voce

new BotNpcNome[BOTS_QTD][12] = {"Bot_Dudu", "Bot_Kaue", "Bot_Leo"};
new BotNpc[BOTS_QTD];
new bool:BotIniciou[BOTS_QTD];
new BotParadoMs[BOTS_QTD];
new BotReemitir[BOTS_QTD];
new BotCiclo;

new PolNpc[MAX_PLAYERS][POL_MAX_CARROS];
new PolPresaMs[MAX_PLAYERS][POL_MAX_CARROS];

new NpcPendVeic[MAX_PLAYERS];
new bool:NpcPendSirene[MAX_PLAYERS];
new bool:NpcNoCarro[MAX_PLAYERS];
new bool:NpcCriando;

new bool:Preso[MAX_PLAYERS];
new PresoFim[MAX_PLAYERS];

// ------------------------------------------------------------
// ANTI-CHEAT / BANIMENTO POR IP
// ------------------------------------------------------------
#define AC_AVISO_MAX        3
#define AC_COOLDOWN         5
#define AC_TELEPORT_DIST    120.0
#define AC_TELEPORT_SPEED   110.0
#define AC_PULO_Z           18.0
#define AC_VOO_Z            25.0

new AC_Avisos[MAX_PLAYERS];
new AC_UltimoAviso[MAX_PLAYERS];
new AC_UltimoCheck[MAX_PLAYERS];
new Float:AC_UltimaPos[MAX_PLAYERS][3];
new AC_ArmaAnterior[MAX_PLAYERS];
new AC_UltimoCPTime[MAX_PLAYERS];
new bool:AC_EmAnalise[MAX_PLAYERS];

// Codigo promocional ativo; cada jogador pode resgatar o codigo uma vez por sessao.
new bool:EventoADMAtivo;
new bool:EventoParticipa[MAX_PLAYERS];
new bool:EventoVencedorDefinido;
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
forward AntiCheatTimer();
forward TurboTimer();
forward MarchaTimer();
forward BotTimer();
forward PoliciaTimer();
forward PresoTimer();
forward RestaurarCorPSTimer(playerid);
forward MarchaParar(playerid);
forward MarchaExpulsar(playerid);

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

// Compatibilidade de pecas: no SA-MP 0.3.7 um componente invalido CRASHA o jogo do jogador.
// Por isso so liberamos pecas de carroceria quando o servidor (open.mp) consegue validar.
#if defined VehicleCanHaveComponent
    #define PS_COMPAT 1
#else
    #define PS_COMPAT 0
#endif

stock PecaCompativel(modelo, comp)
{
    #if PS_COMPAT
        if (VehicleCanHaveComponent(modelo, comp)) return 1;
    #else
        #pragma unused modelo, comp
    #endif
    return 0;
}

new PJModelos[13] = {483, 534, 535, 536, 558, 559, 560, 561, 562, 565, 567, 575, 576};

stock ModeloTemPaintjob(modelo)
{
    for (new i = 0; i < 13; i++) if (PJModelos[i] == modelo) return 1;
    return 0;
}

stock AplicarExtras(v, playerid, slot)
{
    new modelo = GetVehicleModel(v);
    for (new k = F_ROOF; k <= F_SKI2; k++)
    {
        new comp = Garagem[playerid][slot][k];
        if (comp > 0 && PecaCompativel(modelo, comp)) AddVehicleComponent(v, comp);
    }
    if (Garagem[playerid][slot][F_PJ] > 0 && ModeloTemPaintjob(modelo))
        ChangeVehiclePaintjob(v, Garagem[playerid][slot][F_PJ] - 1);
    return 1;
}

stock CriarVeiculoSlot(playerid, slot, Float:x, Float:y, Float:z, Float:a)
{
    new v = CreateVehicle(Garagem[playerid][slot][F_MODELO], x, y, z, a, Garagem[playerid][slot][F_COR1], Garagem[playerid][slot][F_COR2], -1);
    if (Garagem[playerid][slot][F_RODA] > 0) AddVehicleComponent(v, Garagem[playerid][slot][F_RODA]);
    if (Garagem[playerid][slot][F_NITRO] > 0) AddVehicleComponent(v, Garagem[playerid][slot][F_NITRO]);
    if (Garagem[playerid][slot][F_AERO] > 0) AddVehicleComponent(v, Garagem[playerid][slot][F_AERO]);
    if (Garagem[playerid][slot][F_HID] > 0) AddVehicleComponent(v, Garagem[playerid][slot][F_HID]);
    if (Garagem[playerid][slot][F_NEON] > 0) AplicarNeon(v, Garagem[playerid][slot][F_NEON]);
    AplicarExtras(v, playerid, slot);
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
    new nome[MAX_PLAYER_NAME], arq[64], linha[200], tmp[16];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "garagem_%s.txt", nome);
    new File:f = fopen(arq, io_write);
    if (!f) return 0;
    format(linha, sizeof(linha), "%d %d %d\n", Vagas[playerid], UltimoBonus[playerid], RankPontos[playerid]);
    fwrite(f, linha);
    for (new s = 0; s < MAX_SLOTS; s++)
    {
        linha[0] = 0;
        for (new k = 0; k < N_CAMPOS; k++)
        {
            format(tmp, sizeof(tmp), "%d ", Garagem[playerid][s][k]);
            strcat(linha, tmp);
        }
        strcat(linha, "\n");
        fwrite(f, linha);
    }
    fclose(f);
    return 1;
}

stock CarregarGaragem(playerid)
{
    new nome[MAX_PLAYER_NAME], arq[64], linha[200], v[N_CAMPOS], n;
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "garagem_%s.txt", nome);
    Vagas[playerid] = VAGAS_INICIAIS;
    UltimoBonus[playerid] = 0;
    RankPontos[playerid] = 0;
    PromoUsado[playerid][0] = 0;
    AC_Resetar(playerid);
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
                for (new k = 0; k < N_CAMPOS; k++) v[k] = 0;
                n = LerInts(linha, v, N_CAMPOS);
                if (n >= 8) // aceita arquivos antigos (8 campos); os novos ficam 0
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

stock SalvarTurbos(playerid)
{
    new nome[MAX_PLAYER_NAME], arq[64], linha[32];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "turbo_%s.txt", nome);
    new File:f = fopen(arq, io_write);
    if (!f) return 0;
    format(linha, sizeof(linha), "%d %d", TurboComprado[playerid], TurboNivel[playerid]);
    fwrite(f, linha);
    fclose(f);
    return 1;
}

stock CarregarTurbos(playerid)
{
    new nome[MAX_PLAYER_NAME], arq[64], linha[32], pos;
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, sizeof(arq), "turbo_%s.txt", nome);
    TurboComprado[playerid] = 0;
    TurboNivel[playerid] = 0;
    if (!fexist(arq)) return 1;
    new File:f = fopen(arq, io_read);
    if (!f) return 0;
    fread(f, linha);
    fclose(f);
    pos = strfind(linha, " ");
    if (pos != -1)
    {
        TurboComprado[playerid] = strval(linha);
        TurboNivel[playerid] = strval(linha[pos + 1]);
    }
    if (TurboNivel[playerid] < 0 || TurboNivel[playerid] > 3) TurboNivel[playerid] = 0;
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
// ANTI-CHEAT
// ============================================================
stock AC_Resetar(playerid)
{
    AC_Avisos[playerid] = 0;
    AC_UltimoAviso[playerid] = 0;
    AC_UltimoCheck[playerid] = 0;
    AC_UltimoCPTime[playerid] = 0;
    AC_ArmaAnterior[playerid] = 0;
    AC_EmAnalise[playerid] = false;
    GetPlayerPos(playerid, AC_UltimaPos[playerid][0], AC_UltimaPos[playerid][1], AC_UltimaPos[playerid][2]);
    return 1;
}

stock AC_Registrar(playerid, const motivo[])
{
    if (!IsPlayerConnected(playerid)) return 0;

    new agora = gettime();
    if (AC_UltimoAviso[playerid] > 0 && (agora - AC_UltimoAviso[playerid]) < AC_COOLDOWN)
        return 0;

    AC_UltimoAviso[playerid] = agora;
    AC_Avisos[playerid]++;

    new nome[MAX_PLAYER_NAME], ip[16], msg[192];
    GetPlayerName(playerid, nome, sizeof(nome));
    GetPlayerIp(playerid, ip, sizeof(ip));

    if (AC_Avisos[playerid] <= AC_AVISO_MAX)
    {
        format(msg, sizeof(msg), "[ANTI-CHEAT] %s (ID %d): suspeita detectada (%s). AVISO %d/%d.",
            nome, playerid, motivo, AC_Avisos[playerid], AC_AVISO_MAX);
        SendClientMessage(playerid, 0xFFCC00FF, msg);

        format(msg, sizeof(msg), "[ANTI-CHEAT] %s (ID %d) recebeu aviso %d/%d por: %s.",
            nome, playerid, AC_Avisos[playerid], AC_AVISO_MAX, motivo);
        for (new i = 0; i < MAX_PLAYERS; i++)
            if (IsPlayerConnected(i) && IsPlayerAdmin(i))
                SendClientMessage(i, 0xFF8800FF, msg);

        if (AC_Avisos[playerid] == AC_AVISO_MAX)
            SendClientMessage(playerid, 0xFF0000FF, "ULTIMO AVISO: uma nova deteccao confirmada causara banimento por IP.");
    }
    else
    {
        format(msg, sizeof(msg), "[ANTI-CHEAT] BAN AUTOMATICO: %s (ID %d), IP %s. Motivo: %s.",
            nome, playerid, ip, motivo);
        for (new i = 0; i < MAX_PLAYERS; i++)
            if (IsPlayerConnected(i) && IsPlayerAdmin(i))
                SendClientMessage(i, 0xFF0000FF, msg);

        BanEx(playerid, motivo);
        return 2;
    }
    return 1;
}

stock bool:AC_VelocidadeImpossivel(playerid)
{
    if (!IsPlayerInAnyVehicle(playerid)) return false;

    new Float:vx, Float:vy, Float:vz;
    GetVehicleVelocity(GetPlayerVehicleID(playerid), vx, vy, vz);

    // Limite deliberadamente alto para reduzir falso positivo.
    new Float:vel = floatsqroot(vx * vx + vy * vy + vz * vz);
    return (vel > 1.75);
}

stock bool:AC_ArmaProibida(playerid)
{
    if (!IsPlayerInAnyVehicle(playerid)) return false;
    new arma = GetPlayerWeapon(playerid);
    // Durante uma corrida o jogador nao deve portar arma.
    return (arma > 0);
}

stock bool:AC_MovimentoSuspeito(playerid)
{
    new agora = gettime();
    if (AC_UltimoCheck[playerid] == agora) return false;
    AC_UltimoCheck[playerid] = agora;

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    new Float:dx = x - AC_UltimaPos[playerid][0];
    new Float:dy = y - AC_UltimaPos[playerid][1];
    new Float:dz = z - AC_UltimaPos[playerid][2];
    new Float:dist = floatsqroot(dx * dx + dy * dy + dz * dz);

    AC_UltimaPos[playerid][0] = x;
    AC_UltimaPos[playerid][1] = y;
    AC_UltimaPos[playerid][2] = z;

    if (!NaCorrida[playerid] || !CorridaRodando) return false;

    if (dist > AC_TELEPORT_DIST)
        return true;

    if (floatabs(dz) > AC_PULO_Z)
        return true;

    return false;
}

public AntiCheatTimer()
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if (!IsPlayerConnected(playerid) || !Logado[playerid]) continue;

        if (NaCorrida[playerid] && CorridaRodando)
        {
            if (AC_MovimentoSuspeito(playerid))
            {
                AC_Registrar(playerid, "teleporte/pulo anormal");
                continue;
            }

            if (AC_VelocidadeImpossivel(playerid))
            {
                AC_Registrar(playerid, "velocidade impossivel");
                continue;
            }

            if (AC_ArmaProibida(playerid))
            {
                AC_Registrar(playerid, "arma nao permitida na corrida");
                continue;
            }
        }
    }
    return 1;
}

// ============================================================
// CORRIDA
// ============================================================
// ============================================================
// MARCHA MANUAL + MODO DRAG
// ============================================================
stock MarchaDesenhar(playerid, estado)
{
    if (!MarchaAtiva[playerid]) return 0;
    MarchaEstadoTD[playerid] = estado;
    new cor = 0x444444FF;                 // apagada (cinza)
    if (estado == 1) cor = 0xFF0000FF;    // vermelha forte
    else if (estado == 2) cor = 0x550000FF; // vermelha fraca (pisca)
    PlayerTextDrawColor(playerid, MarchaTD[playerid][0], cor);
    PlayerTextDrawShow(playerid, MarchaTD[playerid][0]);
    return 1;
}

stock MarchaIniciar(playerid)
{
    if (MarchaAtiva[playerid]) MarchaParar(playerid);
    MarchaAtiva[playerid] = true;
    MarchaLuz[playerid] = false;
    MarchaMorto[playerid] = false;
    MarchaAtual[playerid] = 1;
    MarchaUltimoToque[playerid] = 0;
    MarchaBlink[playerid] = 0;
    MarchaEstadoTD[playerid] = 0;

    // Bolinha (sprite)
    MarchaTD[playerid][0] = CreatePlayerTextDraw(playerid, 296.0, 335.0, "LD_POOL:ball");
    PlayerTextDrawFont(playerid, MarchaTD[playerid][0], 4);
    PlayerTextDrawTextSize(playerid, MarchaTD[playerid][0], 48.0, 48.0);
    PlayerTextDrawColor(playerid, MarchaTD[playerid][0], 0x444444FF);
    PlayerTextDrawShow(playerid, MarchaTD[playerid][0]);

    // Texto da marcha
    MarchaTD[playerid][1] = CreatePlayerTextDraw(playerid, 320.0, 388.0, "MARCHA 1");
    PlayerTextDrawAlignment(playerid, MarchaTD[playerid][1], 2);
    PlayerTextDrawFont(playerid, MarchaTD[playerid][1], 2);
    PlayerTextDrawLetterSize(playerid, MarchaTD[playerid][1], 0.45, 1.8);
    PlayerTextDrawColor(playerid, MarchaTD[playerid][1], 0xFFFFFFFF);
    PlayerTextDrawSetOutline(playerid, MarchaTD[playerid][1], 1);
    PlayerTextDrawSetProportional(playerid, MarchaTD[playerid][1], 1);
    PlayerTextDrawShow(playerid, MarchaTD[playerid][1]);

    SendClientMessage(playerid, 0xFFFF00FF, "MARCHA MANUAL: quando a luz vermelha piscar, toque 2x rapido no acelerador para trocar!");
    SendClientMessage(playerid, 0xFF0000FF, "Se nao trocar a tempo, o motor quebra e voce sai da corrida.");
    return 1;
}

stock MarchaParar(playerid)
{
    if (!MarchaAtiva[playerid]) return 0;
    MarchaAtiva[playerid] = false;
    MarchaLuz[playerid] = false;
    MarchaMorto[playerid] = false;
    PlayerTextDrawDestroy(playerid, MarchaTD[playerid][0]);
    PlayerTextDrawDestroy(playerid, MarchaTD[playerid][1]);
    return 1;
}

stock MarchaTrocar(playerid)
{
    if (!MarchaAtiva[playerid] || MarchaMorto[playerid]) return 0;
    if (MarchaAtual[playerid] >= MARCHA_MAX) return 0; // ja esta na ultima marcha
    if (!MarchaLuz[playerid])
    {
        GameTextForPlayer(playerid, "~y~CEDO DEMAIS!", 600, 3);
        return 0;
    }
    MarchaAtual[playerid]++;
    MarchaLuz[playerid] = false;
    new texto[24];
    format(texto, sizeof(texto), "MARCHA %d", MarchaAtual[playerid]);
    PlayerTextDrawSetString(playerid, MarchaTD[playerid][1], texto);
    MarchaDesenhar(playerid, 0);
    GameTextForPlayer(playerid, "~g~TROCOU!", 500, 3);
    return 1;
}

stock MarchaEliminar(playerid)
{
    if (MarchaMorto[playerid]) return 0;
    MarchaMorto[playerid] = true;
    MarchaLuz[playerid] = false;
    new v = GetPlayerVehicleID(playerid);
    if (v != INVALID_VEHICLE_ID)
    {
        new e, l, a, d, c, b, o;
        GetVehicleParamsEx(v, e, l, a, d, c, b, o);
        SetVehicleParamsEx(v, 0, l, a, d, c, b, o); // desliga o motor
    }
    GameTextForPlayer(playerid, "~r~MOTOR QUEBROU!~n~~w~Voce errou a troca de marcha", 3000, 3);
    new nome[MAX_PLAYER_NAME], msg[96];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(msg, sizeof(msg), "[MARCHA] %s errou a troca de marcha e foi eliminado!", nome);
    SendClientMessageToAll(0xFF0000FF, msg);
    SetTimerEx("MarchaExpulsar", 2000, false, "i", playerid);
    return 1;
}

public MarchaExpulsar(playerid)
{
    if (!IsPlayerConnected(playerid) || !MarchaMorto[playerid] || !NaCorrida[playerid]) return 1;
    SairCorrida(playerid, 1); // tira da corrida automaticamente
    return 1;
}

// Chamado a cada toque no acelerador; 2 toques rapidos = pedido de troca.
stock MarchaToque(playerid)
{
    new agora = GetTickCount();
    if (MarchaUltimoToque[playerid] != 0 && (agora - MarchaUltimoToque[playerid]) <= MARCHA_DUPLO_MS)
    {
        MarchaUltimoToque[playerid] = 0;
        MarchaTrocar(playerid);
    }
    else MarchaUltimoToque[playerid] = agora;
    return 1;
}

public MarchaTimer()
{
    new Float:x, Float:y, Float:z, Float:vel, Float:cap, Float:f;
    new v, estado, agora = GetTickCount();
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!MarchaAtiva[i]) continue;
        if (!IsPlayerConnected(i) || !NaCorrida[i] || !CorridaRodando) { MarchaParar(i); continue; }
        if (MarchaMorto[i]) continue;
        if (GetPlayerState(i) != PLAYER_STATE_DRIVER) continue;
        v = GetPlayerVehicleID(i);
        if (v == INVALID_VEHICLE_ID) continue;

        if (MarchaAtual[i] < MARCHA_MAX)
        {
            cap = MarchaLimite[MarchaAtual[i] - 1];
            GetVehicleVelocity(v, x, y, z);
            vel = floatsqroot(x * x + y * y) * 180.0; // km/h aproximado
            if (vel > cap) // limitador de giro: nao passa do limite sem trocar
            {
                f = cap / vel;
                SetVehicleVelocity(v, x * f, y * f, z);
                vel = cap;
            }
            if (!MarchaLuz[i])
            {
                if (vel >= cap * MARCHA_LUZ_ON)
                {
                    MarchaLuz[i] = true;
                    MarchaLuzInicio[i] = agora;
                    MarchaBlink[i] = 0;
                    PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
                }
            }
            else if (vel < cap * MARCHA_LUZ_OFF) MarchaLuz[i] = false; // desacelerou, luz apaga
            else if ((agora - MarchaLuzInicio[i]) > MARCHA_PRAZO_MS)
            {
                MarchaEliminar(i);
                continue;
            }
        }
        else MarchaLuz[i] = false;

        estado = 0;
        if (MarchaLuz[i])
        {
            MarchaBlink[i]++;
            estado = (((MarchaBlink[i] / 3) % 2) == 0) ? 1 : 2; // pisca a cada ~150ms
        }
        if (estado != MarchaEstadoTD[i]) MarchaDesenhar(i, estado);
    }
    return 1;
}

stock AbrirDrag(playerid)
{
    if (CorridaRodando || CorridaAberta || ModoDuelo) { SendClientMessage(playerid, 0xFF0000FF, "Ja existe uma corrida aberta ou em andamento."); return 0; }
    if (NaCorrida[playerid]) { SendClientMessage(playerid, 0xFF0000FF, "Voce ja esta na corrida."); return 0; }
    if (TotalCP < 3) { SendClientMessage(playerid, 0xFF0000FF, "Pista nao configurada."); return 0; }
    if (!NoCarroPessoal(playerid)) { SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem (/garagem)."); return 0; }
    ModoDrag = true;
    CorridaAberta = true;
    if (!EntrarNaCorrida(playerid, 8))
    {
        ModoDrag = false;
        CorridaAberta = false;
        return 0;
    }
    SetTimer("IniciarContagem", TEMPO_ABERTURA, false);
    SendClientMessageToAll(0xFF8800FF, "Corrida DRAG aberta! Marcha MANUAL obrigatoria. Digite /entrarcorrida para participar!");
    return 1;
}

// ============================================================
// BOTS (solo contra bots)
// ============================================================
stock PosLargada(idx, &Float:px, &Float:py, &Float:pz, &Float:ang)
{
    new Float:dx = CPs[1][0] - CPs[0][0];
    new Float:dy = CPs[1][1] - CPs[0][1];
    new Float:dist = floatsqroot(dx * dx + dy * dy);
    if (dist < 1.0) dist = 1.0;
    new Float:fx = dx / dist;
    new Float:fy = dy / dist;
    ang = Atan2Graus(-fx, fy);
    new Float:atras = float(idx / 2) * 8.0;
    new Float:lado = float(idx % 2) * 4.0 - 2.0;
    px = CPs[0][0] - fx * atras - fy * lado;
    py = CPs[0][1] - fy * atras + fx * lado;
    pz = CPs[0][2] + 1.0;
    if (idx < 5 && LargadaDefinida[idx])
    {
        px = LargadaPos[idx][0];
        py = LargadaPos[idx][1];
        pz = LargadaPos[idx][2];
        ang = LargadaPos[idx][3];
    }
    return 1;
}

// Move um carro SEM motorista. O SetVehicleVelocity sozinho nao funciona em
// carro vazio (o cliente que sincroniza o carro "segura" ele no lugar), por isso
// o script guarda a posicao x,y e teleporta o carro um passo por tick.
stock MoverVeiculo(v, &Float:x, &Float:y, Float:zAlvo, Float:ang, Float:kmh, Float:dt)
{
    new Float:cx, Float:cy, Float:cz, Float:z;
    new Float:passo = (kmh / 3.6) * dt;
    x -= floatsin(ang, degrees) * passo;
    y += floatcos(ang, degrees) * passo;
    GetVehiclePos(v, cx, cy, cz);
    z = cz;
    if (z < zAlvo - 0.5) z = zAlvo - 0.5;
    else if (z > zAlvo + 3.0) z = zAlvo + 3.0;
    SetVehiclePos(v, x, y, z);
    SetVehicleZAngle(v, ang);
    SetVehicleVelocity(v, -floatsin(ang, degrees) * kmh / 180.0, floatcos(ang, degrees) * kmh / 180.0, 0.0);
    return 1;
}

// ------------------------------------------------------------
// NPC MOTORISTA: cria um NPC, coloca ao volante de um carro e (opcional) liga a sirene.
// Devolve o id do NPC ou SEM_NPC se nao foi possivel (ai o sistema antigo assume).
// ------------------------------------------------------------
stock NpcColocarNoCarro(npc)
{
    #if MODO_NPC
        if (npc < 0 || npc >= MAX_PLAYERS) return 0;
        if (NpcNoCarro[npc] || NpcPendVeic[npc] < 1) return 0;
        if (!NPC_IsValid(npc) || !NPC_IsSpawned(npc)) return 0;
        if (!NPC_PutInVehicle(npc, NpcPendVeic[npc], 0)) return 0;
        NpcNoCarro[npc] = true;
        if (NpcPendSirene[npc]) NPC_UseVehicleSiren(npc, true);
        return 1;
    #else
        #pragma unused npc
        return 0;
    #endif
}

stock NpcCriarMotorista(const nome[], veiculo, bool:sirene)
{
    #if MODO_NPC
        NpcCriando = true;
        new npc = NPC_Create(nome);
        NpcCriando = false;
        if (npc < 0 || npc >= MAX_PLAYERS || !NPC_IsValid(npc)) return SEM_NPC;
        NpcPendVeic[npc] = veiculo;
        NpcPendSirene[npc] = sirene;
        NpcNoCarro[npc] = false;
        NPC_Spawn(npc);
        NpcColocarNoCarro(npc); // se o spawn ainda nao terminou, o OnNPCSpawn/timer tenta de novo
        return npc;
    #else
        #pragma unused nome, veiculo, sirene
        return SEM_NPC;
    #endif
}

stock NpcDestruir(npc)
{
    #if MODO_NPC
        if (npc < 0 || npc >= MAX_PLAYERS) return 0;
        NpcNoCarro[npc] = false;
        NpcPendVeic[npc] = 0;
        if (NPC_IsValid(npc)) NPC_Destroy(npc);
        return 1;
    #else
        #pragma unused npc
        return 0;
    #endif
}

#if MODO_NPC
public OnNPCSpawn(npcid)
{
    NpcColocarNoCarro(npcid);
    return 1;
}
#endif

stock BotsRemover()
{
    for (new b = 0; b < BOTS_QTD; b++)
    {
        if (BotNpc[b] != SEM_NPC) { NpcDestruir(BotNpc[b]); BotNpc[b] = SEM_NPC; }
        if (BotAtivo[b]) DestruirVeiculo(BotVeiculo[b]);
        BotAtivo[b] = false;
        BotChegou[b] = false;
        BotVeiculo[b] = INVALID_VEHICLE_ID;
    }
    BotDono = -1;
    return 1;
}

stock BotsCriar(playerid)
{
    new Float:px, Float:py, Float:pz, Float:ang;
    new e, l, a, d, c, bo, o;
    BotDono = playerid;
    for (new b = 0; b < BOTS_QTD; b++)
    {
        BotNpc[b] = SEM_NPC;
        PosLargada(Participantes, px, py, pz, ang);
        BotVeiculo[b] = CreateVehicle(BotModelos[random(8)], px, py, pz, ang, random(126), random(126), -1);
        if (BotVeiculo[b] == INVALID_VEHICLE_ID) continue;
        // tranca as portas para ninguem roubar o carro do bot
        GetVehicleParamsEx(BotVeiculo[b], e, l, a, d, c, bo, o);
        SetVehicleParamsEx(BotVeiculo[b], e, l, a, 1, c, bo, o);
        BotAtivo[b] = true;
        BotChegou[b] = false;
        BotCP[b] = 1;
        BotX[b] = px;
        BotY[b] = py;
        BotAng[b] = ang;
        BotVel[b] = 0.0;
        BotVMax[b] = BOT_VMAX_MIN + float(random(floatround(BOT_VMAX_VAR) + 1));
        BotAcel[b] = BOT_ACEL * (0.85 + float(random(31)) / 100.0); // 0.85 a 1.15
        BotIniciou[b] = false;
        BotParadoMs[b] = 0;
        BotReemitir[b] = 0;
        BotNpc[b] = NpcCriarMotorista(BotNpcNome[b], BotVeiculo[b], false);
        Participantes++;
    }
    return 1;
}

stock BotTerminou(b)
{
    BotChegou[b] = true;
    Chegaram++;
    SetVehicleVelocity(BotVeiculo[b], 0.0, 0.0, 0.0);
    if (BotDono != -1 && IsPlayerConnected(BotDono))
    {
        new msg[96];
        format(msg, sizeof(msg), "[BOT] %s chegou em %d lugar!", BotNome[b], Chegaram);
        SendClientMessage(BotDono, 0xAAAAAAFF, msg);
    }
    return 1;
}

// ---- bot dirigido por NPC ----
// Manda o bot ir ate o checkpoint atual. A velocidade leva em conta a curva que vem
// depois do checkpoint e o "elastico" (bot atras acelera, bot muito na frente alivia).
stock BotNpcIr(b)
{
    #if MODO_NPC
        new cp = BotCP[b], v = BotVeiculo[b];
        new Float:x, Float:y, Float:z, Float:vmax = BotVMax[b], Float:fator = 1.0;
        GetVehiclePos(v, x, y, z);
        if (BotDono != -1 && IsPlayerConnected(BotDono) && NaCorrida[BotDono])
        {
            new dif = PlayerCP[BotDono] - cp;
            if (dif >= 2) vmax *= BOT_ELASTICO_ATRAS;
            else if (dif <= -3) vmax *= BOT_ELASTICO_FRENTE;
        }
        if (cp + 1 < TotalCP)
        {
            new Float:a1 = Atan2Graus(CPs[cp][1] - y, CPs[cp][0] - x);
            new Float:a2 = Atan2Graus(CPs[cp + 1][1] - CPs[cp][1], CPs[cp + 1][0] - CPs[cp][0]);
            new Float:d = a2 - a1;
            while (d > 180.0) d -= 360.0;
            while (d < -180.0) d += 360.0;
            if (d < 0.0) d = -d;
            if (d > 25.0)
            {
                fator = 1.0 - ((d - 25.0) / 90.0) * 0.55;
                if (fator < 0.45) fator = 0.45;
            }
        }
        NPC_Move(BotNpc[b], CPs[cp][0], CPs[cp][1], CPs[cp][2] + 1.0, NPC_MOVE_TYPE_DRIVE, vmax * fator * NPC_KMH_PARA_VEL, 4.0);
    #else
        #pragma unused b
    #endif
    return 1;
}

stock BotNpcAtualizar(b)
{
    #if MODO_NPC
        new npc = BotNpc[b], v = BotVeiculo[b];
        if (!NpcNoCarro[npc]) { NpcColocarNoCarro(npc); return 0; }
        new Float:x, Float:y, Float:z, Float:vx, Float:vy, Float:vz, Float:dx, Float:dy, Float:kmh;
        GetVehiclePos(v, x, y, z);
        GetVehicleVelocity(v, vx, vy, vz);
        kmh = floatsqroot(vx * vx + vy * vy + vz * vz) * 180.0;
        SetVehicleHealth(v, 1000.0);

        if (!BotIniciou[b])
        {
            BotIniciou[b] = true;
            BotNpcIr(b);
            return 1;
        }

        new cp = BotCP[b];
        dx = CPs[cp][0] - x;
        dy = CPs[cp][1] - y;
        if (floatsqroot(dx * dx + dy * dy) < BOT_NPC_RAIO)
        {
            BotCP[b]++;
            BotParadoMs[b] = 0;
            if (BotCP[b] >= TotalCP)
            {
                NPC_StopMove(npc);
                BotTerminou(b);
                return 1;
            }
            BotNpcIr(b);
            return 1;
        }

        // reenvia a ordem de vez em quando (corrige desvio e atualiza o elastico)
        BotReemitir[b]++;
        if (BotReemitir[b] >= 5) { BotReemitir[b] = 0; BotNpcIr(b); }

        // preso em algo? recoloca no checkpoint anterior, olhando para o proximo
        if (kmh < 8.0) BotParadoMs[b] += BOT_NPC_CICLO * 50;
        else BotParadoMs[b] = 0;
        if (BotParadoMs[b] >= BOT_PARADO_MS)
        {
            new prev = cp - 1;
            if (prev < 0) prev = 0;
            SetVehiclePos(v, CPs[prev][0], CPs[prev][1], CPs[prev][2] + 1.0);
            SetVehicleZAngle(v, Atan2Graus(-(CPs[cp][0] - CPs[prev][0]), CPs[cp][1] - CPs[prev][1]));
            SetVehicleVelocity(v, 0.0, 0.0, 0.0);
            BotParadoMs[b] = 0;
            BotNpcIr(b);
        }
    #else
        #pragma unused b
    #endif
    return 1;
}

public BotTimer()
{
    if (!ModoBots) return 1;
    if (!CorridaRodando) return 1;

    // se nao sobrou ninguem correndo (terminou ou saiu), encerra a corrida
    new humanos = 0;
    for (new i = 0; i < MAX_PLAYERS; i++)
        if (IsPlayerConnected(i) && NaCorrida[i]) humanos++;
    if (humanos == 0) { AgendarReset(4000); return 1; }

    if (Contagem >= 0) return 1; // ainda na contagem 3-2-1

    new Float:dx, Float:dy, Float:dist, Float:desejado, Float:diff, Float:adiff;
    new Float:alvoVel, Float:vmax, Float:zAlvo, Float:segX, Float:segY, Float:seg, Float:t;
    new prev, dif;
    BotCiclo++;
    for (new b = 0; b < BOTS_QTD; b++)
    {
        if (!BotAtivo[b] || BotChegou[b]) continue;

        // bot com NPC motorista: o proprio NPC dirige, o script so da as ordens
        if (BotNpc[b] != SEM_NPC)
        {
            if ((BotCiclo % BOT_NPC_CICLO) == 0) BotNpcAtualizar(b);
            continue;
        }

        dx = CPs[BotCP[b]][0] - BotX[b];
        dy = CPs[BotCP[b]][1] - BotY[b];
        dist = floatsqroot(dx * dx + dy * dy);
        if (dist < BOT_RAIO_CP)
        {
            BotCP[b]++;
            if (BotCP[b] >= TotalCP) { BotTerminou(b); continue; }
            dx = CPs[BotCP[b]][0] - BotX[b];
            dy = CPs[BotCP[b]][1] - BotY[b];
            dist = floatsqroot(dx * dx + dy * dy);
        }

        // direcao desejada e giro limitado por tick
        desejado = Atan2Graus(-dx, dy);
        diff = desejado - BotAng[b];
        while (diff > 180.0) diff -= 360.0;
        while (diff < -180.0) diff += 360.0;
        adiff = (diff < 0.0) ? -diff : diff;
        if (diff > BOT_GIRO_MAX) diff = BOT_GIRO_MAX;
        else if (diff < -BOT_GIRO_MAX) diff = -BOT_GIRO_MAX;
        BotAng[b] += diff;

        // velocidade maxima com um leve "elastico" para a corrida ficar disputada
        vmax = BotVMax[b];
        if (BotDono != -1 && IsPlayerConnected(BotDono) && NaCorrida[BotDono])
        {
            dif = PlayerCP[BotDono] - BotCP[b];
            if (dif >= 2) vmax *= BOT_ELASTICO_ATRAS;
            else if (dif <= -3) vmax *= BOT_ELASTICO_FRENTE;
        }

        // em curva fechada o bot alivia
        alvoVel = vmax;
        if (adiff > 25.0)
        {
            alvoVel = vmax * (1.0 - ((adiff - 25.0) / 90.0) * 0.6);
            if (alvoVel < vmax * 0.4) alvoVel = vmax * 0.4;
        }
        if (BotVel[b] < alvoVel)
        {
            BotVel[b] += BotAcel[b] * (1.2 - BotVel[b] / vmax);
            if (BotVel[b] > alvoVel) BotVel[b] = alvoVel;
        }
        else
        {
            BotVel[b] -= BOT_FREIO;
            if (BotVel[b] < alvoVel) BotVel[b] = alvoVel;
        }

        // altura esperada: interpola entre o checkpoint anterior e o proximo
        prev = BotCP[b] - 1;
        segX = CPs[BotCP[b]][0] - CPs[prev][0];
        segY = CPs[BotCP[b]][1] - CPs[prev][1];
        seg = floatsqroot(segX * segX + segY * segY);
        if (seg < 1.0) seg = 1.0;
        t = 1.0 - dist / seg;
        if (t < 0.0) t = 0.0;
        if (t > 1.0) t = 1.0;
        zAlvo = CPs[prev][2] + (CPs[BotCP[b]][2] - CPs[prev][2]) * t + 0.6;

        MoverVeiculo(BotVeiculo[b], BotX[b], BotY[b], zAlvo, BotAng[b], BotVel[b], 0.05);
    }
    return 1;
}

stock AbrirSoloBots(playerid, bool:drag)
{
    if (CorridaRodando || CorridaAberta || ModoDuelo) { SendClientMessage(playerid, 0xFF0000FF, "Ja existe uma corrida aberta ou em andamento."); return 0; }
    if (NaCorrida[playerid]) { SendClientMessage(playerid, 0xFF0000FF, "Voce ja esta na corrida."); return 0; }
    if (TotalCP < 3) { SendClientMessage(playerid, 0xFF0000FF, "Pista nao configurada."); return 0; }
    if (!NoCarroPessoal(playerid)) { SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem (/garagem)."); return 0; }
    ModoBots = true;
    CorridaAberta = true;
    if (drag) ModoDrag = true; else ModoRanqueada = true;
    if (!EntrarNaCorrida(playerid, 8))
    {
        ModoBots = false;
        ModoDrag = false;
        ModoRanqueada = false;
        CorridaAberta = false;
        return 0;
    }
    BotsCriar(playerid);
    if (drag) SendClientMessage(playerid, 0xFF8800FF, "DRAG SOLO contra bots! Marcha manual obrigatoria. Premio reduzido.");
    else SendClientMessage(playerid, 0x00FFFFFF, "RANQUEADA SOLO contra bots! Premio reduzido e rank so sobe se vencer.");
    IniciarContagem();
    return 1;
}

// ============================================================
// POLICIA + CELA
// Nao e um modo de jogo: aparece em qualquer corrida (amistosa, ranqueada,
// tempo, drag, duelo e solo contra bots) para quem esta correndo.
// Nivel 1 aparece POL_INICIO_SEG depois do VAI e sobe ate o 5.
// Se a policia encostar e o seu carro ficar parado -> cela por 3 minutos.
// ============================================================
stock PoliciaTDAtualizar(playerid)
{
    if (!PolTDok[playerid]) return 0;
    new texto[96], estrelas[64], extra[24];
    estrelas[0] = 0;
    extra[0] = 0;
    for (new e = 1; e <= POL_NIVEL_MAX; e++)
    {
        if (e <= PolNivel[playerid]) strcat(estrelas, "~r~*");
        else strcat(estrelas, "~w~*");
    }
    if (PolEstado[playerid] == 1) format(extra, sizeof(extra), " ~r~ENCOSTOU!");
    format(texto, sizeof(texto), "~w~POLICIA %s ~y~NIVEL %d ~w~%dm%s", estrelas, PolNivel[playerid], PolDist[playerid], extra);
    PlayerTextDrawSetString(playerid, PolTD[playerid], texto);
    PlayerTextDrawShow(playerid, PolTD[playerid]);
    return 1;
}

stock PoliciaCriarCarro(playerid, slot, nivel)
{
    new c = PlayerCP[playerid] - 2 - random(2);
    if (c > TotalCP - 2) c = TotalCP - 2;
    if (c < 0) c = 0;
    new Float:fx = CPs[c + 1][0] - CPs[c][0];
    new Float:fy = CPs[c + 1][1] - CPs[c][1];
    new Float:len = floatsqroot(fx * fx + fy * fy);
    if (len < 1.0) len = 1.0;
    fx /= len;
    fy /= len;
    new Float:atras = float(slot) * 8.0;
    new Float:sx = CPs[c][0] - fx * atras;
    new Float:sy = CPs[c][1] - fy * atras;
    new Float:px, Float:py, Float:pz;
    GetVehiclePos(Veiculo[playerid], px, py, pz);
    new Float:ddx = px - sx;
    new Float:ddy = py - sy;
    new Float:ddist = floatsqroot(ddx * ddx + ddy * ddy);
    if (ddist < POL_SPAWN_MIN)
    {
        sx -= fx * (POL_SPAWN_MIN - ddist);
        sy -= fy * (POL_SPAWN_MIN - ddist);
    }
    new Float:ang = Atan2Graus(-fx, fy);
    new v = CreateVehicle(PolModelo[nivel - 1], sx, sy, CPs[c][2] + 1.0, ang, -1, -1, -1);
    if (v == INVALID_VEHICLE_ID) return 0;
    new pe, pl, pa, pd, pc, pb, po;
    GetVehicleParamsEx(v, pe, pl, pa, pd, pc, pb, po);
    SetVehicleParamsEx(v, 1, 1, pa, 1, pc, pb, po); // motor e farol ligados, portas trancadas
    PolVeiculo[playerid][slot] = v;
    PolCP[playerid][slot] = c + 1;
    PolVel[playerid][slot] = 0.0;
    PolX[playerid][slot] = sx;
    PolY[playerid][slot] = sy;
    PolAng[playerid][slot] = ang;
    PolPresaMs[playerid][slot] = 0;
    // motorista NPC com sirene ligada (se falhar, o sistema antigo move a viatura sozinha)
    new nomeNpc[24];
    format(nomeNpc, sizeof(nomeNpc), "Policia_%d_%d", playerid, slot);
    PolNpc[playerid][slot] = NpcCriarMotorista(nomeNpc, v, true);
    return 1;
}

// Coloca a viatura de volta na pista, atras de voce (usada quando ela fica presa)
stock PoliciaReposicionar(playerid, slot)
{
    new v = PolVeiculo[playerid][slot];
    new c = PlayerCP[playerid] - 3;
    if (c > TotalCP - 2) c = TotalCP - 2;
    if (c < 0) c = 0;
    new Float:fx = CPs[c + 1][0] - CPs[c][0];
    new Float:fy = CPs[c + 1][1] - CPs[c][1];
    SetVehiclePos(v, CPs[c][0], CPs[c][1], CPs[c][2] + 1.0);
    SetVehicleZAngle(v, Atan2Graus(-fx, fy));
    SetVehicleVelocity(v, 0.0, 0.0, 0.0);
    PolCP[playerid][slot] = c + 1;
    PolPresaMs[playerid][slot] = 0;
    return 1;
}

stock PoliciaNivel(playerid, nivel)
{
    if (nivel < 1) nivel = 1;
    if (nivel > POL_NIVEL_MAX) nivel = POL_NIVEL_MAX;
    PolNivel[playerid] = nivel;
    new qtd = PolQtd[nivel - 1], atuais = 0, vv, msg[96], gt[48];
    for (new k = 0; k < POL_MAX_CARROS; k++)
    {
        vv = PolVeiculo[playerid][k];
        if (vv != INVALID_VEHICLE_ID && vv > 0) atuais++;
    }
    for (new k = 0; k < POL_MAX_CARROS && atuais < qtd; k++)
    {
        vv = PolVeiculo[playerid][k];
        if (vv == INVALID_VEHICLE_ID || vv < 1)
        {
            if (PoliciaCriarCarro(playerid, k, nivel)) atuais++;
        }
    }
    format(msg, sizeof(msg), "[POLICIA] Nivel %d! %d viatura(s) na sua cola! Nao deixe elas pararem seu carro.", nivel, atuais);
    SendClientMessage(playerid, 0xFF4444FF, msg);
    format(gt, sizeof(gt), "~r~POLICIA ~w~NIVEL %d", nivel);
    GameTextForPlayer(playerid, gt, 2500, 3);
    PoliciaTDAtualizar(playerid);
    return 1;
}

stock PoliciaIniciar(playerid, nivel)
{
    if (PolAtivo[playerid]) return 0;
    PolAtivo[playerid] = true;
    PolNivel[playerid] = 0;
    PolParadoMs[playerid] = 0;
    PolContatoMs[playerid] = 0;
    PolEstado[playerid] = 0;
    PolDist[playerid] = 0;
    PolTick[playerid] = 0;
    for (new k = 0; k < POL_MAX_CARROS; k++)
    {
        PolVeiculo[playerid][k] = INVALID_VEHICLE_ID;
        PolVel[playerid][k] = 0.0;
        PolNpc[playerid][k] = SEM_NPC;
        PolPresaMs[playerid][k] = 0;
    }
    PolTD[playerid] =CreatePlayerTextDraw(playerid, 400.0, 52.0, "POLICIA");
    PlayerTextDrawAlignment(playerid, PolTD[playerid], 2);
    PlayerTextDrawFont(playerid, PolTD[playerid], 2);
    PlayerTextDrawLetterSize(playerid, PolTD[playerid], 0.33, 1.3);
    PlayerTextDrawColor(playerid, PolTD[playerid], 0xFFFFFFFF);
    PlayerTextDrawSetOutline(playerid, PolTD[playerid], 1);
    PlayerTextDrawSetProportional(playerid, PolTD[playerid], 1);
    PolTDok[playerid] = true;
    PoliciaNivel(playerid, nivel);
    return 1;
}

stock PoliciaParar(playerid)
{
    if (!PolAtivo[playerid]) return 0;
    for (new k = 0; k < POL_MAX_CARROS; k++)
    {
        if (PolNpc[playerid][k] != SEM_NPC) { NpcDestruir(PolNpc[playerid][k]); PolNpc[playerid][k] = SEM_NPC; }
        if (PolVeiculo[playerid][k] != INVALID_VEHICLE_ID && PolVeiculo[playerid][k] > 0)
            DestruirVeiculo(PolVeiculo[playerid][k]);
        PolVeiculo[playerid][k] = INVALID_VEHICLE_ID;
    }
    PolAtivo[playerid] = false;
    PolNivel[playerid] = 0;
    PolParadoMs[playerid] = 0;
    PolContatoMs[playerid] = 0;
    PolEstado[playerid] = 0;
    if (PolTDok[playerid] && IsPlayerConnected(playerid)) PlayerTextDrawDestroy(playerid, PolTD[playerid]);
    PolTDok[playerid] = false;
    return 1;
}

// ---------------- CELA ----------------
stock PresoEnviarCela(playerid)
{
    if (IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
    TogglePlayerControllable(playerid, 1);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, CELA_INT);
    SetPlayerPos(playerid, CELA_X, CELA_Y, CELA_Z);
    SetPlayerFacingAngle(playerid, CELA_A);
    SetCameraBehindPlayer(playerid);
    ResetPlayerWeapons(playerid);
    return 1;
}

stock PresoArquivo(playerid, arq[], tam)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(arq, tam, "preso_%s.txt", nome);
    return 1;
}

stock PresoSalvar(playerid)
{
    new arq[64], linha[24];
    PresoArquivo(playerid, arq, sizeof(arq));
    new File:f = fopen(arq, io_write);
    if (!f) return 0;
    format(linha, sizeof(linha), "%d", PresoFim[playerid]);
    fwrite(f, linha);
    fclose(f);
    return 1;
}

// Se o jogador saiu do servidor preso, continua preso quando voltar.
stock PresoCarregar(playerid)
{
    new arq[64], linha[24];
    PresoArquivo(playerid, arq, sizeof(arq));
    if (!fexist(arq)) return 0;
    new File:f = fopen(arq, io_read);
    if (!f) return 0;
    fread(f, linha);
    fclose(f);
    new fim = strval(linha);
    if (fim <= gettime())
    {
        fremove(arq);
        return 0;
    }
    Preso[playerid] = true;
    PresoFim[playerid] = fim;
    SendClientMessage(playerid, 0xFF4444FF, "[POLICIA] Voce saiu do servidor preso e ainda precisa cumprir a pena.");
    return 1;
}

stock PresoLiberar(playerid)
{
    new arq[64];
    Preso[playerid] = false;
    PresoArquivo(playerid, arq, sizeof(arq));
    if (fexist(arq)) fremove(arq);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, LIBERA_X, LIBERA_Y, LIBERA_Z);
    SetCameraBehindPlayer(playerid);
    GameTextForPlayer(playerid, "~g~VOCE FOI SOLTO!", 4000, 3);
    SendClientMessage(playerid, 0x00FF00FF, "[POLICIA] Pena cumprida. Voce esta livre! Dirija com cuidado.");
    return 1;
}

stock PoliciaPrender(playerid)
{
    new nome[MAX_PLAYER_NAME], msg[128], nivel = PolNivel[playerid];
    GetPlayerName(playerid, nome, sizeof(nome));
    PoliciaParar(playerid);
    SairCorrida(playerid, 0);
    Preso[playerid] = true;
    PresoFim[playerid] = gettime() + PRESO_SEGUNDOS;
    PresoEnviarCela(playerid);
    GameTextForPlayer(playerid, "~r~PRESO!", 4000, 3);
    format(msg, sizeof(msg), "[POLICIA] %s foi parado pela policia (nivel %d) e ficara %d minutos na cela!", nome, nivel, PRESO_SEGUNDOS / 60);
    SendClientMessageToAll(0xFF4444FF, msg);
    SendClientMessage(playerid, 0xFF4444FF, "Voce foi preso! Aguarde na cela. Comandos bloqueados ate cumprir a pena.");
    return 1;
}

// Atualiza a policia de UM jogador (chamado pelo PoliciaTimer)
stock PoliciaAtualizar(playerid, agora)
{
    new pv = Veiculo[playerid];
    new nivel = PolNivel[playerid];

    // o nivel sobe com o tempo de corrida
    new porTempo = 1 + (agora - TempoInicio[playerid] - POL_INICIO_SEG) / POL_SEG_POR_NIVEL;
    if (porTempo > POL_NIVEL_MAX) porTempo = POL_NIVEL_MAX;
    if (porTempo > nivel)
    {
        PoliciaNivel(playerid, porTempo);
        nivel = porTempo;
    }

    new Float:px, Float:py, Float:pz, Float:pvx, Float:pvy, Float:pvz;
    GetVehiclePos(pv, px, py, pz);
    GetVehicleVelocity(pv, pvx, pvy, pvz);
    new Float:kmhJog = floatsqroot(pvx * pvx + pvy * pvy + pvz * pvz) * 180.0;

    new Float:cx, Float:cy, Float:dx, Float:dy, Float:dist, Float:tx, Float:ty, Float:tz;
    new Float:desejado, Float:diff, Float:alvoVel, Float:topo, Float:seguir;
    new Float:menor = 9999.0;
    new Float:vmax = PolVMax[nivel - 1];
    new v, ci, bool:contato = false;

    for (new k = 0; k < POL_MAX_CARROS; k++)
    {
        v = PolVeiculo[playerid][k];
        if (v == INVALID_VEHICLE_ID || v < 1) continue;
        new bool:viaNpc = (PolNpc[playerid][k] != SEM_NPC);
        if (viaNpc)
        {
            // viatura com NPC: a posicao e a REAL do carro (o NPC dirige)
            new Float:cz;
            GetVehiclePos(v, cx, cy, cz);
            if (!NpcNoCarro[PolNpc[playerid][k]]) NpcColocarNoCarro(PolNpc[playerid][k]);
        }
        else
        {
            cx = PolX[playerid][k];
            cy = PolY[playerid][k];
        }
        dx = px - cx;
        dy = py - cy;
        dist = floatsqroot(dx * dx + dy * dy);

        // alvo: longe e atras de voce -> segue a pista; perto -> vai direto em voce
        tx = px;
        ty = py;
        tz = pz;
        ci = PolCP[playerid][k];
        if (dist > POL_DIST_PERSEGUE && ci < PlayerCP[playerid] && ci < TotalCP)
        {
            tx = CPs[ci][0];
            ty = CPs[ci][1];
            tz = CPs[ci][2] + 0.6;
            dx = tx - cx;
            dy = ty - cy;
            if (floatsqroot(dx * dx + dy * dy) < 15.0) PolCP[playerid][k]++;
        }

        // giro limitado por tick
        dx = tx - cx;
        dy = ty - cy;
        desejado = Atan2Graus(-dx, dy);
        diff = desejado - PolAng[playerid][k];
        while (diff > 180.0) diff -= 360.0;
        while (diff < -180.0) diff += 360.0;
        if (diff > POL_GIRO_MAX) diff = POL_GIRO_MAX;
        else if (diff < -POL_GIRO_MAX) diff = -POL_GIRO_MAX;
        PolAng[playerid][k] += diff;

        // velocidade: a viatura acompanha a sua (ratio do nivel) e corre mais se estiver longe
        topo = vmax;
        seguir = kmhJog * PolRatio[nivel - 1];
        if (dist > 30.0) seguir += (dist - 30.0) * 0.5;
        if (seguir > topo) topo = seguir;
        if (topo > POL_VEL_TETO) topo = POL_VEL_TETO;
        alvoVel = topo;
        if (dist < 45.0)
        {
            alvoVel = kmhJog + 15.0;
            if (alvoVel > topo) alvoVel = topo;
            if (alvoVel < 40.0) alvoVel = 40.0;
        }
        if (dist < POL_DIST_MIN) alvoVel = kmhJog;

        if (viaNpc)
        {
            // o NPC dirige de verdade: a cada ~300ms damos o destino e a velocidade
            if ((PolTick[playerid] + k) % 3 == 0)
                NPC_Move(PolNpc[playerid][k], tx, ty, tz, NPC_MOVE_TYPE_DRIVE, alvoVel * NPC_KMH_PARA_VEL, 3.0);
            // viatura sem corpo de bombeiro: mantem o carro inteiro
            if (PolTick[playerid] % 10 == 0) SetVehicleHealth(v, 1000.0);
            // presa em algo (longe de voce e parada)? volta para a pista atras de voce
            new Float:wx, Float:wy, Float:wz;
            GetVehicleVelocity(v, wx, wy, wz);
            if (dist > 25.0 && floatsqroot(wx * wx + wy * wy + wz * wz) * 180.0 < 8.0) PolPresaMs[playerid][k] += POL_TICK;
            else PolPresaMs[playerid][k] = 0;
            if (PolPresaMs[playerid][k] >= POL_PARADO_CARRO_MS) PoliciaReposicionar(playerid, k);
        }
        else
        {
            if (PolVel[playerid][k] < alvoVel)
            {
                PolVel[playerid][k] += POL_ACEL;
                if (PolVel[playerid][k] > alvoVel) PolVel[playerid][k] = alvoVel;
            }
            else
            {
                PolVel[playerid][k] -= POL_FREIO_CARRO;
                if (PolVel[playerid][k] < alvoVel) PolVel[playerid][k] = alvoVel;
            }

            MoverVeiculo(v, cx, cy, tz, PolAng[playerid][k], PolVel[playerid][k], float(POL_TICK) / 1000.0);
            PolX[playerid][k] = cx;
            PolY[playerid][k] = cy;
        }

        dx = px - cx;
        dy = py - cy;
        dist = floatsqroot(dx * dx + dy * dy);
        if (dist < menor) menor = dist;
        if (dist < POL_RAIO_CONTATO) contato = true;
    }

    PolDist[playerid] = floatround(menor);
    PolTick[playerid]++;
    if (PolTick[playerid] % 5 == 0) PoliciaTDAtualizar(playerid);

    if (contato)
    {
        // a policia encosta e vai freando o seu carro; quanto mais tempo encostada, mais freia
        PolContatoMs[playerid] += POL_TICK;
        new Float:freio = PolFreio[nivel - 1] + (float(PolContatoMs[playerid]) / 1000.0) * POL_FREIO_POR_SEG;
        if (freio > 0.85) freio = 0.85;
        pvx *= (1.0 - freio);
        pvy *= (1.0 - freio);
        SetVehicleVelocity(pv, pvx, pvy, pvz);

        if (kmhJog < POL_PARADO_KMH) PolParadoMs[playerid] += POL_TICK;
        else PolParadoMs[playerid] = 0;

        if (PolEstado[playerid] != 1)
        {
            PolEstado[playerid] = 1;
            PoliciaTDAtualizar(playerid);
        }
        if (PolParadoMs[playerid] >= POL_PARADO_MS)
        {
            PoliciaPrender(playerid);
            return 1;
        }
    }
    else
    {
        PolContatoMs[playerid] -= POL_TICK * 2;
        if (PolContatoMs[playerid] < 0) PolContatoMs[playerid] = 0;
        PolParadoMs[playerid] = 0;
        if (PolEstado[playerid] != 0)
        {
            PolEstado[playerid] = 0;
            PoliciaTDAtualizar(playerid);
        }
    }
    return 1;
}

public PoliciaTimer()
{
    new agora = gettime();
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i)) continue;
        if (PolAtivo[i])
        {
            // terminou, saiu, a corrida acabou ou o carro sumiu: tira a policia
            if (!NaCorrida[i] || !CorridaRodando || Veiculo[i] == INVALID_VEHICLE_ID || Veiculo[i] < 1)
            {
                PoliciaParar(i);
                continue;
            }
            PoliciaAtualizar(i, agora);
            continue;
        }
        if (NaCorrida[i] && CorridaRodando && Contagem < 0 && !Preso[i] && TotalCP >= 3
            && Veiculo[i] != INVALID_VEHICLE_ID && Veiculo[i] > 0
            && (agora - TempoInicio[i]) >= POL_INICIO_SEG)
        {
            PoliciaIniciar(i, 1);
        }
    }
    return 1;
}

public PresoTimer()
{
    new agora = gettime(), resta, texto[48];
    new Float:x, Float:y, Float:z, Float:dx, Float:dy;
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i) || !Preso[i]) continue;
        resta = PresoFim[i] - agora;
        if (resta <= 0)
        {
            PresoLiberar(i);
            continue;
        }
        // mantem o jogador dentro da cela
        GetPlayerPos(i, x, y, z);
        dx = x - CELA_X;
        dy = y - CELA_Y;
        if (GetPlayerInterior(i) != CELA_INT || floatsqroot(dx * dx + dy * dy) > 7.0) PresoEnviarCela(i);
        format(texto, sizeof(texto), "~r~PRESO ~w~%d:%02d", resta / 60, resta % 60);
        GameTextForPlayer(i, texto, 1100, 4);
    }
    return 1;
}

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
    AC_Resetar(playerid);
    AC_UltimoCPTime[playerid] = gettime();
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
    if ((ValorAposta > 0 || ModoDuelo || ModoRanqueada) && !ModoBots) minimo = 2;
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
    if (TimerContagemID) KillTimer(TimerContagemID);
    TimerContagemID = SetTimer("Contar", 1000, true);
    return 1;
}

public Contar()
{
    new texto[16];
    // 3, 2, 1 e VAI: o VAI e exibido uma unica vez.
    if (Contagem <= 0)
    {
        if (TimerContagemID) { KillTimer(TimerContagemID); TimerContagemID = 0; }
        for (new i = 0; i < MAX_PLAYERS; i++)
        {
            if (!IsPlayerConnected(i) || !NaCorrida[i]) continue;
            GameTextForPlayer(i, "~g~VAI!", 1000, 3);
            TogglePlayerControllable(i, 1);
            PlayerCP[i] = 1;
            MostrarCP(i);
            TempoInicio[i] = gettime();
            if (ModoDrag || MarchaManual[i]) MarchaIniciar(i); // drag = marcha manual obrigatoria
        }
        Contagem = -1;
        return 1;
    }
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i) || !NaCorrida[i]) continue;
        format(texto, sizeof(texto), "~r~%d", Contagem);
        GameTextForPlayer(i, texto, 900, 3);
    }
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
    PoliciaParar(playerid);
    TurboNivel[playerid] = 0;
    MarchaParar(playerid);
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
    if (TimerContagemID) { KillTimer(TimerContagemID); TimerContagemID = 0; }
    if (DueloAtivo) CancelarDuelo();
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i)) continue;
        MarchaParar(i);
        PoliciaParar(i);
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
    BotsRemover();
    ModoBots = false;
    ModoDrag = false;
    Participantes = 0;
    Chegaram = 0;
    ValorAposta = 0;
    PotAposta = 0;
    return 1;
}

// ============================================================
// CALLBACKS
// ============================================================

// ============================================================
// PAINT SPRAY - o menu abre quando o carro ENTRA na garagem
// ============================================================
#define TOTAL_PAINT          10
#define PAINT_REMOVER_PORTA  1      // 1 = remove a porta (visual) para ela nao fechar | 0 = deixa a porta original
#define PRECO_PAINTJOB       15000

// Posicao da porta de cada Pay 'n' Spray de San Andreas
new Float:PaintPos[TOTAL_PAINT][3] = {
    {2071.48, -1831.42, 14.56},   // Idlewood/Willowfield (LS)
    {1024.98, -1029.35, 33.20},   // Temple (LS)
    {488.28, -1734.70, 12.39},    // Santa Maria Beach (LS)
    {720.02, -462.52, 16.86},     // Dillimore
    {-1904.53, 277.90, 42.95},    // Doherty (SF)
    {-1786.81, 1209.42, 25.84},   // Downtown - Michelle's (SF)
    {-2425.73, 1027.99, 52.28},   // Juniper Hollow (SF)
    {1968.74, 2162.49, 12.09},    // Redsands East (LV)
    {-1420.55, 2591.16, 57.74},   // El Quebrados
    {-100.00, 1111.41, 21.64}     // Fort Carson
};

// Estado da deteccao: 0 longe | 1 perto (fora) | 3 armado (vindo para a porta) | 2 DENTRO | 4 ignorar ate sair
new PSEstado[MAX_PLAYERS], PSGar[MAX_PLAYERS];
new Float:PSUlt[MAX_PLAYERS][2], Float:PSDir[MAX_PLAYERS][2];
new bool:PSDebug[MAX_PLAYERS];

// Pecas de carroceria (teto, para-choques, escapamento, saias)
new PecaTipo[5]  = {CARMODTYPE_ROOF, CARMODTYPE_FRONT_BUMPER, CARMODTYPE_REAR_BUMPER, CARMODTYPE_EXHAUST, CARMODTYPE_SIDESKIRT};
new PecaCampo[5] = {F_ROOF, F_FB, F_RB, F_EXH, F_SKI};
new PecaPreco[5] = {8000, 10000, 10000, 8000, 8000};
new PecaNome[5][24] = {"Teto", "Para-choque dianteiro", "Para-choque traseiro", "Escapamento", "Saia lateral"};
new PecaCat[MAX_PLAYERS], PecaQtd[MAX_PLAYERS], PecaLista[MAX_PLAYERS][24];

stock MostrarMenuPaintSpray(playerid)
{
    new texto[640];
    format(texto, sizeof(texto),
        "Nitro\nAerofolio\nRodas\nHidraulica - $20000\nNeon - $25000\nPintura - $5000\nReparar - $2000\nTurbo (3 niveis)\nTeto - $%d\nPara-choque dianteiro - $%d\nPara-choque traseiro - $%d\nEscapamento - $%d\nSaias laterais - $%d\nPaintjob - $%d",
        PecaPreco[0], PecaPreco[1], PecaPreco[2], PecaPreco[3], PecaPreco[4], PRECO_PAINTJOB);
    ShowPlayerDialog(playerid, D_TUNING, DIALOG_STYLE_LIST, "Paint Spray - Street Racing BR", texto, "Escolher", "Sair");
    return 1;
}

stock AbrirPecas(playerid, cat)
{
    new v = GetPlayerVehicleID(playerid);
    if (v == INVALID_VEHICLE_ID || SlotDoTuning(playerid) < 0) return 0;
    new modelo = GetVehicleModel(v);
    PecaCat[playerid] = cat;
    PecaQtd[playerid] = 0;
    for (new comp = 1000; comp <= 1193 && PecaQtd[playerid] < 24; comp++)
    {
        if (GetVehicleComponentType(comp) != PecaTipo[cat]) continue;
        if (!PecaCompativel(modelo, comp)) continue;
        PecaLista[playerid][PecaQtd[playerid]] = comp;
        PecaQtd[playerid]++;
    }
    if (PecaQtd[playerid] == 0)
    {
        #if PS_COMPAT
            SendClientMessage(playerid, 0xFF0000FF, "Esse carro nao tem essa peca disponivel.");
        #else
            SendClientMessage(playerid, 0xFF0000FF, "Pecas de carroceria indisponiveis: o servidor nao consegue validar a compatibilidade (precisa open.mp).");
        #endif
        MostrarMenuPaintSpray(playerid);
        return 0;
    }
    new lista[900], linha[72], s = SlotAtivo[playerid];
    format(lista, sizeof(lista), "Remover %s (gratis)\n", PecaNome[cat]);
    for (new i = 0; i < PecaQtd[playerid]; i++)
    {
        new c = PecaLista[playerid][i];
        new bool:instalado = (c == Garagem[playerid][s][PecaCampo[cat]]) || (cat == 4 && c == Garagem[playerid][s][F_SKI2]);
        if (instalado) format(linha, sizeof(linha), "%s %d - $%d (instalado)\n", PecaNome[cat], i + 1, PecaPreco[cat]);
        else format(linha, sizeof(linha), "%s %d - $%d\n", PecaNome[cat], i + 1, PecaPreco[cat]);
        strcat(lista, linha);
    }
    ShowPlayerDialog(playerid, D_PECAS, DIALOG_STYLE_LIST, PecaNome[cat], lista, "Instalar", "Voltar");
    return 1;
}

stock AbrirPaintjobs(playerid)
{
    new v = GetPlayerVehicleID(playerid);
    if (v == INVALID_VEHICLE_ID || SlotDoTuning(playerid) < 0) return 0;
    if (!ModeloTemPaintjob(GetVehicleModel(v)))
    {
        SendClientMessage(playerid, 0xFF0000FF, "Esse carro nao aceita paintjob.");
        MostrarMenuPaintSpray(playerid);
        return 0;
    }
    new texto[200];
    format(texto, sizeof(texto), "Remover paintjob (gratis)\nPaintjob 1 - $%d\nPaintjob 2 - $%d\nPaintjob 3 - $%d", PRECO_PAINTJOB, PRECO_PAINTJOB, PRECO_PAINTJOB);
    ShowPlayerDialog(playerid, D_PAINTJOB, DIALOG_STYLE_LIST, "Paintjobs", texto, "Aplicar", "Voltar");
    return 1;
}

// O Paint Spray do jogo repinta o carro no cliente. Aqui a cor salva na garagem
// e reaplicada, entao a cor so muda pelo menu de tunagem.
stock RestaurarCorPS(playerid)
{
    new v = GetPlayerVehicleID(playerid);
    new s = SlotAtivo[playerid];
    if (v == 0 || v != CarroPessoal[playerid] || s < 0 || s >= MAX_SLOTS) return 0;
    ChangeVehicleColor(v, Garagem[playerid][s][F_COR1], Garagem[playerid][s][F_COR2]);
    return 1;
}
public RestaurarCorPSTimer(playerid)
{
    if (IsPlayerConnected(playerid)) RestaurarCorPS(playerid);
    return 1;
}
stock EntrouPaintSpray(playerid)
{
    if (NoCarroPessoal(playerid) && SlotAtivo[playerid] >= 0 && !SlotTravado[playerid][SlotAtivo[playerid]])
    {
        MostrarMenuPaintSpray(playerid);
        GameTextForPlayer(playerid, "~g~PAINT SPRAY", 1800, 3);
    }
    else SendClientMessage(playerid, 0xFFCC00FF, "Entre com seu carro pessoal (/garagem) no Paint Spray para personalizar.");
    return 1;
}

stock RemoverPortasPaint(playerid)
{
    #if PAINT_REMOVER_PORTA
        // Remove so a porta (raio pequeno em volta do centro dela) para ela nunca fechar.
        for (new g = 0; g < TOTAL_PAINT; g++)
            RemoveBuildingForPlayer(playerid, -1, PaintPos[g][0], PaintPos[g][1], PaintPos[g][2], 2.5);
    #else
        #pragma unused playerid
    #endif
    return 1;
}

stock PSMsg(playerid, const texto[])
{
    if (PSDebug[playerid]) SendClientMessage(playerid, 0x00FFFFFF, texto);
    return 1;
}

forward VerificaPaintSpray();
public VerificaPaintSpray()
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if (!IsPlayerConnected(playerid)) continue;
        new vehicleid = GetPlayerVehicleID(playerid);
        if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER || vehicleid == INVALID_VEHICLE_ID || NaCorrida[playerid])
        {
            PSEstado[playerid] = 0;
            PSGar[playerid] = -1;
            continue;
        }

        new Float:x, Float:y, Float:z;
        GetVehiclePos(vehicleid, x, y, z);

        // garagem mais proxima (mesma altura)
        new gar = -1, Float:melhor = 9999.0;
        for (new g = 0; g < TOTAL_PAINT; g++)
        {
            if (floatabs(z - PaintPos[g][2]) > 6.0) continue;
            new Float:gdx = x - PaintPos[g][0], Float:gdy = y - PaintPos[g][1];
            new Float:gd = floatsqroot(gdx * gdx + gdy * gdy);
            if (gd < melhor) { melhor = gd; gar = g; }
        }
        if (gar == -1 || melhor > 30.0)
        {
            PSEstado[playerid] = 0;
            PSGar[playerid] = -1;
            continue;
        }
        if (PSGar[playerid] != gar) { PSGar[playerid] = gar; PSEstado[playerid] = 0; }

        new Float:rx = x - PaintPos[gar][0], Float:ry = y - PaintPos[gar][1];
        new est = PSEstado[playerid];
        new msg[96];

        if (est == 0)
        {
            PSUlt[playerid][0] = x;
            PSUlt[playerid][1] = y;
            if (melhor > 12.0) PSEstado[playerid] = 1;
            else PSEstado[playerid] = 4; // ja apareceu perto/dentro: ignora ate se afastar
        }
        else if (est == 4)
        {
            if (melhor > 18.0) { PSEstado[playerid] = 1; PSUlt[playerid][0] = x; PSUlt[playerid][1] = y; }
        }
        else if (est == 1)
        {
            if (melhor > 12.0)
            {
                PSUlt[playerid][0] = x;
                PSUlt[playerid][1] = y;
            }
            else
            {
                new Float:ax = PaintPos[gar][0] - PSUlt[playerid][0], Float:ay = PaintPos[gar][1] - PSUlt[playerid][1];
                new Float:alen = floatsqroot(ax * ax + ay * ay);
                if (alen < 1.0) PSEstado[playerid] = 4;
                else
                {
                    PSDir[playerid][0] = ax / alen;
                    PSDir[playerid][1] = ay / alen;
                    PSEstado[playerid] = 3;
                    PSMsg(playerid, "[PS] chegando na porta");
                }
            }
        }
        else if (est == 3)
        {
            new Float:proj = rx * PSDir[playerid][0] + ry * PSDir[playerid][1];
            new Float:lat = floatabs(rx * PSDir[playerid][1] - ry * PSDir[playerid][0]);
            if (melhor > 16.0)
            {
                PSEstado[playerid] = 1;
                PSUlt[playerid][0] = x;
                PSUlt[playerid][1] = y;
            }
            else if (proj < 1.0 && melhor > 6.0)
            {
                // ainda do lado de fora: acompanha a direcao da aproximacao
                new Float:ax = -rx, Float:ay = -ry;
                new Float:alen = floatsqroot(ax * ax + ay * ay);
                if (alen > 0.5) { PSDir[playerid][0] = ax / alen; PSDir[playerid][1] = ay / alen; }
            }
            else if (proj > 3.0 && lat < 4.5)
            {
                // passou da porta e esta dentro da garagem
                PSEstado[playerid] = 2;
                format(msg, sizeof(msg), "[PS] DENTRO (prof=%.1f lat=%.1f)", proj, lat);
                PSMsg(playerid, msg);
                EntrouPaintSpray(playerid);
            }
        }
        else if (est == 2)
        {
            RestaurarCorPS(playerid); // dentro da garagem: mantem a cor salva
            new Float:proj2 = rx * PSDir[playerid][0] + ry * PSDir[playerid][1];
            if (proj2 < 0.5 || melhor > 16.0)
            {
                PSEstado[playerid] = 1;
                PSUlt[playerid][0] = x;
                PSUlt[playerid][1] = y;
                PSMsg(playerid, "[PS] saiu da garagem");
                RestaurarCorPS(playerid);
                SetTimerEx("RestaurarCorPSTimer", 1500, false, "i", playerid);
            }
        }
    }
    return 1;
}

// ============================================================
// SERVIDOR SEMPRE DE NOITE
// ============================================================
#define HORA_FIXA     0     // 0 = meia-noite (22, 23 ou 1 ficam mais claros)
#define CLIMA_FIXO    10    // 10 = ceu limpo

stock AplicarNoitePlayer(playerid)
{
    SetPlayerTime(playerid, HORA_FIXA, 0);
    SetPlayerWeather(playerid, CLIMA_FIXO);
    return 1;
}

forward AplicarNoite();
public AplicarNoite()
{
    SetWorldTime(HORA_FIXA);
    for (new i = 0; i < MAX_PLAYERS; i++)
        if (IsPlayerConnected(i)) AplicarNoitePlayer(i);
    return 1;
}

public OnGameModeInit()
{
    SetWeather(CLIMA_FIXO);
    AplicarNoite();
    SetTimer("AplicarNoite", 5000, true);
    SetGameModeText("Street Racing BR v3");
    UsePlayerPedAnims();
    EnableStuntBonusForAll(0);
    AddPlayerClass(0,   1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(29,  1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(60,  1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    AddPlayerClass(106, 1759.0, -1898.0, 13.56, 270.0, 0, 0, 0, 0, 0, 0);
    SetTimer("MantemDinheiro", 3000, true);
    SetTimer("BoostAdm", 50, true);
    // Anticheat automatico desativado a pedido do administrador; moderacao manual.
    SetTimer("TurboTimer", 100, true);
    SetTimer("MarchaTimer", 50, true);
    SetTimer("BotTimer", 50, true);
    SetTimer("PoliciaTimer", POL_TICK, true);
    SetTimer("PresoTimer", 1000, true);
    SetTimer("VerificaPaintSpray", 200, true);
    for (new b = 0; b < BOTS_QTD; b++) BotNpc[b] = SEM_NPC;
    CarregarPistaAtual();
    CarregarLargadas();
    return 1;
}

public OnPlayerConnect(playerid)
{
    // NPCs (bots e policia) tambem "conectam" no open.mp: nada de login/registro para eles
    if (NpcCriando || IsPlayerNPC(playerid))
    {
        NaCorrida[playerid] = false;
        Preso[playerid] = false;
        PolAtivo[playerid] = false;
        PolTDok[playerid] = false;
        Logado[playerid] = false;
        Carregado[playerid] = false;
        DinheiroInf[playerid] = false;
        MarchaAtiva[playerid] = false;
        EntregaAtiva[playerid] = false;
        Veiculo[playerid] = INVALID_VEHICLE_ID;
        CarroPessoal[playerid] = INVALID_VEHICLE_ID;
        CarroAdm[playerid] = INVALID_VEHICLE_ID;
        SlotCorrida[playerid] = -1;
        SlotAtivo[playerid] = -1;
        return 1;
    }
    AplicarNoitePlayer(playerid);
    RemoverPortasPaint(playerid);
    PSEstado[playerid] = 0;
    PSGar[playerid] = -1;
    PSDebug[playerid] = false;
    MarchaAtiva[playerid] = false;
    MarchaManual[playerid] = false;
    MarchaMorto[playerid] = false;
    NaCorrida[playerid] = false;
    Preso[playerid] = false;
    PolAtivo[playerid] = false;
    PolTDok[playerid] = false;
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
    if (IsPlayerNPC(playerid))
    {
        NpcNoCarro[playerid] = false;
        NpcPendVeic[playerid] = 0;
        return 1;
    }
    SairCorrida(playerid, 0);
    PoliciaParar(playerid);
    if (Preso[playerid]) PresoSalvar(playerid);
    Preso[playerid] = false;
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
    if (IsPlayerNPC(playerid)) return 1; // bots e policia nao passam por login/cela/bonus
    AplicarNoitePlayer(playerid);
    if (!Logado[playerid])
    {
        SetPlayerPos(playerid, 1759.0, -1898.0, 13.56);
        return 1;
    }
    if (Preso[playerid] || PresoCarregar(playerid))
    {
        PresoEnviarCela(playerid);
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

public OnPlayerKeyStateChange(playerid, t_KEY:newkeys, t_KEY:oldkeys)
{
    // Toque no acelerador (KEY_SPRINT no veiculo) para trocar de marcha
    if (MarchaAtiva[playerid] && (newkeys & KEY_SPRINT) && !(oldkeys & KEY_SPRINT))
        MarchaToque(playerid);
    return 1;
}

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
    // Evento especial: um unico checkpoint no spawn normal. Premio apenas em dinheiro.
    if (EventoADMAtivo && EventoParticipa[playerid] && !EventoVencedorDefinido)
    {
        EventoVencedorDefinido = true;
        EventoADMAtivo = false;
        EventoParticipa[playerid] = false;
        DisablePlayerRaceCheckpoint(playerid);
        GivePlayerMoney(playerid, 70000);
        SalvarConta(playerid);
        new nomeEvento[MAX_PLAYER_NAME], avisoEvento[144];
        GetPlayerName(playerid, nomeEvento, sizeof(nomeEvento));
        format(avisoEvento, sizeof(avisoEvento), "[EVENTO] %s venceu a corrida e recebeu $70.000!", nomeEvento);
        SendClientMessageToAll(0x00FF00FF, avisoEvento);
        return 1;
    }
    if (!NaCorrida[playerid] || !CorridaRodando) return 1;
    // Ignora callback invalido e impede avancar para fora da lista de checkpoints.
    if (PlayerCP[playerid] < 1 || PlayerCP[playerid] >= TotalCP) return 1;

    // Detecta chegada extremamente rapida ao proximo checkpoint.
    new cpAnterior = PlayerCP[playerid] - 1;
    new cpAtual = PlayerCP[playerid];
    new Float:dxcp = CPs[cpAtual][0] - CPs[cpAnterior][0];
    new Float:dycp = CPs[cpAtual][1] - CPs[cpAnterior][1];
    new Float:distcp = floatsqroot(dxcp * dxcp + dycp * dycp);
    new agoraCP = gettime();
    new tempoCP = agoraCP - AC_UltimoCPTime[playerid];
    if (AC_UltimoCPTime[playerid] == 0) tempoCP = agoraCP - TempoInicio[playerid];

    // Para trechos longos, exigir uma velocidade absurdamente alta para marcar suspeita.
    if (distcp > 250.0 && tempoCP <= 1)
    {
        if (AC_Registrar(playerid, "checkpoint atingido rapido demais") == 2)
            return 1;
    }
    AC_UltimoCPTime[playerid] = agoraCP;

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
            if (Chegaram == 1) { premio = 50000 + (RankPontos[playerid] * 1000); RankPontos[playerid] += (ModoBots ? BOTS_PONTOS_VITORIA : 5); }
            else if (Chegaram == 2) { premio = 20000; if (!ModoBots) RankPontos[playerid] += 3; }
            else { premio = 8000; if (!ModoBots) RankPontos[playerid] += 1; }
            if (ModoBots) premio = premio * BOTS_PREMIO_PCT / 100;
            GivePlayerMoney(playerid, premio);
            SalvarConta(playerid);
            format(msg, sizeof(msg), "[RANQUEADA] %d lugar: %s! +$%d | Pontos: %d (%s)", Chegaram, nome, premio, RankPontos[playerid], RankNome[RankDoJogador(playerid)]);
            SendClientMessageToAll(0x00FFFFFF, msg);
            if (Chegaram >= Participantes) AgendarReset(5000);
            return 1;
        }

        if (ValorAposta > 0) { if (Chegaram == 1) premio = PotAposta - (PotAposta * TAXA_APOSTA / 100); }
        else premio = 20000 / Chegaram;
        if (ModoBots && premio > 0) premio = premio * BOTS_PREMIO_PCT / 100;
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
    // RCON admins can use admin commands even before logging into a game account.
    // Regular players must still log into their account before using gameplay commands.
    if (!Logado[playerid] && !IsPlayerAdmin(playerid))
    {
        SendClientMessage(playerid, 0xFF0000FF, "Faca login primeiro!");
        return 1;
    }

    // PRESO: bloqueia todos os comandos ate cumprir a pena (admin RCON ignora)
    if (Preso[playerid] && !IsPlayerAdmin(playerid))
    {
        new restaPreso = PresoFim[playerid] - gettime();
        new msgPreso[80];
        if (restaPreso < 0) restaPreso = 0;
        format(msgPreso, sizeof(msgPreso), "Voce esta preso! Faltam %d:%02d para ser solto.", restaPreso / 60, restaPreso % 60);
        SendClientMessage(playerid, 0xFF0000FF, msgPreso);
        return 1;
    }

    // ADMIN: /soltar [id] solta alguem da cela (sem id = voce mesmo)
    if (!strcmp(cmdtext, "/soltar", true, 7))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas o administrador RCON pode usar /soltar.");
        new alvoSoltar = playerid;
        if (strlen(cmdtext) > 8) alvoSoltar = strval(cmdtext[8]);
        if (alvoSoltar < 0 || alvoSoltar >= MAX_PLAYERS || !IsPlayerConnected(alvoSoltar) || !Preso[alvoSoltar])
            return SendClientMessage(playerid, 0xFF0000FF, "Jogador nao esta preso. Use /soltar [id].");
        PresoLiberar(alvoSoltar);
        return SendClientMessage(playerid, 0x00FF00FF, "Jogador solto.");
    }

    // ADMIN: /policia [1-5] chama a policia agora (para testar) durante uma corrida ja iniciada
    if (!strcmp(cmdtext, "/policia", true, 8))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas o administrador RCON pode usar /policia.");
        if (!NaCorrida[playerid] || !CorridaRodando || Contagem >= 0 || Veiculo[playerid] == INVALID_VEHICLE_ID)
            return SendClientMessage(playerid, 0xFF0000FF, "Use durante uma corrida ja iniciada (depois do VAI).");
        new nivelTeste = 1;
        if (strlen(cmdtext) > 9) nivelTeste = strval(cmdtext[9]);
        if (nivelTeste < 1 || nivelTeste > POL_NIVEL_MAX) return SendClientMessage(playerid, 0xFF0000FF, "Use /policia [1-5].");
        if (PolAtivo[playerid]) PoliciaParar(playerid);
        PoliciaIniciar(playerid, nivelTeste);
        return 1;
    }


    // Cria uma rampa fixa alguns metros a frente do administrador.
    if (!strcmp(cmdtext, "/rampa", true))
    {
        if (!IsPlayerAdmin(playerid))
            return SendClientMessage(playerid, 0xFF0000FF, "Apenas o administrador RCON pode criar rampas.");
        if (TotalRampasMapa >= MAX_RAMPAS_MAPA)
            return SendClientMessage(playerid, 0xFFCC00FF, "Limite de rampas atingido (50).");

        new Float:x, Float:y, Float:z, Float:angulo;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, angulo);
        // Coloca a rampa a frente do jogador, no chao; fica fixa no mundo, nao no jogador.
        x += 4.0 * floatsin(-angulo, degrees);
        y += 4.0 * floatcos(-angulo, degrees);
        RampaObjeto[TotalRampasMapa] = CreateObject(1632, x, y, z - 0.8, 0.0, 0.0, angulo);
        if (RampaObjeto[TotalRampasMapa] == INVALID_OBJECT_ID)
            return SendClientMessage(playerid, 0xFF0000FF, "Nao foi possivel criar a rampa.");
        TotalRampasMapa++;
        SendClientMessage(playerid, 0x00FF00FF, "Rampa criada e fixa neste local! Ela permanece ate o servidor reiniciar.");
        return 1;
    }

    if (!strcmp(cmdtext, "/dartag", true, 7) && (cmdtext[7] == ' ' || cmdtext[7] == '\0'))
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

    if (!strcmp(cmdtext, "/tirartag", true, 9) && (cmdtext[9] == ' ' || cmdtext[9] == '\0'))
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

    if (!strcmp(cmdtext, "/statusadm", true))
    {
        if (IsPlayerAdmin(playerid))
            return SendClientMessage(playerid, 0x00FF00FF, "Status: autenticado como administrador RCON.");
        return SendClientMessage(playerid, 0xFFCC00FF, "Status: sem permissao RCON. Use /rcon login SUA_SENHA.");
    }

    // ANTI-CHEAT: banimento manual por IP atraves do jogador conectado.
    if (!strcmp(cmdtext, "/ban", true, 4) && (cmdtext[4] == ' ' || cmdtext[4] == 0))
    {
        if (!IsPlayerAdmin(playerid))
            return SendClientMessage(playerid, 0xFF0000FF, "Apenas o dono/admin (RCON) pode usar este comando.");

        if (cmdtext[4] != ' ')
            return SendClientMessage(playerid, 0xFFFF00FF, "Use: /ban [ID] [motivo]");

        new resto[160], idTexto[8], motivo[128];
        strmid(resto, cmdtext, 5, strlen(cmdtext), sizeof(resto));
        new p = 0;
        while (resto[p] == ' ') p++;
        new j = 0;
        while (resto[p] != ' ' && resto[p] != 0 && j < sizeof(idTexto)-1)
            idTexto[j++] = resto[p++];
        idTexto[j] = 0;
        while (resto[p] == ' ') p++;
        format(motivo, sizeof(motivo), "%s", resto[p]);

        new alvo = strval(idTexto);
        if (!IsPlayerConnected(alvo) || alvo == playerid)
            return SendClientMessage(playerid, 0xFF0000FF, "Jogador invalido.");
        if (!motivo[0])
            format(motivo, sizeof(motivo), "Banimento manual pelo administrador");

        new ip[16], nomeAlvo[MAX_PLAYER_NAME], msg[192];
        GetPlayerIp(alvo, ip, sizeof(ip));
        GetPlayerName(alvo, nomeAlvo, sizeof(nomeAlvo));
        format(msg, sizeof(msg), "[BAN] %s (ID %d) banido por IP %s. Motivo: %s", nomeAlvo, alvo, ip, motivo);
        SendClientMessage(playerid, 0xFF0000FF, msg);
        BanEx(alvo, motivo);
        return 1;
    }

    // Exibe o IP de um jogador conectado para o administrador.
    if (!strcmp(cmdtext, "/ip", true, 3) && (cmdtext[3] == ' ' || cmdtext[3] == 0))
    {
        if (!IsPlayerAdmin(playerid))
            return SendClientMessage(playerid, 0xFF0000FF, "Apenas o dono/admin (RCON) pode usar este comando.");
        if (cmdtext[3] != ' ')
            return SendClientMessage(playerid, 0xFFFF00FF, "Use: /ip [ID]");

        new idTexto[8];
        strmid(idTexto, cmdtext, 4, strlen(cmdtext), sizeof(idTexto));
        new alvo = strval(idTexto);
        if (!IsPlayerConnected(alvo))
            return SendClientMessage(playerid, 0xFF0000FF, "Jogador invalido.");

        new ip[16], nomeAlvo[MAX_PLAYER_NAME], msg[128];
        GetPlayerIp(alvo, ip, sizeof(ip));
        GetPlayerName(alvo, nomeAlvo, sizeof(nomeAlvo));
        format(msg, sizeof(msg), "%s (ID %d) - IP: %s", nomeAlvo, alvo, ip);
        return SendClientMessage(playerid, 0x00FF00FF, msg);
    }

    if (!strcmp(cmdtext, "/acreset", true, 7) && (cmdtext[7] == ' ' || cmdtext[7] == 0))
    {
        if (!IsPlayerAdmin(playerid))
            return SendClientMessage(playerid, 0xFF0000FF, "Apenas o dono/admin (RCON) pode usar este comando.");
        if (cmdtext[7] != ' ')
            return SendClientMessage(playerid, 0xFFFF00FF, "Use: /acreset [ID]");

        new idTexto[8];
        strmid(idTexto, cmdtext, 8, strlen(cmdtext), sizeof(idTexto));
        new alvo = strval(idTexto);
        if (!IsPlayerConnected(alvo))
            return SendClientMessage(playerid, 0xFF0000FF, "Jogador invalido.");

        AC_Avisos[alvo] = 0;
        AC_UltimoAviso[alvo] = 0;
        SendClientMessage(playerid, 0x00FF00FF, "Contador de avisos do anti-cheat resetado.");
        return 1;
    }


    if (!strcmp(cmdtext, "/radio", true))
    {
        ShowPlayerDialog(playerid, D_RADIO, DIALOG_STYLE_LIST, "Radio pessoal",
            "Ti - 24s\nOverseer - Doomsday\nThe Crystal Method - Born Too Slow\nFortress - Europe",
            "Tocar", "Fechar");
        return 1;
    }

    if (!strcmp(cmdtext, "/pararradio", true))
    {
        StopAudioStreamForPlayer(playerid);
        SendClientMessage(playerid, 0x00FF00FF, "Radio parado.");
        return 1;
    }

    if (!strcmp(cmdtext, "/ajuda", true))
    {
        SendClientMessage(playerid, 0xFFFF00FF, "=== COMANDOS ===");
        SendClientMessage(playerid, 0xFFFF00FF, "/corrida /ranqueada /tempo /drag /marcha /sair /pistas /dragsolo /ranqueadasolo");
        SendClientMessage(playerid, 0xFFFF00FF, "/loja /garagem /guardar /rank /toprank (tuning: entre no Paint Spray com seu carro)");
        SendClientMessage(playerid, 0xFFFF00FF, "/radio /pararradio");
        SendClientMessage(playerid, 0xFFFF00FF, "/anunciarcarro [preco] /mercado /comprarcarro [id]");
        SendClientMessage(playerid, 0xFFFF00FF, "/apostacarro [id] /entrega /cancelarentrega /pos");
        SendClientMessage(playerid, 0xFFFF00FF, "/promo CODIGO (resgatar promocao)");
        SendClientMessage(playerid, 0xFFCC00FF, "ADM: /all mensagem | /criarpromo CODIGO VALOR | /dardinheiro ID VALOR | /criarevento | /encerr evento");
        SendClientMessage(playerid, 0xFFFF00FF, "Evento: /entrar evento | premio $70.000, sem carro.");
        SendClientMessage(playerid, 0xFFCC00FF, "ADM: /statusadm | /elegyadm | /dinheiro | /dinheiroinf");
        SendClientMessage(playerid, 0xFFCC00FF, "ADM: /ban ID motivo | /ip ID | /acreset ID");
        return 1;
    }

    // Evento de corrida: /criarevento, /entrar evento e /encerr evento
    if (!strcmp(cmdtext, "/criarevento", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        if (EventoADMAtivo) return SendClientMessage(playerid, 0xFFFF00FF, "Ja existe um evento ativo.");
        EventoADMAtivo = true;
        EventoVencedorDefinido = false;
        for (new i = 0; i < MAX_PLAYERS; i++) EventoParticipa[i] = false;
        SendClientMessageToAll(0xFFFF00FF, "[EVENTO] Corrida aberta! Use /entrar evento para participar. Largada: Mount Chiliad. Premio: $70.000.");
        return 1;
    }
    if (!strcmp(cmdtext, "/entrar evento", true))
    {
        if (!EventoADMAtivo) return SendClientMessage(playerid, 0xFF0000FF, "Nao ha evento aberto.");
        if (EventoParticipa[playerid]) return SendClientMessage(playerid, 0xFFFF00FF, "Voce ja entrou no evento.");
        EventoParticipa[playerid] = true;
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, -2320.0, -1620.0, 483.7);
        SetPlayerFacingAngle(playerid, 0.0);
        SetPlayerRaceCheckpoint(playerid, 1, 1759.0, -1898.0, 13.56, 0.0, 0.0, 0.0, 8.0);
        SendClientMessage(playerid, 0x00FF00FF, "Voce entrou no evento! Use /garagem para escolher seu carro. Chegue ao spawn normal primeiro para ganhar $70.000.");
        return 1;
    }
    if (!strcmp(cmdtext, "/encerr evento", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        EventoADMAtivo = false;
        EventoVencedorDefinido = true;
        for (new i = 0; i < MAX_PLAYERS; i++) { EventoParticipa[i] = false; DisablePlayerRaceCheckpoint(i); }
        SendClientMessageToAll(0xFF0000FF, "[EVENTO] Evento encerrado pelo administrador.");
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

    // MARCHA: manual ou automatica
    if (!strcmp(cmdtext, "/marcha", true) || !strcmp(cmdtext, "/macha", true))
    {
        ShowPlayerDialog(playerid, D_MARCHA, DIALOG_STYLE_LIST, "Tipo de marcha",
            "Automatica\nManual (toque 2x no acelerador)", "Escolher", "Fechar");
        return 1;
    }

    // CORRIDA DRAG (linha reta, marcha manual)
    if (!strcmp(cmdtext, "/drag", true))
    {
        AbrirDrag(playerid);
        return 1;
    }

    // SOLO CONTRA BOTS
    if (!strcmp(cmdtext, "/dragsolo", true))
    {
        AbrirSoloBots(playerid, true);
        return 1;
    }
    if (!strcmp(cmdtext, "/ranqueadasolo", true))
    {
        AbrirSoloBots(playerid, false);
        return 1;
    }

    // MENU DE CORRIDA
    if (!strcmp(cmdtext, "/corrida", true))
    {
        if (CorridaRodando || CorridaAberta || ModoDuelo) return SendClientMessage(playerid, 0xFF0000FF, "Ja existe uma corrida aberta ou em andamento.");
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Voce ja esta na corrida.");
        if (TotalCP < 3) return SendClientMessage(playerid, 0xFF0000FF, "Pista nao configurada.");
        if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem (/garagem).");
        ShowPlayerDialog(playerid, D_MODO_CORRIDA, DIALOG_STYLE_LIST, "Modo de corrida",
            "Corrida amistosa (aposta opcional)\nCorrida ranqueada (min. 2 jogadores)\nCorrida contra o tempo (solo)\nDrag (linha reta + marcha manual)\nDrag solo (contra bots)\nRanqueada solo (contra bots)",
            "Escolher", "Fechar");
        return 1;
    }

    if (!strcmp(cmdtext, "/entrarcorrida", true))
    {
        if (!CorridaAberta || CorridaRodando || ModoRanqueada || ModoTempo || ModoDuelo || ModoBots)
            return SendClientMessage(playerid, 0xFF0000FF, "Nao existe corrida amistosa aberta para entrar.");
        if (NaCorrida[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Voce ja esta nessa corrida.");
        if (TotalCP < 3) return SendClientMessage(playerid, 0xFF0000FF, "Pista nao configurada.");
        if (!NoCarroPessoal(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Entre no carro da garagem (/garagem).");
        if (ValorAposta > 0 && !Cobrar(playerid, ValorAposta)) return 1;
        if (!EntrarNaCorrida(playerid, 8))
        {
            if (ValorAposta > 0) GivePlayerMoney(playerid, ValorAposta);
            return SendClientMessage(playerid, 0xFF0000FF, "Nao foi possivel entrar na corrida.");
        }
        PotAposta += ValorAposta;
        new nome[MAX_PLAYER_NAME], msg[144];
        GetPlayerName(playerid, nome, sizeof(nome));
        if (ValorAposta > 0) format(msg, sizeof(msg), "%s entrou na corrida amistosa! Aposta: $%d.", nome, ValorAposta);
        else format(msg, sizeof(msg), "%s entrou na corrida amistosa gratuita!", nome);
        SendClientMessageToAll(0x00FF00FF, msg);
        return 1;
    }

    if (!strcmp(cmdtext, "/ranqueada", true))
    {
        if (ModoBots) return SendClientMessage(playerid, 0xFF0000FF, "Corrida solo contra bots em andamento.");
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
        if (ModoBots) return SendClientMessage(playerid, 0xFF0000FF, "Corrida solo contra bots em andamento.");
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

    if (!strcmp(cmdtext, "/psdebug", true))
    {
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM.");
        PSDebug[playerid] = !PSDebug[playerid];
        if (PSDebug[playerid]) SendClientMessage(playerid, 0x00FFFFFF, "Debug do Paint Spray LIGADO.");
        else SendClientMessage(playerid, 0x00FFFFFF, "Debug do Paint Spray DESLIGADO.");
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
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM RCON. Use /rcon login SUA_SENHA.");
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
        if (!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "Apenas ADM RCON. Use /rcon login SUA_SENHA.");
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
                    CarregarTurbos(playerid);
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
        NovoCarroSlot(playerid, 0, 401); // Bravura inicial gratis
        SalvarConta(playerid);
        CarregarTurbos(playerid);
        SendClientMessage(playerid, 0x00FF00FF, "Conta criada! Voce recebeu $1000 e um Bravura!");
        SendClientMessage(playerid, 0xFFFF00FF, "Use /garagem para pegar o carro e /corrida para competir!");
        SpawnPlayer(playerid);
        return 1;
    }

    if (!Logado[playerid]) return 1;
    if (!response) return 1;

    switch (dialogid)
    {
        // MARCHA: automatica ou manual
        case D_MARCHA:
        {
            MarchaManual[playerid] = (listitem == 1);
            if (MarchaManual[playerid]) SendClientMessage(playerid, 0x00FF00FF, "Marcha MANUAL ativada. Nas corridas, toque 2x no acelerador quando a luz vermelha piscar. No modo drag ela e obrigatoria.");
            else SendClientMessage(playerid, 0x00FF00FF, "Marcha AUTOMATICA ativada. (No modo drag a marcha manual e obrigatoria.)");
        }

        // RADIO PESSOAL: cada jogador ouve apenas a propria selecao.
        case D_RADIO:
        {
            if (!response) return 1;
            switch (listitem)
            {
                case 0: PlayAudioStreamForPlayer(playerid, "https://ia600607.us.archive.org/25/items/fortress-europe-mp-3.pm/Ti_-_24s_%28mp3.pm%29.mp3");
                case 1: PlayAudioStreamForPlayer(playerid, "https://ia600607.us.archive.org/25/items/fortress-europe-mp-3.pm/Overseer_-_Doomsday_%28mp3.pm%29.mp3");
                case 2: PlayAudioStreamForPlayer(playerid, "https://ia600607.us.archive.org/25/items/fortress-europe-mp-3.pm/OST_NFS_Underground_-_The_Chrystal_Method_-_Born_To_Slow_%28mp3.pm%29.mp3");
                case 3: PlayAudioStreamForPlayer(playerid, "https://ia600607.us.archive.org/25/items/fortress-europe-mp-3.pm/Fortress_-_Europe_%28mp3.pm%29.mp3");
            }
            SendClientMessage(playerid, 0x00FF00FF, "Se a musica nao tocar, o link pode estar inacessivel ao cliente SA-MP.");
            return 1;
        }

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
            else if (listitem == 3) // drag
            {
                AbrirDrag(playerid);
            }
            else if (listitem == 4) // drag solo com bots
            {
                AbrirSoloBots(playerid, true);
            }
            else if (listitem == 5) // ranqueada solo com bots
            {
                AbrirSoloBots(playerid, false);
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
            if (valor > 0) { format(msg, sizeof(msg), "Corrida amistosa aberta com aposta de $%d! Digite /entrarcorrida para participar.", valor); SendClientMessageToAll(0x00FF00FF, msg); }
            else SendClientMessageToAll(0x00FF00FF, "Corrida amistosa aberta! Digite /entrarcorrida para participar.");
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
            if (listitem == 0)
            {
                TurboSlotPendente[playerid] = s;
                ShowPlayerDialog(playerid, D_GAR_TURBO_CONF, DIALOG_STYLE_MSGBOX,
                    "Turbo da garagem", "Deseja adicionar turbo a este carro?", "Sim", "Nao");
            }
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

        case D_GAR_TURBO_CONF:
        {
            new s = TurboSlotPendente[playerid];
            if (s < 0 || s >= MAX_SLOTS || Garagem[playerid][s][F_MODELO] == 0) return 1;
            if (!response)
            {
                TurboNivel[playerid] = 0;
                SpawnarCarroPessoal(playerid, s);
                return 1;
            }
            new lista[180], n = 0;
            lista[0] = 0;
            if (TurboComprado[playerid] & 1) { strcat(lista, "Turbo 1 - +10 km/h\n"); n++; }
            if (TurboComprado[playerid] & 2) { strcat(lista, "Turbo 2 - +20 km/h\n"); n++; }
            if (TurboComprado[playerid] & 4) { strcat(lista, "Turbo 3 - +50 km/h\n"); n++; }
            if (!n)
            {
                SendClientMessage(playerid, 0xFFCC00FF, "Voce ainda nao comprou nenhum turbo. Compre no Paint Spray.");
                TurboNivel[playerid] = 0;
                SpawnarCarroPessoal(playerid, s);
                return 1;
            }
            ShowPlayerDialog(playerid, D_GAR_TURBO_NIVEL, DIALOG_STYLE_LIST, "Escolha o turbo comprado", lista, "Equipar", "Cancelar");
        }
        case D_GAR_TURBO_NIVEL:
        {
            new s = TurboSlotPendente[playerid];
            if (s < 0 || s >= MAX_SLOTS || Garagem[playerid][s][F_MODELO] == 0) return 1;
            if (!response) { TurboNivel[playerid] = 0; SpawnarCarroPessoal(playerid, s); return 1; }
            new escolhido = -1, indice = -1;
            for (new nivel = 1; nivel <= 3; nivel++)
            {
                new bit = (nivel == 1) ? 1 : ((nivel == 2) ? 2 : 4);
                if (TurboComprado[playerid] & bit)
                {
                    indice++;
                    if (indice == listitem) escolhido = nivel;
                }
            }
            if (escolhido < 1 || escolhido > 3) return 1;
            TurboNivel[playerid] = escolhido;
            SalvarTurbos(playerid);
            SpawnarCarroPessoal(playerid, s);
            new aviso[100];
            format(aviso, sizeof(aviso), "Turbo nivel %d equipado.", escolhido);
            SendClientMessage(playerid, 0x00FF00FF, aviso);
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
                case 7:
                {
                    new textoTurbo[400];
                    format(textoTurbo, sizeof(textoTurbo),
                        "Desligar turbo\nNivel 1 - +10 km/h - $%d %s\nNivel 2 - +20 km/h - $%d %s\nNivel 3 - +50 km/h - $%d %s\n\nAtual: nivel %d",
                        PRECO_TURBO_1, (TurboComprado[playerid] & 1) ? "(comprado)" : "(comprar)",
                        PRECO_TURBO_2, (TurboComprado[playerid] & 2) ? "(comprado)" : "(comprar)",
                        PRECO_TURBO_3, (TurboComprado[playerid] & 4) ? "(comprado)" : "(comprar)",
                        TurboNivel[playerid]);
                    ShowPlayerDialog(playerid, D_TURBO, DIALOG_STYLE_LIST, "Tuning - Turbo passivo", textoTurbo, "Selecionar", "Voltar");
                }
                case 8: AbrirPecas(playerid, 0);   // Teto
                case 9: AbrirPecas(playerid, 1);   // Para-choque dianteiro
                case 10: AbrirPecas(playerid, 2);  // Para-choque traseiro
                case 11: AbrirPecas(playerid, 3);  // Escapamento
                case 12: AbrirPecas(playerid, 4);  // Saias laterais
                case 13: AbrirPaintjobs(playerid); // Paintjob
            }
        }

        // PECAS DE CARROCERIA (teto, para-choques, escapamento, saias)
        case D_PECAS:
        {
            new s = SlotDoTuning(playerid);
            if (s < 0) return 1;
            new cat = PecaCat[playerid], v = GetPlayerVehicleID(playerid);
            if (cat < 0 || cat > 4 || v == INVALID_VEHICLE_ID) return 1;
            new campo = PecaCampo[cat];
            if (listitem == 0)
            {
                if (Garagem[playerid][s][campo] > 0) RemoveVehicleComponent(v, Garagem[playerid][s][campo]);
                Garagem[playerid][s][campo] = 0;
                if (cat == 4)
                {
                    if (Garagem[playerid][s][F_SKI2] > 0) RemoveVehicleComponent(v, Garagem[playerid][s][F_SKI2]);
                    Garagem[playerid][s][F_SKI2] = 0;
                }
                SalvarConta(playerid);
                SendClientMessage(playerid, 0xFFFF00FF, "Peca removida.");
            }
            else
            {
                new idx = listitem - 1, comp;
                if (idx < 0 || idx >= PecaQtd[playerid]) return 1;
                comp = PecaLista[playerid][idx];
                if (!PecaCompativel(GetVehicleModel(v), comp))
                    return SendClientMessage(playerid, 0xFF0000FF, "Essa peca nao serve nesse carro.");
                if (Garagem[playerid][s][campo] == comp || (cat == 4 && Garagem[playerid][s][F_SKI2] == comp))
                    SendClientMessage(playerid, 0xFFCC00FF, "Essa peca ja esta instalada.");
                else if (Cobrar(playerid, PecaPreco[cat]))
                {
                    AddVehicleComponent(v, comp);
                    if (cat == 4) Garagem[playerid][s][F_SKI2] = Garagem[playerid][s][F_SKI];
                    Garagem[playerid][s][campo] = comp;
                    SalvarConta(playerid);
                    SendClientMessage(playerid, 0x00FF00FF, "Peca instalada!");
                }
            }
            AbrirPecas(playerid, cat);
            return 1;
        }

        // PAINTJOBS
        case D_PAINTJOB:
        {
            new s = SlotDoTuning(playerid);
            if (s < 0) return 1;
            new v = GetPlayerVehicleID(playerid);
            if (v == INVALID_VEHICLE_ID || !ModeloTemPaintjob(GetVehicleModel(v))) return 1;
            if (listitem == 0)
            {
                ChangeVehiclePaintjob(v, 3);
                ChangeVehicleColor(v, Garagem[playerid][s][F_COR1], Garagem[playerid][s][F_COR2]);
                Garagem[playerid][s][F_PJ] = 0;
                SalvarConta(playerid);
                SendClientMessage(playerid, 0xFFFF00FF, "Paintjob removido.");
            }
            else if (listitem >= 1 && listitem <= 3)
            {
                if (Cobrar(playerid, PRECO_PAINTJOB))
                {
                    ChangeVehiclePaintjob(v, listitem - 1);
                    Garagem[playerid][s][F_PJ] = listitem;
                    SalvarConta(playerid);
                    SendClientMessage(playerid, 0x00FF00FF, "Paintjob aplicado!");
                }
            }
            AbrirPaintjobs(playerid);
            return 1;
        }

        // TURBO PASSIVO: comprar niveis separadamente, equipar apenas um
        case D_TURBO:
        {
            if (SlotDoTuning(playerid) < 0) return 1;
            new nivel = listitem, preco, bit, msgTurbo[128];
            if (nivel == 0)
            {
                TurboNivel[playerid] = 0;
                SalvarTurbos(playerid);
                SendClientMessage(playerid, 0x00DFFFFF, "Turbo desligado.");
                return 1;
            }
            if (nivel < 1 || nivel > 3) return 1;
            if (nivel == 1) { preco = PRECO_TURBO_1; bit = 1; }
            else if (nivel == 2) { preco = PRECO_TURBO_2; bit = 2; }
            else { preco = PRECO_TURBO_3; bit = 4; }

            if (!(TurboComprado[playerid] & bit))
            {
                if (!Cobrar(playerid, preco)) return 1;
                TurboComprado[playerid] |= bit;
                SalvarConta(playerid);
                SalvarTurbos(playerid);
                format(msgTurbo, sizeof(msgTurbo), "Turbo nivel %d comprado por $%d.", nivel, preco);
                SendClientMessage(playerid, 0x00FF00FF, msgTurbo);
            }
            TurboNivel[playerid] = nivel;
            SalvarTurbos(playerid);
            format(msgTurbo, sizeof(msgTurbo), "Turbo nivel %d comprado/equipado. Os niveis nao acumulam.", nivel, nivel * 3);
            SendClientMessage(playerid, 0x00DFFFFF, msgTurbo);
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
// TURBO POR NIVEL (aplica impulso adicional enquanto acelera)
// ============================================================
public TurboTimer()
{
    new keys, ud, lr, v;
    new Float:x, Float:y, Float:z, Float:angle;
    new Float:fx, Float:fy, Float:forwardSpeed, Float:factor;

    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i) || !Logado[i] || TurboNivel[i] < 1 || TurboNivel[i] > 3)
            continue;

        v = GetPlayerVehicleID(i);
        if (v == INVALID_VEHICLE_ID || GetPlayerState(i) != PLAYER_STATE_DRIVER)
            continue;

        GetPlayerKeys(i, keys, ud, lr);
        // Só aplica o turbo enquanto a tecla de acelerar estiver pressionada.
        if (ud != KEY_UP) continue;

        GetVehicleVelocity(v, x, y, z);
        GetVehicleZAngle(v, angle);
        fx = -floatsin(angle, degrees);
        fy = floatcos(angle, degrees);
        forwardSpeed = x * fx + y * fy;

        // Só aplica turbo se o veículo estiver se movendo para frente.
        if (forwardSpeed <= 0.05) continue;

        // Bônus pequeno e contínuo: nível 1 < nível 2 < nível 3.
        // Os níveis representam 3%, 6% e 9% de força extra de aceleração.
        // Impulso continuo mas perceptivel. SA-MP nao mede a velocidade em km/h aqui;
        // o ganho real depende do veiculo e do velocimetro usado pelo servidor.
        factor = 1.0 + (float(TurboNivel[i]) * 0.002); // pequena correcao proporcional
        x *= factor;
        y *= factor;
        x += fx * (0.006 * float(TurboNivel[i]));
        y += fy * (0.006 * float(TurboNivel[i]));
        SetVehicleVelocity(v, x, y, z);
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
