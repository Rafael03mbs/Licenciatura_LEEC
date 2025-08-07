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

int main() {
    char instrucao[100];
    char comando[5];
   
  
    estudante e = (estudante)malloc(sizeof(estudante));
    
    gerente gerente1 = (gerente)malloc(sizeof(struct base_gerente));

    quarto q = (quarto)malloc(sizeof(struct base_quarto));
    sistema s = cria_sistema();
    sistema_gerentes sg = cria_sistema_man();

    candidato c = cria_candidatos();
    do
    {   
        
        strcpy(comando,"");
        strcpy(instrucao,"");
        printf("Digite o comando: ");
        fgets(instrucao, sizeof(instrucao), stdin);
        instrucao[strcspn(instrucao, "\n")] = '\0'; // Remover o caractere de nova linha
        sscanf(instrucao, "%s", comando);
            if (instrucao[0]=='#')
            {
                printf("\n");
            }
            else if (strcmp(comando, "IE") == 0)
            {
                funcao_ie(instrucao, s);
            }

            else if (strcmp(comando, "DE") == 0)
            {
                funcao_de(instrucao, s);
            }
            else if (strcmp(comando, "IG") == 0)
            {
                funcao_ig(instrucao,sg, gerente1);
                
            }
            else if (strcmp(comando, "DG") == 0)
            {
                funcao_dg(instrucao,sg);
            }
            else if (strcmp(comando, "IQ") == 0)
            {
                funcao_iq(instrucao, sg,gerente1);
            }   
            else if (strcmp(comando, "DQ") == 0)
            {
                funcao_dq(instrucao, &q);
            }   
            else if (strcmp(comando, "MQ") == 0)
            {
                modificar_estado_quarto(instrucao,c);
            }    
            else if (strcmp(comando, "RQ") == 0)
            {
                remover_quarto(instrucao,c,&q);

            }    
            /*else if (strcmp(comando, "IC") == 0)
            {
                registrar_candidatura(instrucao, &c);
            }    
            else if (strcmp(comando, "AC") == 0)
            {
                aceita_candidato(instrucao,&c,s);
            }     
            else if (strcmp(comando, "LC") == 0)
            {
               funcao_lc(instrucao, s);
            }   */
            else if (strcmp(comando, "XS") == 0)
            {   
                free(e);
               /* free(gerente1);
                free(q);
                */
                apagar_candidatos(c);
                liberta_sistema(s);
                liberta_sistema_man(sg);

                printf(MSG_SAIR);
                printf("\n");
                return 0;
            }     
            else 
            {
                printf("%s\n",MSG_COMANDO_INVALIDO);
            }
            printf("\n");
    } while (1);
    return 0;
    }

