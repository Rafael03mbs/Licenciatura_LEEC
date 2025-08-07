:- consult('golog2_2025.pl').
:- style_check(-discontiguous). % Permite definições de predicados não contíguas
:- style_check(-singleton).    % Permite variáveis singleton sem aviso

% --- Facto dinâmico para a estufa ativa ---
:- dynamic estufa_ativa_id/1.

%***********************************************************************************************
% PREDICADOS UTILITÁRIOS DE DATA
%***********************************************************************************************

% getdate(-DateTimeObject)
% Obtém a data e hora atuais como um objeto de data/hora do Prolog.
getdate(D) :-
    get_time(T),
    stamp_date_time(T,D,'UTC').

% get_simple_date(-DateStringAtom)
% Obtém a data atual no formato 'YYYY-MM-DD' como um átomo.
% Garante dois dígitos para mês e dia.
get_simple_date(DateString) :-
    get_time(T),
    stamp_date_time(T, DateTime, 'UTC'),
    DateTime = date(Y,M,D,_,_,_,_,_,_),
    format(atom(Y_str), '~d', [Y]),
    format(atom(M_str), '~|~`0t~d~2+', [M]), % Preenche com 0 à esquerda para 2 dígitos
    format(atom(D_str), '~|~`0t~d~2+', [D]), % Preenche com 0 à esquerda para 2 dígitos
    atomic_list_concat([Y_str, M_str, D_str], '-', DateString).

% parse_date_string(+DateStringAtom, -Year, -Month, -Day)
% Converte uma string de data 'YYYY-MM-DD' nos seus componentes numéricos.
parse_date_string(DateString, Y, M, D) :-
    atomic_list_concat([Y_atom, M_atom, D_atom], '-', DateString),
    atom_number(Y_atom, Y),
    atom_number(M_atom, M),
    atom_number(D_atom, D).

% add_days_to_date_string(+StartDateString, +DaysToAdd, -EndDateString)
% Adiciona um número de dias a uma data (string 'YYYY-MM-DD') e retorna a nova data (string 'YYYY-MM-DD').
add_days_to_date_string(StartDateString, DaysToAdd, EndDateString) :-
    parse_date_string(StartDateString, Y, M, D),
    date_time_stamp(date(Y,M,D,0,0,0,0,'UTC',_), StartStamp), % Especificar offset 0 e timezone 'UTC'
    SecondsToAdd is DaysToAdd * 24 * 60 * 60,
    EndStamp is StartStamp + SecondsToAdd,
    stamp_date_time(EndStamp, date(EY,EM,ED,_,_,_,_,_,_), 'UTC'),
    % Garantir dois dígitos para Mês e Dia na data final
    format(atom(EY_str), '~d', [EY]),
    format(atom(EM_str), '~|~`0t~d~2+', [EM]),
    format(atom(ED_str), '~|~`0t~d~2+', [ED]),
    atomic_list_concat([EY_str, EM_str, ED_str], '-', EndDateString).

%***********************************************************************************************
% DEFINIÇÃO DO FRAME ESTUFA E COMPONENTES ASSOCIADOS
%***********************************************************************************************

% --- Definição Base do Frame ESTUFA (FR1, FR5, FR6) ---
% def_estufa_inicial(+NomeEstufaAtom)
% Cria um novo frame de estufa com slots padrão e associa demônios.
def_estufa_inicial(NomeEstufa) :-
    new_frame(NomeEstufa),
    new_slot(NomeEstufa, nome_estufa, NomeEstufa), % Identificador da estufa
    new_slot(NomeEstufa, morada, 'Local Desconhecido'),
    % Limites de temperatura base
    new_slot(NomeEstufa, temp_lim_inf_conforto_base, 18),
    new_slot(NomeEstufa, temp_lim_sup_conforto_base, 28),
    new_slot(NomeEstufa, temp_lim_inf_absoluto, 10),
    new_slot(NomeEstufa, temp_lim_sup_absoluto, 35),
    % Limites de conforto atuais (inicialmente iguais aos base)
    new_slot(NomeEstufa, temp_lim_inf_conforto, 18),
    new_slot(NomeEstufa, temp_lim_sup_conforto, 28),
    % Estado da estufa
    new_slot(NomeEstufa, temperatura_atual, 22),    % Valor inicial
    new_slot(NomeEstufa, clima_atual),             % Calculado por demônio
    new_slot(NomeEstufa, status_climatizacao, inactive), % inactive, warming, cooling
    % Métodos de climatização
    new_slot(NomeEstufa, operar_stop, stop_climatizacao_estufa),
    new_slot(NomeEstufa, operar_aquecer, aquecer_climatizacao_estufa),
    new_slot(NomeEstufa, operar_arrefecer, arrefecer_climatizacao_estufa),
    % Parâmetros para lógica de ocupação (Regra Moodle 1.d)
    new_slot(NomeEstufa, numero_ocupantes, 5),
    new_slot(NomeEstufa, ocupantes_limite_X, 10),
    new_slot(NomeEstufa, ocupantes_variabilidade_Y, 2),
    new_slot(NomeEstufa, ajuste_temperatura_Z, 1),
    % Gestão de frutas
    new_slot(NomeEstufa, lotes_em_producao, []),   % Lista de IDs de lotes de fruta
    % Associação dos demônios principais da estufa
    def_demonios_estufa_com_alarme_real(NomeEstufa),
    new_demon(NomeEstufa, numero_ocupantes, demon_ajusta_limites_por_ocupacao, if_write, after, side_effect).

% --- Métodos de Operação da Climatização da Estufa ---
stop_climatizacao_estufa(EstufaFrame) :-
    new_value(EstufaFrame, status_climatizacao, inactive),
    format('~w: Sistema de climatizacao PARADO.~n', [EstufaFrame]).
aquecer_climatizacao_estufa(EstufaFrame) :-
    new_value(EstufaFrame, status_climatizacao, warming),
    format('~w: Sistema de climatizacao AQUECENDO.~n', [EstufaFrame]).
arrefecer_climatizacao_estufa(EstufaFrame) :-
    new_value(EstufaFrame, status_climatizacao, cooling),
    format('~w: Sistema de climatizacao ARREFECENDO.~n', [EstufaFrame]).

%***********************************************************************************************
% DEMÔNIOS DA ESTUFA
%***********************************************************************************************

% def_demonios_estufa_com_alarme_real(+EstufaFrame)
% Define os demônios principais para o funcionamento da estufa.
def_demonios_estufa_com_alarme_real(EstufaFrame) :-
    new_demon(EstufaFrame, clima_atual, demon_calcula_clima_estufa, if_read, after, alter_value),
    new_demon(EstufaFrame, temperatura_atual, demon_controla_climatizacao_estufa_com_alarme, if_write, before, side_effect).

% demon_calcula_clima_estufa(+EstufaFrame, +Slot, +ValorOriginal, -ClimaCalculado)
% Demônio: if_read no slot 'clima_atual'. Calcula o clima com base na temperatura.
demon_calcula_clima_estufa(EstufaFrame, _Slot, _ValorOriginal, ClimaCalculado) :-
    get_value(EstufaFrame, temperatura_atual, TempAtual),
    get_value(EstufaFrame, temp_lim_inf_conforto, Li),
    get_value(EstufaFrame, temp_lim_inf_absoluto, Lai),
    get_value(EstufaFrame, temp_lim_sup_conforto, Ls),
    get_value(EstufaFrame, temp_lim_sup_absoluto, Las),
    classifica_temperatura(TempAtual, Lai, Li, Ls, Las, ClimaCalculado).

% classifica_temperatura(+Temp, +Lai, +Li, +Ls, +Las, -Classificacao)
% Lógica para classificar a temperatura.
classifica_temperatura(T, _Lai, Li, Ls, _Las, comfort) :- T >= Li, T =< Ls, !.
classifica_temperatura(T, Lai, _Li, _Ls, _Las, freezing) :- T < Lai, !.
classifica_temperatura(T, _Lai, _Li, _Ls, Las, burning) :- T > Las, !.
classifica_temperatura(T, Lai, Li, _Ls, _Las, cold) :- T >= Lai, T < Li, !.
classifica_temperatura(T, _Lai, _Li, Ls, Las, hot) :- T > Ls, T =< Las, !.
classifica_temperatura(_, _, _, _, _, desconhecido).

