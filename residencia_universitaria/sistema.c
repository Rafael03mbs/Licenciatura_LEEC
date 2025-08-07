#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "messages.h"
#include "estudante.h"
#include "menu.h"
#include "sistema.h"
#include "messages.h"
#include "quarto.h"
#include "gerente.h"
#include "candidatos.h"


#define NUM_MAX_ESTUDANTE 20000
#define NUM_MAX_GERENTE 20000
#define NUM_MAX_QUARTO 20000
#define NUM_MAX_LOCAL 20000

sistema cria_sistema()
{
    sistema s = malloc(sizeof(struct base_de_dados));
    if (s == NULL) {
        printf("Erro ao alocar memória para o sistema.\n");
        return NULL;
    }

    s->student = malloc(NUM_MAX_ESTUDANTE * sizeof(estudante));
    if (s->student == NULL) {
        printf("Erro ao alocar memória para os estudantes.\n");
        free(s);
        return NULL; 
    }
    s->num_logins = 0;
    return s;
}
sistema_gerentes cria_sistema_man()
{
 sistema_gerentes sg = malloc(sizeof(struct base_de_gerentes));
    if (sg == NULL) {
        printf("Erro ao alocar memória para o sistema.\n");
        free(sg);
        return NULL;
    }

    sg->manager = malloc(NUM_MAX_GERENTE * sizeof(gerente));
    if (sg->manager == NULL) {
        printf("Erro ao alocar memória para os estudantes.\n");
        free(sg);
        return NULL;
    }
    sg->num_logins_man=0;
    return sg;
}

void libertar_estudante(estudante e) {
    free(e);
}
void apagarDadosGerente(gerente g) {
    if (g != NULL) {
        // Limpar os campos de dados
        memset(g->login, 0, sizeof(g->login));
        memset(g->nome_gerente, 0, sizeof(g->nome_gerente));
        memset(g->universidade, 0, sizeof(g->universidade));

        // Liberar a memória ocupada pelo objeto gerente
        free(g);
    }
}

void liberta_sistema_man(sistema_gerentes sg) {
    if (sg != NULL) {
        // Liberar a memória dos gerentes
        if (sg->manager != NULL) {
            for (int i = 0; i < sg->num_logins_man; i++) {
                free(sg->manager[i]);
            }
            free(sg->manager);
        }
        
        // Resetar o sistema de gerentes para valores iniciais
        sg->manager = NULL;
        sg->num_logins_man = 0;

        // Liberar a memória do sistema de gerentes
        free(sg);
    }
}

void liberta_sistema(sistema s) {
    for (int i = 0; i < s->num_logins; i++) {
        libertar_estudante(s->student[i]);
    }
    free(s->student);
    free(s);
}
   


int encontrar_estudante_sistema(sistema s, char* username)
{
    
    if (s == NULL || s->student == NULL) {
        return -1; // Sistema ou lista de estudantes inválidos
    }

    for (int i = 0; i < s->num_logins; i++) {
        if (strcmp(s->student[i]->login, username) == 0) {
            
            return i;
        }
    }

    return -1; // Estudante não encontrado
}

int encontrar_manager_sistema(sistema_gerentes sg, char* username)
{
    
    if (sg == NULL || sg->manager == NULL) {
        return -1; // Sistema ou lista de estudantes inválidos
    }

    for (int i = 0; i < sg->num_logins_man; i++) {
        if (strcmp(sg->manager[i]->login, username) == 0) {
            return i;
        }
    }

    return -1; // Estudante não encontrado
}

void libertar_quarto(quarto q){
     free(q);
}

void adicionar_estudante_sistema(sistema s, char* login, char* name, int age, char* local, char* fct)
{
    if (s->num_logins >= NUM_MAX_ESTUDANTE) {
        printf("Limite máximo de estudantes alcançado.\n");
        return;
    }

    estudante e = malloc(sizeof(struct base_estudante));
    if (e == NULL) {
        printf("Erro ao alocar memória para o estudante.\n");
        return;
    }

    strcpy(e->login, login);
    strcpy(e->nome_estudante, name);
    e->idade = age;
    strcpy(e->local_residencia, local);
    strcpy(e->uni_estudante, fct);

    s->student[s->num_logins] = e;
    s->num_logins++;
    printf("Estudante adicionado com sucesso!\n");
}
void adicionar_gerente_sistema(sistema_gerentes sg, char* login, char* name,char* fct)
{
    if (sg->num_logins_man >= NUM_MAX_ESTUDANTE) {
        printf("Limite máximo de estudantes alcançado.\n");
        return;
    }

    gerente g = malloc(sizeof(struct base_gerente));
    if (g == NULL) {
        printf("Erro ao alocar memória para o estudante.\n");
        return;
    }

    strcpy(g->login, login);
    strcpy(g->nome_gerente, name);
    strcpy(g->universidade, fct);

    sg->manager[sg->num_logins_man] = g;
    sg->num_logins_man++;
    printf("Gerente adicionado com sucesso!\n");
}
