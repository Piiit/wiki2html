#include "symbol_table.h"
#include <stdlib.h>
#include "stdio.h"

static struct wiki_node* symbol_table = NULL;
static struct wiki_scope* global_scope = NULL;

struct wiki_node* symbol_table_init(void)
{
    if (symbol_table == NULL)
    {
        symbol_table = get_new_node();
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

void add_symbol(struct wiki_node* root, struct wiki_node* node)
{
    struct wiki_node* current = root;
    if (current->next != NULL)
        do {
            current = current->next;
        }
        while (current->next != NULL);
    current->next = node;
}

void print_symbol_table(struct wiki_node* root)
{
    struct wiki_node* current = root;
    if (current->next != NULL)
        do {
            current = current->next;
            printf("%s -> %s\n", current->lexeme, current->value);
        }
        while (current->next != NULL);
    else
        printf("%s -> %s\n", current->lexeme, current->value);
}

