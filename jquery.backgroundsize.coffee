{ extend, Tween, map } = $

_init = ( tween ) ->
  { elem, prop, end } = tween

  extend tween,
   start: _parse $( elem ).css prop
   end: _parse end
   set: yes

  { start, end } = tween

  map( endBg, ( val, i ) ->
               [ _rel_op, _amount ] = val
               return val unless _rel_op

               val[ 1 ] = start[ bgIndex ][ i ][ 1 ] + _amount * if _rel_op is '-='
                                                                     -1
                                                                 else
                                                                     1 ) for endBg, bgIndex in end

_parse = ( val ) ->
  for bg in val.split /\s*,\s*/
    for dim in bg.split /\s+/
      _match = dim
                .match ///
                        ^
                        (
                         [+-]
                         =
                        ) ?
                        (
                         [+-] ?
                         \d +
                         (?:
                          \.
                          \d *
                         ) ?
                        )
                        (
                         . *
                        )
                        $
                       ///
      [
       _match[ 1 ],
       parseFloat( _match[ 2 ] ),
       _match[ 3 ] or 'px'
      ]

_get = ( tween ) ->
  _parse $( tween.elem ).css tween.prop

_set = ( tween ) ->
  _init tween unless tween.set
  { elem,
    prop,
    pos,
    unit,
    start,
    end } = tween

  ( for bg, bgIndex in start
      _span = ( axis ) ->
        end[ bgIndex ][ axis ][ 1 ] - start[ bgIndex ][ axis ][ 1 ]
      _adjusted = ( axis ) ->
        start[ bgIndex ][ axis ][ 1 ] + pos * _span axis
      $( elem )
       .css prop,
            ( "#{ _adjusted axis }#{ unit }" for axis in [ 0, 1 ] )
             .join ' ' )
   .join ', '

extend Tween.propHooks,
 backgroundSize:
  get: _get
  set: _set
 backgroundPosition:
  get: _get
  set: _set
