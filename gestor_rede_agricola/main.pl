% ========== PRODUTORES ==========
% produtor(ID, Nome, Zona)
produtor(1, 'João Fernandes', 'Alentejo').
produtor(2, 'Maria Silva', 'Ribatejo').

% ========== QUINTAS ==========
% quinta(ID, Nome, Localizacao, TipoCultivo, ID_Produtor)
quinta(1, 'Quinta do Sol', 'Évora', vinha, 1).
quinta(2, 'Quinta Verde', 'Santarém', milho, 2).
quinta(3, 'Horta Fresca', 'Beja', horticolas, 1).
quinta(4, 'Quinta Norte', 'Porto', macas, 2). % Porto -> norte
%===========Regiao=============
regiao('Évora', sul).
regiao('Santarém', centro).
regiao('Beja', sul).
regiao('Porto', norte).
regiao('Coimbra', centro).
regiao('Faro', sul).
% ========== SENSORES ==========
% sensor(ID, Tipo, ID_Quinta)
sensor(1, temperatura, 1).
sensor(2, humidade, 1).
sensor(3, radiacao, 1).
sensor(4, temperatura, 2).
sensor(5, humidade, 2).

% ========== DISTRIBUIDORES ==========
% distribuidor(ID, Nome, Localizacao, NivelProcura)
distribuidor(1, 'Distribuidor Norte', 'Porto', alta).
distribuidor(2, 'Distribuidor Centro', 'Coimbra', media).
distribuidor(3, 'Distribuidor Sul', 'Faro', baixa).
distribuidor(4, 'Distribuidor Nordeste', 'Braga', media). % Braga -> norte
% ========== TRANSPORTADORAS ==========
% transportadora(ID, Nome, CapacidadeCarga, TipoCombustivel, ImpactoAmbiental, AreasCobertura)

% transportadora(ID, Nome, Capacidade, Combustível, Impacto, Áreas)
transportadora(1, 'TransVerde', 5000, eletrico, 0.5, [norte, centro, sul]). % Cobre todas
transportadora(2, 'RapidaCarga', 8000, fossil, 2.3, [centro, sul]).          % Não cobre norte
transportadora(3, 'EcoTrans', 6000, hibrido, 1.2, [norte, centro]).          % Não cobre sul
% ========== LIGAÇÕES ENTRE NÓS ==========
% ligacao(ID_No1, ID_No2, Distancia, TempoPercurso, TipoVia, Custo)
ligacao(1, 1, 150, 120, autoestrada, 50).   % Quinta 1 (ID 1) -> Distribuidor 1 (ID 1)
ligacao(2, 2, 80, 60, nacional, 30).       % Quinta 2 (ID 2) -> Distribuidor 2 (ID 2)
ligacao(3, 3, 120, 90, autoestrada, 45).   % Quinta 3 (ID 3) -> Distribuidor 3 (ID 3)
ligacao(2, 3, 180, 130, autoestrada, 60).  % Distribuidor 2 (ID 2) -> Distribuidor 3 (ID 3)
ligacao(1, 3, 600, 200, autoestrada, 70).  % Quinta 1 (ID 1) -> Distribuidor 3 (ID 3) (opcional)
ligacao(4, 1, 100, 200, autoestrada, 50). % Quinta 4 -> Distribuidor 1 ('Porto')
ligacao(1, 2, 150, 200, nacional, 40). % Distribuidor 1 ('Porto') -> Distribuidor 2 ('Coimbra')
ligacao(4, 2, 270, 200, autoestrada, 60). % Ligação direta Quinta 4 -> Distribuidor 2 ('Coimbra')
%========== ida e volta ======================
conexao(X, Y, D) :- ligacao(X, Y, D, _, _, _).
conexao(X, Y, D) :- ligacao(Y, X, D, _, _, _).


% ========== LEITURAS DE SENSORES ==========
% leitura(ID_Sensor, Valor, DataHora)
leitura(1, 25.5, '2025-05-01 10:00:00').
leitura(1, 28.0, '2025-05-01 12:00:00').
leitura(2, 45.0, '2025-05-01 10:00:00').
leitura(4, 30.2, '2025-05-01 11:00:00').

% ========== CONSUMOS HÍDRICOS ==========
% consumo_hidrico(ID_Quinta, TipoCultura, Volume, Periodo)
consumo_hidrico(1, vinha, 5000, '2025-04').
consumo_hidrico(2, milho, 8000, '2025-04').
consumo_hidrico(3, horticolas, 3000, '2025-04').

valor_critico(temperatura, V) :- V > 35. % Temperatura > 35°C
valor_critico(humidade, V) :- V < 30.    % Humidade < 30%
valor_critico(radiacao, V) :- V > 800.   % Radiação > 800 W/m²

% Predicado para obter a pontuação do tipo de combustível
pontuacao_combustivel(eletrico, -50).
pontuacao_combustivel(hibrido, -20).
pontuacao_combustivel(fossil, 50).
pontuacao_combustivel(_, 10).       % Para tipos não listados, uma penalidade moderada

:- dynamic quinta/5.
:- dynamic sensor/3.
% RF1---------------------------------------------------------------------------------------------------------------------------
% Menu principal para gestão de quintas
gerir_quintas :-
    repeat,
    format('~n=== GESTÃO DE QUINTAS ===~n', []),
    format('1. Listar quintas~n', []),
    format('2. Adicionar quinta~n', []),
    format('3. Remover quinta~n', []),
    format('4. Voltar~n~n', []),
    get_single_char(Code),
    char_code(Opcao, Code),
    nl,
    (Opcao = '1' -> listar_quintas ;
     Opcao = '2' -> adicionar_quinta ;
     Opcao = '3' -> remover_quinta ;
     Opcao = '4' -> !, format('Retornando ao menu principal...~n', []) ;
     format('Opção inválida!~n', [])),
    Opcao = '4'.

% Listar todas as quintas
listar_quintas :-
    format('~n--- Lista de Quintas ---~n', []),
    (quinta(ID, Nome, Local, Cultivo, ProdutorID),
     produtor(ProdutorID, ProdutorNome, _),
     format('ID: ~w | Nome: ~w | Local: ~w | Cultivo: ~w | Produtor: ~w~n',
            [ID, Nome, Local, Cultivo, ProdutorNome]),
     fail)
    ; true.
