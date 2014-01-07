#include "symbol_table.h"
#include <stdlib.h>
#include "stdio.h"

static struct wiki_node* symbol_table = NULL;
static struct wiki_scope* global_scope = NULL;

struct wiki_node* symbol_table_init(void)
{
    if (symbol_table == NULL)
    {
        symbol_table = malloc(sizeof(symbol_table));
    }
    return symbol_table;
}

void symbol_table_free()
{
    if (symbol_table != NULL)
    {
        free(symbol_table); 
        symbol_table = NULL;
    }
}

struct wiki_node* get_new_node(void)
{
    struct wiki_node* node = malloc(sizeof(struct wiki_node));
    if (node)
    {
        node->lexeme = NULL;
        node->value = NULL;
        node->type = -1;
        node->next = NULL;
        node->scope = NULL;
    }
    return node;
}
