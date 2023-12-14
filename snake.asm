;    set game state memory location
.equ    HEAD_X,         0x1000  ; Snake head's position on x
.equ    HEAD_Y,         0x1004  ; Snake head's position on y
.equ    TAIL_X,         0x1008  ; Snake tail's position on x
.equ    TAIL_Y,         0x100C  ; Snake tail's position on Y
.equ    SCORE,          0x1010  ; Score address
.equ    GSA,            0x1014  ; Game state array address

.equ    CP_VALID,       0x1200  ; Whether the checkpoint is valid.
.equ    CP_HEAD_X,      0x1204  ; Snake head's X coordinate. (Checkpoint)
.equ    CP_HEAD_Y,      0x1208  ; Snake head's Y coordinate. (Checkpoint)
.equ    CP_TAIL_X,      0x120C  ; Snake tail's X coordinate. (Checkpoint)
.equ    CP_TAIL_Y,      0x1210  ; Snake tail's Y coordinate. (Checkpoint)
.equ    CP_SCORE,       0x1214  ; Score. (Checkpoint)
.equ    CP_GSA,         0x1218  ; GSA. (Checkpoint)

.equ    LEDS,           0x2000  ; LED address
.equ    SEVEN_SEGS,     0x1198  ; 7-segment display addresses
.equ    RANDOM_NUM,     0x2010  ; Random number generator address
.equ    BUTTONS,        0x2030  ; Buttons addresses

; button state
.equ    BUTTON_NONE,    0
.equ    BUTTON_LEFT,    1
.equ    BUTTON_UP,      2
.equ    BUTTON_DOWN,    3
.equ    BUTTON_RIGHT,   4
.equ    BUTTON_CHECKPOINT,    5

; array state
.equ    DIR_LEFT,       1       ; leftward direction
.equ    DIR_UP,         2       ; upward direction
.equ    DIR_DOWN,       3       ; downward direction
.equ    DIR_RIGHT,      4       ; rightward direction
.equ    FOOD,           5       ; food

; constants
.equ    NB_ROWS,        8       ; number of rows
.equ    NB_COLS,        12      ; number of columns
.equ    NB_CELLS,       96      ; number of cells in GSA
.equ    RET_ATE_FOOD,   1       ; return value for hit_test when food was eaten
.equ    RET_COLLISION,  2       ; return value for hit_test when a collision was detected
.equ    ARG_HUNGRY,     0       ; a0 argument for move_snake when food wasn't eaten
.equ    ARG_FED,        1       ; a0 argument for move_snake when food was eaten


; initialize stack pointer
addi    sp, zero, LEDS

# question when should we remove the food we did it in hit test

; main
; arguments
;     none
;
; return values
;     This procedure should never return.
main:
 ; TODO: Finish this procedure.
 stw zero, CP_VALID(zero)


 init: 
     call init_game 

 get_inp: 

     addi t0, zero, 1
     slli t0, t0, 21 # timer 
     LOOP_TIME_1 :
         addi t0, t0, -1
         bne t0, zero, LOOP_TIME_1

     call get_input 
     addi t0, zero, 5
     beq v0, t0, check 

 hit: 
     call hit_test
     addi t0, zero, 1
     bne v0, t0, collide 

 score: 
     ldw t6, SCORE(zero)
     addi t6, t6, 1
     stw t6, SCORE(zero)
     call display_score
     addi a0, zero, 1
     call move_snake
     call create_food
     call save_checkpoint
     beq v0, zero, leds_draw

 blink: 
     call blink_score
     br leds_draw

 collide: 
     addi t0, zero, 2
     beq v0, t0, init_lost_game
     beq v0, zero, move

 init_lost_game:
     
     addi t0, zero, 1
     slli t0, t0, 21 # timer 
     LOOP_TIME_2 :
        addi t0, t0, -1
        bne t0, zero, LOOP_TIME_2

     br init

 move: 
     call move_snake 
     br leds_draw

 leds_draw: 
     call clear_leds
     call draw_array

     addi t0, zero, 1
     slli t0, t0, 21 # timer 
     LOOP_TIME_3 :
        addi t0, t0, -1
        bne t0, zero, LOOP_TIME_3

     br get_inp

 check: 
     call restore_checkpoint
     beq v0, zero, get_inp
     br blink

 ret