adicionar_quinta :-
    format('~n--- Adicionar Nova Quinta ---~n', []),

    % Obter novo ID (versão simplificada)
    (findall(ID,quinta(ID,_,_,_,_),IDs),
    (IDs=[]-> NovoID = 1; max_list(IDs,MaxID), NovoID is MaxID + 1)),

     % Obter dados
    format('Nome da Quinta: '), read_line_to_string(user_input, Nome),
    format('Localização: '), read_line_to_string(user_input, Localizacao),
    format('Tipo de Cultivo: '), read_line_to_string(user_input, TipoCultivo),
    format('ID do Produtor: '), read_line_to_string(user_input, ProdutorInput),
    atom_number(ProdutorInput, ProdutorID),

    % Validar e adicionar
    (produtor(ProdutorID, _, _)
     -> assertz(quinta(NovoID, Nome, Localizacao, TipoCultivo, ProdutorID)),
        format('Quinta adicionada com sucesso! ID: ~w~n', [NovoID])
     ; format('ERRO: Produtor não existe!~n', [])).

% Remover quinta existente
remover_quinta :-
    format('~n--- Remover Quinta ---~n', []),
    listar_quintas,
    format('ID da Quinta a remover: ', []),
    read_line_to_string(user_input, IDInput),
    atom_number(IDInput, ID),

    (quinta(ID, Nome, _, _, _) ->
        % Remover todos os sensores associados primeiro
        retractall(sensor(_, _, ID)),
        % Depois remover a quinta
        retract(quinta(ID, Nome, _, _, _)),
        format('Quinta "~w" removida com sucesso!~n', [Nome])
    ;
        format('Erro: Quinta com ID ~w não existe!~n', [ID])
    ).
read_line_to_string(Stream, String) :-
    read_line_to_codes(Stream, Codes),
    atom_codes(String, Codes).

:- dynamic sensor/3.  % sensor(ID, Tipo, ID_Quinta)
:- dynamic leitura/3. % leitura(ID_Sensor, Valor, Timestamp)
% RF2---------------------------------------------------------------------------------------------------------------------------
%

% Menu principal de gestão de sensores
gerir_sensores :-
    repeat,
    format('~n=== GESTÃO DE SENSORES ===~n', []),
    format('1. Listar sensores~n', []),
    format('2. Adicionar sensor~n', []),
    format('3. Remover sensor~n', []),
    format('4. Ver últimas leituras~n', []),
    format('5. Voltar~n~n', []),
    get_single_char(Code),
    char_code(Opcao, Code),
    nl,
    (Opcao == '1' -> listar_sensores ;
     Opcao == '2' -> adicionar_sensor ;
     Opcao == '3' -> remover_sensor ;
     Opcao == '4' -> ver_ultimas_leituras ;
     Opcao == '5' -> !, format('Retornando ao menu principal...~n', []) ;
     format('Opção inválida! Pressione 1-5.~n', [])),
    Opcao == '5'.

% 1. Listar todos os sensores
listar_sensores :-
    format('~n--- Lista de Sensores ---~n', []),
    (sensor(ID, Tipo, QuintaID),
     quinta(QuintaID, NomeQuinta, _, _, _),
     format('ID: ~w | Tipo: ~w | Quinta: ~w~n', [ID, Tipo, NomeQuinta]),
     fail)
    ; true.

% 2. Adicionar novo sensor
adicionar_sensor :-
    format('~n--- Adicionar Novo Sensor ---~n', []),

    % Obter novo ID
    (findall(ID, sensor(ID, _, _), IDs),
     (IDs = [] -> NovoID = 1; max_list(IDs, MaxID), NovoID is MaxID + 1),

    % Listar quintas disponíveis
    format('Quintas disponíveis:~n', []),
    listar_quintas_simplificado,

    % Obter dados do usuário
    format('ID da Quinta: ', []),
    read_line_to_string(user_input, QuintaInput),
    atom_number(QuintaInput, QuintaID),

    format('Tipo do Sensor (temperatura/humidade/radiacao/etc): ', []),
    read_line_to_string(user_input, Tipo),

    % Validar quinta existe
    (quinta(QuintaID, _, _, _, _)
     -> assertz(sensor(NovoID, Tipo, QuintaID)),
        format('Sensor ~w adicionado com sucesso à quinta ID ~w!~n', [Tipo, QuintaID])
     ; format('Erro: Quinta com ID ~w não existe!~n', [QuintaID])) ).

% Listagem simplificada de quintas (para seleção)
listar_quintas_simplificado :-
    quinta(ID, Nome, _, _, _),
    format('ID: ~w - ~w~n', [ID, Nome]),
    fail.
listar_quintas_simplificado.

% 3. Remover sensor existente
remover_sensor :-
    format('~n--- Remover Sensor ---~n', []),
    listar_sensores,
    format('ID do Sensor a remover: ', []),
    read_line_to_string(user_input, IDInput),
    atom_number(IDInput, ID),

    (sensor(ID, Tipo, _)
     -> retract(sensor(ID, Tipo, _)),
        retractall(leitura(ID, _, _)), % Remove todas as leituras associadas
        format('Sensor ~w removido com sucesso!~n', [ID])
     ; format('Erro: Sensor com ID ~w não existe!~n', [ID])).

% 4. Ver últimas leituras de todos os sensores
ver_ultimas_leituras :-
    format('~n--- Últimas Leituras dos Sensores ---~n', []),
    (sensor(ID, Tipo, QuintaID),
     quinta(QuintaID, NomeQuinta, _, _, _),
     (ultima_leitura(ID, Valor)
      -> format('Sensor ~w (~w) na ~w: ~w~n', [ID, Tipo, NomeQuinta, Valor])
      ;  format('Sensor ~w (~w) na ~w: SEM LEITURAS~n', [ID, Tipo, NomeQuinta])),
     fail)
    ; true.

% Predicado auxiliar para última leitura
ultima_leitura(SensorID, Valor) :-
    findall(TS-Val, leitura(SensorID, Val, TS), Leituras),
    Leituras \= [],
    max_member(_-Valor, Leituras).

:- dynamic produtor/3. % produtor(ID, Nome, Regiao)
% RF3---------------------------------------------------------------------------------------------------------------------------

