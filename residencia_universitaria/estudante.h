#ifndef ESTUDANTE_H_
#define ESTUDANTE_H_

typedef struct base_candidato * candidato;

struct base_estudante {
    char login[50];
    char nome_estudante[100];
    int idade;
    char local_residencia[100];
    char uni_estudante[100];
    int num_candidaturas_ativ;
    candidato quartos;
};

typedef struct base_estudante * estudante;
typedef struct base_de_dados* sistema;

/***********************************************
ENCONTRAR ESTUDANTE
vê em todos os elementos da estrutura se um certo username existe ou não
Parametros:
username= login dado no imput para comparar com os da estrutura para ver se existe algum igual

Retorna: -1 caso o username não exista
i caso o username exista dando assim a posicao do mesmo
***********************************************/

estudante info_estudante(char* acesso, sistema s);
/***********************************************
INFO ESTUDANTE
vê se o user existe e caso existe lista a informacao do estudante
Parametros:
posicao= atraves do encontrar_estudante vê se o login existe e qual é a posicao

Retorna: NULL

***********************************************/
int num_de_candidaturas(estudante e);
char * login_estudante(estudante e);
char * name_estudante(estudante e);
char * uni_estudante(estudante e);
char * local_estudante(estudante e);
int idade_estudante(estudante e);

#endif