; BEGIN: clear_leds
clear_leds:
 stw zero, LEDS(zero)
 addi t4, zero, 0x0004
 stw zero, LEDS(t4)
 addi t4, t4, 0x0004
 stw zero, LEDS(t4)
 ret

; END: clear_leds


; BEGIN: set_pixel
set_pixel:

 srli t4, a0, 0x0002
 slli t4, t4, 0x0002
 sub a0, a0, t4
 slli t1, a0, 0x0003
 add t1, t1, a1
 addi t5, zero, 0x0001
 sll t1, t5, t1
 ldw t3, LEDS(t4)
 or t3, t3, t1
 stw t3, LEDS(t4)

 ret

; END: set_pixel


; BEGIN: display_score
display_score:
addi sp, sp, -4
stw ra, 0(sp)

ldw s0, SCORE(zero)
addi s2, zero, -1

loop_display:
    blt s0, zero, END_DISPLAY
    add s1, s0, zero
    addi s0, s0, -10
    addi s2, s2, 1
    br loop_display


END_DISPLAY:

slli s1, s1, 2
ldw s1, digit_map(s1)
stw s1, SEVEN_SEGS+12(zero)
slli s2, s2, 2
ldw s2, digit_map(s2)
stw s2, SEVEN_SEGS+8(zero)

ldw t0, digit_map(zero)
stw t0, SEVEN_SEGS+4(zero)
stw t0, SEVEN_SEGS(zero)


ldw ra, 0(sp)
addi sp, sp, 4

ret

; END: display_score

; BEGIN: init_game
init_game:

 addi sp, sp, -4
 stw ra, 0(sp)


 stw zero, HEAD_X(zero)
 stw zero, HEAD_Y(zero)
 stw zero, TAIL_X(zero)
 stw zero, TAIL_Y(zero)
 addi t0, zero, 4
 stw t0, GSA(zero)

 addi s0, zero, 4
 addi s1, zero, 384

 loop_initialize_gsa : 
     bge s0, s1, end_init_game
     stw zero, GSA(s0)
     addi s0, s0, 0x0004
     br loop_initialize_gsa

 end_init_game:
	call clear_leds
 call create_food
 call draw_array
 stw zero, SCORE(zero)
 call display_score # see if we have to do it

 ldw ra, 0(sp)
 addi sp, sp, 4

 ret

; END: init_game


; BEGIN: create_food
create_food:

 addi sp, sp, -4
 stw ra, 0(sp)

 LOOP_VALID:
     ldw t0, RANDOM_NUM(zero)
	  andi t0, t0, 255
	  blt t0, zero, LOOP_VALID
	  addi t1, zero, 96
	  bge t0, t1, LOOP_VALID
     slli t0, t0, 2
     ldw t2, GSA(t0)
     bne t2, zero, LOOP_VALID

 addi t7, zero, 5
 stw t7, GSA(t0)

 ldw ra, 0(sp)
 addi sp, sp, 4

 ret


; END: create_food


