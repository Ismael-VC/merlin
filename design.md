# Varavara/Uxn Concatenated Interpretive Uxntal Assembler REPL

```
Memory is organized as follows:

0000   0100     prev @here    current @here      @dict          @dict init  ffff
|      |        |             |                  |              |              |
v      v        v             v                  v              v              v
+------+--------+-------------+------------------+--------------+--------------+
| <ZP> | <repl> | <assembled> |     <unused>     | <func table> | <input buff> |
+------+--------+-------------+------------------+--------------+--------------+
                |------------->                  <--------------|
                                growth direction
```

This document explains how I want the interface with the operator to be, not 
what I have accomplished yet. :P

# Operator Interaction

```
Monocycle REPL
Varvara/Uxn Concatenated Interpretive Uxntal Assembler
© MMXXIV Ismael Venegas Castelló
???? bytes used, ???? bytes free.
փ [1337]> #2a18 DEO
*

փ [1337]> @star #2a18 DEO JMP2r  ( 5 bytes )

փ [133c]> ;star JSR2
*
```

## Under the Hood

A parent label starts assembly mode, this will do the following:

1. Assemble the input buffer and place the code after the current position
   of `@here`, and update the `@here` pointer.
2. Add an entry to the "dictionary" ("header" format still under design) and
   update it's pointer.

**Note**: `[` and `]` allow multiline input.

```
փ [1337]> @star ( -- ) [
    #2a18 DEO JMP2r
]

փ [133c]> star
*
```

**Doubts**: 
* `star` JSI semantics (but not syntax) will need to be adapted to jump
to an absolute address in REPL mode?
* How to allow multiline input without using `[ ]`?

### `@here`

The assembled code area will be concatenated as if assembling Uxntal normally.

```
| @here ( 1337 )
| a0 2a 18 17 6c  ( #2a18 DEO JMP2r )
|
∨ @here ( 133c )
```

### `@dict`

The dictionary will grow in the contrary direction at a constant size for each
entry. Instead of a linked list in tipycal Threaded Interpretive Languages 
(TILs), concatenating in inverse order to an array. When searching for a routine
searching from **last entry** to first as done by TILs is accomplished by 
starting the search from the "physical beginning" of the array, where the
current `@dict` pointer points to.

```
∧ @dict ( ????-n entry bytes )
|
| identifier                           addr
| s  t  a  r  ( pad to n max bytes )   1337
| 73 74 61 72 00 00 00 00 00 00 00 00  13 37
| @dict ( ???? )
| ( primitives )
```

## Reasoning

Concatenating instead of threading the routines allows for the usage of Uxntal
and not another Uxntal like language with new or different syntax though some
semantics may need to be adapted.

```
փ [1337]> @print-dec ( dec -- ) [
	DUP #64 DIV print-num/try
	DUP #0a DIV print-num/try
	( >> )
] ( 13 bytes )

փ [1344]> @print-num ( num -- ) [
	#0a DIVk MUL SUB [ LIT "0 ] ADD #18 DEO
	JMP2r
	&try ( num -- )
		DUP ?print-num
		POP JMP2r
] ( 19 bytes )

փ [1357]> #2a print-dec
42

փ [1357]>
```

In this case calling `print-dec` would fall through to `print-num` body as in
normal Uxntal, something that would not be possible with a tipical threaded
implementation.
