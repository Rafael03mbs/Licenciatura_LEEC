#ifndef GERENTE_H_
#define GERENTE_H_

struct base_gerente {
    char login[10];
    char nome_gerente[100];
    char universidade[100];
};
typedef struct base_gerente * gerente;


gerente info_gerente(char* acesso, sistema_gerentes sg);
char * login_gerente(gerente g );
char * name_gerente(gerente g);
char * uni_gerente(gerente g);



#endif