% Menu principal de gestão de produtores
gerir_produtores :-
    repeat,
    format('~n=== GESTÃO DE PRODUTORES ===~n', []),
    format('1. Listar produtores~n', []),
    format('2. Adicionar produtor~n', []),
    format('3. Editar produtor~n', []),
    format('4. Remover produtor~n', []),
    format('5. Voltar~n~n', []),
    get_single_char(Code),
    char_code(Opcao, Code),
    nl,
    (Opcao == '1' -> listar_produtores ;
     Opcao == '2' -> adicionar_produtor ;
     Opcao == '3' -> editar_produtor ;
     Opcao == '4' -> remover_produtor ;
     Opcao == '5' -> !, format('Retornando ao menu principal...~n', []) ;
     format('Opção inválida! Pressione 1-5.~n', [])),
    Opcao == '5'.

% 1. Listar todos os produtores
listar_produtores :-
    format('~n--- Lista de Produtores ---~n', []),
    (produtor(ID, Nome, Regiao),
     format('ID: ~w | Nome: ~w | Região: ~w~n', [ID, Nome, Regiao]),
     fail)
    ; true.

% 2. Adicionar novo produtor
adicionar_produtor :-
    format('~n--- Adicionar Novo Produtor ---~n', []),

    % Obter novo ID
    (findall(ID, produtor(ID, _, _), IDs),
     (IDs = [] -> NovoID = 1; max_list(IDs, MaxID), NovoID is MaxID + 1),

    % Obter dados do usuário
    format('Nome do Produtor: ', []),
    read_line_to_string(user_input, Nome),

    format('Região: ', []),
    read_line_to_string(user_input, Regiao),

    % Adicionar à base de conhecimento
    assertz(produtor(NovoID, Nome, Regiao)),
    format('Produtor ~w adicionado com sucesso (ID: ~w)!~n', [Nome, NovoID])).

% 3. Editar produtor existente
editar_produtor :-
    format('~n--- Editar Produtor ---~n', []),
    listar_produtores,
    format('ID do Produtor a editar: ', []),
    read_line_to_string(user_input, IDInput),
    atom_number(IDInput, ID),

    (produtor(ID, NomeAtual, RegiaoAtual)
     ->
        format('Nome atual: ~w (deixe em branco para manter)~nNovo nome: ', [NomeAtual]),
        read_line_to_string(user_input, NovoNome),
        (NovoNome == "" -> NomeFinal = NomeAtual; NomeFinal = NovoNome),

        format('Região atual: ~w (deixe em branco para manter)~nNova região: ', [RegiaoAtual]),
        read_line_to_string(user_input, NovaRegiao),
        (NovaRegiao == "" -> RegiaoFinal = RegiaoAtual; RegiaoFinal = NovaRegiao),

        % Atualizar os dados
        retract(produtor(ID, _, _)),
        assertz(produtor(ID, NomeFinal, RegiaoFinal)),
        format('Produtor ID ~w atualizado com sucesso!~n', [ID])
     ;
        format('Erro: Produtor com ID ~w não existe!~n', [ID])
    ).

% 4. Remover produtor existente
remover_produtor :-
    format('~n--- Remover Produtor ---~n', []),
    listar_produtores,
    format('ID do Produtor a remover: ', []),
    read_line_to_string(user_input, IDInput),
    atom_number(IDInput, ID),

    (produtor(ID, Nome, _)
     ->
        % Verificar se o produtor tem quintas associadas
        (quinta(_, _, _, _, ID)
         -> format('AVISO: Este produtor tem quintas associadas! Remova-as primeiro.~n', [])
         ;
            retract(produtor(ID, Nome, _)),
            format('Produtor ~w removido com sucesso!~n', [Nome])
        )
     ;
        format('Erro: Produtor com ID ~w não existe!~n', [ID])
    ).

:- dynamic transportadora/6. % transportadora(ID, Nome, Capacidade, TipoCombustivel, ImpactoAmbiental,AreaCoberta)
% RF3---------------------------------------------------------------------------------------------------------------------------

% Menu principal de gestão de transportadoras
gerir_transportadoras :-
    repeat,
    format('~n=== GESTÃO DE TRANSPORTADORAS ===~n', []),
    format('1. Listar transportadoras~n', []),
    format('2. Adicionar transportadora~n', []),
    format('3. Editar transportadora~n', []),
    format('4. Remover transportadora~n', []),
    format('5. Voltar~n~n', []),
    get_single_char(Code),
    char_code(Opcao, Code),
    nl,
    (Opcao == '1' -> listar_transportadoras ;
     Opcao == '2' -> adicionar_transportadora ;
     Opcao == '3' -> editar_transportadora ;
     Opcao == '4' -> remover_transportadora ;
     Opcao == '5' -> !, format('Retornando ao menu principal...~n', []) ;
     format('Opção inválida! Pressione 1-5.~n', [])),
    Opcao == '5'.

% 1. Listar todas as transportadoras
listar_transportadoras :-
    format('~n--- Lista de Transportadoras ---~n', []),
    (transportadora(ID, Nome, Capacidade, Combustivel, Impacto,AreaCoberta),
     format('ID: ~w | Nome: ~w~n', [ID, Nome]),
     format('   Capacidade: ~w kg | Combustível: ~w | Impacto Ambiental: ~w CO2/km | AreaCoberta: ~w ~n~n ',
           [Capacidade, Combustivel, Impacto,AreaCoberta]),
     fail)
    ; true.

% 2. Adicionar nova transportadora
adicionar_transportadora :-
    format('~n--- Adicionar Nova Transportadora ---~n', []),

    % Obter novo ID
    (findall(ID, transportadora(ID, _, _, _, _,_), IDs),
     (IDs = [] -> NovoID = 1; max_list(IDs, MaxID), NovoID is MaxID + 1),

    % Obter dados do usuário
    format('Nome da Transportadora: ', []),
    read_line_to_string(user_input, Nome),

    format('Capacidade de carga (kg): ', []),
    read_line_to_string(user_input, CapInput),
    atom_number(CapInput, Capacidade),

    format('Tipo de Combustível (fossil/eletrico/hibrido/biodiesel): ', []),
    read_line_to_string(user_input, Combustivel),

    format('Impacto Ambiental (CO2/km): ', []),
    read_line_to_string(user_input, ImpactoInput),
    atom_number(ImpactoInput, Impacto),

    format('Area Coberta [norte,centro,sul]: ', []),
    read_line_to_string(user_input, AreaCoberta),

    % Adicionar à base de conhecimento
    assertz(transportadora(NovoID, Nome, Capacidade, Combustivel, Impacto,AreaCoberta)),
    format('Transportadora ~w adicionada com sucesso (ID: ~w)!~n', [Nome, NovoID])).

