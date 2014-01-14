/*
 Rationale

 We have to define a scope in our wiki parser, basically because we want
 to have variables and handle them in a C-like stile regarding the scope.
 Moreover we might want to add some definitions to e.g. define a color for an entire scope
 (like set COLOR #ff00ff makes the entire paragraph of this color), but one might also want to change color in an inner-scope as well...

 Lorenzo & Piiiiiiiiiiiiiiiiiit (needs approval xD)

 */

#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

struct wiki_scope {
    /* Linked list... */
    char*                   name;
    struct wiki_scope*      parent;
};

/* node of a symbol table (keyword, variable...) */
struct wiki_node {
    /* the original input string debugging purpose */
    char*               lexeme;
    /* the resulting string after being parsed, might be equal to the lexeme
      NOTE: even if the string is equal to the lexeme, it is still *different*
      speaking of memory allocation...
      */
    char*               value;
    int                 type;
    /* Some additional information for the error routine */
    long line_number;
    long column_number;
    struct wiki_scope*  scope;
    /* Linked list... */
    struct wiki_node*   next;
};

/* Initialize the symbol table and return it
 * If the table is already initialized, then just return the pointer to the first entry
 */
struct wiki_node* symbol_table_init(void);

/* Allocate a new node, with default (clean) fields */
struct wiki_node* get_new_node(void);

/* Initialize the global scope and return it
 * If the scope is already initialized, then just return the global scope
 */
struct wiki_scope* scope_init(void);
struct wiki_scope* get_new_scope_node(char* name, struct wiki_scope* parent);

/**
 * Clean the global scope
 */
void scope_free(void);

/**
 * Set a particular scope to a node
 */
void set_scope(struct wiki_node* node, struct wiki_scope* scope);

/**
 * Compute the depth of the given scope
 * (1 is a single level (e.g. global scope), 2 is a second level and so on...
 */
int scope_depth(struct wiki_scope* deepest);

/**
 * Add symbol to the symbol table
 */
void add_symbol(struct wiki_node* root, struct wiki_node* node, struct wiki_scope* scope);

void add_keyword(char* keyword);

void symbol_table_free(void);

void print_symbol_table(struct wiki_node* root);

#endif /* SYMBOL_TABLE_H */
