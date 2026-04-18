# Framed RTL

This directory is reserved for framed-pipe variants.

The intent is to keep the current scalar baseline in `rtl/scalar/` stable while new framing-oriented designs are explored here.

```
                 _____________________
                |  pipe-framed01.v    |
                |                     |
                |    pipe_ctrl.v      |
                |        |            |
                |        V            |
pipe-framer.v ->| pipe-framed-data.v  |
                |        A            |
                |        |            |
                | pipe-framed-stage.v |     
                `_____________________'
```