% demon_controla_climatizacao_estufa_com_alarme(+EstufaFrame, +Slot, +NovaTemperatura, ?NovaTemperaturaOut)
% Demônio: if_write no slot 'temperatura_atual'. Controla climatização e gera alarmes de temperatura.
demon_controla_climatizacao_estufa_com_alarme(EstufaFrame, _Slot, NovaTemperatura, NovaTemperatura) :-
    get_value(EstufaFrame, temperatura_atual, TempAnterior),
    get_value(EstufaFrame, temp_lim_inf_conforto, Li),
    get_value(EstufaFrame, temp_lim_inf_absoluto, Lai),
    get_value(EstufaFrame, temp_lim_sup_conforto, Ls),
    get_value(EstufaFrame, temp_lim_sup_absoluto, Las),
    format('~w: Nova temperatura ~w C (anterior: ~w C). Limites conforto [~w C - ~w C]. Verificando acao...~n', [EstufaFrame, NovaTemperatura, TempAnterior, Li, Ls]),
    ( NovaTemperatura > Ls -> call_method_0(EstufaFrame, operar_arrefecer)
    ; NovaTemperatura < Li -> call_method_0(EstufaFrame, operar_aquecer)
    ; call_method_0(EstufaFrame, operar_stop)
    ),
    verificar_alarmes_temperatura_com_genmsg(EstufaFrame, NovaTemperatura, TempAnterior, Lai, Las).

% demon_ajusta_limites_por_ocupacao(+EstufaFrame, +Slot, +NovoNumOcupantes, ?NovoNumOcupantesOut)
% Demônio: if_write no slot 'numero_ocupantes'. Ajusta limites de conforto e gera alarme. (Regra Moodle 1.d)
demon_ajusta_limites_por_ocupacao(EstufaFrame, _Slot, NovoNumOcupantes, NovoNumOcupantes) :-
    get_value(EstufaFrame, ocupantes_limite_X, X),
    get_value(EstufaFrame, ocupantes_variabilidade_Y, Y),
    get_value(EstufaFrame, ajuste_temperatura_Z, Z),
    get_value(EstufaFrame, temp_lim_inf_conforto_base, LiBase),
    get_value(EstufaFrame, temp_lim_sup_conforto_base, LsBase),
    get_value(EstufaFrame, temp_lim_inf_absoluto, Lai),
    get_value(EstufaFrame, temp_lim_sup_absoluto, Las),
    format('~w: Numero de ocupantes alterado para ~w. Verificando ajuste de limites de conforto (Base Li: ~w, Ls: ~w)...~n', [EstufaFrame, NovoNumOcupantes, LiBase, LsBase]),
    LimiteSuperiorOcupacao is X + Y,
    LimiteInferiorOcupacao is X - Y,
    ( NovoNumOcupantes > LimiteSuperiorOcupacao ->
        NovoLi is LiBase - Z, NovoLs is LsBase - Z,
        format('~w: Ocupacao ALTA (~w > ~w). Diminuindo limites de conforto para Li=~w, Ls=~w.~n', [EstufaFrame, NovoNumOcupantes, LimiteSuperiorOcupacao, NovoLi, NovoLs]),
        valida_e_atualiza_limites(EstufaFrame, NovoLi, NovoLs, Lai, Las, limites_clima_reduzidos_ocup_alta, NovoNumOcupantes)
    ; NovoNumOcupantes < LimiteInferiorOcupacao ->
        NovoLi is LiBase + Z, NovoLs is LsBase + Z,
        format('~w: Ocupacao BAIXA (~w < ~w). Aumentando limites de conforto para Li=~w, Ls=~w.~n', [EstufaFrame, NovoNumOcupantes, LimiteInferiorOcupacao, NovoLi, NovoLs]),
        valida_e_atualiza_limites(EstufaFrame, NovoLi, NovoLs, Lai, Las, limites_clima_aumentados_ocup_baixa, NovoNumOcupantes)
    ; % Ocupação normal, verificar se precisa reverter para base
        get_value(EstufaFrame, temp_lim_inf_conforto, LiAtual),
        get_value(EstufaFrame, temp_lim_sup_conforto, LsAtual),
        ( (LiAtual \== LiBase ; LsAtual \== LsBase) ->
            format('~w: Ocupacao NORMAL (~w). Revertendo para limites de conforto base Li=~w, Ls=~w.~n', [EstufaFrame, NovoNumOcupantes, LiBase, LsBase]),
            valida_e_atualiza_limites(EstufaFrame, LiBase, LsBase, Lai, Las, limites_clima_normalizados_ocup_normal, NovoNumOcupantes)
        ;   format('~w: Ocupacao NORMAL (~w). Limites de conforto ja estao nos valores base.~n', [EstufaFrame, NovoNumOcupantes])
        )
    ).

% valida_e_atualiza_limites(+EstufaFrame, +NovoLiProposto, +NovoLsProposto, +Lai, +Las, +TipoAlarme, +ValorAlarmeOcup)
% Valida os novos limites propostos contra os absolutos e atualiza se válidos.
valida_e_atualiza_limites(EstufaFrame, NovoLiProposto, NovoLsProposto, Lai, Las, TipoAlarme, ValorAlarmeOcupantes) :-
    ( NovoLiProposto < Lai -> LiFinal = Lai ; LiFinal = NovoLiProposto ),
    ( NovoLsProposto > Las -> LsFinal = Las ; LsFinal = NovoLsProposto ),
    ( LiFinal >= LsFinal ->
        format('~w: ERRO CRITICO ao ajustar limites: Li (~w) seria >= Ls (~w) apos validacao com Lai/Las. Ajuste cancelado.~n', [EstufaFrame, LiFinal, LsFinal]),
        fail
    ;   new_value(EstufaFrame, temp_lim_inf_conforto, LiFinal),
        new_value(EstufaFrame, temp_lim_sup_conforto, LsFinal),
        format('~w: Limites de conforto atualizados para Li=~w, Ls=~w.~n', [EstufaFrame, LiFinal, LsFinal]),
        atomic_list_concat(['Li:', LiFinal, ',Ls:', LsFinal, ',Ocup:', ValorAlarmeOcupantes], DescAlarme),
        genmsg_estufa(EstufaFrame, TipoAlarme, DescAlarme)
    ).

%***********************************************************************************************
% SISTEMA DE ALARMES (FR7, Regra Moodle 1.e)
%***********************************************************************************************
def_alarme_prototipo :-
    (frame_exists(alarme_prototipo_estufa) -> true ;
        new_frame(alarme_prototipo_estufa),
        new_slot(alarme_prototipo_estufa, tipo_evento),
        new_slot(alarme_prototipo_estufa, valor_associado),
        new_slot(alarme_prototipo_estufa, data_hora_evento),
        new_slot(alarme_prototipo_estufa, estufa_referencia),
        new_slot(alarme_prototipo_estufa, contador_alarmes, 0)
    ),
    (relation_definition(is_alarme_de, _,_,_) -> true ;
        new_relation(is_alarme_de, transitive, exclusion([contador_alarmes]), nil)
    ).

gen_nome_alarme(EstufaNomeAtom, NomeAlarmeAtom) :-
    get_value(alarme_prototipo_estufa, contador_alarmes, C),
    NewC is C + 1,
    new_value(alarme_prototipo_estufa, contador_alarmes, NewC),
    atomic_list_concat(['alarme_', EstufaNomeAtom, '_', NewC], NomeAlarmeAtom).

genmsg_estufa(EstufaFrame, TipoEvento, ValorAssociado) :-
    def_alarme_prototipo,
    get_value(EstufaFrame, nome_estufa, NomeEstufaAtom),
    gen_nome_alarme(NomeEstufaAtom, NomeAlarmeAtom),
    new_frame(NomeAlarmeAtom),
    new_slot(NomeAlarmeAtom, is_alarme_de, alarme_prototipo_estufa),
    new_value(NomeAlarmeAtom, tipo_evento, TipoEvento),
    new_value(NomeAlarmeAtom, valor_associado, ValorAssociado),
    getdate(DataHora),
    new_value(NomeAlarmeAtom, data_hora_evento, DataHora),
    new_value(NomeAlarmeAtom, estufa_referencia, EstufaFrame),
    format('~w: Novo ALARME GERADO [~w]: ~w (Valor: ~w)~n', [EstufaFrame, NomeAlarmeAtom, TipoEvento, ValorAssociado]).

verificar_alarmes_temperatura_com_genmsg(EstufaFrame, NovaTemp, TempAnterior, Lai, Las) :-
    ( NovaTemp > Las, TempAnterior =< Las ->
        genmsg_estufa(EstufaFrame, temperatura_critica_alta, NovaTemp)
    ; NovaTemp < Lai, TempAnterior >= Lai ->
        genmsg_estufa(EstufaFrame, temperatura_critica_baixa, NovaTemp)
    ; true
    ).

%***********************************************************************************************
% SENSORES (FR2, Regra Moodle 1.a, 1.c)
%***********************************************************************************************

