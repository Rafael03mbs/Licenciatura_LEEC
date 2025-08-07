#ifndef _H_SEQUENCIA
#define _H_SEQUENCIA

struct base_candidato
{
	char * * alunos; // apontador para vector de enderecos de elementos
	int num_candidatos;
	int capacidade; // capacidade corrente do vector
};

typedef struct base_candidato * candidato;

candidato cria_candidatos();
void apagar_candidatos(candidato c);

void destroilista (candidato c );
int existe_candidatos(candidato *c);
void adicionar_candidato(candidato c, void * elem, int i);
void * remove_candidato(candidato c, int i);
int encontrar_candidato(candidato c,char* nome_estudante);

#endif