% 3. Editar transportadora existente
editar_transportadora :-
    format('~n--- Editar Transportadora ---~n', []),
    listar_transportadoras,
    format('ID da Transportadora a editar: ', []),
    read_line_to_string(user_input, IDInput),
    atom_number(IDInput, ID),

    (transportadora(ID, NomeAtual, CapAtual, CombAtual, ImpactoAtual,AreaCobertaAtual)
     ->
        format('Nome atual: ~w (deixe em branco para manter)~nNovo nome: ', [NomeAtual]),
        read_line_to_string(user_input, NovoNome),
        (NovoNome == "" -> NomeFinal = NomeAtual; NomeFinal = NovoNome),

        format('Capacidade atual: ~w (0 para manter)~nNova capacidade: ', [CapAtual]),
        read_line_to_string(user_input, NovaCapInput),
        atom_number(NovaCapInput, NovaCap),
        (NovaCap =:= 0 -> CapFinal = CapAtual; CapFinal = NovaCap),

        format('Combustível atual: ~w (deixe em branco para manter)~nNovo combustível: ', [CombAtual]),
        read_line_to_string(user_input, NovoComb),
        (NovoComb == "" -> CombFinal = CombAtual; CombFinal = NovoComb),

        format('Impacto atual: ~w (0 para manter)~nNovo impacto: ', [ImpactoAtual]),
        read_line_to_string(user_input, NovoImpactoInput),
        atom_number(NovoImpactoInput, NovoImpacto),
        (NovoImpacto =:= 0 -> ImpactoFinal = ImpactoAtual; ImpactoFinal = NovoImpacto),

        format('Area atual: ~w (0 para manter)~nNova Area: ', [AreaCobertaAtual]),
        read_line_to_string(user_input, NovaAreaCobertaInput),
        atom_number(NovaAreaCobertaInput, NovaAreaCoberta),
        (NovaAreaCoberta =:= 0 -> AreaCoberta = AreaCobertaAtual; AreaCoberta = NovaAreaCoberta),

        % Atualizar os dados
        retract(transportadora(ID, _, _, _, _,_)),
        assertz(transportadora(ID, NomeFinal, CapFinal, CombFinal, ImpactoFinal,AreaCoberta)),
        format('Transportadora ID ~w atualizada com sucesso!~n', [ID])
     ;
        format('Erro: Transportadora com ID ~w não existe!~n', [ID])
    ).

% 4. Remover transportadora existente
remover_transportadora :-
    format('~n--- Remover Transportadora ---~n', []),
    listar_transportadoras,
    format('ID da Transportadora a remover: ', []),
    read_line_to_string(user_input, IDInput),
    atom_number(IDInput, ID),

    (transportadora(ID, Nome, _, _, _,_)
     ->
        retract(transportadora(ID, Nome, _, _, _,_)),
        format('Transportadora ~w removida com sucesso!~n', [Nome])
     ;
        format('Erro: Transportadora com ID ~w não existe!~n', [ID])
    ).

:- dynamic ligacao/6. % ligacao(ID, NoOrigem, NoDestino, Distancia, Tempo, Custo)
% RF4---------------------------------------------------------------------------------------------------------------------------
% Menu principal de gestão de ligações
gerir_ligacoes :-
    repeat,
    format('~n=== GESTÃO DE LIGAÇÕES DA REDE ===~n', []),
    format('1. Listar todas as ligações~n', []),
    format('2. Adicionar ligação~n', []),
    format('3. Editar ligação~n', []),
    format('4. Remover ligação~n', []),
    format('5. Voltar~n~n', []),
    get_single_char(Code),
    char_code(Opcao, Code),
    nl,
    (Opcao == '1' -> listar_ligacoes ;
     Opcao == '2' -> adicionar_ligacao ;
     Opcao == '3' -> editar_ligacao ;
     Opcao == '4' -> remover_ligacao ;
     Opcao == '5' -> !, format('Retornando ao menu principal...~n', []) ;
     format('Opção inválida! Pressione 1-5.~n', [])),
    Opcao == '5'.

% 1. Listar todas as ligações
listar_ligacoes :-
    format('~n--- Lista de Ligações da Rede ---~n', []),
    (ligacao(ID, Origem, Destino, Dist, Tempo, Custo),
     (no(Origem, NomeOrigem), (no(Destino, NomeDestino)),
     format('ID: ~w | ~w (ID:~w) -> ~w (ID:~w)~n', [ID, NomeOrigem, Origem, NomeDestino, Destino]),
     format('   Distância: ~w km | Tempo: ~w min | Custo: ~w€~n~n', [Dist, Tempo, Custo]),
     fail)
    ; true).

% Predicado auxiliar para obter nome do nó (quinta ou distribuidor)
no(ID, Nome) :- quinta(ID, Nome, _, _, _).
no(ID, Nome) :- distribuidor(ID, Nome, _,_).

% 2. Adicionar nova ligação
adicionar_ligacao :-
    format('~n--- Adicionar Nova Ligação ---~n', []),

    % Obter novo ID
    (findall(ID, ligacao(ID, _, _, _, _, _), IDs),
     (IDs = [] -> NovoID = 1; max_list(IDs, MaxID), NovoID is MaxID + 1),

    % Listar nós disponíveis
    format('Nós disponíveis (quintas e distribuidores):~n', []),
    listar_nos_simplificado,

    % Obter dados do usuário
    format('ID do Nó de Origem: ', []),
    read_line_to_string(user_input, OrigemInput),
    atom_number(OrigemInput, Origem),

    format('ID do Nó de Destino: ', []),
    read_line_to_string(user_input, DestinoInput),
    atom_number(DestinoInput, Destino),

    format('Distância (km): ', []),
    read_line_to_string(user_input, DistInput),
    atom_number(DistInput, Distancia),

    format('Tempo médio de percurso (minutos): ', []),
    read_line_to_string(user_input, TempoInput),
    atom_number(TempoInput, Tempo),

    format('Custo médio (€): ', []),
    read_line_to_string(user_input, CustoInput),
    atom_number(CustoInput, Custo),

    % Validar nós existem e são diferentes
    (no(Origem, _), no(Destino, _), Origem \= Destino
     ->
        assertz(ligacao(NovoID, Origem, Destino, Distancia, Tempo, Custo)),
        format('Ligação adicionada com sucesso (ID: ~w)!~n', [NovoID])
     ;
        format('Erro: IDs inválidos ou iguais! Verifique os nós existentes.~n', [])
    ) ).