% --- Definição do Protótipo de Sensor ---
def_sensor_prototipo :-
    (frame_exists(sensor_generico) -> true ;
        new_frame(sensor_generico),
        new_slot(sensor_generico, id_sensor),
        new_slot(sensor_generico, tipo_sensor),
        new_slot(sensor_generico, unidade_medida),
        new_slot(sensor_generico, valor_atual),
        new_slot(sensor_generico, timestamp_ultima_leitura),
        new_slot(sensor_generico, instalado_em_estufa)
    ),
    (relation_definition(is_tipo_sensor, _,_,_) -> true ;
        new_relation(is_tipo_sensor, transitive, all, nil)
    ).

% --- Demônio de Controle de Rega (associado ao sensor de humidade) ---
demon_controla_rega(SensorFrame, _Slot, NovoValorHumidade, NovoValorHumidade) :-
    get_value(SensorFrame, instalado_em_estufa, EstufaFrame),
    get_value(SensorFrame, limite_inferior_rega, LimiteRega),
    atom_concat(EstufaFrame, '_atuadores', AtuadoresID),
    frame_exists(AtuadoresID),
    format('~w: Humidade atual ~w%. Limite para rega: ~w%. Verificando rega...~n', [SensorFrame, NovoValorHumidade, LimiteRega]),
    ( NovoValorHumidade < LimiteRega ->
        get_value(AtuadoresID, status_rega, StatusRegaAtual),
        ( StatusRegaAtual == off ->
            format('~w: Humidade baixa (~w%), ligando REGA.~n', [SensorFrame, NovoValorHumidade]),
            call_method_1(AtuadoresID, operar_rega, on),
            genmsg_estufa(EstufaFrame, rega_automatica_ativada, NovoValorHumidade)
          ; format('~w: Humidade baixa (~w%), mas REGA ja esta LIGADA.~n', [SensorFrame, NovoValorHumidade])
        )
    ;
        get_value(AtuadoresID, status_rega, StatusRegaAtual),
        ( StatusRegaAtual == on ->
            format('~w: Humidade OK (~w%). REGA permanece LIGADA (sem logica de desligamento automatico implementada).~n', [SensorFrame, NovoValorHumidade])
          ; true
        )
    ).

% --- Demônio de Controle de Qualidade do Ar e Ventilador (associado ao sensor de CO2) ---
demon_controla_qualidade_ar_e_ventilador(SensorCO2Frame, _Slot, NovoValorCO2, NovoValorCO2) :-
    get_value(SensorCO2Frame, instalado_em_estufa, EstufaFrame),
    get_value(SensorCO2Frame, limite_superior_co2_alarme, LimiteCO2Alarme),
    LimiteCO2Normal is LimiteCO2Alarme - 100,
    (LimiteCO2Normal < 0 -> LimiteCO2NormalAjustado = 0 ; LimiteCO2NormalAjustado = LimiteCO2Normal),
    atom_concat(EstufaFrame, '_atuadores', AtuadoresID),
    frame_exists(AtuadoresID),
    format('~w: CO2 atual ~wppm. Limite alarme: ~wppm. Verificando ventilador...~n', [SensorCO2Frame, NovoValorCO2, LimiteCO2Alarme]),
    ( NovoValorCO2 > LimiteCO2Alarme ->
        genmsg_estufa(EstufaFrame, qualidade_ar_deficiente_co2_alto, NovoValorCO2),
        get_value(AtuadoresID, status_ventilador, StatusVentiladorAtual),
        ( StatusVentiladorAtual == off ->
            format('~w: CO2 ALTO (~wppm), ligando VENTILADOR.~n', [SensorCO2Frame, NovoValorCO2]),
            call_method_1(AtuadoresID, operar_ventilador, on),
            genmsg_estufa(EstufaFrame, ventilador_automatico_ativado_co2, NovoValorCO2)
          ; format('~w: CO2 ALTO (~wppm), mas VENTILADOR ja esta LIGADO.~n', [SensorCO2Frame, NovoValorCO2])
        )
    ; NovoValorCO2 < LimiteCO2NormalAjustado ->
        get_value(AtuadoresID, status_ventilador, StatusVentiladorAtual),
        ( StatusVentiladorAtual == on ->
            format('~w: CO2 NORMALIZADO (~wppm), desligando VENTILADOR.~n', [SensorCO2Frame, NovoValorCO2]),
            call_method_1(AtuadoresID, operar_ventilador, off),
            genmsg_estufa(EstufaFrame, ventilador_automatico_desativado_co2, NovoValorCO2)
          ; format('~w: CO2 NORMALIZADO (~wppm), VENTILADOR ja esta DESLIGADO.~n', [SensorCO2Frame, NovoValorCO2])
        )
    ;
        format('~w: CO2 (~wppm) em nivel intermediario. Nenhuma acao no ventilador.~n', [SensorCO2Frame, NovoValorCO2])
    ).

% --- Criação dos Sensores para uma Estufa ---
def_sensores_estufa(EstufaFrame) :-
    def_sensor_prototipo,
    atom_concat(EstufaFrame, '_soil_01', SensorHumidadeID),
    new_frame(SensorHumidadeID),
    new_slot(SensorHumidadeID, is_tipo_sensor, sensor_generico),
    new_value(SensorHumidadeID, id_sensor, SensorHumidadeID),
    new_value(SensorHumidadeID, tipo_sensor, humidade_solo),
    new_value(SensorHumidadeID, unidade_medida, '%'),
    new_value(SensorHumidadeID, valor_atual, 60),
    new_value(SensorHumidadeID, instalado_em_estufa, EstufaFrame),
    getdate(NowSoil), new_value(SensorHumidadeID, timestamp_ultima_leitura, NowSoil),
    new_slot(SensorHumidadeID, limite_inferior_rega, 40),
    new_demon(SensorHumidadeID, valor_atual, demon_controla_rega, if_write, after, side_effect),
    format('Sensor ~w (humidade solo) criado para ~w com demonio de controle de rega.~n', [SensorHumidadeID, EstufaFrame]),

    atom_concat(EstufaFrame, '_co2_01', SensorCO2ID),
    new_frame(SensorCO2ID),
    new_slot(SensorCO2ID, is_tipo_sensor, sensor_generico),
    new_value(SensorCO2ID, id_sensor, SensorCO2ID),
    new_value(SensorCO2ID, tipo_sensor, co2),
    new_value(SensorCO2ID, unidade_medida, 'ppm'),
    new_value(SensorCO2ID, valor_atual, 450),
    new_value(SensorCO2ID, instalado_em_estufa, EstufaFrame),
    getdate(NowCO2), new_value(SensorCO2ID, timestamp_ultima_leitura, NowCO2),
    new_slot(SensorCO2ID, limite_superior_co2_alarme, 1000),
    new_demon(SensorCO2ID, valor_atual, demon_controla_qualidade_ar_e_ventilador, if_write, after, side_effect),
    format('Sensor ~w (CO2) criado para ~w com demonio de controle de ventilador.~n', [SensorCO2ID, EstufaFrame]),
    true.

% simular_leitura_sensor(+IDSensor, +NovoValor)
simular_leitura_sensor(IDSensor, NovoValor) :-
    frame_exists(IDSensor),
    get_value(IDSensor, tipo_sensor, Tipo),
    format('Simulando nova leitura para sensor ~w (~w): ~w.~n', [IDSensor, Tipo, NovoValor]),
    new_value(IDSensor, valor_atual, NovoValor),
    getdate(Now),
    new_value(IDSensor, timestamp_ultima_leitura, Now).

%***********************************************************************************************
% ATUADORES (Regra Moodle 1.b)
%***********************************************************************************************

% --- Criação do Frame de Atuadores para uma Estufa ---
def_atuadores_estufa(EstufaFrame) :-
    atom_concat(EstufaFrame, '_atuadores', AtuadoresID),
    new_frame(AtuadoresID),
    new_slot(AtuadoresID, estufa_associada, EstufaFrame),
    new_slot(AtuadoresID, status_rega, off),
    new_slot(AtuadoresID, status_ventilador, off),
    new_slot(AtuadoresID, status_nebulizador, off),
    new_slot(AtuadoresID, operar_rega, operar_rega_estufa),
    new_slot(AtuadoresID, operar_ventilador, operar_ventilador_estufa),
    new_slot(AtuadoresID, operar_nebulizador, operar_nebulizador_estufa),
    format('Frame de atuadores ~w criado para ~w.~n', [AtuadoresID, EstufaFrame]).

% --- Métodos de Operação dos Atuadores ---
operar_rega_estufa(AtuadoresFrame, NovoEstado) :-
    ((NovoEstado == on ; NovoEstado == off) ->
        new_value(AtuadoresFrame, status_rega, NovoEstado),
        format('Atuador REGA (~w) definido para: ~w.~n', [AtuadoresFrame, NovoEstado])
    ;   format('Erro: Estado invalido (~w) para rega. Use on/off.~n', [NovoEstado]), fail).
