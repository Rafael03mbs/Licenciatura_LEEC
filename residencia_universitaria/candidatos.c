
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


candidato cria_candidatos()
{
    candidato c;
    c = (candidato)malloc(sizeof(struct base_candidato));
    if(c==NULL) 
    {
    return NULL;
    }
    c->alunos = malloc(sizeof(c->alunos));
    if(c->alunos == NULL) 
    {
        free(c);
        return NULL;
    }
    c->num_candidatos = 0;
    return c;
}

void apagar_candidatos(candidato c) {
    if (c == NULL) {
        return;
    }
    
    for (int i = 0; i < c->num_candidatos; i++) {
        free(c->alunos[i]);
    }
    
    free(c->alunos);
    free(c);
}




int existe_candidatos(candidato *c){

    if((*c)->num_candidatos == 0)
        return 0;
    else
        return 1;
}                           
void adicionar_candidato(candidato c, void * elem, int i){

        for(int num = c->num_candidatos; num>=i; num--) {
            c->alunos[num] = c->alunos[num-1];
        }
        c->alunos[i-1] = elem;
        c->alunos++;
}


void * remove_candidato(candidato c, int i){
    void* a;

    a = c->alunos[i-1];

    for(; i < c->num_candidatos; i++) {
        c->alunos[i-1] = c->alunos[i];
    }
    c->num_candidatos--;
    return a;
}
int encontrar_candidato(candidato c,char* nome_estudante) {
    for (int i = 0; i < c->num_candidatos; i++) {
        
        if (strcmp(c->alunos[i], nome_estudante) == 0) {
            return 1;
        }
    }
    return 0;
}
