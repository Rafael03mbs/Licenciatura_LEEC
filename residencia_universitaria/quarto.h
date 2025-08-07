#ifndef QUARTO_H_
#define QUARTO_H_

    
struct base_quarto {
    char codigo[20];
    char localidade[50];
    char universidade[50];
    char residencia[50];
    int andar;
    char estado[10];
    char gerente[50];
    char descricao[200];
    candidato estudante;
};

typedef struct base_quarto * quarto;
typedef struct base_candidato * candidato;

void adicionar_quarto(char* codigo, char* localidade, char* universidade,int andar, char* residencia, char* gerente, char* descricao, quarto novo_quarto);
void adicionar_estudante(char* login, char* nome, char* universidade);
quarto* encontrar_quarto(char* codigo);
void mostrar_dados_quarto(quarto quartos);
void mostrar_dados_estudante(estudante estudantes);
void destroiquarto(quarto q );
void estado_quarto(quarto q,char * estado );
void remove_candidatos(char * nome_estudante);
void remove_quartos(char * cod_quarto);
void lista_candidatos(quarto q,sistema s);



#endif