operar_ventilador_estufa(AtuadoresFrame, NovoEstado) :-
    ((NovoEstado == on ; NovoEstado == off) ->
        new_value(AtuadoresFrame, status_ventilador, NovoEstado),
        format('Atuador VENTILADOR (~w) definido para: ~w.~n', [AtuadoresFrame, NovoEstado])
    ;   format('Erro: Estado invalido (~w) para ventilador. Use on/off.~n', [NovoEstado]), fail).
operar_nebulizador_estufa(AtuadoresFrame, NovoEstado) :-
    ((NovoEstado == on ; NovoEstado == off) ->
        new_value(AtuadoresFrame, status_nebulizador, NovoEstado),
        format('Atuador NEBULIZADOR (~w) definido para: ~w.~n', [AtuadoresFrame, NovoEstado])
    ;   format('Erro: Estado invalido (~w) para nebulizador. Use on/off.~n', [NovoEstado]), fail).

%***********************************************************************************************
% FRUTAS E LOTES (FR2, Etapas 6 e 7)
%***********************************************************************************************

% --- Definição dos Protótipos de Frutas ---
def_prototipos_frutas :-
    (frame_exists(prototipo_morango) -> true ;
        new_frame(prototipo_morango),
        new_slot(prototipo_morango, nome_amigavel, 'Morango Comum'),
        new_slot(prototipo_morango, cond_ideal_temp_min, 15),
        new_slot(prototipo_morango, cond_ideal_temp_max, 25),
        new_slot(prototipo_morango, tempo_amadurecimento_dias, 30),
        new_slot(prototipo_morango, tempo_prateleira_dias, 5),
        new_slot(prototipo_morango, preco_unitario, 0.50)
    ),
    (frame_exists(prototipo_tomate) -> true ;
        new_frame(prototipo_tomate),
        new_slot(prototipo_tomate, nome_amigavel, 'Tomate Cereja'),
        new_slot(prototipo_tomate, cond_ideal_temp_min, 20),
        new_slot(prototipo_tomate, cond_ideal_temp_max, 30),
        new_slot(prototipo_tomate, tempo_amadurecimento_dias, 60),
        new_slot(prototipo_tomate, tempo_prateleira_dias, 10),
        new_slot(prototipo_tomate, preco_unitario, 0.20)
    ),
    (relation_definition(is_lote_de, _,_,_) -> true ;
        new_relation(is_lote_de, intransitive, all, nil)
    ).

% --- Adicionar Lote de Fruta a uma Estufa ---
add_lote_fruta(EstufaFrame, IDLote, PrototipoFrutaFrame, QtdPlantada) :-
    add_lote_fruta(EstufaFrame, IDLote, PrototipoFrutaFrame, QtdPlantada, nil).

add_lote_fruta(EstufaFrame, IDLote, PrototipoFrutaFrame, QtdPlantada, DataSemeio) :-
    frame_exists(EstufaFrame),
    frame_exists(PrototipoFrutaFrame),
    \+ frame_exists(IDLote),
    new_frame(IDLote),
    new_slot(IDLote, id_lote, IDLote),
    new_slot(IDLote, is_lote_de, PrototipoFrutaFrame),
    ( DataSemeio == nil -> get_simple_date(Hoje), new_slot(IDLote, data_semeio, Hoje)
    ; new_slot(IDLote, data_semeio, DataSemeio)
    ),
    new_slot(IDLote, quantidade_plantada, QtdPlantada),
    new_slot(IDLote, estufa_alocada, EstufaFrame),
    new_slot(IDLote, quantidade_em_stock, 0),
    new_slot(IDLote, data_colheita_prevista),
    new_slot(IDLote, data_colheita_real),
    new_slot(IDLote, data_validade_lote),
    (get_value(EstufaFrame, lotes_em_producao, ListaLotesAtual) ->
        (member(IDLote, ListaLotesAtual) -> true
        ; append(ListaLotesAtual, [IDLote], NovaListaLotes), new_value(EstufaFrame, lotes_em_producao, NovaListaLotes) )
    ; new_value(EstufaFrame, lotes_em_producao, [IDLote])
    ),
    format('Lote de fruta ~w (~w) adicionado a estufa ~w. Quantidade plantada: ~w.~n', [IDLote, PrototipoFrutaFrame, EstufaFrame, QtdPlantada]).

% --- Visualizar Frutas em Produção numa Estufa ---
mostrar_frutas_em_estufa(EstufaFrame) :-
    ( \+ frame_exists(EstufaFrame) -> format('Estufa ~w nao existe.~n', [EstufaFrame]), ! ; true),
    get_value(EstufaFrame, nome_estufa, NomeEstufa),
    format('--- Frutas em Producao na Estufa: ~w ---~n', [NomeEstufa]),
    (get_value(EstufaFrame, lotes_em_producao, Lotes) ->
        ( Lotes == [] ->
            write('Nenhum lote de fruta em producao no momento.'), nl
        ;   forall(member(IDLote, Lotes),
                   (   get_value(IDLote, is_lote_de, PrototipoFruta),
                       get_value(PrototipoFruta, nome_amigavel, NomeFruta),
                       get_value(IDLote, quantidade_plantada, QtdPlantada),
                       get_value(IDLote, data_semeio, DataSemeio),
                       format('Lote ID: ~w~n  Tipo: ~w~n  Plantado: ~w unidades em ~w~n', [IDLote, NomeFruta, QtdPlantada, DataSemeio]),
                       (get_value(IDLote, quantidade_em_stock, Stock) ->
                           format('  Stock Atual: ~w unidades~n', [Stock])
                       ;   format('  Stock Atual: 0 unidades (slot nao definido)~n')
                       ),
                       (frame_slot_values(IDLote, data_colheita_real, [DCR|_]) ->
                           format('  Colhido em: ~w~n', [DCR])
                       ;   format('  Colhido em: (ainda nao)~n')
                       ),
                       (frame_slot_values(IDLote, data_validade_lote, [DVL|_]) ->
                           format('  Validade: ~w~n', [DVL])
                       ;   format('  Validade: (indefinida)~n')
                       ),
                       nl
                   )
              )
        )
    ;   write('Slot lotes_em_producao nao encontrado ou vazio.'), nl
    ).

% --- Registar Colheita de um Lote ---
registar_colheita(IDLote, QuantidadeColhida) :-
    get_simple_date(Hoje),
    registar_colheita(IDLote, QuantidadeColhida, Hoje).

registar_colheita(IDLote, QuantidadeColhida, DataColheitaReal) :-
    ( \+ frame_exists(IDLote) ->
        format('Erro: Lote ~w nao existe.~n', [IDLote]), fail
    ;   true
    ),
    get_value(IDLote, quantidade_plantada, QtdPlantada),
    ( get_value(IDLote, quantidade_em_stock, StockAtual) -> true ; StockAtual = 0),
    RestanteParaColher is QtdPlantada - StockAtual,
    ( QuantidadeColhida > RestanteParaColher ->
        format('Erro: Tentando colher ~w unidades do lote ~w, mas apenas ~w unidades restantes para colher (Plantado: ~w, Ja em Stock: ~w).~n', [QuantidadeColhida, IDLote, RestanteParaColher, QtdPlantada, StockAtual]),
        fail
    ;   true
    ),
    NovoStock is StockAtual + QuantidadeColhida,
    new_value(IDLote, quantidade_em_stock, NovoStock),
    new_value(IDLote, data_colheita_real, DataColheitaReal),
    get_value(IDLote, is_lote_de, PrototipoFruta),
    (get_value(PrototipoFruta, tempo_prateleira_dias, DiasPrateleira) ->
        add_days_to_date_string(DataColheitaReal, DiasPrateleira, DataValidade),
        new_value(IDLote, data_validade_lote, DataValidade),
        format('Lote ~w: Colheita de ~w unidades registada em ~w. Novo stock: ~w. Validade: ~w.~n', [IDLote, QuantidadeColhida, DataColheitaReal, NovoStock, DataValidade])
    ;   format('Lote ~w: Colheita de ~w unidades registada em ~w. Novo stock: ~w. (Tempo de prateleira nao definido no prototipo).~n', [IDLote, QuantidadeColhida, DataColheitaReal, NovoStock])
    ).

%***********************************************************************************************
% ENCOMENDAS (FR3, FR4 - Etapa 8 com correções)
%***********************************************************************************************

% --- Definição do Protótipo de Encomenda ---
def_prototipo_encomenda :-
    (frame_exists(encomenda_base) -> true ;
        new_frame(encomenda_base),
        new_slot(encomenda_base, id_encomenda),
        new_slot(encomenda_base, id_cliente),
        new_slot(encomenda_base, data_encomenda),
        new_slot(encomenda_base, itens_desejados, []),
        new_slot(encomenda_base, itens_alocados, []),
        new_slot(encomenda_base, valor_total, 0.0),
        new_slot(encomenda_base, estado_encomenda)
    ),
    (relation_definition(is_encomenda_de, _,_,_) -> true ;
        new_relation(is_encomenda_de, intransitive, all, nil)
    ),
    (frame_exists(contador_global_encomendas), get_value(contador_global_encomendas, proximo_id, _) -> true ;
        new_frame(contador_global_encomendas),
        new_slot(contador_global_encomendas, proximo_id, 1)
    ).

