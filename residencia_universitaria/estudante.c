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

estudante info_estudante(char* acesso, sistema s) {
    
    
    int posicao = encontrar_estudante_sistema(s, acesso);
    

        if (posicao == -1) 
    {
        printf("%s\n",MSG_ESTUDANTE_INEXISTENTE);
        return NULL;
    }
    else 
    {
            printf("%s, ",login_estudante(s->student[posicao]));
            printf("%s, ",name_estudante(s->student[posicao]));
            printf("%d idade, ",idade_estudante(s->student[posicao]));
            printf("%s\n",local_estudante(s->student[posicao]));
            printf("%s",uni_estudante(s->student[posicao]));
        return NULL;
    }
}


int num_de_candidaturas(estudante e){
    return e->num_candidaturas_ativ;
}
char * login_estudante(estudante e)
{
    return e->login;
}
char * name_estudante(estudante e){
    return e->nome_estudante;
}
int idade_estudante(estudante e){
    return e->idade;
}
char * local_estudante(estudante e){
    return e->local_residencia;
}
char * uni_estudante(estudante e){
    return e->uni_estudante;
}


