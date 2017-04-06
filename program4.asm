;*******************************************************************************
; Programming Assignment 4
; Journey Game
;
; This is the starter code. You are given several subroutines which you MUST NOT
; modify. The subroutines you are responsible for are given as empty stubs at
; the bottom. Follow the contract. You are free to rearrange YOUR subroutines
; if the need arises.
;*******************************************************************************

.ORIG x3000

;*******************************************************************************
; Main Program
;*******************************************************************************
                    LDI   R0, BLOCKS
                    JSR   LOAD_JOURNEY
                    JSR   DISPLAY_BOARD
GAMEON
                    TRAP  x20                       ; get a character from keyboard into R0
                    LD    R3, ASCII_Q_COMPLEMENT    ; load the 2's complement of ASCII 'Q'
                    ADD   R3, R0, R3                ; compare the first character with 'Q'
                    BRz   EXIT                      ; if input was 'Q', exit
                    JSR   IS_INPUT_VALID            ; convert i, j, k, l to up(0) left(1),
                                                    ; down(2), right(3) respectively
                    ADD   R2, R2, #0                ; R2 will be zero if the move was valid
                    BRz   VALID_INPUT
                    LEA   R0, INVALID_MOVE_STRING   ; if the input was invalid, output
                                                    ; corresponding message and go back to prompt
                    TRAP  x22
                    BR    GAMEON
VALID_INPUT
                    JSR   APPLY_MOVE                ; apply the move (input in R0)
                    JSR   DISPLAY_BOARD
                    JSR   IS_GAME_OVER
                    ADD   R2, R2, #0                ; R2 will be zero if reached end
                    BRnp  GAMEON                    ; otherwise, loop back
EXIT                LEA   R0, GOODBYE_STRING
                    TRAP  x22                       ; output a goodbye message
                    TRAP  x25                       ; halt

ASCII_Q_COMPLEMENT  .FILL    x-71
INVALID_MOVE_STRING .STRINGZ "\nInvalid Input (i, j, k, l)\n"
GOODBYE_STRING      .STRINGZ "\nJourney's End! Goodbye!\n"
BLOCKS              .FILL x4000

;*******************************************************************************
; DISPLAY_BOARD
;   Displays the current state of the GRID (game board)
;   Inputs: none
;   Outputs: none
;*******************************************************************************
DISPLAY_BOARD       ST    R0, DB_R0                 ; save registers
                    ST    R1, DB_R1
                    ST    R2, DB_R2
                    ST    R3, DB_R3
                    ST    R7, DB_R7
                    AND   R1, R1, #0                ; R1 will be loop counter
                    ADD   R1, R1, #8
                    LEA   R2, GRID                  ; R2 will be pointer to row
                    LEA   R3, COL                   ; R3 will be pointer to row number
                    ADD   R3, R3, #12
                    LD    R0, ASCII_NEWLINE
                    OUT
                    OUT
                    LEA   R0, COL
                    PUTS
DB_ROWOUT           LD    R0, ASCII_NEWLINE
                    OUT
                    ADD   R0, R3, #0                ; move address of row number to R0
                    PUTS
                    ADD   R0, R2, #0                ; move address of row to R0
                    PUTS
                    ADD   R2, R2, #10               ; increment R2 to point to next row
                    ADD   R3, R3, #3                ; increment R3 to point to next row number
                    ADD   R1, R1, #-1
                    BRzp  DB_ROWOUT
                    LD    R0, ASCII_NEWLINE
                    OUT
                    LD    R0, DB_R0                 ; restore registers
                    LD    R1, DB_R1
                    LD    R2, DB_R2
                    LD    R3, DB_R3
                    LD    R7, DB_R7
                    RET

DB_R0               .BLKW #1
DB_R1               .BLKW #1
DB_R2               .BLKW #1
DB_R3               .BLKW #1
DB_R7               .BLKW #1

;*******************************************************************************
; CAN_MOVE
;   Checks if a move is valid and returns the new position
;   Inputs: R0 - a move represented by ‘i’, ‘j’, ‘k’, or ‘l’
;   Outputs: R1, R2 - the new row and new col, respectively
;            if the move is to an invalid (blocked or outside the GRID), R1 = -1
;*******************************************************************************
CAN_MOVE
                    ST    R6, TRAN_R6               ; save registers
                    ST    R7, TRAN_R7
                    ST    R0, TRAN_R0
                    AND  R1, R1, #0
                    AND  R2, R2, #0
                    LD   R1, CURRENT_ROW
                    LD   R2, CURRENT_COL
                    LD   R6, CHAR_I
                    ADD  R6, R0, R6
                    BRnp NOT_I
                    ADD  R1, R1, #-1                ; i -> UP
                    BRn  INVALID_MOVE
                    BRzp DONE_RC
NOT_I
                    LD   R6, CHAR_J
                    ADD  R6, R0, R6
                    BRnp NOT_J
                    ADD  R2, R2, #-1                ; j -> LEFT
                    BRn  INVALID_MOVE
                    BRzp DONE_RC
NOT_J
                    LD   R6, CHAR_K
                    ADD  R6, R0, R6
                    BRnp NOT_K
                    ADD  R1, R1, #1                 ; k -> DOWN
                    ADD  R6, R1, #-3
                    BRp  INVALID_MOVE
                    BRnz DONE_RC