% --- Gerar ID Único para Encomenda ---
gerar_id_encomenda(IDCliente, IDEncomenda) :-
    get_value(contador_global_encomendas, proximo_id, Num),
    atomic_list_concat(['enc_', IDCliente, '_', Num], IDEncomenda),
    NovoNum is Num + 1,
    new_value(contador_global_encomendas, proximo_id, NovoNum).

% --- Iniciar Criação de Encomenda ---
iniciar_criacao_encomenda(IDCliente, ListaItensDesejados, IDEncomendaOut) :-
    def_prototipo_encomenda,
    gerar_id_encomenda(IDCliente, IDEncomenda),
    new_frame(IDEncomenda),
    new_slot(IDEncomenda, is_encomenda_de, encomenda_base),
    new_value(IDEncomenda, id_encomenda, IDEncomenda),
    new_value(IDEncomenda, id_cliente, IDCliente),
    get_simple_date(Hoje),
    new_value(IDEncomenda, data_encomenda, Hoje),
    new_value(IDEncomenda, itens_desejados, ListaItensDesejados),
    new_value(IDEncomenda, estado_encomenda, 'criada_a_processar_stock'),
    IDEncomendaOut = IDEncomenda,
    format('Encomenda ~w criada para cliente ~w. Itens desejados: ~w. A processar stock...~n', [IDEncomenda, IDCliente, ListaItensDesejados]),
    processar_stock_encomenda_com_rollback(IDEncomenda).

% --- Lógica de Alocação de Stock para Encomenda ---
encontrar_e_alocar_stock_para_item(PrototipoFruta, QtdDesejada, [Estufa|_OutrasEstufas], IDLote, QtdDesejada, PrecoUnitario) :-
    get_value(Estufa, lotes_em_producao, LotesDaEstufa),
    member(IDLote, LotesDaEstufa),
    get_value(IDLote, is_lote_de, ProtoDoLote), ProtoDoLote == PrototipoFruta,
    get_value(IDLote, quantidade_em_stock, StockAtualLote), StockAtualLote >= QtdDesejada,
    (   frame_slot_values(IDLote, data_validade_lote, [DataValidadeLoteStr|_]) ->
        get_simple_date(HojeStr),
        % As linhas de DEBUG foram removidas desta versão final
        (   DataValidadeLoteStr @>= HojeStr -> true % Validade OK
        ;   format('INFO: Lote ~w (~w) EXPIRADO (~w vs hoje ~w). Tentando proximo lote...~n', [IDLote, PrototipoFruta, DataValidadeLoteStr, HojeStr]),
            fail
        )
    ;   format('INFO: Lote ~w (~w) sem data de validade definida. Assumindo OK.~n', [IDLote, PrototipoFruta]),
        true
    ),
    NovoStockLote is StockAtualLote - QtdDesejada,
    new_value(IDLote, quantidade_em_stock, NovoStockLote),
    get_value(PrototipoFruta, preco_unitario, PrecoUnitario),
    format('ALOCADO: ~w unidades de ~w do lote ~w. Novo stock: ~w.~n', [QtdDesejada, PrototipoFruta, IDLote, NovoStockLote]),
    !. % Sucesso, corta
encontrar_e_alocar_stock_para_item(PrototipoFruta, QtdDesejada, [_|RestoEstufas], IDLoteAlocado, QtdAlocada, PrecoUnitario) :-
    encontrar_e_alocar_stock_para_item(PrototipoFruta, QtdDesejada, RestoEstufas, IDLoteAlocado, QtdAlocada, PrecoUnitario).

alocar_itens_da_lista([], _Estufas, AccItens, AccItens, AccValor, AccValor, AccSucesso, AccSucesso).
alocar_itens_da_lista([[PrototipoFruta, QtdDesejada] | RestoDesejados], Estufas, AccItensIn, AccItensOut, AccValorIn, AccValorOut, AccSucessoIn, AccSucessoOut) :-
    (   AccSucessoIn == false ->
        alocar_itens_da_lista(RestoDesejados, Estufas, AccItensIn, AccItensOut, AccValorIn, AccValorOut, false, AccSucessoOut)
    ;   encontrar_e_alocar_stock_para_item(PrototipoFruta, QtdDesejada, Estufas, IDLoteAlocado, QtdDesejada, PrecoItem) ->
            NovaAccValor is AccValorIn + (QtdDesejada * PrecoItem),
            append(AccItensIn, [[IDLoteAlocado, QtdDesejada, PrecoItem]], NovaAccItens),
            alocar_itens_da_lista(RestoDesejados, Estufas, NovaAccItens, AccItensOut, NovaAccValor, AccValorOut, true, AccSucessoOut)
    ;   format('FALHA AO ALOCAR: ~w unidades de ~w.~n', [QtdDesejada, PrototipoFruta]),
        alocar_itens_da_lista(RestoDesejados, Estufas, AccItensIn, AccItensOut, AccValorIn, AccValorOut, false, AccSucessoOut)
    ).

rollback_stock_alocado([]).
rollback_stock_alocado([[IDLote, QtdAlocada, _Preco]|Resto]) :-
    (get_value(IDLote, quantidade_em_stock, StockAtual) ->
        NovoStock is StockAtual + QtdAlocada,
        new_value(IDLote, quantidade_em_stock, NovoStock),
        format('Rollback: Devolvido ~w unidades ao lote ~w. Novo stock: ~w.~n', [QtdAlocada, IDLote, NovoStock])
    ;   format('Erro no rollback: Nao foi possivel obter stock do lote ~w.~n', [IDLote])
    ),
    rollback_stock_alocado(Resto).

processar_stock_encomenda_com_rollback(IDEncomenda) :-
    frame_exists(IDEncomenda),
    get_value(IDEncomenda, itens_desejados, ItensDesejados),
    get_value(IDEncomenda, estado_encomenda, EstadoAtual),
    ( EstadoAtual \== 'criada_a_processar_stock' ->
        format('Encomenda ~w ja foi processada ou esta em estado invalido (~w) para processar stock.~n', [IDEncomenda, EstadoAtual])
    ;   format('Processando stock para encomenda ~w...~n', [IDEncomenda]),
        findall(E, (frame_(E), get_value(E, nome_estufa, _)), EstufasReais),
        alocar_itens_da_lista(ItensDesejados, EstufasReais, [], ItensAlocadosAcc, 0, ValorTotalAcc, true, TodosAlocados),
        ( TodosAlocados == true ->
            new_value(IDEncomenda, itens_alocados, ItensAlocadosAcc),
            new_value(IDEncomenda, valor_total, ValorTotalAcc),
            new_value(IDEncomenda, estado_encomenda, 'confirmada_stock_ok'),
            format('Encomenda ~w: Stock confirmado. Valor: ~2f. Estado: confirmada_stock_ok.~n', [IDEncomenda, ValorTotalAcc])
        ;
            new_value(IDEncomenda, estado_encomenda, 'cancelada_stock_insuficiente'),
            format('Encomenda ~w: Stock insuficiente. Estado: cancelada_stock_insuficiente.~n', [IDEncomenda]),
            rollback_stock_alocado(ItensAlocadosAcc),
            new_value(IDEncomenda, itens_alocados, []),
            new_value(IDEncomenda, valor_total, 0.0)
        )
    ).

% --- Visualizar Encomenda ---
mostrar_encomenda(IDEncomenda) :-
    ( \+ frame_exists(IDEncomenda) ->
        format('Encomenda ~w nao encontrada.~n', [IDEncomenda])
    ;   get_value(IDEncomenda, id_cliente, Cliente),
        get_value(IDEncomenda, data_encomenda, DataEnc),
        get_value(IDEncomenda, estado_encomenda, EstadoEnc),
        get_value(IDEncomenda, itens_desejados, Desejados),
        get_value(IDEncomenda, itens_alocados, Alocados),
        get_value(IDEncomenda, valor_total, ValorTotal),
        format('--- Detalhes da Encomenda: ~w ---~n', [IDEncomenda]),
        format('Cliente: ~w~nData: ~w~nEstado: ~w~n', [Cliente, DataEnc, EstadoEnc]),
        format('Itens Desejados: ~w~n', [Desejados]),
        format('Itens Alocados (Lote, Qtd, PrecoUnit): ~w~n', [Alocados]),
        format('Valor Total: ~2f~n-----------------------------------~n', [ValorTotal])
    ).

%***********************************************************************************************
% ETAPA 9 & 10: MENU DE INTERAÇÃO E GESTÃO DE MÚLTIPLAS ESTUFAS
%***********************************************************************************************

