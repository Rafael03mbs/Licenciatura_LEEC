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

gerente info_gerente(char* acesso, sistema_gerentes sg) {
    
    
    int posicao = encontrar_manager_sistema(sg, acesso);
    

        if (posicao == -1) 
    {
        printf("%s\n",MSG_GERENTE_INEXISTENTE);
        return NULL;
    }
    else 
    {
            printf("%s, ",login_gerente(sg->manager[posicao]));
            printf("%s\n",name_gerente(sg->manager[posicao])); 
            printf("%s\n",uni_gerente(sg->manager[posicao]));
        return NULL;
    }
}


char * login_gerente(gerente g )
{
    return g->login;
}
char * name_gerente(gerente g){
    return g->nome_gerente;
}
char * uni_gerente(gerente g){
    return g->universidade;
}

