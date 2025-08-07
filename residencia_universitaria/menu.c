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

char* juntanome(char nome[], char apelido[]){

    char espaco []= " ";


    strcat(nome, espaco);
    nome = strcat(nome, apelido);
    
    return nome;
}


void funcao_ie(char* instrucao, sistema s) {
    char nome[20];
    char apelido[20];
    char com[5];
    char comando2[100];

    estudante e = malloc(sizeof(struct base_estudante));
    memset(e, 0, sizeof(struct base_estudante));

   

    strcpy(nome, "");
    strcpy(apelido, "");
    strcpy(com, "");
    strcpy(comando2, "");
    
    if (e == NULL)
    {
        printf("%s\n", MSG_COMANDO_INVALIDO);
        free(e);
        return;
    }

    sscanf(instrucao, "%s %s %s %s", com, e->login, nome, apelido);
    strcpy(e->nome_estudante, juntanome(nome, apelido));

    e->idade = 0;
    fgets(comando2, sizeof(comando2), stdin);
    sscanf(comando2, "%d %s", &e->idade, e->local_residencia);

    fgets(e->uni_estudante, sizeof(e->uni_estudante), stdin);

    // Verificar se o login do estudante já existe
    if (encontrar_estudante_sistema(s, e->login) != -1) {
        printf("%s\n", MSG_UTILIZADOR_EXISTENTE);
        free(e);
        return;
    }

    // Adicionar o novo estudante ao sistema
    adicionar_estudante_sistema(s, e->login, e->nome_estudante, e->idade, e->local_residencia, e->uni_estudante);
    free(e);

    //printf("%s\n", MSG_REGISTO_ESTUDANTE_OK);
}

void funcao_de(char* instrucao, sistema s) {

    char com[5];
    char acesso[10];

    strcpy(com, "");
    strcpy(acesso, "");
    
    
    sscanf(instrucao, "%s %s", com, acesso);
    //printf("%s,%s",com,acesso);
    
    info_estudante(acesso, s);
            
               
    }
void funcao_ig(char* instrucao, sistema_gerentes sg, gerente g) {
    char nome[20];
    char apelido[20];
    char com[5];
    char comando2[100];

  

    strcpy(nome, "");
    strcpy(apelido, "");
    strcpy(com, "");
    strcpy(comando2, "");
    
    if (g == NULL)
    {
        printf("%s\n", MSG_COMANDO_INVALIDO);
        free(g);
        return;
    }


    sscanf(instrucao, "%s %s %s %s", com, g->login, nome, apelido);
    strcpy(g->nome_gerente, juntanome(nome, apelido));
    fgets(g->universidade, sizeof(g->universidade), stdin);
    g->universidade[strcspn(g->universidade, "\n")] = '\0';

    // Verificar se o login do estudante já existe
    if (encontrar_manager_sistema(sg, g->login) != -1) {
        printf("%s\n", MSG_UTILIZADOR_EXISTENTE);
        free(g);
        return;
    }

    // Adicionar o novo estudante ao sistema
    adicionar_gerente_sistema(sg, g->login,g->nome_gerente,g->universidade);
    
    
    
}

void funcao_dg(char* instrucao, sistema_gerentes sg) {

    char com[5];
    char acesso[10];

    strcpy(com, "");
    strcpy(acesso, "");
    
    
    sscanf(instrucao, "%s %s", com, acesso);
    //printf("%s,%s",com,acesso);
    
    info_gerente(acesso,sg);
            
               
}