% --- Predicados Auxiliares de Leitura para o Menu ---
read_input_atom(Atom) :-
    read_line_to_codes(user_input, Codes),
    string_codes(String, Codes),
    atom_string(Atom, String).

read_opcao(Opcao) :-
    read_line_to_codes(user_input, Codes),
    string_codes(String, Codes),
    atom_string(Atom, String),
    ( atom_number(Atom, Opcao) ->
        true
    ;   write('Opcao invalida. Por favor, insira um numero.'), nl,
        fail
    ).

% --- Predicados para Gerir Múltiplas Estufas (Etapa 10) ---
listar_estufas_existentes :-
    nl, write('--- Estufas Existentes ---'), nl,
    (findall(EstufaID,
             (frame_(EstufaID), get_value(EstufaID, nome_estufa, _)),
             ListaEstufas),
     ListaEstufas \== [] ->
        forall(member(E, ListaEstufas),
               (get_value(E, nome_estufa, Nome), format('- ~w (ID: ~w)~n', [Nome, E])))
    ;   write('Nenhuma estufa cadastrada.'), nl
    ).

criar_nova_estufa_menu :-
    nl, write('--- Criar Nova Estufa ---'), nl,
    write('Digite o ID (nome unico) para a nova estufa (e.g., estufa2): '),
    read_input_atom(NomeNovaEstufa),
    ( frame_exists(NomeNovaEstufa) ->
        format('Erro: Ja existe uma estufa com o ID ~w.~n', [NomeNovaEstufa])
    ;   def_estufa_inicial(NomeNovaEstufa),
        def_sensores_estufa(NomeNovaEstufa),
        def_atuadores_estufa(NomeNovaEstufa),
        format('Estufa ~w criada com sucesso com sensores e atuadores.~n', [NomeNovaEstufa]),
        write('Tornar esta estufa a ativa? (sim/nao): '),
        read_input_atom(Resp),
        ( Resp == sim ->
            retractall(estufa_ativa_id(_)),
            asserta(estufa_ativa_id(NomeNovaEstufa)),
            format('Estufa ~w agora e a estufa ativa.~n', [NomeNovaEstufa])
        ;   true
        )
    ).

selecionar_estufa_menu :-
    nl, write('--- Selecionar Estufa Ativa ---'), nl,
    listar_estufas_existentes,
    write('Digite o ID da estufa que deseja tornar ativa: '),
    read_input_atom(EstufaEscolhidaID),
    ( (frame_exists(EstufaEscolhidaID), get_value(EstufaEscolhidaID, nome_estufa, _)) ->
        retractall(estufa_ativa_id(_)),
        asserta(estufa_ativa_id(EstufaEscolhidaID)),
        format('Estufa ~w agora e a estufa ativa.~n', [EstufaEscolhidaID])
    ;   format('Erro: Estufa com ID ~w nao encontrada ou nao e uma estufa valida.~n', [EstufaEscolhidaID])
    ).

apagar_estufa_menu :-
    nl, write('--- Apagar Estufa ---'), nl,
    listar_estufas_existentes,
    ( estufa_ativa_id(EstufaAtiva) ->
        format('Estufa ativa atual: ~w~n', [EstufaAtiva])
    ;   true
    ),
    write('Digite o ID da estufa que deseja apagar: '),
    read_input_atom(EstufaParaApagar),
    ( (frame_exists(EstufaParaApagar), get_value(EstufaParaApagar, nome_estufa, _)) ->
        format('Tem certeza que deseja apagar a estufa ~w e TODOS os seus componentes associados? (sim/nao): ', [EstufaParaApagar]),
        read_input_atom(Confirm),
        ( Confirm == sim ->
            atom_concat(EstufaParaApagar, '_soil_01', SoilID),
            (frame_exists(SoilID) -> delete_frame(SoilID) ; true),
            atom_concat(EstufaParaApagar, '_co2_01', CO2ID),
            (frame_exists(CO2ID) -> delete_frame(CO2ID) ; true),
            atom_concat(EstufaParaApagar, '_atuadores', ActID),
            (frame_exists(ActID) -> delete_frame(ActID) ; true),
            (get_value(EstufaParaApagar, lotes_em_producao, Lotes) ->
                forall(member(Lote, Lotes), (frame_exists(Lote) -> delete_frame(Lote) ; true))
            ;   true
            ),
            delete_frame(EstufaParaApagar),
            ( estufa_ativa_id(EstufaParaApagar) ->
                retractall(estufa_ativa_id(EstufaParaApagar))
            ;   true
            ),
            format('Estufa ~w e componentes associados foram apagados.~n', [EstufaParaApagar])
        ;   write('Operacao de apagar cancelada.'), nl
        )
    ;   format('Erro: Estufa com ID ~w nao encontrada.~n', [EstufaParaApagar])
    ).


% --- Menu Principal ---
menu_principal :-
    nl, write('--- Menu Principal Estufa Inteligente ---'), nl,
    (estufa_ativa_id(Ativa) ->
        format('Estufa Ativa: ~w~n', [Ativa])
    ;   write('Nenhuma estufa ativa selecionada. Use a Opcao 7 para selecionar ou criar uma.~n')
    ),
    write('1. Gerir Estufa Ativa'), nl,
    write('2. Gerir Sensores da Estufa Ativa'), nl,
    write('3. Gerir Atuadores da Estufa Ativa'), nl,
    write('4. Gerir Frutas e Lotes da Estufa Ativa'), nl,
    write('5. Gerir Encomendas (Global)'), nl,
    write('6. Visualizar Todos os Alarmes Gerados (Global)'), nl,
    write('7. Gerir Sistema de Estufas (Listar, Criar, Selecionar, Apagar)'), nl,
    write('0. Sair'), nl,
    write('Escolha uma opcao: '),
    read_opcao(Opcao),
    processar_opcao_principal(Opcao),
    ( Opcao == 0 ->
        write('A sair do sistema...'), nl, !
    ;   menu_principal
    ).

% --- Processador de Opções do Menu Principal ---
processar_opcao_principal(1) :- !, (estufa_ativa_id(EstufaID) -> menu_gerir_estufa(EstufaID) ; write('Nenhuma estufa ativa. Use a Opcao 7.'), nl).
processar_opcao_principal(2) :- !, (estufa_ativa_id(EstufaID) -> menu_gerir_sensores(EstufaID) ; write('Nenhuma estufa ativa. Use a Opcao 7.'), nl).
processar_opcao_principal(3) :- !, (estufa_ativa_id(EstufaID) -> menu_gerir_atuadores(EstufaID) ; write('Nenhuma estufa ativa. Use a Opcao 7.'), nl).
processar_opcao_principal(4) :- !, (estufa_ativa_id(EstufaID) -> menu_gerir_frutas(EstufaID) ; write('Nenhuma estufa ativa. Use a Opcao 7.'), nl).
processar_opcao_principal(5) :- !, menu_gerir_encomendas.
processar_opcao_principal(6) :- !, visualizar_todos_alarmes.
processar_opcao_principal(7) :- !, menu_sistema_estufas.
processar_opcao_principal(0) :- !.
processar_opcao_principal(_) :- write('Opcao desconhecida.'), nl.

% --- Submenu: Gerir Sistema de Estufas ---
menu_sistema_estufas :-
    nl, write('--- Menu Gerir Sistema de Estufas ---'), nl,
    write('1. Listar estufas existentes'), nl,
    write('2. Criar nova estufa'), nl,
    write('3. Selecionar estufa ativa'), nl,
    write('4. Apagar estufa (CUIDADO!)'), nl,
    write('0. Voltar ao Menu Principal'), nl,
    write('Escolha uma opcao: '),
    read_opcao(Opcao),
    (catch(processar_opcao_sistema_estufas(Opcao), E, (write('Erro no processamento: '), print(E), nl)) ; true),
    ( Opcao == 0 -> ! ; menu_sistema_estufas ).

% --- Processador de Opções do Submenu Gerir Sistema de Estufas ---
processar_opcao_sistema_estufas(1) :- !, listar_estufas_existentes.
processar_opcao_sistema_estufas(2) :- !, criar_nova_estufa_menu.
processar_opcao_sistema_estufas(3) :- !, selecionar_estufa_menu.
processar_opcao_sistema_estufas(4) :- !, apagar_estufa_menu.
processar_opcao_sistema_estufas(0) :- !.
processar_opcao_sistema_estufas(_) :- write('Opcao desconhecida.'), nl.