% Listagem simplificada de nós
listar_nos_simplificado :-
    (quinta(ID, Nome, _, _, _),
     format('Quinta ID: ~w - ~w~n', [ID, Nome]),
     fail ;
    distribuidor(ID, Nome, _, _),
     format('Distribuidor ID: ~w - ~w~n', [ID, Nome]),
     fail).
listar_nos_simplificado.

% 3. Editar ligação existente
editar_ligacao :-
    format('~n--- Editar Ligação ---~n', []),
    listar_ligacoes,
    format('ID da Ligação a editar: ', []),
    read_line_to_string(user_input, IDInput),
    atom_number(IDInput, ID),

    (ligacao(ID, Origem, Destino, DistAtual, TempoAtual, CustoAtual)
     ->
        format('Distância atual: ~w km (0 para manter)~nNova distância: ', [DistAtual]),
        read_line_to_string(user_input, NovaDistInput),
        atom_number(NovaDistInput, NovaDist),
        (NovaDist =:= 0 -> DistFinal = DistAtual; DistFinal = NovaDist),

        format('Tempo atual: ~w min (0 para manter)~nNovo tempo: ', [TempoAtual]),
        read_line_to_string(user_input, NovoTempoInput),
        atom_number(NovoTempoInput, NovoTempo),
        (NovoTempo =:= 0 -> TempoFinal = TempoAtual; TempoFinal = NovoTempo),

        format('Custo atual: ~w€ (0 para manter)~nNovo custo: ', [CustoAtual]),
        read_line_to_string(user_input, NovoCustoInput),
        atom_number(NovoCustoInput, NovoCusto),
        (NovoCusto =:= 0 -> CustoFinal = CustoAtual; CustoFinal = NovoCusto),

        % Atualizar os dados
        retract(ligacao(ID, _, _, _, _, _)),
        assertz(ligacao(ID, Origem, Destino, DistFinal, TempoFinal, CustoFinal)),
        format('Ligação ID ~w atualizada com sucesso!~n', [ID])
     ;
        format('Erro: Ligação com ID ~w não existe!~n', [ID])
    ).

% 4. Remover ligação existente
remover_ligacao :-
    format('~n--- Remover Ligação ---~n', []),
    listar_ligacoes,
    format('ID da Ligação a remover: ', []),
    read_line_to_string(user_input, IDInput),
    atom_number(IDInput, ID),

    (ligacao(ID, Origem, Destino, _, _, _)
     ->
        retract(ligacao(ID, Origem, Destino, _, _, _)),
        format('Ligação entre ~w e ~w removida com sucesso!~n', [Origem, Destino])
     ;
        format('Erro: Ligação com ID ~w não existe!~n', [ID])
    ).

% RF5-------------------------------------------------------------------------------------------------------------------------
% Registar e atualizar leituras dos sensores (temperatura, humidade,
% etc) e consumos hídricos por quinta ou cultura.
:- dynamic leitura/3.      % leitura(ID_Sensor, Tipo, Valor, DataHora)
:- dynamic consumo_agua/4. % consumo_agua(ID_Quinta, TipoCultura, Volume, Periodo)

% Menu principal de gestão
gerir_monitoramento :-
    repeat,
    format('~n=== MONITORAMENTO AGRÍCOLA ===~n', []),
    format('1. Registrar leitura de sensor~n', []),
    format('2. Registrar consumo hídrico~n', []),
    format('3. Consultar leituras recentes~n', []),
    format('4. Consultar consumos hídricos~n', []),
    format('5. Alertas de valores críticos~n', []),
    format('6. Voltar~n~n', []),
    get_single_char(Code),
    char_code(Opcao, Code),
    nl,
    (Opcao == '1' -> registrar_leitura ;
     Opcao == '2' -> registrar_consumo ;
     Opcao == '3' -> consultar_leituras ;
     Opcao == '4' -> consultar_consumos ;
     Opcao == '5' -> verificar_alertas ;
     Opcao == '6' -> !, format('Retornando ao menu principal...~n', []) ;
     format('Opção inválida! Pressione 1-6.~n', [])),
    Opcao == '6'.

% 1. Registrar nova leitura de sensor
registrar_leitura :-
    format('~n--- REGISTRAR LEITURA DE SENSOR ---~n', []),

    % Listar sensores disponíveis
    format('Sensores disponíveis:~n', []),
    findall(ID-Tipo, sensor(ID, Tipo, _), Sensores),
    mostrar_lista(Sensores),

    % Obter dados do usuário
    format('ID do Sensor: ', []),
    read_line_to_string(user_input, SensorInput),
    atom_number(SensorInput, SensorID),

    (member(SensorID-_, Sensores)
     ->
        format('Valor da leitura: ', []),
        read_line_to_string(user_input, ValorInput),
        atom_number(ValorInput, Valor),

        % Obter data/hora atual
        get_time(Timestamp),
        stamp_date_time(Timestamp, DateTime, 'UTC'),
        format_time(atom(DataHora), '%Y-%m-%d %H:%M:%S', DateTime),

        % Registrar a leitura
        sensor(SensorID, Tipo, _),
        assertz(leitura(SensorID,Valor, DataHora)),
        format('Leitura de ~w registrada: ~w em ~w~n', [Tipo, Valor, DataHora])
     ;
        format('Erro: Sensor com ID ~w não existe!~n', [SensorID])
    ).