; BEGIN: hit_test
hit_test:

 addi sp, sp, -4
 stw ra, 0(sp)

 addi t7, zero, 0x0001
 ldw t0, HEAD_X(zero)
 ldw t1, HEAD_Y(zero)
 slli t2, t0, 0x0003
 add t2, t2, t1
 slli t2, t2, 0x0002
 ldw t2, GSA(t2)  # (current head direction)
 add v0, zero, zero

 add t6, zero, zero
 beq t2, t6, END_HIT # ask for no directions in the tail
 add t6, t6, t7
 beq t2, t6, LEFT_POSITION
 add t6, t6, t7
 beq t2, t6, UP_POSITION
 add t6, t6, t7
 beq t2, t6, DOWN_POSITION
 add t6, t6, t7
 beq t2, t6, RIGHT_POSITION

 LEFT_POSITION: # to see how to change leds
     sub t0, t0, t7
     br COMPARE_COLLISION_SCREEN

 UP_POSITION:
     sub t1, t1, t7
     br COMPARE_COLLISION_SCREEN

 DOWN_POSITION: 
     add t1, t1, t7
     br COMPARE_COLLISION_SCREEN

 RIGHT_POSITION:
     add t0, t0, t7
     br COMPARE_COLLISION_SCREEN


 COMPARE_COLLISION_SCREEN:
     blt t0, zero, COLLISION_SCREEN_OR_BODY
     addi t3, zero, 12
     bge t0, t3, COLLISION_SCREEN_OR_BODY
     blt t1, zero, COLLISION_SCREEN_OR_BODY
     addi t3, zero, 8
     bge t1, t3, COLLISION_SCREEN_OR_BODY
     br COMPARE_FOOD_OR_BODY

 COMPARE_FOOD_OR_BODY:
     slli t2, t0, 0x0003
     add t2, t2, t1
     slli t2, t2, 0x0002
     ldw t3, GSA(t2)
     addi t6, zero, 5
     beq t3, t6, COLLISION_FOOD
     addi t6, zero, 1
     blt t3, t6, END_HIT
     addi t6, zero, 6
     bge t3, t6, END_HIT


 COLLISION_SCREEN_OR_BODY:
     addi v0, zero, 2
     br END_HIT

 COLLISION_FOOD:
     addi v0, zero, 1
     br END_HIT

 END_HIT:

 ldw ra, 0(sp)
 addi sp, sp, 4

 ret

; END: hit_test


; BEGIN: get_input
get_input:

# push
 addi sp, sp, -4
 stw s0, 0(sp)

 addi sp, sp, -4
 stw s1, 0(sp)

 addi t1, zero, 0x0004
 ldw t2, BUTTONS(t1) 
 stw zero, BUTTONS(t1)
 add s0, zero, zero
 addi s1, zero, 0x0005
 addi s2, zero, 0x0010  # the 5th bit is set 

 loop :
     beq s1, s0, ENDING
     and t3, t2, s2
     addi t6, zero, 1
     addi t7, s1, -1
     srl t3, t3, t7
     beq t3, t6, ENDING  # comparaison pour que le bit vaut 1
     srli s2, s2, 0x0001  
     sub s1, s1, t6
     br loop

  ENDING :
     add v0, s1, zero
     ldw t0, HEAD_X(zero)
     ldw t1, HEAD_Y(zero)
     slli t2, t0, 0x0003
     add t2, t2, t1
     slli t2, t2, 0x0002
     ldw s3, GSA(t2)
     beq v0, zero, end_get_input
	 addi t5, zero, 5
	 beq v0, t5, end_get_input
     addi t5, zero, 1
     beq v0, t5, compare_left_right
     addi t5, zero, 2
     beq v0, t5, compare_up_down
     addi t5, zero, 3
     beq v0, t5, compare_down_up
     addi t5, zero, 4
     beq v0, t5, compare_right_left


    compare_left_right:
        addi t5, zero, 4
        beq s3, t5, not_change
        br change

    compare_up_down:
        addi t5, zero, 3
        beq s3, t5, not_change
        br change

    compare_down_up:
        addi t5, zero, 2
        beq s3, t5, not_change
        br change

    compare_right_left:
        addi t5, zero, 1
        beq s3, t5, not_change
        br change   
    

    change:
        stw v0, GSA(t2)
        add t2, zero, zero
        stw t2, BUTTONS(t1) # clear it

 not_change:
 add v0, zero, zero
 
 end_get_input:

# pop
 ldw s1, 0(sp)
 addi sp, sp, 4
 ldw s0, 0(sp)
 addi sp, sp, 4

 ret  
 # need to clear it



; END: get_input