% --- Submenu: Gerir Estufa (opera na EstufaID ativa) ---
menu_gerir_estufa(EstufaID) :-
    nl, format('--- Menu Gerir Estufa: ~w ---~n', [EstufaID]),
    write('1. Visualizar estado completo da estufa'), nl,
    write('2. Alterar temperatura atual da estufa'), nl,
    write('3. Alterar numero de ocupantes da estufa'), nl,
    write('4. Parametrizar Limites de Ocupacao (X, Y, Z)'), nl,
    write('5. Parametrizar Limites Base de Temperatura (Li, Ls, Lai, Las)'), nl,
    write('0. Voltar ao Menu Principal'), nl,
    write('Escolha uma opcao: '),
    read_opcao(Opcao),
    (catch(processar_opcao_estufa(Opcao, EstufaID), E, (write('Erro: '), print(E), nl)) ; true),
    ( Opcao == 0 -> ! ; menu_gerir_estufa(EstufaID) ).

% --- Processador de Opções do Submenu Gerir Estufa ---
processar_opcao_estufa(1, EstufaID) :- !, show_frame(EstufaID).
processar_opcao_estufa(2, EstufaID) :- !,
    write('Nova temperatura desejada para a estufa: '), read_opcao(NovaTemp),
    (number(NovaTemp) -> new_value(EstufaID, temperatura_atual, NovaTemp)
    ; write('Valor invalido para temperatura.'), nl).
processar_opcao_estufa(3, EstufaID) :- !,
    write('Novo numero de ocupantes na estufa: '), read_opcao(NovosOcupantes),
    ( (integer(NovosOcupantes), NovosOcupantes >= 0) -> new_value(EstufaID, numero_ocupantes, NovosOcupantes)
    ; write('Valor invalido para numero de ocupantes.'), nl).
processar_opcao_estufa(4, EstufaID) :- !,
    write('Novo Limite X de Ocupantes (e.g., 10): '), read_opcao(X),
    write('Nova Variabilidade Y de Ocupantes (e.g., 2): '), read_opcao(Y),
    write('Novo Ajuste Z de Temperatura (e.g., 1): '), read_opcao(Z),
    ( (integer(X), integer(Y), number(Z), X>=0, Y>=0) ->
        new_value(EstufaID, ocupantes_limite_X, X),
        new_value(EstufaID, ocupantes_variabilidade_Y, Y),
        new_value(EstufaID, ajuste_temperatura_Z, Z),
        write('Parametros de ocupacao atualizados.'), nl
    ; write('Valores invalidos para parametros de ocupacao.'), nl ).
processar_opcao_estufa(5, EstufaID) :- !,
    write('Novo Limite Inferior Base de Conforto (Li Base, e.g., 18): '), read_opcao(LiBase),
    write('Novo Limite Superior Base de Conforto (Ls Base, e.g., 28): '), read_opcao(LsBase),
    write('Novo Limite Inferior Absoluto (Lai, e.g., 10): '), read_opcao(Lai),
    write('Novo Limite Superior Absoluto (Las, e.g., 35): '), read_opcao(Las),
    ( (number(LiBase), number(LsBase), number(Lai), number(Las), Lai < LiBase, LiBase < LsBase, LsBase < Las) ->
        new_value(EstufaID, temp_lim_inf_conforto_base, LiBase),
        new_value(EstufaID, temp_lim_sup_conforto_base, LsBase),
        new_value(EstufaID, temp_lim_inf_absoluto, Lai),
        new_value(EstufaID, temp_lim_sup_absoluto, Las),
        new_value(EstufaID, temp_lim_inf_conforto, LiBase),
        new_value(EstufaID, temp_lim_sup_conforto, LsBase),
        write('Limites base de temperatura atualizados. Limites de conforto atuais resetados para base.'), nl,
        get_value(EstufaID, numero_ocupantes, OcupAtuais),
        demon_ajusta_limites_por_ocupacao(EstufaID, numero_ocupantes, OcupAtuais, OcupAtuais)
    ; write('Valores invalidos para limites de temperatura ou ordem incorreta (Lai < Li < Ls < Las).'), nl ).
processar_opcao_estufa(0, _EstufaID) :- !.
processar_opcao_estufa(_, _EstufaID) :- write('Opcao desconhecida no menu Gerir Estufa.'), nl.

% --- Submenu: Gerir Sensores (opera na EstufaID ativa) ---
menu_gerir_sensores(EstufaID) :-
    nl, format('--- Menu Gerir Sensores: ~w ---~n', [EstufaID]),
    atom_concat(EstufaID, '_soil_01', SoilSensorID),
    atom_concat(EstufaID, '_co2_01', CO2SensorID),
    write('1. Visualizar sensor humidade solo'), nl,
    write('2. Visualizar sensor CO2'), nl,
    write('3. Simular leitura sensor humidade solo'), nl,
    write('4. Simular leitura sensor CO2'), nl,
    write('0. Voltar ao Menu Principal'), nl,
    write('Escolha uma opcao: '),
    read_opcao(Opcao),
    (catch(processar_opcao_sensores(Opcao, EstufaID, SoilSensorID, CO2SensorID),E,(write('Erro: '),print(E),nl)) ; true),
    ( Opcao == 0 -> ! ; menu_gerir_sensores(EstufaID) ).

% --- Processador de Opções do Submenu Gerir Sensores ---
processar_opcao_sensores(1, _EstufaID, SoilSensorID, _CO2SensorID) :- !, (frame_exists(SoilSensorID) -> show_frame(SoilSensorID) ; write('Sensor de humidade do solo nao encontrado.'),nl).
processar_opcao_sensores(2, _EstufaID, _SoilSensorID, CO2SensorID) :- !, (frame_exists(CO2SensorID) -> show_frame(CO2SensorID) ; write('Sensor de CO2 nao encontrado.'),nl).
processar_opcao_sensores(3, _EstufaID, SoilSensorID, _CO2SensorID) :- !, write('Nova leitura para humidade do solo (e.g., 30): '), read_opcao(NovaHumidade), (number(NovaHumidade) -> simular_leitura_sensor(SoilSensorID, NovaHumidade) ; write('Valor invalido.'), nl).
processar_opcao_sensores(4, _EstufaID, _SoilSensorID, CO2SensorID) :- !, write('Nova leitura para CO2 (e.g., 1200): '), read_opcao(NovoCO2), (number(NovoCO2) -> simular_leitura_sensor(CO2SensorID, NovoCO2) ; write('Valor invalido.'), nl).
processar_opcao_sensores(0, _EstufaID, _SoilSensorID, _CO2SensorID) :- !.
processar_opcao_sensores(_, _EstufaID, _SoilSensorID, _CO2SensorID) :- write('Opcao desconhecida no menu Gerir Sensores.'), nl.

% --- Submenu: Gerir Atuadores (opera na EstufaID ativa) ---
menu_gerir_atuadores(EstufaID) :-
    nl, format('--- Menu Gerir Atuadores: ~w ---~n', [EstufaID]),
    atom_concat(EstufaID, '_atuadores', ActuatorsID),
    write('1. Visualizar estado dos atuadores'), nl,
    write('2. Ligar/Desligar Rega Manualmente'), nl,
    write('3. Ligar/Desligar Ventilador Manualmente'), nl,
    write('4. Ligar/Desligar Nebulizador Manualmente'), nl,
    write('0. Voltar ao Menu Principal'), nl,
    write('Escolha uma opcao: '),
    read_opcao(Opcao),
    (catch(processar_opcao_atuadores(Opcao, ActuatorsID),E,(write('Erro: '),print(E),nl)) ; true),
    ( Opcao == 0 -> ! ; menu_gerir_atuadores(EstufaID) ).

% --- Processador de Opções do Submenu Gerir Atuadores ---
processar_opcao_atuadores(1, ActuatorsID) :- !, (frame_exists(ActuatorsID) -> show_frame(ActuatorsID) ; write('Frame de atuadores nao encontrado.'),nl).
processar_opcao_atuadores(2, ActuatorsID) :- !, write('Estado para Rega (on/off): '), read_input_atom(Estado), ( (Estado == on ; Estado == off) -> call_method_1(ActuatorsID, operar_rega, Estado) ; write('Estado invalido.'), nl ).
processar_opcao_atuadores(3, ActuatorsID) :- !, write('Estado para Ventilador (on/off): '), read_input_atom(Estado), ( (Estado == on ; Estado == off) -> call_method_1(ActuatorsID, operar_ventilador, Estado) ; write('Estado invalido.'), nl ).
processar_opcao_atuadores(4, ActuatorsID) :- !, write('Estado para Nebulizador (on/off): '), read_input_atom(Estado), ( (Estado == on ; Estado == off) -> call_method_1(ActuatorsID, operar_nebulizador, Estado) ; write('Estado invalido.'), nl ).
processar_opcao_atuadores(0, _ActuatorsID) :- !.
processar_opcao_atuadores(_, _ActuatorsID) :- write('Opcao desconhecida no menu Gerir Atuadores.'), nl.