% 2. Registrar consumo hídrico
registrar_consumo :-
    format('~n--- REGISTRAR CONSUMO HÍDRICO ---~n', []),

    % Listar quintas disponíveis
    format('Quintas disponíveis:~n', []),
    findall(ID-Nome, quinta(ID, Nome, _, _, _), Quintas),
    mostrar_lista(Quintas),

    % Obter dados do usuário
    format('ID da Quinta: ', []),
    read_line_to_string(user_input, QuintaInput),
    atom_number(QuintaInput, QuintaID),

    (member(QuintaID-_, Quintas)
     ->
        quinta(QuintaID, _, _, TipoCultura, _),
        format('Tipo de Cultura [~w]: ', [TipoCultura]),
        read_line_to_string(user_input, CulturaInput),
        (CulturaInput == "" -> Cultura = TipoCultura; Cultura = CulturaInput),

        format('Volume de água consumido (litros): ', []),
        read_line_to_string(user_input, VolumeInput),
        atom_number(VolumeInput, Volume),

        format('Período (YYYY-MM): ', []),
        read_line_to_string(user_input, Periodo),

        % Registrar o consumo
        assertz(consumo_agua(QuintaID, Cultura, Volume, Periodo)),
        format('Consumo registrado: ~w litros para ~w em ~w~n', [Volume, Cultura, Periodo])
     ;
        format('Erro: Quinta com ID ~w não existe!~n', [QuintaID])
    ).

% 3. Consultar leituras recentes
consultar_leituras :-
    format('~n--- LEITURAS RECENTES ---~n', []),
    (leitura(ID, Valor, DataHora),
     sensor(ID, _, QuintaID),
     quinta(QuintaID, NomeQuinta, _, _, _),
     format('~w | ~w | Quinta: ~w (~w)~n', [DataHora,Valor, NomeQuinta, QuintaID]),
     fail)
    ; true.

% 4. Consultar consumos hídricos
consultar_consumos :-
    format('~n--- CONSUMOS HÍDRICOS ---~n', []),
    format('1. Por quinta~n', []),
    format('2. Por cultura~n', []),
    format('Opção: ', []),
    get_single_char(Code),
    char_code(Opcao, Code),
    nl,
    (Opcao == '1' -> consumos_por_quinta ;
     Opcao == '2' -> consumos_por_cultura ;
     format('Opção inválida!~n', [])).

consumos_por_quinta :-
    format('~n--- CONSUMO POR QUINTA ---~n', []),
    findall(QuintaID-Nome, quinta(QuintaID, Nome, _, _, _), Quintas),
    (member(QuintaID-Nome, Quintas),
     findall(Volume, consumo_agua(QuintaID, _, Volume, _), Volumes),
     sum_list(Volumes, Total),
     format('~w: ~w litros~n', [Nome, Total]),
     fail)
    ; true.

consumos_por_cultura :-
    format('~n--- CONSUMO POR CULTURA ---~n', []),
    setof(Cultura, QuintaID^Volume^Periodo^consumo_agua(QuintaID, Cultura, Volume, Periodo), Culturas),
    (member(Cultura, Culturas),
     findall(Volume, consumo_agua(_, Cultura, Volume, _), Volumes),
     sum_list(Volumes, Total),
     format('~w: ~w litros~n', [Cultura, Total]),
     fail)
    ; true.

% 5. Verificar alertas
verificar_alertas :-
    format('~n--- ALERTAS DE VALORES CRÍTICOS ---~n', []),
    (leitura(ID, Valor,__ ),
     sensor(ID, Tipo, QuintaID),
     valor_critico(Tipo, Valor),
     quinta(QuintaID, NomeQuinta, _, _, _),
     format('ALERTA: ~w na quinta ~w - Valor: ~w~n', [Tipo, NomeQuinta, Valor]),
     fail)
    ; true.

% Predicados auxiliares
mostrar_lista([]).
mostrar_lista([ID-Nome|Resto]) :-
    format('~w - ~w~n', [ID, Nome]),
    mostrar_lista(Resto).

%============RF11===================

:- dynamic melhor_rota/2.

rota_mais_curta(Origem, Destino, Caminho, Distancia) :-
    retractall(melhor_rota(_, _)),
    dfs(Origem, Destino, [Origem], 0),
    melhor_rota(CaminhoInv, Distancia),
    reverse(CaminhoInv, Caminho).

dfs(Destino, Destino, Caminho, Distancia) :-
    atualiza_rota(Caminho, Distancia).
dfs(Atual, Destino, Visitados, DistTotal) :-
    conexao(Atual, Prox, Dist),
    \+ member(Prox, Visitados),
    NovoDist is DistTotal + Dist,
    dfs(Prox, Destino, [Prox|Visitados], NovoDist).

atualiza_rota(Caminho, Distancia) :-
    ( melhor_rota(_, DAntiga) ->
        Distancia < DAntiga,
        retract(melhor_rota(_, _)),
        assertz(melhor_rota(Caminho, Distancia))
    ;
        assertz(melhor_rota(Caminho, Distancia))
    ).

% Rota mais curta entre uma quinta e um distribuidor usando os NOMES
rota_por_nome(NomeQuinta, NomeDistribuidor, Caminho, Distancia) :-
    quinta(IDQuinta, NomeQuinta, _, _, _),
    distribuidor(IDDistribuidor, NomeDistribuidor, _, _),
    rota_mais_curta(IDQuinta, IDDistribuidor, CaminhoIDs, Distancia),
    maplist(nome_nodo, CaminhoIDs, Caminho).

% Converte ID de quinta ou distribuidor no respetivo nome
nome_nodo(ID, Nome) :-
    quinta(ID, Nome, _, _, _), !.
nome_nodo(ID, Nome) :-
    distribuidor(ID, Nome, _, _), !.
%================ RF12 =================

% Cálculo de impacto ambiental total para uma rota
impacto_ambiental_rota([_], _, 0).
impacto_ambiental_rota([Origem, Destino|Resto], TransportadoraID, ImpactoTotal) :-
    ligacao(Origem, Destino, Distancia, _, _, _),
    transportadora(TransportadoraID, _, _, _, ImpactoPorKm, AreasCobertura),
    (quinta(Origem, _, LocalizacaoOrigem, _, _) ; distribuidor(Origem, _, LocalizacaoOrigem, _)),
    (quinta(Destino, _, LocalizacaoDestino, _, _) ; distribuidor(Destino, _, LocalizacaoDestino, _)),
    regiao(LocalizacaoOrigem, RegiaoOrigem),
    regiao(LocalizacaoDestino, RegiaoDestino),
    member(RegiaoOrigem, AreasCobertura),
    member(RegiaoDestino, AreasCobertura),
    impacto_ambiental_rota([Destino|Resto], TransportadoraID, ImpactoRestante),
    ImpactoTotal is Distancia * ImpactoPorKm + ImpactoRestante.

