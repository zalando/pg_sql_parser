grammar SelectStmtGrammar;

import CommonParserRules;


// http://www.postgresql.org/docs/9.1/static/queries-overview.html
// http://www.postgresql.org/docs/9.1/static/sql-select.html
// http://www.postgresql.org/docs/9.1/static/plpgsql-statements.html


// see http://www.postgresql.org/docs/9.1/static/queries-overview.html
selectStmt : select ';' ;

// TODO we leave WINDOW out for now
// (WITH withQueries)? 
select :  SELECT  selectList
			(    
//			   intoClause?     // necessary for selectStmt
			   fromClause
//			   whereClause?
//		       groupByClause?
//			   havingClause?
//			   bulkOperationClause?
//			   orderByClause?
//			   limitClause?
//			   offsetClause?
//			   fetchClause?
//			   forClause?
			)? 
			;

selectList          : (ALL | distinctClause )?  ( selectAll | selectSpecific );
distinctClause      : DISTINCT ON expression (',' expression)* ;
selectSpecific      : expression (',' expression)* ; // TODO make labels AS label=ID -> as expression
selectAll           : '*';


intoClause     : INTO   strict=STRICT? target=ID ;
limitClause    : LIMIT  limit=( INTEGER_VALUE | ALL ) ;
offsetClause   : OFFSET offset=INTEGER_VALUE (ROW | ROWS)? ;

orderByClause  : ORDER_BY orderByItem (',' orderByItem)*;
orderByItem    : expression  ordering=( ASC | DESC )?  nullsOrdering ? # standardOrdering
			   | expression orderByUsing nullsOrdering ?               # usingOrdering
			   ;	
				
orderByUsing   :  USING operator=(LT | LTE | GT | GTE);
 
nullsOrdering  : NULLS  ordering=( FIRST | LAST  );

//withQueries    : ;

// http://www.postgresql.org/docs/9.1/static/sql-select.html#SQL-FROM
fromClause        : FROM  tableExpression (',' tableExpression);

// TODO not finished yet
tableExpression   : (only=ONLY)? tableName=QNAME ('*')? (AS?  alias=ID columnAlias)?  # fromTable
				  | '(' select ')' AS? alias=ID  columnAlias?                         # fromSelect
			      ;

columnAlias     : '(' columnAliasItem (',' columnAliasItem)* ')' ;
columnAliasItem : ID;


whereClause         : WHERE    condition;
groupByClause       : GROUP_BY expression ; 
havingClause        : HAVING   condition;
bulkOperationClause : ( operator=( UNION | INTERSECT | EXCEPT )   selectMode=(ALL | DISTINCT) select)? ;


condition : booleanExpr;


// In this syntax, to write anything except a simple integer constant for start or count, 
// you must write parentheses around it. If count is omitted in a FETCH clause, it defaults to 1. 
// ROW and ROWS as well as FIRST and NEXT are noise words that don't influence the effects of these clauses
fetchClause  : FETCH  (FIRST | NEXT )? (count=INTEGER_VALUE)?  (ROW | ROWS)? ONLY;

forClause    :  FOR lockMode=(UPDATE | SHARE)  (lockedTables)?  nowait=NOWAIT?;
lockedTables : OF lockedTable (',' lockedTable)*;
lockedTable  : ID;