% --- Submenu: Gerir Frutas e Lotes (opera na EstufaID ativa) ---
menu_gerir_frutas(EstufaID) :-
    nl, format('--- Menu Gerir Frutas e Lotes: ~w ---~n', [EstufaID]),
    write('1. Visualizar frutas em producao'), nl,
    write('2. Adicionar novo lote de fruta'), nl,
    write('3. Registar colheita de um lote'), nl,
    write('0. Voltar ao Menu Principal'), nl,
    write('Escolha uma opcao: '),
    read_opcao(Opcao),
    (catch(processar_opcao_frutas(Opcao, EstufaID),E,(write('Erro: '),print(E),nl)) ; true),
    ( Opcao == 0 -> ! ; menu_gerir_frutas(EstufaID) ).

% --- Processador de Opções do Submenu Gerir Frutas ---
processar_opcao_frutas(1, EstufaID) :- !, mostrar_frutas_em_estufa(EstufaID).
processar_opcao_frutas(2, EstufaID) :- !,
    write('ID do Prototipo da Fruta (e.g., prototipo_morango): '), read_input_atom(ProtoFruta),
    (frame_exists(ProtoFruta) ->
        write('ID unico para o novo lote (e.g., lote_morango_e1_03): '), read_input_atom(IDLote),
        (\+ frame_exists(IDLote) ->
            write('Quantidade plantada: '), read_opcao(Qtd),
            ( (integer(Qtd), Qtd > 0) ->
                write('Data de semeio (YYYY-MM-DD, ou "hoje" para data atual): '), read_input_atom(DataSemeioStr),
                ( DataSemeioStr == hoje -> add_lote_fruta(EstufaID, IDLote, ProtoFruta, Qtd)
                ; add_lote_fruta(EstufaID, IDLote, ProtoFruta, Qtd, DataSemeioStr)
                )
            ; write('Quantidade invalida.'), nl)
        ; write('ID de lote ja existe.'), nl)
    ; write('Prototipo de fruta nao encontrado.'),nl
    ).
processar_opcao_frutas(3, _EstufaID) :- !,
    write('ID do Lote a colher: '), read_input_atom(IDLote),
    (frame_exists(IDLote) ->
        write('Quantidade colhida: '), read_opcao(QtdColhida),
        ( (integer(QtdColhida), QtdColhida > 0) ->
            write('Data da colheita (YYYY-MM-DD, ou "hoje" para data atual): '), read_input_atom(DataColheitaStr),
            ( DataColheitaStr == hoje -> registar_colheita(IDLote, QtdColhida)
            ; registar_colheita(IDLote, QtdColhida, DataColheitaStr)
            )
        ; write('Quantidade invalida.'), nl)
    ; write('Lote nao encontrado.'),nl
    ).
processar_opcao_frutas(0, _EstufaID) :- !.
processar_opcao_frutas(_, _EstufaID) :- write('Opcao desconhecida no menu Gerir Frutas.'), nl.

% --- Submenu: Gerir Encomendas (Global) ---
menu_gerir_encomendas :-
    nl, write('--- Menu Gerir Encomendas ---'), nl,
    write('1. Criar nova encomenda'), nl,
    write('2. Visualizar encomenda existente'), nl,
    write('0. Voltar ao Menu Principal'), nl,
    write('Escolha uma opcao: '),
    read_opcao(Opcao),
    (catch(processar_opcao_encomendas(Opcao),E,(write('Erro: '),print(E),nl)) ; true),
    ( Opcao == 0 -> ! ; menu_gerir_encomendas ).

% --- Processador de Opções do Submenu Gerir Encomendas ---
processar_opcao_encomendas(1) :- !,
    write('ID do Cliente: '), read_input_atom(IDCliente),
    collect_itens_encomenda([], ItensDesejados),
    ( ItensDesejados \== [] ->
        iniciar_criacao_encomenda(IDCliente, ItensDesejados, IDEncomenda),
        (frame_exists(IDEncomenda) -> mostrar_encomenda(IDEncomenda) ; true)
    ; write('Nenhum item adicionado a encomenda.'),nl
    ).
processar_opcao_encomendas(2) :- !,
    write('ID da Encomenda a visualizar: '), read_input_atom(IDEnc),
    mostrar_encomenda(IDEnc).
processar_opcao_encomendas(0) :- !.
processar_opcao_encomendas(_) :- write('Opcao desconhecida no menu Gerir Encomendas.'), nl.

% collect_itens_encomenda(+AcumuladorItens, -ListaItensFinal)
% Auxiliar para coletar múltiplos itens para uma nova encomenda.
collect_itens_encomenda(Acc, ItensFinais) :-
    write('Adicionar item? (sim/nao): '), read_input_atom(Resp),
    ( Resp == sim ->
        write('ID do Prototipo da Fruta (e.g., prototipo_morango): '), read_input_atom(ProtoFruta),
        (frame_exists(ProtoFruta) ->
            write('Quantidade desejada: '), read_opcao(Qtd),
            ( (integer(Qtd), Qtd > 0) ->
                append(Acc, [[ProtoFruta, Qtd]], NovoAcc),
                collect_itens_encomenda(NovoAcc, ItensFinais)
            ;   write('Quantidade invalida.'), nl,
                collect_itens_encomenda(Acc, ItensFinais)
            )
        ;   write('Prototipo de fruta nao encontrado.'),nl,
            collect_itens_encomenda(Acc, ItensFinais)
        )
    ; ItensFinais = Acc
    ).

% --- Visualizar Todos os Alarmes Gerados (Global) ---
visualizar_todos_alarmes :-
    nl, write('--- Todos os Alarmes Gerados ---'), nl,
    (findall(AlarmeID,
             (frame_(AlarmeID), get_value(AlarmeID, is_alarme_de, alarme_prototipo_estufa)),
             ListaAlarmes),
     ListaAlarmes \== [] ->
        (member(Alarme, ListaAlarmes),
            format('~n--- Alarme: ~w ---~n', [Alarme]),
            (get_value(Alarme, tipo_evento, Evento) -> format('Evento: ~w~n', [Evento]) ; true),
            (get_value(Alarme, valor_associado, Valor) -> format('Valor: ~w~n', [Valor]) ; true),
            (get_value(Alarme, data_hora_evento, DataHora) -> format('Data/Hora: ~w~n', [DataHora]) ; true),
            (get_value(Alarme, estufa_referencia, EstRef) -> format('Estufa: ~w~n', [EstRef]) ; true),
            fail % Para mostrar todos os alarmes por backtracking
        )
    ; write('Nenhum alarme gerado ainda.'), nl
    ),
    true. % Para o predicado suceder após o findall/fail ou se a lista for vazia.

%***********************************************************************************************
% INICIALIZAÇÃO DO MODELO E PONTO DE ENTRADA DO MENU
%***********************************************************************************************

% --- Inicialização do Modelo com Dados de Exemplo ---
modelo_estufa_inicializacao_completa :-
    delete_kb, % Limpa a base de conhecimento para um novo começo
    % Define protótipos globais
    def_alarme_prototipo,
    def_sensor_prototipo,
    def_prototipos_frutas,
    def_prototipo_encomenda,
    % Cria a primeira estufa e seus componentes
    def_estufa_inicial(estufa1),
    def_sensores_estufa(estufa1),
    def_atuadores_estufa(estufa1),
    % Define estufa1 como a estufa ativa por defeito
    retractall(estufa_ativa_id(_)),
    asserta(estufa_ativa_id(estufa1)),
    % Adiciona alguns lotes de fruta à estufa1
    add_lote_fruta(estufa1, lote_morango_e1_01, prototipo_morango, 100),
    add_lote_fruta(estufa1, lote_tomate_e1_01, prototipo_tomate, 50, '2025-05-10'), % Com data de semeio específica
    % Regista colheitas para ter stock disponível para encomendas
    get_simple_date(Hoje),
    add_days_to_date_string(Hoje, -2, DataColheitaMorangoValida), % Colhido há 2 dias
    registar_colheita(lote_morango_e1_01, 80, DataColheitaMorangoValida),
    add_days_to_date_string(Hoje, -1, DataColheitaTomateValida),  % Colhido ontem
    registar_colheita(lote_tomate_e1_01, 30, DataColheitaTomateValida),
    write('Modelo Completo com Menu (Fase 10 - Gestao Estufas) carregado.'), nl,
    (get_value(lote_morango_e1_01, data_validade_lote, ValMorango) -> true ; ValMorango = 'N/A'),
    (get_value(lote_tomate_e1_01, data_validade_lote, ValTomate) -> true ; ValTomate = 'N/A'),
    format('Stock inicial (estufa1): 80 morangos (validade ~w), 30 tomates (validade ~w). Data atual para teste: ~w~n', [ValMorango, ValTomate, Hoje]).

% --- Ponto de Entrada Principal do Programa ---
start :-
    modelo_estufa_inicializacao_completa,
    menu_principal.