NOT_K
                    LD   R6, CHAR_L
                    ADD  R6, R0, R6
                    BRnp INVALID_MOVE
                    ADD  R2, R2, #1                 ; l -> RIGHT
                    ADD  R6, R2, #-3
                    BRp  INVALID_MOVE
DONE_RC                                             ; finished manipulating new row/col in R1, R2
                    JSR  GET_ADDRESS
                    LDR  R6, R0, #0
                    LD   R0, HASHTAG
                    ADD  R6, R0, R6
                    BRnp REST_TRAN                  ; if not hashtag then valid
INVALID_MOVE
                    AND  R1, R1, #0
                    ADD  R1, R1, #-1
REST_TRAN
                    LD    R6, TRAN_R6               ; restore registers
                    LD    R7, TRAN_R7
                    LD    R0, TRAN_R0
                    RET

TRAN_R6             .BLKW  1
TRAN_R7             .BLKW 1
TRAN_R0             .BLKW 1
CHAR_I              .FILL   x-69
CHAR_J              .FILL   x-6A
CHAR_K              .FILL   x-6B
CHAR_L              .FILL   x-6C
HASHTAG             .FILL   x-23

;*******************************************************************************
; Global constants used in program
;*******************************************************************************
COL                 .STRINGZ "   0 1 2 3 "
                    .STRINGZ "  "
ZERO                .STRINGZ "0 "
                    .STRINGZ "  "
ONE                 .STRINGZ "1 "
                    .STRINGZ "  "
TWO                 .STRINGZ "2 "
                    .STRINGZ "  "
THREE               .STRINGZ "3 "
                    .STRINGZ "  "
ASCII_OFFSET        .FILL   x0030
ASCII_NEWLINE       .FILL   x000A

;*******************************************************************************
; The data structure for the game board (GRID)
;*******************************************************************************
GRID                .STRINGZ "+-+-+-+-+"
ROW0                .STRINGZ "| | | | |"
                    .STRINGZ "+-+-+-+-+"
ROW1                .STRINGZ "| | | | |"
                    .STRINGZ "+-+-+-+-+"
ROW2                .STRINGZ "| | | | |"
                    .STRINGZ "+-+-+-+-+"
ROW3                .STRINGZ "| | | | |"
                    .STRINGZ "+-+-+-+-+"

;*******************************************************************************
; Variables to store the current position of player and the End point
;*******************************************************************************
CURRENT_ROW         .BLKW   1           ; row position of the player
CURRENT_COL         .BLKW   1           ; col position of the player
END_ROW             .BLKW   1           ; row position of the End point
END_COL             .BLKW   1           ; col position of the End point

;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
; The code above is provided for you.
; DO NOT MODIFY THE CODE ABOVE THIS LINE.
;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
;*******************************************************************************

;*******************************************************************************
; LOAD_JOURNEY
;
; This subroutine reads the input linked list and appropriately populates the
; contents of the GRID. See manual for the description of the input format.
;   Inputs: R0 - the address of the head of the linked list of space records
;       *** See instruction manual for details.
;   Outputs: populates the GRID with the space characters (*, E, #)
;       Additionally, set the following variables:
;       * CURRENT_ROW - initialize with the row of the Start point
;       * CURRENT_COL - initialize with the column of the Start point
;       * END_ROW - initialize with the row of the End point
;       * END_COL - initialize with the column of the End point
;*******************************************************************************
LOAD_JOURNEY

                    RET

;*******************************************************************************
; GET_ADDRESS
;
; This subroutine is key. Several of the subroutines you write depend on (call)
; this subroutine to convert moves to addresses. It translates the (row, col)
; logical GRID coordinates of a space to the physical address in the GRID
; memory.
;   Inputs: R1 - row number [0, 3]; R2 - column number [0, 3]
;   Outputs: R0 - corresponding memory address of the space in the GRID
; Hint: There are 9 physical rows of characters and only 4 logical rows.
;*******************************************************************************
GET_ADDRESS

                    RET

;*******************************************************************************
; IS_INPUT_VALID
;
; This subroutine validates the player move to make sure it is one of the
; movement characters. All it does is check if a valid character is entered.
;   Inputs: R0 - a move represented by ‘i’, ‘j’, ‘k’, or ‘l’
;   Outputs: R2 - 0 = valid; -1 = invalid
;*******************************************************************************
IS_INPUT_VALID

                    RET

;*******************************************************************************
; APPLY_MOVE
;
; This subroutine makes the move if it can be completed. It checks if the
; movement is possible by calling CAN_MOVE which returns the coordinates of
; where the move goes (or -1 if movement is not possible). If the move is valid
; then this routine moves the player symbol to the new coordinates and clears
; any walls (|’s and -’s) necessary for the movement to take place. If the
; movement is blocked, output a console message of your choice and return. This
; subroutine should also change CURRENT_ROW and CURRENT_COL if appropriate.
;   Inputs: R0 - a move represented by ‘i’, ‘j’, ‘k’, or ‘l’
;   Outputs: none
; Note: This subroutine calls CAN_MOVE and GET_ADDRESS.
;*******************************************************************************
APPLY_MOVE

                    RET

;*******************************************************************************
; IS_GAME_OVER
;
; This subroutine determines if the game is over or not. That is, it checks to
; see if the player has reached the End point.
;   Inputs: none
;   Outputs: R2 - 0 if game over; -1 if game not over
;*******************************************************************************
IS_GAME_OVER

                    RET

.END