; BEGIN: draw_array
draw_array:

 addi sp, sp, -4
 stw ra, 0(sp)

 add s0, zero, zero
 addi s1, zero, 384

 LOOP_DRAW : 
     add t0, s0, zero
     bge s0, s1, ENDING_DRAW
     ldw t1, GSA(s0)
     addi s0, s0, 0x0004
     beq t1, zero, LOOP_DRAW

     srli t2, t0, 0x0005 # X coordinate
     add a0, t2, zero # argument x
     slli t4, t2, 0x0003 # 8*X
     srli t5, t0, 0x0002 # (1/4) * j
     sub t6, t5, t4 # Y = (1/4)j - 8X
     add a1, t6, zero
     call set_pixel

     br LOOP_DRAW


 ENDING_DRAW :
 add a0, zero, zero
 add a1, zero, zero

 ldw ra, 0(sp)
 addi sp, sp, 4

 ret

 # what is the expected latency


; END: draw_array


; BEGIN: move_snake
move_snake:
 addi t7, zero, 0x0001
 ldw t0, HEAD_X(zero)
 ldw t1, HEAD_Y(zero)
 add t2, v0, zero # CHECK THE NEW HEAD DIRECTION (new direction)
 # not sure if we should use GSA or the register v0
 slli t2, t0, 0x0003
 add t2, t2, t1
 slli t2, t2, 0x0002
 ldw t2, GSA(t2)  # (current head direction)

 add t6, zero, zero
 beq t2, t6, NEXT_MOVE # ask for no directions in the tail
 add t6, t6, t7
 beq t2, t6, LEFT_HEAD_MOVE
 add t6, t6, t7
 beq t2, t6, UP_HEAD_MOVE
 add t6, t6, t7
 beq t2, t6, DOWN_HEAD_MOVE
 add t6, t6, t7
 beq t2, t6, RIGHT_HEAD_MOVE

 LEFT_HEAD_MOVE: # to see how to change leds
     sub t0, t0, t7
     stw t0, HEAD_X(zero) 
     br NEXT_MOVE

 UP_HEAD_MOVE:
     sub t1, t1, t7
     stw t1, HEAD_Y(zero)
     br NEXT_MOVE

 DOWN_HEAD_MOVE: 
     add t1, t1, t7
     stw t1, HEAD_Y(zero)
     br NEXT_MOVE

 RIGHT_HEAD_MOVE:
     add t0, t0, t7
     stw t0, HEAD_X(zero)
     br NEXT_MOVE


 NEXT_MOVE : 
     slli t3, t0, 0x0003
     add t3, t3, t1
     slli t3, t3, 0x0002 
     stw t2, GSA(t3) # new direction for the new head
     addi t7, zero, 1
     beq a0, t7, ENDING_MOVE # length stay the same
     ldw t4, TAIL_X(zero)
     ldw t5, TAIL_Y(zero)
     slli t0, t4, 0x0003
     add t0, t0, t5
     slli t0, t0, 0x0002
     ldw t3, GSA(t0)
     stw zero, GSA(t0)

     add t6, zero, zero
     beq t3, t6, ENDING_MOVE # ask for no directions in the tail
     add t6, t6, t7
     beq t3, t6, LEFT_TAIL_MOVE
     add t6, t6, t7
     beq t3, t6, UP_TAIL_MOVE
     add t6, t6, t7
     beq t3, t6, DOWN_TAIL_MOVE
     add t6, t6, t7
     beq t3, t6, RIGHT_TAIL_MOVE

     LEFT_TAIL_MOVE : # to see how to change leds
         sub t4, t4, t7
         stw t4, TAIL_X(zero)
         br ENDING_MOVE

     UP_TAIL_MOVE :
         sub t5, t5, t7
         stw t5, TAIL_Y(zero)
         br ENDING_MOVE

     DOWN_TAIL_MOVE : 
         add t5, t5, t7
         stw t5, TAIL_Y(zero)
         br ENDING_MOVE

     RIGHT_TAIL_MOVE :
         add t4, t4, t7
         stw t4, TAIL_X(zero)
         br ENDING_MOVE


 ENDING_MOVE :
     ret


 # ask if you are in x= 11 where should you go