% Verifica se a transportadora cobre todas as regiões da rota
verifica_cobertura_rota([], _).
verifica_cobertura_rota([No|Resto], AreasCobertura) :-
    (quinta(No, _, Localizacao, _, _) ; distribuidor(No, _, Localizacao, _)),
    regiao(Localizacao, Regiao),
    member(Regiao, AreasCobertura),
    verifica_cobertura_rota(Resto, AreasCobertura).

% Seleciona a melhor transportadora para a rota
melhor_rota_menor_impacto(Origem, Destino, MelhorTransportadora, MenorImpacto) :-
    findall(Rota, rota_mais_curta(Origem, Destino, Rota, _), Rotas),
    findall(
        Impacto-Transp-Rota,
        (member(Rota, Rotas),
         transportadora(Transp, _, _, _, _, AreasCobertura),
         verifica_cobertura_rota(Rota, AreasCobertura),
         impacto_ambiental_rota(Rota, Transp, Impacto)),
        ListaImpactos
    ),
    (ListaImpactos \= [] ->
        sort(ListaImpactos, [MenorImpacto-MelhorTransportadora-MelhorRota | _]),
        format('Melhor transportadora: ~w | Impacto: ~2f | Rota: ~w~n', [MelhorTransportadora, MenorImpacto, MelhorRota])
    ;
        format('Nenhuma transportadora válida encontrada para as rotas disponíveis.~n'),
        fail
    ).

% RF13 - Rota com distribuidor intermédio mais sustentável
% =============================
%
% impacto_total_de_rota(ListaNos, TransportadoraID, ImpactoTotal)
% Calcula o impacto ambiental total para uma rota (ListaNos) usando uma TransportadoraID.
%
impacto_total_de_rota([], _, 0).
impacto_total_de_rota([_], _, 0). % Rota com um único nó tem impacto 0
impacto_total_de_rota([No1, No2 | RestoNos], TransportadoraID, ImpactoTotal) :-
    conexao(No1, No2, Distancia), % Obtém distância entre No1 e No2
    transportadora(TransportadoraID, _, _, _, ImpactoPorKm, _), % O 5º arg é ImpactoAmbiental por km
    ImpactoSegmento is Distancia * ImpactoPorKm,
    impacto_total_de_rota([No2 | RestoNos], TransportadoraID, ImpactoRestante),
    ImpactoTotal is ImpactoSegmento + ImpactoRestante.

% melhor_transportadora_para_rota(ListaNos, Carga, MelhorTransportadoraID, MenorImpacto)
% Encontra a transportadora que minimiza o impacto para a rota ListaNos e Carga especificada.
melhor_transportadora_para_rota(ListaNos, Carga, MelhorTransportadoraID, MenorImpacto) :-
    findall(Impacto-TransID,
            (   transportadora(TransID, _, _, _, _, _), % Itera sobre todas as transportadoras
                transportadora_cobre(TransID, ListaNos),
                transportadora_suporta(TransID, Carga),
                impacto_total_de_rota(ListaNos, TransID, Impacto) % Usa o novo impacto_total_de_rota
            ),
            ListaImpactosTransportadoras),
    ListaImpactosTransportadoras \= [], % Garante que há pelo menos uma transportadora válida
    sort(ListaImpactosTransportadoras, [MenorImpacto-MelhorTransportadoraID | _]). % Pega a com menor impacto

% transportadora_suporta(TransportadoraID, Carga)
% Verifica se a TransportadoraID tem capacidade para a Carga.
transportadora_suporta(TransportadoraID, Carga) :-
    transportadora(TransportadoraID, _, CapacidadeCarga, _, _, _), % O 3º arg é CapacidadeCarga
    CapacidadeCarga >= Carga.

% transportadora_cobre(TransportadoraID, Nos)
% Verifica se a TransportadoraID cobre todas as regiões dos nós na ListaNos.
transportadora_cobre(TransportadoraID, Nos) :-
    transportadora(TransportadoraID, _, _, _, _, RegioesCobertas), % O 6º arg é a lista de regiões
    forall(
        (member(No, Nos),
         (quinta(No, _, LocalizacaoNo, _, _) ; distribuidor(No, _, LocalizacaoNo, _)), % Obtém localização do nó
         regiao(LocalizacaoNo, RegiaoNo)), % Converte localização para região
        member(RegiaoNo, RegioesCobertas) % Verifica se a região do nó está coberta
    ).

rota_com_intermedio_sustentavel(Origem, Destino, Intermedio, Carga,
                                RotaFinalEmPares, TransportadoraFinalID) :-
    % Validações iniciais
    distribuidor(Intermedio, _, _, _), % Garante que o Intermedio é um distribuidor
    Origem \= Intermedio,             % Origem deve ser diferente do Intermedio
    Intermedio \= Destino,            % Intermedio deve ser diferente do Destino
    Origem \= Destino,                % Origem deve ser diferente do Destino

    % 1. Calcular o impacto da melhor rota direta (Origem -> Destino)
    RotaDiretaNos = [Origem, Destino],
    (   melhor_transportadora_para_rota(RotaDiretaNos, Carga, _TransDiretaID, ImpactoDireta)
    ->  true % Impacto da rota direta foi calculado
    ;   write('Não foi encontrada transportadora válida para a rota direta.'), nl,
        !, fail % Se não há transportadora para a rota direta, não podemos comparar
    ),

    % 2. Calcular o impacto da melhor rota intermédia (Origem -> Intermedio -> Destino)
    RotaIntermediaNos = [Origem, Intermedio, Destino],
    (   melhor_transportadora_para_rota(RotaIntermediaNos, Carga, TransIntermediaID, ImpactoIntermedia)
    ->  true % Impacto da rota intermédia foi calculado
    ;   write('Não foi encontrada transportadora válida para a rota intermédia.'), nl,
        !, fail % Se não há transportadora para a rota intermédia, ela não pode ser escolhida
    ),

    % 3. Comparar os impactos
    % A rota intermédia deve ser estritamente mais sustentável (menor impacto)
    ImpactoIntermedia < ImpactoDireta,

    % 4. Se todas as condições foram satisfeitas, unificar as variáveis de saída
    RotaFinalEmPares = [Origem-Intermedio, Intermedio-Destino],
    TransportadoraFinalID = TransIntermediaID,

    format('Rota intermédia via ~w é mais sustentável (Impacto: ~2f) do que rota direta (Impacto: ~2f).~n',
           [Intermedio, ImpactoIntermedia, ImpactoDireta]),
    format('Transportadora para rota intermédia: ~w.~n', [TransportadoraFinalID]),
    format('Rota: ~w -> ~w -> ~w.~n', [Origem, Intermedio, Destino]).