void funcao_iq(char* instrucao, sistema_gerentes sg,gerente g) {
    char com[5];
    char codigo[50];
    char login[20];
    char residencia[50];
    char universidade[50];
    char localidade[50];
    char andar_c[5];
    char descricao[200];
   

    // Analisar os argumentos do comando a partir da string 'instrucao' usando sscanf ou outros métodos adequados
    sscanf(instrucao, "%s %s %s", com, codigo, login);
    
    fgets(residencia, sizeof(residencia), stdin);
    residencia[strcspn(residencia, "\n")] = '\0';
    
    fgets(universidade, sizeof(universidade), stdin);
    universidade[strcspn(universidade, "\n")] = '\0';
    
    fgets(localidade, sizeof(localidade), stdin);
    localidade[strcspn(localidade, "\n")] = '\0';

    fgets(andar_c, sizeof(andar_c), stdin);
    andar_c[strcspn(andar_c, "\n")] = '\0';

    fgets(descricao, sizeof(descricao), stdin);
    descricao[strcspn(descricao, "\n")] = '\0';


    // Verificar se o código do quarto é único
    quarto* quarto_existente = encontrar_quarto(codigo);

    if (quarto_existente != NULL) {
        printf("%s\n",MSG_QUARTO_EXISTENTE);
        return;
    }

    int indice_gerente = encontrar_manager_sistema(sg, login);

    if (indice_gerente == -1) 
    { 
        printf("%s\n",MSG_GERENTE_INEXISTENTE);
        return;
    }
    else
    {  
        if(strcmp(sg->manager[indice_gerente]->universidade,universidade)==0)
        {
            
            // Criar um novo objeto de quarto e atribuir as informações fornecidas
            quarto novo_quarto = (quarto)malloc(sizeof(struct base_quarto));
            novo_quarto->andar = atoi(andar_c);

            strcpy(novo_quarto->codigo, codigo);
            strcpy(novo_quarto->localidade, localidade);
            strcpy(novo_quarto->universidade, universidade);
            strcpy(novo_quarto->residencia, residencia);
            strcpy(novo_quarto->estado, "livre");
            strcpy(novo_quarto->gerente, login);
            strcpy(novo_quarto->descricao, descricao);
    
            // Adicionar o novo quarto ao sistema
            adicionar_quarto(novo_quarto->codigo, novo_quarto->localidade, novo_quarto->universidade,novo_quarto->andar, novo_quarto->residencia, novo_quarto->gerente, novo_quarto->descricao, novo_quarto);

            
            //printf("codigo: %s \nlocalidade:%suniversidade: %sandar: %d\nresidencia: %sgerente: %sdescricao: %s",novo_quarto->codigo, novo_quarto->localidade, novo_quarto->universidade,novo_quarto->andar, novo_quarto->residencia, novo_quarto->gerente, novo_quarto->descricao);
            printf("%s\n",MSG_REGISTO_QUARTO_OK  );
            free(novo_quarto);
        }
        else
        {
            printf("%s\n",MSG_OP_NAO_AUTORIZADA );
        }
    }  
}



void funcao_dq(char* instrucao, quarto* q) {
    char com[5];
    char codigo[50];

    sscanf(instrucao, "%s %s", com, codigo);
    q = encontrar_quarto(codigo);
    if (q != NULL) {
        mostrar_dados_quarto(*q);
    } else {
        printf("%s\n",MSG_QUARTO_INEXISTENTE);
    }
}

void modificar_estado_quarto(char* instrucao, candidato c) 
{
    char com[5];
    char codigo[50];
    char gerente[15];
    char estado[10];
    sscanf(instrucao, "%s %s %s %s", com, codigo, gerente, estado);
    quarto* q = encontrar_quarto(codigo);
    if (q != NULL) {
        if (strcmp((*q)->gerente, gerente) == 0) {
            if (strcmp(estado, "ocupado") == 0) {
                if (existe_candidatos(&c) != 0) {
                    printf("%s\n", MSG_CANDIDATURAS_ACTIVAS);
                    return;
                }
            }
            strcpy((*q)->estado, estado);
            printf("%s\n", MSG_QUARTO_ATUALIZADO);
        } else {
            printf("%s\n", MSG_OP_NAO_AUTORIZADA);
        }
    } else {
        printf("%s\n", MSG_QUARTO_INEXISTENTE);
    }
}

void remover_quarto(char* instrucao,candidato c,quarto* q)
{    

    char com[5];
    char codigo[50];
    char gerente [50];
    sscanf(instrucao, "%s %s %s", com, codigo,gerente);
    q=encontrar_quarto(codigo);
    if (q != NULL) {
        if (strcmp((*q)->gerente, gerente) == 0) {
                if (existe_candidatos(&c) != 0) 
                {
                    printf("%s\n",MSG_CANDIDATURAS_ACTIVAS);
                    return;
                }
                else
                {
                    free(*q);
                    printf("%s\n",MSG_REMOCAO_QUARTO_OK);
                }
        } else {
            printf("%s\n",MSG_OP_NAO_AUTORIZADA);
            
        }
    } else {
        printf("%s\n",MSG_QUARTO_INEXISTENTE);
        
    }
}

