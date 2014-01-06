/*
 Rationale

 We have to define a scope in our wiki parser, basically because we want
 to have variables and handle them in a C-like stile regarding the scope.
 Moreover we might want to add some definitions to e.g. define a color for an entire scope
 (like set COLOR #ff00ff makes the entire paragraph of this color), but one might also want to change color in an inner-scope as well...

 Lorenzo & Piiiiiiiiiiiiiiiiiit (needs approval xD)

 */


struct wiki_scope {
    /* Linked list... */
    struct wiki_scope    *parent;
};

/* node of a symbol table (keyword, variable...) */
struct wiki_node {
    // TODO make it dynamic (for example a simple linked list of characters, or just using OS provided malloc())
    char*         lexeme;
    struct wiki_scope   *scope;
    /* Linked list... */
    struct wiki_node*   next;
};

/* Initialize the symbol table and return it
 * If the table is already initialized, then just return the pointer to the first entry
 */
struct wiki_node* symbol_table_init(void);
/* Initialize the global scope and return it
 * If the scope is already initialized, then just return the global scope
 */
int scope_init(struct wiki_scope* node);
void add_keyword(char* keyword);
void scope_free(void);
void symbol_table_free(void);
