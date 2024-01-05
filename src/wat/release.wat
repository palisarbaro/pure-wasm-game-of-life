(module
    (global $rnd (import "js" "rnd") (mut i64))
    (memory $0 1000 1000)
    (export "memory" (memory $0)) ;; layout buf1(buffSize=w*h*4(i32)), buff2(buffSize); coordshift(4(i32)*8(neighbours)*2(coords))
    (global $buf1 (mut i32) (i32.const 0))
    (global $buf2 (mut i32) (i32.const 0))
    (global $buffSize (mut i32) (i32.const 0))
    (global $coordshift (mut i32) (i32.const 0))
    (global $width (mut i32) (i32.const 0))
    (global $height (mut i32) (i32.const 0))
    (global $alive (mut i32) (i32.const 0xff00ff00))
    (global $dead (mut i32) (i32.const 0xff000000))
    (func $swapBuff 
        global.get $buf1
        global.get $buf2
        global.set $buf1
        global.set $buf2
    )
    (func $allocateBuff (param $w i32) (param $h i32) 
        local.get $w
        global.set $width

        local.get $h
        global.set $height

        ;; $buf1 = 0

        local.get $w
        local.get $h
        i32.const 4
        i32.mul
        i32.mul
        global.set $buffSize
        global.get $buffSize
        global.set $buf2

        global.get $buf2
        global.get $buffSize
        i32.add
        global.set $coordshift


        ;; init $coordshift
            global.get $coordshift
            i32.const -1              ;;x=-1
            i32.store offset=0
            global.get $coordshift
            i32.const -1              ;;y=-1
            i32.store offset=4

            global.get $coordshift
            i32.const -1              ;;x=-1
            i32.store offset=8
            global.get $coordshift
            i32.const 0              ;; y=0
            i32.store offset=12

            global.get $coordshift
            i32.const -1              ;;x=-1
            i32.store offset=16
            global.get $coordshift
            i32.const 1              ;; y=1
            i32.store offset=20

            global.get $coordshift
            i32.const 0              ;;x=0
            i32.store offset=24
            global.get $coordshift
            i32.const -1              ;; y=-1
            i32.store offset=28

            global.get $coordshift
            i32.const 0              ;;x=0
            i32.store offset=32
            global.get $coordshift
            i32.const 1              ;; y=1
            i32.store offset=36

            global.get $coordshift
            i32.const 1              ;;x=1
            i32.store offset=40
            global.get $coordshift
            i32.const -1              ;;y=-1
            i32.store offset=44

            global.get $coordshift
            i32.const 1              ;;x=1
            i32.store offset=48
            global.get $coordshift
            i32.const 0              ;; y=0
            i32.store offset=52

            global.get $coordshift
            i32.const 1              ;;x=1
            i32.store offset=56
            global.get $coordshift
            i32.const 1              ;; y=1
            i32.store offset=60
        ;;;;;;;;;;;;;;;


    )
    (func $clearBuff (param $start i32) (param $color i32)
        (local $end i32)
        local.get $start
        global.get $buffSize
        i32.add
        local.set $end
        (loop $for
            local.get $start
            local.get $color
            i32.store ;; store color to memory[start]

            local.get $start
            i32.const 4
            i32.add
            local.set $start ;; start +=4

            local.get $start
            local.get $end
            i32.lt_s ;; start < end
            br_if $for
        )
    )
    (func $getRand (result i32)
        global.get $rnd
        i64.const 1103515245
        i64.mul
        i64.const 12345
        i64.add
        global.set $rnd
        global.get $rnd
        i64.const 65536
        i64.div_u
        i32.wrap_i64
        i32.const 32768
        i32.rem_u
    )
    (func $rndBuff (param $start i32)
        (local $end i32)
        local.get $start
        global.get $buffSize
        i32.add
        local.set $end
        (loop $for
            local.get $start
            global.get $dead
            global.get $alive
            call $getRand
            i32.const 2
            i32.rem_u
            select
            i32.store ;; store color to memory[start]

            local.get $start
            i32.const 4
            i32.add
            local.set $start ;; start +=4

            local.get $start
            local.get $end
            i32.lt_s ;; start < end
            br_if $for
        )
    )

    (func $init(export "init") (param $w i32) (param $h i32) (result i32)
        (local $byte i32)
        nop
        local.get $w
        local.get $h
        call $allocateBuff
        ;; set buf1 to rnd
        global.get $buf1
        call $rndBuff


        ;; glider for 40x40
        ;; global.get $buf1
        ;; global.get $alive
        ;; i32.store  offset=1000

        ;; global.get $buf1
        ;; global.get $alive
        ;; i32.store  offset=1164

        ;; global.get $buf1
        ;; global.get $alive
        ;; i32.store  offset=1324

        ;; global.get $buf1
        ;; global.get $alive
        ;; i32.store  offset=1320

        ;; global.get $buf1
        ;; global.get $alive
        ;; i32.store  offset=1316

        ;; set buf2 to dead
        global.get $buf2
        global.get $dead
        call $clearBuff
        global.get $buf1
    )

    (func $calcNewState(export "calcNewState") (param $x i32) (param $y i32) (param $index i32) (result i32)
        (local $count i32)
        (local $shift i32)
        global.get $coordshift
        local.set $shift
        (loop $for
            local.get $shift
            i32.load ;; dx
            local.get $x
            i32.add ;; x+dx
            global.get $width
            i32.add
            global.get $width
            i32.rem_u ;; (x+dx+width)%width


            local.get $shift
            i32.load offset=4 ;; dy
            local.get $y
            i32.add ;; y+dy
            global.get $height
            i32.add
            global.get $height
            i32.rem_u ;; (y+dy+height)%height
            global.get $width
            i32.mul ;; ((y+dy+height)%height)*width
            i32.add ;; neighbor_index
            i32.const 4
            i32.mul;; neigbor_offset
            global.get $buf1
            i32.add ;; neighbor_ptr
            i32.load ;; neighbor_color
            global.get $alive
            i32.eq ;; neighbor_color == alive
            local.get $count
            i32.add 
            local.set $count;; count += (neighbor_color == alive) ? 1 : 0

            local.get $shift
            i32.const 8
            i32.add
            local.set $shift ;;  shift += 8 (skip 2 i32)

            local.get $shift

            i32.const 64 
            global.get $coordshift
            i32.add;; end of coordshift

            i32.lt_s ;; shift< end of coordshift
            br_if $for
        )
        local.get $index
        i32.const 4
        i32.mul ;; index offset
        global.get $buf1
        i32.add ;; ptr to buf1[index]
        i32.load
        global.get $alive
        i32.eq ;; cell == alive
        (if
            (then ;; alive cell
                global.get $alive
                global.get $dead
                local.get $count
                i32.const 2
                i32.sub
                i32.const 1
                i32.le_u
                select
                return
            )
            (else ;; dead cell
                global.get $alive
                global.get $dead
                local.get $count
                i32.const 3
                i32.eq
                select
                return
            )
        )
        i32.const 0xffff00ff
    )

    (func $step(export "step") (result i32)
        (local $index i32)
        (local $x i32)
        (local $y i32)
        (loop $for
            local.get $index
            global.get $width
            i32.div_u
            local.set $y

            local.get $index
            global.get $width
            i32.rem_u
            local.set $x
            
            local.get $index
            i32.const 4
            i32.mul
            global.get $buf2
            i32.add ;; stack: ptr to buf2[$index]

            local.get $x
            local.get $y
            local.get $index
            call $calcNewState   ;; stack:  ptr to buf2[$index], new color
        
            i32.store

            local.get $index
            i32.const 1
            i32.add
            local.set $index

            local.get $index
            global.get $buffSize
            i32.const 4
            i32.div_s
            i32.lt_s ;; while index < buffSize/4
            br_if $for
            
        )

        call $swapBuff
        global.get $buf1
    )
)
