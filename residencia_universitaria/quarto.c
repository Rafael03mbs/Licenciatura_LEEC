#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "messages.h"
#include "estudante.h"
#include "menu.h"
#include "sistema.h"
#include "quarto.h"
#include "gerente.h"
#include "candidatos.h"

#define NUM_MAX_ESTUDANTE 20000
#define NUM_MAX_GERENTE 1000
#define NUM_MAX_QUARTO 10000
#define NUM_MAX_LOCAL 500

quarto quartos[NUM_MAX_QUARTO];
int num_quartos = 0;

estudante estudantes[NUM_MAX_ESTUDANTE];
int num_estudantes = 0;

quarto* encontrar_quarto(char* codigo) {
    for (int i = 0; i < num_quartos; i++) {
        
        if (strcmp(quartos[i]->codigo, codigo) == 0) {
            return &quartos[i];
        }
    }
    return NULL;
}


void adicionar_estudante(char* login, char* nome, char* universidade) {
    estudante novo_estudante = (estudante)malloc(sizeof(estudante));
    strcpy(novo_estudante->login, login);
    strcpy(novo_estudante->nome_estudante, nome);
    strcpy(novo_estudante->uni_estudante, universidade);

    estudantes[num_estudantes] = novo_estudante;
    num_estudantes++;
    free(novo_estudante);
}
void remove_candidatos(char * nome_estudante)
{
    int j =0;
    for (int i = 0;  quartos[i] != NULL ; i++) 
        {
            for ( j = 0;  quartos[i]->estudante->alunos[j] != NULL ; j++)
            {
                if (strcmp(quartos[i]->estudante->alunos[j],nome_estudante)== 0)
                {
                    quartos[i]->estudante->num_candidatos--;
                    free(quartos[i]->estudante->alunos[j]);
                }
            } 
         }
    
}
void remove_quartos(char * cod_quarto)
{
    int j =0;
    for (int i = 0;  estudantes[i] != NULL ; i++) 
        {
            for ( j = 0;  estudantes[i]->quartos->alunos != NULL ; j++)
            {
                if (strcmp(estudantes[i]->quartos->alunos[j],cod_quarto)== 0)
                {
                    estudantes[i]->quartos->alunos--;
                    free(estudantes[i]->quartos->alunos);
                }
            } 
         }
    
}

void adicionar_quarto(char* codigo, char* localidade, char* universidade,int andar, char* residencia, char* gerente, char* descricao, quarto novo_quarto) {
    
    novo_quarto = (quarto)malloc(sizeof(struct base_quarto));
    strcpy(novo_quarto->codigo, codigo);
    strcpy(novo_quarto->localidade, localidade);
    strcpy(novo_quarto->universidade, universidade);
    strcpy(novo_quarto->residencia, residencia);
    novo_quarto->andar = andar;
    strcpy(novo_quarto->estado, "livre");
    strcpy(novo_quarto->gerente, gerente);
    strcpy(novo_quarto->descricao, descricao);
    quartos[num_quartos] = (quarto)malloc(sizeof(struct base_quarto));
    memcpy(quartos[num_quartos], novo_quarto, sizeof(struct base_quarto));

    num_quartos++;
    free(novo_quarto);
}
void destroiquarto(quarto q ){
    free(q);
}
void estado_quarto(quarto q,char * estado ){
    strcpy(estado,q->estado);
}
void mostrar_dados_quarto(quarto quartos) {
    printf("%s, ", quartos->codigo);
    printf("%s", quartos->residencia);
    printf("%s\n", quartos->universidade);
    printf("%s\n", quartos->localidade);
    printf("%d\n", quartos->andar);
    printf("%s\n", quartos->descricao);
    printf("%s\n", quartos->estado);
    //printf("Gerente: %s\n", quartos->gerente);
}

void mostrar_dados_estudante( estudante e ) {
    printf("Login: %s\n", e->login);
    printf("Nome: %s\n", e->nome_estudante);
    printf("Universidade: %s\n", e->uni_estudante);
}
void lista_candidatos(quarto q,sistema s)
{
    int i;char aluno[10];int posicao;
    for ( i = 0; q->estudante->alunos[i] != NULL ; i++)
    {
        strcpy(aluno,q->estudante->alunos[i]);
        posicao =encontrar_estudante_sistema(s,aluno);
        printf("%s,",s->student[posicao]->login);
        printf("%s,",s->student[posicao]->nome_estudante);
        printf("%s",s->student[posicao]->uni_estudante);
        printf("\n");
    }
    
}