%Predicado principal do RF14
% rf14_transportadora_ideal(ListaNosRota, CargaNecessaria, MelhorTransportadoraID, DetalhesTransportadora, MelhorScore)
rf14_transportadora_ideal(ListaNosRota, CargaNecessaria, MelhorTransportadoraID, DetalhesTransportadora, MelhorScore) :-
    findall(Score-TransID-Detalhes,
            (   transportadora(TransID, Nome, Capacidade, Combustivel, ImpactoKm, AreasCobertura),
                transportadora_cobre(TransID, ListaNosRota),
                transportadora_suporta(TransID, CargaNecessaria),
                impacto_total_de_rota(ListaNosRota, TransID, ImpactoRotaTotal),
                pontuacao_combustivel(Combustivel, ScoreCombustivel),
                Score is ImpactoRotaTotal + ScoreCombustivel, % Score final
                Detalhes = transportadora(TransID, Nome, Capacidade, Combustivel, ImpactoKm, AreasCobertura, ImpactoRotaTotal, Score) % Guardar detalhes relevantes
            ),
            ListaCandidatas),

    ListaCandidatas \= [], % Garante que há pelo menos uma transportadora candidata
    sort(ListaCandidatas, [MelhorScore-MelhorTransportadoraID-DetalhesTransportadora | _Outras]), % Sort pega a de menor score
    !. % Corta para encontrar apenas a melhor

% Interface para o utilizador (exemplo)
menu_rf14 :-
    format('~n--- RF14: Encontrar Transportadora Ideal para uma Rota ---~n'),
    % Obter ListaNosRota do utilizador
    % Pode pedir IDs separados por vírgula e converter para lista de números.
    % Exemplo simplificado:
    write('Insira os IDs dos nós da rota, separados por vírgula (ex: 1,2,3): '),
    read_line_to_string(user_input, RotaString),
    atomic_list_concat(AtomosRota, ',', RotaString),
    maplist(atom_number, AtomosRota, ListaNosRota),

    write('Insira a carga necessária (kg): '),
    read_line_to_string(user_input, CargaString),
    atom_number(CargaString, CargaNecessaria),

    (   rf14_transportadora_ideal(ListaNosRota, CargaNecessaria, ID, Detalhes, Score)
    ->  format('~nTransportadora Ideal Encontrada (Score: ~2f):~n', [Score]),
        % Detalhes é transportadora(TransID, Nome, Capacidade, Combustivel, ImpactoKm, AreasCobertura, ImpactoRotaTotalCalculado, ScoreCalculado)
        Detalhes = transportadora(ID, Nome, Cap, Comb, ImpKm, Areas, ImpRota, _ScoreDetalhes),
        format('  ID: ~w~n', [ID]),
        format('  Nome: ~w~n', [Nome]),
        format('  Capacidade: ~w kg~n', [Cap]),
        format('  Combustível: ~w~n', [Comb]),
        format('  Impacto por Km: ~w~n', [ImpKm]),
        format('  Áreas Cobertura: ~w~n', [Areas]),
        format('  Impacto Total Estimado para esta Rota: ~2f~n', [ImpRota])
    ;   format('~Nenhuma transportadora ideal encontrada para os critérios/rota especificados.~n')
    ).

% --- RF15: Listar Transportadoras por Tipo de Combustível ---

menu_rf15_listar_transportadoras_por_combustivel :-
    format('~n--- RF15: Listar Transportadoras por Tipo de Combustível ---~n'),
    listar_tipos_combustivel_disponiveis_rf15,
    write('Insira o tipo de combustível desejado: '),
    read_line_to_string(user_input, CombustivelInputString),
    atom_string(CombustivelInputAtom, CombustivelInputString),
    listar_transportadoras_do_tipo_rf15(CombustivelInputAtom).

listar_tipos_combustivel_disponiveis_rf15 :-
    setof(Combustivel, ID^Nome^Cap^Imp^Areas^transportadora(ID, Nome, Cap, Combustivel, Imp, Areas), ListaTipos),
    ( ListaTipos \= [] ->
        format('Tipos de combustível registados: ~w~n', [ListaTipos])
    ;
        format('Nenhum tipo de combustível registado para transportadoras.~n')
    ).

listar_transportadoras_do_tipo_rf15(TipoCombustivelDesejado) :-
    findall(transportadora(ID, Nome, Cap, TipoCombustivelDesejado, ImpKm, Areas),
            transportadora(ID, Nome, Cap, TipoCombustivelDesejado, ImpKm, Areas),
            ListaTransportadoras),
    ( ListaTransportadoras = [] ->
        format('Nenhuma transportadora encontrada com o tipo de combustível "~w".~n', [TipoCombustivelDesejado])
    ;
        format('~nTransportadoras que utilizam combustível "~w":~n', [TipoCombustivelDesejado]),
        imprimir_lista_transportadoras_rf15(ListaTransportadoras)
    ).

imprimir_lista_transportadoras_rf15([]).
imprimir_lista_transportadoras_rf15([transportadora(ID, Nome, Cap, _, ImpKm, Areas) | Resto]) :-
    format('  ID: ~w~n', [ID]),
    format('    Nome: ~w~n', [Nome]),
    format('    Capacidade: ~w kg~n', [Cap]),
    format('    Impacto/km: ~w~n', [ImpKm]),
    format('    Áreas Cobertura: ~w~n~n', [Areas]),
    imprimir_lista_transportadoras_rf15(Resto).