; END: move_snake


; BEGIN: save_checkpoint
save_checkpoint:

 addi sp, sp, -4
 stw s0, 0(sp)

 ldw s0, SCORE(zero)

 loop_score:
     blt s0, zero, end_loop_score
     addi s0, s0, -10
     br loop_score


 end_loop_score:
     addi v0, zero, 0
     addi s0, s0, 10
     bne s0, zero, end_save
     addi v0, zero, 1
     stw v0, CP_VALID(zero)

     ldw t0, HEAD_X(zero)
     stw t0, CP_HEAD_X(zero)

     ldw t0, HEAD_Y(zero)
     stw t0, CP_HEAD_Y(zero)

     ldw t0, TAIL_X(zero)
     stw t0, CP_TAIL_X(zero)

     ldw t0, TAIL_Y(zero)
     stw t0, CP_TAIL_Y(zero)

     ldw t0, SCORE(zero)
     stw t0, CP_SCORE(zero)

 add s0, zero, zero
 addi s1, zero, 384

 LOOP_GSA : 
     bge s0, s1, end_save
     ldw t1, GSA(s0)
     stw t1, CP_GSA(s0)
     addi s0, s0, 0x0004
     br LOOP_GSA

 end_save:

 ldw s0, 0(sp)
 addi sp, sp, 4

 ret

; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:
 ldw v0, CP_VALID(zero)
 addi t1, zero, 1
 bne v0, t1, end_restore

 ldw t0, CP_HEAD_X(zero)
 stw t0, HEAD_X(zero)

 ldw t0, CP_HEAD_Y(zero)
 stw t0, HEAD_Y(zero)

 ldw t0, CP_TAIL_X(zero)
 stw t0, TAIL_X(zero)

 ldw t0, CP_TAIL_Y(zero)
 stw t0, TAIL_Y(zero)

 ldw t0, CP_SCORE(zero)
 stw t0, SCORE(zero)

 add s0, zero, zero
 addi s1, zero, 384

 LOOP_CP_GSA : 
     bge s0, s1, end_restore
     ldw t1, CP_GSA(s0)
     stw t1, GSA(s0)
     addi s0, s0, 0x0004
     br LOOP_CP_GSA

 end_restore:
 ret

; END: restore_checkpoint


; BEGIN: blink_score
blink_score:

 addi sp, sp, -4
 stw ra, 0(sp)

	
 add s4, zero, zero
 addi t3, zero, 3 

 blink_1:
		beq s4, t3, end_blink
		addi s4, s4, 1		
 		stw zero, SEVEN_SEGS(zero)
 		addi t1, zero, 4
 		stw zero, SEVEN_SEGS(t1)
 		addi t1, t1, 4
 		stw zero, SEVEN_SEGS(t1)
 		addi t1, t1, 4
 		stw zero, SEVEN_SEGS(t1)

 		addi t0, zero, 1
       slli t0, t0, 21 # timer 
    	LOOP_TIME_4 :
         addi t0, t0, -1
         bne t0, zero, LOOP_TIME_4 

 		call display_score

       addi t0, zero, 1
       slli t0, t0, 21 # timer 
    	LOOP_TIME_5 :
         addi t0, t0, -1
         bne t0, zero, LOOP_TIME_5

		br blink_1
	
 end_blink:

 ldw ra, 0(sp)
 addi sp, sp, 4

 ret 

; END: blink_score


digit_map:
 .word 0xFC ; 0
 .word 0x60 ; 1 
 .word 0xDA ; 2 
 .word 0xF2 ; 3 
 .word 0x66 ; 4 
 .word 0xB6 ; 5 
 .word 0xBE ; 6 
 .word 0xE0 ; 7 
 .word 0xFE ; 8 
 .word 0xF6 ; 9