/*void registrar_candidatura(char* instrucao, candidato* candidatos) {
    char com[5];
    char codigo_quarto[50];
    char login[15];
    sscanf(instrucao, "%s %s %s", com,login,codigo_quarto);
    candidatos->alunos = NULL;  // Initialize to NULL
    candidatos->num_candidatos = 0;
    candidatos->capacidade = 0;
    // Verificar se o quarto existe no sistema
    quarto* quarto_existente = encontrar_quarto(codigo_quarto);
    if (quarto_existente == NULL) {
        printf(MSG_QUARTO_INEXISTENTE);
        return;
    }

    // Verificar se o estudante já possui uma candidatura ativa para o quarto
    for (int i = 0; i < candidatos->num_candidatos; i += 2) {
        if (strcmp(candidatos->alunos[i], login) == 0 && strcmp(candidatos->alunos[i + 1], codigo_quarto) == 0) {
            printf(MSG_CANDIDATURA_EXISTENTE);
            return;
        }
    }

    // Verificar se há capacidade para adicionar um novo candidato
    if (candidatos->num_candidatos >= candidatos->capacidade) {
        // Aumentar a capacidade do vetor de candidatos
        candidatos->capacidade *= 2;
        candidatos->alunos = realloc(candidatos->alunos, candidatos->capacidade * sizeof(char*));
    }

    // Adicionar o novo candidato à lista de candidatos
    candidatos->alunos[candidatos->num_candidatos] = strdup(login);
    candidatos->alunos[candidatos->num_candidatos + 1] = strdup(codigo_quarto);
    candidatos->num_candidatos += 2;

    printf(MSG_REGISTO_CANDIDATURA_OK);
}

void aceita_candidato(char* instrucao,candidato *c,sistema s)
{
    estudante e = malloc(sizeof(struct base_estudante));
    quarto q1 = malloc(sizeof(quarto));
    char com[5];
    char codigo[50];
    char estudante[15];
    char gerente[15];
    char estado[10]="ocupado";
    sscanf(instrucao, "%s %s %s %s", com,codigo,gerente,estudante);
    quarto* q = encontrar_quarto(codigo);
        if (q != NULL)
        {
            if(strcmp(q1->gerente,gerente)== 0)
            {
                if (encontrar_candidato(q1->estudante,estudante)== 1)
                {
                    strcpy(q1->estado,estado);
                    free(e->quartos->alunos);
                    e->quartos->num_candidatos =0;
                    q1->estudante->num_candidatos =0;
                    free(q1->estudante->alunos);
                    remove_candidatos(estudante);
                    remove_quartos(codigo);
                }
                else
                    {
                    printf(MSG_CANDIDATURA_INEXISTENTE);
                    }
            }  
            else
            {
                printf(MSG_OP_NAO_AUTORIZADA);
            }
        }
        else  
        {
        printf("Quarto não encontrado.\n");
        }
}
void funcao_lc(char* instrucao,sistema s)
{
    quarto q1 = malloc(sizeof(quarto));
    char com[5];
    char codigo[50];
    char estudante[15];
    char gerente[15];
    sscanf(instrucao, "%s %s %s", com,codigo,gerente);
    quarto* q = encontrar_quarto(codigo);
        if (q != NULL)
        {
            if(strcmp(q1->gerente,gerente)== 0)
            {
                if (encontrar_candidato(q1->estudante,estudante)== 1)
                {
                   lista_candidatos(q1,s);
                }
                else
                    {
                    printf(MSG_CANDIDATURA_INEXISTENTE);
                    }
            }  
            else
            {
                printf(MSG_OP_NAO_AUTORIZADA);
            }
        }
        else  
        {
        printf(MSG_QUARTO_INEXISTENTE);
        }
}*/